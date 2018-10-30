//
//  NewMessageController.swift
//  GameOfChats
//
//  Created by BTK Apple on 28.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    var users = [User]()
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelNewMessage))
        navigationItem.title = "New Message"
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUsers()
    }
    
    func fetchUsers(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            self.users.append(user)
            self.tableView.reloadData()
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = users[indexPath.row].email
        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: users[indexPath.row].imageUrlString)
        return cell
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.messagesController?.showChatControllerWithUser(user: self.users[indexPath.row])
        }
    }
    
    @objc func cancelNewMessage(){
        dismiss(animated: true, completion: nil)
    }

}
