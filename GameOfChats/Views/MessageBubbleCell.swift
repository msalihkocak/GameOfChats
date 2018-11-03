//
//  MessageBubbleCell.swift
//  GameOfChats
//
//  Created by Mehmet Salih Koçak on 30.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class MessageBubbleCell: UICollectionViewCell {
    
    var chatLogController: ChatLogController?
    var message:Message?
    
    var messageTextLabel:UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.white
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    static let grayColor = UIColor(r: 230, g: 230, b: 230)
    
    var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var playVideoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "play"), for: .normal)
        button.addTarget(self, action: #selector(handlePlayVideoTap), for: .touchUpInside)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiview = UIActivityIndicatorView(style: .whiteLarge)
        aiview.translatesAutoresizingMaskIntoConstraints = false
        aiview.hidesWhenStopped = true
        return aiview
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    var profileLeftAnchor: NSLayoutConstraint?
    var profileWidthAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(messageTextLabel)
        addSubview(profileImageView)
        
        setupBubbleView()
        setupTextView()
        setupImageView()
        setupMessageImageView()
        setupVideoPlayButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupMessageImageView(){
        bubbleView.addSubview(messageImageView)
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    }
    
    func setupVideoPlayButton(){
        bubbleView.addSubview(playVideoButton)
        playVideoButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playVideoButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playVideoButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playVideoButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        setupActivityIndicatorView()
    }
    
    func setupActivityIndicatorView(){
        bubbleView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupImageView(){
        profileLeftAnchor = profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8)
        profileLeftAnchor?.isActive = true
        
        profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        profileWidthAnchor = profileImageView.widthAnchor.constraint(equalToConstant: 32)
        profileWidthAnchor?.isActive = true
        
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    func showProfileImage(){
        bubbleRightAnchor?.isActive = false
        profileLeftAnchor?.isActive = true
        profileWidthAnchor?.constant = 32
        bubbleLeftAnchor?.isActive = true
    }
    
    func hideProfileImage(){
        profileLeftAnchor?.isActive = false
        profileWidthAnchor?.constant = 0
        bubbleLeftAnchor?.isActive = false
        bubbleRightAnchor?.isActive = true
    }
    
    func setupBubbleView(){
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func setupTextView(){
        messageTextLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        messageTextLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        messageTextLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        messageTextLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    @objc func handleZoomTap(tapGesture:UITapGestureRecognizer){
        if message?.videoUrl != ""{
            return
        }
        //PRO Tip: Don't perform a lot of custom logic inside of a view class
        guard let imageView = tapGesture.view as? UIImageView else{ return }
        self.chatLogController?.performZoomInForImageView(imageToZoomIn: imageView)
    }
    
    var playerLayer: AVPlayerLayer?
    var player:AVPlayer?
    
    @objc func handlePlayVideoTap(){
        guard let msg = message else{ return }
        guard let url = URL(string: msg.videoUrl) else{ return }
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bubbleView.bounds
        bubbleView.layer.addSublayer(playerLayer!)
        player?.play()
        activityIndicatorView.startAnimating()
        playVideoButton.isHidden = true
        //if player?.
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        activityIndicatorView.stopAnimating()
//        playerLayer = nil
//        player = nil
    }
}
