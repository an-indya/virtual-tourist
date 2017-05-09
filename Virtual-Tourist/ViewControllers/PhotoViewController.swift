//
//  PhotoViewController.swift
//  Virtual-Tourist
//
//  Created by Anindya Sengupta on 4/30/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class PhotoViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    var location: CLLocationCoordinate2D?
    var pin: Pin?
    var page: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        updateMapView()
        setupCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { fatalError("Wrong layout type") }
        let length = view.bounds.width/4
        layout.itemSize = CGSize(width: length, height: length)
    }

    func updateMapView () {
        if let latitude = self.location?.latitude,
            let longitude = self.location?.longitude {
            let latDelta:CLLocationDegrees = 0.01
            let lonDelta:CLLocationDegrees = 0.01

            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
            if let mapview = mapView {
                mapview.region = region
                let annotation = MKPointAnnotation ()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)                
                DispatchQueue.main.async {
                    mapview.addAnnotation(annotation)
                }
            }
        }
    }




    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didSelectNewCollection(_ sender: Any) {
        if let pin = pin {
            PhotoDataManager.deletePhoto(for: pin)
            page += 1
            PhotoNetworkManager.getFlickrImages(for: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude), page: page)
            setupCollectionView()
        }
    }

    // MARK: Private

    fileprivate var dataSource: CollectionViewDataSource<PhotoViewController>!

    fileprivate func setupCollectionView() {
        guard let pin = pin else { return }
        let predicate = NSPredicate(format: "%K == %@", "pin", pin)
        let request = Photo.sortedFetchRequest(with: predicate)
        request.returnsObjectsAsFaults = false
        request.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.shared.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        guard let cv = collectionView else { fatalError("must have collection view") }
        dataSource = CollectionViewDataSource(collectionView: cv, cellIdentifier: "photoCell", fetchedResultsController: frc, delegate: self)
    }
}

extension PhotoViewController: CollectionViewDataSourceDelegate {
    func configure(_ cell: PhotoCollectionViewCell, for object: Photo) {
        cell.configure(for: object)
    }
}

extension PhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = dataSource.objectAtIndexPath(indexPath)
        Photo.deletePhoto(context: CoreDataManager.shared.managedObjectContext, photo: photo)
        setupCollectionView()
    }
}
