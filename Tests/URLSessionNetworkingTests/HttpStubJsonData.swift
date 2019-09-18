//
//  HttpStubJsonData.swift
//  
//  Original Code Base: https://github.com/objcio/tiny-networking
//  Enchanced by Subramanian, Ganesh on 9/16/19.
//

import Foundation

struct Person: Codable, Equatable {
    var name: String
}

let personJson = """
[
    {
        "name": "Alice"
    },
    {
        "name": "Bob"
    }
]
"""

let personJsonError = """
[
    {
        "name": "Alice"
    },
    {
      adasd~``
]
"""

let personNoData = ""

struct Body: Codable, Equatable {
    var name: String
}

let bodyJson = """
[
    {
        "name": "Alice"
    },
    {
        "name": "Bob"
    }
]
"""

struct PostResult: Codable, Equatable {
    var statusCode: String
    var statusMessage: String
}

let postResultJson = """
    {
        "statusCode": "000",
        "statusMessage": "success"
    }
"""
