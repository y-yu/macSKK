// SPDX-FileCopyrightText: 2023 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

/// `BinarySearchResult`はバイナリサーチの結果
///   * `found`の場合はバイナリサーチに成功して見つかった場所と要素となり、
///   * `shouldInsertAt`の場合は要素が見つからなかったが、インサートするべきインデックスを返す
enum BinarySearchResult<Index, Element> {
    case found(Index, Element)
    case shouldInsertAt(Index)
}

extension BinarySearchResult: Equatable where Index: Equatable, Element: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.found(let lIndex, let lElement), .found(let rIndex, let rElement)):
            lIndex == rIndex && lElement == rElement
        case (.shouldInsertAt(let lIndex), .shouldInsertAt(let rIndex)):
            lIndex == rIndex
        default:
            false
        }
    }
}

extension RandomAccessCollection {
    func binarySearch(condition: (Element) -> Int) -> BinarySearchResult<Index, Element> {
        var low = startIndex
        var high = endIndex
        while low < high {
            if let mid = index(low, offsetBy: distance(from: low, to: high) / 2, limitedBy: endIndex) {
                let result = condition(self[mid])
                if result == 0 {
                    return .found(mid, self[mid])
                } else if result < 0 {
                    high = mid
                } else {
                    low = index(after: mid)
                }
            } else {
                break
            }
        }
        return .shouldInsertAt(low)
    }
    
    func binarySearch(target: Element) -> BinarySearchResult<Index, Element> where Element: Comparable {
        return binarySearch { element in
            if element == target {
                0
            } else if target > element {
                1
            } else {
                -1
            }
        }
    }    
}
