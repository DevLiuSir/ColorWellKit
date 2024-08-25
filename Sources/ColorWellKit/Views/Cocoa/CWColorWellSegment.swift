//
//  CWColorWellSegment.swift
//  ColorWellKit
//

import AppKit

// MARK: - CWColorWellSegment

/// A view that draws a segmented portion of a color well.
class CWColorWellSegment: NSView {
    /// A type that represents the state of a color well segment.
    enum State {
        case `default`
        case hover
        case highlight
        case pressed
    }

    /// The edge of a color well where segments of this type are drawn.
    ///
    /// The value of this property specifies how the color well should be
    /// drawn, specifically, whether it should be drawn as a continuous
    /// rounded rectangle, or as a partial rounded rectangle that makes up
    /// a segment in the final shape, with one of its sides drawn with a
    /// flat edge to match up with the segment on the opposite side.
    ///
    /// Any value other than `nil` indicates that the segment should be
    /// drawn as a partial rounded rectangle. A `nil` value indicates that
    /// the segment fills the entire bounds of the color well, and should
    /// be drawn as a continuous rounded rectangle.
    ///
    /// The default value for the base segment class is `nil`, and should
    /// be overridden by subclasses.
    class var edge: Edge? { nil }

    weak var colorWell: CWColorWell?

    /// The current and previous states of the segment.
    var backingStates = (current: State.default, previous: State.default)

    /// The current state of the segment.
    ///
    /// Updating this property displays the segment, if the value returned
    /// from `needsDisplayOnStateChange(_:)` is `true`.
    var state: State {
        get {
            backingStates.current
        }
        set {
            backingStates = (newValue, state)
            if needsDisplayOnStateChange(newValue) {
                needsDisplay = true
            }
        }
    }

    /// Passthrough of `isActive` on `colorWell`.
    var isActive: Bool {
        colorWell?.isActive ?? false
    }

    /// Passthrough of `isEnabled` on `colorWell`.
    var isEnabled: Bool {
        colorWell?.isEnabled ?? false
    }

    /// The default fill color for a color well segment.
    var segmentColor: NSColor {
        switch ColorScheme.current {
        case .light: .controlColor
        case .dark: .selectedControlColor
        }
    }

    /// The fill color for a highlighted color well segment.
    var highlightedSegmentColor: NSColor {
        switch ColorScheme.current {
        case .light: segmentColor.blended(withFraction: 0.5, of: .selectedControlColor) ?? segmentColor
        case .dark: segmentColor.blended(withFraction: 0.2, of: .highlightColor) ?? segmentColor
        }
    }

    /// The fill color for a selected color well segment.
    var selectedSegmentColor: NSColor {
        switch ColorScheme.current {
        case .light: .selectedControlColor
        case .dark: segmentColor.withAlphaComponent(segmentColor.alphaComponent + 0.25)
        }
    }

    /// The unaltered fill color of the segment.
    var rawColor: NSColor { segmentColor }

    /// The color that is displayed directly in the segment.
    var displayColor: NSColor { rawColor }

    override var acceptsFirstResponder: Bool { true }

    override var needsPanelToBecomeKey: Bool { false }

    override var focusRingMaskBounds: NSRect { bounds }

