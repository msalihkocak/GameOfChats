//
//  ChatLogController.swift
//  GameOfChats
//
//  Created by BTK Apple on 29.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController,UITextFieldDelegate {
    
    var messages = [Message]()
    let cellId = "bubbleCellId"
    
    var selectedChatUser: User? {
        didSet {
            navigationItem.title = selectedChatUser!.name
            observeMessages()
        }
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
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(UIColor(r: 60, g: 140, b: 230), for: .normal)
        button.addTarget(self, action: #selector(sendTextMessage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var messageTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.white
        textField.placeholder = "Write your message..."
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var uploadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "upload_image_icon")
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var inputContainerView:UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        containerView.backgroundColor = UIColor.white
            //UIColor(r: 245, g: 245, b: 245)
        
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadImage)))
        
        setupInputContainerTopSeperator(inside: containerView)
        setupSendButton(inside: containerView)
        setupUploadImageView(inside: containerView)
        setupMessageTextField(inside: containerView)
        
        
        return containerView
    }()
    
    @objc func handleUploadImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
        present(picker, animated: true, completion: nil)
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
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
    
    func setupSendButton(inside view:UIView){
        view.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 8).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2).isActive = true
        sendButton.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func setupMessageTextField(inside view:UIView){
        view.addSubview(messageTextField)
        messageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
        messageTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        messageTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor).isActive = true
        messageTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier:0.7).isActive = true
    }
    
    func setupUploadImageView(inside view:UIView){
        view.addSubview(uploadImageView)
        uploadImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    func setupInputContainerTopSeperator(inside view:UIView){
        // Top Seperator View
        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        
        view.addSubview(seperator)
        seperator.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        seperator.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        seperator.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        seperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTextMessage()
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView:UIImageView?
}

//For interaction with cells
// MARK: Interaction with Message Cells
extension ChatLogController{
    func performZoomInForImageView(imageToZoomIn:UIImageView){
        self.messageTextField.resignFirstResponder()
        startingImageView = imageToZoomIn
        startingImageView?.alpha = 0
        
        startingFrame = imageToZoomIn.superview?.convert(imageToZoomIn.frame, to: nil)
        guard let keyWindow = UIApplication.shared.keyWindow else{ return }
        
        blackBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height))
        blackBackgroundView?.backgroundColor = .black
        blackBackgroundView?.alpha = 0
        keyWindow.addSubview(blackBackgroundView!)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = imageToZoomIn.image
        zoomingImageView.layer.cornerRadius = 16
        zoomingImageView.clipsToBounds = true
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performZoomOutFromImage(tapGesture:))))
        
        keyWindow.addSubview(zoomingImageView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let height = (self.startingFrame!.height / self.startingFrame!.width) * keyWindow.frame.width
            zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            zoomingImageView.center = keyWindow.center
            
            zoomingImageView.layer.cornerRadius = 0
            self.blackBackgroundView?.alpha = 1
            self.inputContainerView.alpha = 0
            
        }, completion: nil)
    }
    
    @objc func performZoomOutFromImage(tapGesture:UITapGestureRecognizer){
        guard let zoomingImageView = tapGesture.view as? UIImageView else{ return }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            zoomingImageView.frame = self.startingFrame!
            
            zoomingImageView.layer.cornerRadius = 16
            self.blackBackgroundView?.alpha = 0
            self.inputContainerView.alpha = 1
        }, completion: { (completed) in
            zoomingImageView.removeFromSuperview()
            self.startingImageView?.alpha = 1
        })
    }
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

