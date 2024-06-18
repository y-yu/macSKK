// SPDX-FileCopyrightText: 2024 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

enum EucJis2004Error: Error, CustomStringConvertible {
    case unsupported
    case convert(Int?)
    
    var description: String {
        switch self {
        case .unsupported:
            return "EucJis2004Error.unsupported"
        case .convert(let .some(code)):
            return "EucJis2004Error.convert(iconv exit code: \(code))"
        case .convert(.none):
            return "EucJis2004Error.convert"
        }
    }
}

extension Data {
    /**
     * libiconvを使ってEUC-JPの拡張であるEUC-JISX0213としてデコードする。
     */
    func eucJis2004String() throws -> String {
        if isEmpty {
            return ""
        }
        let cd = iconv_open("UTF-8".cString(using: .ascii), "EUC-JISX0213".cString(using: .ascii))
        if cd == iconv_t(bitPattern: -1) {
            logger.error("iconvの初期化に失敗しました")
            throw EucJis2004Error.unsupported
        }
        defer {
            if iconv_close(cd) == -1 {
                logger.error("iconv変換ディスクリプタの解放に失敗しました: \(errno)")
            }
        }
        var data = self
        var inLeft = data.count
        // EUC-JIS-2004は1文字で1..2バイト (ASCIIは1バイト)、UTF-8は1..4バイト (ASCIIは1バイト) なのでバッファサイズは2倍用意する
        var outLeft = data.count * 2
        var buffer = Array<CChar>(repeating: 0, count: outLeft)
        return try data.withUnsafeMutableBytes {
            var inPtr = $0.baseAddress?.assumingMemoryBound(to: CChar.self)
            try buffer.withUnsafeMutableBufferPointer {
                var outPtr = $0.baseAddress
                let ret = iconv(cd, &inPtr, &inLeft, &outPtr, &outLeft)
                if ret == -1 {
                    if errno == EBADF {
                        logger.error("iconv変換ディスクリプタの状態が異常です")
                    } else if errno == EILSEQ {
                        logger.error("入力に不正なバイト列が存在します")
                    } else if errno == E2BIG {
                        logger.error("EUC-JIS-2004からの変換先のバッファが足りません")
                    } else if errno == EINVAL {
                        logger.error("入力文字列が終端していません")
                    }
                    throw EucJis2004Error.convert(ret)
                } else if ret > 0 {
                    logger.warning("EUC-JIS-2004から処理できない文字が \(ret) 文字ありました")
                }
            }
            guard let str = String(validatingUTF8: buffer) else {
                throw EucJis2004Error.convert(.none)
            }
            return str
        }
    }
}
