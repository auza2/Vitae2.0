//
//  Workout+CoreDataProperties.swift
//  exerciseLibrary_HwS
//
//  Created by Jamie Auza on 3/13/18.
//  Copyright © 2018 Jamie Auza. All rights reserved.
//
//

import Foundation
import CoreData


extension Workout {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout")
    }

    @NSManaged public var name: String
    @NSManaged public var exercises: [Exercise]?

}

// MARK: Generated accessors for exercises
extension Workout {

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: Exercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: Exercise)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: [Exercise])

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: [Exercise])

}
