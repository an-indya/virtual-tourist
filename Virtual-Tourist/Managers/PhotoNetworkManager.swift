//
//  PhotoNetworkManager.swift
//  Virtual-Tourist
//
//  Created by Anindya Sengupta on 5/6/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation
import CoreLocation

enum methodName: String {
    case GET
    case POST
    case PUT
}

class PhotoNetworkManager {

    class func getFlickrImages(for location: CLLocationCoordinate2D, page: Int) {

        var urlComponents = URLComponents()
        let url = URL(string: URLs.flickrBaseURL)!
        urlComponents.scheme = url.scheme
        urlComponents.host = url.host
        urlComponents.path = Endpoints.flickrURLPath
        urlComponents.queryItems = generateQueryItems (for: location, page: page)

        if let url = urlComponents.url {
            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = methodName.GET.rawValue

            let task = session.dataTask(with: request) {
                (data, response, error) in
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error")
                    return
                }
                do {
                    let responseJson  = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    if let urlList = parse(json: responseJson) {
                        for url in urlList {
                            if let imageURL = URL(string: url) {
                                Downloader.load(url: imageURL, completion: { data in
                                    DispatchQueue.main.async {
                                        PhotoDataManager.insertPhoto(imageURL: url, data: data, location: location)
                                    }
                                })
                            }
                        }
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
            task.resume()
        }


    }

    private class func parse(json: Any) -> [String]? {
        if let dict = json as? [String: Any],
            let photosDict = dict["photos"] as? [String: Any],
            let photos = photosDict["photo"] as? [Any]
        {
            var urls = [String]()
            for photo in photos {
                if let photoDict = photo as? [String: Any],
                    let farmId = photoDict["farm"] as? Int,
                    let serverId = photoDict["server"] as? String,
                    let id = photoDict["id"] as? String,
                    let secret = photoDict["secret"] as? String {
                        let url = "https://farm\(farmId).staticflickr.com/\(serverId)/\(id)_\(secret)_m.jpg"
                        urls.append(url)
                }
            }
            return urls
        }
        return nil
    }

    private class func generateQueryItems (for location: CLLocationCoordinate2D, page: Int) -> [URLQueryItem] {
        var queryList = [URLQueryItem]()
        queryList.append(URLQueryItem(name: "method", value: "flickr.photos.search"))
        queryList.append(URLQueryItem(name: "api_key", value: "f122596adfe163f07e762b5e1d26fde4"))
        queryList.append(URLQueryItem(name: "accuracy", value: "6"))
        queryList.append(URLQueryItem(name: "lat", value: String(describing:location.latitude)))
        queryList.append(URLQueryItem(name: "lon", value: String(describing:location.longitude)))
        queryList.append(URLQueryItem(name: "per_page", value: "20"))
        queryList.append(URLQueryItem(name: "page", value: "\(page)"))
        queryList.append(URLQueryItem(name: "format", value: "json"))
        queryList.append(URLQueryItem(name: "nojsoncallback", value: "1"))
        return queryList
    }

}

class Downloader {
    class func load(url: URL, completion: @escaping (Data) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        request.httpMethod = "GET"
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }

                do {
                    let data = try Data(contentsOf: tempLocalUrl)
                    completion(data)
                } catch {
                    print("error converting data file \(error.localizedDescription)")
                }
            } else {
                print("Failure: \(String(describing: error?.localizedDescription))")
            }
        }
        task.resume()
    }
}
