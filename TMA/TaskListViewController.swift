//
//  TaskListViewController.swift
//  TMA
//
//  Created by 笠原未来 on 2020/03/01.
//  Copyright © 2020 Kasahara Harami. All rights reserved.
//

import UIKit
import RealmSwift

class TaskListViewController: UIViewController {
    
    @IBOutlet var badgeImageView: UIImageView!
    @IBOutlet var goalLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var goalIndexNum: Int = 0
    var taskIndexNum: Int = 0
    var taskTextArray: [String] = []
    var goalItem = Goal()
    var taskItems = List<Task>()
    var editBool: Bool = false
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setGoal()
        tableView.reloadData()
    }
    
    // MARK: - segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "toAddTask" {
               let nextVC: AddTaskViewController = segue.destination as! AddTaskViewController
               nextVC.goalIndexNum = self.goalIndexNum
               nextVC.taskIndexNum = self.taskIndexNum
            if editBool == true {
                nextVC.editBool = true
                nextVC.taskText = self.taskTextArray[taskIndexNum]
            }
           }
           
       }
    
    // MARK: - method
    @IBAction func addTask() {
        editBool = false
        performSegue(withIdentifier: "toAddTask", sender: nil)
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    func setGoal() {
        let goalItems = realm.objects(Goal.self)
        goalItem = goalItems[goalIndexNum]
        goalLabel.text = goalItem.goalText
        
        if goalItems[goalIndexNum].tasks.count == 0 && goalItems[goalIndexNum].doneCount == 0 {
            progressLabel.text = "0 / 0"
        }else{
            taskItems = goalItem.tasks // ここでソートする
            let allTaskCount = goalItem.tasks.count + goalItem.doneCount
            progressView.setProgress(Float(goalItem.doneCount)/Float(allTaskCount), animated: true)
            print(Float(goalItem.doneCount)/Float(allTaskCount))
            progressLabel.text = "\(goalItem.doneCount) / \(allTaskCount)"
        }
        //        print("taskItemsは\(taskItems)")
    }
    
    // UIを更新するメソッド作る
    func updateUI() {
        
    }
}

// MARK: - DetaSource
extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TaskTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TaskTableViewCell
        let taskItemsByPriority = taskItems.sorted(byKeyPath: "priority", ascending: false) // ascending: falseで降順
//        print("ソート後は\(taskItemsByPriority)")
        cell.taskLabel.text = taskItemsByPriority[indexPath.row].taskText
        taskTextArray.append(taskItemsByPriority[indexPath.row].taskText)
        
        for i in 1...5 {
            if i == taskItemsByPriority[indexPath.row].priority {
                cell.priorityImageView.image = UIImage(named: "star\(i).png")
            }
        }
        
        return cell
    }
}

// MARK: - Delegate
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        taskIndexNum = indexPath.row
        editBool = true
        performSegue(withIdentifier: "toAddTask", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: swipe action
    // 左から右へスワイプ DONE
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal,title:  "完了",handler: { (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
            success(true)
            let doneItem = self.taskItems.sorted(byKeyPath: "priority", ascending: false)[indexPath.row]
            let doneCount = self.goalItem.doneCount + 1
//            print(self.goalItem)
            
            try! self.realm.write {
                self.realm.delete(doneItem)
                self.goalItem.doneCount = doneCount
//                self.realm.add(self.goalItem)
            }
            
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            self.setGoal()
        })
        
        doneAction.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    // 右から左へスワイプ 削除
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal,title:  "削除",handler: { (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
            success(true)
            let deleteItem = self.taskItems.sorted(byKeyPath: "priority", ascending: false)[indexPath.row]
//            print(deleteItem)
            try! self.realm.write{
                self.realm.delete(deleteItem)
            }
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            self.setGoal()
        })
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

