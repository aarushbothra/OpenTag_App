//
//  PlayerWaitingViewController.swift
//  laser tag
//
//  Created by Aarush Bothra on 7/22/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import Foundation
import UIKit

class PlayerWaitingViewController: UIViewController, TCPDelegatePlayerWaiting, BTDelegatePlayerWaiting {
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        bluetooth.playerWaitingVC = self
        networking.playerWaitingVCTCP = self
        bluetooth.activeVC = "playerWaiting"
        networking.setActiveVC(VC: "playerWaiting")
        //networking.adminVCTCP = self
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func disconnectFromServer(_ sender: Any) {
        networking.disconnectFromServer()
    }
    
    @IBAction func restartServerButton(_ sender: Any) {
        networking.restartServer()
    }
    
    func restart(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let mainViewController = mainStoryboard.instantiateViewController(identifier: "MainVC") as! ViewController
        
        self.navigationController?.pushViewController(mainViewController, animated: true)
        print("switching to mainVC")
    }
    
    func goToPlayerSetup(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let playerSetUpVC = mainStoryboard.instantiateViewController(identifier: "PlayerSetUpVC") as! PlayerSetUpVC
        
        self.navigationController?.pushViewController(playerSetUpVC, animated: true)
        print("switching to playerSetUpVC")
    }
    
    func flashScreen() {
        let snapshotView = UIView()
            snapshotView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(snapshotView)
            // Activate full screen constraints
            let constraints:[NSLayoutConstraint] = [
                snapshotView.topAnchor.constraint(equalTo: view.topAnchor),
                snapshotView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                snapshotView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                snapshotView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
            // White because it's the brightest color
            snapshotView.backgroundColor = UIColor.white
            // Animate the alpha to 0 to simulate flash
            UIView.animate(withDuration: 0.3, animations: {
                snapshotView.alpha = 0
            }) { _ in
                // Once animation completed, remove it from view.
                snapshotView.removeFromSuperview()
            }
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
