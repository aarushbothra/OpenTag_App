//
//  StartingCountdownVC.swift
//  laser tag
//
//  Created by Aarush Bothra on 7/30/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import UIKit

class StartingCountdownVC: UIViewController {
    
    @IBOutlet var startingCountdownLabel: UILabel!
    var timer: Timer!
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(decrementCountdownLabel), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
    }
    
    @objc func decrementCountdownLabel(){
        
        counter += 1
        startingCountdownLabel.text = String(5 - counter)
        
        if counter == 5 {
            self.timer.invalidate()
            dismiss(animated: true)
            DispatchQueue.global(qos: .userInteractive).async {
                handleGame.gameTimeStart()
            }
            handleGame.handleReload()
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
