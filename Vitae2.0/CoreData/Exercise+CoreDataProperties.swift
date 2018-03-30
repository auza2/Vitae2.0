//
//  Exercise+CoreDataProperties.swift
//  Vitae2.0
//
//  Created by Jamie Auza on 3/29/18.
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
    @NSManaged public var logs: [Log]?
    @NSManaged public var variants: [Variant]?
    @NSManaged public var workouts: [Workout]?

}

// MARK: Generated accessors for logs
extension Exercise {

    @objc(addLogsObject:)
    @NSManaged public func addToLogs(_ value: Log)

    @objc(removeLogsObject:)
    @NSManaged public func removeFromLogs(_ value: Log)

    @objc(addLogs:)
    @NSManaged public func addToLogs(_ values: NSSet)

    @objc(removeLogs:)
    @NSManaged public func removeFromLogs(_ values: NSSet)

}

// MARK: Generated accessors for variants
extension Exercise {

    @objc(addVariantsObject:)
    @NSManaged public func addToVariants(_ value: Variant)

    @objc(removeVariantsObject:)
    @NSManaged public func removeFromVariants(_ value: Variant)

    @objc(addVariants:)
    @NSManaged public func addToVariants(_ values: NSSet)

    @objc(removeVariants:)
    @NSManaged public func removeFromVariants(_ values: NSSet)

}

// MARK: Generated accessors for workouts
extension Exercise {

    @objc(addWorkoutsObject:)
    @NSManaged public func addToWorkouts(_ value: Workout)

    @objc(removeWorkoutsObject:)
    @NSManaged public func removeFromWorkouts(_ value: Workout)

    @objc(addWorkouts:)
    @NSManaged public func addToWorkouts(_ values: NSSet)

    @objc(removeWorkouts:)
    @NSManaged public func removeFromWorkouts(_ values: NSSet)

}
