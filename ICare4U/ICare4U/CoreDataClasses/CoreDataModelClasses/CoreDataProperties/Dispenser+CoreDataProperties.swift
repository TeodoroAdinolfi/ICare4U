//
//  Dispenser+CoreDataProperties.swift
//  ICare4U
//
//  Created by Teodoro Adinolfi on 15/05/22.
//
//

import Foundation
import CoreData


extension Dispenser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dispenser> {
        return NSFetchRequest<Dispenser>(entityName: "Dispenser")
    }

    @NSManaged public var nome: String
    @NSManaged public var pillolePresenti: Int16
    @NSManaged public var contenuti: Farmaco?

}

extension Dispenser : Identifiable {

}
