//
//  IncomingMessages.swift
//  WhatsappBySid
//
//  Created by mac on 08/05/20.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessges{
    var collectionView : JSQMessagesCollectionView
    
    
    init(collectionView_: JSQMessagesCollectionView) {
    collectionView = collectionView_
    }
    
    func createMessage(messageDictionary:NSDictionary, chatRoomId: String)-> JSQMessage?{
        
        var message : JSQMessage?
        
        let type = messageDictionary[kTYPE] as! String
        
        switch type {
        case kTEXT:
        print("create text message")
            message = createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
        print("create picture message")
            message = createPictureMessage(messageDictionary: messageDictionary)
        case kAUDIO:
        print("create audio message")
        case kVIDEO:
        print(" //create video message")
        case kLOCATION:
        print("create location message")
        default:
            print("unknown message type")
        }
        
        if message != nil{
            return message
        }
        return nil
    }



func createTextMessage(messageDictionary: NSDictionary, chatRoomId: String)-> JSQMessage{
    
    let name = messageDictionary[kSENDERNAME] as? String
    let id = messageDictionary[kSENDERID] as? String
    var date : Date!
    
    if let created = messageDictionary[kDATE]{
        if(created as! String).count != 14 {
            date = Date()
        }else{
            date = dateFormatter().date(from: created as! String)
        }
    }else{
        date = Date()
    }
    let text = messageDictionary[kMESSAGE] as! String
    return JSQMessage(senderId:id, senderDisplayName: name, date: date, text: text)
    

}
    
    
    func createPictureMessage(messageDictionary: NSDictionary)-> JSQMessage{
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userid = messageDictionary[kSENDERID] as? String
        
        var date : Date!
        
        if let created = messageDictionary[kDATE]{
            if(created as! String).count != 14 {
                date = Date()
            }else{
                date = dateFormatter().date(from: created as! String)
            }
        }else{
            date = Date()
        }
        
        let mediaItem = PhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingMessageStatusForUser(senderId: userid!)
        
        downloadImage(imageUrl: messageDictionary[kPICTURE] as! String) { (image) in
            if image != nil{
                mediaItem?.image = image!
                self.collectionView.reloadData()
            }
        }
        
        return JSQMessage(senderId: userid, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    
    // Helper:
    
    
    func returnOutgoingMessageStatusForUser(senderId: String) -> Bool {

        
        return senderId == FUser.currentId()
    }
}
