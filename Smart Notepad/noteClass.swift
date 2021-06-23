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
    var location:CLLocation?
    var image:UIImage?
    var id:Date?

    init(fromDictionary dictionary: [String:Any]){
        title = dictionary["title"] as? String
        noteDescription = dictionary["noteDescription"] as? String
        location = dictionary["location"] as? CLLocation
        image = dictionary["image"] as? UIImage
        id = dictionary["date"] as? Date

    }
}
