//
//  QuestionMenuTableViewController.swift
//  Coca Cola Can Game
//
//  Created by macbook on 5/21/20.
//  Copyright © 2020 assylkhantleubayev. All rights reserved.
//

import UIKit

class QuestionMenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Constants.modifyNavigationController(navigationController: navigationController)
        self.title = "Опрос"
    }

}
