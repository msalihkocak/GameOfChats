//
//  ViewController.swift
//  GameOfChats
//
//  Created by Mehmet Salih Koçak on 23.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    var userIdsHavingConversationWith = [String]()
    var cellId = "messageCellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        checkIfUserIsLoggedIn()
        observeUserMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //observeUserMessages()
    }
    
    func observeUserMessages(){
        userIdsHavingConversationWith.removeAll(keepingCapacity: false)
        guard let currentUserId = Auth.auth().currentUser?.uid else{ return }
        let currentUserMessagesRef = Database.database().reference().child("user-messages").child(currentUserId)
        currentUserMessagesRef.observe(.childAdded) { (snapshot) in
            let toUserId = snapshot.key
            self.userIdsHavingConversationWith.append(toUserId)
            let toUserMessagesRef = currentUserMessagesRef.child(toUserId)
            toUserMessagesRef.observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessage(withMessageId: messageId)
            })
        }
    }
    
    func removeAllObserversFromAllNodes(except exceptUserId:String){
        guard let currentUserId = Auth.auth().currentUser?.uid else{ return }
        let myRef = Database.database().reference().child("user-messages").child(currentUserId)
        myRef.removeAllObservers()
        userIdsHavingConversationWith.forEach { (userId) in
            if userId != exceptUserId{
                myRef.child(userId).removeAllObservers()
            }
        }
    }
    
    func fetchMessage(withMessageId messageId:String){
        let messageRef = Database.database().reference().child("messages").child(messageId)
        messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let message = Message(snapshot: snapshot)
            self.messagesDictionary[message.chatPartnerId()] = message
            self.attemptToReloadData()
        })
    }
    
    var tableReloadTimer:Timer?
    
    func attemptToReloadData(){
        self.tableReloadTimer?.invalidate()
        self.tableReloadTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (timer) in
            self.messages = Array(self.messagesDictionary.values)
            self.messages.sort(by: { $0.timestamp.intValue > $1.timestamp.intValue })
            self.tableView.reloadData()
        })
    }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            fetchUserCredentials()
        }
    }
    
    func fetchUserCredentials(){
        guard let uid = Auth.auth().currentUser?.uid else{ return }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            self.setupNavBarWithUser(user:user)
        }, withCancel: nil)
    }
    
    func resetUserMessages(){
        self.messages.removeAll()
        self.messagesDictionary.removeAll()
        self.observeUserMessages()
        self.tableView.reloadData()
    }
    
    func setupNavBarWithUser(user:User){
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        self.navigationItem.titleView = titleView
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 16
        profileImageView.layer.borderColor = UIColor(r: 30, g: 30, b: 30).withAlphaComponent(0.8).cgColor
        profileImageView.layer.borderWidth = 2
        profileImageView.clipsToBounds = true
        profileImageView.loadImageUsingCacheWithUrlString(urlString: user.imageUrlString)
        
        let textLabel = UILabel()
        textLabel.text = user.name
        textLabel.minimumScaleFactor = 0.75
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(profileImageView)
        titleView.addSubview(textLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        textLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        textLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        textLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
    }
    
    @objc func showChatControllerWithUser(user:User){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.selectedChatUser = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleLogout(){
        do{
            try Auth.auth().signOut()
        }catch let logoutError{
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesVC = self
        present(loginController, animated: true, completion:nil)
    }
    
    @objc func handleNewMessage(){
        let nmController = NewMessageController()
        nmController.messagesController = self
        let navController = UINavigationController(rootViewController: nmController)
        present(navController, animated: true, completion: nil)
    }
}

extension MessagesController{
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userRef = Database.database().reference().child("users").child(messages[indexPath.row].chatPartnerId())
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            let user = User(snapshot:snapshot)
            //self.removeAllObserversFromAllNodes(except: user.id)
            self.showChatControllerWithUser(user: user)
        }
    }
}

