//
//  ViewController.swift
//  sdk-bridge-sample
//
//  Created by Carter Harrison on 2/12/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import UIKit
import XyBleSdk
import mod_ble_swift
import sdk_bridge_swift
import sdk_core_swift

class ViewController: UIViewController, XyoNodeListener {
    @IBOutlet weak var indexlabel : UILabel!
    private var currentAlert : UIAlertController? = nil
    private static let BRIDGE_LISTENER_KEY = "BRIDGE_LISTENER"
    private static let BRIDGE_SCANNER_KEY = "BRIDGE_VIEW"
    var bridge : XyoBleToTcpBridge? = nil
    let scanner = XYSmartScan.instance

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        XyoBluetoothDevice.family.enable(enable: true)
        XyoBluetoothDeviceCreator.enable(enable: true)
        
        
        setBridge()
        bridge!.archivists["MAIN"] = XyoTcpPeer(ip: "192.168.86.48", port: 11000)
        bridge!.addListener(key: ViewController.BRIDGE_LISTENER_KEY, listener: self)
        bridge!.originState.addSigner(signer: XyoStubSigner())
        scanner.setDelegate(bridge!, key: ViewController.BRIDGE_SCANNER_KEY)
        scanner.start(for: [XyoBluetoothDevice.family], mode: .foreground)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateIndex()
    }
    
    private func setBridge () {
        if (bridge == nil) {
            do {
                let repo = try XyoStrageProviderOriginBlockRepository(storageProvider: XyoInMemoryStorage(), hasher: XyoSha256())
                self.bridge = XyoBleToTcpBridge(hasher: XyoSha256(), blockRepository: repo)
            } catch {
                // this should never hit, unless the schemas are changed, whitch we did not do
                fatalError()
            }
        }

    }
    
    
    private func updateIndex () {
        DispatchQueue.main.async {
            do {
                self.indexlabel.text = String(try self.bridge!.originState.getIndex().getValueCopy().getUInt32(offset: 0))
            } catch {}
        }
    }
    
    func onBoundWitnessStart() {}
    func onBoundWitnessDiscovered(boundWitness: XyoBoundWitness) {}
    
    func onBoundWitnessEndFailure() {

        updateIndex()
    }
    
    func onBoundWitnessEndSuccess(boundWitness: XyoBoundWitness) {
        updateIndex()
    }
}

