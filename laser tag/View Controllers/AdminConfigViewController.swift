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
    
    @IBOutlet var teamsPickerView: UIPickerView!
    @IBOutlet var locationPickerView: UIPickerView!
    
    @IBOutlet var ammoLabel: UILabel!
    @IBOutlet var livesLabel: UILabel!
    @IBOutlet var timeLimitLabel: UILabel!
    @IBOutlet var killLimitLabel: UILabel!
    
    @IBOutlet var ammoSlider: UISlider!
    @IBOutlet var livesSlider: UISlider!
    @IBOutlet var timeLimitSlider: UISlider!
    @IBOutlet var killLimitSlider: UISlider!
    
    let teamsOptions = ["FFA", "2 Teams", "3 Teams", "4 Teams","5 Teams","6 Teams","7 Teams","8 Teams"]
    let locationOptions = ["Indoor", "Outdoor"]
    
    var teamSelected: Int = 0
    var locationSelected = 0
    
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
        // Do any additional setup after loading the view.
    }
    
    @IBAction func restartServerButton(_ sender: Any) {
        networking.restartServer()
    }
    
    @IBAction func createGameButton(_ sender: Any) {
        if Int(killLimitSlider.value) == 0 && Int(timeLimitSlider.value) == 0{
            let alert = UIAlertController(title: "Error", message: "Kill Limit and Time Limit cannot be unlimited in the same game", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else{
            networking.sendGameConfig(teamSetting: teamSelected, ammo: Int(ammoSlider.value), lives: Int(livesSlider.value), timeLimit: Int(timeLimitSlider.value), killLimit: Int(killLimitSlider.value), location: locationSelected)
        }
        
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
    
    @IBAction func killLimitSlider(_ sender: Any) {
        if Int(killLimitSlider.value) == 0{
            killLimitLabel.text = "Kill Limit: Unlimited"
        } else {
            killLimitLabel.text = "Kill Limit: " + String(Int(killLimitSlider.value))
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
        if pickerView.tag == 0 {
            return teamsOptions.count
        } else {
           // print("locationoptions.count")
            return locationOptions.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return teamsOptions[row]
        } else {
          //  print("locationoptions[row]")
            return locationOptions[row]
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            teamSelected = row
        } else {
            locationSelected = row
        }
        
    }
}
