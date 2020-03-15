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
    
    let realm = try! Realm()
    
    var goal: Goal!
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        difficultyPicker.dataSource = self
        difficultyPicker.delegate = self
        importancePicker.dataSource = self
        importancePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let task = task {
            textField.text = task.taskText
        }
    }
    
    @IBAction func addTask() {
        // 文字数制限かける
        
        priorityJudgment()
        
        if let text = textField.text, !text.isEmpty {
            if let task = task { // もしtaskがnilじゃなかったら = 編集時
                try! realm.write{
                    task.taskText = textField.text!
                    task.priority = priorityNum
                }
                dismiss(animated: true, completion: nil)
            } else { // もしtaskがnilだったら = 新規追加
                task = Task()
                task.taskText = textField.text!
                task.priority = priorityNum
                try! realm.write {
                    goal.tasks.append(task)
                }
                dismiss(animated: true, completion: nil)
            }
        } else {
            CDAlertView(title: "タスクが入力されていません！", message: "画面上部から入力してください✏️", type: .notification).show()
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
        
        switch (difficultyNum, importanceNum) {
        case (0, 0):
            priorityNum = 3
        case (0, 1):
            priorityNum = 2
        case (0, 2):
            priorityNum = 1
        case (1, 0):
            priorityNum = 4
        case (1, 1):
            priorityNum = 3
        case (1, 2):
            priorityNum = 1
        case (2, 0):
            priorityNum = 5
        case (2, 1):
            priorityNum = 2
        case (2, 2):
            priorityNum = 1
        default:
            priorityNum = 0
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
