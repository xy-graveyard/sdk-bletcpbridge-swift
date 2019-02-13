//
//  XyoBleToTcpBridge.swift
//  sdk-bridge-swift
//
//  Created by Carter Harrison on 2/12/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_core_swift
import mod_ble_swift
import sdk_objectmodel_swift
import XyBleSdk
import Promises

public class XyoBleToTcpBridge : XyoRelayNode, XYSmartScanDelegate {
    private var catalogue = XyoFlagProcedureCatalogue(forOther: 0xff, withOther: 0xff)
    private var lastBleDeviceMinor : UInt16?
    private var canCollect : Bool = true
    private var canSend : Bool = true
    public var archivists = [String : XyoTcpPeer]()
    
    
    public func smartScan(detected devices: [XYBluetoothDevice], family: XYDeviceFamily) {
        if (canCollect) {
            let xyoDevices = getXyoDevices(devices: devices)
            guard let randomDevice = getRandomXyoDevice(devices: xyoDevices) else {
                return
            }
            
            lastBleDeviceMinor = randomDevice.iBeacon?.minor
            collect(bleDevice: randomDevice)
        }
    }
    
    public func collect (bleDevice : XyoBluetoothDevice) {
        if (canCollect) {
            DispatchQueue.global().async {
                bleDevice.connection {
                    self.enableBoundWitnesses(enable: false)
                    
                    guard let pipe = bleDevice.tryCreatePipe() else {
                        return
                    }
                    
                    do {
                        _ = try self.doNeogeoationThenBoundWitness(handler: XyoNetworkHandler(pipe: pipe),
                                                                   procedureCatalogue: self.catalogue)
                        
                        XYCentral.instance.disconnect(from: bleDevice)
                        self.enableBoundWitnesses(enable: true)
                        self.bridge()
                        return
                    } catch is XyoError {
                        self.enableBoundWitnesses(enable: true)
                    } catch is XyoObjectError {
                        self.enableBoundWitnesses(enable: true)
                    }
                    
                    XYCentral.instance.disconnect(from: bleDevice)
                }
            }
        }
    }
    
    public func bridge () {
        DispatchQueue.global().async {
            for (_, archivist) in self.archivists {
                if (self.bridge(tcpDevice: archivist) != nil) {
                    break
                }
            }
        }
    }
    
    public func bridge (tcpDevice : XyoTcpPeer) -> XyoBoundWitness? {
        if (canSend) {
            let socket = XyoTcpSocket.create(peer: tcpDevice)
            let pipe = XyoTcpSocketPipe(socket: socket, initiationData: nil)
        
            do {
                let boundWitness = try self.doNeogeoationThenBoundWitness(handler: XyoNetworkHandler(pipe: pipe),
                                                           procedureCatalogue: self.catalogue)
                self.enableBoundWitnesses(enable: true)
                
                
                return boundWitness
            } catch is XyoError {
                self.enableBoundWitnesses(enable: true)
            } catch is XyoObjectError {
                self.enableBoundWitnesses(enable: true)
            } catch {
                self.enableBoundWitnesses(enable: true)
            }
        }
        
        return nil
    }
    
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
    
    public func enableBoundWitnesses (enable : Bool) {
        canSend = enable
        canCollect = enable
    }
    
    // unused scanner callbacks
    public func smartScan(status: XYSmartScanStatus) {}
    public func smartScan(location: XYLocationCoordinate2D) {}
    public func smartScan(detected device: XYBluetoothDevice, signalStrength: Int, family: XYDeviceFamily) {}
    public func smartScan(entered device: XYBluetoothDevice) {}
    public func smartScan(exiting device: XYBluetoothDevice) {}
    public func smartScan(exited device: XYBluetoothDevice) {}
}
