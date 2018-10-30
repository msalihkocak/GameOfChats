//
//  UserCell.swift
//  GameOfChats
//
//  Created by BTK Apple on 30.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell{
    
    var message: Message?{
        didSet{
            self.setupNameAndProfileImage()
            let date = Date(timeIntervalSince1970: TimeInterval(truncating: self.message!.timestamp))
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "H:mm"
            let dateString = formatter.string(from: date)
            self.timeLabel.text = dateString
            self.setupTimeLabel()
        }
    }
    
    func setupNameAndProfileImage(){
        let chatPartnerId: String?
        if message?.fromId == Auth.auth().currentUser?.uid{
            chatPartnerId = message?.toId
        }else{
            chatPartnerId = message?.fromId
        }
        guard let id = chatPartnerId else{ return }
        let ref = Database.database().reference().child("users").child(id)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let user = User(snapshot: snapshot)
            self.textLabel?.text = user.name
            self.detailTextLabel?.text = self.message!.text
            self.profileImageView.loadImageUsingCacheWithUrlString(urlString: user.imageUrlString)
        }
    }
    
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 28
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let timeLabel:UILabel = {
        let label = UILabel()
        label.text = "HH:MM:SS"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.light)
        label.textColor = UIColor.gray
        label.textAlignment = .right
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 80, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 80, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        textLabel?.numberOfLines = 0
        
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 56).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        setupTimeLabel()
    }
    
    func setupTimeLabel(){
        if message != nil{
            addSubview(timeLabel)
            timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            timeLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
            timeLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
