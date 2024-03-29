//
//  Drill+CoreDataProperties.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-08.
//
//

import CoreData
import Foundation

extension Drill {
    @NSManaged private var attemptsValue: Int64
    @NSManaged private var titleValue: String?
    @NSManaged private var isFailableValue: Bool
    @NSManaged private var dateCreatedValue: Date
    @NSManaged private var resultsValue: NSSet?

    @objc var dateCreated: Date {
        get {
            dateCreatedValue
        }
        set {
            dateCreatedValue = newValue
        }
    }

    /// To improve clarity, the `isFailable` property has been renamed to
    /// `isContinuous` and its boolean value has been inverted.
    ///
    /// Since the value can be easily inverted within this wrapper property without any impact to codebase,
    /// there is no urgent need to update the CoreData model unless a wider migration is performed.
    @objc var isContinuous: Bool {
        get {
            !isFailableValue
        }
        set {
            isFailableValue = !newValue
        }
    }

    /// To improve clarity, the `attempts` property has been renamed to `shotCount`.
    ///
    /// Underlying CoreData value will be renamed when a wider migration is performed.
    @objc var shotCount: Int {
        get {
            Int(attemptsValue)
        }
        set {
            attemptsValue = Int64(newValue)
        }
    }

    @objc var title: String {
        get {
            titleValue ?? "Drill Title"
        }
        set {
            titleValue = newValue
        }
    }

    var results: [DrillResult] {
        guard let resultsSet = resultsValue as? Set<DrillResult> else { return [] }
        return Array(resultsSet).sorted { $0.date > $1.date }
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Drill> {
        NSFetchRequest<Drill>(entityName: "Drill")
    }
}

extension Drill: Identifiable { }

// MARK: Generated accessors for resultsValue

extension Drill {
    @objc(addResultsValueObject:)
    @NSManaged public func addToResultsValue(_ value: DrillResult)

    @objc(removeResultsValueObject:)
    @NSManaged public func removeFromResultsValue(_ value: DrillResult)

    @objc(addResultsValue:)
    @NSManaged public func addToResultsValue(_ values: NSSet)

    @objc(removeResultsValue:)
    @NSManaged public func removeFromResultsValue(_ values: NSSet)
}
