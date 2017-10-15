//
//  leaderboardVC.swift
//  catmash
//
//  Created by Mehdi Silini on 11/10/2017.
//  Copyright © 2017 Mehdi Silini. All rights reserved.
//

import UIKit
import SwiftyJSON

class leaderboardVC: UITableViewController {
    
    @IBOutlet var customTableView: UITableView!
    var leaderboard = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leaderboard = sortLeaderboard(leaderboard: leaderboard)
        print(leaderboard)
        customTableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboard.count
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! customCell
        cell.nameLabel.text = leaderboard[indexPath.row][0]
        cell.scoreLabel.text = leaderboard[indexPath.row][1]
        
        return cell
    }
    
    func sortLeaderboard(leaderboard toSort: [[String]]) -> [[String]] {
        return leaderboard.sorted(by: { $0[1] > $1[1] })
    }
}
