import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NetworkingResourceJsonTests.allTests),
        testCase(URLSessionNetworkingTests.allTests),
    ]
}
#endif
