//
//  URLSessionNetworkingJsonTests.swift
//
//  Original Code Base: https://github.com/objcio/tiny-networking
//  Enchanced by Subramanian, Ganesh on 9/16/19.
//

import XCTest
@testable import URLSessionNetworking

final class URLSessionNetworkingJsonTests: XCTestCase {
    override func setUp() {
       super.setUp()
       URLProtocol.registerClass(HttpStubUrlRequest.self)
    }

    override func tearDown() {
       super.tearDown()
       URLProtocol.unregisterClass(HttpStubUrlRequest.self)
    }

    func testJsonGetDataTaskRequestSuccess() {
       let url = URL(string: "http://www.example.com/example.json")!

       HttpStubUrlRequest.urls[url] = HttpStubbedResponse(response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, data: personJson.data(using: .utf8)!)

       let resource = NetworkingResource<[Person]>(json: .get, url: url)
       let expectation = self.expectation(description: "Stubbed get network call")

       let task = URLSession.shared.load(resource) { result in
           switch result {
           case let .success(payload):
               XCTAssertEqual([Person(name: "Alice"), Person(name: "Bob")], payload)
               expectation.fulfill()
           case let .failure(error):
               XCTFail(String(describing: error))
               expectation.fulfill()
           }
       }

       task.resume()

       wait(for: [expectation], timeout: 1)
    }
    
