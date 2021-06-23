//
//  AllNotesViewModel.swift
//  Smart Notepad
//
//  Created by ahmed talaat on 23/06/2021.
//

import Foundation
import RxSwift
import RxCocoa
import GoogleMaps

class allNotesViewModel{
    var allNotesSorted = BehaviorRelay<[note]>(value: [])
    private var allNotes = [note]()
    var locationManager : CLLocationManager!
    var isSorted = false
    
    func initViewModel(){
//        realmDB.shared.write(title: "String1", description: "String", lat: 30.18155597, lng: 31.34513391, image: #imageLiteral(resourceName: "pin"), id: Date().addingTimeInterval(TimeInterval(5*60*60*24)))
//
//        realmDB.shared.write(title: "String2", description: "String", lat: 40.18155597, lng: 21.34513391, image: #imageLiteral(resourceName: "pin"), id: Date().addingTimeInterval(TimeInterval(3*60*60*24)))
//
//        realmDB.shared.write(title: "String3", description: "String", lat: 30.18155597, lng: 31, image: #imageLiteral(resourceName: "pin"), id: Date().addingTimeInterval(TimeInterval(7*60*60*24)))
//
//        realmDB.shared.write(title: "String4", description: "String", lat: 30, lng: 31.34513391, image: #imageLiteral(resourceName: "pin"), id: Date().addingTimeInterval(TimeInterval(6*60*60*24)))
//
//        realmDB.shared.write(title: "String5", description: "String", lat: 10.18155597, lng: 31.34513391, image: #imageLiteral(resourceName: "pin"), id: Date().addingTimeInterval(TimeInterval(13*60*60*24)))


        

        allNotes = realmDB.shared.read()
    }
    
    
    func getNearestNote(Authorized:Bool,location:CLLocation = CLLocation(latitude: 0, longitude: 0)){
        if !Authorized {
            allNotes = allNotes.sorted(by: { $0.id! < $1.id! })
            allNotesSorted.accept(allNotes)
        }else{
            if !isSorted && allNotes.count > 0{
                allNotes = calcDistance()
                
                var sortedNotes = allNotes.sorted(by: { $0.distanceToCurrentLocation < $1.distanceToCurrentLocation })
                let nearestNote = sortedNotes[0]
                nearestNote.nearest = true
                
                sortedNotes.remove(at: 0)
                sortedNotes = sortedNotes.sorted(by: { $0.id! < $1.id! })
                allNotes = sortedNotes
                
                allNotes.insert(nearestNote, at: 0)
                
                isSorted = true
                allNotesSorted.accept(allNotes)
            }
        }
    }
    
    func calcDistance() -> [note]{
        var notesWithDistance = [note]()
        for note in allNotes{
            let newNote = note
            let location = CLLocation(latitude: CLLocationDegrees(newNote.lat), longitude: CLLocationDegrees(newNote.lng))
            let distance = location.distance(from: AllNotesViewController.currentCoordinate)
            print("\(newNote.lat)" + " //// " + "\(newNote.lng)")
            print(distance)
            print("\(newNote.id)")
            newNote.distanceToCurrentLocation = distance
            notesWithDistance.append(newNote)
        }
        return notesWithDistance
    }
}
