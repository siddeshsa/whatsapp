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
    
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String ) {
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date),status,type], forKeys: [kMESSAGE as NSCopying,kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying ])
    }
    
    
    func sendMessage(chatRoomId: String, messageDictionary: NSMutableDictionary, memberIds: [String], membersToPush: [String]){
            var messageId = UUID().uuidString
            messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIds{
            reference(.Message).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String:Any])
        }
    }
}