    /// Creates a segment for the given color well.
    init(colorWell: CWColorWell) {
        super.init(frame: .zero)
        self.colorWell = colorWell
        self.wantsLayer = true
        updateForCurrentActiveState(colorWell.isActive)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Performs a predefined action for this segment class using the given segment.
    ///
    /// Subclasses should override this method to provide their own custom behavior.
    /// It is defined as a class method to allow a given implementation to delegate
    /// to an implementation belonging to a different segment class.
    ///
    /// - Parameter segment: A segment to perform the action with.
    ///
    /// - Returns: A Boolean value indicating whether the action was successfully
    ///   performed.
    class func performAction(for segment: CWColorWellSegment) -> Bool { false }

    /// Performs the segment's action using the given key event, after
    /// performing validation on the key event to ensure it can be used
    /// to perform the action.
    ///
    /// The segment must be enabled in order to successfully perform its
    /// action. The event must be a key-down event, and its `characters`
    /// property must consist of a single space (U+0020) character. If
    /// these conditions are not met, or performing the action otherwise
    /// fails, this method returns `false`.
    ///
    /// - Parameter event: A key event to validate.
    ///
    /// - Returns: A Boolean value indicating whether the action was
    ///   successfully performed.
    func validateAndPerformAction(withKeyEvent event: NSEvent) -> Bool {
        if
            isEnabled,
            event.type == .keyDown,
            event.characters == "\u{0020}" // space
        {
            return Self.performAction(for: self)
        }
        return false
    }

    /// Updates the state of the segment to match the specified active state.
    func updateForCurrentActiveState(_ isActive: Bool) { }

    /// Invoked to return whether the segment should be redrawn after its state changes.
    func needsDisplayOnStateChange(_ state: State) -> Bool { false }

    /// Returns the path to draw the segment in the given rectangle.
    func segmentPath(_ rect: NSRect) -> Path {
        Path.segmentPath(
            rect: rect,
            controlSize: colorWell?.controlSize,
            segmentType: Self.self
        )
    }

    override func draw(_ dirtyRect: NSRect) {
        segmentPath(bounds).fill(with: displayColor)
    }

    override func drawFocusRingMask() {
        segmentPath(focusRingMaskBounds).fill(with: .black)
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        guard isEnabled else {
            return
        }
        state = .highlight
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        guard
            isEnabled,
            frameConvertedToWindow.contains(event.locationInWindow)
        else {
            return
        }
        _ = Self.performAction(for: self)
    }

    override func keyDown(with event: NSEvent) {
        if !validateAndPerformAction(withKeyEvent: event) {
            super.keyDown(with: event)
        }
    }

    override func accessibilityParent() -> Any? {
        return colorWell
    }

    override func accessibilityPerformPress() -> Bool {
        Self.performAction(for: self)
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        return .button
    }

    override func isAccessibilityElement() -> Bool {
        return true
    }
}

// MARK: - CWSwatchSegment

/// 显示带有颜色池当前
/// 颜色选择的颜色样本的部分。
class CWSwatchSegment: CWColorWellSegment {
    /// 与颜色选择器段落相关的拖动信息。
    struct DraggingInformation {
        /// 此实例的默认值。
        ///
        /// 这些值在初始化时提供并缓存，用于重置该实例。
        private let defaults: (threshold: CGFloat, isDragging: Bool, offset: CGSize)
        
        /// 开始拖动会话之前必须发生的移动量。
        var threshold: CGFloat
        
        /// 一个布尔值，指示是否正在进行拖动。
        var isDragging: Bool
        
        /// 当前拖动事件系列的累计偏移量。
        var offset: CGSize
        
        /// 一个布尔值，指示当前拖动信息是否有效，可以开始拖动会话。
        var isValid: Bool {
            // 计算偏移量的平方根是否大于等于阈值，以判断拖动是否有效
            hypot(offset.width, offset.height) >= threshold
        }
        
        /// 使用给定的值创建一个实例。
        ///
        /// 这里提供的值会被缓存，并用于重置该实例。
        ///
        /// - Parameters:
        ///   - threshold: 开始拖动会话之前的最小移动量，默认为 4。
        ///   - isDragging: 指示是否正在拖动的布尔值，默认为 `false`。
        ///   - offset: 当前拖动事件的偏移量，默认为 `.zero`（`CGSize()`）。
        init(
            threshold: CGFloat = 4,
            isDragging: Bool = false,
            offset: CGSize = CGSize()
        ) {
            self.defaults = (threshold, isDragging, offset)
            self.threshold = threshold
            self.isDragging = isDragging
            self.offset = offset
        }

