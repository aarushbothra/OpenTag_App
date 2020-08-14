//
//  PlayerSetUpVC.swift
//  laser tag
//
//  Created by Aarush Bothra on 7/23/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import Foundation
import UIKit

class PlayerSetUpVC: UIViewController, TCPDelegatePlayerSetup, BTDelegatePlayerSetup{
    
    
    
    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var gunTypePickerView: UIPickerView!
    @IBOutlet var teamPickerView: UIPickerView!
    
    
    @IBOutlet var disconnectButton: UIButton!
    @IBOutlet var restartButton: UIButton!
    @IBOutlet var readyButton: UIButton!
    
    let gunTypes = ["Sniper", "Burst", "Full Auto", "Single Shot"]
    let teamOptionsTotal = ["Team 1", "Team 2", "Team 3","Team 4","Team 5","Team 6","Team 7", "Team 8"]
    var teamOptionsAvailable =  [String]()
    
    var playerTeam: Int!
    var playerGunType: Int!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        bluetooth.playerSetupVC = self
        networking.playerSetupVCTCP = self
        networking.setActiveVC(VC: "playerSetup")
        bluetooth.activeVC = "playerSetup"
        
        usernameTextField.delegate = self
        gunTypePickerView.dataSource = self
        gunTypePickerView.delegate = self
        teamPickerView.dataSource = self
        teamPickerView.delegate = self
        
        usernameTextField.delegate = self
        
        if Game.teamSetting == 0 {
            teamOptionsAvailable.append("FFA")
        } else {
            for x in 0...Game.teamSetting {
                teamOptionsAvailable.append(teamOptionsTotal[x])
            }
        }
        
        if networking.getIsAdmin(){
            disconnectButton.isHidden = true
        }
    }
    
    @IBAction func disconnectButton(_ sender: Any) {
        networking.disconnectFromServer()
    }
    
    @IBAction func restartServerButton(_ sender: Any) {
        networking.restartServer()
    }
    
    @IBAction func readyButton(_ sender: Any) {
        if Game.teamSetting > 0{
            if playerTeam == nil{
                playerTeam = 1
            }
        } else {
            playerTeam = 0
        }
        networking.sendPlayerConfig(username: usernameTextField.text ?? "username",team: playerTeam, gunType: playerGunType ?? 0)
        goToLobby()
    }
    
    func restart() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let mainViewController = mainStoryboard.instantiateViewController(identifier: "MainVC") as! ViewController
        
        self.navigationController?.pushViewController(mainViewController, animated: true)
        print("switching to mainVC")
    }
    
    func goToLobby(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let lobbyVC = mainStoryboard.instantiateViewController(identifier: "LobbyVC") as! LobbyVC
        
        self.navigationController?.pushViewController(lobbyVC, animated: true)
        print("switching to lobbyVC")
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
    
}
    


extension PlayerSetUpVC: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 10
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}



extension PlayerSetUpVC: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return gunTypes.count
        } else {
            return teamOptionsAvailable.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return gunTypes[row]
        } else {
            return teamOptionsAvailable[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            playerGunType = row
        } else {
            if Game.teamSetting == 0{
                playerTeam = row
//                print("player team (ffa): \(playerTeam)")
            } else {
                    playerTeam = row + 1
//                    print("player team: \(playerTeam)")

                
                
            }
            
        }
    }
    
    
}

