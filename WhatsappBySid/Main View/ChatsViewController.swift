//
//  ChatsViewController.swift
//  WhatsappBySid
//
//  Created by mac on 25/04/20.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RecentChatsTableViewCellDelegate, UISearchResultsUpdating{
  
    
   
    @IBOutlet weak var tableView: UITableView!
    
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    var recentListener: ListenerRegistration!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        
        setTableViewHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadRecentChats()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }

    @IBAction func createNewChatButtonPressed(_ sender: Any) {
        let userVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
        self.navigationController?.pushViewController(userVc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != ""{
            return filteredChats.count
        }else{
        return recentChats.count
    }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell" ,for: indexPath)as! RecentChatsTableViewCell
        let recent : NSDictionary!
        cell.delegate = self
        
        if searchController.isActive && searchController.searchBar.text != ""{
            recent = filteredChats[indexPath.row]
        }else{
        recent = recentChats[indexPath.row]
        }
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        return cell
    }
    
    
    //Taableview delegate methods
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var tempRecent : NSDictionary!
        if searchController.isActive && searchController.searchBar.text != ""{
            tempRecent = filteredChats[indexPath.row]
        }else{
            tempRecent = recentChats[indexPath.row]
        }
        
        var muteTitle = "Unmute"
        var mute = false
        
        if(tempRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()){
             muteTitle = "Mute"
             mute = false
        }
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
                self.recentChats.remove(at: indexPath.row)
            
                deleteRecentChat(recentChatDictionary: tempRecent   )
            
        }
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { (action, indexPath) in
            print("mute\(indexPath)")
        }
        
        muteAction.backgroundColor = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
        deleteAction.backgroundColor = #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1)
        return [deleteAction,muteAction]
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        tableView.deselectRow(at: indexPath, animated: true)
        
        var recent	: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != ""{
            recent = filteredChats[indexPath.row]
        }else{
            recent = recentChats[indexPath.row]
        }
        //restart  chat
        restartRecentChat(recent: recent)
        
        //show chat now
        
        let chatVC = ChatViewController()
        chatVC.hidesBottomBarWhenPushed = true
        chatVC.titleName = (recent[kWITHUSERFULLNAME] as?   String)!    
        chatVC.memberIds = (recent[kMEMBERS] as? [String])!
        chatVC.membersToPush = (recent[kMEMBERSTOPUSH] as? [String])!
        chatVC.chatRoomId = (recent[kCHATROOMID] as? String)!
        chatVC.isGroup = false
        navigationController?.pushViewController(chatVC, animated: true)
        
        
    }
    
    
    
    func loadRecentChats(){
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else { return }
            self.recentChats = []
            if !snapshot.isEmpty {
                let sorted = ((dictionaryFromSnapshots(snapshots:snapshot.documents))as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted{
                
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil &&   recent[kRECENTID] != nil {
                            self.recentChats.append(recent)
                        
                    }
                }
                self.tableView.reloadData()
            }
        })
    }
    //MARK: CustomTableviewHeader
    func setTableViewHeader(){
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
        let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: tableView.frame.width, height: 35))
        let groupButton = UIButton(frame: CGRect(x: tableView.frame.width - 110 , y: 10, width: 100, height: 20))
        
        groupButton.addTarget(self, action: #selector(self.groupButtonPressed), for: .touchUpInside)
        groupButton.setTitle("New group", for: .normal)
        let buttonColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        groupButton.setTitleColor(buttonColor, for: .normal)
        
        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1, width: tableView.frame.width, height: 1))
        lineView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
        buttonView.addSubview(groupButton)
        headerView.addSubview(buttonView)
        headerView.addSubview(lineView)
        
        tableView.tableHeaderView = headerView
    }
    
    @objc func groupButtonPressed(){
        print("helelo")
    }
    
    func didTapAvatarImage(indexPath: IndexPath) {
        var recentChat : NSDictionary!
        if searchController.isActive && searchController.searchBar.text != ""{
            recentChat = filteredChats[indexPath.row]
        }else{
        recentChat = recentChats[indexPath.row]
        }
        if recentChat[kTYPE] as! String == kPRIVATE{
            reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument{(snapshot, error) in
            guard let snapshot = snapshot else{ return }
            if snapshot.exists{
                let userDictionary = snapshot.data() as! NSDictionary
                let tempUser = FUser(_dictionary: userDictionary)
                self.showUserProfile(user: tempUser)
            }
        }
        }
    }
    
    func showUserProfile(user: FUser){
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as!  ProfileTableViewController
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        
        filteredChats = recentChats.filter({ (recentChat) -> Bool in
            return (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
