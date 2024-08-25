//
//  ColorWellRepresentable.swift
//  ColorWellKit
//

#if canImport(SwiftUI)
import SwiftUI

/// 适用于 SwiftUI 的 ColorWell 表示结构体
@available(macOS 10.15, *)
struct ColorWellRepresentable: NSViewRepresentable {

    /// BridgedColorWell 是 CWColorWell 的子类，用于处理自定义的颜色选择行为。
    final class BridgedColorWell: CWColorWell {
        /// 本地事件监控器，用于处理鼠标事件。
        var mouseMonitor: LocalEventMonitor?

        /// 是否支持透明度。
        var supportsOpacity: Bool = true {
            didSet {
                // 如果需要，将当前颜色的透明度移除。
                updateColor(color, options: [])
            }
        }

        /// 返回指定点的颜色选择器分段。
        /// - Parameter point: 窗口中的位置。
        /// - Returns: 对应的颜色选择器分段，若无则返回 nil。
        func segment(at point: NSPoint) -> CWColorWellSegment? {
            layoutView.segments.first { segment in
                segment.frameConvertedToWindow.contains(point)
            }
        }

        /// 更新颜色的方法，根据是否支持透明度进行处理。
        /// - Parameters:
        ///   - newColor: 新颜色（可选）。
        ///   - options: 更新颜色的选项。
        override func updateColor(_ newColor: NSColor?, options: ColorUpdateOptions) {
            guard let newColor else {
                // 如果新颜色为 nil，设置为黑色（与 NSColorWell 行为一致）。
                // 在返回前调用父类的实现以确保一致的行为。
                super.updateColor(nil, options: options)
                return
            }
            if supportsOpacity || newColor.alphaComponent == 1 {
                // 如果支持透明度或新颜色已经是不透明的，则直接传递给父类。
                super.updateColor(newColor, options: options)
            } else {
                let opaqueColor = newColor.withAlphaComponent(1)

                // 避免不必要的状态修改（这是个临时解决方案）。
                // TODO: 进一步调查此问题。
                guard !opaqueColor.resembles(color, tolerance: 0) else {
                    return
                }

                super.updateColor(opaqueColor, options: options)
            }
        }

        /// 计算颜色选择器的内在内容大小。
        /// - Parameter controlSize: 控件的尺寸。
        /// - Returns: 计算得出的内容大小。
        override func computeIntrinsicContentSize(for controlSize: ControlSize) -> NSSize {
            var size = BackingStorage.defaultSize
            switch backingStorage.style {
            case .default:
                switch controlSize {
                case .large:
                    size.width += 17
                    size.height += 5
                case .regular:
                    size.width += 6
                case .small:
                    size.width -= 5
                    size.height -= 7
                case .mini:
                    size.width -= 9
                    size.height -= 9
                @unknown default:
                    break
                }
            case .minimal:
                switch controlSize {
                case .large:
                    size.width += 17
                    size.height += 5
                case .regular:
                    size.width += 3
                case .small:
                    size.width -= 5
                    size.height -= 7
                case .mini:
                    size.width -= 9
                    size.height -= 9
                @unknown default:
                    break
                }
            case .expanded:
                size.width += CWToggleSegment.widthConstant
                switch controlSize {
                case .large:
                    size.width += 6
                    size.height += 5
                case .regular:
                    break // 不做更改
                case .small:
                    size.width -= 8
                    size.height -= 7
                case .mini:
                    size.width -= 9
                    size.height -= 9
                @unknown default:
                    break
                }
            }
            return size
        }
    }

    /// 处理颜色选择器委托回调的类。
    final class BridgedColorWellDelegate: CWColorWellDelegate {
        let representable: ColorWellRepresentable

        init(representable: ColorWellRepresentable) {
            self.representable = representable
        }

        /// 当颜色选择器的颜色发生变化时调用。
        func colorWellDidChangeColor(_ colorWell: CWColorWell) {
            representable.selection = colorWell.color
        }

        /// 当颜色选择器激活时调用。
        func colorWellDidActivate(_ colorWell: CWColorWell) {
            if NSColorPanel.shared.isMainAttachedObject(colorWell) {
                NSColorPanel.shared.showsAlpha = representable.supportsOpacity
            }
        }
    }

    @Binding var selection: NSColor

    let supportsOpacity: Bool

    /// 创建 NSView 实例（颜色选择器）。
    func makeNSView(context: Context) -> BridgedColorWell {
        let colorWell = BridgedColorWell(color: selection)

        colorWell.supportsOpacity = supportsOpacity
        colorWell.delegate = context.coordinator

        // 某些 SwiftUI 视图（如分组样式的表单）会阻止颜色选择器接收鼠标事件。
        // 目前的解决方案是安装一个本地事件监控器，并将事件传递给对应位置的颜色选择器分段。
        let mouseMonitor = LocalEventMonitor(
            mask: [.leftMouseDown, .leftMouseUp, .leftMouseDragged]
        ) { [weak colorWell] event in
            let locationInWindow = event.locationInWindow
            guard
                let colorWell,
                event.window === colorWell.window,
                colorWell.frameConvertedToWindow.contains(locationInWindow),
                let segment = colorWell.segment(at: locationInWindow)
            else {
                return event
            }
            switch event.type {
            case .leftMouseDown:
                segment.mouseDown(with: event)
                return nil
            case .leftMouseUp:
                segment.mouseUp(with: event)
                return nil
            case .leftMouseDragged:
                segment.mouseDragged(with: event)
                return nil
            default:
                return event
            }
        }

        mouseMonitor.start()
        colorWell.mouseMonitor = mouseMonitor

        return colorWell
    }

    /// 更新现有的 NSView 实例。
    func updateNSView(_ colorWell: BridgedColorWell, context: Context) {
        if colorWell.supportsOpacity != supportsOpacity {
            colorWell.supportsOpacity = supportsOpacity
        }
        if colorWell.color != selection {
            colorWell.color = selection
        }
        if colorWell.style != context.environment.colorWellStyleConfiguration.style {
            colorWell.style = context.environment.colorWellStyleConfiguration.style
        }
        if let swatchColors = context.environment.colorWellSwatchColors,
            colorWell.swatchColors != swatchColors
        {
            colorWell.swatchColors = swatchColors
        }
        if colorWell.colorPanelMode != context.environment.colorPanelModeConfiguration?.mode {
            colorWell.colorPanelMode = context.environment.colorPanelModeConfiguration?.mode
        }
        if let secondaryActionDelegate = context.environment.colorWellSecondaryActionDelegate {
            colorWell.secondaryAction = #selector(secondaryActionDelegate.performAction)
            colorWell.secondaryTarget = secondaryActionDelegate
        } else {
            colorWell.secondaryAction = nil
            colorWell.secondaryTarget = nil
        }
    }

    /// 创建协调器，用于管理 NSView 的委托。
    func makeCoordinator() -> BridgedColorWellDelegate {
        BridgedColorWellDelegate(representable: self)
    }
}
#endif

