//
//  WelcomeViewController.swift
//  WhatsappBySid
//
//  Created by mac on 19/04/20.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
import ProgressHUD
class WelcomeViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        dismissKeyboard()
        
        if emailTextField.text != "" && passwordTextField.text != ""{
           loginuser()
        }else{
            ProgressHUD.showError("email and password fields are compulsory to login!")
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        dismissKeyboard()
        if emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != ""{
            
            if repeatPasswordTextField.text == passwordTextField.text{
            registerUser()
            }else{
                ProgressHUD.showError("passwords dont match")
            }
        }else{
            ProgressHUD.showError("All fields are compulsory!")
        }
    }
    
    
    @IBAction func backgroundTap(_ sender: Any) {
        dismissKeyboard()
    }
    
    func registerUser(){
        print("register")
        dismissKeyboard()
        
        performSegue(withIdentifier: "welcomeToFinishreg", sender: self)
        cleanTextFields()

    }
    
    func loginuser(){
        
        ProgressHUD.show("Login...")
        
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!){
            (error) in
            
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            self.goToApp()
            //present the app
        }
        
    }
    
    //MARK: Helpers
    func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    func cleanTextFields(){
        emailTextField.text=""
        passwordTextField.text=""
        repeatPasswordTextField.text=""
    }
    
    func goToApp(){
       ProgressHUD.dismiss()
        cleanTextFields()
        dismissKeyboard()
        print("going to ap")
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "welcomeToFinishreg" {
            
            let vc = segue.destination as! FinishRegisterViewController
            vc.email = emailTextField.text!
            vc.password = passwordTextField.text!
        }
    }
    
}
