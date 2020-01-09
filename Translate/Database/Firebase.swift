//
//  Firebase.swift
//  RemindMe
//
//  Created by QUỐC on 6/27/19.
//  Copyright © 2019 QUỐC. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

struct Firebase {
    static let shared = Firebase()
    
    //MARK: - Authen
    
    func signIn(_ email:String,_ pass: String,_ completion:@escaping ((Bool)->())) {
        Auth.auth().signIn(withEmail: email, password: pass) { (Result, Error) in
            if Error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func signUp(_ email:String,_ pass:String,_ name:String,_ completion:@escaping ((Bool)->())) {
        Auth.auth().createUser(withEmail: email, password: pass) { (Result, Error) in
            if (Error == nil) {
                guard let uid = Result?.user.uid else { return }
                let values = [ID:uid, NAME: name,EMAIL:email]
                let ref = Database.database().reference().child(USER).child(uid)
                ref.updateChildValues(values, withCompletionBlock: { (Error, Database) in
                    if (Error == nil) {
                        completion(true)
                    } else {
                        completion(false)
                    }
                })
            } else {
                completion(false)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            AppRouter.shared.updateAppRouter()
        } catch {
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    func getDataUser(_ completion: @escaping ((User?)->())) {
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child(USER).child(currentId)
        ref.observeSingleEvent(of: .value) { (DataSnapshot) in
            if let data = DataSnapshot.value as? [String:AnyObject] {
                let user = User(data)
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    //MARK: - Topic
    
    func getAllTopic(_ completion: @escaping (([Topic]?)->())) {
        SVProgressHUD.show()
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child(TOPIC).child(currentId)
        ref.observe(.value) { (DataSnapshot) in
            SVProgressHUD.dismiss()
            if let data = DataSnapshot.value as? [String:AnyObject] {
                var topics = [Topic]()
                Array(data.values).forEach({ (Obj) in
                    let topic = Topic(Obj as! [String : AnyObject])
                    topics.append(topic)
                })
                completion(topics)
            } else {
                completion(nil)
            }
        }
    }
    
    func createTopic(_ title: String) {
        SVProgressHUD.show()
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child(TOPIC).child(currentId).childByAutoId()
        let value = [TITLE: title, ID: ref.key ?? kEmpty]
        ref.updateChildValues(value) { (error, data) in
            SVProgressHUD.dismiss()
            if (error != nil) {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
        }
    }
    
    func createSentence(_ text: String, _ id: String, isVN: Bool = true) {
        SVProgressHUD.show()
        FirebaseTranslate.shared.translateLanguage(text: text, isVN: isVN,  completion: { (reponse) in
            guard let currentId = Auth.auth().currentUser?.uid else { return }
            let ref = Database.database().reference().child(SENTENCES).child(currentId).child(id).childByAutoId()
            let value = [ENGLISH: reponse, VNESE: text, ID: ref.key ?? kEmpty]
            ref.updateChildValues(value) { (error, data) in
                SVProgressHUD.dismiss()
                if (error != nil) {
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
            }
        }) { (error) in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: error)
        }
    }
    
    func getAllSentence(_ id: String, _ completion: @escaping (([Sentence]?)->())) {
        SVProgressHUD.show()
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child(SENTENCES).child(currentId).child(id)
        ref.observe(.value) { (DataSnapshot) in
            SVProgressHUD.dismiss()
            if let data = DataSnapshot.value as? [String:AnyObject] {
                var sentences = [Sentence]()
                Array(data.values).forEach({ (Obj) in
                    let topic = Sentence(Obj as! [String : AnyObject])
                    sentences.append(topic)
                })
                completion(sentences)
            } else {
                completion(nil)
            }
        }
    }
    
    func getAllAnswears(_ idParent: String, _ idChild: String, _ completion: @escaping (([Sentence]?)->())) {
        SVProgressHUD.show()
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child(ANSWEARS).child(currentId).child(idParent).child(idChild)
        ref.observe(.value) { (DataSnapshot) in
            SVProgressHUD.dismiss()
            if let data = DataSnapshot.value as? [String:AnyObject] {
                var sentences = [Sentence]()
                Array(data.values).forEach({ (Obj) in
                    let topic = Sentence(Obj as! [String : AnyObject])
                    sentences.append(topic)
                })
                completion(sentences)
            } else {
                completion(nil)
            }
        }
    }
    
    func createAnswear(_ text: String, _ idParent: String, _ idChild: String, isVN: Bool = true) {
        SVProgressHUD.show()
        FirebaseTranslate.shared.translateLanguage(text: text, isVN: isVN,  completion: { (reponse) in
            guard let currentId = Auth.auth().currentUser?.uid else { return }
            let ref = Database.database().reference().child(ANSWEARS).child(currentId).child(idParent).child(idChild).childByAutoId()
            let value = [ENGLISH: reponse, VNESE: text, ID: ref.key ?? kEmpty]
            ref.updateChildValues(value) { (error, data) in
                SVProgressHUD.dismiss()
                if (error != nil) {
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
            }
        }) { (error) in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: error)
        }
    }
    
    func deleteAnswear(_ idParent: String, _ idChild: String, _ idItem: String) {
        SVProgressHUD.show()
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child(ANSWEARS).child(currentId).child(idParent).child(idChild).child(idItem)
        ref.removeValue { error, _ in
            SVProgressHUD.dismiss()
            if (error != nil) {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
        }
    }
    
    func deleteSentence(_ idParent: String, _ idChild: String) {
        SVProgressHUD.show()
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        let refANSWEARS = Database.database().reference().child(ANSWEARS).child(currentId).child(idParent).child(idChild)
        let refSENTENCES = Database.database().reference().child(SENTENCES).child(currentId).child(idParent).child(idChild)
        refANSWEARS.removeValue { error, _ in
            dispatchGroup.leave()
            if (error != nil) {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
        }
        
        refSENTENCES.removeValue { error, _ in
            dispatchGroup.leave()
            if (error != nil) {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            SVProgressHUD.dismiss()
        }
    }
    
    func deleteTopic(_ id: String) {
        SVProgressHUD.show()
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        let refTOPIC = Database.database().reference().child(TOPIC).child(currentId).child(id)
        let refANSWEARS = Database.database().reference().child(ANSWEARS).child(currentId).child(id)
        let refSENTENCES = Database.database().reference().child(SENTENCES).child(currentId).child(id)
        
        refTOPIC.removeValue { error, _ in
            dispatchGroup.leave()
            if (error != nil) {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
        }
        refANSWEARS.removeValue { error, _ in
            dispatchGroup.leave()
            if (error != nil) {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
        }
        
        refSENTENCES.removeValue { error, _ in
            dispatchGroup.leave()
            if (error != nil) {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            SVProgressHUD.dismiss()
        }
    }
}
