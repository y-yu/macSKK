// SPDX-FileCopyrightText: 2023 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import XCTest

@testable import macSKK

final class StateTests: XCTestCase {
    func testComposingStateAppendText() throws {
        var state = ComposingState(
            isShift: true, text: ["あ", "い"], okuri: nil, romaji: "", cursor: nil)
        state = state.appendText(Romaji.Moji(firstRomaji: "u", kana: "う"))
        XCTAssertEqual(state.string(for: .hiragana, convertHatsuon: false), "あいう")
        state = state.moveCursorLeft()
        XCTAssertEqual(state.cursor, 2)
        state = state.appendText(Romaji.Moji(firstRomaji: "e", kana: "え"))
        XCTAssertEqual(state.string(for: .hiragana, convertHatsuon: false), "あいえう")
        XCTAssertEqual(state.cursor, 3)
        state = state.moveCursorRight()
        XCTAssertNil(state.cursor, "末尾まで移動したらカーソルはnilになる")
    }

    func testComposingStateDropLast() {
        let state = ComposingState(
            isShift: true, text: ["あ", "い"], okuri: nil, romaji: "", cursor: nil)
        XCTAssertEqual(state.dropLast()?.text, ["あ"])
    }

    func testComposingStateDropLastYokuon() {
        let state = ComposingState(
            isShift: true, text: ["き", "ゃ"], okuri: nil, romaji: "", cursor: nil)
        XCTAssertEqual(state.dropLast()?.text, ["き"])
    }

    func testComposingStateDropLastEmpty() {
        var state = ComposingState(isShift: true, text: [], okuri: nil, romaji: "", cursor: nil)
        XCTAssertNil(state.dropLast())
        state = ComposingState(isShift: true, text: [], okuri: nil, romaji: "k", cursor: nil)
        XCTAssertNil(state.dropLast())
        state = ComposingState(isShift: true, text: ["あ"], okuri: nil, romaji: "", cursor: nil)
        XCTAssertNotNil(state.dropLast())
    }

    func testComposingStateDropLastTextAndRomaji() {
        let state = ComposingState(isShift: true, text: ["あ"], okuri: nil, romaji: "k", cursor: nil)
        let state2 = state.dropLast()
        XCTAssertEqual(state2?.romaji, "")
        let state3 = state2?.dropLast()
        XCTAssertNotNil(state3)
        XCTAssertNil(state3?.dropLast())
    }

    func testComposingStateDropLastTextAndOkuri() {
        let state = ComposingState(isShift: true, text: ["あ"], okuri: [], romaji: "", cursor: nil)
        let state2 = state.dropLast()
        XCTAssertNil(state2?.okuri)
    }

    func testComposingStateDropLastCursor() {
        var state = ComposingState(
            isShift: true, text: ["あ", "い"], okuri: nil, romaji: "", cursor: 1)
        XCTAssertEqual(state.dropLast()?.text, ["い"])
        state = ComposingState(
            isShift: true, text: ["あ", "い"], okuri: nil, romaji: "", cursor: 0)
        XCTAssertEqual(state.dropLast()?.text, ["あ", "い"], "カーソル位置が先頭のときはなにも削除しない")
    }

    func testComposingStateSubText() {
        var state = ComposingState(
            isShift: true, text: ["あ", "い"], okuri: nil, romaji: "", cursor: 1)
        XCTAssertEqual(state.subText(), ["あ"])
        state.cursor = nil
        XCTAssertEqual(state.subText(), ["あ", "い"])
    }

    func testComposingStateTrim() {
        let state = ComposingState(
            isShift: true, text: ["あ"], okuri: nil, romaji: "n", cursor: nil).trim()
        XCTAssertEqual(state.text, ["あ", "ん"])
        XCTAssertNil(state.okuri)
    }

    func testComposingStateTrimOkuriN() {
        let state = ComposingState(
            isShift: true, text: ["く", "や"], okuri: [], romaji: "n", cursor: nil).trim()
        XCTAssertEqual(state.trim().text, ["く", "や"])
        XCTAssertEqual(state.trim().okuri, [Romaji.n])
    }

    func testComposingStateYomi() {
        var state = ComposingState(
            isShift: true,
            text: ["あ", "い"],
            okuri: nil,
            romaji: "",
            cursor: nil)
        XCTAssertEqual(state.yomi(for: .hiragana), "あい")
        XCTAssertEqual(state.yomi(for: .katakana), "あい")
        XCTAssertEqual(state.yomi(for: .hankaku), "あい")
        XCTAssertEqual(state.yomi(for: .direct), "あい")
        state.cursor = 1
        XCTAssertEqual(state.yomi(for: .hiragana), "あ")
        state.okuri = [Romaji.Moji(firstRomaji: "u", kana: "う")]
        state.cursor = nil
        XCTAssertEqual(state.yomi(for: .katakana), "あいu")
    }

