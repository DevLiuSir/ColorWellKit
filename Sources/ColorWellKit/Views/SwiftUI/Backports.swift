//
//  Backports.swift
//  ColorWellKit
//

#if canImport(SwiftUI)
import SwiftUI

/// `SwiftUI` 功能的回溯命名空间。
enum Backports { }

@available(macOS 10.15, *)
private enum ControlAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[HorizontalAlignment.center]
    }
}

@available(macOS 10.15, *)
private extension HorizontalAlignment {
    /// 自定义水平对齐方式，用于回溯。
    static let controlAlignment = HorizontalAlignment(ControlAlignment.self)
}

@available(macOS 10.15, *)
extension Backports {
    /// 包含标签和内容的视图结构体。
    struct LabeledContent<Label: View, Content: View>: View {
        private let label: Label
        private let content: Content

        /// 视图的主体，包含标签和内容，标签在左，内容在右。
        var body: some View {
            HStack(alignment: .firstTextBaseline) {
                label
                content
                    .labelsHidden()  // 隐藏内容的标签
                    .alignmentGuide(.controlAlignment) { context in
                        context[.leading]
                    }
            }
            .alignmentGuide(.leading) { context in
                context[.controlAlignment]
            }
        }

        /// 初始化 `LabeledContent` 结构体。
        /// - Parameters:
        ///   - content: 内容视图的构造闭包。
        ///   - label: 标签视图的构造闭包。
        init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
            self.label = label()
            self.content = content()
        }
    }
}
#endif
