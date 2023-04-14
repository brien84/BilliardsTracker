//
//  DrillResult+CoreDataProperties.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-08.
//
//

import Foundation
import CoreData

extension DrillResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DrillResult> {
        return NSFetchRequest<DrillResult>(entityName: "DrillResult")
    }

    @NSManaged private var dateValue: Date?
    @NSManaged private var potCountValue: Int64
    @NSManaged private var missCountValue: Int64
    @NSManaged private var drillValue: Drill?

    var date: Date {
        get {
            dateValue ?? Date()
        }
        set {
            dateValue = newValue
        }
    }

    var potCount: Int {
        get {
            Int(potCountValue)
        }
        set {
            potCountValue = Int64(newValue)
        }
    }

    var missCount: Int {
        get {
            Int(missCountValue)
        }
        set {
            missCountValue = Int64(newValue)
        }
    }

    var drill: Drill? {
        get {
            drillValue
        }
        set {
            drillValue = newValue
        }
    }
}

extension DrillResult: Identifiable {

}