extension ChatLogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
            // Video selected from library
            sendVideoToFirebaseStorage(withUrl: videoUrl)
        }else{
            // Image selected from library
            handleImageSelected(forInfo: info)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func sendVideoToFirebaseStorage(withUrl url:URL){
        let filename = UUID().uuidString
        let videoRef = Storage.storage().reference().child("message_videos").child("\(filename).mov")
        let videoUploadHandle = videoRef.putFile(from: url, metadata: nil) { (metadata, error) in
            if let err = error{
                print(err.localizedDescription)
                return
            }
            
            if let videoStorageUrl = metadata?.downloadURL()?.absoluteString{
                guard let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url) else{ return }
                self.sendImageToFirebaseStorage(image: thumbnailImage, completion: { (imageUrl) in
                    self.sendVideoMessage(videoUrl: videoStorageUrl, thumbnailImageUrl: imageUrl, imageSize: thumbnailImage.size)
                })
                

            }
        }
        
        videoUploadHandle.observe(.progress) { (snapshot) in
            DispatchQueue.main.async {
                self.title = "\(snapshot.progress!.completedUnitCount)"
            }
        }
        videoUploadHandle.observe(.success) { (snapshot) in
            guard let user = self.selectedChatUser else{ return }
            self.title = user.name
        }
    }
    
    private func handleImageSelected(forInfo info:[UIImagePickerController.InfoKey : Any]){
        var selectedImage: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImage = editedImage
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImage = originalImage
        }
        
        if let image = selectedImage{
            sendImageToFirebaseStorage(image: image) { (imageUrl) in
                self.sendImageMessage(withUrlString: imageUrl, andSize: image.size)
            }
        }
    }
    
    func sendImageToFirebaseStorage(image:UIImage, completion: @escaping (_ imageUrl:String) -> ()){
        let uuid = NSUUID().uuidString
        let messageImageRef = Storage.storage().reference().child("message_images").child(uuid)
        if let uploadData = image.jpegData(compressionQuality: 0.2){
            messageImageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if let err = error{
                    print(err.localizedDescription)
                    return
                }
                if let downUrlStr = metadata?.downloadURL()?.absoluteString{
                    completion(downUrlStr)
                }
            }
        }
    }
    
    func sendImageMessage(withUrlString url:String, andSize size:CGSize?){
        var values = fillInOtherMessageParameters()
        values["imageUrl"] = url
        if let width = size?.width{
            values["imageWidth"] = "\(width)"
        }
        if let height = size?.height{
            values["imageHeight"] = "\(height)"
        }
        handleSend(with: values as [String : AnyObject])
    }
    
    func sendVideoMessage(videoUrl url:String, thumbnailImageUrl:String, imageSize:CGSize){
        var values = fillInOtherMessageParameters()
        values["videoUrl"] = url
        values["imageUrl"] = thumbnailImageUrl
        values["imageWidth"] = "\(imageSize.width)"
        values["imageHeight"] = "\(imageSize.height)"
        handleSend(with: values as [String : AnyObject])
    }
    
    private func thumbnailImageForFileUrl(fileUrl:URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do{
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        }catch let err{
            print(err.localizedDescription)
        }
        return nil
    }
    
    func fillInOtherMessageParameters() -> [String:String]{
        if let toUserId = selectedChatUser?.id{
            if let fromUserId = Auth.auth().currentUser?.uid{
                let timestamp = Int(NSDate().timeIntervalSince1970)
                return ["fromId":fromUserId, "toId":toUserId, "timestamp":"\(timestamp)"]
            }
        }
        return [String:String]()
    }
    
    @objc func sendTextMessage(){
        var values = fillInOtherMessageParameters()
        guard let messageBody = messageTextField.text else { return }
        values["text"] = messageBody
        handleSend(with: values as [String : AnyObject])
    }
    
    @objc func handleSend(with values:[String:AnyObject]){
        guard let fromUserId = values["fromId"] as? String else{ return }
        guard let toUserId = values["toId"] as? String else{ return }
        let messageRef = Database.database().reference().child("messages").childByAutoId()
        messageRef.updateChildValues(values) { (error, returnRef) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            let userMessagesRef = Database.database().reference().child("user-messages")
            let fromUserMessagesRef = userMessagesRef.child(fromUserId).child(toUserId)
            let toUserMessagesRef = userMessagesRef.child(toUserId).child(fromUserId)
            
            let messageId = messageRef.key
            
            fromUserMessagesRef.updateChildValues([messageId:1])
            toUserMessagesRef.updateChildValues([messageId:1])
        }
        messageTextField.text = ""
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        dismiss(animated: true, completion: nil)
    }
}
