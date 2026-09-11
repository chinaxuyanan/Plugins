import SwiftUI

// MARK: - 底部抽屉（档位计算）

/// 底部抽屉的档位 / 高度 / 吸附计算，以及 `.bottomSheet(...)` 视图修饰符
///
/// 和系统 `.sheet` 的「全屏半高」不同，底部抽屉**一开始就贴着底边**、
/// 只是高度不同；往上拖可以展开到更高档位，往下拖到最小档以下则关闭。
/// 这里的静态方法都是**纯函数**，可以直接单元测试。
///
/// - Note: 为兼容 iOS 15 / macOS 12，本组件没有用系统 iOS 16.4 才有的
///   `presentationDetents`，而是自己用 `DragGesture` + 高度吸附实现。
///
/// - Example:
///   ```swift
///   VStack { ... }
///       .bottomSheet(isPresented: $showPicker, detents: [0.3, 0.6, 0.9]) {
///           PickerContent()
///       }
///   ```
/// 中文名 `底部抽屉` 与 `BottomSheet` 等价。
public enum BottomSheet {

    /// 归一化档位数组
    ///
    /// 只保留 `(0, 1]` 且是有限数的值，按升序排列并去重（相邻相等的只留一个），
    /// 结果为空时回退到 `[0.4, 0.7]`。
    ///
    /// - Parameter detents: 原始档位（占容器高度的比例）
    public static func normalizedDetents(_ detents: [CGFloat]) -> [CGFloat] {
        let cleaned = detents
            .filter { $0.isFinite && $0 > 0 && $0 <= 1 }
            .map { min(1, max(0.05, $0)) }
            .sorted()
        var result: [CGFloat] = []
        for value in cleaned where result.last != value {
            result.append(value)
        }
        return result.isEmpty ? [0.4, 0.7] : result
    }

    /// 把档位下标夹到合法范围 `0..<count`
    /// - Parameters:
    ///   - index: 目标下标
    ///   - count: 档位个数
    public static func clamp(_ index: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return min(count - 1, max(0, index))
    }

    /// 某一档对应的面板高度
    /// - Parameters:
    ///   - containerHeight: 容器高度
    ///   - detent: 档位（占容器高度的比例，会被夹到 `0...1`）
    public static func height(containerHeight: CGFloat, detent: CGFloat) -> CGFloat {
        max(0, containerHeight * min(1, max(0, detent)))
    }

    /// 拖动结束后要吸附到哪一档
    ///
    /// 先按「离哪一档最近」选，再根据甩动速度至少挪一档：
    /// 向上甩（`velocity` 为负）往更大档走，向下甩往更小档走。
    ///
    /// - Parameters:
    ///   - currentDetent: 松手时的档位（当前高度 ÷ 容器高度）
    ///   - detents: 全部档位
    ///   - velocity: 甩动速度（单位：档，向上为负），默认 `0`
    public static func nearestIndex(currentDetent: CGFloat,
                                    detents: [CGFloat],
                                    velocity: CGFloat = 0) -> Int {
        let levels = normalizedDetents(detents)
        guard levels.count > 1 else { return 0 }
        var closest = 0
        var best = CGFloat.greatestFiniteMagnitude
        for (index, detent) in levels.enumerated() {
            let distance = abs(detent - currentDetent)
            if distance < best {
                best = distance
                closest = index
            }
        }
        if velocity <= -0.35 {
            closest = min(levels.count - 1, closest + 1)
        } else if velocity >= 0.35 {
            closest = max(0, closest - 1)
        }
        return closest
    }
}

// MARK: - 视图修饰符

public extension View {

    /// 底部抽屉
    ///
    /// 从底边弹出的可拖动面板：点击外部或向下拖到最小档以下关闭，
    /// 向上拖可在多个档位间展开。
    ///
    /// - Parameters:
    ///   - isPresented: 控制是否显示的绑定值
    ///   - detents: 档位数组（占容器高度的比例），默认 `[0.4, 0.7]`
    ///   - initialDetent: 初始档位下标，默认 `0`（最小档）
    ///   - showsHandle: 是否显示顶部拖拽把手，默认 `true`
    ///   - cornerRadius: 面板圆角，默认 `16`
    ///   - dismissOnTapOutside: 点击面板外是否关闭，默认 `true`
    ///   - content: 面板内容
    ///
    /// - Example:
    ///   ```swift
    ///   Button("选择城市") { show = true }
    ///       .bottomSheet(isPresented: $show, detents: [0.35, 0.8]) {
    ///           CityList()
    ///       }
    ///   ```
    func bottomSheet<Content: View>(isPresented: Binding<Bool>,
                                    detents: [CGFloat] = [0.4, 0.7],
                                    initialDetent: Int = 0,
                                    showsHandle: Bool = true,
                                    cornerRadius: CGFloat = 16,
                                    dismissOnTapOutside: Bool = true,
                                    @ViewBuilder content: @escaping () -> Content) -> some View {
        modifier(BottomSheetModifier(isPresented: isPresented,
                                     detents: detents,
                                     initialDetent: initialDetent,
                                     showsHandle: showsHandle,
                                     cornerRadius: cornerRadius,
                                     dismissOnTapOutside: dismissOnTapOutside,
                                     content: content))
    }
}

