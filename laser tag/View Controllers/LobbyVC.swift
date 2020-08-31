//
//  LobbyVC.swift
//  laser tag
//
//  Created by Aarush Bothra on 7/25/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import UIKit

class LobbyVC: UIViewController, BTDelegateLobby, TCPDelegateLobby {

    @IBOutlet var lobbyCV: UICollectionView!
    
    @IBOutlet var disconnectButton: UIButton!
    @IBOutlet var restartServerButton: UIButton!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var createRespawnTagButton: UIButton!
    
    let teamOptionsTotal = ["Team 1", "Team 2", "Team 3","Team 4","Team 5","Team 6","Team 7", "Team 8"]
    var collectionViewCellLabels = [String]()
    var collectionViewCells = [CollectionViewCellLobby]()
    var playersByTeam = [[Player]](repeating: [Player](), count: 8)
    var firstLoadComplete = false
    var currentTeam = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networking.setActiveVC(VC: "lobby")
        bluetooth.activeVC = "lobby"
        bluetooth.lobbyVC = self
        networking.lobbyVCTCP = self
        playersByTeam = [[Player]](repeating: [Player](), count: 8)
        
        if Game.teamSetting == 0 {
            collectionViewCellLabels.append("FFA")
        } else {
            for x in 0...Game.teamSetting {
                collectionViewCellLabels.append(teamOptionsTotal[x])
            }
        }
        
        playersByTeam = [[Player]](repeating: [Player](), count: 8)
        for player in Players{
            if Game.teamSetting > 0 {
                playersByTeam[player.team-1].append(player)
                print("appending \(player.username) to \(player.team-1) in viewdidload")

            }
        }
        
        if networking.isAdmin{
            disconnectButton.isHidden = true
        } else {
            startButton.isHidden = true
        }
//        self.lobbyCV.register(CollectionViewCellLobby.self, forCellWithReuseIdentifier: "Cell")
        lobbyCV.delegate = self
        lobbyCV.dataSource = self
    
        
        if let flowLayout = lobbyCV.collectionViewLayout as? UICollectionViewFlowLayout,
            let collectionView = lobbyCV {
            let w = collectionView.frameLayoutGuide.layoutFrame.width - 10
            let h = collectionView.frame.height
            flowLayout.estimatedItemSize = CGSize(width: w, height: h)
            
        }
        
        refreshCV()
        
    
    }
    
    @IBAction func disconnectButton(_ sender: Any) {
        networking.disconnectFromServer()
    }
    
    @IBAction func restartServerButton(_ sender: Any) {
        networking.restartServer()
    }
    
    @IBAction func startButton(_ sender: Any) {
        networking.startGame()
    }
    
    func toGame(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let inGameVC = mainStoryboard.instantiateViewController(identifier: "InGameVC") as! InGameVC
        self.navigationController?.pushViewController(inGameVC, animated: true)
        print("switching to inGameVC")
    }
    
    func restart() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let mainViewController = mainStoryboard.instantiateViewController(identifier: "MainVC") as! ViewController
        
        self.navigationController?.pushViewController(mainViewController, animated: true)
        print("switching to mainVC")
    }
    
    @IBAction func createRespawnTagButton(_ sender: Any) {
        NFCWrite.createRespawnPoint()
    }
    
    func refreshCV(){
        firstLoadComplete = true
        currentTeam = -1
        playersByTeam = [[Player]](repeating: [Player](), count: 8)
        collectionViewCells = [CollectionViewCellLobby]()
        for player in Players{
            if Game.teamSetting > 0 {
                playersByTeam[player.team-1].append(player)
               // NSLog("appending \(player.username) to \(player.team-1) in refresh")
            }
        }
       // print("reloading")
        lobbyCV.reloadData()
        
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

extension LobbyVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // print("setting amount of cells")
        return collectionViewCellLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        print("creating cell \(collectionViewCellLabels[indexPath.row])")
        let cell = lobbyCV.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCellLobby
//        print("creating cell \(collectionViewCellLabels[indexPath.row])")
        cell.teamLabel.text = collectionViewCellLabels[indexPath.row]
        if Game.teamSetting > 0{
            cell.players = playersByTeam[indexPath.row]
          //  print("team : \(indexPath.row+1) with count \(playersByTeam[indexPath.row].count)")
        } else {
            cell.players = Players
        }
        cell.rosterTV.delegate = cell
        cell.rosterTV.dataSource = cell
        cell.rosterTV.separatorStyle = UITableViewCell.SeparatorStyle.none
        if firstLoadComplete {
            cell.rosterTV.reloadData()
        }
        switch collectionViewCellLabels[indexPath.row] {
        case "Team 1":
            cell.backgroundColor = UIColor.red
            cell.rosterTV.backgroundColor = UIColor.red
            cell.identifier = "Team 1"
        case "Team 2":
            cell.backgroundColor = UIColor.blue
            cell.rosterTV.backgroundColor = UIColor.blue
            cell.identifier = "Team 2"
        case "Team 3":
            cell.backgroundColor = UIColor.green
            cell.rosterTV.backgroundColor = UIColor.green
            cell.identifier = "Team 3"
        case "Team 4":
            cell.backgroundColor = UIColor.purple
            cell.rosterTV.backgroundColor = UIColor.purple
            cell.identifier = "Team 4"
        case "Team 5":
            cell.backgroundColor = UIColor.orange
            cell.rosterTV.backgroundColor = UIColor.orange
            cell.identifier = "Team 5"
        case "Team 6":
            cell.backgroundColor = UIColor.cyan
            cell.rosterTV.backgroundColor = UIColor.cyan
            cell.identifier = "Team 6"
        case "Team 7":
            cell.backgroundColor = UIColor.yellow
            cell.rosterTV.backgroundColor = UIColor.yellow
            cell.identifier = "Team 7"
        case "Team 8":
            cell.backgroundColor = UIColor.magenta
            cell.rosterTV.backgroundColor = UIColor.magenta
            cell.identifier = "Team 8"
        default:
            cell.backgroundColor = UIColor.systemGray2
            cell.rosterTV.backgroundColor = UIColor.systemGray2
            cell.teamLabel.isHidden = true
            cell.identifier = "FFA"
        }

        return cell
    }
    
    
}

