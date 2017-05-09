//
//  Pin.swift
//  Virtual-Tourist
//
//  Created by Anindya Sengupta on 5/4/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

struct Coordinates {
    var latitude: Double
    var longitude: Double
}

final class Pin: NSManagedObject {
    @NSManaged public fileprivate(set) var latitude: Double
    @NSManaged public fileprivate(set) var longitude: Double
    @NSManaged var photos: Set<Photo>?

    static func insert(into context: NSManagedObjectContext, coordinates: CLLocationCoordinate2D) -> Pin {
        let pin: Pin = context.insertObject()
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude
        return pin
    }
}

extension Pin: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "latitude", ascending: true)]
    }
}