    func testJsonGetDataTaskUrlParseRequestFailure() {
        let url = URL(string: "http:/www.example.com/example.json")!

        let resource = NetworkingResource<[Person]>(json: .get, url: url)
        let expectation = self.expectation(description: "Stubbed get network call")

        let task = URLSession.shared.load(resource) { result in
            switch result {
            case .success(_):
                XCTFail()
                expectation.fulfill()
            case let .failure(.httpError(statusCode, _)):
                XCTAssertEqual(statusCode, 404)
                expectation.fulfill()
            case let .failure(error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }

        task.resume()

        wait(for: [expectation], timeout: 1)
    }
    
    func testJsonGetDataTaskUrlGenericRequestFailure() {
          let url = URL(string: "www.example.com/example.json")!

          let resource = NetworkingResource<[Person]>(json: .get, url: url)
          let expectation = self.expectation(description: "Stubbed get network call")

          let task = URLSession.shared.load(resource) { result in
              switch result {
              case .success(_):
                  XCTFail()
                  expectation.fulfill()
              case let .failure(.genericError(error as NSError)):
                XCTAssertEqual(error.code, -1002)
                expectation.fulfill()
              case let .failure(error):
                XCTFail(String(describing: error))
                expectation.fulfill()
              }
          }

          task.resume()

          wait(for: [expectation], timeout: 1)
    }
    
    func testJsonGetDataTaskResponseParseRequestFailure() {
        let url = URL(string: "http://www.example.com/example1.json")!

        HttpStubUrlRequest.urls[url] = HttpStubbedResponse(response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, data: personJsonError.data(using: .utf8)!)
        
        
        let resource = NetworkingResource<[Person]>(json: .get, url: url)
        let expectation = self.expectation(description: "Stubbed get network call")

        let task = URLSession.shared.load(resource) { result in
            switch result {
            case .success(_):
               XCTFail()
               expectation.fulfill()
            case let .failure(.parseError(error as NSError)):
               XCTAssertEqual(error.code, 4864)
               expectation.fulfill()
            case let .failure(error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }

        task.resume()

        wait(for: [expectation], timeout: 1)
    }
    
    func testJsonGetDataTaskResponseNoContentRequestSuccess() {
        let url = URL(string: "https://httpstat.us/204")!
        
        HttpStubUrlRequest.urls[url] = HttpStubbedResponse(response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, data: personNoData.data(using: .utf8)!)

        let resource = NetworkingResource<()>(.get, url: url)
        let expectation = self.expectation(description: "Stubbed get network call")

        let task = URLSession.shared.load(resource) { result in
            switch result {
            case .success(_):
               XCTAssertTrue(true)
               expectation.fulfill()
            case let .failure(error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }

        task.resume()

        wait(for: [expectation], timeout: 1)
    }
    
    func testJsonGetDataTaskDataNilRequest() {
        let url = URL(string: "http://www.example.com/examplenil.json")!
        
        HttpStubUrlRequest.urls[url] = HttpStubbedResponse(response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, data: nil)

        let resource = NetworkingResource<[Person]>(json: .get, url: url)
        let expectation = self.expectation(description: "Stubbed get network call")

        let task = URLSession.shared.load(resource) { result in
            switch result {
            case .success(_):
               XCTFail()
               expectation.fulfill()
            case .failure(.noDataError):
              XCTAssertTrue(true)
              expectation.fulfill()
            case let .failure(error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }

        task.resume()

        wait(for: [expectation], timeout: 1)
    }
    
    func testJsonGetDataTaskResponseNilRequestFailure() {
        let url = URL(string: "http://www.example.com/examplerespnil.json")!

        HttpStubUrlRequest.urls[url] = HttpStubbedResponse(response: nil, data: personJsonError.data(using: .utf8)!)

        let resource = NetworkingResource<[Person]>(json: .get, url: url)
        let expectation = self.expectation(description: "Stubbed get network call")

        let task = URLSession.shared.load(resource) { result in
            switch result {
            case .success(_):
                XCTFail()
                expectation.fulfill()
            case.failure(.responseError):
                XCTAssertTrue(true)
                expectation.fulfill()
            case let .failure(error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }

          task.resume()

          wait(for: [expectation], timeout: 1)
      }
    
    func testJsonDataTaskPostRequestSuccess() {
        let url = URL(string: "http://www.example.com/post")!

        HttpStubUrlRequest.urls[url] = HttpStubbedResponse(response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, data: postResultJson.data(using: .utf8)!)

        let resource = NetworkingResource<PostResult>(json: .post, url: url, body: [Body(name: "Alice"), Body(name: "Bob")])
        let expectation = self.expectation(description: "Stubbed post network call")

        let task = URLSession.shared.load(resource) { result in
            switch result {
            case let .success(payload):
                XCTAssertEqual(PostResult(statusCode: "000", statusMessage: "success"), payload)
                expectation.fulfill()
            case let .failure(error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }

        task.resume()

        wait(for: [expectation], timeout: 1)
    }
    
    func testJsonDataTaskPutRequestSuccess() {
        let url = URL(string: "http://www.example.com/put")!

        HttpStubUrlRequest.urls[url] = HttpStubbedResponse(response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, data: postResultJson.data(using: .utf8)!)

        let resource = NetworkingResource<()>(json: .put, url: url, body: [Body(name: "Alice"), Body(name: "Bob")])
        let expectation = self.expectation(description: "Stubbed network call")

        let task = URLSession.shared.load(resource) { result in
            switch result {
            case .success(_):
                XCTAssertTrue(true)
                expectation.fulfill()
            case let .failure(error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }

        task.resume()

        wait(for: [expectation], timeout: 1)
    }
    
    func testJsonDataTaskPatchDataNilRequestFailure() {
        let url = URL(string: "http://www.example.com/patchnil")!

        HttpStubUrlRequest.urls[url] = HttpStubbedResponse(response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, data: nil)

        let resource = NetworkingResource<PostResult>(json: .patch, url: url, body: [Body(name: "Alice"), Body(name: "Bob")])
        let expectation = self.expectation(description: "Stubbed network call")

        let task = URLSession.shared.load(resource) { result in
           switch result {
           case .success(_):
              XCTFail()
              expectation.fulfill()
           case .failure(.noDataError):
             XCTAssertTrue(true)
             expectation.fulfill()
           case let .failure(error):
               XCTFail(String(describing: error))
               expectation.fulfill()
           }
        }

        task.resume()

        wait(for: [expectation], timeout: 1)
    }
    
    func testJsonDataTaskDeleteParseRequestFailure() {
        let url = URL(string: "http://www.example.com/deleteparseerror")!

        HttpStubUrlRequest.urls[url] = HttpStubbedResponse(response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, data: personJsonError.data(using: .utf8)!)
        
        let resource = NetworkingResource<PostResult>(json: .patch, url: url, body: [Body(name: "Alice"), Body(name: "Bob")])
        let expectation = self.expectation(description: "Stubbed network call")

        let task = URLSession.shared.load(resource) { result in
            switch result {
            case .success(_):
               XCTFail()
               expectation.fulfill()
            case let .failure(.parseError(error as NSError)):
               XCTAssertEqual(error.code, 4864)
               expectation.fulfill()
            case let .failure(error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }

        task.resume()

        wait(for: [expectation], timeout: 1)
    }

    static var allTests = [
       ("testJsonGetDataTaskRequestSuccess", testJsonGetDataTaskRequestSuccess),
       ("testJsonGetDataTaskUrlParseRequestFailure", testJsonGetDataTaskUrlParseRequestFailure),
       ("testJsonGetDataTaskUrlGenericRequestFailure", testJsonGetDataTaskUrlGenericRequestFailure),
       ("testJsonGetDataTaskResponseParseRequestFailure", testJsonGetDataTaskResponseParseRequestFailure),
       ("testJsonGetDataTaskResponseNoContentRequestSuccess", testJsonGetDataTaskResponseNoContentRequestSuccess),
       ("testJsonGetDataTaskDataNilRequest", testJsonGetDataTaskDataNilRequest),
       ("testJsonGetDataTaskResponseNilRequestFailure", testJsonGetDataTaskResponseNilRequestFailure),
       ("testJsonDataTaskPostRequestSuccess", testJsonDataTaskPostRequestSuccess),
       ("testJsonDataTaskPutRequestSuccess", testJsonDataTaskPutRequestSuccess),
       ("testJsonDataTaskPatchDataNilRequestFailure", testJsonDataTaskPatchDataNilRequestFailure),
       ("testJsonDataTaskDeleteParseRequestFailure", testJsonDataTaskDeleteParseRequestFailure),
    ]
}
