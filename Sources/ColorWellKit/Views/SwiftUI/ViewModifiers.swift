//
//  ViewModifiers.swift
//  ColorWellKit
//

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, *)
extension View {
    /// 设置此视图中的颜色选择器样式。
    ///
    /// - Parameter style: 要应用于颜色选择器的样式。
    public func colorWellStyle<S: ColorWellStyle>(_ style: S) -> some View {
        environment(\.colorWellStyleConfiguration, style._configuration)
    }

    /// 设置颜色选择弹出框中颜色样本的颜色，
    /// 这些弹出框由此视图中的颜色选择器显示。
    ///
    /// 颜色选择弹出框由使用 ``ColorWellStyle/expanded`` 和
    /// ``ColorWellStyle/minimal`` 样式的颜色选择器显示。
    /// 此修饰符允许您提供自定义颜色数组来替换默认颜色。
    ///
    /// ```swift
    /// ColorWell(selection: $color)
    ///     .colorWellSwatchColors([
    ///         .red, .orange, .yellow, .green, .blue, .indigo,
    ///         .purple, .brown, .gray, .white, .black,
    ///     ])
    ///     .colorWellStyle(.expanded)
    /// ```
    ///
    /// ![自定义颜色样本](custom-swatch-colors)
    ///
    /// - Parameter colors: 用于创建颜色样本的颜色数组。
    @available(macOS 11.0, *)
    public func colorWellSwatchColors(_ colors: [Color]) -> some View {
        transformEnvironment(\.colorWellSwatchColors) { swatchColors in
            swatchColors = colors.map { NSColor($0) }
        }
    }

    /// 设置当此视图中颜色选择器的颜色区域被按下时执行的操作。
    ///
    /// 如果应用此修饰符，使用 ``ColorWellStyle/expanded`` 或
    /// ``ColorWellStyle/minimal`` 样式的颜色选择器会执行提供的操作，
    /// 而不会显示颜色选择弹出框，并且修改弹出框的修饰符（如
    /// ``colorWellSwatchColors(_:)``）将不再生效。
    ///
    /// - Parameter action: 当颜色选择器的颜色区域被按下时要执行的操作。
    public func colorWellSecondaryAction(_ action: @escaping () -> Void) -> some View {
        transformEnvironment(\.colorWellSecondaryActionDelegate) { delegate in
            delegate = ColorWellSecondaryActionDelegate(action: action)
        }
    }

    /// 设置此视图中颜色选择器的颜色面板模式。
    ///
    /// 当使用此修饰符的颜色选择器被激活时，系统颜色面板会切换到
    /// 传递给 `mode` 参数的颜色面板模式。
    ///
    /// - Parameter mode: 要应用于颜色选择器的颜色面板模式。
    public func colorPanelMode<M: ColorPanelMode>(_ mode: M) -> some View {
        environment(\.colorPanelModeConfiguration, mode._configuration)
    }
}
#endif
