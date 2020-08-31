//
//  NFCHandler.swift
//  laser tag
//
//  Created by Aarush Bothra on 8/5/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import Foundation
import CoreNFC

protocol NFCDelegateDeathScreen {
    func respawn()
}

class NFCReadHandler: NSObject, NFCNDEFReaderSessionDelegate {
    
    var readSession: NFCNDEFReaderSession!
    
    var deathScreenNFC:  NFCDelegateDeathScreen!
    
    //0 - Read to respawn
    //1 - read to refill
    //2 - read respawn point
    //3 - read oddball
    var readType = 0
    
    func readRespawnPoint() {
        readType = 0
        readSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        readSession?.alertMessage = "Hold your phone near the respawn NFC tag"
        readSession.begin()
    }
    
    func readServerAddressTag(){
        readType = 2
        readSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        readSession?.alertMessage = "Hold your phone near the server address NFC tag"
        readSession.begin()
    }
    
    func readNFCTag () {
        readType = -1
        readSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        readSession?.alertMessage = "Hold your phone near a NFC tag"
        readSession.begin()
    }
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {}
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var nfcMessage = ""
        for payload in messages[0].records {
            nfcMessage += String.init(data: payload.payload.advanced(by: 0), encoding: .utf8) ?? "invalid"
        }
        
        
        print("print nfc message: \(nfcMessage)")
        
        DispatchQueue.main.async {
            switch self.readType {
            case 0:
                if nfcMessage == "respawn"{
                    self.deathScreenNFC.respawn()
                    session.alertMessage = "Respawning..."
                } else {
                    session.alertMessage = "Invalid NFC Tag"
                }
            case 2:
                if String(nfcMessage[..<nfcMessage.index(nfcMessage.startIndex, offsetBy: 6)]) == "addr: " {
                    nfcMessage = nfcMessage.replacingOccurrences(of: "addr: ", with: "")
                    let stringArray = nfcMessage.components(separatedBy: ",")
                    networking.connectToServer(addr: stringArray[0], port: Int32(Int(stringArray[1]) ?? 1))
                    session.alertMessage = "Connecting to server..."
                } else {
                    session.alertMessage = "Invalid NFC Tag"
                }
            default:
                switch nfcMessage {
                case "respawn":
                    if handleGame.playerWithOddball.gunID != handleGame.playerSelf.gunID {
                        handleGame.respawn()
                        session.alertMessage = "Health and ammo refilled"
                    }
                    
                case "oddball":
                    if handleGame.playerWithOddball.gunID == -1 && Game.gameType == 1 {
                        networking.oddballReceived()
                        session.alertMessage = "Oddball claimed"
                    } else {
                        session.alertMessage = "Oddball has already been claimed"
                    }
                default:
                    session.alertMessage = "Invalid NFC Tag"
                }
            }
            
            session.invalidate()
        }
        
        
        
    }
    
    
    
    
}
