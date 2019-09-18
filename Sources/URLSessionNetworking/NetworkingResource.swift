//
//  NetworkingResource.swift
//  
//  Original Code Base: https://github.com/objcio/tiny-networking
//  Enchanced by Subramanian, Ganesh on 9/16/19.
//

import Foundation

/// Built-in Content Types
public enum ContentType: String {
  case json = "application/json"
  case xml = "application/xml"
}

/// Returns `true` if `code` is in the 200..<300 range.
public func expectedHttpCode200to300(_ code: Int) -> Bool {
   return code >= 200 && code < 300
}

/// The HTTP Method
public enum HttpMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
}

/// Authentication Type
public enum AuthenticationType: String {
    case oauth, jwt, none
}

/// This describes an networking api resource returning `A` values. It contains both a `URLRequest` and a way to parse the response.
public struct NetworkingResource<A> {

    /// The request for this api
    public var request: URLRequest
    
    /// This is used to (try to) parse a response into an `A`.
    var parse: (Data?, URLResponse?) -> Result<A, NetworkingError>
    
    /// This is used to check the status code of a response.
    var expectedHttpStatusCode: (Int) -> Bool = expectedHttpCode200to300
    
    /// Create a new NetworkingResource.
    ///
    /// - Parameters:
    ///   - method: the HTTP method
    ///   - url: the endpoint's URL
    ///   - accept: the content type for the `Accept` header
    ///   - contentType: the content type for the `Content-Type` header
    ///   - body: the body of the request.
    ///   - headers: additional headers for the request
    ///   - expectedHttpStatusCode: the status code that's expected. If this returns false for a given status code, parsing fails.
    ///   - timeOutInterval: the timeout interval for his request
    ///   - query: query parameters to append to the url
    ///   - parse: this converts a response into an `A`.
    public init(_ method: HttpMethod,
                url: URL,
                accept: ContentType? = nil,
                contentType: ContentType? = nil,
                body: Data? = nil,
                headers: [String:String] = [:],
                expectedHttpStatusCode: @escaping (Int) -> Bool = expectedHttpCode200to300,
                timeOutInterval: TimeInterval = 10,
                query: [String:String] = [:],
                parse: @escaping (Data?, URLResponse?) -> Result<A, NetworkingError>) {
        var requestUrl : URL
        if query.isEmpty {
            requestUrl = url
        } else {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            comps.queryItems = comps.queryItems ?? []
            comps.queryItems!.append(contentsOf: query.map { URLQueryItem(name: $0.0, value: $0.1) })
            requestUrl = comps.url!
        }
        request = URLRequest(url: requestUrl)
        if let a = accept {
            request.setValue(a.rawValue, forHTTPHeaderField: "Accept")
        }
        if let ct = contentType {
            request.setValue(ct.rawValue, forHTTPHeaderField: "Content-Type")
        }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.timeoutInterval = timeOutInterval
        request.httpMethod = method.rawValue

        // body *needs* to be the last property that we set, because of this bug:
        // https://bugs.swift.org/browse/SR-6687
        
        request.httpBody = body

        self.expectedHttpStatusCode = expectedHttpStatusCode
        self.parse = parse
    }
    
    
    /// Creates a new NetworkingResource from a request
    ///
    /// - Parameters:
    ///   - request: the URL request
    ///   - expectedHttpStatusCode: the status code that's expected. If this returns false for a given status code, parsing fails.
    ///   - parse: this converts a response into an `A`.
    public init(request: URLRequest,
                expectedHttpStatusCode: @escaping (Int) -> Bool = expectedHttpCode200to300,
                parse: @escaping (Data?, URLResponse?) -> Result<A, NetworkingError>) {
        self.request = request
        self.expectedHttpStatusCode = expectedHttpStatusCode
        self.parse = parse
    }
}

// MARK: - CustomStringConvertible
extension NetworkingResource: CustomStringConvertible {
    public var description: String {
        var body = ""
        if let httpBody = request.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            body = bodyString
        }
        var url = "<no url>"
        var httpMethod = "GET"
        if let requestUrl = request.url {
            url = requestUrl.absoluteString
        }
        if let method = request.httpMethod {
            httpMethod = method
        }

        return "\(httpMethod) \(url) \(body)"
    }
}

