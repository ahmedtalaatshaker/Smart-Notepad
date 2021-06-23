//
//  noteView.swift
//  Smart Notepad
//
//  Created by ahmed talaat on 23/06/2021.
//

import UIKit

protocol noteTapped {
    func tapped(_ noteView:noteView)
}
class noteView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var note_description: UILabel!
    @IBOutlet weak var nearest: UILabel!
    @IBOutlet weak var noteLocation: UIImageView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var conView: UIView!

    var delegate :noteTapped?
    var noteObj = note(fromDictionary: [:])
    
    @IBInspectable var setNote: note? {
        didSet {
            noteObj = setNote!
            title.text = noteObj.title
            note_description.text = noteObj.noteDescription
            if noteObj.nearest! {
                nearest.isHidden = false
            }
            
            if noteObj.lat != 0.0 && noteObj.lng != 0.0 {
                noteLocation.isHidden = false
            }
            
            if noteObj.image != nil {
                img.isHidden = false
                img.image = noteObj.image
            }
        }
    }
    
    @IBInspectable var getNote: note? {
        get {
            return noteObj
        }
    }
    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.tapped(self)
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
        
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    func commonInit() {
        
        guard let view = Bundle(for: type(of: self)).loadNibNamed("noteView", owner: self, options: nil)?.first as? UIView else {
            return
        }
        
        frame = view.bounds
        
        self.addSubview(view)
        
        initUi()
    }
    
    
    fileprivate func initUi() {
        conView.layer.cornerRadius = 10
        conView.layer.masksToBounds = false
        conView.layer.shadowColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        conView.layer.shadowOpacity = 0.5
        conView.layer.shadowRadius = 4

    }
    
}