        /// 将拖动信息重置为其默认值。
        mutating func reset() {
            self = DraggingInformation(
                threshold: defaults.threshold,
                isDragging: defaults.isDragging,
                offset: defaults.offset
            )
        }
        
        /// 根据 x 和 y 更新段的拖动偏移量。
        /// 给定事件的增量。
        mutating func updateOffset(with event: NSEvent) {
            offset.width += event.deltaX
            offset.height += event.deltaY
        }
    }

    var draggingInformation = DraggingInformation()

    var borderColor: NSColor {
        let displayColor = displayColor
        let component = min(displayColor.averageBrightness, displayColor.alphaComponent)
        let limitedComponent = min(component, 0.3)
        let white = 1 - limitedComponent
        let alpha = min(limitedComponent * 1.3, 0.7)
        return NSColor(white: white, alpha: alpha)
    }

    override var rawColor: NSColor {
        colorWell?.color ?? super.rawColor
    }

    override var displayColor: NSColor {
        super.displayColor.usingColorSpace(.displayP3) ?? super.displayColor
    }

    override var acceptsFirstResponder: Bool { false }

    override init(colorWell: CWColorWell) {
        super.init(colorWell: colorWell)
        registerForDraggedTypes([.color])
    }

    /// 绘制该段的样本。
    @objc dynamic
    func drawSwatch() {
        guard let context = NSGraphicsContext.current else {
            return
        }

        context.saveGraphicsState()
        defer {
            context.restoreGraphicsState()
        }
        
        // 解决剪切路径影响色板边框的问题：
        // 在剪切之前将色板绘制为图像，然后剪切图像而不是色板
        let swatchImage = NSImage(size: bounds.size, flipped: false) { [weak displayColor] bounds in
            guard let displayColor else {
                return false
            }
            displayColor.drawSwatch(in: bounds)
            return true
        }

        segmentPath(bounds).nsBezierPath().addClip()
        swatchImage.draw(in: bounds)
    }

    override func draw(_ dirtyRect: NSRect) {
        drawSwatch()
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        draggingInformation.reset()
    }

    override func mouseUp(with event: NSEvent) {
        defer {
            draggingInformation.reset()
        }
        guard !draggingInformation.isDragging else {
            return
        }
        super.mouseUp(with: event)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        guard isEnabled else {
            return
        }

        draggingInformation.updateOffset(with: event)

        guard
            draggingInformation.isValid,
            let color = colorWell?.color
        else {
            return
        }

        draggingInformation.isDragging = true
        state = backingStates.previous

        let colorForDragging = color.createArchivedCopy()
        NSColorPanel.dragColor(colorForDragging, with: event, from: self)
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard
            isEnabled,
            let types = sender.draggingPasteboard.types,
            types.contains(where: { registeredDraggedTypes.contains($0) })
        else {
            return []
        }
        return .move
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if
            let colorWell,
            let color = NSColor(from: sender.draggingPasteboard)
        {
            colorWell.updateColor(color, options: [
                .informDelegate,
                .informObservers,
                .sendAction,
            ])
            return true
        }
        return false
    }

    override func isAccessibilityElement() -> Bool {
        return false
    }
}

// MARK: - CWBorderedSwatchSegment

/// 一个显示带有颜色池当前
/// 颜色选择的颜色样本的部分，按下时会切换颜色面板。
class CWBorderedSwatchSegment: CWSwatchSegment {
    override class var edge: Edge? { nil }

    var bezelColor: NSColor {
        let bezelColor: NSColor = switch state {
        case .highlight, .pressed:
            switch ColorScheme.current {
            case .light:
                selectedSegmentColor
            case .dark:
                .highlightColor
            }
        default:
            segmentColor
        }
        guard isEnabled else {
            let alphaComponent = max(bezelColor.alphaComponent - 0.5, 0.1)
            return bezelColor.withAlphaComponent(alphaComponent)
        }
        return bezelColor
    }

