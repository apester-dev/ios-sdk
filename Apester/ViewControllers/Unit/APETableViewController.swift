//
//  APETableViewController.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 12/12/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit

class APETableViewController: UITableViewController {

  let mediaIds: [String] = ["5a302c281fcfe6000198cfd8", "5a31346691af9500014e28bb", "5a2ebfc283629700019469e7"]

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 200
    tableView.register(APEWKWebViewTableViewCell.self, forCellReuseIdentifier: "APEWKWebViewTableViewCell")
  }

  // MARK: - Table view data source

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return mediaIds.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let mediaId = mediaIds[indexPath.row]

      let cell: APEWKWebViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "APEWKWebViewTableViewCell", for: indexPath)  as? APEWKWebViewTableViewCell ?? APEWKWebViewTableViewCell()
      cell.configure(mediaId: mediaId, delegate: self)
      return cell
  }
}

extension APETableViewController: APEWebViewTableViewCellDelegate {
  func didUpdateApesterUnitHeight() {
    self.tableView.beginUpdates()
    self.tableView.endUpdates()
  }
}

