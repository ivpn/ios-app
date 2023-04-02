//
//  CustomPort+CoreDataProperties.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2022-10-05.
//  Copyright (c) 2022 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

extension CustomPort {
    
    @NSManaged public var vpnProtocol: String?
    @NSManaged public var type: String?
    @NSManaged public var port: Int32

    @nonobjc public class func fetchRequest(vpnProtocol: String = "") -> NSFetchRequest<CustomPort> {
        let fetchRequest = NSFetchRequest<CustomPort>(entityName: "CustomPort")
        var filters = [NSPredicate]()
        
        if !vpnProtocol.isEmpty {
            filters.append(NSPredicate(format: "vpnProtocol == %@", vpnProtocol))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filters)
        
        return fetchRequest
    }

}
