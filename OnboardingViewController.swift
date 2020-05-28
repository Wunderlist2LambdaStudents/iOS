//
//  OnboardingViewController.swift
//  WunderList
//
//  Created by Marissa Gonzales on 5/27/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit
import SpriteKit

@IBDesignable class OnboardingViewController: UIViewController {
    @IBOutlet var wunderlistLabel: UILabel!

    private func configureWunderlistLabel() {
        wunderlistLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        wunderlistLabel.text = "Wunderlist"
        wunderlistLabel.font = UIFont(name: "sweet purple", size: 96)
        view.addSubview(wunderlistLabel)
    }

    @objc private func springButtonTapped() {
        wunderlistLabel.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        UIView.animate(withDuration: 3,
                       delay: 2,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: {
                        self.wunderlistLabel.transform = .identity
        },
                       completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWunderlistLabel()
        self.wunderlistLabel.fadeOut(completion: {  _ in
            self.wunderlistLabel.fadeIn()
        })
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