// MARK: - where A == ()
extension NetworkingResource where A == () {
    /// Creates a new endpoint without a parse function.
    ///
    /// - Parameters:
    ///   - method: the HTTP method
    ///   - url: the endpoint's URL
    ///   - accept: the content type for the `Accept` header
    ///   - headers: additional headers for the request
    ///   - expectedHttpStatusCode: the status code that's expected. If this returns false for a given status code, parsing fails.
    ///   - query: query parameters to append to the url
    public init(_ method: HttpMethod,
                url: URL,
                accept: ContentType? = nil,
                contentType: ContentType? = nil,
                headers: [String:String] = [:],
                expectedHttpStatusCode: @escaping (Int) -> Bool = expectedHttpCode200to300,
                query: [String:String] = [:]) {
        self.init(method, url: url, accept: accept, contentType: contentType, headers: headers,
                  expectedHttpStatusCode: expectedHttpStatusCode,
                  query: query, parse: { _, _ in .success(()) })
    }

    /// Creates a new endpoint without a parse function.
    ///
    /// - Parameters:
    ///   - json: the HTTP method
    ///   - url: the endpoint's URL
    ///   - accept: the content type for the `Accept` header
    ///   - body: the body of the request. This gets encoded using a default `JSONEncoder` instance.
    ///   - headers: additional headers for the request
    ///   - expectedHttpStatusCode: the status code that's expected. If this returns false for a given status code, parsing fails.
    ///   - query: query parameters to append to the url
    public init<B: Encodable>(json method: HttpMethod,
                              url: URL,
                              body: B,
                              headers: [String:String] = [:],
                              expectedHttpStatusCode: @escaping (Int) -> Bool = expectedHttpCode200to300,
                              query: [String:String] = [:]) {
        let b = try! JSONEncoder().encode(body)
        self.init(method, url: url, accept: .json, contentType: .json, body: b, headers: headers,
                  expectedHttpStatusCode: expectedHttpStatusCode, query: query, parse: { _, _ in .success(()) })
    }
}

// MARK: - where A: Decodable
extension NetworkingResource where A: Decodable {
    /// Creates a new NetworkingResource.
    ///
    /// - Parameters:
    ///   - method: the HTTP method
    ///   - url: the endpoint's URL
    ///   - accept: the content type for the `Accept` header
    ///   - headers: additional headers for the request
    ///   - expectedHttpStatusCode: the status code that's expected. If this returns false for a given status code, parsing fails.
    ///   - query: query parameters to append to the url
    ///   - decoder: the decoder that's used for decoding `A`s.
    public init(json method: HttpMethod,
                url: URL,
                accept: ContentType = .json,
                headers: [String: String] = [:],
                expectedHttpStatusCode: @escaping (Int) -> Bool = expectedHttpCode200to300,
                query: [String: String] = [:],
                decoder: JSONDecoder = JSONDecoder()) {
        self.init(method, url: url, accept: accept, body: nil, headers: headers,
                  expectedHttpStatusCode: expectedHttpStatusCode, query: query) { data, _ in
            guard let data = data, !data.isEmpty else {
                return .failure(.noDataError)
            }
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(A.self, from: data)
                return .success(json)
            } catch {
                return .failure(.parseError(error))
            }
        }
    }

    /// Creates a new NetworkingResource.
    ///
    /// - Parameters:
    ///   - method: the HTTP method
    ///   - url: the endpoint's URL
    ///   - accept: the content type for the `Accept` header
    ///   - body: the body of the request. This is encoded using a default encoder.
    ///   - headers: additional headers for the request
    ///   - expectedHttpStatusCode: the status code that's expected. If this returns false for a given status code, parsing fails.
    ///   - query: query parameters to append to the url
    ///   - decoder: the decoder that's used for decoding `A`s.
    public init<B: Encodable>(json method: HttpMethod,
                              url: URL,
                              accept: ContentType = .json,
                              body: B? = nil,
                              headers: [String: String] = [:],
                              expectedHttpStatusCode: @escaping (Int) -> Bool = expectedHttpCode200to300,
                              query: [String: String] = [:],
                              decoder: JSONDecoder = JSONDecoder()) {
        let b = body.map { try! JSONEncoder().encode($0) }
        self.init(method, url: url, accept: accept, contentType: .json, body: b, headers: headers,
                  expectedHttpStatusCode: expectedHttpStatusCode, query: query) { data, _ in
            guard let data = data, !data.isEmpty else {
                return .failure(.noDataError)
            }
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(A.self, from: data)
                return .success(json)
            } catch {
                return .failure(.parseError(error))
            }
        }
    }
}
