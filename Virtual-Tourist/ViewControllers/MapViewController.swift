//
//  ViewController.swift
//  Virtual-Tourist
//
//  Created by Anindya Sengupta on 4/30/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController  {

    @IBOutlet weak var mapview: MKMapView!
    var userDidChangeLocation: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
        if let regionDict: [String: Any] = UserDefaultsManager.getCustomObject(for: Keys.kRegionKey),
            let region = MKCoordinateRegion(decode: regionDict) {
            mapview.region = region
        }
    }

}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if userDidChangeLocation == true {
            UserDefaultsManager.setCustomObject(object: mapview.region.encode, for: Keys.kRegionKey)
            userDidChangeLocation = false
        }
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if let view = mapview.subviews.first {
            for recognizer in view.gestureRecognizers! {
                if recognizer.state == .began || recognizer.state == .ended {
                    userDidChangeLocation = true
                    break
                }
            }
        }
    }
}
