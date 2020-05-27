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



class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {

    var chatRoomId: String!
    var memberIds: [String]!
    var membersToPush: [String]!
    var titleName: String!
    var isGroup: Bool?
    var group: NSDictionary?
    var withUsers: [FUser] = []
    
    var typingListener: ListenerRegistration?
    var updatedChatListener: ListenerRegistration?
    var newChatListener : ListenerRegistration?
    
    
    
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
    
    
    let leftBarButtonView : UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 200, height: 44))
        return view
    }()

    let avatarButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y:10, width: 25, height: 25))
        return button
    }()
    
    let titleLabel : UILabel = {
        let title = UILabel(frame: CGRect(x: 30, y: 10, width: 140, height: 15))
        title.textAlignment = .left
        title.font = UIFont(name: title.font.fontName, size: 14)
        return title
    }()
    
    let subTitle : UILabel = {
        let subtitle = UILabel(frame: CGRect(x: 30, y: 25, width: 140, height: 15))
        subtitle.textAlignment = .left
        subtitle.font = UIFont(name: subtitle.font.fontName, size: 10)
        return subtitle
    }()
    
    
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

        setCustomTitle()
        
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
    
    
   
    
    
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]

        if data.senderId == FUser.currentId() {
            cell.textView.textColor = .white
        }else{
            cell.textView.textColor = .black
        }
        return cell
    }
    
  
    
    
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
 
    
    
    
    
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
   
    
    
    
    
    
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentId(){
            return outgoingBubble
        }else{
            return incomingBubble
        }
    }
    
  
    
    
    
    
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0{
            let message = messages[indexPath.row]
            
            return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    
    
    
    
    
    
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0{
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }else{
            return 0.0
        }
    }
    
    
  
    
    
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = objectMessages[indexPath.row]
        let status: NSAttributedString!
        let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.darkGray]
        
        switch message[kSTATUS] as! String {
        case kDELIVERED:
            status = NSAttributedString(string: kDELIVERED)
            
        case kREAD:
            let statusText = "Read" + " " + readTimeFrom(dateString: message[kREADDATE] as! String)
            status = NSAttributedString(string: statusText, attributes: attributedStringColor )
            
        default:
            status = NSAttributedString(string: "✔️")
        }
        
        if indexPath.row == (messages.count - 1){
            return status
        }else{
            return NSAttributedString(string: " ")
        }
    }
    
    
    
    
    
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentId(){
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }else{
            return 0.0
        }
    }
    
    
    
    
    
    
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("camera")
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
                camera.PresentPhotoLibrary(target: self, canEdit: false)

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
    
    
    
    
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
        self.collectionView.reloadData()
    }
    
    
    
    
    //mark: send messages
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video:NSURL?, audio: String?){
        var outgoingMessage: OutgoingMessage?
        let currentUser = FUser.currentUser()!
        
        //text message
        if let text = text{
            outgoingMessage = OutgoingMessage(message: text, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        
        //picture message
        
        if let pic = picture{
            
            uploadImage(image: pic, chatRoomId: chatRoomId, view: self.navigationController!.view) { (imageLink) in
                if imageLink != nil {
                        let text = kPICTURE
                     outgoingMessage = OutgoingMessage(message: text, pictureLink: imageLink!, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kPICTURE)
                    
                        JSQSystemSoundPlayer.jsq_playMessageSentSound()
                        self.finishSendingMessage()
                    
                    outgoingMessage?.sendMessage(chatRoomId: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                    
                    
                }
            }
            return
        }
        
        //send video
        
        if let video = video{
            
        let videoData = NSData(contentsOfFile: video.path!)
            
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
            
            //get picture messsages
            
            self.getOldMessagesInBackground()
            self.listenForNewChats()

    }
    }
    
    
    
    
    
    func listenForNewChats(){
        var lastMessageDate = "0"
        
        if loadedMessages.count > 0{
            lastMessageDate = loadedMessages.last![kDATE] as! String
        }
        
        newChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isGreaterThan:lastMessageDate).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else{
                return
            }
            if !snapshot.isEmpty {
                for diff in snapshot.documentChanges {
                    if ( diff.type  == .added ){
                        let item = diff.document.data() as NSDictionary
                        if let type = item[kTYPE]{
                            if self.legitTypes.contains(type as! String){
                                //gthis is for picture message
                                if type as! String == kPICTURE{
                                    
                                }
                                
                                if self .insertInitialLoadMessages(messageDictionary: item){
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                }
                                self.finishReceivingMessage()
                            }
                        }
                    }
                }
            }
        })
    }
    
    
    
    
    
    func getOldMessagesInBackground(){
        if loadedMessages.count > 10 {
            let firstMessageDate = loadedMessages.first![kDATE] as! String
            reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isLessThan: firstMessageDate).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else{
                    return
                }
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as! NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
                
                
                self.loadedMessages = self.removeBadMessages(allMessages: sorted) + self.loadedMessages
                
                //get picture mesages
                
                self.maxMessageNumber = self.loadedMessages.count - self.loadedMessagesCount - 1
                self.minMessageNumber = self.maxMessageNumber - kNUMBEROFMESSAGES
                
            }
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
    
    
    
    
    func loadMoreMessages(maxNumber: Int, minNumber: Int){
        
        if loadOld{
            maxMessageNumber = minNumber - 1
            minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        }
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed(){
            let messageDictionary =  loadedMessages[i]
            insertNewMessage(messageDictionary: messageDictionary )
        }
        
        loadOld = true
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    
    
    
    
    
    
    func insertNewMessage(messageDictionary: NSDictionary){
        let incomingMessage = IncomingMessges(collectionView_: self.collectionView!)
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
        objectMessages.insert(messageDictionary, at: 0)
        messages.insert(message!, at: 0)
    }
    
    
    
    //ibactions
    
    
    @objc func infoButtonPressed(){
        print("info button pressed")
    }
    
    
    @objc func showGroup(){
        print("show group pressed")
    }
    
    @objc func showUserProfile(){
        print("show user profile")
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView")   as! ProfileTableViewController
        profileVC.user = withUsers.first!
        self.navigationController?.pushViewController(profileVC, animated: true)
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

    
    
    
    //MARK:updateUI
    
    func setCustomTitle(){
        
        leftBarButtonView.addSubview(avatarButton)
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitle)
        
        let infoButton = UIBarButtonItem(image: UIImage(named: "info"), style: .plain, target: self, action: #selector(self.infoButtonPressed))
        
        self.navigationItem.rightBarButtonItem = infoButton
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        if isGroup!{
            avatarButton.addTarget(self, action: #selector(self.showGroup), for: .touchUpInside)
        }else{
            avatarButton.addTarget(self, action: #selector(self.showUserProfile), for: .touchUpInside)

        }
        
        getUsersFromFirestore(withIds: memberIds) { (withUsers) in
            self.withUsers = withUsers
            
            if !self.isGroup! {
                self.setUIForSingleChat()
            }
        }
    }
    
    
    
    func setUIForSingleChat(){
        let withUser = withUsers.first!
        
        imageFromData(pictureData: withUser.avatar) { (image) in
            if image != nil {
                avatarButton.setImage(image!.circleMasked, for: .normal)
            }
        }
        titleLabel.text = withUser.fullname
        
        if withUser.isOnline{
            subTitle.text = "Online"
        }else{
            subTitle.text = "Offline"
            
        }
        avatarButton.addTarget(self, action: #selector(self.showUserProfile), for: .touchUpInside)
    }
    
    
    
    
    
    
    //MARK: UIImagePickerController delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        sendMessage(text: nil, date: Date(), picture: picture, location: nil, video: video, audio: nil)
       
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    //helper functions
    func readTimeFrom(dateString: String)-> String{
        let date = dateFormatter().date(from: dateString)
        
        let currentDataFormat = dateFormatter()
        currentDataFormat.dateFormat = "HH:mm"
        
        return currentDataFormat.string(from: date!)
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
