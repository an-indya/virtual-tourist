//
//  MapDataManager.swift
//  Virtual-Tourist
//
//  Created by Anindya Sengupta on 5/4/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation
import MapKit
import CoreData
import CoreLocation

class MapDataManager {

    class func insertAnnotation (annotation: MKPointAnnotation) {
        if let managedObjectContext = CoreDataManager.shared.managedObjectContext {
            managedObjectContext.performChanges {
                _ = Pin.insert(into: managedObjectContext, coordinates: CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
            }
        }
    }

    class func fetch(pinLocation: CLLocationCoordinate2D, completion: @escaping ([Pin]?) -> Void) {
        DispatchQueue.main.async {
            if let managedObjectContext = CoreDataManager.shared.managedObjectContext {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Pin.entityName)
                let predicate = NSCompoundPredicate(type: .and, subpredicates: [
                    NSPredicate(format: "%K == %lf", "latitude", pinLocation.latitude),
                    NSPredicate(format: "%K == %lf", "longitude", pinLocation.longitude)])
                fetchRequest.predicate = predicate
                do {
                    let pins = try managedObjectContext.fetch(fetchRequest) as! [Pin]
                    completion(pins)
                } catch {
                    print(error.localizedDescription)
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    class func fetch (completion: @escaping ([Pin]?) -> Void) {
        DispatchQueue.main.async {
            if let managedObjectContext = CoreDataManager.shared.managedObjectContext {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Pin.entityName)
                do {
                    let pins = try managedObjectContext.fetch(fetchRequest) as! [Pin]
                    completion(pins)
                } catch {
                    print(error.localizedDescription)
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
}
