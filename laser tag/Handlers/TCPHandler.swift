//
//  TCPHandler.swift
//  laser tag
//
//  Created by Aarush Bothra on 7/21/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import Foundation
import SwiftSocket



protocol TCPDelegateMain : NSObject {
    func changeConnectToGunButtonState(to state:Bool)
    func clearTextFields()
    func flashScreen()
    func changeView()
    func alertVersionMismatch(serverVersion: String, clientVersion: String)
    func alertUnableToConnectToServer()
}

protocol TCPDelegateAdmin {
    func restart()
    func goToPlayerSetup()
}

protocol TCPDelegatePlayerWaiting {
    func restart()
    func goToPlayerSetup()
}

protocol TCPDelegatePlayerSetup {
    func restart()
}

protocol TCPDelegateLobby {
    func restart()
    func refreshCV()
    func toGame()
}

protocol TCPDelegateInGame {
    func restart()
    func gameOver()
    
}

class TCPHandler: NSObject{
    
    var mainViewControllerTCP: TCPDelegateMain!
    var adminVCTCP: TCPDelegateAdmin!
    var playerWaitingVCTCP: TCPDelegatePlayerWaiting!
    var playerSetupVCTCP: TCPDelegatePlayerSetup!
    var lobbyVCTCP: TCPDelegateLobby!
    var inGameVCTCP: TCPDelegateInGame!
    
    var client:TCPClient!
    var serverAddr:String!
    var serverPort:Int32!
    var readServerMessage = false
    var isAdmin = false
    
    var activeVC:String!
    
    var gameStarted = false
    
    //version 1.3
    var version = [Int(1), Int(3)]
    
    func findPlayerByGunID(gunID: Int) -> Player{
        for player in Players{
            if gunID == player.gunID{
                return player
            }
        }
        
        print("player not found by gunID")
        return Players[0]
    }
    
    public func setActiveVC(VC:String){
        activeVC = VC
    }
        
    public func getIsAdmin() -> Bool{
        return isAdmin
    }
    
