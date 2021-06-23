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
    @objc dynamic var location = CLLocation()
    @objc dynamic var image = UIImage()
    @objc dynamic var id = Date()


    
    static func create(title:String,description:String,location:CLLocation,image:UIImage,id:Date) -> noteTable{
        let note = noteTable()
        note.title = title
        note.note_description = description
        note.location = location
        note.image = image
        note.id = id
        
        return note
    }
}

protocol newNoteAdded {
    func added(note:note)
}

class realmDB :NSObject{
    @objc static let shared = realmDB()
    let realm = try! Realm()
    var allNotes = [note]()

    var delegate :newNoteAdded?
    func write(title:String,description:String,location:CLLocation,image:UIImage,id:Date){
        let noteObj = noteTable.create(title: title, description: description, location: location, image: image, id: id)
        
        try? realm.write{
            realm.add(noteObj)
            let single_note = note(fromDictionary: [:])
            single_note.title = title
            single_note.noteDescription = description
            single_note.location = location
            single_note.image = image
            single_note.id = id

            allNotes.append(single_note)
            delegate?.added(note: single_note)
        }
    }
    
    func read(){
        let data = realm.objects(noteTable.self)
        allNotes = []
        
        for row in data{
            let single_note = note(fromDictionary: [:])
            single_note.title = row.title
            single_note.noteDescription = row.description
            single_note.location = row.location
            single_note.image = row.image
            single_note.id = row.id

            allNotes.append(single_note)
        }
    }
    
    func delete(id:Date){
        let data = realm.objects(noteTable.self)
        for row in data {
            if row.id == id {
                try! realm.write {
                    realm.delete(row)
                }
                break
            }
        }
        
        allNotes.removeAll{ $0.id == id }
    }
    
    func update(newTitle:String,newDescription:String,newLocation:CLLocation,newImage:UIImage,id:Date){
        let data = realm.objects(noteTable.self)
        for rowIndex in 0..<data.count {
            let row = data[rowIndex]
            if row.id == id {
                try! realm.write {
                    row.title = newTitle
                    row.note_description = newDescription
                    row.location = newLocation
                    row.image = newImage
                    
                    allNotes.remove(at: rowIndex)
                    allNotes.insert(convertRowToNote(row: row), at: rowIndex)
                }
                
                
                break
            }
        }
    }
    
    func convertRowToNote(row:noteTable) -> note{
        let single_note = note(fromDictionary: [:])
        single_note.title = row.title
        single_note.noteDescription = row.description
        single_note.location = row.location
        single_note.image = row.image
        single_note.id = row.id
        
        return single_note
    }
    
    
}
