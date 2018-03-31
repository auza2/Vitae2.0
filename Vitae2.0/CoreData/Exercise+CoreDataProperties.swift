//
//  Exercise+CoreDataProperties.swift
//  Vitae2.0
//
//  Created by Jamie Auza on 3/30/18.
//  Copyright © 2018 Jamie Auza. All rights reserved.
//
//

import Foundation
import CoreData


extension Exercise {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var name: String
    @NSManaged public var variants: [Variant]?

}

// MARK: Generated accessors for variants
extension Exercise {

    @objc(addVariantsObject:)
    @NSManaged public func addToVariants(_ value: Variant)

    @objc(removeVariantsObject:)
    @NSManaged public func removeFromVariants(_ value: Variant)

    @objc(addVariants:)
    @NSManaged public func addToVariants(_ values: [Variant])

    @objc(removeVariants:)
    @NSManaged public func removeFromVariants(_ values: [Variant])

}
