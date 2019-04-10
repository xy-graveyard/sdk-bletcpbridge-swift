//
//  XyoBridgeProcedureCatalogue.swift
//  sdk-bridge-swift
//
//  Created by Carter Harrison on 2/21/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_core_swift

public class XyoBridgeProcedureCatalogue : XyoFlagProcedureCatalogue {
    private static let allSupportedFunctions = UInt32(
        XyoProcedureCatalogueFlags.BOUND_WITNESS |
        XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN |
        XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN)
    
    public init () {
        super.init(forOther: XyoBridgeProcedureCatalogue.allSupportedFunctions,
                   withOther: XyoBridgeProcedureCatalogue.allSupportedFunctions)
    }
    
    override public func choose(catalogue: [UInt8]) -> [UInt8] {
        guard let intrestedFlags = catalogue.last else {
            return []
        }
        
        if (intrestedFlags & UInt8(XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN) != 0 && canDo(bytes: [UInt8(XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN)])) {
            return [UInt8(XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN)]
        }
        
        if (intrestedFlags & UInt8(XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN) != 0 && canDo(bytes: [UInt8(XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN)])) {
            return [UInt8(XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN)]
        }
        
        return [UInt8(XyoProcedureCatalogueFlags.BOUND_WITNESS)]
    }
}

public class XyoBridgeProcedureStrictCatalogue : XyoFlagProcedureCatalogue {
    private static let allSupportedFunctions = UInt32(
        XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN |
            XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN)

    public init () {
        super.init(forOther: XyoBridgeProcedureStrictCatalogue.allSupportedFunctions,
                   withOther: XyoBridgeProcedureStrictCatalogue.allSupportedFunctions)
    }

    override public func choose(catalogue: [UInt8]) -> [UInt8] {
        guard let intrestedFlags = catalogue.last else {
            return []
        }

        if (intrestedFlags & UInt8(XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN) != 0 && canDo(bytes: [UInt8(XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN)])) {
            return [UInt8(XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN)]
        }

        if (intrestedFlags & UInt8(XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN) != 0 && canDo(bytes: [UInt8(XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN)])) {
            return [UInt8(XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN)]
        }

        return []
    }
}
