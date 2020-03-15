//
//  ViewController.swift
//  TMA
//
//  Created by 笠原未来 on 2020/02/29.
//  Copyright © 2020 Kasahara Harami. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var goalArray: [String] = []
    var taskArray: [String] = []
    var doneArray: [String] = []
    var indexNum: Int = 0
    
    let realm = try! Realm()
    var goalItems: Results<Goal>!
    var goalItem = Goal()
    var goalItemsCount: Int!
    var themeColor: UIColor = UIColor(red: 0.482, green: 0.760, blue:0.788, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "GoalTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        goalItems = realm.objects(Goal.self)
        goalItemsCount = goalItems.count
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTask" {
            let nextVC: TaskListViewController = segue.destination as! TaskListViewController
            nextVC.goalIndexNum = self.indexNum
        }else if segue.identifier == "toAdd" {
            let nextVC: AddGoalViewController = segue.destination as! AddGoalViewController
            nextVC.goal = goalItem
        }
    }
    
}

//MARK: - DataSource
extension ViewController: UITableViewDataSource {
    //MARK: section
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return goalItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView: UIView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    
    //MARK: cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 159
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GoalTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GoalTableViewCell
        goalItem = goalItems[indexPath.section]
        
        if goalItem.tasks.count == 0 && goalItem.doneCount == 0 {
            cell.taskProgressLabel.text = "0 / 0"
            cell.taskProgressView.setProgress(0.0, animated: true)
        }else{
            let allTaskCount = goalItem.tasks.count + goalItem.doneCount
            cell.taskProgressView.setProgress(Float(goalItem.doneCount)/Float(allTaskCount), animated: true)
            cell.taskProgressLabel.text = "\(goalItem.doneCount) / \(allTaskCount)"
            if goalItem.doneCount == allTaskCount {
                cell.taskProgressLabel.textColor = UIColor(red: 0.988, green: 0.364, blue:0.270, alpha: 1.000)
            }else{
                cell.taskProgressLabel.textColor = .black
            }
        }
        
        cell.goalTitleLabel.text = goalItem.goalText
        
        cell.taskProgressView.tintColor = themeColor
        cell.taskProgressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowRadius = 20
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        
        return cell
    }
}

//MARK: - Delegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexNum = indexPath.section
        performSegue(withIdentifier: "toTask", sender: nil)
    }
    
    // 左から右へスワイプ　編集
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal,title:  "編集",handler: { (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
            success(true)
            self.goalItem = self.goalItems[indexPath.section]
            self.performSegue(withIdentifier: "toAdd", sender: nil)
        })
        editAction.backgroundColor = themeColor
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    // 右から左へスワイプ 削除
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal,title:  "削除",handler: { (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
            success(true)
            try! self.realm.write{
                self.realm.delete(self.goalItems[indexPath.section])
            }
            tableView.reloadData()
        })
        deleteAction.backgroundColor = UIColor(red: 0.988, green: 0.364, blue:0.270, alpha: 1.000)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

