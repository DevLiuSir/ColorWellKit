//
//  ColorWell.swift
//  ColorWellKit
//

#if canImport(SwiftUI)
import SwiftUI

/// 一个 SwiftUI 视图，显示可供用户选择的颜色值。
@available(macOS 10.15, *)
public struct ColorWell<Label: View>: View {
    // 绑定的颜色选择值（使用 NSColor）。
    @Binding private var selection: NSColor

    // 是否支持不透明度调节。
    private let supportsOpacity: Bool

    // 可选的标签视图。
    private let label: Label?

    // 用于显示颜色选择器的视图。
    private var representable: some View {
        ColorWellRepresentable(selection: $selection, supportsOpacity: supportsOpacity)
            .alignmentGuide(.firstTextBaseline) { context in
                context[VerticalAlignment.center]
            }
            .fixedSize()
    }

    // 将标签与颜色选择器对齐的视图。
    private var alignedLabel: (some View)? {
        label?.alignmentGuide(.firstTextBaseline) { context in
            context[VerticalAlignment.center]
        }
    }

    /// 颜色选择器的内容视图。
    public var body: some View {
        if let alignedLabel {
            if #available(macOS 13.0, *) {
                LabeledContent(
                    content: { representable },
                    label: { alignedLabel }
                )
            } else {
                Backports.LabeledContent(
                    content: { representable },
                    label: { alignedLabel }
                )
            }
        } else {
            representable
        }
    }

    /// 基础的初始化方法供其他初始化方法使用。
    private init(selection: Binding<NSColor>, supportsOpacity: Bool, label: Label?) {
        self._selection = selection
        self.supportsOpacity = supportsOpacity
        self.label = label
    }
}

// MARK: - 带标签的 ColorWell 扩展
@available(macOS 10.15, *)
extension ColorWell {
    /// 使用提供的视图作为标签，创建一个颜色选择器。
    ///
    /// - Parameters:
    ///   - selection: 颜色选择器绑定的颜色值。
    ///   - supportsOpacity: 一个布尔值，指示颜色选择器是否允许调节不透明度；默认值为 `true`。
    ///   - label: 一个描述颜色选择器用途的视图。
    @available(macOS 11.0, *)
    public init(selection: Binding<Color>, supportsOpacity: Bool = true, @ViewBuilder label: () -> Label) {
        self.init(selection: selection.nsColor, supportsOpacity: supportsOpacity, label: label())
    }

    /// 使用提供的视图作为标签，创建一个颜色选择器。
    ///
    /// - Parameters:
    ///   - selection: 颜色选择器绑定的颜色值。
    ///   - supportsOpacity: 一个布尔值，指示颜色选择器是否允许调节不透明度；默认值为 `true`。
    ///   - label: 一个描述颜色选择器用途的视图。
    public init(selection: Binding<CGColor>, supportsOpacity: Bool = true, @ViewBuilder label: () -> Label) {
        self.init(selection: selection.nsColor, supportsOpacity: supportsOpacity, label: label())
    }
}

// MARK: - 无标签的 ColorWell 扩展
@available(macOS 10.15, *)
extension ColorWell where Label == Never {
    /// 创建一个颜色选择器。
    ///
    /// - Parameters:
    ///   - selection: 颜色选择器绑定的颜色值。
    ///   - supportsOpacity: 一个布尔值，指示颜色选择器是否允许调节不透明度；默认值为 `true`。
    @available(macOS 11.0, *)
    public init(selection: Binding<Color>, supportsOpacity: Bool = true) {
        self.init(selection: selection.nsColor, supportsOpacity: supportsOpacity, label: nil)
    }

    /// 创建一个颜色选择器。
    ///
    /// - Parameters:
    ///   - selection: 颜色选择器绑定的颜色值。
    ///   - supportsOpacity: 一个布尔值，指示颜色选择器是否允许调节不透明度；默认值为 `true`。
    public init(selection: Binding<CGColor>, supportsOpacity: Bool = true) {
        self.init(selection: selection.nsColor, supportsOpacity: supportsOpacity, label: nil)
    }
}

// MARK: - 带文本标签的 ColorWell 扩展
@available(macOS 10.15, *)
extension ColorWell where Label == Text {

    // MARK: 从 StringProtocol 生成标签

    /// 使用字符串生成标签，创建一个颜色选择器。
    ///
    /// - Parameters:
    ///   - title: 一个描述颜色选择器用途的字符串。
    ///   - selection: 颜色选择器绑定的颜色值。
    ///   - supportsOpacity: 一个布尔值，指示颜色选择器是否允许调节不透明度；默认值为 `true`。
    @available(macOS 11.0, *)
    public init<S: StringProtocol>(_ title: S, selection: Binding<Color>, supportsOpacity: Bool = true) {
        self.init(selection: selection.nsColor, supportsOpacity: supportsOpacity, label: Text(title))
    }

    /// 使用字符串生成标签，创建一个颜色选择器。
    ///
    /// - Parameters:
    ///   - title: 一个描述颜色选择器用途的字符串。
    ///   - selection: 颜色选择器绑定的颜色值。
    ///   - supportsOpacity: 一个布尔值，指示颜色选择器是否允许调节不透明度；默认值为 `true`。
    public init<S: StringProtocol>(_ title: S, selection: Binding<CGColor>, supportsOpacity: Bool = true) {
        self.init(selection: selection.nsColor, supportsOpacity: supportsOpacity, label: Text(title))
    }

    // MARK: 从 LocalizedStringKey 生成标签

    /// 使用本地化字符串键生成标签，创建一个颜色选择器。
    ///
    /// - Parameters:
    ///   - titleKey: 颜色选择器的本地化标题键。
    ///   - selection: 颜色选择器绑定的颜色值。
    ///   - supportsOpacity: 一个布尔值，指示颜色选择器是否允许调节不透明度；默认值为 `true`。
    @available(macOS 11.0, *)
    public init(_ titleKey: LocalizedStringKey, selection: Binding<Color>, supportsOpacity: Bool = true) {
        self.init(selection: selection.nsColor, supportsOpacity: supportsOpacity, label: Text(titleKey))
    }

    /// 使用本地化字符串键生成标签，创建一个颜色选择器。
    ///
    /// - Parameters:
    ///   - titleKey: 颜色选择器的本地化标题键。
    ///   - selection: 颜色选择器绑定的颜色值。
    ///   - supportsOpacity: 一个布尔值，指示颜色选择器是否允许调节不透明度；默认值为 `true`。
    public init(_ titleKey: LocalizedStringKey, selection: Binding<CGColor>, supportsOpacity: Bool = true) {
        self.init(selection: selection.nsColor, supportsOpacity: supportsOpacity, label: Text(titleKey))
    }
}
#endif
