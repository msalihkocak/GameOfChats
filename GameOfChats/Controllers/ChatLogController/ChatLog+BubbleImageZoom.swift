//
//  ChatLog+BubbleImageZoom.swift
//  GameOfChats
//
//  Created by Mehmet Salih Koçak on 3.11.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit

//For interaction with cells
// MARK: Interaction with Message Cells
extension ChatLogController{
    func performZoomInForImageView(imageToZoomIn:UIImageView){
        inputContainerView.messageTextField.resignFirstResponder()
        startingImageView = imageToZoomIn
        startingImageView?.alpha = 0
        
        startingFrame = imageToZoomIn.superview?.convert(imageToZoomIn.frame, to: nil)
        guard let keyWindow = UIApplication.shared.keyWindow else{ return }
        
        blackBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height))
        blackBackgroundView?.backgroundColor = .black
        blackBackgroundView?.alpha = 0
        keyWindow.addSubview(blackBackgroundView!)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = imageToZoomIn.image
        zoomingImageView.layer.cornerRadius = 16
        zoomingImageView.clipsToBounds = true
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performZoomOutFromImage(tapGesture:))))
        
        keyWindow.addSubview(zoomingImageView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let height = (self.startingFrame!.height / self.startingFrame!.width) * keyWindow.frame.width
            zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            zoomingImageView.center = keyWindow.center
            
            zoomingImageView.layer.cornerRadius = 0
            self.blackBackgroundView?.alpha = 1
            self.inputContainerView.alpha = 0
            
        }, completion: nil)
    }
    
    @objc func performZoomOutFromImage(tapGesture:UITapGestureRecognizer){
        guard let zoomingImageView = tapGesture.view as? UIImageView else{ return }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            zoomingImageView.frame = self.startingFrame!
            
            zoomingImageView.layer.cornerRadius = 16
            self.blackBackgroundView?.alpha = 0
            self.inputContainerView.alpha = 1
        }, completion: { (completed) in
            zoomingImageView.removeFromSuperview()
            self.startingImageView?.alpha = 1
        })
    }
}
