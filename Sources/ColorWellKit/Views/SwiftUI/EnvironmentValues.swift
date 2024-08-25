//
//  EnvironmentValues.swift
//  ColorWellKit
//

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, *)
/// 定义颜色选择器样式配置的环境键
private struct ColorWellStyleConfigurationKey: EnvironmentKey {
    /// 环境中颜色选择器样式配置的默认值
    static let defaultValue = _ColorWellStyleConfiguration.default
}

@available(macOS 10.15, *)
/// 定义颜色样本的环境键
private struct ColorWellSwatchColorsKey: EnvironmentKey {
    /// 环境中颜色样本的默认值（默认为 nil）
    static let defaultValue: [NSColor]? = nil
}

@available(macOS 10.15, *)
/// 定义颜色选择器的次要操作代理的环境键
private struct ColorWellSecondaryActionDelegateKey: EnvironmentKey {
    /// 环境中次要操作代理的默认值（默认为 nil）
    static let defaultValue: ColorWellSecondaryActionDelegate? = nil
}

@available(macOS 10.15, *)
/// 定义颜色面板模式配置的环境键
private struct ColorPanelModeConfigurationKey: EnvironmentKey {
    /// 环境中颜色面板模式配置的默认值（默认为 nil）
    static var defaultValue: _ColorPanelModeConfiguration?
}

@available(macOS 10.15, *)
extension EnvironmentValues {
    /// 访问或设置颜色选择器样式配置
    var colorWellStyleConfiguration: _ColorWellStyleConfiguration {
        get { self[ColorWellStyleConfigurationKey.self] }
        set { self[ColorWellStyleConfigurationKey.self] = newValue }
    }
}

@available(macOS 10.15, *)
extension EnvironmentValues {
    /// 访问或设置颜色样本数组
    var colorWellSwatchColors: [NSColor]? {
        get { self[ColorWellSwatchColorsKey.self] }
        set { self[ColorWellSwatchColorsKey.self] = newValue }
    }
}

@available(macOS 10.15, *)
extension EnvironmentValues {
    /// 访问或设置颜色选择器的次要操作代理
    var colorWellSecondaryActionDelegate: ColorWellSecondaryActionDelegate? {
        get { self[ColorWellSecondaryActionDelegateKey.self] }
        set { self[ColorWellSecondaryActionDelegateKey.self] = newValue }
    }
}

@available(macOS 10.15, *)
extension EnvironmentValues {
    /// 访问或设置颜色面板模式配置
    var colorPanelModeConfiguration: _ColorPanelModeConfiguration? {
        get { self[ColorPanelModeConfigurationKey.self] }
        set { self[ColorPanelModeConfigurationKey.self] = newValue }
    }
}
#endif
