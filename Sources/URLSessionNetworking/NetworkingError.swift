//
//  NetworkingError.swift
//  
//  Created by Subramanian, Ganesh on 9/16/19.
//

import Foundation

public enum NetworkingError: Error {
    case noDataError
    case httpError(statusCode: Int, response: HTTPURLResponse?)
    case unauthorized401Error
    case genericError(_ error: Error? = nil)
    case responseError
    case parseError(_ error: Error)
}
