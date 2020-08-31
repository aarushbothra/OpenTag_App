//
//  BluetoothHandler.swift
//  laser tag
//
//  Created by Aarush Bothra on 7/21/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

protocol BTDelegateMain : NSObject {
    func changeConnectToGunButtonState(to state:Bool)
    func clearTextFields()
    func flashScreen()
    func alertGunConnectConfirmation()
    func showConnectToServer()
}

protocol BTDelegateAdmin {
    func flashScreen()
    func restart()
}

protocol BTDelegatePlayerWaiting {
    func flashScreen()
    func restart()
}

protocol BTDelegatePlayerSetup {
    func flashScreen()
    func restart()
}

protocol BTDelegateLobby {
    func flashScreen()
    func restart()
}

protocol BTDelegateInGame {
    func restart()
    func setAmmoInGunLabel(string: String)
    func setTotalAmmoLabel(string: String)
    func reload()
}


class BluetoothHandler: NSObject {
    
    var mainViewController: BTDelegateMain!
    var adminVC: BTDelegateAdmin!
    var playerWaitingVC: BTDelegatePlayerWaiting!
    var playerSetupVC: BTDelegatePlayerSetup!
    var lobbyVC: BTDelegateLobby!
    var inGameVC: BTDelegateInGame!
    
    var laserTagGun: CBPeripheral!
    var centralManager: CBCentralManager!
    
    let gunServiceUUID = CBUUID(string: "0x9D10")
    let gunServiceRecoilGunUUID = CBUUID(string: "E6F59D10-8230-4a5c-B22F-C062B1D329E3")

    //characteristics of service Recoil Gun
    let gunCharacteristicIDUUID = CBUUID(string: "E6F59D11-8230-4a5c-B22F-C062B1D329E3")
    let gunCharacteristicTelemUUID = CBUUID(string: "E6F59D12-8230-4a5c-B22F-C062B1D329E3")
    let gunCharacteristicControlUUID = CBUUID(string: "E6F59D13-8230-4a5c-B22F-C062B1D329E3")
    let gunCharacteristicConfigUUID = CBUUID(string: "E6F59D14-8230-4a5c-B22F-C062B1D329E3")

    var gunCharacteristicControl:CBCharacteristic!
    var gunCharacteristicTelem:CBCharacteristic!
    var gunCharacteristicID:CBCharacteristic!
    var gunCharacteristicConfig:CBCharacteristic!
    var gunID:UInt8!
    var commandID:UInt8 = 0

    let commandIDIncrement:UInt8 = 17
    let weaponID:UInt8 = 0

    var countReloadButtonPressed:Int!

    var maxAmmo:UInt8 = 30

    var gunConnected = false
    
    var activeVC = ""
    
    var gameStarted = false
    
    var execute = true
    
    var possibleGuns = [Gun]()
    
    public func initializeCentraManager(){
        print("initializing")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    public func setCommandID() -> UInt8{
        if commandID >= 239 {
            commandID = 0
        }
        commandID += commandIDIncrement
        print("commandID: \(commandID)")
        return commandID
        
        
    }
    
    public func uint8ToData(bytes:[UInt8]) -> Data {
        return Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: bytes), count: bytes.count, deallocator: .none)
        
    }
    
    
}

//delegate for manager
extension BluetoothHandler: CBCentralManagerDelegate {
    
    
    
    //function called after manager is initialized, state of bluetooth on manager
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            mainViewController.changeConnectToGunButtonState(to: true)
            print("connect to gun enabled")
            
