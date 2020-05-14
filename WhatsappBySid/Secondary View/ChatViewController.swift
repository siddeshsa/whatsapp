//
//  ChatViewController.swift
//  WhatsappBySid
//
//  Created by mac on 05/05/20.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore



class ChatViewController: JSQMessagesViewController {

    var chatRoomId: String!
    var memberIds: [String]!
    var membersToPush: [String]!
    var titleName: String!
    
    var legitTypes = [kAUDIO,kVIDEO,kTEXT,kLOCATION,kPICTURE]
    
    var messages : [JSQMessage] = []
    var objectMessages : [NSDictionary] = []
    var loadedMessages : [NSDictionary] = []
    var allPictureMessages : [String] = []
     var initialLoadComplete = false
    
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleRed())
    var incomingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    
    
    // fix for alignment in iphone chat
   
    
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
            // fix for alignment in iphone chat ens
    
   
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        loadMessages()
        
       

        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.firstname

        
        // fix for alignment in iphone chat
        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        
        constraint.priority = UILayoutPriority(rawValue: 1000)
        
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
                // fix for alignment in iphone chat eend
        
        self.inputToolbar.contentView.rightBarButtonItem.setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        
    }
    
    
    
    
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
    let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("camera")
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            print("PhotoLibrary")
        }
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
            print("Video Library")
        }
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (action) in
            print("Share Location")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("cMancel")
        }
        
         takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
         sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
         shareVideo.setValue(UIImage(named: "video"), forKey: "image")
         shareLocation.setValue(UIImage(named: "location"), forKey: "image")
    
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu,animated: true, completion: nil)

    }
    
    
    
    
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != ""{
            self.sendMessage(text: text, date: date, picture: nil, location: nil, video: nil , audio: nil)
            
            
            updateSendButton(isSend: false  )
        }else{
            print("audio message")
        }
    }
    
    
    
    
    
    
    //mark: send messages
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video:NSURL?, audio: String?){
        var outgoingMessage: OutgoingMessage?
        let currentUser = FUser.currentUser()!
        
        //text message
        if let text = text{
            outgoingMessage = OutgoingMessage(message: text, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomId: chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memberIds, membersToPush: membersToPush)
    }
    
    
    
    
    
    func loadMessages(){
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments{(snapshot,error) in
            
            guard let snapshot = snapshot else{
                self.initialLoadComplete = true
                //listen for new chats
                return
            }
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents))as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            self.loadedMessages = self.removeBadMessages(allMessages: sorted)
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            self.initialLoadComplete = true
            
            print("we have \(self.messages.count) messages")

    }
    }
    
    
    
    
    //Mark:insert mesages
    
    func insertMessages(){
        maxMessageNumber = loadedMessages.count - loadedMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0 	
        }
        
        for i in minMessageNumber ..< maxMessageNumber{
            let messageDictionary = loadedMessages[i]
            print(messageDictionary)
            insertInitialLoadMessages(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    
    
    
    
    
    func insertInitialLoadMessages(messageDictionary: NSDictionary)-> Bool{
        let incomingMessage = IncomingMessges(collectionView_: self.collectionView!)
        if(messageDictionary[kSENDERID] as! String) != FUser.currentId(){
            //update message status
        }

        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)

        if message != nil{
            objectMessages.append(messageDictionary)
            messages.append(message!)
        }

        return isIncoming(messageDictionary:messageDictionary)
       
    }
    
    
    
    
    
    @objc func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != ""{
            updateSendButton(isSend: true)
        }else{
            updateSendButton(isSend: false)
        }
    }
    func updateSendButton(isSend: Bool){
        if isSend{
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        }else{
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        }
    }


    
    
    func removeBadMessages(allMessages: [NSDictionary])-> [NSDictionary]{
        var tempMessages = allMessages
        for message in tempMessages{
            if message[kTYPE] != nil{
                if !self.legitTypes.contains(message[kTYPE] as! String){
                    //remove the mwssage
                    tempMessages.remove(at: tempMessages.index(of: message)!)
                }
            }else{
                tempMessages.remove(at: tempMessages.index(of: message)!)
            }
        }
        return tempMessages
    }
    
    
    func isIncoming(messageDictionary: NSDictionary)->Bool{
        if FUser.currentId() == messageDictionary[kSENDERID] as! String{
            return false
        }else{
            return true
        }
    }
}
