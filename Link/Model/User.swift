//
//  User.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation
struct User: Codable {
    let username: String
    let email: String
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

