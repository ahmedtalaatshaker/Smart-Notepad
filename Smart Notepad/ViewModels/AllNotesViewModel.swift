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
    var allNotes = [note]()
    var locationManager : CLLocationManager!
    var isSorted = BehaviorRelay<Bool>(value: false)

    var Authorized = false
    var currentLocation = CLLocation()
    var disposeBag = DisposeBag()
    
    func initViewModel(){
        self.isSorted
            .observe(on: MainScheduler.instance)
            .take(while: {$0 != (0 != 0)})
            .subscribe { (value) in
                if !(value.element ?? false){
                    print("getNearestNote")
                    self.getNearestNote(Authorized: self.Authorized)
                }
            }.disposed(by: disposeBag)


        allNotes = realmDB.shared.read()
    }
    
    func getNearestNote(Authorized:Bool){
        if !Authorized {
            setAllNotesNotNearest()
            isSorted.accept(false)
            allNotes = allNotes.sorted(by: { $0.id! > $1.id! })
            allNotesSorted.accept(allNotes)
        }else{
            if !isSorted.value && allNotes.count > 0{
                isSorted.accept(true)
                allNotes = calcDistance()
                
                var sortedNotes = allNotes.sorted(by: { $0.distanceToCurrentLocation < $1.distanceToCurrentLocation })
                 
                let nearestNote = sortedNotes[0]
                if nearestNote.address != ""{
                    nearestNote.nearest = true
                }
                
                sortedNotes.remove(at: 0)
                sortedNotes = sortedNotes.sorted(by: { $0.id! > $1.id! })
                allNotes = sortedNotes
                
                allNotes.insert(nearestNote, at: 0)
                
                allNotesSorted.accept(allNotes)
            }else if allNotes.count == 0 {
                allNotesSorted.accept(allNotes)
            }
        }
    }
    
    func calcDistance() -> [note]{
        var notesWithDistance = [note]()
        for note in allNotes{
            let newNote = note
            let location = CLLocation(latitude: CLLocationDegrees(newNote.lat), longitude: CLLocationDegrees(newNote.lng))
            let distance = location.distance(from: currentLocation)
            newNote.distanceToCurrentLocation = distance
            newNote.nearest = false
            notesWithDistance.append(newNote)
        }
        return notesWithDistance
    }
    
    func setAllNotesNotNearest(){
        for note in allNotes{
            note.nearest = false
        }
    }
    
    func openNoteDetails(note:note = note(fromDictionary: [:]),vc:UIViewController,viewModel:allNotesViewModel){
        let target = UIStoryboard.init(name: "noteDetailsViewController", bundle: nil).instantiateViewController(withIdentifier: "noteDetailsViewController") as! noteDetailsViewController
        
        target.noteObj = note
        target.viewModel = viewModel
        vc.navigationController?.pushViewController(target, animated: true)
    }
    
}
