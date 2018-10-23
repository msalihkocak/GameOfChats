//
//  ViewController.swift
//  GameOfChats
//
//  Created by Mehmet Salih Koçak on 23.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
        
    }
    
    @objc func logoutTapped(){
        let loginController = LoginController()
        present(loginController, animated: true, completion:nil)
    }

}

