// CollectionExtensionsTests.swift - Copyright 2025 SwifterSwift

@testable import SwifterSwift
import XCTest

final class CollectionExtensionsTests: XCTestCase {
    private enum TestData {
        static let collection = [1, 2, 3, 4, 5]
    }

    func testFullRange() {
        XCTAssertEqual(TestData.collection.fullRange, 0..<5)
        XCTAssertEqual([Int]().fullRange, 0..<0)
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
    func testForEachInParallel() async {
        actor Counter {
            private(set) var count = 0

            func increment() { count += 1 }
        }

        let expectation = XCTestExpectation(description: "forEachInParallel")

        let counter = Counter()
        TestData.collection.forEachInParallel { [counter] in
            XCTAssert(TestData.collection.contains($0))
            Task {
                await counter.increment()
                if await counter.count == TestData.collection.count {
                    expectation.fulfill()
                }
            }
        }
        await fulfillment(of: [expectation], timeout: 1)
        let count = await counter.count
        XCTAssertEqual(count, TestData.collection.count)
    }

    func testSafeSubscript() {
        XCTAssertNotNil(TestData.collection[safe: 2])
        XCTAssertEqual(TestData.collection[safe: 2], 3)
        XCTAssertNil(TestData.collection[safe: 10])
    }

    #if !os(Linux) && !os(Android)
    func testIndicesWhere() {
        let array: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let indices = array.indices { $0 % 2 == 0 }
        XCTAssertEqual(indices, [0, 2, 4, 6, 8])
        let emptyArray: [Int] = []
        let emptyIndices = emptyArray.indices { $0 % 2 == 0 }
        XCTAssertNil(emptyIndices)
    }
    #endif

    func testForEachSlice() {
        // A slice with value zero
        var iterations = 0
        var array: [String] = ["james", "irving", "jordan", "jonshon", "iverson", "shaq"]
        array.forEach(slice: 0) { _ in
            iterations += 1
        }
        XCTAssertEqual(iterations, 0)

        // A slice that divide the total evenly
        array = ["james", "irving", "jordan", "jonshon", "iverson", "shaq"]
        array.forEach(slice: 2) { sliceArray in
            switch iterations {
            case 0: XCTAssertEqual(sliceArray, ["james", "irving"])
            case 1: XCTAssertEqual(sliceArray, ["jordan", "jonshon"])
            case 2: XCTAssertEqual(sliceArray, ["iverson", "shaq"])
            default: break
            }
            iterations += 1
        }
        XCTAssertEqual(iterations, 3)

        // A slice that does not divide the total evenly
        iterations = 0
        array = ["james", "irving", "jordan", "jonshon", "iverson", "shaq", "bird"]
        array.forEach(slice: 2) { sliceArray in
            switch iterations {
            case 0: XCTAssertEqual(sliceArray, ["james", "irving"])
            case 1: XCTAssertEqual(sliceArray, ["jordan", "jonshon"])
            case 2: XCTAssertEqual(sliceArray, ["iverson", "shaq"])
            case 3: XCTAssertEqual(sliceArray, ["bird"])
            default: break
            }
            iterations += 1
        }
        XCTAssertEqual(iterations, 4)

        // A slice greater than the array count
        iterations = 0
        array = ["james", "irving", "jordan", "jonshon"]
        array.forEach(slice: 6) { sliceArray in
            XCTAssertEqual(sliceArray, ["james", "irving", "jordan", "jonshon"])
            iterations += 1
        }
        XCTAssertEqual(iterations, 1)

        iterations = 0

        // Empty array
        array = []
        array.forEach(slice: 1) { _ in
            XCTFail("Should not find any slices")
            iterations += 1
        }
        XCTAssertEqual(iterations, 0)
    }

    func testGroupBySize() {
        // A slice with value zero
        var array: [String] = ["james", "irving", "jordan", "jonshon", "iverson", "shaq"]
        var slices = array.group(by: 0)
        XCTAssertNil(slices)

        // A slice that divide the total evenly
        array = ["james", "irving", "jordan", "jonshon", "iverson", "shaq"]
        slices = array.group(by: 2)
        XCTAssertNotNil(slices)
        XCTAssertEqual(slices?.count, 3)

        // A slice that does not divide the total evenly
        array = ["james", "irving", "jordan", "jonshon", "iverson", "shaq", "bird"]
        slices = array.group(by: 2)
        XCTAssertNotNil(slices)
        XCTAssertEqual(slices?.count, 4)

        // A slice greater than the array count
        array = ["james", "irving", "jordan", "jonshon"]
        slices = array.group(by: 6)
        XCTAssertNotNil(slices)
        XCTAssertEqual(slices?.count, 1)
    }

    func testIndices() {
        XCTAssertEqual([].indices(of: 5), [])
        XCTAssertEqual([1, 1, 2, 3, 4, 1, 2, 1].indices(of: 5), [])
        XCTAssertEqual([1, 1, 2, 3, 4, 1, 2, 1].indices(of: 1), [0, 1, 5, 7])
        XCTAssertEqual(["a", "b", "c", "b", "4", "1", "2", "1"].indices(of: "b"), [1, 3])
    }

    func testAverage() {
        XCTAssertEqual([1.2, 2.3, 3.4, 4.5, 5.6].average(), 3.4)
        XCTAssertEqual([Double]().average(), 0)

        XCTAssertEqual([1, 2, 3, 4, 5].average(), 3)
        XCTAssertEqual([Int]().average(), 0)
    }

    func testAdjacentPairsWithOddNumberOfElementsInCollection() {
        let pairs = Array([1, 2, 3].adjacentPairs())
        XCTAssertEqual(pairs.count, 3)
        XCTAssertEqual(pairs[0].0, 1)
        XCTAssertEqual(pairs[0].1, 2)
        XCTAssertEqual(pairs[1].0, 1)
        XCTAssertEqual(pairs[1].1, 3)
        XCTAssertEqual(pairs[2].0, 2)
        XCTAssertEqual(pairs[2].1, 3)
    }

    func testAdjacentPairsWithEvenNumberOfElementsInCollection() {
        let pairs = Array([1, 2].adjacentPairs())
        XCTAssertEqual(pairs.count, 1)
        XCTAssertEqual(pairs[0].0, 1)
        XCTAssertEqual(pairs[0].1, 2)
    }

    func testAdjacentPairsWithEmptyCollection() {
        let pairs = Array([Int]().adjacentPairs())
        XCTAssertEqual(pairs.count, 0)
    }
}
