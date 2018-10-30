//
//  Extensions.swift
//  GameOfChats
//
//  Created by BTK Apple on 29.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView{
    func loadImageUsingCacheWithUrlString(urlString:String){
        self.image = nil
        if let image = imageCache.object(forKey: urlString as NSString){
            DispatchQueue.main.async {
                self.image = image
            }
        }else{
            if let url = URL(string: urlString){
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if error != nil{
                        print("Image download failed: \(error!.localizedDescription)")
                        return
                    }
                    if let imageData = data{
                        if let image = UIImage(data: imageData){
                            imageCache.setObject(image, forKey: urlString as NSString)
                            DispatchQueue.main.async {
                                self.image = image
                            }
                        }
                    }
                }.resume()
            }
        }
    }
}


extension UIColor{
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
    }
}
