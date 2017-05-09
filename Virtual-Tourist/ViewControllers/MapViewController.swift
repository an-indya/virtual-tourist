//
//  ViewController.swift
//  Virtual-Tourist
//
//  Created by Anindya Sengupta on 4/30/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, SegueHandler  {

    @IBOutlet weak var mapview: MKMapView!
    var userDidChangeLocation: Bool?
    enum SegueIdentifier: String {
        case revealPhotos = "revealPhotos"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapview.removeAnnotations(mapview.annotations)
        populatePins()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
        restoreRegion()
        registerLongPressGesture()

    }

    func registerLongPressGesture () {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 2
        mapview.addGestureRecognizer(longPress)
    }

    func restoreRegion () {
        if let regionDict: [String: Any] = UserDefaultsManager.getCustomObject(for: Keys.kRegionKey),
            let region = MKCoordinateRegion(decode: regionDict) {
            mapview.region = region
        }
    }

    func populatePins () {
        MapDataManager.fetch { (pins) in
            if let pins = pins {
                pins.forEach({ (pin) in
                    let annotation = MKPointAnnotation ()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                    DispatchQueue.main.async {[weak self] in
                        guard let weakself = self else { return }
                        weakself.mapview.addAnnotation(annotation)
                    }
                })
            }
        }
    }

    func handleLongPress (recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state != .ended else { return }
        let touchCoordinate = mapview.convert(recognizer.location(in: mapview), toCoordinateFrom: mapview)
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchCoordinate
        DispatchQueue.main.async {
            self.mapview.addAnnotation(annotation)
            if let managedObjectContext = CoreDataManager.shared.managedObjectContext {
                managedObjectContext.performChanges {
                    let coordinates = CLLocationCoordinate2D(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
                    let pin = Pin.insert(into: managedObjectContext, coordinates: coordinates)
                    if pin.photos == nil || pin.photos?.count == 0 {
                        PhotoNetworkManager.getFlickrImages(for: coordinates, page: 1)
                    }
                }
            }
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

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        annotationView.canShowCallout = false
        annotationView.animatesDrop = true

        return annotationView
    }


    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            MapDataManager.fetch(pinLocation: annotation.coordinate, completion: { (pins) in
                if let pins = pins, let pin = pins.first {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: .revealPhotos, sender: pin)
                    }
                }
            })
        }
    }
}

extension MapViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pin = sender as? Pin,
            let photoVC = segue.destination as? PhotoViewController {
            photoVC.location = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            photoVC.pin = pin
        }
    }
}
