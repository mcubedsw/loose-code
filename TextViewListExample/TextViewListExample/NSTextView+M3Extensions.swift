//
//  NSTextView+M3Extensions.swift
//  TextViewListExample
//
//  Created by Martin Pilkington on 02/04/2021.
//
//  Please read the LICENCE.txt for licensing information
//

import AppKit

extension NSTextView {
    func modifyText(in ranges: [NSRange], _ block: (NSTextStorage) -> Void) {
        guard let textStorage = self.textStorage else {
            return
        }

        let rangesAsValues = ranges.map { NSValue(range: $0) }
        guard self.shouldChangeText(inRanges: rangesAsValues, replacementStrings: nil) else {
            return
        }

        textStorage.beginEditing()
        block(textStorage)
        textStorage.endEditing()
        self.didChangeText()
    }
}
