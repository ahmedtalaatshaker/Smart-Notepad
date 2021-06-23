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
    
    var viewModel : allNotesViewModel!
    var allNotes = [note]()
    var allSortedNote = [note]()
    var disposeBag = DisposeBag()
    static var currentCoordinate = CLLocation()
    @IBOutlet weak var notesStack: UIStackView!
    
    @IBOutlet weak var noNotesView: UIView!
    @IBOutlet weak var addButton: UIButton!
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
            AllNotesViewController.currentCoordinate = currentLocation
            print(AllNotesViewController.currentCoordinate)
            self.viewModel.getNearestNote(Authorized: true,location:AllNotesViewController.currentCoordinate)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            print("authorized")
            
        }
        if status == .denied {
            print("denied")
            self.viewModel.getNearestNote(Authorized: false)
        }
    }
    
    
}

extension AllNotesViewController:noteTapped{
    func tapped(_ noteView: noteView) {
        print("tapped")
    }
    
    
}
