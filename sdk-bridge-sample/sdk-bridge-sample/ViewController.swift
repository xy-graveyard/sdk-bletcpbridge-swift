//
//  ViewController.swift
//  sdk-bridge-sample
//
//  Created by Carter Harrison on 2/12/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import UIKit
import XyBleSdk
import sdk_xyobleinterface_swift
import sdk_bridge_swift
import sdk_core_swift

class ViewController: UIViewController, XyoNodeListener {
    @IBOutlet weak var indexlabel : UILabel!
    @IBOutlet weak var archivistIpBox : UITextField!
    @IBOutlet weak var archivistPortBox : UITextField!
    @IBOutlet weak var archivistSubmit : UIButton!
    private var currentAlert : UIAlertController? = nil
    private static let BRIDGE_LISTENER_KEY = "BRIDGE_LISTENER"
    private static let BRIDGE_SCANNER_KEY = "BRIDGE_VIEW"
    private var bridge : XyoBleToTcpBridge!
    private let scanner = XYSmartScan.instance
    private let server = XyoBluetoothServer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        XyoBluetoothDevice.family.enable(enable: true)
        XyoBluetoothDeviceCreator.enable(enable: true)
        
        setBridge()
        bridge.addListener(key: ViewController.BRIDGE_LISTENER_KEY, listener: self)
        bridge.originState.addSigner(signer: XyoStubSigner())
        scanner.setDelegate(bridge, key: ViewController.BRIDGE_SCANNER_KEY)
        scanner.start(for: [XyoBluetoothDevice.family], mode: .foreground)
        server.start(listener: bridge)
        archivistSubmit.addTarget(self, action: #selector(addArchivistClick), for: UIControl.Event.touchUpInside)

    }
    
    @objc
    func addArchivistClick(sender: UIButton) {
        let ip = archivistIpBox.text ?? "localhost"
        let port = UInt32(archivistPortBox.text ?? "11000") ?? 11000
        
        bridge.archivists["MAIN"] = XyoTcpPeer(ip: ip, port: port)
        bridge.bridge()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateIndex()
    }
    
    private func setBridge () {
        if (bridge == nil) {
            let storage = XyoInMemoryStorage()
            let repo = XyoStrageProviderOriginBlockRepository(storageProvider: storage, hasher: XyoSha256())
            self.bridge = XyoBleToTcpBridge(hasher: XyoSha256(),
                                            blockRepository: repo,
                                            originStateRepository: XyoStorageOriginChainStateRepository(storage: storage),
                                            queueRepository: XyoStorageBridgeQueueRepository(storage: storage))
        }
    }
    
    private func updateIndex () {
        DispatchQueue.main.async {
            do {
                self.indexlabel.text = String(try self.bridge!.originState.getIndex().getValueCopy().getUInt32(offset: 0))
            } catch {
                
            }
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

