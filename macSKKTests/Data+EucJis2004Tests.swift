// SPDX-FileCopyrightText: 2024 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import XCTest

@testable import macSKK

final class URLEucJis2004Tests: XCTestCase {
    func testLoad() throws {
        let fileURL = Bundle(for: Self.self).url(forResource: "euc-jis-2004", withExtension: "txt")!
        let data = try Data(contentsOf: fileURL)
        XCTAssertEqual(try data.eucJis2004String(), "川﨑")
    }

    func testLoadFail() throws {
        let fileURL = Bundle(for: Self.self).url(forResource: "SKK-JISYO.test", withExtension: "utf8")!
        let data = try Data(contentsOf: fileURL)
        XCTAssertThrowsError(try data.eucJis2004String()) {
            XCTAssertEqual($0 as! EucJis2004Error, EucJis2004Error.convert(-1))
        }
    }

    func testLoadEmpty() throws {
        let fileURL = Bundle(for: Self.self).url(forResource: "empty", withExtension: "txt")!
        let data = try Data(contentsOf: fileURL)
        XCTAssertEqual(try data.eucJis2004String(), "")
    }
}

extension EucJis2004Error: Equatable {
    public static func ==(lhs: EucJis2004Error, rhs: EucJis2004Error) -> Bool {
        switch (lhs, rhs) {
        case (.unsupported, .unsupported):
            return true
        case (.convert(let l_value), .convert(let r_value)):
            return l_value == r_value
        default:
            return false
        }
    }
}
