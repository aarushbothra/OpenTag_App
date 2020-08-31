//
//  GameHandler.swift
//  laser tag
//
//  Created by Aarush Bothra on 7/31/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import Foundation

protocol GameHandlerDelegate {
    func setTimerLabel(string: String)
    func flashRed()
    func setHealthBar()
    func setAmmoInGunLabel(string: String)
    func setTotalAmmoLabel(string: String)
    func setAlertLabel(string: String)
    func updateScoreLabel()
    func updateDeathsLabel()
    func updateTableView(teamsSorted: [Team], playersInYourTeam: [Player])
    func updateTableView(playersSorted: [Player])
    func switchToDeathScreen(string: String)
    func setShieldBar()
    func setBackgroundWhite()
    func setBackgroundNormal()
}

struct Team {
    var team: Int!
    var score: Int!
}


class GameHandler {
    
    var gameViewController: GameHandlerDelegate!
    
    var gameTimeElapsed = Double(0)
    var timer = Timer()
    
    var playerSelf: Player!
    
    var isDead = false
    var sendTimeSync = true
    
    var sniperDamage = 35
    var burstDamage = 8
    var fullAutoDamage = 8
    var singleShotDamage = 28
    
    var sniperAmmo = 12
    var burstAmmo = 40
    var fullAutoAmmo = 30
    var singleShotAmmo = 10
    
    let dummyPlayer = Player(username: "dummy", team: -1, gunType: -1, gunID: -1, isSelf: false, kills: -1, deaths: -1, score: -1)
    
    //time oddball is first recieved
    var timeAtOddballRecieved: Int!
    var oddballReceived = false
    var playerWithOddball: Player!
    var scoreIncremented = false
    
    var isRespawning = false
    var timeRespawnedAt: Double!
    var respawnInvincibilityDelay = 1.5
    
