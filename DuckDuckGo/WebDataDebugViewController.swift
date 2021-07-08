//
//  WebDataDebugViewController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import UIKit
import WebKit

class WebDataDebugViewController: UITableViewController {

    var records = [WKWebsiteDataRecord]()

    override func viewDidLoad() {
        super.viewDidLoad()
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            self.records = records.sorted(by: { $0.displayName < $1.displayName })
            self.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.isEmpty ? 1 : records.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if records.isEmpty {
            cell.textLabel?.text = "No data found"
            cell.detailTextLabel?.text = ""
        } else {
            cell.textLabel?.text = records[indexPath.row].displayName
            cell.detailTextLabel?.text = records[indexPath.row].dataTypes.sorted(by: { $0 < $1 }).joined(separator: ", ")
        }
        return cell
    }

}
