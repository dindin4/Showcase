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
    
    func createFirebaseUser(uuid:String, user: Dictionary<String, String>) {
        self.ref.child("users").child(uuid).setValue(user)
    }
}
