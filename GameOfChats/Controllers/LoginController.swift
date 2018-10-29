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
    
    var messagesVC: MessagesController?
    let placeholderImageAddress = "https://static.comicvine.com/uploads/square_small/1/15659/4261710-x-gene-x-men2013-marvel_now_promo_art-edited.jpg"
    
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
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
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
    
    lazy var profileImageView:  UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gameofthrones_splash")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainView()
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupTextFields()
        setupImageView()
        setupLoginRegisterSegmentedControl()
    }
    
    func setupMainView(){
        view.backgroundColor = UIColor(r:61, g:91, b:151)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(tap:))))
        
        [inputsContainerView, loginRegisterButton, profileImageView, loginRegisterSegmentedControl].forEach({view.addSubview($0)})
    }
    
    func setupLoginRegisterSegmentedControl(){
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupImageView(){
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25).isActive = true
    }
    
    var inputsContainerViewHeightAnchor : NSLayoutConstraint?
    
    func setupInputsContainerView(){
        // need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9, constant: 0).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        [nameTextField, nameSeperator, mailTextField, mailSeperator, passwordTextField].forEach({inputsContainerView.addSubview($0)})
    }
    
    func setupLoginRegisterButton(){
        // need x, y, width, height constraints
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraintEqualToSystemSpacingBelow(inputsContainerView.bottomAnchor, multiplier: 1.2).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    var nameTextFieldHeighAnchor : NSLayoutConstraint?
    var mailTextFieldHeighAnchor : NSLayoutConstraint?
    
    func setupTextFields(){
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameSeperator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        mailTextField.topAnchor.constraint(equalTo: nameSeperator.bottomAnchor).isActive = true
        mailSeperator.topAnchor.constraint(equalTo: mailTextField.bottomAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: mailSeperator.bottomAnchor).isActive = true
        
        [nameTextField, mailTextField, passwordTextField].forEach {
            $0.leftAnchor.constraintEqualToSystemSpacingAfter(inputsContainerView.leftAnchor, multiplier: 1.1).isActive = true
            $0.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier:0.95).isActive = true
        }
        
        [nameSeperator, mailSeperator].forEach {
            $0.centerXAnchor.constraint(equalTo: inputsContainerView.centerXAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        nameTextFieldHeighAnchor = nameTextField.heightAnchor.constraint(equalTo: mailTextField.heightAnchor, multiplier: 1)
        mailTextFieldHeighAnchor = mailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextField.heightAnchor.constraint(equalTo: mailTextField.heightAnchor, multiplier: 1).isActive = true
        
        nameTextFieldHeighAnchor?.isActive = true
        mailTextFieldHeighAnchor?.isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}

extension UIColor{
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
    }
}
