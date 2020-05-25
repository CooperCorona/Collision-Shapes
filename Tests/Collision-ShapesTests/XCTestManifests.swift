import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Collision_ShapesTests.allTests),
    ]
}
#endif
