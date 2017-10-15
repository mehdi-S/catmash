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
    var leaderboardArray = [[String]]()
    let dispatchGroup = DispatchGroup()
    
    @IBOutlet weak var voteButtonTop: UIButton!
    @IBOutlet weak var voteButtonBot: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadData(url: "https://latelier.co/data/cats.json")
        dispatchGroup.notify(queue: .main) {
            print(self.catJsonArray)
            print(self.leaderboardArray)
            self.updateButtons(leaderboard: self.leaderboardArray, UIbuttonArray: [self.voteButtonTop, self.voteButtonBot])
        }
    }
    
    @IBAction func voteButtonPressed(sender: UIButton) {
        print(sender.titleLabel?.text ?? "null")
        updateLeaderboard(leaderboard: self.leaderboardArray, sender: sender)
        updateButtons(leaderboard: self.leaderboardArray, UIbuttonArray: [self.voteButtonTop, self.voteButtonBot])
        print(self.leaderboardArray)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentLeaderboardVC" {
            if let leaderboardVC = segue.destination as? leaderboardVC{
                leaderboardVC.leaderboard = self.leaderboardArray
            }
        }
    }
    
    func downloadData(url: String) {
        self.dispatchGroup.enter()
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                self.setArrayFromJson(jsonObject: JSON(value))
                print("success")
                self.dispatchGroup.leave()
            case .failure(let error):
                // fail to get JSON
                print(error)
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
    
    func updateLeaderboard(leaderboard: [[String]], sender: UIButton) {
        for (index, element) in leaderboard.enumerated()  {
            if(element[0] == sender.titleLabel?.text) {
                leaderboardArray[index][1] = String(Int(element[1])! + 1)
            }
        }
    }
    
    func pickRandomCat(leaderboard: [[String]], exclude: [String]?) -> String {
        let diceRoll = Int(arc4random_uniform(UInt32(leaderboard.count)))
        var pickedCat = leaderboard[diceRoll][0]
        if (exclude != nil) {
            for cat in exclude! {
                if pickedCat == cat {
                    pickedCat = pickRandomCat(leaderboard: leaderboard, exclude: exclude)
                }
            }
        }
        return pickedCat
    }
    
    func updateButtons(leaderboard: [[String]] ,UIbuttonArray: [UIButton]) -> Void {
        var buttonTitlesSet = [String]()
        for button in UIbuttonArray {
            button.setTitle(self.pickRandomCat(leaderboard: leaderboard, exclude: buttonTitlesSet),for: .normal)
            buttonTitlesSet.append((button.titleLabel?.text)!)
        }
    }
}

