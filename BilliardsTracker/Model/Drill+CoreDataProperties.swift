//
//  Drill+CoreDataProperties.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-08.
//
//

import Foundation
import CoreData

extension Drill {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Drill> {
        return NSFetchRequest<Drill>(entityName: "Drill")
    }

    @NSManaged private var attemptsValue: Int64
    @NSManaged private var titleValue: String?
    @NSManaged private var resultsValue: NSSet?

    var attempts: Int {
        get {
            Int(attemptsValue)
        }
        set {
            attemptsValue = Int64(newValue)
        }
    }

    var title: String {
        get {
            titleValue ?? ""
        }
        set {
            titleValue = newValue
        }
    }

    var results: [DrillResult] {
        get {
            guard let resultsSet = resultsValue as? Set<DrillResult> else { return [] }
            return Array(resultsSet).sorted { $0.date > $1.date }
        }
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
