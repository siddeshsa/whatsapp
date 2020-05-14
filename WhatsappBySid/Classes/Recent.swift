//
//  Recent.swift
//  WhatsappBySid
//
//  Created by mac on 29/04/20.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation

func startPrivateChat(user1: FUser, user2: FUser)-> String{
    let userid1 = user1.objectId
    let userid2 = user2.objectId
    
    var chatroomid = ""
    let value = userid1.compare(userid2).rawValue
    
    if value < 0{
        chatroomid = userid1 + userid2
    }else{
        chatroomid = userid2 + userid1
    }
    let members = [userid1,userid2]
    
    createRecent(members: members, chatroomid: chatroomid, withUserUserName: "", type: kPRIVATE, users: [user1,user2], avatarOfGroup: nil)
    return chatroomid
}


func createRecent(members: [String], chatroomid: String, withUserUserName: String, type: String, users :[FUser]?, avatarOfGroup: String?){
    
    var tempmembers = members
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatroomid).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else{
            return
        }
        
        
        
        
        if !snapshot.isEmpty{
            
            for recent in snapshot.documents{
                
                let currentRecent = recent.data() as NSDictionary
                
                if let currentUserId = currentRecent[kUSERID] {
                    
                    if tempmembers.contains(currentUserId as! String){
                        tempmembers.remove(at: tempmembers.index(of:currentUserId as! String)!)
                    }
                    
                }
            }
        }
        
        for userid in tempmembers{
            //create recent items
            createRecentItem(userId: userid, chatRoomId: chatroomid, members: members, withUserUserName: withUserUserName, type: type, users: users, avatarOfGroup: avatarOfGroup)
        }
        
    }
    
}


func  createRecentItem(userId:String, chatRoomId:String, members: [String],withUserUserName:String, type:String,users:[FUser]?, avatarOfGroup: String? ) {
    let  localReference = reference(.Recent).document()
    let recentId = localReference.documentID
    
    let date = dateFormatter().string(from: Date())
    var recent : [String : Any]!
    
    //private one to one chat
    if type == kPRIVATE{
        var withUser :FUser?
        if users != nil && users!.count > 0{
            if userId == FUser.currentId(){
            withUser = users!.last!
            }else{
                 withUser = users!.first!
            }
        }
        recent = [kRECENTID: recentId,kUSERID: userId, kCHATROOMID: chatRoomId, kMEMBERS: members, kMEMBERSTOPUSH: members, kWITHUSERFULLNAME: withUser!.fullname, kWITHUSERUSERID: withUser!.objectId, kLASTMESSAGE: "" , kCOUNTER:0, kDATE:date, kTYPE:type, kAVATAR:withUser!.avatar ] as [String:Any]
    }
    //group chat
    else{
        if avatarOfGroup != nil{
         recent = [kRECENTID: recentId,kUSERID: userId, kCHATROOMID: chatRoomId, kMEMBERS: members, kMEMBERSTOPUSH: members, kWITHUSERFULLNAME: withUserUserName, kLASTMESSAGE: "" , kCOUNTER:0, kDATE:date, kTYPE:type, kAVATAR:avatarOfGroup! ] as [String:Any]
        }
        }
    
    //save recent chat
    localReference.setData(recent)
    
}
//restart chat

func restartRecentChat(recent:NSDictionary){
    if recent[kTYPE] as! String == kPRIVATE{
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatroomid: recent[kCHATROOMID] as! String, withUserUserName: FUser.currentUser()!.firstname as! String, type: kPRIVATE, users: [FUser.currentUser()!], avatarOfGroup: nil)
    }
    if recent[kTYPE] as! String == kGROUP{
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatroomid: recent[kCHATROOMID] as! String, withUserUserName: recent[kWITHUSERUSERNAME] as! String, type: kGROUP, users: nil, avatarOfGroup: recent[kAVATAR] as? String)
    }
}

//MARK: Delete Recent
func deleteRecentChat(recentChatDictionary: NSDictionary){

    if let recentId = recentChatDictionary[kRECENTID]{
        reference(.Recent).document(recentId as! String).delete()
    }
}
