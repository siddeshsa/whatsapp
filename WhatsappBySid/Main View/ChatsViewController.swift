//
//  ChatsViewController.swift
//  WhatsappBySid
//
//  Created by mac on 25/04/20.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    var recentListener: ListenerRegistration!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecentChats()
        // Do any additional setup after loading the view.
    }

    @IBAction func createNewChatButtonPressed(_ sender: Any) {
        let userVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
        self.navigationController?.pushViewController(userVc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("we have \(recentChats.count)")
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell" ,for: indexPath)as! RecentChatsTableViewCell
        return cell
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
}
