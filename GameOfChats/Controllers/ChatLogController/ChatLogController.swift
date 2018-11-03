//
//  ChatLogController.swift
//  GameOfChats
//
//  Created by BTK Apple on 29.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController,UITextFieldDelegate {
    
    var messages = [Message]()
    let cellId = "bubbleCellId"
    
    var selectedChatUser: User? {
        didSet {
            navigationItem.title = selectedChatUser!.name
            observeMessages()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func observeMessages(){
        guard let selectedUser = selectedChatUser else{ return }
        guard let id = Auth.auth().currentUser?.uid else { return }
        let userMessagesRef = Database.database().reference().child("user-messages").child(id).child(selectedUser.id)
        userMessagesRef.observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let message = Message(snapshot:snapshot)
                self.messages.append(message)
                self.collectionView?.reloadData()
                let indexpath = IndexPath(row: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: indexpath, at: .bottom, animated: true)
            })
        }
    }
    
    lazy var inputContainerView: ChatInputContainerView = {
        let containerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        containerView.sendButton.addTarget(self, action: #selector(sendTextMessage), for: .touchUpInside)
        containerView.uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadImage)))
        containerView.messageTextField.delegate = self
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    @objc func keyboardDidShown(notification:Notification){
        if messages.count > 0{
            let indexpath = IndexPath(row: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexpath, at: .top, animated: true)
        }
    }
    
    func setupCollectionView(){
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(MessageBubbleCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTextMessage()
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // Variables for image zooming operations
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView:UIImageView?
}

extension ChatLogController: UICollectionViewDelegateFlowLayout{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageBubbleCell
        setupCellBubbles(for: cell, and: messages[indexPath.row])
        return cell
    }
    
    func setupCellBubbles(for cell:MessageBubbleCell, and message:Message){
        cell.message = message
        cell.chatLogController = self
        
        setupForIncomingOrOutgoingMessage(for: cell, and: message)
        
        cell.playVideoButton.isHidden = message.videoUrl == ""
        
        // Setup for image or text cell
        if message.imageUrl != ""{
            cell.bubbleWidthAnchor?.constant = 200
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.messageImageView.isHidden = false
            cell.messageTextLabel.isHidden = true
            cell.messageTextLabel.text = ""
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: message.imageUrl)
        }else{
            cell.messageImageView.image = nil
            cell.messageImageView.isHidden = true
            cell.messageTextLabel.isHidden = false
            cell.messageTextLabel.text = message.text
            cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: message.text).width + 32
        }
    }
    
    func setupForIncomingOrOutgoingMessage(for cell:MessageBubbleCell, and message:Message){
        if message.fromId == Auth.auth().currentUser?.uid{
            cell.bubbleView.backgroundColor = MessageBubbleCell.blueColor
            cell.messageTextLabel.textColor = UIColor.white
            cell.hideProfileImage()
        }else{
            cell.bubbleView.backgroundColor = MessageBubbleCell.grayColor
            cell.messageTextLabel.textColor = UIColor.black
            cell.showProfileImage()
            guard let user = selectedChatUser else{ return }
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: user.imageUrlString)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height:CGFloat = 80
        let width:CGFloat = UIScreen.main.bounds.width
        if messages[indexPath.row].imageUrl != ""{
            if let imgHeight = messages[indexPath.row].imageHeight{
                if let imgWidth = messages[indexPath.row].imageWidth{
                     let ratio = imgHeight.floatValue / imgWidth.floatValue
                    height = 200 * CGFloat(ratio)
                }
            }
        }else if messages[indexPath.row].videoUrl != ""{
            
        }else{
            height = estimatedFrameForText(text: messages[indexPath.row].text).height + 17
        }
        return CGSize(width: width, height: height)
    }
    
    private func estimatedFrameForText(text:String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
}
