//
//  ColorWellSecondaryActionDelegate.swift
//  ColorWellKit
//

import Foundation

/// 处理颜色选择器辅助操作的委托类。
class ColorWellSecondaryActionDelegate: NSObject {
    /// 用于执行操作的闭包。
    private let action: () -> Void

    /// 初始化方法，接受一个闭包作为参数。
    /// - Parameter action: 当触发辅助操作时要执行的代码块。
    init(action: @escaping () -> Void) {
        self.action = action
    }

    /// 执行辅助操作的方法。
    /// 该方法会在需要触发辅助操作时被调用。
    @objc func performAction() {
        action()
    }
}

