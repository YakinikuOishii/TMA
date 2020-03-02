//
//  Goal.swift
//  TMA
//
//  Created by 笠原未来 on 2020/03/01.
//  Copyright © 2020 Kasahara Harami. All rights reserved.
//

import RealmSwift

class Goal: Object {
    @objc dynamic var goalText = ""
    @objc dynamic var doneCount = 0
    let tasks = List<Task>()
}

class Task: Object {
    @objc dynamic var taskText = ""
    @objc dynamic var priority = 0
}