        @unknown default:
            print("central.state is .unknown")
        }
        
    }
    
     
    
    public func connectToGun() {
        
        self.centralManager.scanForPeripherals(withServices: [self.gunServiceUUID])
        
        let progress = Progress(totalUnitCount: 10)
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){ (timer) in
            
            guard progress.isFinished == false else {
                timer.invalidate()
                print("attempting connection")
                if self.possibleGuns.count > 0 {
                    var peripheralToConnect = self.possibleGuns[0]
                    for gun in self.possibleGuns {
                        print(Int(gun.RSSI))
                        print(gun.peripheral.identifier)
                        if Int(gun.RSSI) > Int(peripheralToConnect.RSSI) {
                            peripheralToConnect = gun
                        }
                    }
                    print("Peripheral To Connect: \(peripheralToConnect.peripheral.identifier)")
                    //self.possibleGuns.sorted(by: {Int($0.RSSI) < Int($1.RSSI)})
                    print("connecting")
                    self.laserTagGun = peripheralToConnect.peripheral
                    //points the peripheral to its delegate function
                    self.laserTagGun.delegate = self
                    self.centralManager.connect(self.laserTagGun)
                    
                }
                return
            }
            
            progress.completedUnitCount += 1
            
            
        }
    }
    
    
    //function called after manager has found gun
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //centralManager.stopScan()
        print("scanning")
        if possibleGuns.count == 0 {
            possibleGuns.append(Gun(peripheral: peripheral, RSSI: RSSI))
            //print(peripheral)
        } else {
            for gun in possibleGuns {
                if gun.peripheral.identifier != peripheral.identifier {
                    possibleGuns.append(Gun(peripheral: peripheral, RSSI: RSSI))
                    //print(peripheral)
                }
            }
        }
        
        //peripheral is gun
        
        
        
    }
    
    //function called after manager is connected to gun
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to gun!")
        DispatchQueue.main.async {
            self.mainViewController.alertGunConnectConfirmation()
        }
        laserTagGun.discoverServices([gunServiceRecoilGunUUID])
        //gunConnected = true
        print("connect to server enabled")
        mainViewController.showConnectToServer()
    }
    
    func syncGun() {
        print("")
        print("---------------------------------SYNCING----------------------------------")
        print("")
        var bytes = [UInt8](repeating: 0, count: 20)
        bytes[0] = setCommandID()
        bytes[2] = 128
        if gunID != nil {
            bytes[4] = gunID
        }
        print("\(laserTagGun.writeValue(uint8ToData(bytes: bytes), for: gunCharacteristicControl, type: CBCharacteristicWriteType.withResponse))")

    }
    
    func setGunID(ID:Int){
        gunID = UInt8(ID)
        var bytes = [UInt8](repeating: 0, count: 20)
        bytes[0] = setCommandID()
        bytes[2] = 2
        bytes[4] = gunID
        
        print("Gun ID bytes: \(bytes)")
        print("\(laserTagGun.writeValue(uint8ToData(bytes: bytes), for: gunCharacteristicControl, type: CBCharacteristicWriteType.withResponse))")
        print("GunID Set")
        
    }
    
    func setGunType(gunType: Int){
        var bytes = [UInt8](repeating: 0, count: 20)
        bytes[2] = 9
        
        bytes[7] = 255
        bytes[8] = 255
        bytes[9] = 128
        if Game.location == 0 {
           // print("location indoor selected")
            bytes[5] = 25
        } else {
           // print("location outdoor selected")
            bytes[5] = 255
            bytes[6] = 200 // adds cone shape to bullet spread
        }
        
        bytes[10] = 2
        bytes[11] = 52
        
        switch gunType{
        case 0://sniper
            bytes[3] = 0
            bytes[4] = 1
        case 1://burst
            bytes[3] = 3
            bytes[4] = 3
        case 2://full auto
            bytes[3] = 254
            bytes[4] = 1
        case 3://single shot
            bytes[3] = 254
            bytes[6] = 0 //removes cone shape from bullet spread for single shot
        default:
            bytes[3] = 254
            bytes[4] = 1
        }
        print("\(laserTagGun.writeValue(uint8ToData(bytes: bytes), for: gunCharacteristicConfig, type: CBCharacteristicWriteType.withResponse))")
        print("gun type set")
    }
    
    func setReload(gunID: Int){
        print("setting reload")
        var bytes = [UInt8](repeating: 0, count: 20)
        bytes[0] = setCommandID()
        bytes[2] = 2
        bytes[4] = UInt8(gunID)
        //bytes[6] = 0
        print(laserTagGun.writeValue(uint8ToData(bytes: bytes), for: gunCharacteristicControl, type: CBCharacteristicWriteType.withResponse))

    }
    
    func unsetReload(ammo: Int, gunID: Int){
        print("unsetting reload")
        var bytes = [UInt8](repeating: 0, count: 20)
        bytes[0] = setCommandID()
        bytes[2] = 4
        bytes[4] = UInt8(gunID)
        bytes[6] = UInt8(ammo)
        print(laserTagGun.writeValue(uint8ToData(bytes: bytes), for: gunCharacteristicControl, type: CBCharacteristicWriteType.withResponse))
    }
    
    func disconnectGun() {
        centralManager.cancelPeripheralConnection(laserTagGun)
    }
}

