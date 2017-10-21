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
    // leaderboard[X][0] is the identifier for element X
    // leaderboard[X][1] is the score for element X
    var leaderboard = [[String]]()
    // Database reference
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // sort the new leaderboard obtained from segueWay
        leaderboard = sortLeaderboard(leaderboard: leaderboard)
        // reload tableView with the new sorted data
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
    
    // Sort an Array[[String]] by descending order
    func sortLeaderboard(leaderboard toSort: [[String]]) -> [[String]] {
        return leaderboard.sorted(by: { $0[1] > $1[1] })
    }
}
