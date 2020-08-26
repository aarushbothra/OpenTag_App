//
//  ShowMinusOptions.swift
//  laser tag
//
//  Created by Aarush Bothra on 8/6/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import UIKit

class ShowMinusOptions: UIViewController {

    @IBOutlet var disconnectButton: UIButton!
    @IBOutlet var restartButton: UIButton!
    @IBOutlet var endGameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if networking.isAdmin {
            disconnectButton.isHidden = true
        } else {
            endGameButton.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func disconnectButton(_ sender: Any) {
        networking.disconnectFromServer()
        dismiss(animated: true)
    }
    
    @IBAction func restartButton(_ sender: Any) {
        networking.restartServer()
        dismiss(animated: true)
    }
    
    @IBAction func endGameButton(_ sender: Any) {
        networking.endGame()
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