    override var borderColor: NSColor {
        switch ColorScheme.current {
        case .light: super.borderColor.blended(withFraction: 0.25, of: .controlTextColor) ?? super.borderColor
        case .dark: super.borderColor
        }
    }

    override class func performAction(for segment: CWColorWellSegment) -> Bool {
        CWToggleSegment.performAction(for: segment)
    }

    override func drawSwatch() {
        guard let context = NSGraphicsContext.current else {
            return
        }

        context.saveGraphicsState()
        defer {
            context.restoreGraphicsState()
        }

        segmentPath(bounds).fill(with: bezelColor)

        var inset: CGFloat = 3
        var radius: CGFloat = 2
        switch colorWell?.controlSize {
        case .large:
            inset += 0.25
            radius += 0.2
        case .regular, .none:
            break // 不做修改
        case .small:
            inset -= 0.75
            radius -= 0.6
        case .mini:
            inset -= 1
            radius -= 0.8
        @unknown default:
            break
        }

        let clippingPath = NSBezierPath(
            roundedRect: bounds.insetBy(dx: inset, dy: inset),
            xRadius: radius,
            yRadius: radius
        )

        clippingPath.lineWidth = 1
        clippingPath.addClip()

        displayColor.drawSwatch(in: bounds)

        borderColor.setStroke()
        clippingPath.stroke()
    }

    override func updateForCurrentActiveState(_ isActive: Bool) {
        state = isActive ? .pressed : .default
    }

    override func needsDisplayOnStateChange(_ state: State) -> Bool {
        state != .hover
    }
}

// MARK: - CWPullDownSwatchSegment

/// 显示带有颜色井当前
/// 颜色选择的颜色样本的部分，并在按下时触发下拉操作。
class CWPullDownSwatchSegment: CWSwatchSegment {
    private var mouseEnterExitTrackingArea: NSTrackingArea?

    var canPerformAction: Bool {
        if let colorWell {
            if colorWell.secondaryAction != nil && colorWell.secondaryTarget != nil {
                // 我们有一个辅助操作和一个执行它的目标；这
                // 优先于弹出配置，因此无需
                // 执行进一步的检查
                return true
            }
            return !colorWell.swatchColors.isEmpty
        }
        return false
    }

    override var draggingInformation: DraggingInformation {
        didSet {
            // 确保拖动开始时插入符号消失
            if draggingInformation.isDragging {
                state = .default
            }
        }
    }

    override class func performAction(for segment: CWColorWellSegment) -> Bool {
        guard let colorWell = segment.colorWell else {
            return false
        }

        if
            let segment = segment as? Self,
            !segment.canPerformAction || NSEvent.modifierFlags.contains(.shift)
        {
            // 无法执行标准操作；视为切换段
            return CWToggleSegment.performAction(for: segment)
        }

        if
            let secondaryAction = colorWell.secondaryAction,
            let secondaryTarget = colorWell.secondaryTarget
        {
            // 次要操作优先于显示弹出窗口
            return NSApp.sendAction(secondaryAction, to: secondaryTarget, from: colorWell)
        }

        return colorWell.makeAndShowPopover(relativeTo: segment)
    }

    private func drawBorder() {
        guard let context = NSGraphicsContext.current else {
            return
        }

        context.saveGraphicsState()
        defer {
            context.restoreGraphicsState()
        }

        let lineWidth: CGFloat = 0.5
        let insetRect = bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        segmentPath(insetRect).stroke(with: borderColor, lineWidth: lineWidth)
    }

