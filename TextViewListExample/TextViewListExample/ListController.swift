//
//  ListController.swift
//  TextViewListExample
//
//  Created by Martin Pilkington on 02/04/2021.
//
//  Please read the LICENCE.txt for licensing information
//

import Cocoa

/// This exists as a separate class just for convenience of transferring from Coppice's code, but could be put into an NSTextView subclass if preferred
class ListController: NSObject {
    let textView: NSTextView
    init(textView: NSTextView) {
        self.textView = textView
    }

    func updateSelection(withListType listType: NSTextList?) {
        let (range, level) = ListCalculator().calculateListRangeAndLevel(in: self.textView)
        guard let editingRange = range else {
            return
        }

        var selectedLocation = self.textView.selectedRange().location

        self.textView.modifyText(in: [editingRange]) { (textStorage) in
            //The end of the text view is a special case, where we just append
            guard editingRange.location < textStorage.length else {
                if let list = listType {
                    self.add(list, toEndOf: textStorage)
                }
                return
            }

            //We want an copy of the old string as we need it to calculate the ranges of the old list markers to replace
            let oldString = textStorage.copy() as! NSAttributedString
            var replacements: [(NSRange, String, NSParagraphStyle)] = []
            textStorage.enumerateAttribute(.paragraphStyle, in: editingRange, options: []) { (attribute, effectiveRange, _) in
                guard
                    let oldParagraphStyle = attribute as? NSParagraphStyle,
                    let newParagraphStyle = oldParagraphStyle.mutableCopy() as? NSMutableParagraphStyle
                else {
                    return
                }

                var textLists = newParagraphStyle.textLists
                //If we're setting a list then we want to replace the list at the desired level
                if let listType = listType {
                    if (textLists.count > level) {
                        textLists[level] = listType
                    } else {
                        textLists = [listType]
                    }
                } else {
                    //If we have no list then we're removing all lists
                    textLists = []
                }
                newParagraphStyle.textLists = textLists

                //Update the paragraph style on the text storage
                textStorage.removeAttribute(.paragraphStyle, range: effectiveRange)
                textStorage.addAttribute(.paragraphStyle, value: newParagraphStyle, range: effectiveRange)

                //Enumerate the lines of the old attribute string to find our replacement ranges
                (oldString.string as NSString).enumerateSubstrings(in: effectiveRange, options: .byLines) { (substring, substringRange, effectiveRange, _) in
                    var existingRange = NSRange(location: substringRange.location, length: 0)
                    //If we had an old list then we want to calculate the marker so we can get its range for replacement
                    if let oldList = oldParagraphStyle.textLists.last {
                        var itemNumber = oldString.itemNumber(in: oldList, at: substringRange.location)
                        //We need to manually handle the startingItemNumber as itemNumber(in:at:) doesn't (despite being giving the list)
                        if (oldList.startingItemNumber > 1) {
                            itemNumber = oldList.startingItemNumber + (itemNumber - 1)
                        }
                        //We just need the length of the marker as the location is always the start of the line
                        //We also add 2 as we always have a tab before and after
                        existingRange.length = oldList.marker(forItemNumber: itemNumber).count + 2
                    }

                    //Add the range and text to replace. We don't actually replace here as we don't want to mess up enumerateAttributes()
                    if let list = textLists.last {
                        replacements.append((existingRange, "\t\(list.marker(forItemNumber: textStorage.itemNumber(in: list, at: substringRange.location)))\t", newParagraphStyle))
                    } else {
                        replacements.append((existingRange, "", newParagraphStyle))
                    }
                }
            }

            //Going from back to front (so the ranges remain valid) apply all the list replacements
            for (range, string, paragraphStyle) in replacements.reversed() {
                textStorage.replaceCharacters(in: range, with: string)
                //If we're adding a list then we need to make absolutely sure what is added has the paragraph style
                //This is especially true for the earliest range we're adding as it may use the attributes of the text before
                if (range.length == 0) {
                    let addedRange = NSRange(location: range.location, length: string.count)
                    textStorage.removeAttribute(.paragraphStyle, range: addedRange)
                    textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: addedRange)
                }
                //We also want to update the selectionLocation so the cursor goes back to the start of the location, which may have shifted due to other list items changing above
                if (range.location < selectedLocation) {
                    selectedLocation += (string.count - range.length)
                }
            }
        }

        self.textView.selectedRanges = [NSValue(range: NSRange(location: selectedLocation, length: 0))]
    }

    private func add(_ list: NSTextList, toEndOf textStorage: NSTextStorage) {
        let string = "\t\(list.marker(forItemNumber: 0))\t"
        var attributes = self.textView.typingAttributes
        let paragraphStyle = (attributes[.paragraphStyle] as? NSParagraphStyle) ?? textView.defaultParagraphStyle ?? NSParagraphStyle()
        if let mutableStyle = paragraphStyle.mutableCopy() as? NSMutableParagraphStyle {
            mutableStyle.textLists = [list]
            attributes[.paragraphStyle] = mutableStyle.copy()
        }

        textStorage.append(NSAttributedString(string: string, attributes: attributes))
    }
}
