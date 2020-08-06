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
    
    
    
    func readRespawnPoint() {
        
        readSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        readSession?.alertMessage = "Hold your phone near the respawn NFC tag"
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
            switch nfcMessage {
            case "respawn":
                self.deathScreenNFC.respawn()
                session.invalidate()
            case "invalid":
                session.alertMessage = "Not a valid NFC tag"
                session.invalidate()
            default:
                session.alertMessage = "Not a valid NFC tag"
                session.invalidate()
            }
        }
        
        
        
    }
    
    
    
    
}
