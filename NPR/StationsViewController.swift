//
//  StationsViewController.swift
//  NPR
//
//  Created by Connor Montgomery on 1/3/19.
//  Copyright © 2019 Connor Montgomery. All rights reserved.
//

import Cocoa
import Preferences

class StationsViewController: NSViewController, Preferenceable, NSSearchFieldDelegate, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchField: NSSearchField!
    var stations:[Station] = []
    let toolbarItemTitle = "Stations"
    let toolbarItemIcon = NSImage(named: NSImage.advancedName)!

    override func viewDidLoad() {
        searchField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()
        // Do view setup here.
    }
    
    // MARK - search field
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        let zipCode = sender.stringValue
        StationsManager.sharedManager.fetchStreamsForZipCode(zip: zipCode) { (stations) in
            self.stations = stations
            self.tableView.reloadData()
        }
    }
    
    // MARK - tableView
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.stations.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let station = stations[row]
        let identifier = tableColumn?.identifier
        var text = ""
        if identifier!.rawValue == "frequency" {
            text = station.attributes.brand.frequency
        } else {
            text = station.attributes.brand.call
        }
        if let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = self.tableView.selectedRow
        if selectedRow >= 0 {
            let station = self.stations[selectedRow]
            StationsManager.sharedManager.currentStation = station
        }
    }
    
}
