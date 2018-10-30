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
    var id:String
    var name:String
    var email:String
    var imageUrlString:String
    
    override init() {
        id = ""
        name = ""
        email = ""
        imageUrlString = ""
    }
    
    init(id:String, name: String, email:String, imageUrlString:String){
        self.id = id
        self.name = name
        self.email = email
        self.imageUrlString = imageUrlString
    }
    
    convenience init(dict:[String:AnyObject]){
        guard let id = dict["id"] as? String else {
            self.init()
            return
        }
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
        self.init(id: id, name: name, email: email, imageUrlString: imageUrlString)
    }
    
    convenience init(snapshot:DataSnapshot){
        if var userDict = snapshot.value as? [String:AnyObject]{
            userDict["id"] = snapshot.key as AnyObject
            self.init(dict: userDict)
        }else{
            self.init()
        }
    }
}
