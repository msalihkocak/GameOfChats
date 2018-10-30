//
//  LoginController+handlers.swift
//  GameOfChats
//
//  Created by BTK Apple on 28.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase

extension LoginController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @objc func handleSelectProfileImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImage = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = originalImage
        }
        
        if let image = selectedImage{
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleLoginRegister(){
        dismissKeyboard()
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0{
            handleLogin()
        }else{
            handleRegister()
        }
    }
    
    func handleRegister(){
        guard let email = mailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let name = nameTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let err = error{
                print(err.localizedDescription)
                return
            }
            guard let uid = user?.uid else{ return }
            
            let profileImagesRef = Storage.storage().reference().child("profile_images").child("user-\(uid).jpg")
            guard let imageData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1) else { return }
            var values = ["name":name,"email":email]
            profileImagesRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print("Image upload failed: \(error!.localizedDescription)")
                    values["imageUrlString"] = self.placeholderImageAddress
                }else{
                    guard let imageUrlString = metadata?.downloadURL()?.absoluteString else { return }
                    values["imageUrlString"] = imageUrlString
                }
                
                self.registerUserToDatabaseWithUid(uid: uid, andValues: values as [String : AnyObject])
            })
        }
    }
    
    func registerUserToDatabaseWithUid(uid:String, andValues values:[String:AnyObject]){
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil{
                print(err!.localizedDescription)
                return
            }
            var userDict = values
            userDict["id"] = uid as AnyObject
            self.messagesVC?.setupNavBarWithUser(user: User(dict: userDict))
            self.messagesVC?.resetUserMessages()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleLogin(){
        guard let email = mailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print("Could not login: \(error!.localizedDescription)")
                return
            }
            self.messagesVC?.fetchUserCredentials()
            self.messagesVC?.resetUserMessages()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleLoginRegisterChange(){
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        nameTextFieldHeighAnchor?.isActive = false
        nameTextFieldHeighAnchor = nameTextField.heightAnchor.constraint(equalTo: mailTextField.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1)
        nameTextFieldHeighAnchor?.isActive = true
        
        mailTextFieldHeighAnchor?.isActive = false
        mailTextFieldHeighAnchor = mailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        mailTextFieldHeighAnchor?.isActive = true
    }
    
    @objc func viewTapped(tap:UITapGestureRecognizer){
        dismissKeyboard()
    }
    
    @objc func dismissKeyboard(){
        [nameTextField, mailTextField, passwordTextField].forEach {
            $0.resignFirstResponder()
        }
    }
}
