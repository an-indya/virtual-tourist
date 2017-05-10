//
//  PhotoCollectionViewCell.swift
//  Virtual-Tourist
//
//  Created by Anindya Sengupta on 5/6/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: AsyncImageView!
}


extension PhotoCollectionViewCell {
    func configure(for photo: Photo) {
        if let data = photo.imageData {
            image.image = UIImage(data: data)
        } else {
            image.imageURL = URL(string: photo.imageURL)
        }
    }
}
