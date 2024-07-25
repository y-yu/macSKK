// SPDX-FileCopyrightText: 2024 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import XCTest

@testable import macSKK

final class RandomAccessCollectionSearchTests: XCTestCase {
    func testToBinarySearchByTarget() throws {
        let oneHundred = (0 ..< 100)
        for e in oneHundred {
            XCTAssertEqual(oneHundred.binarySearch(target: e), .found(e, e))
        }
        XCTAssertEqual(oneHundred.binarySearch(target: 9999), .shouldInsertAt(100))
    }
    
    func testToBinarySearchByCondition() throws {
        let target = 128
        var count = 0        
        let actual = (0 ..< 1024).binarySearch { e in
            count += 1
            return if e == target {
                0
            } else if target > e {
                1
            } else {
                -1
            }
        }
        XCTAssertEqual(actual, .found(128, 128))
        XCTAssertEqual(count, 3)
    }
}