    private func drawCaret() {
        guard
            canPerformAction,
            let context = NSGraphicsContext.current
        else {
            return
        }
        // 插入符号需要根据控件大小以不同方式绘制；
        // 这些值不基于任何实际逻辑，只是为了好看
        let (bgBounds, caretBounds, lineWidth): (NSRect, NSRect, CGFloat) = {
            let (bgDimension, lineWidth, sizeFactor, padding): (CGFloat, CGFloat, CGFloat, CGFloat) = {
                // 惰性声明阻止在第一次重新分配时进行重新分配
                lazy var bgDimension: CGFloat = 12.0
                lazy var lineWidth: CGFloat = 1.5
                lazy var sizeFactor: CGFloat = 2.0
                lazy var padding: CGFloat = 4.0

                switch colorWell?.controlSize {
                case .large, .regular, .none:
                    break // 不做修改
                case .small:
                    bgDimension = 10.0
                    lineWidth = 1.33
                    sizeFactor = 1.85
                    padding = 3.0
                case .mini:
                    bgDimension = 9.0
                    lineWidth = 1.25
                    sizeFactor = 1.75
                    padding = 2.0
                @unknown default:
                    break
                }

                return (bgDimension, lineWidth, sizeFactor, padding)
            }()

            let bgBounds = NSRect(
                x: bounds.maxX - bgDimension - padding,
                y: bounds.midY - bgDimension / 2,
                width: bgDimension,
                height: bgDimension
            )
            let caretBounds: NSRect = {
                let dimension = (bgDimension - lineWidth) / sizeFactor
                let size = NSSize(
                    width: dimension,
                    height: dimension / 2
                )
                let origin = NSPoint(
                    x: bgBounds.midX - (size.width / 2),
                    y: bgBounds.midY - (size.height / 2) - (lineWidth / 4)
                )
                return NSRect(origin: origin, size: size)
            }()

            return (bgBounds, caretBounds, lineWidth)
        }()

        context.saveGraphicsState()
        defer {
            context.restoreGraphicsState()
        }

        NSColor(white: 0, alpha: 0.25).setFill()
        NSBezierPath(ovalIn: bgBounds).fill()

        let caretPath = Path(elements: [
            .move(to: NSPoint(x: caretBounds.minX, y: caretBounds.maxY)),
            .line(to: NSPoint(x: caretBounds.midX, y: caretBounds.minY)),
            .line(to: NSPoint(x: caretBounds.maxX, y: caretBounds.maxY)),
        ]).nsBezierPath()

        caretPath.lineCapStyle = .round
        caretPath.lineJoinStyle = .round
        caretPath.lineWidth = lineWidth

        NSColor.white.setStroke()
        caretPath.stroke()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawBorder()
        if state == .hover {
            drawCaret()
        }
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        guard isEnabled else {
            return
        }
        state = .hover
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        guard isEnabled else {
            return
        }
        state = .default
    }

    override func needsDisplayOnStateChange(_ state: State) -> Bool {
        switch state {
        case .hover, .default: true
        case .highlight, .pressed: false
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let mouseEnterExitTrackingArea {
            removeTrackingArea(mouseEnterExitTrackingArea)
        }
        let mouseEnterExitTrackingArea = NSTrackingArea(
            rect: bounds,
            options: [
                .activeInKeyWindow,
                .mouseEnteredAndExited,
            ],
            owner: self
        )
        addTrackingArea(mouseEnterExitTrackingArea)
        self.mouseEnterExitTrackingArea = mouseEnterExitTrackingArea
    }
}

// MARK: - CWSinglePullDownSwatchSegment

/// 下拉的色板段可以很好地填充其颜色。
class CWSinglePullDownSwatchSegment: CWPullDownSwatchSegment {
    override class var edge: Edge? { nil }