    func testComposingStateYomiAbbrevCursor() {
        var state = ComposingState(
            isShift: true,
            text: ["a", "b"],
            okuri: nil,
            romaji: "",
            cursor: nil)
        XCTAssertEqual(state.yomi(for: .direct), "ab")
        state.cursor = 1
        XCTAssertEqual(state.yomi(for: .direct), "a")
    }

    func testComposingStateMoveCorsorEmptyText() {
        var state = ComposingState(isShift: true, text: [], okuri: nil, romaji: "", cursor: nil)
        state = state.moveCursorLeft()
        XCTAssertNil(state.cursor)
        state = state.moveCursorRight()
        XCTAssertNil(state.cursor)
        state = state.moveCursorFirst()
        XCTAssertNil(state.cursor)
        state = state.moveCursorLast()
        XCTAssertNil(state.cursor)
    }

    func testComposingStateMoveCorsor() {
        var state = ComposingState(isShift: true, text: ["あ", "い"], okuri: nil, romaji: "", cursor: nil)
        state = state.moveCursorLeft()
        XCTAssertEqual(state.cursor, 1)
        state = state.moveCursorRight()
        XCTAssertNil(state.cursor)
        state = state.moveCursorFirst()
        XCTAssertEqual(state.cursor, 0)
        state = state.moveCursorLast()
        XCTAssertNil(state.cursor)
    }

    func testComposingStateDisplayTextSimple() {
        let composingState = ComposingState(isShift: true, text: ["お", "い"], romaji: "")
        XCTAssertEqual(composingState.markedTextElements(inputMode: .hiragana), [.markerCompose, .plain("おい")])
    }

    func testComposingStateDisplayTextRomaji() {
        let composingState = ComposingState(isShift: false, text: [], okuri: nil, romaji: "k")
        XCTAssertEqual(composingState.markedTextElements(inputMode: .hiragana), [.plain("k")])
    }

    func testComposingStateDisplayTextOkuri() {
        let composingState = ComposingState(isShift: true, text: ["お", "い"], okuri: [], romaji: "s")
        XCTAssertEqual(composingState.markedTextElements(inputMode: .hiragana), [.markerCompose, .plain("おい*s")])
    }

    func testComposingStateDisplayTextCursor() {
        let composingState = ComposingState(isShift: true, text: ["お", "い"], okuri: [], romaji: "s", cursor: 1)
        XCTAssertEqual(composingState.markedTextElements(inputMode: .hiragana), [.markerCompose, .plain("お*s"), .cursor, .plain("い")])
    }

    func testComposingStateRemain() {
        var composingState = ComposingState(isShift: true, text: ["あ", "い"], okuri: [], romaji: "", cursor: nil)
        XCTAssertNil(composingState.remain()) // カーソルがnilのときはnil
        composingState = ComposingState(isShift: true, text: ["あ", "い"], okuri: [], romaji: "", cursor: 0)
        XCTAssertEqual(composingState.remain(), ["あ", "い"])
        composingState = ComposingState(isShift: true, text: ["あ", "い"], okuri: [], romaji: "", cursor: 1)
        XCTAssertEqual(composingState.remain(), ["い"])
    }

    func testSelectingStateFixedText() throws {
        let selectingState = SelectingState(
            prev: SelectingState.PrevState(
                mode: .hiragana,
                composing: ComposingState(isShift: true, text: ["あ"], romaji: "")),
            yomi: "あ",
            candidates: [Candidate("亜")],
            candidateIndex: 0,
            cursorPosition: .zero,
            remain: nil
        )
        XCTAssertEqual(selectingState.fixedText, "亜")
    }

    func testSelectingStateFixedTextOkuriari() throws {
        let selectingState = SelectingState(
            prev: SelectingState.PrevState(
                mode: .hiragana,
                composing: ComposingState(
                    isShift: true,
                    text: ["あ"],
                    okuri: [Romaji.Moji(firstRomaji: "r", kana: "る")],
                    romaji: ""
                )
            ),
            yomi: "あ",
            candidates: [Candidate("有")],
            candidateIndex: 0,
            cursorPosition: .zero,
            remain: nil
        )
        XCTAssertEqual(selectingState.fixedText, "有る")
    }

