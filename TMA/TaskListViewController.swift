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
    var goalItems: Results<Goal>!
    var goalItem = Goal()
    var task: Task!
    var taskItemsByPriority: Results<Task>!
    
    var themeColor: UIColor = UIColor(red: 0.482, green: 0.760, blue:0.788, alpha: 1.0)
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        progressView.tintColor = themeColor
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
        print(goalItem)
        tableView.reloadData()
    }
    
    // MARK: - segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddTask" {
            let nextVC: AddTaskViewController = segue.destination as! AddTaskViewController
            
            if let task = task {
                nextVC.taskText = task.taskText
            }
            nextVC.task = self.task
            nextVC.goal = goalItem
        }
        
    }
    
    // MARK: - method
    @IBAction func addTask() {
        performSegue(withIdentifier: "toAddTask", sender: nil)
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    // UIを更新するメソッド作る
    func updateUI() {
        goalItems = realm.objects(Goal.self)
        goalItem = goalItems[goalIndexNum]
        goalLabel.text = goalItem.goalText
        
        if goalItems[goalIndexNum].tasks.count == 0 && goalItems[goalIndexNum].doneCount == 0 {
            progressLabel.text = "0 / 0"
            progressView.setProgress(0.0, animated: true)
        }else{
            taskItemsByPriority = goalItem.tasks.sorted(byKeyPath: "priority", ascending: false) // ascending: falseで降順
            
            let allTaskCount = goalItem.tasks.count + goalItem.doneCount
            progressView.setProgress(Float(goalItem.doneCount)/Float(allTaskCount), animated: true)
            
            progressLabel.text = "\(goalItem.doneCount) / \(allTaskCount)"
            
            if goalItem.doneCount == allTaskCount {
                progressLabel.textColor = UIColor(red: 0.988, green: 0.364, blue:0.270, alpha: 1.000)
            }else{
                progressLabel.textColor = .black
            }
        }
    }
}

// MARK: - DetaSource
extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if taskItemsByPriority == nil {
            return 0
        }else{
            return taskItemsByPriority.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TaskTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TaskTableViewCell
        
        cell.taskLabel.text = taskItemsByPriority[indexPath.row].taskText
        
        for i in 1...5 {
            if i == taskItemsByPriority[indexPath.row].priority {
                cell.priorityImageView.image = UIImage(named: "star\(i).png")
            }
        }
        
        if indexPath.row == 0 {
            cell.backgroundColor = themeColor
        }
        return cell
    }
}

// MARK: - Delegate
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        taskIndexNum = indexPath.row
        task = taskItemsByPriority[indexPath.row]
        
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
            let doneItem = self.taskItemsByPriority[indexPath.row]
            let doneCount = self.goalItem.doneCount + 1
            
            try! self.realm.write {
                self.realm.delete(doneItem)
                self.goalItem.doneCount = doneCount
            }
            
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            self.updateUI()
            tableView.reloadData()
        })
        
        doneAction.backgroundColor = themeColor
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    // 右から左へスワイプ 削除
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal,title:  "削除",handler: { (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
            success(true)
            let deleteItem = self.taskItemsByPriority[indexPath.row]
            //            print(deleteItem)
            try! self.realm.write{
                self.realm.delete(deleteItem)
            }
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            self.updateUI()
            tableView.reloadData()
        })
        deleteAction.backgroundColor = UIColor(red: 0.988, green: 0.364, blue:0.270, alpha: 1.000)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

