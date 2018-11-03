//
//  ChatLog+MediaOps.swift
//  GameOfChats
//
//  Created by Mehmet Salih Koçak on 3.11.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MobileCoreServices

extension ChatLogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @objc func handleUploadImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
        present(picker, animated: true, completion: nil)
    }
    
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
        guard let messageBody = inputContainerView.messageTextField.text else { return }
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
        inputContainerView.messageTextField.text = ""
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        dismiss(animated: true, completion: nil)
    }
}
