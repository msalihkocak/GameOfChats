//
//  LoginController.swift
//  GameOfChats
//
//  Created by Mehmet Salih Koçak on 23.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    lazy var loginRegisterButton : UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    @objc func handleRegister(){
        guard let email = mailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let name = nameTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let err = error{
                print(err.localizedDescription)
                return
            }
            guard let uid = user?.uid else{ return }
            let ref = Database.database().reference(fromURL: "https://gameofchats-6c7c0.firebaseio.com/")
            let usersReference = ref.child("users").child(uid)
            usersReference.updateChildValues(["name":name,"email":email], withCompletionBlock: { (err, ref) in
                                    if err != nil{
                                        print(err!.localizedDescription)
                                        return
                                    }
                                    print("Saved user successfully into firebase db")
            })
        }
    }
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Name"
        return textField
    }()
    
    let nameSeperator: UIView = {
        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = UIColor.lightGray
        return seperator
    }()
    
    let mailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.placeholder = "Email"
        return textField
    }()
    
    let mailSeperator: UIView = {
        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = UIColor.lightGray
        return seperator
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let profileImageView:  UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gameofthrones_splash")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainView()
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupTextFields()
        setupImageView()
    }
    
    func setupMainView(){
        view.backgroundColor = UIColor(r:61, g:91, b:151)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(tap:))))
        
        [inputsContainerView, loginRegisterButton, profileImageView].forEach({view.addSubview($0)})
    }
    
    func setupImageView(){
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25).isActive = true
    }
    
    func setupInputsContainerView(){
        // need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9, constant: 0).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        [nameTextField, nameSeperator, mailTextField, mailSeperator, passwordTextField].forEach({inputsContainerView.addSubview($0)})
    }
    
    func setupLoginRegisterButton(){
        // need x, y, width, height constraints
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraintEqualToSystemSpacingBelow(inputsContainerView.bottomAnchor, multiplier: 1.2).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupTextFields(){
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameSeperator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        mailTextField.topAnchor.constraint(equalTo: nameSeperator.bottomAnchor).isActive = true
        mailSeperator.topAnchor.constraint(equalTo: mailTextField.bottomAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: mailSeperator.bottomAnchor).isActive = true
        
        [nameTextField, mailTextField, passwordTextField].forEach {
            $0.leftAnchor.constraintEqualToSystemSpacingAfter(inputsContainerView.leftAnchor, multiplier: 1.1).isActive = true
            $0.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier:0.95).isActive = true
            $0.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        }
        
        [nameSeperator, mailSeperator].forEach {
            $0.centerXAnchor.constraint(equalTo: inputsContainerView.centerXAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @objc func viewTapped(tap:UITapGestureRecognizer){
        [nameTextField, mailTextField, passwordTextField].forEach {
            $0.resignFirstResponder()
        }
    }
}

extension UIColor{
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
    }
}
