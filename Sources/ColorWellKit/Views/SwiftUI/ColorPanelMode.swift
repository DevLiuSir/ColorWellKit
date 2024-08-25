//
//  ColorPanelMode.swift
//  ColorWellKit
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - ColorPanelModeConfiguration

/// 配置系统颜色面板模式的值。
@available(macOS 10.15, *)
public struct _ColorPanelModeConfiguration {
    /// 底层颜色面板的模式。
    let mode: NSColorPanel.Mode
}

// MARK: - ColorPanelMode

/// 定义系统颜色面板模式的类型协议。
@available(macOS 10.15, *)
public protocol ColorPanelMode {
    /// 配置系统颜色面板模式的值。
    var _configuration: _ColorPanelModeConfiguration { get }
}

// MARK: - GrayscaleColorPanelMode

/// 灰度颜色面板模式。
@available(macOS 10.15, *)
public struct GrayscaleColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .gray)

    /// 创建灰度颜色面板模式的实例。
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == GrayscaleColorPanelMode {
    /// 灰度颜色面板模式。
    public static var gray: GrayscaleColorPanelMode {
        GrayscaleColorPanelMode()
    }
}

// MARK: - RGBColorPanelMode

/// 红绿蓝（RGB）颜色面板模式。
@available(macOS 10.15, *)
public struct RGBColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .RGB)

    /// 创建红绿蓝（RGB）颜色面板模式的实例。
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == RGBColorPanelMode {
    /// 红绿蓝（RGB）颜色面板模式。
    public static var rgb: RGBColorPanelMode {
        RGBColorPanelMode()
    }
}

// MARK: - CMYKColorPanelMode

/// 青品黄黑（CMYK）颜色面板模式。
@available(macOS 10.15, *)
public struct CMYKColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .CMYK)

    /// 创建青品黄黑（CMYK）颜色面板模式的实例。
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == CMYKColorPanelMode {
    /// 青品黄黑（CMYK）颜色面板模式。
    public static var cmyk: CMYKColorPanelMode {
        CMYKColorPanelMode()
    }
}

// MARK: - HSBColorPanelMode

/// 色调-饱和度-亮度（HSB）颜色面板模式。
@available(macOS 10.15, *)
public struct HSBColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .HSB)

    /// 创建色调-饱和度-亮度（HSB）颜色面板模式的实例。
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == HSBColorPanelMode {
    /// 色调-饱和度-亮度（HSB）颜色面板模式。
    public static var hsb: HSBColorPanelMode {
        HSBColorPanelMode()
    }
}

// MARK: - CustomPaletteColorPanelMode

/// 自定义调色板颜色面板模式。
@available(macOS 10.15, *)
public struct CustomPaletteColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .customPalette)

    /// 创建自定义调色板颜色面板模式的实例。
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == CustomPaletteColorPanelMode {
    /// 自定义调色板颜色面板模式。
    public static var customPalette: CustomPaletteColorPanelMode {
        CustomPaletteColorPanelMode()
    }
}

// MARK: - ColorListColorPanelMode

/// 颜色列表面板模式。
@available(macOS 10.15, *)
public struct ColorListColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .colorList)

    /// 创建颜色列表面板模式的实例。
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == ColorListColorPanelMode {
    /// 颜色列表面板模式。
    public static var colorList: ColorListColorPanelMode {
        ColorListColorPanelMode()
    }
}

// MARK: - ColorWheelColorPanelMode

/// 色轮面板模式。
@available(macOS 10.15, *)
public struct ColorWheelColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .wheel)

    /// 创建色轮面板模式的实例。
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == ColorWheelColorPanelMode {
    /// 色轮面板模式。
    public static var wheel: ColorWheelColorPanelMode {
        ColorWheelColorPanelMode()
    }
}

// MARK: - CrayonPickerColorPanelMode

/// 蜡笔选择器面板模式。
@available(macOS 10.15, *)
public struct CrayonPickerColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .crayon)

    /// 创建蜡笔选择器面板模式的实例。
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == CrayonPickerColorPanelMode {
    /// 蜡笔选择器面板模式。
    public static var crayon: CrayonPickerColorPanelMode {
        CrayonPickerColorPanelMode()
    }
}
#endif
