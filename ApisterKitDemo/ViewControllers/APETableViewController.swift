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
    tableView.estimatedRowHeight = 200
    tableView.register(APEUIWebViewTableViewCell.self, forCellReuseIdentifier: "APEUIWebViewTableViewCell")
    tableView.register(APEWKWebViewTableViewCell.self, forCellReuseIdentifier: "APEWKWebViewTableViewCell")
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (indexPath.row == 0) {
      let cell = tableView.dequeueReusableCell(withIdentifier: "APEUIWebViewTableViewCell", for: indexPath) as! APEUIWebViewTableViewCell
       cell.configure(mediaId: "5a302c281fcfe6000198cfd8", delegate: self)
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "APEWKWebViewTableViewCell", for: indexPath) as! APEWKWebViewTableViewCell
      cell.configure(mediaId: "5a2ebfc283629700019469e7", delegate: self)
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

