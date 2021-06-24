//
//  DB_Hnadler.swift
//  Smart Notepad
//
//  Created by ahmed talaat on 23/06/2021.
//

import Foundation
import RealmSwift
import GoogleMaps

class noteTable :Object{
    static var shared = noteTable()
    
    @objc dynamic var title = ""
    @objc dynamic var note_description = ""
    @objc dynamic var lat:Float = 0.0
    @objc dynamic var lng:Float = 0.0
    @objc dynamic var image = Data()
    @objc dynamic var id = Date()
    @objc dynamic var address = ""


    
    static func create(title:String,description:String,lat:Float,lng:Float,image:UIImage?,id:Date,address:String) -> noteTable{
        let note = noteTable()
        note.title = title
        note.note_description = description
        note.lat = lat
        note.lng = lng
        let imageData = Data(image?.pngData() ?? Data())
        note.image = imageData
        note.id = id
        note.address = address

        return note
    }
}

class realmDB :NSObject{
    @objc static let shared = realmDB()
    let realm = try! Realm()
    var allNotes = [note]()

    func write(title:String,description:String,lat:Float,lng:Float,image:UIImage?,id:Date,address:String) -> [note]{
        let noteObj = noteTable.create(title: title, description: description, lat: lat,lng:lng, image: image, id: id, address: address)
        
        try? realm.write{
            realm.add(noteObj)
            let single_note = note(fromDictionary: [:])
            single_note.title = title
            single_note.noteDescription = description
            single_note.lat = lat
            single_note.lng = lng
            single_note.image = image
            single_note.id = id
            single_note.address = address

            allNotes.append(single_note)
        }
        
        return allNotes
    }
    
    func read() -> [note]{
        let data = realm.objects(noteTable.self)
        allNotes = []
        
        for row in data{
            let single_note = note(fromDictionary: [:])
            single_note.title = row.title
            single_note.noteDescription = row.note_description
            single_note.lat = row.lat
            single_note.lng = row.lng
            let imgPNG = UIImage.init(data: row.image)
            single_note.image = imgPNG
            single_note.id = row.id
            single_note.address = row.address

            allNotes.append(single_note)
        }
        
        return allNotes
    }
    
    func delete(id:Date) -> [note]{
        let data = realm.objects(noteTable.self)
        for row in data {
            if row.id == id {
                try? realm.write {
                    realm.delete(row)
                }
                break
            }
        }
        
        allNotes.removeAll{ $0.id == id }
        return allNotes
    }
    
    func update(newTitle:String,newDescription:String,newLat:Float,newLng:Float,newImage:UIImage?,newId:Date,id:Date,address:String) -> [note]{
        let data = realm.objects(noteTable.self)
        for rowIndex in 0..<data.count {
            let row = data[rowIndex]
            if row.id == id {
                try! realm.write {
                    row.title = newTitle
                    row.note_description = newDescription
                    row.lat = newLat
                    row.lng = newLng
                    let imageData = Data(newImage?.pngData() ?? Data())
                    row.image = imageData
                    row.id = newId
                    row.address = address

                    allNotes.remove(at: rowIndex)
                    allNotes.insert(convertRowToNote(row: row), at: rowIndex)
                }
                
                
                break
            }
        }
        
        return allNotes
    }
    
    func convertRowToNote(row:noteTable) -> note{
        let single_note = note(fromDictionary: [:])
        single_note.title = row.title
        single_note.noteDescription = row.note_description
        single_note.lat = row.lat
        single_note.lng = row.lng
        let imgPNG = UIImage.init(data: row.image)
        single_note.image = imgPNG
        single_note.id = row.id
        single_note.address = row.address

        return single_note
    }
    
    
}
