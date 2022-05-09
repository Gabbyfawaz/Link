//
//  SearchResult.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation

public struct SearchResult: Codable, Hashable {
    let name: String
    let email: String
}

public struct SearchUser: Codable, Hashable {
    let name: String
}
