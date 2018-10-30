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
    
    override init() {
        self.id = ""
        self.fromId = ""
        self.toId = ""
        self.text = ""
        self.timestamp = 0
    }
    
    init(id:String, fromId:String, toId: String, text:String, timestamp:NSNumber){
        self.id = id
        self.fromId = fromId
        self.toId = toId
        self.text = text
        self.timestamp = timestamp
    }
    
    convenience init(dict:[String:AnyObject]){
        guard let id = dict["id"] as? String else {
            self.init()
            return
        }
        guard let fromId = dict["fromId"] as? String else {
            self.init()
            return
        }
        guard let toId = dict["toId"] as? String else {
            self.init()
            return
        }
        guard let text = dict["text"] as? String else {
            self.init()
            return
        }
        guard let timestampString = dict["timestamp"] as? String, let timestamp = Int(timestampString) else {
            self.init()
            return
        }
        
        let tmstmp = NSNumber(integerLiteral: timestamp)
        self.init(id: id, fromId: fromId, toId: toId, text: text, timestamp: tmstmp)
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
