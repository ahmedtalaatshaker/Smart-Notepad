//
//  ViewController.swift
//  Smart Notepad
//
//  Created by ahmed talaat on 23/06/2021.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa


class AllNotesViewController: MainViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var notesStack: UIStackView!
    @IBOutlet weak var noNotesView: UIView!
    @IBOutlet weak var addButton: UIButton!

    var viewModel : allNotesViewModel!
    var allNotes = [note]()
    var allSortedNote = [note]()
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = allNotesViewModel()
        viewModel.initViewModel()
        
        addButton.layer.borderWidth = 2
        addButton.layer.cornerRadius = 9
        
        if self.traitCollection.userInterfaceStyle == .dark {
            addButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
            addButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else {
            addButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            addButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        bindToViewModel()
        initMap()
        // Do any additional setup after loading the view.
    }
    
    func bindToViewModel(){
        viewModel.allNotesSorted.asObservable()
            .subscribe { (notes) in
                self.freeStack()
                if notes.element?.count ?? 0 > 0{
                    self.noNotesView.isHidden = true
                    self.drawNotes(notes: notes.element ?? [])
                }else{
                    self.noNotesView.isHidden = false
                }
            }.disposed(by: disposeBag)
        
    }
    
    func drawNotes(notes:[note]){
        for note in notes{
            let note_view = noteView()
            note_view.delegate = self
            note_view.widthAnchor.constraint(equalToConstant: viewWidth).isActive = true
            note_view.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            note_view.setNote = note
            notesStack.addArrangedSubview(note_view)
        }
    }
    
    func freeStack(){
        for vi in notesStack.subviews{
            vi.removeFromSuperview()
        }
    }
    
    func initMap() {
        viewModel.locationManager = CLLocationManager()
        viewModel.locationManager.delegate = self
        viewModel.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        viewModel.locationManager.requestAlwaysAuthorization()
        viewModel.locationManager.distanceFilter = 50
        viewModel.locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locations")
        print(locations)
        if let currentLocation = locations.last {
            self.viewModel.Authorized = true
            self.viewModel.currentLocation = currentLocation
            self.viewModel.getNearestNote(Authorized: self.viewModel.Authorized)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            print("authorized")
            
        }
        
        if status == .denied {
            print("denied")
            self.viewModel.Authorized = false
            self.viewModel.getNearestNote(Authorized: viewModel.Authorized)
            self.AlertWith2ButtonsAndActionFirstButton(title: "Allow Access to Location", message: "Please Allow Access to Location to get nearest note", VC: self, B1Action: {
                if let url = URL(string:UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }, B1Title: "Settings", B2Title: "Cancel")
        }
    }
    
    @IBAction func addNote(_ sender: Any) {
        viewModel.openNoteDetails(vc: self,viewModel:viewModel)
    }
    
}

extension AllNotesViewController:noteTapped{
    func tapped(_ noteView: noteView) {
        print("tapped")
        viewModel.openNoteDetails(note:noteView.getNote!,vc: self,viewModel:viewModel)
        
    }
    
    
}
