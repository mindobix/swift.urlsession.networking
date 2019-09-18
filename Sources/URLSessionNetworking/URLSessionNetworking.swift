//
//  URLSessionNetworking.swift
//
//  Original Code Base: https://github.com/objcio/tiny-networking
//  Enchanced by Subramanian, Ganesh on 9/16/19.
//

import Foundation

extension URLSession {
    @discardableResult
    /// Loads an endpoint by creating (and directly resuming) a data task.
    ///
    /// - Parameters:
    ///   - e: The endpoint.
    ///   - onComplete: The completion handler.
    /// - Returns: The data task.
    public func load<A>(_ e: NetworkingResource<A>, onComplete: @escaping (Result<A, NetworkingError>) -> ()) -> URLSessionDataTask {
        let r = e.request
        let task = dataTask(with: r, completionHandler: { data, resp, err in
            if let err = err {
                onComplete(.failure(.genericError(err)))
                return
            }
            
            guard let h = resp as? HTTPURLResponse else {
                onComplete(.failure(.responseError))
                return
            }
            
            guard e.expectedHttpStatusCode(h.statusCode) else {
                onComplete(.failure(.httpError(statusCode: h.statusCode, response: h)))
                return
            }
            
            onComplete(e.parse(data,resp))
        })
        task.resume()
        return task
    }
}

