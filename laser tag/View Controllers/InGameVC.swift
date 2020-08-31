//
//  InGameVC.swift
//  laser tag
//
//  Created by Aarush Bothra on 7/28/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import UIKit

var handleGame = GameHandler()

class InGameVC: UIViewController, BTDelegateInGame, TCPDelegateInGame, GameHandlerDelegate {

    @IBOutlet var inGameCV: UICollectionView!
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var deathsLabel: UILabel!
    @IBOutlet var ammoInGunLabel: UILabel!
    @IBOutlet var totalAmmoLabel: UILabel!
    @IBOutlet var alertLabel: UILabel!
    
    @IBOutlet var healthBar: UIProgressView!
    @IBOutlet var shieldBar: UIProgressView!
    
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var minusButton: UIButton!
    
    @IBOutlet var healthBarView: UIView!
    @IBOutlet var ammoView: UIView!
    
    var isLowHealth = false
    
    var teamsSorted: [Team]!
    var playersInYourTeam: [Player]!
    var playersSorted: [Player]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        handleGame = GameHandler()
        
        bluetooth.activeVC = "inGame"
        networking.activeVC = "inGame"
        
        inGameCV.delegate = self
        inGameCV.dataSource = self
        
        handleGame.gameViewController = self
        bluetooth.inGameVC = self
        networking.inGameVCTCP = self
        
        handleGame.createInGameTableViews()
        
        healthBar.transform = healthBar.transform.scaledBy(x: 1, y: 10)
        shieldBar.transform = shieldBar.transform.scaledBy(x: 1, y: 10)
        
        setBackgroundNormal()
        
        if let flowLayout = inGameCV.collectionViewLayout as? UICollectionViewFlowLayout,
            let CV = inGameCV {
            let w = CV.frameLayoutGuide.layoutFrame.width - 12
            let h = CV.frame.height - 20
            flowLayout.estimatedItemSize = CGSize(width: w, height: h)
            
        }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let startingCountdownVC = mainStoryboard.instantiateViewController(identifier: "StartingCountdownVC") as! StartingCountdownVC
        
        present(startingCountdownVC, animated: true)
        print("presenting starting countdown")
        // Do any additional setup after loading the view.
        if Game.timeLimit == 0 {
            timerLabel.text = "Unlimited"
        }
    }
    
    func setTimerLabel(string: String) {
        timerLabel.text = string
    }
    
    
    func setHealthBar() {
        print("setting health bar")
        var playerHealth = Float(handleGame.playerSelf.health)
        if playerHealth <= 0 {
            playerHealth = 0
        }
        let healthFloat = Float(playerHealth / 100)
        
        healthBar.progressTintColor = UIColor.green
        if healthFloat <= 0.30 {
            healthBar.progressTintColor = UIColor.red
        }
        
        healthBar.setProgress(healthFloat, animated: true)
        
        
    }
    
    func setShieldBar() {
        var playerShield = Float(handleGame.playerSelf.shield)
        if playerShield <= 0 {
            playerShield = 0
        }
        let shieldFloat = Float(playerShield / 100)
        
        shieldBar.setProgress(shieldFloat, animated: true)
    }
    
    func setAmmoInGunLabel(string: String){
        ammoInGunLabel.text = string
    }
    
    func setTotalAmmoLabel(string: String){
        totalAmmoLabel.text = string
    }
    
    func setAlertLabel(string: String){
        alertLabel.alpha = 1
        alertLabel.text = string
        fadeViewOut(view: alertLabel, delay: 1)
    }
    
    func updateScoreLabel(){
        switch Game.gameType {
        case 0://TDM and FFA
            scoreLabel.text = "S: \(handleGame.playerSelf.kills)"
        case 1://Oddball
            scoreLabel.text = "S: \(handleGame.playerSelf.score)"
        default:
            break
            
        }
        
    }
    
    func updateDeathsLabel(){
        deathsLabel.text = "D: \(handleGame.playerSelf.deaths)"
    }
    
    func updateTableView(teamsSorted: [Team], playersInYourTeam: [Player]){
        self.teamsSorted = teamsSorted
        self.playersInYourTeam = playersInYourTeam
        inGameCV.reloadData()
    }
    
    func updateTableView(playersSorted: [Player]){
        self.playersSorted = playersSorted
        inGameCV.reloadData()
    }
    
    @IBAction func plusButton(_ sender: Any) {
//        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//
//        let showPlusOptionsVC = mainStoryboard.instantiateViewController(identifier: "ShowPlusOptionsVC") as! ShowPlusOptions
//
//        present(showPlusOptionsVC, animated: true)
//        print("presenting plus options")
        NFCRead.readNFCTag()
    }
    
    @IBAction func minusButton(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let showMinusOptionsVC = mainStoryboard.instantiateViewController(identifier: "ShowMinusOptionsVC") as! ShowMinusOptions
        
        present(showMinusOptionsVC, animated: true)
        print("presenting minus options")
    }
    
    func switchToDeathScreen(string: String){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let deathScreenVC = mainStoryboard.instantiateViewController(identifier: "DeathScreenVC") as! DeathScreenVC
        
        deathScreenVC.deathString = string
        
        present(deathScreenVC, animated: true)
        print("presenting death screen")
    }
    
    func gameOver() {
        bluetooth.disconnectGun()
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let gameOverVC = mainStoryboard.instantiateViewController(identifier: "GameOverVC") as! GameOverVC
         
        self.navigationController?.pushViewController(gameOverVC, animated: true)
        print("switching to gameOverVC")
       
    }
    
    
    func restart() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let mainViewController = mainStoryboard.instantiateViewController(identifier: "MainVC") as! ViewController
        bluetooth.disconnectGun()
        self.navigationController?.pushViewController(mainViewController, animated: true)
        print("switching to mainVC")
        
    }
    
    
    

}

