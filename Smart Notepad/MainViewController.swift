//
//  MainViewController.swift
//  Smart Notepad
//
//  Created by ahmed talaat on 23/06/2021.
//
import UIKit
import Foundation

class MainViewController :UIViewController{
   
    let viewWidth = UIScreen.main.bounds.width - 40
    func alert(message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func keyboardWillShow(notification :Notification, scroll: UIScrollView) {
        guard let userInfo = notification.userInfo,
              let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height , right: 0)
        scroll.contentInset = contentInset
    }
    
    func keyboardWillHide(notification : Notification, scroll: UIScrollView){
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scroll.contentInset = contentInset
    }
    
    func removeObserver(scroll: UIScrollView) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addAbserver(scroll: UIScrollView)  {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) {
            notification in
            self.keyboardWillShow(notification : notification, scroll: scroll)
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) {
            notification in
            self.keyboardWillHide(notification : notification, scroll: scroll)
        }
    }
    
}
