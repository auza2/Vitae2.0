//
//  Variant+CoreDataProperties.swift
//  Vitae2.0
//
//  Created by Jamie Auza on 3/29/18.
//  Copyright © 2018 Jamie Auza. All rights reserved.
//
//

import Foundation
import CoreData


extension Variant {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Variant> {
        return NSFetchRequest<Variant>(entityName: "Variant")
    }

    @NSManaged public var repetitions: Int16
    @NSManaged public var sets: Int16
    @NSManaged public var weight: Int16
    @NSManaged public var datesLogged: [Date]?
    @NSManaged public var exercise: Exercise?

}

extension Variant{
    @objc func removeDate(fromDatesLogged date:Date ){
        
    }
}
