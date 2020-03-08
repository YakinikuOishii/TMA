//
//  AddTaskViewController.swift
//  TMA
//
//  Created by 笠原未来 on 2020/03/01.
//  Copyright © 2020 Kasahara Harami. All rights reserved.
//

import UIKit
import RealmSwift
import CDAlertView

class AddTaskViewController: UIViewController {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var difficultyPicker: UIPickerView!
    @IBOutlet var importancePicker: UIPickerView!
    
    let difficultyArray: [String] = ["必ず作れる","おそらく作れる","不明"]
    let importanceArray: [String] = ["必要","できれば必要","なくても困らない"]
    var difficultyNum: Int = 0
    var importanceNum: Int = 0
    var priorityNum: Int = 0
    
    var goalIndexNum: Int = 0
    var taskIndexNum: Int = 0
    var doneCount: Int = 0
    var taskText: String!
    var editBool: Bool = false
    
    let realm = try! Realm()
    let goal = Goal()
    let task = Task()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        difficultyPicker.dataSource = self
        difficultyPicker.delegate = self
        importancePicker.dataSource = self
        importancePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("editBoolは\(editBool)")
        if editBool == true {
            textField.text = taskText
        }
    }
    
    @IBAction func addTask() {
        // 文字数制限かける
        priorityJudgment()
        
        if editBool == false {
            if textField.text?.isEmpty == true {
                CDAlertView(title: "タスクが入力されていません！", message: "画面上部から入力してください✏️", type: .notification).show()
            }else{
                let goalItems = realm.objects(Goal.self)
                task.taskText = textField.text!
                task.priority = priorityNum
                try! realm.write {
                    goalItems[goalIndexNum].tasks.append(task)
                }
                dismiss(animated: true, completion: nil)
            }
        }else if editBool == true {
            if textField.text?.isEmpty == true {
                CDAlertView(title: "タスクが入力されていません！", message: "画面上部から入力してください✏️", type: .notification).show()
            }else{
                let goalItems = realm.objects(Goal.self)
                task.taskText = textField.text!
                task.priority = priorityNum
                try! realm.write {
                    goalItems[goalIndexNum].tasks[taskIndexNum].taskText = textField.text!
                    goalItems[goalIndexNum].tasks[taskIndexNum].priority = priorityNum
                }
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // テキストフィールド外を触るとキーボードが閉じる
        self.view.endEditing(true)
    }
    
    func priorityJudgment() {
        if difficultyNum == 0 && importanceNum == 0 {
            priorityNum = 3
        }else if difficultyNum == 0 && importanceNum == 1 {
            priorityNum = 2
        }else if difficultyNum == 0 && importanceNum == 2 {
            priorityNum = 1
        }else if difficultyNum == 1 && importanceNum == 0 {
            priorityNum = 4
        }else if difficultyNum == 1 && importanceNum == 1 {
            priorityNum = 3
        }else if difficultyNum == 1 && importanceNum == 2 {
            priorityNum = 1
        }else if difficultyNum == 2 && importanceNum == 0 {
            priorityNum = 5
        }else if difficultyNum == 2 && importanceNum == 1 {
            priorityNum = 2
        }else if difficultyNum == 2 && importanceNum == 2 {
            priorityNum = 1
        }
    }
    
}
// MARK: - DataSource
extension AddTaskViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return difficultyArray[row]
        }else if pickerView.tag == 2 {
            return importanceArray[row]
        }else{
            return "error"
        }
    }
    
}

// MARK: - Delegate
extension AddTaskViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            difficultyNum = row
        }else if pickerView.tag == 2 {
            importanceNum = row
        }
    }
}
