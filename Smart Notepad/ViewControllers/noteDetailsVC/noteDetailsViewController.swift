//
//  noteDetailsViewController.swift
//  Smart Notepad
//
//  Created by ahmed talaat on 23/06/2021.
//

import UIKit
import DKImagePickerController
import RxSwift
import RxCocoa

class noteDetailsViewController: MainViewController,UITextViewDelegate {

    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var body: UITextView!
    @IBOutlet weak var noteLocation: UILabel!
    @IBOutlet weak var noteAddPhotoLab: UILabel!
    @IBOutlet weak var noteSelectedImage: UIImageView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var scroll: UIScrollView!
    
    var pickerController = DKImagePickerController()
    var viewModel : allNotesViewModel!
    var noteDetailsVM :noteDetailsViewModel!
    let disposeBag = DisposeBag()
    var noteObj = note(fromDictionary: [:])
    var lat :Float = 0.0
    var lng :Float = 0.0
    var close = true

    override func viewDidLoad() {
        super.viewDidLoad()
        noteDetailsVM = noteDetailsViewModel()
        
        body.delegate = self
        body.layer.cornerRadius = 8
        
        initPlaceholder()
        bindToViewModel()
        hideKeyboardWhenTappedAround()
        fillViewWithNote()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        close = true
    }
    
    func bindToViewModel(){
        // bind vc elemnts to view model
        noteTitle.rx.text
            .orEmpty
            .bind(to: noteDetailsVM.noteTitle)
            .disposed(by:disposeBag)
        
        body.rx.text
            .orEmpty
            .bind(to: noteDetailsVM.body)
            .disposed(by:disposeBag)
        
//        noteLocation.rx.text
//            .bind(to: noteDetailsVM.noteLocation)
//            .disposed(by:disposeBag)
    }
    
    func initPlaceholder(){
        body.text = "Note Body Here"
        body.textColor = UIColor.lightGray

        noteTitle.text = "Note Title Here"
        noteTitle.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Note Body Here"
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func textFieldEndEditing(_ sender: Any) {
        if noteTitle.text?.isEmpty ?? false{
            noteTitle.text = "Note Title Here"
            noteTitle.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func textFieldBeginEditing(_ sender: Any) {
        if noteTitle.textColor == UIColor.lightGray {
            noteTitle.text = nil
            noteTitle.textColor = UIColor.black
        }
    }
    
    func fillViewWithNote(){
        if noteObj.id != nil{
            noteTitle.textColor = UIColor.black
            noteTitle.text = noteObj.title
            body.textColor = UIColor.black
            body.text = noteObj.noteDescription
            if noteObj.image != nil{
                noteAddPhotoLab.isHidden = true
                noteSelectedImage.isHidden = false
                noteSelectedImage.image = noteObj.image
            }
            noteLocation.text = noteObj.address != "" ? noteObj.address : "Add location"
            lat = noteObj.lat
            lng = noteObj.lng
        }
    }
    
    
    func canSaveNote() -> (canSave:Bool,noteToSave:note){
        let image = noteSelectedImage.isHidden ? nil : noteSelectedImage.image
        let address = (noteLocation.text?.lowercased() != "Add location".lowercased() ? noteLocation.text : "") ?? ""
        
        
        return noteDetailsVM.canSaveNote(image: image, address: address, lat: lat, lng: lng)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if close{
            let canSave_note = canSaveNote()
            
            if canSave_note.canSave{
                if noteObj.id != nil{
                    noteDetailsVM.updateNote(note: canSave_note.noteToSave,id:noteObj.id!, viewModel: viewModel).subscribe { (notes) in
                        self.navigationController?.popViewController(animated: true)
                    }.disposed(by: disposeBag)

                }else{
                    noteDetailsVM.addNote(note: canSave_note.noteToSave, viewModel: viewModel).subscribe { (notes) in
                        self.navigationController?.popViewController(animated: true)
                    }.disposed(by: disposeBag)

                }
            }
        }
    }
    
    @IBAction func deleteNote(_ sender: Any) {
        close = false
        if noteObj.id != nil {
            noteDetailsVM.deleteNote(id: noteObj.id!, viewModel: viewModel).subscribe { (notes) in
                self.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        }else{
            self.navigationController?.popViewController(animated: true)
        }

    }
    
    @IBAction func selectImage(_ sender: Any) {
        handleSelectedImage()
    }
    
    func handleSelectedImage(){
        pickerController = noteDetailsVM.initImagePicker(pickerController: pickerController)
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")

            if assets.count > 0 {
                for img in assets{
                    img.fetchOriginalImage { (image, info) in
                        if let image = image {
                            self.noteAddPhotoLab.isHidden = true
                            self.noteSelectedImage.isHidden = false
                            self.noteSelectedImage.image = image
                        }
                    }
                }
            }else{
                self.noteSelectedImage.image = nil
                self.noteAddPhotoLab.isHidden = false
                self.noteSelectedImage.isHidden = true
            }
        }
        
        self.present(pickerController, animated: true) {}

    }
    
    @IBAction func selectLocation(_ sender: Any) {
        close = false
        noteDetailsVM.openMaps(lat: lat, lng: lng, address: noteLocation.text != "Add location" ? noteLocation.text! : "", vc: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension noteDetailsViewController :didSelectAddress{
    func selectAddress(latitude: Double, longitude: Double, address: String) {
        lat = Float(latitude)
        lng = Float(longitude)
        noteLocation.text = address
        
        print(lat)
        print(lng)
        print(address)

        
    }
    
    
}
