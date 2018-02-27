//
//  ViewController.swift
//  ethe
//
//  Created by Łukasz Bożek on 22/02/2018.
//  Copyright © 2018 lu. All rights reserved.
//

import UIKit
import Geth

class ViewController: UIViewController {
    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var firstPass: UITextField!
    @IBOutlet weak var secondPass: UITextField!
    @IBOutlet weak var segments: UISegmentedControl!
    
    var ks: GethKeyStore!
    var acc: GethAccount?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        ks = GethNewKeyStore(datadir + "/keystore", GethLightScryptN, GethLightScryptP)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionButton(_ sender: Any) {
        switch segments.selectedSegmentIndex {
        case 0:
            makeKey()
        case 1:
            changePass()
        case 2:
            sign()
        case 3:
            exportKey()
        default:
            break
        }
    }
    
    func makeKey() {
        guard let pass = firstPass.text, !pass.isEmpty else {
            return
        }
        // Create a new account with the specified encryption passphrase.
        acc = try! ks?.newAccount(pass)
        
        
        log("acc created")
        
    }
    
    func changePass() {
        guard let pass = firstPass.text, !pass.isEmpty else {
            return
        }
        guard let newPass = secondPass.text, !newPass.isEmpty else {
            return
        }
        // Update the passphrase on the account created above inside the local keystore.
        try! ks?.update(acc, passphrase: pass, newPassphrase: newPass)
        
        
        log("updated")
    }
    
    func exportKey() {
        guard let pass = firstPass.text, !pass.isEmpty else {
            return
        }
        guard let newPass = secondPass.text, !newPass.isEmpty else {
            return
        }
        // Export the newly created account with a different passphrase. The returned
        // data from this method invocation is a JSON encoded, encrypted key-file.
        let jsonKey = try! ks?.exportKey(acc!, passphrase: pass, newPassphrase: newPass)
        
        
        log("exported")
        
        // Delete the account updated above from the local keystore.
        //        try! ks?.delete(acc, passphrase: "Update password")
        
        // Import back the account we've exported (and then deleted) above with yet
        // again a fresh passphrase.
        //        let impAcc  = try! ks?.importKey(jsonKey, passphrase: "Export password", newPassphrase: "Import password")
    }
    
    func sign() {
        guard let pass = firstPass.text, !pass.isEmpty else {
            return
        }
        // Create a new account to sign transactions with
        var error: NSError?
        let signer = try! ks?.newAccount(pass)
        
        let to    = GethNewAddressFromHex("0x0000000000000000000000000000000000000000", &error)
        let tx    = GethNewTransaction(1, to, GethNewBigInt(0), GethNewBigInt(0), GethNewBigInt(0), nil) // Random empty transaction
        let chain = GethNewBigInt(4) // Chain identifier of the main net = 1, 4 = testnet
        
        // Sign a transaction with a single authorization
        var signed = try! ks?.signTxPassphrase(signer, passphrase: pass, tx: tx, chainID: chain)
        
        log("signed")
        
        // Sign a transaction with multiple manually cancelled authorizations
//        try! ks?.unlock(signer, passphrase: "Signer password")
//        signed = try! ks?.signTx(signer, tx: tx, chainID: chain)
//        try! ks?.lock(signer?.getAddress())
        
        // Sign a transaction with multiple automatically cancelled authorizations
//        try! ks?.timedUnlock(signer, passphrase: "Signer password", timeout: 1000000000)
//        signed = try! ks?.signTx(signer, tx: tx, chainID: chain)
    }
    
    func log(_ str: String) {
        logView.text = str + "\n" + logView.text
    }

}

