//
//  Asset3DCardView.swift
//  VisualCents
//
//  3D 资产卡片 - 可以旋转的信用卡效果
//  支持陀螺仪视差效果
//

import SwiftUI
import SceneKit

/// 3D 资产卡片
struct Asset3DCardView: View {
    @Environment(\.appTheme) private var theme

    let assetName: String
    let amount: Double
    let cardColor: Color
    let cardType: CardType

    @State private var pitch: CGFloat = 0
    @State private var yaw: CGFloat = 0

    var body: some View {
        VStack(spacing: 16) {
            // 3D 卡片视图
            SceneKitView(
                cardColor: cardColor,
                assetName: assetName,
                amount: amount,
                cardType: cardType,
                pitch: pitch,
                yaw: yaw
            )
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)

            // 资产信息
            VStack(alignment: .leading, spacing: 8) {
                Text(assetName)
                    .font(theme.customFont(size: 18, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)

                HStack {
                    Text("余额")
                        .font(theme.customFont(size: 14, weight: .medium))
                        .foregroundStyle(theme.textTertiary)

                    Spacer()

                    NumberTicker(
                        value: amount,
                        currency: "¥",
                        precision: 2
                    )
                    .font(theme.amountFont(size: 20))
                    .foregroundStyle(cardColor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .onAppear {
            // 启动陀螺仪效果（需要权限）
            // startGyroscopeUpdates()
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    yaw = value.translation.width / 20
                    pitch = -value.translation.height / 20
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        yaw = 0
                        pitch = 0
                    }
                }
        )
    }
}

enum CardType {
    case visa
    case mastercard
    case amex
    case unionpay
    case custom

    var iconName: String {
        switch self {
        case .visa: return "creditcard"
        case .mastercard: return "creditcard.circle"
        case .amex: return "creditcard.fill"
        case .unionpay: return "creditcard.trianglebadge.exclamationmark"
        case .custom: return "rectangle.portrait"
        }
    }
}

// MARK: - SceneKit 3D View

struct SceneKitView: UIViewRepresentable {
    let cardColor: Color
    let assetName: String
    let amount: Double
    let cardType: CardType
    let pitch: CGFloat
    let yaw: CGFloat

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()

        // 创建场景
        let scene = SCNScene()
        scnView.scene = scene

        // 创建相机
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 5)
        scene.rootNode.addChildNode(cameraNode)

        // 创建 3D 卡片
        let cardNode = create3DCard()
        scene.rootNode.addChildNode(cardNode)

        // 添加光照
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(0, 10, 10)
        scene.rootNode.addChildNode(lightNode)

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor(white: 0.5, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)

        // 启用交互
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = .clear

        // 保存引用
        context.coordinator.cardNode = cardNode

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // 更新旋转
        context.coordinator.cardNode?.eulerAngles = SCNVector3(
            Float(pitch * .pi / 180),
            Float(yaw * .pi / 180),
            0
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func create3DCard() -> SCNNode {
        // 创建卡片几何体（扁平的盒子）
        let cardGeometry = SCNBox(
            width: 3.4,
            height: 2.1,
            length: 0.03,
            chamferRadius: 0.15
        )

        // 卡片材质
        let cardMaterial = SCNMaterial()
        cardMaterial.diffuse.contents = UIColor(cardColor)
        cardMaterial.specular.contents = UIColor.white
        cardMaterial.shininess = 0.8
        cardGeometry.materials = [cardMaterial]

        let cardNode = SCNNode(geometry: cardGeometry)

        // 添加卡号纹理
        addCardDetails(to: cardNode)

        return cardNode
    }

    private func addCardDetails(to node: SCNNode) {
        // 添加卡号（简化为文本节点）
        let amountText = SCNText(string: formatAmount(), extrusionDepth: 0.01)
        amountText.font = UIFont.systemFont(ofSize: 0.3, weight: .bold)
        amountText.firstMaterial?.diffuse.contents = UIColor.white

        let textNode = SCNNode(geometry: amountText)
        textNode.position = SCNVector3(-0.8, -0.3, 0.02)
        node.addChildNode(textNode)

        // 添加卡片类型图标
        let sphere = SCNSphere(radius: 0.15)
        sphere.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.3)
        sphere.firstMaterial?.transparency = 0.5

        let iconNode = SCNNode(geometry: sphere)
        iconNode.position = SCNVector3(1.0, 0.5, 0.02)
        node.addChildNode(iconNode)
    }

    private func formatAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? ""
    }

    class Coordinator {
        var cardNode: SCNNode?
    }
}

// MARK: - 手势控制扩展

extension Asset3DCardView {
    func startGyroscopeUpdates() {
        // TODO: 集成 CoreMotion 获取陀螺仪数据
        // 需要添加 CoreMotion 框架和权限请求
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        Text("3D 资产卡片")
            .font(.title)
            .padding()

        Asset3DCardView(
            assetName: "招商银行",
            amount: 12580.50,
            cardColor: .blue,
            cardType: .visa
        )
        .padding()
    }
    .background(Color(red: 0.97, green: 0.95, blue: 0.92))
    .environment(\.appTheme, CharcoalTheme())
}