    override var borderColor: NSColor { .placeholderTextColor }
}

// MARK: - CWPartialPullDownSwatchSegment

/// 下拉的色板段未很好填充其颜色。
class CWPartialPullDownSwatchSegment: CWPullDownSwatchSegment {
    override class var edge: Edge? { .leading }
}

// MARK: - CWToggleSegment

/// 按下时切换系统颜色面板的片段。
class CWToggleSegment: CWColorWellSegment {
    private enum Images {
        static let defaultImage: NSImage = {
            // 强制展开在这里是可以的，因为图像是 AppKit 内置的
            // swiftlint:disable:next force_unwrapping
            let image = NSImage(named: NSImage.touchBarColorPickerFillName)!

            let minDimension = min(image.size.width, image.size.height)
            let croppedSize = NSSize(width: minDimension, height: minDimension)
            let croppedRect = NSRect(origin: .zero, size: croppedSize)
                .centered(in: NSRect(origin: .zero, size: image.size))

            return NSImage(size: croppedSize, flipped: false) { bounds in
                image.draw(in: bounds, from: croppedRect, operation: .copy, fraction: 1)
                return true
            }
        }()

        static let enabledImageForDarkAppearance = defaultImage.tinted(to: .white, fraction: 1 / 3)

        static let enabledImageForLightAppearance = defaultImage.tinted(to: .black, fraction: 1 / 5)

        static let disabledImageForDarkAppearance = defaultImage.tinted(to: .gray, fraction: 1 / 3).withOpacity(0.5)

        static let disabledImageForLightAppearance = defaultImage.tinted(to: .gray, fraction: 1 / 5).withOpacity(0.5)
    }

    static let widthConstant: CGFloat = 20

    override class var edge: Edge? { .trailing }

    override var rawColor: NSColor {
        switch state {
        case .highlight:
            return highlightedSegmentColor
        case .pressed:
            return selectedSegmentColor
        default:
            return segmentColor
        }
    }

    override init(colorWell: CWColorWell) {
        super.init(colorWell: colorWell)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: Self.widthConstant).isActive = true
    }

    override class func performAction(for segment: CWColorWellSegment) -> Bool {
        guard let colorWell = segment.colorWell else {
            return false
        }
        if colorWell.isActive {
            colorWell.deactivate()
        } else {
            colorWell.activateAutoExclusive()
        }
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard
            let context = NSGraphicsContext.current,
            let colorWell
        else {
            return
        }

        context.saveGraphicsState()
        defer {
            context.restoreGraphicsState()
        }

        let imageRect: NSRect = {
            let (pad, width, height) = (5.5, bounds.width, bounds.height)
            var dimension = min(max(height - pad * 2, width - pad), width - 1)
            switch colorWell.controlSize {
            case .large, .regular:
                break // 不做修改
            case .small:
                dimension -= 3
            case .mini:
                dimension -= 4
            @unknown default:
                break
            }
            return NSRect(
                x: bounds.midX - dimension / 2,
                y: bounds.midY - dimension / 2,
                width: dimension,
                height: dimension
            )
        }()

        let image: NSImage = {
            switch ColorScheme.current {
            case .light where isEnabled:
                if state == .highlight {
                    return Images.enabledImageForLightAppearance
                }
                return Images.defaultImage
            case .light:
                return Images.disabledImageForLightAppearance
            case .dark where isEnabled:
                if state == .highlight {
                    return Images.enabledImageForDarkAppearance
                }
                return Images.defaultImage
            case .dark:
                return Images.disabledImageForDarkAppearance
            }
        }()

        NSBezierPath(ovalIn: imageRect).addClip()
        image.draw(in: imageRect)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        guard isEnabled else {
            return
        }
        if frameConvertedToWindow.contains(event.locationInWindow) {
            state = .highlight
        } else if isActive {
            state = .pressed
        } else {
            state = .default
        }
    }

    override func updateForCurrentActiveState(_ isActive: Bool) {
        state = isActive ? .pressed : .default
    }

    override func needsDisplayOnStateChange(_ state: State) -> Bool {
        switch state {
        case .highlight, .pressed, .default:
            return true
        case .hover:
            return false
        }
    }

    override func accessibilityLabel() -> String? {
        return "color picker"
    }
}
