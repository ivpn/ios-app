//
//  Server+CoreDataProperties.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19/02/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation
import CoreData

extension Server {
    
    @NSManaged public var gateway: String?
    @NSManaged public var group: String?
    @NSManaged public var isFastestEnabled: Bool
    
    convenience init(context: NSManagedObjectContext, needToSave: Bool) {
        let entity = NSEntityDescription.entity(forEntityName: "Server", in: context)
        self.init(entity: entity!, insertInto: needToSave ? context : nil)
    }
    
    @nonobjc public class func fetchRequest(gateway: String = "", group: String = "", isFastestEnabled: Bool = false) -> NSFetchRequest<Server> {
        let fetchRequest = NSFetchRequest<Server>(entityName: "Server")
        var filters = [NSPredicate]()
        
        if !gateway.isEmpty {
            filters.append(NSPredicate(format: "gateway == %@", gateway))
        }
        
        if !group.isEmpty {
            filters.append(NSPredicate(format: "group == %@", group))
        }
        
        if isFastestEnabled {
            filters.append(NSPredicate(format: "isFastestEnabled == %@", NSNumber(value: isFastestEnabled)))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filters)
        
        return fetchRequest
    }

}
