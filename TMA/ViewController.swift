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
    var goalItem = Goal()
    var goalItemsCount: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "GoalTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let goalItems = realm.objects(Goal.self)
        goalItemsCount = goalItems.count
        print("goalItemsは\(goalItems)")
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTask" {
            let nextVC: TaskListViewController = segue.destination as! TaskListViewController
            nextVC.goalIndexNum = self.indexNum
//            nextVC.goalLabel.text = goalText
        }
    }
    
}

//MARK: - DataSource
extension ViewController: UITableViewDataSource {
    //MARK: section
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return goalItemsCount
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
        let goalItems = realm.objects(Goal.self)
        goalItem = goalItems[indexPath.section]
        
        if goalItem.tasks.count == 0 {
            cell.taskProgressLabel.text = "0 / 0"
        }else{
            
//            let taskItem = goalItem.tasks[indexPath.section]
//            let allTaskCount = goalItem.tasks.count + taskItem.doneCount
//            cell.taskProgressLabel.text = "\(taskItem.doneCount) / \(allTaskCount)"
        }
        
        cell.goalTitleLabel.text = goalItem.goalText
        
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
        print(indexNum)
        performSegue(withIdentifier: "toTask", sender: nil)
    }
}

