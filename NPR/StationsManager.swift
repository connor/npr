//
//  StationsManager.swift
//  NPR
//
//  Created by Connor Montgomery on 1/3/19.
//  Copyright © 2019 Connor Montgomery. All rights reserved.
//

import Foundation

struct CacheKeys {
    static let currentStation = "currentStation"
}

extension Notification.Name {
    static let stationChanged = Notification.Name("stationChanged")
}

struct APIResponse : Codable {
    let version:String
    let href:String
    let items:[Station]
}

struct StationBrand : Codable {
    let band:String
    let call:String
    let frequency:String
    let marketCity:String
    let marketState:String
    let name:String
    let tagline:String
}

struct StationBrandLink : Codable {
    let rel:String
    let href:String
    let contentType:String
    
    private enum CodingKeys : String, CodingKey {
        case rel, href, contentType = "content-type"
    }
}

struct StationAttribute : Codable {
    let orgId: String
    let brand:StationBrand
}

struct Stream : Codable {
    let guid:String
    let href:String
    let isPrimaryStream:Bool
    let title:String
    let typeId:String
    let typeName:String
}

struct Donation : Codable {
    let guid:String?
    let href:String
    let title:String?
    let typeId:String
    let typeName:String
}

struct StationLinks : Codable {
    let streams:[Stream]?
    let donation:[Donation]?
    let brand:[StationBrandLink]?
}

struct Station : Codable {
    let version:String
    let href:String
    let attributes:StationAttribute
    let links:StationLinks
}

extension Station {
    public func getPrimaryStream() -> Stream? {
<<<<<<< HEAD
        guard let streams = self.links.streams, var primaryStream = streams.first else { return nil }
=======
        guard let streams = self.links.streams else { return nil }
>>>>>>> 688ca53... Integrate with MediaKeyTap.

        for stream in streams {
            if stream.isPrimaryStream {
               return stream
            }
        }
<<<<<<< HEAD
=======
        return nil
>>>>>>> 688ca53... Integrate with MediaKeyTap.
    }
    
    public func getCurrentlyListeningTitle() -> String? {
        return getPrimaryStream()?.title
    }
    
    public func getDonateObject() -> Donation? {
        return links.donation?.first
    }
}


class StationsManager: NSObject {
    static let sharedManager = StationsManager()
    
    override init() {
        let cachedStationJSON:Data? = UserDefaults.standard.object(forKey: CacheKeys.currentStation) as? Data
        if (cachedStationJSON != nil) {
            let decoder = JSONDecoder()
            if let decodedStation = try? decoder.decode(Station.self, from: cachedStationJSON!) {
                self.currentStation = decodedStation
            }
        }
    }
    
    var currentStation:Station? {
        didSet {
            let encoder = JSONEncoder()
            if let encodedStation = try? encoder.encode(self.currentStation) {
                UserDefaults.standard.set(encodedStation, forKey: CacheKeys.currentStation)
                NotificationCenter.default.post(name: .stationChanged, object: currentStation)
            }
        }
    }
    
    func fetchStreamsForZipCode(zip:String, completion: @escaping (_ stations: [Station]) -> Void) {
        let urlString = "https://www.npr.org/proxy/stationfinder/v3/stations?q=\(zip)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            do {
                let stationsData = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    var stations:[Station] = []
                    for station in stationsData.items {
                        if station.getPrimaryStream() != nil {
                            stations.append(station)
                        }
                    }
                    completion(stations)
                }
                
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
    }
}
