//
//  ShowPlusOptions.swift
//  laser tag
//
//  Created by Aarush Bothra on 8/6/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import UIKit

class ShowPlusOptions: UIViewController {

    @IBOutlet var refillButton: UIButton!
    @IBOutlet var claimOddballButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Game.gameType != 1 {
            claimOddballButton.isHidden = true
        }
        
        if handleGame.playerWithOddball.gunID == handleGame.playerSelf.gunID {
            refillButton.isEnabled = false
        }
        
        if handleGame.playerWithOddball.gunID != -1 {
            claimOddballButton.isEnabled = false
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func refillButton(_ sender: Any) {
//        NFCRead.readRefillAmmoAndHealth()
//        dismiss(animated: true)
    }
    
    @IBAction func claimOddballButton(_ sender: Any) {
//        NFCRead.readOddballTag()
//        dismiss(animated: true)
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
