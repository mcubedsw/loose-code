//
//  AppDelegate.swift
//  TextViewListExample
//
//  Created by Martin Pilkington on 02/04/2021.
//
//  Please read the LICENCE.txt for licensing information
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    @IBOutlet var textView: NSTextView!

    lazy var listController: ListController = {
        return ListController(textView: self.textView)
    }()

    @IBAction func addBulletedList(_ sender: Any) {
        self.listController.updateSelection(withListType: NSTextList(markerFormat: .disc, options: 0))
    }

    @IBAction func addNumberedList(_ sender: Any) {
        self.listController.updateSelection(withListType: NSTextList(markerFormat: .decimal, options: 0))
    }

    @IBAction func removeList(_ sender: Any) {
        self.listController.updateSelection(withListType: nil)
    }
}

