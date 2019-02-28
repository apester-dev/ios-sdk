//
//  APETableViewController.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 12/12/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit

class APETableViewController: UITableViewController {

  let mediaIds: [Int: [String]] = [0: ["5a302c281fcfe6000198cfd8", "5a31346691af9500014e28bb", "5a2ebfc283629700019469e7"],
                                   1: ["5a31346691af9500014e28bb", "5a2ebfc283629700019469e7", "5a302c281fcfe6000198cfd8"]]

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 200
    tableView.register(APEUIWebViewTableViewCell.self, forCellReuseIdentifier: "APEUIWebViewTableViewCell")
    tableView.register(APEWKWebViewTableViewCell.self, forCellReuseIdentifier: "APEWKWebViewTableViewCell")
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return mediaIds.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return mediaIds[section]?.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let mediaId = mediaIds[indexPath.section]?[indexPath.row] ?? ""

    if (indexPath.section == 0) {
      let cell = tableView.dequeueReusableCell(withIdentifier: "APEUIWebViewTableViewCell", for: indexPath) as? APEUIWebViewTableViewCell ?? APEUIWebViewTableViewCell()
       cell.configure(mediaId: mediaId, delegate: self)
      return cell
    } else {
      let cell: APEWKWebViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "APEWKWebViewTableViewCell", for: indexPath)  as? APEWKWebViewTableViewCell ?? APEWKWebViewTableViewCell()
      cell.configure(mediaId: mediaId, delegate: self)
      return cell
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "\(section)" // " == 0 ? "UI WebView" : "WK WebView"
  }
}

extension APETableViewController: APEWebViewTableViewCellDelegate {
  func didUpdateApesterUnitHeight() {
    self.tableView.beginUpdates()
    self.tableView.endUpdates()
  }
}

