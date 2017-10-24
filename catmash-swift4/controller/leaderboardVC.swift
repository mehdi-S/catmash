//
//  leaderboardVC.swift
//  catmash
//
//  Created by Mehdi Silini on 11/10/2017.
//  Copyright © 2017 Mehdi Silini. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import FirebaseDatabase

class leaderboardVC: UITableViewController {
    
    @IBOutlet var customTableView: UITableView!
    // create an instance of the UIRefreshControl class
    private let customRefreshControl = UIRefreshControl()
    // leaderboard[X][0] is the identifier for element X
    // leaderboard[X][1] is the score for element X
    var leaderboard = [[String]]()
    var urlArray = [[String]]()
    var catJsonArray = [JSON]()
    // setting up firebase database reference
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeDatabase()
        // sort the new leaderboard obtained from segueWay
        leaderboard = sortLeaderboard(leaderboard: leaderboard)
        // Add Refresh Control to Table View
        customRefreshControl.addTarget(self, action: #selector(refreshCellData(_:)), for: .valueChanged)
        customTableView.refreshControl = customRefreshControl
        // reload tableView with the new sorted data
        print(urlArray)
    }
    
    func observeDatabase() -> Void {
        // Database leaderboard reference
        let scoresRef = self.ref.child("leaderboard")
        scoresRef.observe(.value, with: { (snapshot) in
            self.leaderboard = [[String]]()
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let score = snap.childSnapshot(forPath: "score")
                var row = [String]()
                row.append(snap.key)
                row.append("\(score.value ?? "0")")
                self.leaderboard.append(row)
            }
            self.leaderboard = self.sortLeaderboard(leaderboard: self.leaderboard)
            print(self.leaderboard)
        })
    }
    
    @objc private func refreshCellData(_ sender: Any) {
        // reload cell content when user pullDownToRefresh
        customTableView.reloadData()
        customRefreshControl.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboard.count
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! customCell
        let rank = indexPath.row + 1
        
        cell.tag = rank
        cell.scoreLabel.text = leaderboard[indexPath.row][1]
        for item in urlArray {
            if (item[0] == leaderboard[indexPath.row][0]) {
                cell.profileImageView.loadImageFromUrl(withUrl: item[1], withDefault: #imageLiteral(resourceName: "loadingCat"))
            }
        }
        if let medal = UIImage.init(named: "\(cell.tag)") {
            cell.medalImageView.image = medal
        } else {
            cell.medalImageView.image = #imageLiteral(resourceName: "blank")
        }
        return cell
    }
    
    // Sort an Array[[String]] by descending order
    func sortLeaderboard(leaderboard toSort: [[String]]) -> [[String]] {
        return leaderboard.sorted { $0[1].compare($1[1], options: .numeric) == ComparisonResult.orderedDescending }
    }
}
