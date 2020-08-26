//
//  ViewController.swift
//  laser tag
//
//  Created by Aarush Bothra on 7/3/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import UIKit
import CoreBluetooth
import SwiftSocket



var networking: TCPHandler!
var bluetooth: BluetoothHandler!
var Game: GameSettings!
var Players = [Player]()
var NFCRead: NFCReadHandler!
var NFCWrite: NFCWriteHandler!
//var serverAddressTyped = false
//var serverPortTyped = false
class ViewController: UIViewController, BTDelegateMain, TCPDelegateMain {
    
    @IBOutlet var connectToGunButton: UIButton!
    @IBOutlet var connectToServerButton: UIButton!
    @IBOutlet var writeServerInfoToTagButton: UIButton!
    @IBOutlet var readServerAddressTagButton: UIButton!
    @IBOutlet var getServerSoftwareButton: UIButton!
    
    @IBOutlet var serverAddressTextField: UITextField!
    @IBOutlet var serverPortTextField: UITextField!
        
    @IBOutlet var serverConnectStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true

        //initializing manager
        print("disabling buttons")
        self.navigationController?.isNavigationBarHidden = true
        
        networking = TCPHandler()
        bluetooth = BluetoothHandler()
        Players = [Player]()
        NFCRead = NFCReadHandler()
        NFCWrite = NFCWriteHandler()
                
        serverConnectStackView.isHidden = true
        
        serverPortTextField.delegate = self
        serverAddressTextField.delegate = self
        
        bluetooth.mainViewController = self
        networking.mainViewControllerTCP = self
        bluetooth.activeVC = "main"
        networking.setActiveVC(VC: "main")
        bluetooth.initializeCentraManager()
        
        
    }
    
    @IBAction func connectToGunButton(_ sender: Any) {
        bluetooth.connectToGun()
    }
    
    @IBAction func connectToServerButton(_ sender: Any) {
        let addr = serverAddressTextField.text
        let portText = serverPortTextField.text!
        let portInt = Int(portText) ?? -1
        networking.connectToServer(addr: addr, port: Int32(portInt))
    }
    
    
    func clearTextFields(){
        serverPortTextField.text = ""
        serverAddressTextField.text = ""
    }
    
    func changeConnectToGunButtonState(to state: Bool) {
        connectToGunButton.isEnabled = state
    }
    
    @IBAction func createRespawnTagButton(_ sender: Any) {
        NFCWrite.createRespawnPoint()
    }
    
    @IBAction func writeServerInfoToTagButton(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let writeServerToCardVC = mainStoryboard.instantiateViewController(identifier: "WriteServerToCard") as! WriteServerToCard
        
        present(writeServerToCardVC, animated: true)
        print("presenting writeServerAddressToCard vc options")
    }
    
    @IBAction func readServerAddressTagButton(_ sender: Any) {
        NFCRead.readServerAddressTag()
    }
    
    @IBAction func getServerSoftwareButton(_ sender: Any) {
        if let url = URL(string: "https://github.com/APersonnn/OpenTag_Server") {
            UIApplication.shared.open(url)
        }
    }
    
    func showConnectToServer(){
        serverConnectStackView.isHidden = false
        connectToGunButton.isHidden = true
    }
    
    func alertVersionMismatch(serverVersion: String, clientVersion: String){
        let alert = UIAlertController(title: "Version Mismatch", message: "Client Version: \(clientVersion), Server Version: \(serverVersion)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func alertUnableToConnectToServer(){
        let alert = UIAlertController(title: "Unable to Connect", message:"Unable to connect to server", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func alertGunConnectConfirmation() {
        let alert = UIAlertController(title: "Gun Connected!", message:"Pull the trigger after dismissing this alert to confirm that the gun has connected", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func changeView(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let adminConfigViewController = mainStoryboard.instantiateViewController(identifier: "AdminConfigVC") as! AdminConfigViewController
        
        let playerWaitingViewController = mainStoryboard.instantiateViewController(identifier: "PlayerWaitingVC") as! PlayerWaitingViewController
        
//        navigationController?.addChild(adminConfigViewController)
//        navigationController?.addChild(playerWaitingViewController)
        print("Visible VC: \(String(describing: navigationController?.visibleViewController))")
        print(navigationController?.viewControllers)
        if networking.isAdmin {
            self.navigationController?.pushViewController(adminConfigViewController, animated: true)
            print("switching to admin")
        } else {
            print("switching to player")
            self.navigationController?.pushViewController(playerWaitingViewController, animated: true)
        }
        print("Visible VC: \(String(describing: navigationController?.visibleViewController))")

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

extension ViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
