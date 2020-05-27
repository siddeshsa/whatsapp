//
//  OutgoingMessages.swift
//  WhatsappBySid
//
//  Created by mac on 07/05/20.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation

class OutgoingMessage{
    let messageDictionary : NSMutableDictionary
    
    //mark
    //text message
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String ) {
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date),status,type], forKeys: [kMESSAGE as NSCopying,kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying ])
    }
    
    
    //picture message
    init(message: String,pictureLink:String, senderId: String, senderName: String, date: Date, status: String, type: String ) {
        messageDictionary = NSMutableDictionary(objects: [message, pictureLink, senderId, senderName, dateFormatter().string(from: date),status,type], forKeys: [kMESSAGE as NSCopying,kPICTURE as NSCopying ,kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying ])
    }
    
    // video message
    init(message: String,video: String, thumnbNail: NSData,senderId: String, senderName: String, date: Date, status: String, type: String ){
        let picThumb = thumnbNail.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        messageDictionary = NSMutableDictionary(objects: [message, video, picThumb, senderId, senderName, dateFormatter().string(from: date),status,type], forKeys: [kMESSAGE as NSCopying,kVIDEO as NSCopying ,kPICTURE as NSCopying,kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying ])
        
    }
    
    
    func sendMessage(chatRoomId: String, messageDictionary: NSMutableDictionary, memberIds: [String], membersToPush: [String]){
            var messageId = UUID().uuidString
            messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIds{
            reference(.Message).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String:Any])
        }
    }
}
