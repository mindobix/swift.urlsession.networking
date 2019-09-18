//
//  HttpStubUrlRequest.swift
//  
//  Original Code Base: https://github.com/objcio/tiny-networking
//  Enchanced by Subramanian, Ganesh on 9/16/19.
//

import Foundation

struct HttpStubbedResponse {
    let response: HTTPURLResponse?
    let data: Data?
}

class HttpStubUrlRequest: URLProtocol {
    static var urls = [URL: HttpStubbedResponse]()

    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        return urls.keys.contains(url)
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override class func requestIsCacheEquivalent(_: URLRequest, to _: URLRequest) -> Bool {
        return false
    }

    override func startLoading() {
        guard let client = client, let url = request.url, let stub = HttpStubUrlRequest.urls[url] else {
            fatalError()
        }

        if let resp = stub.response {
            client.urlProtocol(self, didReceive: resp, cacheStoragePolicy: .notAllowed)
        }
        if let data = stub.data {
            client.urlProtocol(self, didLoad: data)
        }
        client.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
