//
//  Variant+CoreDataProperties.swift
//  Vitae2.0
//
//  Created by Jamie Auza on 3/30/18.
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
    @NSManaged public var exercise: Exercise
    @NSManaged public var logs: [Log]?
    @NSManaged public var workouts: [Workout]?

}

// MARK: Generated accessors for logs
extension Variant {

    @objc(addLogsObject:)
    @NSManaged public func addToLogs(_ value: Log)

    @objc(removeLogsObject:)
    @NSManaged public func removeFromLogs(_ value: Log)

    @objc(addLogs:)
    @NSManaged public func addToLogs(_ values: [Workout])

    @objc(removeLogs:)
    @NSManaged public func removeFromLogs(_ values: [Workout])

}

// MARK: Generated accessors for workouts
extension Variant {

    @objc(addWorkoutsObject:)
    @NSManaged public func addToWorkouts(_ value: Workout)

    @objc(removeWorkoutsObject:)
    @NSManaged public func removeFromWorkouts(_ value: Workout)

    @objc(addWorkouts:)
    @NSManaged public func addToWorkouts(_ values: [Workout])

    @objc(removeWorkouts:)
    @NSManaged public func removeFromWorkouts(_ values: [Workout])

}
