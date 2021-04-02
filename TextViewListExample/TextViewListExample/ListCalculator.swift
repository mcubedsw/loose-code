//
//  ListCalculator.swift
//  TextViewListExample
//
//  Created by Martin Pilkington on 02/04/2021.
//
//  Please read the LICENCE.txt for licensing information
//

import Cocoa

class ListCalculator {
    private var level: Int? = nil
    private var editingRange: NSRange? = nil


    /// Calculate the total range of lists to edit in a textView, and (in the case of nested lists) the level of list we'll change
    /// - Parameter textView: The text view to calculate on
    /// - Returns: A tuple with the range (or nil if invalid), and the level of list (which should match the index to edit in all NSParagraphStyle.textLists in the range)
    func calculateListRangeAndLevel(in textView: NSTextView) -> (NSRange?, Int) {
        guard let textStorage = textView.textStorage else {
            return (nil, 0)
        }

        let selectedRanges = textView.selectedRanges.compactMap { $0.rangeValue }.filter { ($0.lowerBound <= textStorage.length) && ($0.upperBound <= textStorage.length) }
        //For an empty text view, the editing range is (0,0)
        if textStorage.length == 0, selectedRanges.count == 1, selectedRanges[0] == NSRange(location: 0, length: 0) {
            return (NSRange(location: 0, length: 0), 0)
        }

        for range in selectedRanges {
            guard range.length > 0 else {
                self.handleZeroLengthRange(range, in: textStorage, defaultStyle: textView.defaultParagraphStyle)
                continue
            }

            textStorage.enumerateAttribute(.paragraphStyle, in: range, options: []) { (attribute, effectiveRange, _) in
                guard let paragraphStyle = attribute as? NSParagraphStyle else {
                    return
                }
                self.updateLevelAndRange(using: paragraphStyle, effectiveRange: effectiveRange, in: textStorage)
            }
        }
        return (self.editingRange, self.level ?? 0)
    }


    /// Zero length ranges require special treatment, as we can't use NSAttributedString.enumerateAttribute()
    private func handleZeroLengthRange(_ range: NSRange, in textStorage: NSTextStorage, defaultStyle: NSParagraphStyle?) {
        var effectiveRange = NSRange(location: NSNotFound, length: 0)

        var attribute: Any? = defaultStyle
        if (textStorage.length > 0) {
            var actualRange = range
            //If the cursor is at the end of the text view, we have to shift forward when fetching the attribute to avoid an out of bounds exception
            if (actualRange.location == textStorage.length) {
                actualRange.location = max(actualRange.location - 1, 0)
            }
            attribute = textStorage.attribute(.paragraphStyle, at: actualRange.location, effectiveRange: &effectiveRange)
            //If there are currently no text lists, then the paragraph style will actually cover multiple paragraphs. In this case we only want the current paragraph
            if let attribute = attribute as? NSParagraphStyle {
                if attribute.textLists.count == 0 {
                    effectiveRange = (textStorage.string as NSString).paragraphRange(for: range)
                }
            }
        }
        //Perform the update calculation
        if let paragraphStyle = attribute as? NSParagraphStyle {
            self.updateLevelAndRange(using: paragraphStyle, effectiveRange: effectiveRange, in: textStorage)
        }
    }


    /// Actually update the level and range
    private func updateLevelAndRange(using paragraphStyle: NSParagraphStyle, effectiveRange: NSRange, in textStorage: NSTextStorage) {
        var newRange = effectiveRange
        //The level is the index of NSParagraphStyle.textLists we need to edit. This is always the list with the lowest indentation in the selection
        //This should be zero indexed so it maps to the .textLists array
        if let currentLevel = self.level {
            self.level = min(currentLevel, max(paragraphStyle.textLists.count - 1, 0))
        } else {
            self.level = max(paragraphStyle.textLists.count - 1, 0)
        }

        //If we're in a list then we need to get the full range of the list, which may be outside the selection range
        if let list = paragraphStyle.textLists.last {
            let listRange = textStorage.range(of: list, at: effectiveRange.location)
            if (listRange.location != NSNotFound) {
                newRange = listRange
            }
        } else {
            //If we're outside of a list then we just want the current paragraph
            newRange = (textStorage.string as NSString).paragraphRange(for: effectiveRange)
        }

        //Merge the ranges
        guard let editRange = self.editingRange else {
            self.editingRange = newRange
            return
        }
        self.editingRange = editRange.union(newRange)
    }
}
