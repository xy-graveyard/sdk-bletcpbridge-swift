//
//  XyoBleToTcpBridge.swift
//  sdk-bridge-swift
//
//  Created by Carter Harrison on 2/12/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_core_swift
import sdk_xyobleinterface_swift
import sdk_objectmodel_swift
import XyBleSdk
import Promises

/// A bridge from bluetooth pipes to tcp, this is the primary bridge in the XYO network.
public class XyoBleToTcpBridge : XyoRelayNode {
    public var secondsToWaitInBetweenConnections = 10
    private var lastConnectTime : Date? = nil
    private var catalogue = XyoBridgeProcedureCatalogue()
    private var lastBleDeviceMinor : UInt16?
    private var canCollect : Bool = true
    private var canSend : Bool = true
    public var archivists = [String : XyoTcpPeer]()
    
    
    public func bridge (index: Int = 0) {
        if ((archivists.count - 1) < index) {
            return
        }
        
        DispatchQueue.global().async {
            let archivist = Array(self.archivists)[index].value
            
            self.bridge(tcpDevice: archivist, completion: { (boundWitness, error) in
                if (error != nil) {
                    self.bridge(index: (index + 1))
                }
            })
        }
    }
    
    private func isCollectTimeoutDone () -> Bool {
        guard let time = lastConnectTime else {
            return true
        }
        
        return time.timeIntervalSinceNow < TimeInterval(exactly: -(secondsToWaitInBetweenConnections))!
    }
    
    public func bridge (tcpDevice : XyoTcpPeer, completion: @escaping (_: XyoBoundWitness?, _: XyoError?)->()) {
        if (canSend) {
            let socket = XyoTcpSocket.create(peer: tcpDevice)
            let pipe = XyoTcpSocketPipe(socket: socket, initiationData: nil)
        
            self.boundWitness(handler: XyoNetworkHandler(pipe: pipe), procedureCatalogue: self.catalogue) { (boundWitness, error) in
                
                pipe.close()
                self.enableBoundWitnesses(enable: true)
                
                completion(boundWitness, error)
            }
        }
    }
    
    public func enableBoundWitnesses (enable : Bool) {
        canSend = enable
        canCollect = enable
    }
}

extension XyoBleToTcpBridge : XYSmartScanDelegate {
    public func smartScan(detected devices: [XYBluetoothDevice], family: XYDeviceFamily) {
        if (canCollect && isCollectTimeoutDone()) {
            let xyoDevices = getXyoDevices(devices: devices)
            guard let randomDevice = getRandomXyoDevice(devices: xyoDevices) else {
                return
            }
            
            lastBleDeviceMinor = randomDevice.iBeacon?.minor
            collect(bleDevice: randomDevice)
        }
    }
    
    // unused scanner callbacks
    public func smartScan(status: XYSmartScanStatus) {}
    public func smartScan(location: XYLocationCoordinate2D) {}
    public func smartScan(detected device: XYBluetoothDevice, signalStrength: Int, family: XYDeviceFamily) {}
    public func smartScan(entered device: XYBluetoothDevice) {}
    public func smartScan(exiting device: XYBluetoothDevice) {}
    public func smartScan(exited device: XYBluetoothDevice) {}
    
    private func getXyoDevices (devices : [XYBluetoothDevice]) -> [XyoBluetoothDevice] {
        var xyoDevices = [XyoBluetoothDevice]()
        
        for device in devices {
            let xyoDevice = device as? XyoBluetoothDevice
            
            if (xyoDevice != nil)  {
                xyoDevices.append(xyoDevice!)
            }
        }
        
        return xyoDevices
    }
    
    private func getRandomXyoDevice (devices : [XyoBluetoothDevice]) -> XyoBluetoothDevice? {
        if (devices.count == 0) {
            return nil
        }
        
        for i in 0...devices.count - 1 {
            let device = devices[i]
            
            if (device.iBeacon?.minor != lastBleDeviceMinor) {
                return device
            }
        }
        
        return devices.first
    }
    
    public func collect (bleDevice : XyoBluetoothDevice) {
        if (canCollect) {
            self.enableBoundWitnesses(enable: false)
            
            bleDevice.connection {
                guard let pipe = bleDevice.tryCreatePipe() else {
                    return
                }

                self.boundWitness(handler: XyoNetworkHandler(pipe: pipe), procedureCatalogue: self.catalogue, completion: { (boundWitness, error) in
                    XYCentral.instance.disconnect(from: bleDevice)
                    self.lastConnectTime = Date()
                    XYCentral.instance.disconnect(from: bleDevice)
                    self.enableBoundWitnesses(enable: true)
                    self.bridge()
                })
            }
        }
    }
}


extension XyoBleToTcpBridge : XyoPipeCharacteristicLisitner {
    public func onPipe(pipe: XyoNetworkPipe) {
        self.enableBoundWitnesses(enable: false)
        
        DispatchQueue.global().async {
            self.boundWitness(handler: XyoNetworkHandler(pipe: pipe), procedureCatalogue: self.catalogue, completion: { (boundWitness, error) in
                self.enableBoundWitnesses(enable: true)
                pipe.close()
                self.bridge()
            })
        }
    }
}
