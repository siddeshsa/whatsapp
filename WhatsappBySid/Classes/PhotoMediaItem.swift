//
//  PhotoMediaItem.swift
//  WhatsappBySid
//
//  Created by mac on 19/05/20.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class PhotoMediaItem: JSQPhotoMediaItem{
    
    override func mediaViewDisplaySize() -> CGSize {
        let defaultSize : CGFloat = 256
        
        var thumbsize : CGSize = CGSize(width: defaultSize, height: defaultSize)
        
        if (self.image != nil && self.image.size.height > 0 && self.image.size.width > 0){
            let aspect : CGFloat = self.image.size.width / self.image.size.height
            
            if(self.image.size.width > self.image.size.height){
                thumbsize = CGSize(width: defaultSize, height: defaultSize / aspect)
            }else{
                thumbsize = CGSize(width: defaultSize * aspect, height: defaultSize)
            }
        }
        return thumbsize
    }
}
