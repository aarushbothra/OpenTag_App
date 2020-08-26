//
//  NFCHandler.swift
//  laser tag
//
//  Created by Aarush Bothra on 8/5/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import Foundation
import CoreNFC


class NFCWriteHandler: NSObject, NFCNDEFReaderSessionDelegate {
    
    var session: NFCNDEFReaderSession!
    
    var messageToWrite = ""
    
    func createRespawnPoint() {
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your phone near an NFC tag to create respawn point"
        session.begin()
        messageToWrite = "respawn"
    }
    
    func createServerAddressCard(serverAddress: String, serverPort: String){
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your phone near an NFC tag"
        session.begin()
        messageToWrite = "addr: \(serverAddress),\(serverPort)"
    }
    
    func createOddballCard(){
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your phone near an NFC tag to create an oddball"
        session.begin()
        messageToWrite = "oddball"
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {}
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        
        let messageToUInt8 = [UInt8](messageToWrite.utf8)
        
        
        if tags.count > 1 {
            //restart polling after 500 milliseconds
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than one tag detected. Please try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
                
            })
            return
        }
        
        //connect tag found and write an ndef message to it
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error : Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag"
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    session.alertMessage = "Unable to query the NDEF status of the tag"
                    session.invalidate()
                    return
                }
                
                switch ndefStatus {
                case .notSupported:
                    session.alertMessage = "NFC tag is not complient"
                case .readOnly:
                    session.alertMessage = "NFC tag is read only"
                case .readWrite:
                    
                    tag.writeNDEF(.init(records: [.init(format: .nfcWellKnown, type: Data([06]), identifier: Data([0x0C]), payload: Data(messageToUInt8))]), completionHandler: { (error: Error?) in
                        if nil != error {
                            session.alertMessage = "NFC write failed: \(error!)"
                        } else {
                            session.alertMessage = "NFC write successful"
                        }
                        session.invalidate()
                    })
                @unknown default:
                    session.alertMessage = "Unknown NFC tag status"
                }
                
            })
        })
        
        
    }
    
    
}

