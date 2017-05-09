//
//  FlickrDataManager.swift
//  Virtual-Tourist
//
//  Created by Anindya Sengupta on 5/6/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class PhotoDataManager {

    class func insertPhoto (imageURL: String, data: Data, location: CLLocationCoordinate2D) {
        if let managedObjectContext = CoreDataManager.shared.managedObjectContext {
            MapDataManager.fetch(pinLocation: location, completion: { (pins) in
                if let pin = pins?.first {
                    managedObjectContext.performChanges {
                        _ = Photo.insert(into: managedObjectContext, imageURL: imageURL, imageData: data, pin: pin)
                    }
                }
            })

        }
    }

    class func deletePhoto(for pin: Pin) {
        if let managedObjectContext = CoreDataManager.shared.managedObjectContext {
            Photo.deletePhotos(context: managedObjectContext, pin: pin)
        }
    }

    class func fetch (completion: @escaping ([Photo]?) -> Void) {
        DispatchQueue.main.async {
            if let managedObjectContext = CoreDataManager.shared.managedObjectContext {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Photo.entityName)
                do {
                    let photos = try managedObjectContext.fetch(fetchRequest) as! [Photo]
                    completion(photos)
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
