//
//  ColorWellStyle.swift
//  ColorWellKit
//

#if canImport(SwiftUI)

// MARK: - ColorWellStyleConfiguration

/// 配置颜色选择器样式的值。
@available(macOS 10.15, *)
public struct _ColorWellStyleConfiguration {
    /// 颜色选择器的底层样式。
    let style: CWColorWell.Style
}

@available(macOS 10.15, *)
extension _ColorWellStyleConfiguration {
    /// 默认的颜色选择器样式配置。
    static var `default`: _ColorWellStyleConfiguration {
        _ColorWellStyleConfiguration(style: CWColorWell.BackingStorage.defaultStyle)
    }
}

@available(macOS 10.15, *)
extension _ColorWellStyleConfiguration: CustomStringConvertible {
    /// 描述颜色选择器样式配置的字符串。
    public var description: String {
        String(describing: style)
    }
}

// MARK: - ColorWellStyle

/// 指定颜色选择器外观和行为的类型协议。
@available(macOS 10.15, *)
public protocol ColorWellStyle {
    /// 配置颜色选择器样式的值。
    var _configuration: _ColorWellStyleConfiguration { get }
}

// MARK: - DefaultColorWellStyle

/// 一个颜色选择器样式，在矩形控件内显示颜色选择器的颜色，并在点击时切换系统颜色面板。
///
/// 你也可以使用 ``default`` 来构造此样式。
@available(macOS 10.15, *)
public struct DefaultColorWellStyle: ColorWellStyle {
    public let _configuration = _ColorWellStyleConfiguration(style: .default)

    /// 创建默认颜色选择器样式的实例。
    public init() { }
}

@available(macOS 10.15, *)
extension ColorWellStyle where Self == DefaultColorWellStyle {
    /// 一个颜色选择器样式，在矩形控件内显示颜色选择器的颜色，并在点击时切换系统颜色面板。
    public static var `default`: DefaultColorWellStyle {
        DefaultColorWellStyle()
    }
}

// MARK: - MinimalColorWellStyle

/// 一个颜色选择器样式，在矩形控件内显示颜色选择器的颜色，并在点击时显示包含颜色样本的弹出视图。
///
/// 你也可以使用 ``minimal`` 来构造此样式。
@available(macOS 10.15, *)
public struct MinimalColorWellStyle: ColorWellStyle {
    public let _configuration = _ColorWellStyleConfiguration(style: .minimal)

    /// 创建最小化颜色选择器样式的实例。
    public init() { }
}

@available(macOS 10.15, *)
extension ColorWellStyle where Self == MinimalColorWellStyle {
    /// 一个颜色选择器样式，在矩形控件内显示颜色选择器的颜色，并在点击时显示包含颜色样本的弹出视图。
    public static var minimal: MinimalColorWellStyle {
        MinimalColorWellStyle()
    }
}

// MARK: - ExpandedColorWellStyle

/// 一个颜色选择器样式，在颜色区域旁边显示一个专用按钮，用于切换系统颜色面板。
///
/// 点击颜色区域会显示包含颜色样本的弹出视图。
///
/// 你也可以使用 ``expanded`` 来构造此样式。
@available(macOS 10.15, *)
public struct ExpandedColorWellStyle: ColorWellStyle {
    public let _configuration = _ColorWellStyleConfiguration(style: .expanded)

    /// 创建扩展颜色选择器样式的实例。
    public init() { }
}

@available(macOS 10.15, *)
extension ColorWellStyle where Self == ExpandedColorWellStyle {
    /// 一个颜色选择器样式，在颜色区域旁边显示一个专用按钮，用于切换系统颜色面板。
    ///
    /// 点击颜色区域会显示包含颜色样本的弹出视图。
    public static var expanded: ExpandedColorWellStyle {
        ExpandedColorWellStyle()
    }
}
#endif
