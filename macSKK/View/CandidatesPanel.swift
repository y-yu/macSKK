// SPDX-FileCopyrightText: 2023 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import Cocoa
import SwiftUI

/// 変換候補リストをフローティングモーダルで表示するパネル
@MainActor
final class CandidatesPanel: NSPanel {
    let viewModel: CandidatesViewModel
    var cursorPosition: NSRect = .zero

    /**
     * - Parameters:
     *   - showAnnotationPopover: パネル表示時に注釈を表示するかどうか
     */
    init(showAnnotationPopover: Bool) {
        viewModel = CandidatesViewModel(candidates: [],
                                        currentPage: 0,
                                        totalPageCount: 0,
                                        showAnnotationPopover: showAnnotationPopover)
        let rootView = CandidatesView(candidates: self.viewModel)
        let viewController = NSHostingController(rootView: rootView)
        // borderlessにしないとdeactivateServerが呼ばれてしまう
        super.init(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: true)
        backgroundColor = .clear
        contentViewController = viewController
        // フルキーボードアクセスが有効なときに変換パネルが表示されなくなるのを回避
        setAccessibilityElement(false)
    }

    func setCandidates(_ candidates: CurrentCandidates, selected: Candidate?) {
        viewModel.selected = selected
        viewModel.candidates = candidates
    }

    func setSystemAnnotation(_ systemAnnotation: String, for word: Word.Word) {
        viewModel.systemAnnotations[word] = systemAnnotation
    }

    func setCursorPosition(_ cursorPosition: NSRect) {
        self.cursorPosition = cursorPosition
        if let mainScreen = NSScreen.main {
            viewModel.maxWidth = mainScreen.visibleFrame.size.width - cursorPosition.origin.x
        }
    }

    func setShowAnnotationPopover(_ showAnnotationPopover: Bool) {
        self.viewModel.showAnnotationPopover = showAnnotationPopover
    }

    /**
     * 表示する。スクリーンからはみ出す位置が指定されている場合は自動で調整する。
     *
     * - 下にはみ出る場合: テキストの上側に表示する
     * - 右にはみ出す場合: スクリーン右端に接するように表示する
     */
    func show() {
        guard let viewController = contentViewController as? NSHostingController<CandidatesView> else {
            fatalError("ビューコントローラの状態が壊れている")
        }
        #if DEBUG
        print("content size = \(viewController.sizeThatFits(in: CGSize(width: Int.max, height: Int.max)))")
        print("intrinsicContentSize = \(viewController.view.intrinsicContentSize)")
        print("frame = \(frame)")
        print("preferredContentSize = \(viewController.preferredContentSize)")
        print("sizeThatFits = \(viewController.sizeThatFits(in: CGSize(width: 10000, height: 10000)))")
        #endif
        var origin = cursorPosition.origin
        let width: CGFloat
        let height: CGFloat
        if case let .panel(words, _, _) = viewModel.candidates {
            width = viewModel.showAnnotationPopover ? viewModel.minWidth + CandidatesView.annotationPopupWidth : viewModel.minWidth
            height = CGFloat(words.count) * CandidatesView.lineHeight + CandidatesView.footerHeight
            if viewModel.displayPopoverInLeft {
                origin.x = origin.x - CandidatesView.annotationPopupWidth - CandidatesView.annotationMargin
            }
        } else {
            // FIXME: 短い文のときにはそれに合わせて高さを縮める
            width = viewModel.minWidth
            height = 200
        }
        setContentSize(NSSize(width: width, height: height))
        if let mainScreen = NSScreen.main {
            // スクリーン右にはみ出す場合はスクリーン右端に接するように表示する
            if origin.x + width > mainScreen.visibleFrame.size.width {
                origin.x = mainScreen.frame.size.width - width
            }
        }
        if origin.y > height {
            setFrameTopLeftPoint(origin)
        } else {
            // スクリーン下にはみ出す場合はテキスト入力位置の上に表示する
            setFrameOrigin(CGPoint(x: origin.x, y: origin.y + cursorPosition.size.height))
        }
        level = .floating
        orderFrontRegardless()
    }
}
