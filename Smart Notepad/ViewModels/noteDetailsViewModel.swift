//
//  noteDetailsViewModel.swift
//  Smart Notepad
//
//  Created by ahmed talaat on 24/06/2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import DKImagePickerController

class noteDetailsViewModel{
    var noteTitle = BehaviorRelay<String?>(value: "")
    var body = BehaviorRelay<String?>(value: "")
    var noteLocation = BehaviorRelay<String?>(value: "")
    var noteSelectedImage = BehaviorRelay<UIImage?>(value: UIImage())
    
    func canSaveNote(previousNote:note,image:UIImage?,address:String,lat:Float,lng:Float) -> (canSave:Bool,noteToSave:note,same:Bool){
        var canSave = false
        
        var newTitle = noteTitle.value
        newTitle = newTitle == "Note Title Here" ? "" : newTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        var newDescription = body.value
        newDescription = newDescription == "Note Body Here" ? "" : newDescription?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        
        if newTitle == "" {
            if image != nil && address != ""{
                newTitle = "Location And Image"
                canSave = true
            }else if image != nil{
                newTitle = "Image"
                canSave = true
            }else if address != ""{
                newTitle = "Location"
                canSave = true
            }else if newDescription == "" {
                canSave = false
            }else{
                newTitle = newDescription
                canSave = true
            }
        }else{
            canSave = true
        }
        
        let noteToSave = note(fromDictionary: [:])
        noteToSave.address = address
        noteToSave.id = Date()
        noteToSave.image = image
        noteToSave.lat = lat
        noteToSave.lng = lng
        noteToSave.noteDescription = newDescription
        noteToSave.title = newTitle
        
        
        return (canSave,noteToSave,compareNotes(noteToSave: noteToSave, previousNote: previousNote))
    }
    
    func compareNotes(noteToSave:note,previousNote:note) -> (Bool){
        var sameNotes = true
        if noteToSave.title != previousNote.title{
            sameNotes = false
            return sameNotes
        }else if noteToSave.noteDescription != previousNote.noteDescription{
            sameNotes = false
            return sameNotes
        }else if noteToSave.address != previousNote.address{
            sameNotes = false
            return sameNotes
        }else if noteToSave.lat != previousNote.lat{
            sameNotes = false
            return sameNotes
        }else if noteToSave.lng != previousNote.lng{
            sameNotes = false
            return sameNotes
        }else if noteToSave.image != previousNote.image{
            sameNotes = false
            return sameNotes
        }
        
        return sameNotes
    }
    
    func deleteNote(id:Date,viewModel:allNotesViewModel) -> Observable<[note]> {
        return Observable.create { (observar) -> Disposable in
            viewModel.allNotes = realmDB.shared.delete(id: id)
            viewModel.isSorted.accept(false)
            viewModel.getNearestNote(Authorized: viewModel.Authorized)
            observar.onNext(viewModel.allNotes)
            
            return Disposables.create{ }
        }
        
    }
    
    func updateNote(note:note,id:Date,viewModel:allNotesViewModel) -> Observable<[note]> {
        return Observable.create { (observar) -> Disposable in
            viewModel.allNotes = realmDB.shared.update(newTitle: note.title.trimmingCharacters(in: .whitespacesAndNewlines), newDescription: note.noteDescription.trimmingCharacters(in: .whitespacesAndNewlines), newLat: note.lat, newLng: note.lng, newImage: note.image, newId: Date(), id: id, address: note.address!.trimmingCharacters(in: .whitespacesAndNewlines))
            viewModel.isSorted.accept(false)
            viewModel.getNearestNote(Authorized: viewModel.Authorized)
            observar.onNext(viewModel.allNotes)
            
            return Disposables.create{ }

        }
    }
    
    func addNote(note:note,viewModel:allNotesViewModel) -> Observable<[note]> {
        return Observable.create { (observar) -> Disposable in
            viewModel.allNotes = realmDB.shared.write(title: note.title.trimmingCharacters(in: .whitespacesAndNewlines), description: note.noteDescription.trimmingCharacters(in: .whitespacesAndNewlines), lat: note.lat, lng: note.lng, image: note.image, id: note.id!, address: note.address!.trimmingCharacters(in: .whitespacesAndNewlines))
            viewModel.isSorted.accept(false)
            viewModel.getNearestNote(Authorized: viewModel.Authorized)
            observar.onNext(viewModel.allNotes)
            
            return Disposables.create{ }

        }
    }
    
    
    func openMaps(lat:Float = 0.0 , lng:Float = 0.0 , address :String = "",vc :UIViewController = noteDetailsViewController()){
        let target = UIStoryboard.init(name: "MapViewController", bundle: nil).instantiateInitialViewController() as! GoogleMapViewController
        
        target.lat = lat
        target.lng = lng
        target.address = address
        target.delegate = vc as? didSelectAddress

        vc.navigationController?.pushViewController(target, animated: true)

    }
    
    func initImagePicker(pickerController: DKImagePickerController) -> DKImagePickerController{
        var pickerController = DKImagePickerController()

        pickerController = DKImagePickerController()
        pickerController.singleSelect = true
        pickerController.autoCloseOnSingleSelect = false
        pickerController.showsCancelButton = true
        pickerController.maxSelectableCount = 1
        pickerController.sourceType = .both
        pickerController.assetType = .allPhotos

        return pickerController

    }

    
}