// MARK: - 实现

private struct BottomSheetModifier<SheetContent: View>: ViewModifier {

    @Binding var isPresented: Bool
    let detents: [CGFloat]
    let initialDetent: Int
    let showsHandle: Bool
    let cornerRadius: CGFloat
    let dismissOnTapOutside: Bool
    let content: () -> SheetContent

    @State private var detentIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0

    init(isPresented: Binding<Bool>,
         detents: [CGFloat],
         initialDetent: Int,
         showsHandle: Bool,
         cornerRadius: CGFloat,
         dismissOnTapOutside: Bool,
         content: @escaping () -> SheetContent) {
        self._isPresented = isPresented
        self.detents = detents
        self.initialDetent = initialDetent
        self.showsHandle = showsHandle
        self.cornerRadius = cornerRadius
        self.dismissOnTapOutside = dismissOnTapOutside
        self.content = content
    }

    private var levels: [CGFloat] { BottomSheet.normalizedDetents(detents) }

    private var animation: Animation { .spring(response: 0.32, dampingFraction: 0.86) }

    func body(content base: Content) -> some View {
        base
            .overlay(alignment: .bottom) {
                GeometryReader { geo in
                    if isPresented {
                        ZStack(alignment: .bottom) {
                            scrim
                            panel(containerHeight: geo.size.height)
                                .transition(.move(edge: .bottom))
                        }
                    }
                }
                .ignoresSafeArea()
            }
            .animation(animation, value: isPresented)
            .animation(animation, value: detentIndex)
            .onChange(of: isPresented) { presented in
                if presented {
                    detentIndex = BottomSheet.clamp(initialDetent, count: levels.count)
                }
            }
    }

    // MARK: 子视图

    private var scrim: some View {
        Color.black.opacity(0.35)
            .ignoresSafeArea()
            .allowsHitTesting(dismissOnTapOutside)
            .onTapGesture {
                if dismissOnTapOutside { isPresented = false }
            }
    }

    private func panel(containerHeight: CGFloat) -> some View {
        let levels = self.levels
        let index = BottomSheet.clamp(detentIndex, count: levels.count)
        let maxHeight = BottomSheet.height(containerHeight: containerHeight,
                                           detent: levels.last ?? 0.7)
        let minHeight = BottomSheet.height(containerHeight: containerHeight,
                                           detent: levels.first ?? 0.4)
        let restingHeight = BottomSheet.height(containerHeight: containerHeight,
                                               detent: levels[index])
        let draggedHeight = restingHeight - dragOffset
        let height = min(maxHeight, max(minHeight, draggedHeight))
        return VStack(spacing: 0) {
            if showsHandle {
                Capsule()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 6)
            }
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 12, y: -2)
        .gesture(dragGesture(containerHeight: containerHeight,
                             index: index,
                             restingHeight: restingHeight))
    }

    // MARK: 拖动

    private func dragGesture(containerHeight: CGFloat,
                             index: Int,
                             restingHeight: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                settle(value,
                       containerHeight: containerHeight,
                       restingHeight: restingHeight)
            }
    }

    private func settle(_ value: DragGesture.Value,
                        containerHeight: CGFloat,
                        restingHeight: CGFloat) {
        guard containerHeight > 0 else { return }
        let levels = self.levels
        let minHeight = BottomSheet.height(containerHeight: containerHeight,
                                           detent: levels.first ?? 0.4)
        let endHeight = restingHeight - value.translation.height
        // 拖到最小档以下足够多 → 直接关闭
        if endHeight < minHeight - 48 {
            isPresented = false
            return
        }
        let currentDetent = endHeight / containerHeight
        let predictedHeight = restingHeight - value.predictedEndTranslation.height
        let predictedDetent = predictedHeight / containerHeight
        detentIndex = BottomSheet.nearestIndex(currentDetent: currentDetent,
                                               detents: levels,
                                               velocity: predictedDetent - currentDetent)
    }
}

// MARK: 中文命名别名

/// 中文名：底部抽屉（等同 `BottomSheet`）
public typealias 底部抽屉 = BottomSheet

public extension BottomSheet {

    /// 归一化档位数组（等同 `normalizedDetents(_:)`）
    static func 归一化档位(_ 档位: [CGFloat]) -> [CGFloat] {
        normalizedDetents(档位)
    }

    /// 某一档对应的面板高度（等同 `height(containerHeight:detent:)`）
    static func 面板高度(容器高: CGFloat, 档位: CGFloat) -> CGFloat {
        height(containerHeight: 容器高, detent: 档位)
    }

    /// 拖动结束后要吸附到哪一档（等同 `nearestIndex(currentDetent:detents:velocity:)`）
    static func 吸附档位(当前档位: CGFloat, 档位组: [CGFloat], 甩动速度: CGFloat = 0) -> Int {
        nearestIndex(currentDetent: 当前档位, detents: 档位组, velocity: 甩动速度)
    }
}
