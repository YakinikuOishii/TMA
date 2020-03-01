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
        goalLabel.text = goalItem.goalText
        
        if goalItems[indexNum].tasks.count == 0 {
            progressLabel.text = "0 / 0"
        }else{
            let taskItem = goalItem.tasks
            let allTaskCount = taskItem[indexNum].taskText.count + taskItem[indexNum].doneCount
            progressLabel.text = "\(taskItem[indexNum].doneCount) / \(allTaskCount)"
        }
    }
    
}

extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let taskItems = goalItem.tasks
        return taskItems[indexNum].taskText.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TaskTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TaskTableViewCell
        let taskItems = goalItem.tasks
        let taskItemsByPriority = taskItems.sorted(byKeyPath: "priority")
        let taskItem = taskItemsByPriority[indexPath.row]
        cell.taskLabel.text = taskItem.taskText
        for i in 1...5 {
            if i == taskItem.priority {
                cell.priorityImageView.image = UIImage(named: "star\(i).png")
            }
        }
        
        return cell
    }
}

extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
}
