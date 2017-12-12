//
//  APETableViewController.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 12/12/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit

class APETableViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 400
    tableView.register(APEUIWebViewTableViewCell.self, forCellReuseIdentifier: "APEUIWebViewTableViewCell")
    tableView.register(APEWKWebViewTableViewCell.self, forCellReuseIdentifier: "APEWKWebViewTableViewCell")
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (indexPath.section == 0) {
      let cell = tableView.dequeueReusableCell(withIdentifier: "APEUIWebViewTableViewCell", for: indexPath) as! APEUIWebViewTableViewCell
      cell.configure(with: self)
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "APEWKWebViewTableViewCell", for: indexPath) as! APEWKWebViewTableViewCell
      cell.configure(with: self)
      return cell
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ? "UI WebView" : "WK WebView"
  }
}

extension APETableViewController: APEWebViewTableViewCellDelegate {
  func didUpdateApesterUnitHeight() {
    self.tableView.beginUpdates()
    self.tableView.endUpdates()
  }
}

