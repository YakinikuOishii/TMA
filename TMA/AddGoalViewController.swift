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
    
    let goal = Goal()
    let realm = try! Realm()
    
    @IBOutlet var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addGoal() {
        if textField.text?.isEmpty == true{
            CDAlertView(title: "ゴールが入力されていません！", message: "画面上部から入力してください✏️", type: .notification).show()
        }else{
            goal.goalText = textField.text!
            
            try! realm.write{
                realm.add(goal)
            }
            dismiss(animated: true, completion: nil)
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
