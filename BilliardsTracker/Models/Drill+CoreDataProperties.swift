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
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Drill> {
        NSFetchRequest<Drill>(entityName: "Drill")
    }

    @nonobjc public class func attemptsSortDescriptor() -> NSSortDescriptor {
        NSSortDescriptor(key: "attemptsValue", ascending: true)
    }

    @nonobjc public class func dateCreatedSortDescriptor() -> NSSortDescriptor {
        NSSortDescriptor(key: "dateCreatedValue", ascending: false)
    }

    @nonobjc public class func titleSortDescriptor() -> NSSortDescriptor {
        NSSortDescriptor(key: "titleValue", ascending: true)
    }

    @NSManaged private var attemptsValue: Int64
    @NSManaged private var titleValue: String?
    @NSManaged private var isFailableValue: Bool
    @NSManaged private var dateCreatedValue: Date
    @NSManaged private var resultsValue: NSSet?

    var attempts: Int {
        get {
            Int(attemptsValue)
        }
        set {
            attemptsValue = Int64(newValue)
        }
    }

    var dateCreated: Date {
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
    var isContinuous: Bool {
        get {
            !isFailableValue
        }
        set {
            isFailableValue = !newValue
        }
    }

    var title: String {
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

}

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

extension Drill: Identifiable {

}