extension BluetoothHandler: CBPeripheralDelegate{
    
    //function called for laserTagGun.discoverServices
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        
        peripheral.discoverCharacteristics(nil, for: services[0])
        
    }
    
    //function called for .discoverCharacteristics
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                           error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            switch characteristic.uuid {
            case gunCharacteristicIDUUID:
                gunCharacteristicID = characteristic
            case gunCharacteristicTelemUUID:
                gunCharacteristicTelem = characteristic
                laserTagGun.setNotifyValue(true, for: characteristic)
            case gunCharacteristicControlUUID:
                gunCharacteristicControl = characteristic
            case gunCharacteristicConfigUUID:
                gunCharacteristicConfig = characteristic
            default:
                print("unhandled characteristic")
                
            }
            
        }
    }
    
    //called to read value of characteristic
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                           error: Error?) {
        
        switch characteristic.uuid {
        case gunCharacteristicControlUUID:
            print(characteristic.uuid)
            print(characteristic.value ?? "no value")
        case gunCharacteristicIDUUID:
            print(characteristic.uuid)
            print(characteristic.value ?? "no value")
        case gunCharacteristicConfigUUID:
            print(characteristic.uuid)
            print(characteristic.value ?? "no value")
        case gunCharacteristicTelemUUID:
            //print(characteristic.uuid)
            //print(characteristic.value ?? "no value")
            //print(voltage(from: characteristic))
            gunTelemListener(from: characteristic)
        default:
            print()
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
            print()
        }
        
    }
    
    private func gunTelemListener(from characteristic: CBCharacteristic){
        let characteristicData = characteristic.value!
        let byteArray = [UInt8](characteristicData)
        
        //playerHit
        if networking.gameStarted && byteArray[9] > 0 {
            print("")
            NSLog("\(byteArray)")
            print("")
            
            if byteArray[9]/4 == gunID {
                print("-----------------GUN IDS MATCH--------------------")
            }
            handleGame.onPlayerHit(gunID: Int(byteArray[9] / 4))
        }
        
        if execute {
            switch byteArray[2] {
            case 1:
               // NSLog("\(byteArray)")
                if !networking.gameStarted {
                    flashAllScreens()
                    execute = false
                } else {
                    print("Gun Setting: \(byteArray[15])")
                    var playerSelf: Player!
                    for player in Players {
                        if player.isSelf {
                            playerSelf = player
                        }
                    }
                    playerSelf.ammoInGun = Int(byteArray[14])
                    //print("Player Gun Ammo: \(handleGame.playerSelf.ammoInGun ?? -1)")
                    inGameVC.setAmmoInGunLabel(string: String(playerSelf.ammoInGun))
                }
                print("firing")
            case 2:
                if networking.gameStarted && !handleGame.isDead {
                    //unsetReload()
                    setReload(gunID: handleGame.playerSelf.gunID)
                    inGameVC.reload()
                    //handleGame.resetHealth()
                    execute = false
                }
            case 4:
                if networking.gameStarted && !handleGame.isDead {
                    NFCRead.readNFCTag()
                    execute = false
                }
            default:
                break
            }
        } else if byteArray[2] == 0 {
            execute = true
        }
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral,
                           didUpdateNotificationStateFor characteristic: CBCharacteristic,
                           error: Error?){
        print("Notifcations set!!")
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("value written!")
    }
    
    func flashAllScreens(){
        switch activeVC{
        case "main":
            mainViewController.flashScreen()
        case "admin":
            adminVC.flashScreen()
        case "playerWaiting":
            playerWaitingVC.flashScreen()
        case "playerSetup":
            playerSetupVC.flashScreen()
        case "lobby":
            lobbyVC.flashScreen()
        default:
            print("oops")
        }
        
        
        
    }
    
}

struct Gun {
    let peripheral: CBPeripheral
    let RSSI: NSNumber
}

