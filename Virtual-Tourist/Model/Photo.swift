//
//  Photo.swift
//  Virtual-Tourist
//
//  Created by Anindya Sengupta on 5/6/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation
import CoreData

final class Photo: NSManagedObject {
    @NSManaged public fileprivate(set) var imageURL: String
    @NSManaged public var imageData: Data?
    @NSManaged public fileprivate(set) var pin: Pin

    static func insert(into context: NSManagedObjectContext, imageURL: String, imageData: Data?, pin: Pin) -> Photo {
        let photo: Photo = context.insertObject()
        photo.imageURL = imageURL
        photo.imageData = imageData
        photo.pin = pin
        return photo
    }

    static func deletePhotos (context: NSManagedObjectContext, pin: Pin) {
        let predicate = NSPredicate(format: "%K == %@", "pin", pin)
        delete(context, where: predicate)
    }

    static func deletePhoto (context: NSManagedObjectContext, photo: Photo) {
        let predicate = NSPredicate(format: "%K == %@", "imageURL", photo.imageURL)
        delete(context, where: predicate)
    }
}

extension Photo: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "imageURL", ascending: true)]
    }
}
