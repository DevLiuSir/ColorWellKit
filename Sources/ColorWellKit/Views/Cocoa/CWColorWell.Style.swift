//
//  Style.swift
//  ColorWellKit
//

import Foundation

extension CWColorWell {
    /// 定义了颜色选择器的外观和行为的常量。
    @objc public enum Style: Int {
        /// 颜色选择器以矩形控件显示，展示选定的颜色，点击时显示系统颜色面板。
        case `default` = 0

        /// 颜色选择器以矩形控件显示，展示选定的颜色，点击时显示包含颜色选择器色板的弹出框。
        ///
        /// 弹出框中包含一个选项，可以显示系统颜色面板。
        case minimal = 1

        /// 颜色选择器以分段控件显示，展示选定的颜色，并配有一个专用按钮以显示系统颜色面板。
        ///
        /// 点击颜色区域内会显示包含颜色选择器色板的弹出框。
        case expanded = 2
    }
}

extension CWColorWell.Style: CustomStringConvertible {
    public var description: String {
        let prefix = String(describing: Self.self) + "."
        return switch self {
        case .default: prefix + "default"
        case .minimal: prefix + "minimal"
        case .expanded: prefix + "expanded"
        }
    }
}
