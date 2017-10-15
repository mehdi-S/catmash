//
//  voteVC.swift
//  catmash
//
//  Created by Mehdi Silini on 11/10/2017.
//  Copyright © 2017 Mehdi Silini. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class voteVC: UIViewController {
    
    var catJson: JSON! = JSON.null
    var catJsonArray = [JSON]()
    // leaderboardArray[X][0] is the identifier for element X
    // leaderboardArray[X][1] is the score for element X
    var leaderboardArray = [[String]]()
    let dispatchGroup = DispatchGroup()
    
    @IBOutlet weak var voteButtonTop: UIButton!
    @IBOutlet weak var voteButtonBot: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadData(url: "https://latelier.co/data/cats.json")
        // Using GCD to get notified when the web request is done to refresh UI
        dispatchGroup.notify(queue: .main) {
            self.updateButtons(leaderboard: self.leaderboardArray, UIbuttonArray: [self.voteButtonTop, self.voteButtonBot])
        }
    }
    
    @IBAction func voteButtonPressed(sender: UIButton) {
        updateLeaderboard(leaderboard: self.leaderboardArray, sender: sender)
        updateButtons(leaderboard: self.leaderboardArray, UIbuttonArray: [self.voteButtonTop, self.voteButtonBot])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentLeaderboardVC" {
            if let leaderboardVC = segue.destination as? leaderboardVC {
                // Pass leaderboardArray to the next VC
                leaderboardVC.leaderboard = self.leaderboardArray
            }
        }
    }
    
    func downloadData(url: String) {
        self.dispatchGroup.enter()
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                // If request is successfull, transform the response for easier use
                self.setArrayFromJson(jsonObject: JSON(value))
                self.dispatchGroup.leave()
            case .failure(let error):
                print(error)
                // fail to get JSON
            }
        }
    }
    
    func setArrayFromJson(jsonObject: JSON) -> Void {
        // catJSON get filled with initial value
        self.catJson = jsonObject
        for obj in self.catJson["images"] {
            // filling array[JSON] with each JSON object in catJSON
            self.catJsonArray.append(obj.1)
            // filling array[array[String]] for leaderboard score purpose
            // creating row of Array[String]
            var row = [String]()
            row.append(obj.1["id"].stringValue)
            row.append("0")
            // appending row[String] to leaderboardArray[[String]]
            self.leaderboardArray.append(row)
        }
    }
    
    // Update the score of element <index> pressed by adding 1 to leaderboardArray[index][1]
    func updateLeaderboard(leaderboard: [[String]], sender: UIButton) {
        for (index, element) in leaderboard.enumerated()  {
            if(element[0] == sender.titleLabel?.text) {
                leaderboardArray[index][1] = String(Int(element[1])! + 1)
            }
        }
    }
    
    // Pick a random element in leaderboard and ensure that each picked elem can not be picked again
    func pickRandomElem(leaderboard: [[String]], exclude: [String]?) -> String {
        let diceRoll = Int(arc4random_uniform(UInt32(leaderboard.count)))
        var pickedElem = leaderboard[diceRoll][0]
        if (exclude != nil) {
            for elem in exclude! {
                if pickedElem == elem {
                    pickedElem = pickRandomElem(leaderboard: leaderboard, exclude: exclude)
                }
            }
        }
        return pickedElem
    }
    
    // Update each buttons by picking a random element in given Array[[String]]
    func updateButtons(leaderboard: [[String]] ,UIbuttonArray: [UIButton]) -> Void {
        var buttonTitlesSet = [String]()
        for button in UIbuttonArray {
            button.setTitle(self.pickRandomElem(leaderboard: leaderboard, exclude: buttonTitlesSet),for: .normal)
            buttonTitlesSet.append((button.titleLabel?.text)!)
        }
    }
}

