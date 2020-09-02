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
        
        func sendError(_ error: String) {
            DispatchQueue.main.async {
                completion([],error)
            }
        }
        
        var listOfimages = [String]()
        
        let url = "\(FlickrAPI.flickrURL)&lon=\(longitude)&lat=\(latitude)&page=\(page)"
        
        let request = URL(string: url)
        
        //create urlSession
        let session = URLSession(configuration: .default)
        
        // give a session task
        let task = session.dataTask(with: request!){ (data, response, error) in
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(error!.localizedDescription)
                return
            }
            
            guard let dataObject = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            
            let decoder = JSONDecoder()
            do{
                let decodedData = try decoder.decode(FlickrData.self, from: dataObject)
                
                let photos = decodedData.photos.photo
                
                for photo in photos{
                    
                    listOfimages.append(photo.url_m)
                }
                
            } catch {
                
                completion([],"Error in parsing data")
            }
            
            completion(listOfimages,nil)
        }
        //start task
        task.resume()
        
    }
}
