//
//  Log+CoreDataProperties.swift
//  Vitae2.0
//
//  Created by Jamie Auza on 3/29/18.
//  Copyright © 2018 Jamie Auza. All rights reserved.
//
//

import Foundation
import CoreData


extension Log {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Log> {
        return NSFetchRequest<Log>(entityName: "Log")
    }

    @NSManaged public var date: Date
    @NSManaged public var notes: String?
    @NSManaged public var exercises: [Exercise]?

}

// MARK: Generated accessors for exercises
extension Log {

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: Exercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: Exercise)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: [Exercise])

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: [Exercise])

}
