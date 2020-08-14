//
//  WriteServerToCard.swift
//  laser tag
//
//  Created by Aarush Bothra on 8/14/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import UIKit

class WriteServerToCard: UIViewController {

    @IBOutlet var serverAddressNFCTextField: UITextField!
    @IBOutlet var serverPortNFCTextField: UITextField!
    
    @IBOutlet var writeToCardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   
    @IBAction func writeToCardButton(_ sender: Any) {
        NFCWrite.createServerAddressCard(serverAddress: serverAddressNFCTextField.text!, serverPort: serverPortNFCTextField.text!)
        dismiss(animated: true)
    }
    
}
