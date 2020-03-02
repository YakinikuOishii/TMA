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
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var indexNum: Int = 0
    var goalItem = Goal()
    var taskItems = List<Task>()
    
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
    
    @IBAction func addTask() {
        performSegue(withIdentifier: "toAddTask", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddTask" {
            let nextVC: AddTaskViewController = segue.destination as! AddTaskViewController
            nextVC.indexNum = self.indexNum
        }
        
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    func setGoal() {
        let goalItems = realm.objects(Goal.self)
        goalItem = goalItems[indexNum]
        print("indexNumは\(indexNum)")
        goalLabel.text = goalItem.goalText
        
        if goalItems[indexNum].tasks.count == 0 {
            progressLabel.text = "0 / 0"
        }else{
            taskItems = goalItem.tasks // ここでソートする
            let allTaskCount = goalItem.tasks.count + goalItem.doneCount
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
        print("ソート後は\(taskItemsByPriority)")
        cell.taskLabel.text = taskItemsByPriority[indexPath.row].taskText
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
        print(indexPath.row)
    }
    
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 左から右へスワイプ
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // MARK: DONEアクション
        let doneAction = UIContextualAction(style: .normal,title:  "完了",handler: { (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
            success(true)
            let doneItem = self.taskItems.sorted(byKeyPath: "priority", ascending: false)[indexPath.row]
            let doneCount = self.goalItem.doneCount + 1
            print(self.goalItem)
            
            try! self.realm.write {
                self.realm.delete(doneItem)
                self.goalItem.doneCount = doneCount
//                self.realm.add(self.goalItem)
            }
            
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
        })
        
        doneAction.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    // 右から左へスワイプ
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // MARK: 削除アクション
        let deleteAction = UIContextualAction(style: .normal,title:  "削除",handler: { (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
            success(true)
            let deleteItem = self.taskItems.sorted(byKeyPath: "priority", ascending: false)[indexPath.row]
            print(deleteItem)
            try! self.realm.write{
                self.realm.delete(deleteItem)
            }
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
        })
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let deleteItem = taskItems.sorted(byKeyPath: "priority", ascending: false)[indexPath.row]
//            print(deleteItem)
//            try! realm.write{
//                realm.delete(deleteItem)
//            }
//            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
//        }
//    }

//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
//            self.array.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//        deleteButton.backgroundColor = UIColor.red
//
//        return [deleteButton]
//    }


