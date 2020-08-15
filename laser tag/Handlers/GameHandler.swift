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
    func updateKillsLabel()
    func updateDeathsLabel()
    func updateTableView(teamsSorted: [Team], playersInYourTeam: [Player])
    func updateTableView(playersSorted: [Player])
    func switchToDeathScreen(string: String)
}

struct Team {
    var team: Int!
    var score: Int!
}


class GameHandler {
    
    var gameViewController: GameHandlerDelegate!
    
    var timerCounter: Float = -1
    var timer = Timer()
    
    var playerSelf: Player!
    
    var isDead = false
    
    init() {
        for player in Players {
            if player.isSelf {
                playerSelf = player
            }
        }
    }
    
    
    func timerStart(){
        //print("starting timer")
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleTimerLabel), userInfo: nil, repeats: true)
        let runLoop = RunLoop.current
        runLoop.add(timer, forMode: .default)
        runLoop.run()
    }
    
    @objc func handleTimerLabel(){
        let timerString = timerHandler()
        //print("handling timer")
        DispatchQueue.main.async {
            self.gameViewController.setTimerLabel(string: timerString)
        }
        
    }
    
    func timerHandler() -> String {
        
        timerCounter += 0.1
        // print(timerCounter)
        
        let flooredCounter = Int(floor(Float(Game.timeLimit*60) - timerCounter))
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
        
        let decisecond = String(format: "%.1f", timerCounter).components(separatedBy: ".").last!
        
        if  flooredCounter >= 0 {
            //only display hour if there are more than 60 minutes and only display minutes if there are more than 60 seconds
            if flooredCounter > 3600{
                
                return "\(hour):\(minuteString):\(secondString)"
            } else if flooredCounter > 60 {
                
                return "\(minuteString):\(secondString)"
            } else {
                
                return "\(secondString).\(decisecond)"
            }
        } else if flooredCounter < 0 {
            timer.invalidate()
            DispatchQueue.main.async {
                networking.endGame()
            }
            
        }
        
        return ""
    }
    
    // handles respawning as well as refilling ammo and health
    func respawn() {
        playerSelf.health = 100
        playerSelf.totalAmmo = Game.ammo
        gameViewController.setHealthBar()
        isDead = false
        handleReload()
    }
    
    func onPlayerHit(gunID: Int){
        if !isDead {
            var playerShooting: Player!
            for player in Players {
                if gunID == player.gunID {
                    print("found player shooting")
                    playerShooting = player
                }
            }
            print(playerSelf.health)
            if Game.teamSetting == 0 {
                switch playerShooting.gunType {
                case 0://sniper
                    playerSelf.health -= 35
                case 1://burst
                    playerSelf.health -= 4
                case 2://full auto
                    playerSelf.health -= 4
                case 3:
                    playerSelf.health -= 28
                default:
                    playerSelf.health -= 4
                }
                
                
                
                if playerSelf.health <= 0 {
                    networking.sendPlayerKilled(shooterGunID: playerShooting.gunID, selfGunID: playerSelf.gunID)
                    bluetooth.syncGun()
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
                
            } else {
                if playerShooting.team != playerSelf.team {
                    switch playerShooting.gunType {
                    case 0://sniper
                        playerSelf.health -= 35
                    case 1://burst
                        playerSelf.health -= 4
                    case 2://full auto
                        playerSelf.health -= 4
                    case 3://single shot
                        playerSelf.health -= 14
                    default:
                        playerSelf.health -= 4
                    }
                    
                    
                    
                    if playerSelf.health <= 0 {
                        networking.sendPlayerKilled(shooterGunID: playerShooting.gunID, selfGunID: playerSelf.gunID)
                        bluetooth.syncGun()
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
    
    func handleReload(){
        
        var ammo = 0
        
        
        if Game.ammo > 0 {
            switch playerSelf.gunType {
            case 0: //sniper
                playerSelf.totalAmmo -= (12 - playerSelf.ammoInGun)
                playerSelf.ammoInGun = 12
                ammo = 12
            case 1://burst
                playerSelf.totalAmmo -= (40 - playerSelf.ammoInGun)
                playerSelf.ammoInGun = 40
                ammo = 40
            case 2://full auto
                playerSelf.totalAmmo -= (30 - playerSelf.ammoInGun)
                playerSelf.ammoInGun = 30
                ammo = 30
            case 3://single shot
                playerSelf.totalAmmo -= (10 - playerSelf.ammoInGun)
                playerSelf.ammoInGun = 10
                ammo = 10
            default:
                break
            }
            
            gameViewController.setAmmoInGunLabel(string: String(ammo))
            gameViewController.setTotalAmmoLabel(string: String(playerSelf.totalAmmo))
        } else {
            switch playerSelf.gunType {
            case 0: //sniper
                playerSelf.ammoInGun = 12
                ammo = 12
            case 1://burst
                playerSelf.ammoInGun = 40
                ammo = 40
            case 2://full auto
                playerSelf.ammoInGun = 12
                ammo = 30
            case 3://single shot
                playerSelf.ammoInGun = 12
                ammo = 10
            default:
                break
            }
            
            gameViewController.setAmmoInGunLabel(string: String(ammo))
            gameViewController.setTotalAmmoLabel(string: "Unlimited")
        }
        bluetooth.unsetReload(ammo: ammo, gunID: playerSelf.gunID)
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
        
        
        if Game.teamSetting > 0 {
            let teams = createTeams()
            
            gameViewController.updateTableView(teamsSorted: teams.sorted(by: {$0.score > $1.score}), playersInYourTeam: self.findPlayersInYourTeam())
            gameViewController.updateKillsLabel()
            gameViewController.updateDeathsLabel()
            
        } else {
            gameViewController.updateTableView(playersSorted: Players.sorted(by: {$0.kills > $1.kills}))
            gameViewController.updateKillsLabel()
            gameViewController.updateDeathsLabel()
            
        }
        
        var gameEnding = false
        if Game.killLimit > 0 {
            if Game.teamSetting > 0 {
                let teams = createTeams()
                for team in teams {
                    if findTeamScore(team: team.team) >= Game.killLimit {
                        networking.endGame()
                        gameEnding = true
                    }
                }
            } else {
                for player in Players {
                    if player.kills >= Game.killLimit {
                        networking.endGame()
                        gameEnding = true
                    }
                }
            }
        }
        
        if !gameEnding && playerHit.gunID == playerSelf.gunID {
            gameViewController.switchToDeathScreen(string: "Killed by \(playerShooting.username)")
        }
        
        
    }
    
    func createInGameTableViews() {
        if Game.teamSetting > 0 {
            let teams = createTeams()
            
            gameViewController.updateTableView(teamsSorted: teams.sorted(by: {$0.score > $1.score}), playersInYourTeam: self.findPlayersInYourTeam())
            gameViewController.updateKillsLabel()
            gameViewController.updateDeathsLabel()
            
        } else {
            gameViewController.updateTableView(playersSorted: Players.sorted(by: {$0.kills > $1.kills}))
            gameViewController.updateKillsLabel()
            gameViewController.updateDeathsLabel()
            
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
            if player.team == team {
                teamScore += player.kills
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