//animations and effects
extension InGameVC {
    func flashRed() {
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
        snapshotView.backgroundColor = UIColor.red
        snapshotView.alpha = 0.35
        // Animate the alpha to 0 to simulate flash
        UIView.animate(withDuration: 0.5, animations: {
            snapshotView.alpha = 0
        }) { _ in
            // Once animation completed, remove it from view.
            snapshotView.removeFromSuperview()
        }
    }
    
    func fadeViewOut(view : UIView, delay: TimeInterval) {

        let animationDuration = 0.25

        
                // After the animation completes, fade out the view after a delay

                UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseOut, animations: { () -> Void in
                    view.alpha = 0
                    },
                    completion: nil)
        
    }
    
    func reload(){
        let reloadView = UIView()
        reloadView.translatesAutoresizingMaskIntoConstraints = false
        ammoView.addSubview(reloadView)
        
        let constraints:[NSLayoutConstraint] = [
            reloadView.topAnchor.constraint(equalTo: ammoView.safeAreaLayoutGuide.topAnchor),
            reloadView.leadingAnchor.constraint(equalTo: ammoView.safeAreaLayoutGuide.leadingAnchor),
            reloadView.trailingAnchor.constraint(equalTo: ammoView.safeAreaLayoutGuide.trailingAnchor),
            reloadView.bottomAnchor.constraint(equalTo: ammoView.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        reloadView.backgroundColor = UIColor.systemGray2
        
        if (handleGame.playerSelf.totalAmmo > 0 || handleGame.playerSelf.ammoInGun > 0) || Game.ammo == 0 {
            let reloadProgress = UIProgressView()
            reloadProgress.translatesAutoresizingMaskIntoConstraints = false
            reloadView.addSubview(reloadProgress)
            
            let reloadProgressContraints:[NSLayoutConstraint] = [
                reloadProgress.trailingAnchor.constraint(equalTo: reloadView.trailingAnchor, constant: -10),
                reloadProgress.centerYAnchor.constraint(equalTo: reloadView.centerYAnchor),
                reloadProgress.centerXAnchor.constraint(equalTo: reloadView.centerXAnchor),
                reloadProgress.leadingAnchor.constraint(equalTo: reloadView.leadingAnchor, constant: 10)
             
            ]
            NSLayoutConstraint.activate(reloadProgressContraints)
            reloadProgress.transform = reloadProgress.transform.scaledBy(x: 1, y: 10)
            reloadProgress.progressTintColor = UIColor.systemBlue
            reloadProgress.setProgress(0, animated: false)
            
            //reload time (seconds) = totalUnitCount / 100
            let progress = Progress(totalUnitCount: 200)
            
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true){ (timer) in
                
                guard progress.isFinished == false else {
                    timer.invalidate()
                    reloadView.removeFromSuperview()
                    handleGame.handleReload()
                    return
                }
                
                progress.completedUnitCount += 1
                
                let progressFloat = Float(progress.fractionCompleted)
                reloadProgress.setProgress(progressFloat, animated: true)
                
            }
        } else {
            let noAmmoLabel = UILabel()
            noAmmoLabel.translatesAutoresizingMaskIntoConstraints = false
            reloadView.addSubview(noAmmoLabel)
            
            let noAmmoLabelConstraints:[NSLayoutConstraint] = [
                noAmmoLabel.topAnchor.constraint(equalTo: reloadView.safeAreaLayoutGuide.topAnchor),
                noAmmoLabel.leadingAnchor.constraint(equalTo: reloadView.safeAreaLayoutGuide.leadingAnchor),
                noAmmoLabel.trailingAnchor.constraint(equalTo: reloadView.safeAreaLayoutGuide.trailingAnchor),
                noAmmoLabel.bottomAnchor.constraint(equalTo: reloadView.safeAreaLayoutGuide.bottomAnchor)
            ]
            NSLayoutConstraint.activate(noAmmoLabelConstraints)
            
            noAmmoLabel.text = "Out of Ammo"
            noAmmoLabel.textAlignment = .center
            noAmmoLabel.textColor = UIColor.systemBlue
            noAmmoLabel.font.withSize(40)
            fadeViewOut(view: reloadView, delay: 1)
        }
        
        
        
    }
    
    func setBackgroundWhite() {
        view.backgroundColor = .white
    }
    
    func setBackgroundNormal(){
        if Game.teamSetting > 0 {
            for player in Players {
                if player.gunID == bluetooth.gunID {
                    switch player.team {
                    case 1:
                        view.backgroundColor = UIColor.red
                    case 2:
                        view.backgroundColor = UIColor.blue
                    case 3:
                        view.backgroundColor = UIColor.green
                    case 4:
                        view.backgroundColor = UIColor.purple
                    case 5:
                        view.backgroundColor = UIColor.orange
                    case 6:
                        view.backgroundColor = UIColor.cyan
                    case 7:
                        view.backgroundColor = UIColor.yellow
                    case 8:
                        view.backgroundColor = UIColor.magenta
                    default:
                        view.backgroundColor = UIColor.systemBlue
                    }
                }
            }
            
        } else {
            view.backgroundColor = UIColor.systemBlue
        }
    }
}



extension InGameVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if Game.teamSetting > 0 {
            return 2
        } else if Game.teamSetting == 0 {
            return 1
        }
        
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = inGameCV.dequeueReusableCell(withReuseIdentifier: "RankingCell", for: indexPath) as! CollectionViewCellRankings
        cell.backgroundColor = UIColor.systemGray2
        print("IndexPath.row: \(indexPath.row)")
        
            cell.tableViewInGame.backgroundColor = UIColor.systemGray2
            if Game.teamSetting > 0 {
                
                cell.cellNumber = indexPath.row + 1
                cell.playersInYourTeam = playersInYourTeam
                cell.teamsSorted = teamsSorted
            } else {
                cell.cellNumber = 0
                cell.playersSorted = playersSorted
            }
            
        
        cell.tableViewInGame.delegate = cell
        cell.tableViewInGame.dataSource = cell
       // cell.tableViewInGame.separatorStyle = UITableViewCell.SeparatorStyle.none
        cell.tableViewInGame.reloadData()
        return cell
    }
    
    

}

