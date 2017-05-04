//
//  Extensions.swift
//  Virtual-Tourist
//
//  Created by Anindya Sengupta on 5/4/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation
import MapKit

extension MKCoordinateRegion {

    var encode:[String: Any] {
        return ["center": ["latitude": self.center.latitude, "longitude": self.center.longitude],
                "span": ["latitudeDelta": self.span.latitudeDelta, "longitudeDelta": self.span.longitudeDelta]]
    }

    init?(decode: [String: Any]) {
        guard let center = decode["center"] as? [String: AnyObject],
            let latitude = center["latitude"] as? Double,
            let longitude = center["longitude"] as? Double,
            let span = decode["span"] as? [String: AnyObject],
            let latitudeDelta = span["latitudeDelta"] as? Double,
            let longitudeDelta = span["longitudeDelta"] as? Double else { return nil }

        self.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
}
