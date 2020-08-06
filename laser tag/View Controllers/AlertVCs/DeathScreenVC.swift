//
//  DeathScreenVC.swift
//  laser tag
//
//  Created by Aarush Bothra on 8/4/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import UIKit

class DeathScreenVC: UIViewController, NFCDelegateDeathScreen {
    
    

    @IBOutlet var killedByLabel: UILabel!
    
    @IBOutlet var respawnButton: UIButton!
    
    var deathString = ""
    
//    var inGameViewController: InGameVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        killedByLabel.text = deathString
//        inGameViewController.deathScreen = self
        NFCRead.deathScreenNFC = self
        // Do any additional setup after loading the view.
    }
    

    @IBAction func respawnButton(_ sender: Any) {
        NFCRead.readRespawnPoint()
        
    }
    
    func respawn() {
        dismiss(animated: true)
        handleGame.respawn()
    }
    
    func dismiss() {
        dismiss(animated: true)
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