    init() {
        for player in Players {
            if player.isSelf {
                playerSelf = player
            }
        }
        playerWithOddball = dummyPlayer
    }
    
    
    func gameTimeStart(){
        //print("starting timer")
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleGameTime), userInfo: nil, repeats: true)
        let runLoop = RunLoop.current
        runLoop.add(timer, forMode: .default)
        runLoop.run()
    }
    
    @objc func handleGameTime() {
        
        gameTimeElapsed += 0.1
        
        if Game.timeLimit > 0 {
            let flooredCounter = Int(Double((Game.timeLimit * 60)) - gameTimeElapsed)
            let hour = flooredCounter/3600
            
            let minute = (flooredCounter % 3600) / 60
            var minuteString = "\(minute)"
            if minute < 10 {
                minuteString = "0\(minute)"
            }
            
            let second = (flooredCounter % 3600) % 60
            var secondString = "\(second)"
            if second < 10 {
                secondString = "0\(second)"
            }
            
            let decisecond = String(format: "%.1f", Double((Game.timeLimit * 60)) - gameTimeElapsed).components(separatedBy: ".").last!
            
            
            if Int(gameTimeElapsed) % 10 == 0 && networking.isAdmin {
                if sendTimeSync {
                    sendTimeSync = false
                    let coefficient = Int(gameTimeElapsed / 255)
                    let remainder = Int(gameTimeElapsed) % 255
                    print("SYNCING TIME: coefficient: \(coefficient), remainder: \(remainder), gameTimeElapsed: \(gameTimeElapsed) ")
                    networking.syncTime(coefficient: coefficient, remainder: Int(remainder))
                }
                
            } else {
                sendTimeSync = true
            }
            
            var timeString: String
            if  flooredCounter >= 0 {
                //only display hour if there are more than 60 minutes and only display minutes if there are more than 60 seconds
                if flooredCounter > 3600{
                    
                    timeString = "\(hour):\(minuteString):\(secondString)"
                } else if flooredCounter > 60 {
                    
                    timeString = "\(minuteString):\(secondString)"
                } else {
                    
                    timeString = "\(secondString).\(decisecond)"
                }
                
                DispatchQueue.main.async {
                    self.gameViewController.setTimerLabel(string: timeString)
                }
            } else if flooredCounter < 0 {
                timer.invalidate()
                DispatchQueue.main.async {
                    networking.endGame()
                }
                
            }
        }
        
        if oddballReceived {
            if (Int(gameTimeElapsed) - timeAtOddballRecieved) % 5 == 0 {
                if !scoreIncremented {
                    networking.scoreIncrease()
                    scoreIncremented = true
                }
                
            } else {
                scoreIncremented = false
            }
        }
        
        if isRespawning {
            
            if (gameTimeElapsed - timeRespawnedAt) >= respawnInvincibilityDelay {
                
                isDead = false
                isRespawning = false
                
                
            }
        }
        
    }
    
    // handles respawning as well as refilling ammo and health
    func respawn() {
        playerSelf.health = 100
        //playerSelf.shield = 0
        playerSelf.totalAmmo = Game.ammo
        gameViewController.setHealthBar()
        handleReload()
        
        if isDead {
            timeRespawnedAt = gameTimeElapsed
            isRespawning = true
        }
    }
    
    func onPlayerHit(gunID: Int){
        if !isDead {
            var playerShooting: Player!
            for player in Players {
                if gunID == player.gunID {
                    print("found player shooting")
                    playerShooting = player
                    break
                } else {
                    playerShooting = dummyPlayer
                }
            }
            print(playerSelf.health)
            if playerShooting.gunID != -1 {
                if Game.teamSetting == 0 {
                    if playerSelf.shield > 0 {
                        switch playerShooting.gunType {
                        case 0://sniper
                            playerSelf.shield -= sniperDamage
                        case 1://burst
                            playerSelf.shield -= burstDamage
                        case 2://full auto
                            playerSelf.shield -= fullAutoDamage
                        case 3://single shot
                            playerSelf.shield -= singleShotDamage
                        default:
                            break;
                        }
                        gameViewController.setShieldBar()
                        gameViewController.flashRed()
                    } else {
                        switch playerShooting.gunType {
                        case 0://sniper
                            playerSelf.health -= sniperDamage
                        case 1://burst
                            playerSelf.health -= burstDamage
                        case 2://full auto
                            playerSelf.health -= fullAutoDamage
                        case 3://single shot
                            playerSelf.health -= singleShotDamage
                        default:
                            break;
                        }
                        
                        
                        
                        if playerSelf.health <= 0 {
                            networking.sendPlayerKilled(shooterGunID: playerShooting.gunID, selfGunID: playerSelf.gunID)
                            // bluetooth.syncGun()
                            bluetooth.setReload(gunID: playerSelf.gunID)
                            isDead = true
                            gameViewController.setHealthBar()
                            //  gameViewController.switchToDeathScreen(string: "Killed by \(playerShooting.username)")
                            //bluetooth.syncGun()
                            
                        } else {
                            networking.sendPlayerHit(shooterGunID: playerShooting.gunID, selfGunID: playerSelf.gunID)
                            gameViewController.flashRed()
                            gameViewController.setHealthBar()
                        }
                    }
                    
                    
                } else {
                    if playerSelf.shield > 0 {
                        switch playerShooting.gunType {
                        case 0://sniper
                            playerSelf.shield -= sniperDamage
                        case 1://burst
                            playerSelf.shield -= burstDamage
                        case 2://full auto
                            playerSelf.shield -= fullAutoDamage
                        case 3://single shot
                            playerSelf.shield -= singleShotDamage
                        default:
                            break;
                        }
                        gameViewController.setShieldBar()
                        gameViewController.flashRed()
                    } else {
                        if playerShooting.team != playerSelf.team {
                            switch playerShooting.gunType {
                            case 0://sniper
                                playerSelf.health -= sniperDamage
                            case 1://burst
                                playerSelf.health -= burstDamage
                            case 2://full auto
                                playerSelf.health -= fullAutoDamage
                            case 3://single shot
                                playerSelf.health -= singleShotDamage
                            default:
                                break;
                            }
                            
                            
                            
                            if playerSelf.health <= 0 {
                                networking.sendPlayerKilled(shooterGunID: playerShooting.gunID, selfGunID: playerSelf.gunID)
                                // bluetooth.syncGun()
                                bluetooth.setReload(gunID: playerSelf.gunID)
                                gameViewController.setHealthBar()
                                // gameViewController.switchToDeathScreen(string: "Killed by \(playerShooting.username)")
                                
                                isDead = true
                                //bluetooth.syncGun()
                                
                            } else {
                                networking.sendPlayerHit(shooterGunID: playerShooting.gunID, selfGunID: playerSelf.gunID)
                                gameViewController.flashRed()
                                gameViewController.setHealthBar()
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func handleReload(){
        
        if Game.ammo > 0 {
            switch playerSelf.gunType {
            case 0: //sniper
                let maxAmmoToAdd = sniperAmmo - playerSelf.ammoInGun
                if playerSelf.totalAmmo <= maxAmmoToAdd {
                    playerSelf.ammoInGun = playerSelf.ammoInGun + playerSelf.totalAmmo
                    playerSelf.totalAmmo = 0
                } else {
                    playerSelf.totalAmmo -= (sniperAmmo - playerSelf.ammoInGun)
                    playerSelf.ammoInGun = sniperAmmo
                }
                
            case 1://burst
                let maxAmmoToAdd = burstAmmo - playerSelf.ammoInGun
                if playerSelf.totalAmmo <= maxAmmoToAdd {
                    playerSelf.ammoInGun = playerSelf.ammoInGun + playerSelf.totalAmmo
                    playerSelf.totalAmmo = 0
                } else {
                    playerSelf.totalAmmo -= (burstAmmo - playerSelf.ammoInGun)
                    playerSelf.ammoInGun = burstAmmo
                }
            case 2://full auto
                let maxAmmoToAdd = fullAutoAmmo - playerSelf.ammoInGun
                if playerSelf.totalAmmo <= maxAmmoToAdd {
                    playerSelf.ammoInGun = playerSelf.ammoInGun + playerSelf.totalAmmo
                    playerSelf.totalAmmo = 0
                } else {
                    playerSelf.totalAmmo -= (fullAutoAmmo - playerSelf.ammoInGun)
                    playerSelf.ammoInGun = fullAutoAmmo
                }
            case 3://single shot
                let maxAmmoToAdd = singleShotAmmo - playerSelf.ammoInGun
                if playerSelf.totalAmmo <= maxAmmoToAdd {
                    playerSelf.ammoInGun = playerSelf.ammoInGun + playerSelf.totalAmmo
                    playerSelf.totalAmmo = 0
                } else {
                    playerSelf.totalAmmo -= (singleShotAmmo - playerSelf.ammoInGun)
                    playerSelf.ammoInGun = singleShotAmmo
                }
                
            default:
                break
            }
            
            gameViewController.setAmmoInGunLabel(string: String(playerSelf.ammoInGun))
            gameViewController.setTotalAmmoLabel(string: String(playerSelf.totalAmmo))
        } else {
            switch playerSelf.gunType {
            case 0: //sniper
                playerSelf.ammoInGun = sniperAmmo
            case 1://burst
                playerSelf.ammoInGun = burstAmmo
            case 2://full auto
                playerSelf.ammoInGun = fullAutoAmmo
            case 3://single shot
                playerSelf.ammoInGun = singleShotAmmo
            default:
                break
            }
            
            gameViewController.setAmmoInGunLabel(string: String(playerSelf.ammoInGun))
            gameViewController.setTotalAmmoLabel(string: "Unlimited")
        }
        bluetooth.unsetReload(ammo: playerSelf.ammoInGun, gunID: playerSelf.gunID)
    }
    
    
    
    func handlePlayerHit(playerShooting: Player, playerHit: Player){
        if playerSelf.gunID == playerShooting.gunID {
            gameViewController.setAlertLabel(string: "You hit \(playerHit.username)!")
        }
        
        if playerSelf.gunID == playerHit.gunID {
            gameViewController.setAlertLabel(string: "Hit by \(playerShooting.username)")
        }
    }
    
    func handlePlayerDeath(playerShooting: Player, playerHit: Player){
        for player in Players {
            if player.gunID == playerShooting.gunID {
                player.kills += 1
                print("player kills: \(player.kills)")
            }
            
            if player.gunID == playerHit.gunID {
                player.deaths += 1
                print("player deaths: \(player.deaths)")
            }
        }
        
        if playerShooting.gunID == playerSelf.gunID {
            gameViewController.setAlertLabel(string: "You killed \(playerHit.username)")
            playerSelf.totalAmmo += 45
        }
        
        var gameEnding = false
        
        if Game.gameType == 0 {
            createInGameTableViews()
            
            if Game.scoreLimit > 0 {
                if Game.teamSetting > 0 {
                    let teams = createTeams()
                    for team in teams {
                        if findTeamScore(team: team.team) >= Game.scoreLimit {
                            networking.endGame()
                            gameEnding = true
                        }
                    }
                } else {//FFA
                    for player in Players {
                        if player.kills >= Game.scoreLimit {
                            networking.endGame()
                            gameEnding = true
                        }
                    }
                    
                }
            }
        }
        
        if !gameEnding && playerHit.gunID == playerSelf.gunID {
            if playerSelf.gunID == playerWithOddball.gunID {
                networking.oddballLost()
            }
            gameViewController.switchToDeathScreen(string: "Killed by \(playerShooting.username)")
        }
    }
    
    func oddballReceived(gunID: Int) {
        for player in Players {
            if player.gunID == gunID {
                playerWithOddball = player
            }
        }
        
        if playerWithOddball.gunID == playerSelf.gunID {
            playerSelf.shield = 100
            oddballReceived = true
            timeAtOddballRecieved = Int(gameTimeElapsed)
            DispatchQueue.main.async {
                self.gameViewController.setBackgroundWhite()
            }
        }
        
        DispatchQueue.main.async {
            self.createInGameTableViews()
            self.gameViewController.setShieldBar()
            
        }
        
    }
    
    func scoreIncrease(gunID: Int) {
        for player in Players {
            if player.gunID == gunID {
                player.score += 1
                if player.score == 255 || player.score == Game.scoreLimit{
                    timer.invalidate()
                    networking.endGame()
                }
            }
        }
        
        DispatchQueue.main.async {
            self.createInGameTableViews()
        }
        
    }
    
    func oddballLost() {
        playerWithOddball = dummyPlayer
        oddballReceived = false
        DispatchQueue.main.async {
            self.createInGameTableViews()
            self.gameViewController.setBackgroundNormal()
        }
    }
}


extension GameHandler {
    func createInGameTableViews() {
        if Game.teamSetting > 0 {
            let teams = createTeams()
            
            gameViewController.updateTableView(teamsSorted: teams.sorted(by: {$0.score > $1.score}), playersInYourTeam: self.findPlayersInYourTeam())
            gameViewController.updateScoreLabel()
            gameViewController.updateDeathsLabel()
            
        } else {//FFA
            switch Game.gameType {
            case 0://regular FFA
                gameViewController.updateTableView(playersSorted: Players.sorted(by: {$0.kills > $1.kills}))
                gameViewController.updateScoreLabel()
                gameViewController.updateDeathsLabel()
            case 1://oddball
                gameViewController.updateTableView(playersSorted: Players.sorted(by: {$0.score > $1.score}))
                gameViewController.updateScoreLabel()
                gameViewController.updateDeathsLabel()
            default:
                break
            }
            
            
        }
    }
    
    func findPlayersInYourTeam() -> [Player]{
        var team = [Player]()
        for player in Players {
            if playerSelf.team == player.team {
                team.append(player)
            }
        }
        return team
    }
    
    func findTeamScore(team: Int) -> Int{
        var teamScore = 0
        for player in Players {
            if Game.gameType == 0 {
                if player.team == team {
                    teamScore += player.kills
                }
            } else {
                if player.team == team {
                    teamScore += player.score
                }
            }
            
        }
        return teamScore
    }
    
    func createTeams() -> [Team]{
        var teams = [Team]()
        for x in 0..<Game.teamSetting + 1 {
            teams.append(Team(team: x+1, score: findTeamScore(team: x+1)))
        }
        return teams
    }
}