    func testSelectingStateMarkedTextElements() {
        let composingState = ComposingState(isShift: true, text: ["お"], romaji: "")
        var selectingState = SelectingState(prev: SelectingState.PrevState(mode: .hiragana, composing: composingState),
                                            yomi: "お",
                                            candidates: [Candidate("尾")],
                                            candidateIndex: 0,
                                            cursorPosition: .zero,
                                            remain: nil)
        XCTAssertEqual(selectingState.markedTextElements(inputMode: .hiragana), [.markerSelect, .emphasized("尾")])
        selectingState = SelectingState(prev: SelectingState.PrevState(mode: .hiragana, composing: composingState),
                                            yomi: "お",
                                            candidates: [Candidate("尾")],
                                            candidateIndex: 0,
                                            cursorPosition: .zero,
                                            remain: ["か", "き"])
        XCTAssertEqual(selectingState.markedTextElements(inputMode: .hiragana), [.markerSelect, .emphasized("尾"), .cursor, .plain("かき")])
    }

    func testSelectingStateOkuri() {
        var selectingState = SelectingState(
            prev: SelectingState.PrevState(
                mode: .hiragana,
                composing: ComposingState(
                    isShift: true,
                    text: ["お"],
                    romaji: ""
                )
            ),
            yomi: "お",
            candidates: [Candidate("尾")],
            candidateIndex: 0,
            cursorPosition: .zero,
            remain: nil
        )
        XCTAssertEqual(selectingState.okuri, nil)

        selectingState = SelectingState(
            prev: SelectingState.PrevState(
                mode: .hiragana,
                composing: ComposingState(
                    isShift: true,
                    text: ["あ"],
                    okuri: [Romaji.Moji(firstRomaji: "r", kana: "る")],
                    romaji: ""
                )
            ),
            yomi: "あ",
            candidates: [Candidate("有")],
            candidateIndex: 0,
            cursorPosition: .zero,
            remain: nil
        )
        XCTAssertEqual(selectingState.okuri, "る")
    }

    func testRegisterStateAppendText() throws {
        var state = RegisterState(
            prev: RegisterState.PrevState(
                mode: .hiragana, composing: ComposingState(isShift: true, text: ["あ"], okuri: nil, romaji: "")),
            yomi: "あ", text: "")
        state = state.appendText("あ")
        XCTAssertEqual(state.appendText("い").text, "あい")
        state = state.moveCursorLeft()
        XCTAssertEqual(state.cursor, 0)
        state = state.appendText("い")
        XCTAssertEqual(state.text, "いあ")
        XCTAssertEqual(state.cursor, 1)
        state = state.appendText("しゅ")
        XCTAssertEqual(state.text, "いしゅあ")
        XCTAssertEqual(state.cursor, 3)
    }

    func testRegisterStateDropLast() throws {
        var state = RegisterState(
            prev: RegisterState.PrevState(
                mode: .hiragana, composing: ComposingState(isShift: true, text: ["あ"], okuri: nil, romaji: "")),
            yomi: "あ", text: "あいう", cursor: nil)
        state = state.dropLast()
        XCTAssertEqual(state.text, "あい")
        state = state.moveCursorLeft().dropLast()
        XCTAssertEqual(state.text, "い")
        XCTAssertEqual(state.cursor, 0)
    }

    func testUnregisterState() throws {
        let prevSelectingState = SelectingState(
            prev: SelectingState.PrevState(
                mode: .hiragana,
                composing: ComposingState(
                    isShift: true,
                    text: ["あ"],
                    okuri: [Romaji.Moji(firstRomaji: "r", kana: "る")],
                    romaji: ""
                )
            ),
            yomi: "あ",
            candidates: [Candidate("有")],
            candidateIndex: 0,
            cursorPosition: .zero,
            remain: nil
        )
        var state = UnregisterState(
            prev: UnregisterState.PrevState(mode: .hiragana, selecting: prevSelectingState), text: "")
        state = state.appendText("y")
        XCTAssertEqual(state.text, "y")
        state = state.appendText("e").moveCursorLeft().dropLast()
        XCTAssertEqual(state.text, "y")
    }

    func testIMEStateDisplayTextComposing() {
        let composingState = ComposingState(isShift: true, text: ["そ"], romaji: "r", cursor: nil)
        let state = IMEState(inputMode: .hiragana,
                             inputMethod: .composing(composingState),
                             specialState: nil,
                             candidates: [])
        let displayText = state.displayText()
        XCTAssertEqual(displayText.elements, [.markerCompose, .plain("そr")])
    }

    func testIMEStateDisplayTextComposingCursor() {
        let composingState = ComposingState(isShift: true, text: ["おそ"], romaji: "r", cursor: 1)
        let state = IMEState(inputMode: .hiragana,
                             inputMethod: .composing(composingState),
                             specialState: nil,
                             candidates: [])
        let displayText = state.displayText()
        XCTAssertEqual(displayText.elements, [.markerCompose, .plain("おr"), .cursor, .plain("そ")])
    }

