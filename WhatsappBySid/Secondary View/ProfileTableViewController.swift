//
//  ProfileTableViewController.swift
//  WhatsappBySid
//
//  Created by mac on 26/04/20.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    @IBOutlet weak var fullnameLabelView: UILabel!
    @IBOutlet weak var phoneLabelView: UILabel!
    @IBOutlet weak var messageButtonOutlet: UIButton!
    @IBOutlet weak var callButtonOutlet: UIButton!
    @IBOutlet weak var blockButtonOutlet: UIButton!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var user : FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Table view data source

    
    
    @IBAction func callButtonPressed(_ sender: Any) {
    }
    
    @IBAction func chatButtonPressed(_ sender: Any) {
    }
    
    @IBAction func blockButtonPressed(_ sender: Any) {
        
        var currentBlockedIds = FUser.currentUser()!.blockedUsers
        
        if currentBlockedIds.contains(user!.objectId){
            let index = currentBlockedIds.index(of: user!.objectId)!
            currentBlockedIds.remove(at: index)
        }else{
            currentBlockedIds.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedIds]) { (error) in
            if error != nil{
                print("error in updsating user \(error!.localizedDescription)")
                return
            }
            self.updateBlockStatus()
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }
        return 30
        
    }
    
    func setupUI(){
        if user != nil{
            self.title = "Profile"
            fullnameLabelView.text = user!.fullname
            phoneLabelView.text = user!.phoneNumber
            updateBlockStatus()
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                if avatarImageView != nil{
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    func updateBlockStatus() {
        if user!.objectId != FUser.currentId(){
            blockButtonOutlet.isHidden = false
            messageButtonOutlet.isHidden = false
            callButtonOutlet.isHidden = false
        }else{
           blockButtonOutlet.isHidden = true
           messageButtonOutlet.isHidden = true
           callButtonOutlet.isHidden = true
        }
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId ) {
            blockButtonOutlet.setTitle("unblock user", for: .normal)
        }else{
            blockButtonOutlet.setTitle("block user", for: .normal)
        }
    }
}
