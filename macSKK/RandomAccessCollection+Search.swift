// SPDX-FileCopyrightText: 2023 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

extension RandomAccessCollection {
    func binarySearchIndex(condition: (Element) -> Int) -> Index? {
        var low = startIndex
        var high = endIndex
        while low < high {
            if let mid = index(low, offsetBy: distance(from: low, to: high) / 2, limitedBy: endIndex) {
                let result = condition(self[mid])
                if result == 0 {
                    return mid
                } else if result < 0 {
                    high = mid
                } else {
                    low = index(after: mid)
                }
            } else {
                break
            }
        }
        return nil
    }
    
    func binarySearch(condition: (Element) -> Int) -> Element? {
        return binarySearchIndex(condition: condition).map { self[$0] }
    }
    
    func binarySearch(target: Element) -> Element? where Element: Comparable {
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
