//
//  Message.swift
//  GameOfChats
//
//  Created by BTK Apple on 30.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var id:String
    var fromId:String
    var toId:String
    var text:String
    var timestamp:NSNumber
    var imageUrl:String
    
    var imageWidth:NSNumber?
    var imageHeight:NSNumber?
    
    override init() {
        self.id = ""
        self.fromId = ""
        self.toId = ""
        self.text = ""
        self.timestamp = 0
        self.imageUrl = ""
    }
    
    init(id:String, fromId:String, toId: String, text:String, timestamp:NSNumber, imageUrl:String){
        self.id = id
        self.fromId = fromId
        self.toId = toId
        self.text = text
        self.timestamp = timestamp
        self.imageUrl = imageUrl
    }
    
    convenience init(dict:[String:AnyObject]){
        self.init()
        
        if let id = dict["id"] as? String {
            self.id = id
        }else{
            self.id = ""
        }
        
        if let fromId = dict["fromId"] as? String {
            self.fromId = fromId
        }else{
            self.fromId = ""
        }
        
        if let toId = dict["toId"] as? String {
            self.toId = toId
        }else{
            self.toId = ""
            
        }
        
        if let text = dict["text"] as? String {
            self.text = text
        }else{
            self.text = ""
        }
        
        if let timestampString = dict["timestamp"] as? String, let timestamp = Int(timestampString) {
            let tmstmp = NSNumber(integerLiteral: timestamp)
            self.timestamp = tmstmp
        }else{
            self.timestamp = 0
        }
        
        if let url = dict["imageUrl"] as? String{
            self.imageUrl = url
        }else{
            self.imageUrl = ""
        }

        if let widthStr = dict["imageWidth"] as? String, let width = Double(widthStr){
            self.imageWidth = NSNumber(floatLiteral: width)
        }
        if let heightStr = dict["imageHeight"] as? String, let height = Double(heightStr){
            self.imageHeight = NSNumber(floatLiteral: height)
        }
    }
    
    convenience init(snapshot:DataSnapshot){
        if var messageDict = snapshot.value as? [String:AnyObject]{
            messageDict["id"] = snapshot.key as AnyObject
            self.init(dict: messageDict)
        }else{
            self.init()
        }
    }
    
    func chatPartnerId() -> String{
        let chatPartnerId: String?
        if fromId == Auth.auth().currentUser?.uid{
            chatPartnerId = toId
        }else{
            chatPartnerId = fromId
        }
        guard let id = chatPartnerId else{ return "" }
        return id
    }
}
