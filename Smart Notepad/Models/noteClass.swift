//
//  noteClass.swift
//  Smart Notepad
//
//  Created by ahmed talaat on 23/06/2021.
//

import Foundation
import GoogleMaps

class note:NSObject{
    var title:String!
    var noteDescription:String!
    var lat:Float!
    var lng:Float!
    var image:UIImage?
    var id:Date?
    var distanceToCurrentLocation:Double!
    var nearest:Bool?
    var address:String?
    
    init(fromDictionary dictionary: [String:Any]){
        title = dictionary["title"] as? String
        noteDescription = dictionary["noteDescription"] as? String
        lat = dictionary["lat"] as? Float
        lng = dictionary["lng"] as? Float
        image = dictionary["image"] as? UIImage
        id = dictionary["date"] as? Date
        nearest = false
        distanceToCurrentLocation = 0.0
        address = dictionary["address"] as? String

    }
}