    func floatValue(data: Data) -> Float {
        return Float(bitPattern: UInt32(littleEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) }))
    }
    
    public func serverListener(){
            let bytes = [UInt8](repeating: 0, count: 1)
            while readServerMessage{
                var byteArray = [UInt8](repeating: 0, count: 20)
                byteArray[0] = 252
                
                switch client.send(data: byteArray) {
                case .success:
                    let message = client.read(79, timeout: 1)
                    
                    if message != nil{
                        print("Message Received!")
                        print(String(bytes: message ?? bytes, encoding: .utf8)!)
                        
                        serverMessageParser(serverMessage: serverMessageToIntArray(str: String(bytes: message ?? bytes, encoding: .utf8)!))
                        
                    }
                case .failure(_):
                    client.close()
                    readServerMessage = false
                    DispatchQueue.main.async {
                        print("server forcibly disconnected")
                        switch self.activeVC{
                        case "admin":
                            self.adminVCTCP.restart()
                        case "playerWaiting":
                            self.playerWaitingVCTCP.restart()
                        case "playerSetup":
                            self.playerSetupVCTCP.restart()
                        case "lobby":
                            self.lobbyVCTCP.restart()
                        case "inGame":
                            self.inGameVCTCP.restart()
                        default:
                            print("oops")
                        }
                    }
                    
                }
                
                
                
                
            }
        }
    
    public func serverMessageToIntArray(str:String) -> [Int]{
        let stringArray = str.components(separatedBy: ",")
        var intArray:[Int] = []
        
        for string in stringArray{
            let intToAdd = Int(string) ?? -3
            if intToAdd >= 0 {
                intArray.append(intToAdd)
            }
        }
        
        return intArray
    }
        
        public func serverMessageParser(serverMessage:[Int]){
            switch serverMessage[0]{
            case 0: //set admin and gunID. Sends to admin config page
                isAdmin = true
                bluetooth.setGunID(ID: serverMessage[1])
                DispatchQueue.main.async {
                    self.mainViewControllerTCP.changeView()

                }
                
            case 1: //set gunID. Sends to player waiting page
                bluetooth.setGunID(ID: serverMessage[1])
                
                DispatchQueue.main.async {
                    self.mainViewControllerTCP.changeView()

                }
            case 2://creates game
                Game = GameSettings(teamSetting: Int(serverMessage[1]), ammo: Int(serverMessage[2]), lives: Int(serverMessage[3]), timeLimit: Int(serverMessage[4]), scoreLimit: Int(serverMessage[5]), location: Int(serverMessage[6]), gameType: serverMessage[7])
                DispatchQueue.main.async {
                    switch self.activeVC{
                    case "admin":
                        self.adminVCTCP.goToPlayerSetup()
                    case "playerWaiting":
                        self.playerWaitingVCTCP.goToPlayerSetup()
                    case "playerSetup":
                        break;
                    case "lobby":
                        break;
                    default:
                        print("oops")
                    }
                }
            case 3://create a player from data received from server
                var usernameArray = [UInt8]()
                for x in 1...10{
                    if serverMessage[x] >= 32 {
                         usernameArray.append(UInt8(serverMessage[x]))
                    }
                   
                }
                
                print("Username length: \(usernameArray.count)")
                let username = String(bytes: usernameArray, encoding: .utf8)
                var isSelf = false
                if bluetooth.gunID == UInt8(serverMessage[13]){
                    isSelf = true
                }
                
                Players.append(Player(username: username!, team: serverMessage[11], gunType: serverMessage[12], gunID: serverMessage[13], isSelf: isSelf, kills: serverMessage[14], deaths: serverMessage[15], score: serverMessage[16]))
                
                let playerAdded = Players[Players.count - 1]
                switch serverMessage[12] {
                case 0:
                    playerAdded.ammoInGun = 12
                case 1:
                    playerAdded.ammoInGun = 40
                case 2:
                    playerAdded.ammoInGun = 30
                case 3:
                    playerAdded.ammoInGun = 10
                default:
                    break
                }
                
                if activeVC == "lobby"{
                    DispatchQueue.main.async {
                        self.lobbyVCTCP.refreshCV()
                    }
                }
                
                if activeVC == "inGame" {
                    DispatchQueue.main.async {
                        handleGame.createInGameTableViews()
                    }
                    
                }
            case 4://remove player disconnected from server
                for x in 0..<Players.count{
                    if Players[x].gunID == serverMessage[1]{
                        print("Player removed: \(Players[x].username) \(Players[x].gunID)")
                        Players.remove(at: x)
                        break
                    }
                }
                if activeVC == "lobby"{
                    DispatchQueue.main.async {
                        self.lobbyVCTCP.refreshCV()
                    }
                }
            case 5://start game
                for player in Players {
                    if player.isSelf {
                        player.totalAmmo = Game.ammo
                    }
                }
                gameStarted = true
                DispatchQueue.main.async{
                    self.lobbyVCTCP.toGame()
                }
                
            case 6://received from server if a player is hit during the game (any player)
                DispatchQueue.main.async{
                    handleGame.handlePlayerHit(playerShooting: self.findPlayerByGunID(gunID: serverMessage[1]),playerHit: self.findPlayerByGunID(gunID: serverMessage[2]))
                }
                
                
            case 7://recieved from server if player dies in game
                DispatchQueue.main.async{
                    handleGame.handlePlayerDeath(playerShooting: self.findPlayerByGunID(gunID: serverMessage[1]),playerHit: self.findPlayerByGunID(gunID: serverMessage[2]))
                }
                
            case 8:
                
                handleGame.timer.invalidate()
                
                DispatchQueue.main.async {
                    if self.activeVC == "inGame" {
                        self.inGameVCTCP.gameOver()
                    }
                    bluetooth.disconnectGun()
                }
                
            case 9:
                if gameStarted {
                    handleGame.gameTimeElapsed = Double((serverMessage[1] * 255) + serverMessage[2])
                }
                
            case 10:
                handleGame.oddballReceived(gunID: serverMessage[1])
                
            case 11:
                handleGame.oddballLost()
                
            case 12:
                handleGame.scoreIncrease(gunID: serverMessage[1])
                
            case 253://version check
                print("version from server: \(serverMessage[1]).\(serverMessage[2])")
                
                var byteArray = [UInt8](repeating: 0, count: 20)
                byteArray[0] = 253
                if serverMessage[1] == version[0] && serverMessage[2] == version[1] {
                    byteArray[1] = 1
                } else {
                    byteArray[1] = 0
                    DispatchQueue.main.async {
                        self.mainViewControllerTCP.alertVersionMismatch(serverVersion: "\(serverMessage[1]).\(serverMessage[2])", clientVersion: "\(self.version[0]).\(self.version[1])")
                    }
                    
                }
                
                client.send(data: byteArray)
                
            case 254: //server restarting, sends player to first page
                readServerMessage = false
                client.close()
                DispatchQueue.main.async {
                    switch self.activeVC{
                    case "admin":
                        self.adminVCTCP.restart()
                    case "playerWaiting":
                        self.playerWaitingVCTCP.restart()
                    case "playerSetup":
                        self.playerSetupVCTCP.restart()
                    case "lobby":
                        self.lobbyVCTCP.restart()
                    case "inGame":
                        self.inGameVCTCP.restart()
                    default:
                        print("oops")
                    }
                }
                
                
                print("server restarting")
            case 255: //server disconnected, sends player to first page
                readServerMessage = false
                client.close()
                DispatchQueue.main.async {
                    switch self.activeVC{
                    case "admin":
                        self.adminVCTCP.restart()
                    case "playerWaiting":
                        self.playerWaitingVCTCP.restart()
                    case "playerSetup":
                        self.playerSetupVCTCP.restart()
                    case "lobby":
                        self.lobbyVCTCP.restart()
                    case "inGame":
                        self.inGameVCTCP.restart()
                    default:
                        print("oops")
                    }
                }
                
                print("server disconnected")
            default:
                print("uh oh")
            }
        }
    
    
    
}

