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
import Firebase
import FirebaseDatabase

class voteVC: UIViewController {
    
    var ref: DatabaseReference!
    var catJson: JSON! = JSON.null
    var catJsonArray = [JSON]()
    // leaderboardArray[X][0] is the identifier for element X
    // leaderboardArray[X][1] is the score for element X
    var urlArray = [[String]]()
    var buttonTagArray = [String]()
    var scoreArray = [[String]]()
    let dispatchGroup = DispatchGroup()
    
    @IBOutlet weak var voteButtonTop: customUIButton!
    @IBOutlet weak var voteButtonBot: customUIButton!
    @IBOutlet weak var imageButtonTop: customImageView!
    @IBOutlet weak var imageButtonBottom: customImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setting up firebase database reference
        ref = Database.database().reference()
        downloadData(url: "https://latelier.co/data/cats.json")
        // Using GCD to get notified when the web request is done to refresh UI
        dispatchGroup.notify(queue: .main) {
            self.updateButtons(leaderboard: self.urlArray, UIButtonArray: [self.voteButtonTop, self.voteButtonBot])
        }
    }
    
    @IBAction func voteButtonPressed(sender: UIButton) {
        updateLeaderboard(leaderboard: self.urlArray, sender: sender)
        updateButtons(leaderboard: self.urlArray, UIButtonArray: [self.voteButtonTop, self.voteButtonBot])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentLeaderboardVC" {
            if let leaderboardVC = segue.destination as? leaderboardVC {
                // NEXT STEP
                // refresh leaderboard the first time we open it up (GCD)
                leaderboardVC.urlArray = self.urlArray
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
            row.append(obj.1["url"].stringValue)
            // appending row[String] to leaderboardArray[[String]]
            self.urlArray.append(row)
        }
    }
    
    // Update the score of element <index> pressed by adding 1 to leaderboardArray[index][1]
    func updateLeaderboard(leaderboard: [[String]], sender: UIButton) {
        for element in leaderboard  {
            if(element[0] == buttonTagArray[sender.tag]) {
                let leaderboardRef = self.ref.child("leaderboard").child(element[0]).child("score")
                // Update database value for key element[0]
                leaderboardRef.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
                    let value = currentData.value as? Int ?? 0
                    currentData.value = value + 1
                    return TransactionResult.success(withValue: currentData)
                }
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
    func updateButtons(leaderboard: [[String]] ,UIButtonArray: [customUIButton]) -> Void {
        self.buttonTagArray = [String]()
        var buttonTitlesSet = [String]()
        var generatedId: String
        var actualTag:Int = 0
        
        for button in UIButtonArray {
            generatedId = self.pickRandomElem(leaderboard: leaderboard, exclude: buttonTitlesSet)
            print(generatedId)
            button.tag = actualTag
            self.buttonTagArray.append(generatedId)
            buttonTitlesSet.append(generatedId)
            for item in urlArray {
                if (item[0] == generatedId) {
                    button.loadButtonImageFromUrl(withUrl: item[1], withDefault: #imageLiteral(resourceName: "loadingCat"))
                }
            }
            actualTag = actualTag + 1
        }
    }
}

