//
//  CWColorWellDelegate.swift
//  ColorWellKit
//

import AppKit

/// 一个代理对象，用于在 `CWColorWell` 中传达变化信息。
public protocol CWColorWellDelegate: AnyObject {
    /// 通知代理即将改变颜色选择器的颜色。
    ///
    /// 当颜色选择器即将更改颜色时调用此方法。代理可以通过 `colorWell` 参数的 ``CWColorWell/color`` 属性获取颜色选择器的当前颜色。
    ///
    /// - Parameters:
    ///   - colorWell: 颜色即将改变的颜色选择器。
    ///   - newColor: 颜色选择器的新颜色。
    func colorWellWillChangeColor(_ colorWell: CWColorWell, to newColor: NSColor)

    /// 通知代理颜色选择器的颜色已经改变。
    ///
    /// 当颜色选择器的颜色已经改变时调用此方法。代理可以通过 `colorWell` 参数的 ``CWColorWell/color`` 属性获取颜色选择器的当前颜色。
    ///
    /// - Parameter colorWell: 颜色已经改变的颜色选择器。
    func colorWellDidChangeColor(_ colorWell: CWColorWell)

    /// 通知代理颜色选择器已经激活。
    ///
    /// 当颜色选择器被激活时调用此方法。此方法在颜色选择器的激活状态发生变化时触发。
    ///
    /// - Parameter colorWell: 已激活的颜色选择器。
    func colorWellDidActivate(_ colorWell: CWColorWell)

    /// 通知代理颜色选择器已经停用。
    ///
    /// 当颜色选择器被停用时调用此方法。此方法在颜色选择器的停用状态发生变化时触发。
    ///
    /// - Parameter colorWell: 已停用的颜色选择器。
    func colorWellDidDeactivate(_ colorWell: CWColorWell)
}

// MARK: 默认实现
extension CWColorWellDelegate {
    /// 默认实现：颜色选择器即将改变颜色时调用。
    ///
    /// 可以在此方法中提供默认行为，但如果代理对象需要特定的处理，可以重写此方法。
    ///
    /// - Parameters:
    ///   - colorWell: 颜色即将改变的颜色选择器。
    ///   - newColor: 颜色选择器的新颜色。
    public func colorWellWillChangeColor(_ colorWell: CWColorWell, to newColor: NSColor) { }

    /// 默认实现：颜色选择器的颜色已经改变时调用。
    ///
    /// 可以在此方法中提供默认行为，但如果代理对象需要特定的处理，可以重写此方法。
    ///
    /// - Parameter colorWell: 颜色已经改变的颜色选择器。
    public func colorWellDidChangeColor(_ colorWell: CWColorWell) { }

    /// 默认实现：颜色选择器已经激活时调用。
    ///
    /// 可以在此方法中提供默认行为，但如果代理对象需要特定的处理，可以重写此方法。
    ///
    /// - Parameter colorWell: 已激活的颜色选择器。
    public func colorWellDidActivate(_ colorWell: CWColorWell) { }

    /// 默认实现：颜色选择器已经停用时调用。
    ///
    /// 可以在此方法中提供默认行为，但如果代理对象需要特定的处理，可以重写此方法。
    ///
    /// - Parameter colorWell: 已停用的颜色选择器。
    public func colorWellDidDeactivate(_ colorWell: CWColorWell) { }
}
