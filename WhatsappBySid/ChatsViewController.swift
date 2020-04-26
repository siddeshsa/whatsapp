//
//  ChatsViewController.swift
//  WhatsappBySid
//
//  Created by mac on 25/04/20.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func createNewChatButtonPressed(_ sender: Any) {
        let userVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
        self.navigationController?.pushViewController(userVc, animated: true)
    }
}
