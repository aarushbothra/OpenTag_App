//
//  AdminConfigViewController.swift
//  laser tag
//
//  Created by Aarush Bothra on 7/21/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import UIKit

class AdminConfigViewController: UIViewController, BTDelegateAdmin, TCPDelegateAdmin {
    
    @IBOutlet var restartServerButton: UIButton!
    @IBOutlet var createGameButton: UIButton!
    @IBOutlet var createOddballTagButton: UIButton!
    
    @IBOutlet var teamsPickerView: UIPickerView!
    @IBOutlet var locationPickerView: UIPickerView!
    @IBOutlet var gameTypePickerView: UIPickerView!
    
    @IBOutlet var ammoLabel: UILabel!
    @IBOutlet var livesLabel: UILabel!
    @IBOutlet var timeLimitLabel: UILabel!
    @IBOutlet var scoreLimitLabel: UILabel!
    
    @IBOutlet var ammoSlider: UISlider!
    @IBOutlet var livesSlider: UISlider!
    @IBOutlet var timeLimitSlider: UISlider!
    @IBOutlet var scoreLimitSlider: UISlider!
    
    let teamsOptions = ["FFA", "2 Teams", "3 Teams", "4 Teams","5 Teams","6 Teams","7 Teams","8 Teams"]
    let locationOptions = ["Indoor", "Outdoor"]
    let gameTypeOptions = ["Normal", "Oddball"]
    
    var teamSelected: Int = 0
    var locationSelected = 0
    var gameTypeSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        bluetooth.adminVC = self
        networking.adminVCTCP = self
        bluetooth.activeVC = "admin"
        networking.setActiveVC(VC: "admin")
        teamsPickerView.dataSource = self
        teamsPickerView.delegate = self
        locationPickerView.dataSource = self
        locationPickerView.delegate = self
        gameTypePickerView.dataSource = self
        gameTypePickerView.delegate = self
        livesSlider.isEnabled = false 
        createOddballTagButton.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func restartServerButton(_ sender: Any) {
        networking.restartServer()
    }
    
    @IBAction func createGameButton(_ sender: Any) {
        if Int(scoreLimitSlider.value) == 0 && Int(timeLimitSlider.value) == 0{
            let alert = UIAlertController(title: "Error", message: "Score Limit and Time Limit cannot be unlimited in the same game", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else{
            networking.sendGameConfig(teamSetting: teamSelected, ammo: Int(ammoSlider.value), lives: Int(livesSlider.value), timeLimit: Int(timeLimitSlider.value), scoreLimit: Int(scoreLimitSlider.value), location: locationSelected, gameType: gameTypeSelected)
        }
        
    }
    
    @IBAction func createOddballTagButton(_ sender: Any) {
        NFCWrite.createOddballCard()
    }
    
    @IBAction func ammoSlider(_ sender: Any) {
        if Int(ammoSlider.value) == 0{
            ammoLabel.text = "Ammo: Unlimited"
        } else {
            ammoLabel.text = "Ammo: " + String(Int(ammoSlider.value))
        }
        
    }
    
    @IBAction func livesSlider(_ sender: Any) {
        if Int(livesSlider.value) == 0{
            livesLabel.text = "Lives: Unlimited"
        } else {
            livesLabel.text = "Lives: " + String(Int(livesSlider.value))
        }
    }
    
    @IBAction func timeLimitSlider(_ sender: Any) {
        if Int(timeLimitSlider.value) == 0{
            timeLimitLabel.text = "Time Limit: Unlimited"
        } else {
            timeLimitLabel.text = "Time Limit: " + String(Int(timeLimitSlider.value)) + " minutes"
        }
    }
    
    @IBAction func scoreLimitSlider(_ sender: Any) {
        if Int(scoreLimitSlider.value) == 0{
            scoreLimitLabel.text = "Score Limit: Unlimited"
        } else {
            scoreLimitLabel.text = "Score Limit: \(Int(scoreLimitSlider.value))"
        }
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

extension AdminConfigViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return teamsOptions.count
        case 1:
            return locationOptions.count
        case 2:
            return gameTypeOptions.count
        default:
            break
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0:
            return teamsOptions[row]
        case 1:
            return locationOptions[row]
        case 2:
            return gameTypeOptions[row]
        default:
            break
        }
        return "Error"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            teamSelected = row
        case 1:
            locationSelected = row
        case 2:
            gameTypeSelected = row
            switch row {
            case 0:
                createOddballTagButton.isHidden = true
                livesLabel.isHidden = false
                livesSlider.isHidden = false
                livesSlider.value = 0
                if Int(livesSlider.value) == 0{
                    livesLabel.text = "Lives: Unlimited"
                } else {
                    livesLabel.text = "Lives: " + String(Int(livesSlider.value))
                }
            case 1:
                livesLabel.isHidden = true
                livesSlider.isHidden = true
                livesSlider.value = 0
                createOddballTagButton.isHidden = false
                if Int(livesSlider.value) == 0{
                    livesLabel.text = "Lives: Unlimited"
                } else {
                    livesLabel.text = "Lives: " + String(Int(livesSlider.value))
                }
            default:
                break
            }
        default:
            break
        }
        
    }
}
