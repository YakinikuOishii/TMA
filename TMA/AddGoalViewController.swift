//
//  AddGoalViewController.swift
//  TMA
//
//  Created by 笠原未来 on 2020/03/01.
//  Copyright © 2020 Kasahara Harami. All rights reserved.
//

import UIKit
import RealmSwift
import CDAlertView

class AddGoalViewController: UIViewController {
    
    var goal: Goal!
    let realm = try! Realm()
    
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let goal = goal {
            textField.text = goal.goalText
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addGoal() {
        // textField.textがnilの場合、nilが許容されて落ちないようにif let を使う
        if let text = textField.text, !text.isEmpty {
            if let goal = goal { // 編集時
                try! realm.write {
                    goal.goalText = textField.text!
                }
                dismiss(animated: true, completion: nil)
            } else { // 新規
                goal = Goal()
                goal.goalText = textField.text!
                try! realm.write {
                    realm.add(self.goal)
                }
                dismiss(animated: true, completion: nil)
            }
            
        } else {
            CDAlertView(title: "ゴールが入力されていません！", message: "画面上部から入力してください✏️", type: .notification).show()
        }
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
