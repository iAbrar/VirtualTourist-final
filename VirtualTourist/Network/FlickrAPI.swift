//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by imac on 8/31/20.
//  Copyright © 2020 Abrar. All rights reserved.
//

import Foundation

class FlickrAPI{
    static let flickrURL = "https://api.flickr.com/services/rest?api_key=8d927e7b549ee5c8661eb815006bcbf3&method=flickr.photos.search&format=json&per_page=10&extras=url_m&nojsoncallback=1&accuracy=11"
    

    
    
    class func downloadJSON(longitude: Double, latitude: Double, page: Int, completion: @escaping ([String],String?)->Void){
        var listOfimages = [String]()
        
        let url = "\(FlickrAPI.flickrURL)&lon=\(longitude)&lat=\(latitude)&page=\(page)"

        let request = URL(string: url)
        
        //create urlSession
        let session = URLSession(configuration: .default)
        
        // give a session task
        let task = session.dataTask(with: request!){ (data, response, error) in
            if error != nil {
                print(error!)
                DispatchQueue.main.async {
                    completion([],"error")
                }
            }
            if let dataObject = data {
                
                let decoder = JSONDecoder()
                do{
                    let decodedData = try decoder.decode(FlickrData.self, from: dataObject)
                    
                    let photos = decodedData.photos.photo
                    
                    
                    for photo in photos{
                        //                print(photo.url_m)
                        listOfimages.append(photo.url_m)
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        completion([],"error")
                    }
                }
                
            }
                
            else{
                DispatchQueue.main.async {
                    completion([],"parsing data error")
                }
            }
            completion(listOfimages,nil)
        }
        //start task
        task.resume()
        
        
    }
}
