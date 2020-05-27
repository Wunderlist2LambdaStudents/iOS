//
//  SettingsViewController.swift
//  WunderList
//
//  Created by Harmony Radley on 5/27/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signOutButton(_ sender: Any) {
        self.presentSignInView()
    }
  
    
    private func presentSignInView() {
        let loginStoryboard = UIStoryboard(name: "Auth", bundle: Bundle(identifier: "com.hazystudios.WunderList"))
        let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginView")
        loginViewController.modalPresentationStyle = .fullScreen
        present(loginViewController, animated: true)
    }

}
