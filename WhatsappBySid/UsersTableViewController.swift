//
//  UsersTableViewController.swift
//  
//
//  Created by mac on 24/04/20.
//

import UIKit
import Firebase
import ProgressHUD

class UsersTableViewController: UITableViewController,UISearchResultsUpdating,UserTableViewCellDelegate{
  

    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var filterSegmentedControll: UISegmentedControl!
    
    var allUsers:[FUser] = []
    var filteredUsers: [FUser] = []
    var allUsersGroupped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList : [String] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//for title
        self.title = "Users"
        navigationItem.largeTitleDisplayMode = .never
        
//for no empty cells
        tableView.tableFooterView = UIView()
        
        
//implementing search option
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        loadUsers(filter: kCITY)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if searchController.isActive && searchController.searchBar.text != "" {
            print("numberOfSections",allUsersGroupped.count)
            return 1
            
        }else{
                print("numberOfSections",allUsersGroupped.count)
                return allUsersGroupped.count
                
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        }else{
              let sectionTitle = self.sectionTitleList[section]
              let users = self.allUsersGroupped[sectionTitle]
            
               return users!.count
        }
      
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        
        var user:FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
            
        }else{
            let sectionTitle = self.sectionTitleList[indexPath.section]
            let users = self.allUsersGroupped[sectionTitle]
            user = users![indexPath.row]
        }
        
        cell.generateCellWith(fUser: user, indexpath: indexPath)
        cell.delegate = self
        return cell
    }
    
    
    //Mark// implementing delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != "" {
          return ""
        }else{
            return sectionTitleList[section]
    }
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        }else{
            return self.sectionTitleList
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func loadUsers(filter: String){
        ProgressHUD.show()
        
        var query: Query!
        
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city)
        case kCOUNTRY:
             query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country)
        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
            
        }
        query.getDocuments{
            (snapshot,error) in
            self.allUsers = []
            self.sectionTitleList = []
            self.allUsersGroupped = [:]
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            guard let snapshot = snapshot else{
                ProgressHUD.dismiss(); return
            }
            if !snapshot.isEmpty{
                for userDictionary in snapshot.documents{
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    if fUser.objectId != FUser.currentId(){
                        self.allUsers.append(fUser)
                    }
                }
                self.splitDataIntoSection()
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
    }
    
    //MARK:search
    @IBAction func filterSegmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadUsers(filter: kCITY)
        case 1:
            loadUsers(filter: kCOUNTRY)
        case 2:
            loadUsers(filter: "")
        default:
            return
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All"){
    
        filteredUsers = allUsers.filter({ (user) -> Bool in
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    fileprivate func splitDataIntoSection() {

        var sectionTitle: String = ""
print("allUsers  count ",allUsers.count)
        for i in 0..<self.allUsers.count {

            let currentUser = self.allUsers[i]
            let firstChar = currentUser.firstname.first!
            let firstCarString = "\(firstChar)"

            if firstCarString !=  sectionTitle{
                sectionTitle = firstCarString
                self.allUsersGroupped[sectionTitle] = []
                self.sectionTitleList.append(sectionTitle)
            }
            self.allUsersGroupped[firstCarString]?.append(currentUser)
        }
        print(allUsersGroupped,"siddesh")
    }
    
    func didTapAvatarImage(indexPath: IndexPath) {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView")as! ProfileTableViewController
        
        var user:FUser
               
               if searchController.isActive && searchController.searchBar.text != "" {
                   user = filteredUsers[indexPath.row]
                   
               }else{
                   let sectionTitle = self.sectionTitleList[indexPath.section]
                   let users = self.allUsersGroupped[sectionTitle]
                   user = users![indexPath.row]
               }
               
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
