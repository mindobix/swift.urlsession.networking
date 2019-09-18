//
//  NetworkingResourceJsonTests.swift
//  
//  Original Code Base: https://github.com/objcio/tiny-networking
//  Enchanced by Subramanian, Ganesh on 9/16/19.
//

import XCTest
@testable import URLSessionNetworking

final class NetworkingResourceJsonTests: XCTestCase {
    
    func testJsonGetUrlNoParse() {
           let url = URL(string: "http://www.example.com/example.json")!
           let resource = NetworkingResource<()>(.get, url: url)
           XCTAssertEqual(url, resource.request.url)
    }
    
    func testJsonGetUrlWithHeaderNoParse() {
        let url = URL(string: "http://www.example.com/example.json")!
        let urlToTest = URL(string: "http://www.example.com/example.json?foo=bar%20bar")!
        var header: [String: String] {
            ["Authorization": "Basic test"]
        }
        let resource = NetworkingResource<()>(.get, url: url,
                                              accept: ContentType.json,
                                              contentType: ContentType.json,
                                              body: nil,
                                              headers: header,
                                              timeOutInterval: 10,
                                              query: ["foo": "bar bar"],
                                              parse: { _, _ in .success(()) })
        XCTAssertEqual(urlToTest, resource.request.url)
    }
    
    func testJsonRequestUrlNoParse() {
        let url = URL(string: "http://www.example.com/example.json")!
        var request: URLRequest = URLRequest(url: url)
        request.setValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")
        request.setValue(ContentType.json.rawValue, forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        request.httpMethod = HttpMethod.get.rawValue
        request.httpBody = nil
        let resource = NetworkingResource<()>(request: request, parse: { _, _ in .success(()) })
        XCTAssertEqual(url, resource.request.url)
    }
    
    func testJsonPostUrlWithBodyNoParse() {
           let url = URL(string: "http://www.example.com/example.json")!
           let resource = NetworkingResource<()>(json: .post, url: url, body: [Body(name: "Alice"), Body(name: "Bob")])
           XCTAssertEqual(url, resource.request.url)
    }
    
    func testJsonGetUrlWithoutParams() {
        let url = URL(string: "http://www.example.com/example.json")!
        let resource = NetworkingResource<[String]>(json: .get, url: url)
        XCTAssertEqual(url, resource.request.url)
    }
    
    func testJsonPostUrlWithNoParams() {
        let url = URL(string: "http://www.example.com/example.json")!
        let resource = NetworkingResource<Person>(json: .post, url: url, body: [Body(name: "Alice"), Body(name: "Bob")])
        XCTAssertEqual(url, resource.request.url)
    }

    func testJsonGetUrlWithParams() {
        let url = URL(string: "http://www.example.com/example.json")!
        let resource = NetworkingResource<[String]>(json: .get, url: url, query: ["foo": "bar bar"])
        XCTAssertEqual(URL(string: "http://www.example.com/example.json?foo=bar%20bar")!, resource.request.url)
    }

    func testJsonGetUrlAdditionalParams() {
        let url = URL(string: "http://www.example.com/example.json?abc=def")!
        let resource = NetworkingResource<[String]>(json: .get, url: url, query: ["foo": "bar bar"])
        XCTAssertEqual(URL(string: "http://www.example.com/example.json?abc=def&foo=bar%20bar")!, resource.request.url)
    }
    
    func testJsonGetUrlDescription() {
        let url = URL(string: "http://www.example.com/example.json")!
        let resource = NetworkingResource<[String]>(json: .get, url: url, body: [Body(name: "Alice"), Body(name: "Bob")])
        XCTAssertEqual(resource.description, "GET http://www.example.com/example.json [{\"name\":\"Alice\"},{\"name\":\"Bob\"}]")
    }
    
    func testJsonGetUrlDefaultDescription() {
        let url = URL(string: "http://www.example.com/example.json")!
        var request = URLRequest(url: url)
        request.httpMethod = nil
        request.url = nil
        request.httpBody = nil
        let resource = NetworkingResource<()>(request: request, parse: { _, _ in .success(()) })
        XCTAssertEqual(resource.description, "GET <no url> ")
    }

    static var allTests = [
        ("testJsonGetUrlNoParse", testJsonGetUrlNoParse),
        ("testJsonGetUrlWithHeaderNoParse", testJsonGetUrlWithHeaderNoParse),
        ("testJsonRequestUrlNoParse", testJsonRequestUrlNoParse),
        ("testJsonPostUrlWithBodyNoParse", testJsonPostUrlWithBodyNoParse),
        ("testJsonGetUrlWithoutParams", testJsonGetUrlWithoutParams),
        ("testJsonPostUrlWithNoParams", testJsonPostUrlWithNoParams),
        ("testJsonGetUrlWithParams", testJsonGetUrlWithParams),
        ("testJsonGetUrlAdditionalParams", testJsonGetUrlAdditionalParams),
        ("testJsonGetUrlDescription", testJsonGetUrlDescription),
        ("testJsonGetUrlDefaultDescription", testJsonGetUrlDefaultDescription),
    ]
}

