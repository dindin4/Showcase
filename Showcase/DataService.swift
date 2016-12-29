//
//  DataService.swift
//  Showcase
//
//  Created by Dinesh Vijaykumar on 28/12/2016.
//  Copyright © 2016 Dinesh Vijaykumar. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DataService {
    static let instance = DataService()
    
    let ref = FIRDatabase.database().reference()
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = UserDefaults.standard.value(forKey: KEY_UUID) as! String
        let user = self.ref.child("users").child(uid)
        return user
    }
    
    func createFirebaseUser(uuid:String, user: Dictionary<String, String>) {
        self.ref.child("users").child(uuid).setValue(user)
    }
}
