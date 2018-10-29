//
//  User.swift
//  GameOfChats
//
//  Created by BTK Apple on 28.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase

class User: NSObject {
    var name:String
    var email:String
    var imageUrlString:String
    
    override init() {
        name = ""
        email = ""
        imageUrlString = ""
    }
    
    init(name: String, email:String, imageUrlString:String){
        self.name = name
        self.email = email
        self.imageUrlString = imageUrlString
    }
    
    convenience init(dict:[String:AnyObject]){
        guard let name = dict["name"] as? String else {
            self.init()
            return
        }
        guard let email = dict["email"] as? String else {
            self.init()
            return
        }
        guard let imageUrlString = dict["imageUrlString"] as? String else {
            self.init()
            return
        }
        self.init(name: name, email: email, imageUrlString: imageUrlString)
    }
    
    convenience init(snapshot:DataSnapshot){
        if let userDict = snapshot.value as? [String:AnyObject]{
            self.init(dict: userDict)
        }else{
            self.init()
        }
    }
}