extension TCPHandler{
    
    public func connectToServer(addr:String?, port:Int32){
        serverAddr = addr
        serverPort = port
        client = TCPClient(address: addr!, port: port)
        switch client.connect(timeout: 2) {
          case .success:
            print("Connected to server!!")

            DispatchQueue.global(qos: .background).async {
                self.readServerMessage = true
                self.serverListener()
            }
            
            
             
            
          case .failure:
            print("Failed to connect to server")
            client.close()
            DispatchQueue.main.async {
                self.mainViewControllerTCP.alertUnableToConnectToServer()
            }
        }
    }
    
    public func restartServer(){
        var byteArray = [UInt8](repeating: 0, count: 20)
        byteArray[0] = 254
        client.send(data: byteArray)
        print("server restarted")
    }
    
    public func disconnectFromServer(){
        var byteArray = [UInt8](repeating: 0, count: 20)
        byteArray[0] = 255
        readServerMessage = false
        client.send(data: byteArray)
        client.close()
        DispatchQueue.main.async {
            switch self.activeVC{
            case "admin":
                self.adminVCTCP.restart()
            case "playerWaiting":
                self.playerWaitingVCTCP.restart()
            case "playerSetup":
                self.playerSetupVCTCP.restart()
            case "lobby":
                self.lobbyVCTCP.restart()
            case "inGame":
                self.inGameVCTCP.restart()
            default:
                print("oops")
            }
        }
        print("disconnected")
    }
    
    public func sendGameConfig(teamSetting:Int, ammo:Int, lives:Int, timeLimit:Int, scoreLimit:Int, location: Int, gameType: Int){
        var byteArray = [UInt8](repeating: 0, count: 20)
        byteArray[1] = UInt8(teamSetting)
        byteArray[2] = UInt8(ammo)
        byteArray[3] = UInt8(lives)
        byteArray[4] = UInt8(timeLimit)
        byteArray[5] = UInt8(scoreLimit)
        byteArray[6] = UInt8(location)
        byteArray[7] = UInt8(gameType)
        print("game setup: \(byteArray)")
        client.send(data: byteArray)
    }
    
    func sendPlayerConfig(username: String, team: Int, gunType: Int) {
        var byteArray = [UInt8](repeating: 0, count: 20)
        byteArray[0] = 1
        let usernameAscii = username.asciiValues
        for x in 0..<usernameAscii.count{
            byteArray[x+1] = usernameAscii[x]
        }
        byteArray[11] = UInt8(team)
        byteArray[12] = UInt8(gunType)
        
        client.send(data: byteArray)
        bluetooth.setGunType(gunType: gunType)
    }
    
    func startGame(){
        var byteArray = [UInt8](repeating: 0, count: 20)
        byteArray[0] = 2
        client.send(data: byteArray)
    }
    
    func sendPlayerHit(shooterGunID: Int, selfGunID: Int) {
        var byteArray = [UInt8](repeating: 0, count: 20)
        byteArray[0] = 3
        byteArray[1] = UInt8(shooterGunID)
        byteArray[2] = UInt8(selfGunID)
        client.send(data: byteArray)
    }
    
    func sendPlayerKilled(shooterGunID: Int, selfGunID: Int) {
        var byteArray = [UInt8](repeating: 0, count: 20)
        byteArray[0] = 4
        byteArray[1] = UInt8(shooterGunID)
        byteArray[2] = UInt8(selfGunID)
        client.send(data: byteArray)
    }
    
    func endGame() {
        if isAdmin {
            var byteArray = [UInt8](repeating: 0, count: 20)
            byteArray[0] = 5
            client.send(data: byteArray)
        }
        
    }
    
    func syncTime(coefficient: Int, remainder: Int) {
        var byteArray = [UInt8](repeating: 0, count: 20)
        byteArray[0] = 6
        byteArray[1] = UInt8(coefficient)
        byteArray[2] = UInt8(remainder)
        client.send(data: byteArray)
    }
    
    func oddballReceived() {
        var byteArray = [UInt8](repeating: 0, count: 20)
        byteArray[0] = 7
        byteArray[1] = UInt8(handleGame.playerSelf.gunID)
        client.send(data: byteArray)
    }
    
    func scoreIncrease() {
        var byteArray = [UInt8](repeating: 0, count: 20)
        byteArray[0] = 9
        byteArray[1] = UInt8(handleGame.playerSelf.gunID)
        client.send(data: byteArray)
    }
    
    func oddballLost() {
        var byteArray = [UInt8](repeating: 0, count: 20)
        byteArray[0] = 8
        byteArray[1] = UInt8(handleGame.playerSelf.gunID)
        client.send(data: byteArray)
    }
}

extension StringProtocol {
    var asciiValues: [UInt8] { compactMap(\.asciiValue) }
}