    func testIMEStateDisplayTextSelecting() {
        let composingState = ComposingState(isShift: true, text: ["い"], romaji: "")
        let selectingState = SelectingState(prev: SelectingState.PrevState(mode: .hiragana, composing: composingState),
                                            yomi: "い",
                                            candidates: [Candidate("井")],
                                            candidateIndex: 0,
                                            cursorPosition: .zero,
                                            remain: nil)
        let state = IMEState(inputMode: .hiragana,
                             inputMethod: .selecting(selectingState),
                             specialState: nil,
                             candidates: [])
        let displayText = state.displayText()
        XCTAssertEqual(displayText.elements, [.markerSelect, .emphasized("井")])
    }

    func testIMEStateDisplayTextRegister() {
        let prevComposingState = ComposingState(isShift: true, text: ["あいうえお"], romaji: "")
        let registerState = RegisterState(prev: RegisterState.PrevState(mode: .hiragana, composing: prevComposingState),
                                          yomi: "あいうえお",
                                          text: "愛上")
        let composingState = ComposingState(isShift: true, text: ["お"], romaji: "")
        let selectingState = SelectingState(prev: SelectingState.PrevState(mode: .hiragana, composing: composingState),
                                            yomi: "お",
                                            candidates: [Candidate("尾")],
                                            candidateIndex: 0,
                                            cursorPosition: .zero,
                                            remain: nil)
        let state = IMEState(inputMode: .hiragana,
                             inputMethod: .selecting(selectingState),
                             specialState: .register(registerState),
                             candidates: [])
        let displayText = state.displayText()
        XCTAssertEqual(displayText.elements, [.plain("[登録：あいうえお]"), .plain("愛上"), .markerSelect, .emphasized("尾")])
    }

    func testIMEStateDisplayTextRegisterCursor() {
        let prevComposingState = ComposingState(isShift: true, text: ["あいうえお"], romaji: "")
        let registerState = RegisterState(prev: RegisterState.PrevState(mode: .hiragana, composing: prevComposingState),
                                          yomi: "あいうえお",
                                          text: "愛上",
                                          cursor: 1)
        let composingState = ComposingState(isShift: true, text: ["お"], romaji: "")
        let selectingState = SelectingState(prev: SelectingState.PrevState(mode: .hiragana, composing: composingState),
                                            yomi: "お",
                                            candidates: [Candidate("尾")],
                                            candidateIndex: 0,
                                            cursorPosition: .zero,
                                            remain: nil)
        let state = IMEState(inputMode: .hiragana,
                             inputMethod: .selecting(selectingState),
                             specialState: .register(registerState),
                             candidates: [])
        let displayText = state.displayText()
        XCTAssertEqual(displayText.elements, [.plain("[登録：あいうえお]"), .plain("愛"), .markerSelect, .emphasized("尾"), .cursor, .plain("上")])
    }

    func testIMEStateDisplayTextUnregister() {
        let prevSelectingState = SelectingState(
            prev: SelectingState.PrevState(
                mode: .hiragana,
                composing: ComposingState(
                    isShift: true,
                    text: ["あ"],
                    okuri: [Romaji.Moji(firstRomaji: "r", kana: "る")],
                    romaji: ""
                )
            ),
            yomi: "あr",
            candidates: [Candidate("有")],
            candidateIndex: 0,
            cursorPosition: .zero,
            remain: nil
        )
        let unregisterState = UnregisterState(prev: UnregisterState.PrevState(mode: .hiragana, selecting: prevSelectingState), text: "yes")
        let state = IMEState(inputMode: .hiragana,
                             inputMethod: .normal,
                             specialState: .unregister(unregisterState),
                             candidates: [])
        let displayText = state.displayText()
        XCTAssertEqual(displayText.elements, [.plain("あr /有/ を削除します(yes/no)"), .plain("yes")])
    }

    func testIMEStateDisplayTextUnregisterNumberEntry() {
        let prevSelectingState = SelectingState(
            prev: SelectingState.PrevState(
                mode: .hiragana,
                composing: ComposingState(
                    isShift: true,
                    text: ["だい2"],
                    okuri: nil,
                    romaji: ""
                )
            ),
            yomi: "だい2",
            candidates: [Candidate("第2", original: Candidate.Original(midashi: "だい#", word: "第#"))],
            candidateIndex: 0,
            cursorPosition: .zero,
            remain: nil
        )
        let unregisterState = UnregisterState(prev: UnregisterState.PrevState(mode: .hiragana, selecting: prevSelectingState), text: "yes")
        let state = IMEState(inputMode: .hiragana,
                             inputMethod: .normal,
                             specialState: .unregister(unregisterState),
                             candidates: [])
        let displayText = state.displayText()
        XCTAssertEqual(displayText.elements, [.plain("だい# /第#/ を削除します(yes/no)"), .plain("yes")])
    }
}
