import MetalKit
import Spatial

final class Renderer: NSObject, MTKViewDelegate {

    private let device: MTLDevice
    private let state: MTLRenderPipelineState
    private lazy var commandQueue = device.makeCommandQueue()!

	init(view: MTKView) {
        view.colorPixelFormat = .bgra8Unorm_srgb
        device = MTLCreateSystemDefaultDevice()!
        let library = device.makeDefaultLibrary()!

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.label = "Triangle"
        descriptor.vertexFunction =  library.makeFunction(name: "vertexMain")
        descriptor.fragmentFunction = library.makeFunction(name: "fragmentMain")
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        state = try! device.makeRenderPipelineState(descriptor: descriptor)

		super.init()
		view.delegate = self
        view.device = device
        view.isPaused = false
        view.enableSetNeedsDisplay = false
	}

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }

	func draw(in view: MTKView) {
//        view.clearColor = clearColor()
        
        guard
            let passDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        else { return }
        
        renderEncoder.setRenderPipelineState(state)
        

        let vertices: Array<Vertex> = [
            Vertex(position: verticesPosition[0], color: simd_float4(SIMD3<Float>(1.0, 0.1, 0.1), 1.0)),
            Vertex(position: verticesPosition[1], color: simd_float4(SIMD3<Float>(0.1, 1.0, 0.1), 1.0)),
            Vertex(position: verticesPosition[2], color: simd_float4(SIMD3<Float>(0.1, 0.1, 1.0), 1.0))
        ]

        let verticesSize = MemoryLayout<Vertex>.stride * vertices.count
        renderEncoder.setVertexBytes(vertices, length: verticesSize, index: 0)
        
        let matrix = scaleMatrix(for: view) * rotationMatrix()
        let uniform = Uniform(matrix: matrix)
        withUnsafePointer(to: uniform) { uniform in
            renderEncoder.setVertexBytes(uniform, length: MemoryLayout<Uniform>.stride, index: 1)
        }
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder.endEncoding()
        
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        commandBuffer.commit()
    }

    private let verticesPosition: [simd_float2] = {
        let radius: Float = 0.8
        let angle = Float.pi / 6
        let xd = cos(angle) * radius
        let yd = sin(angle) * radius
        return [
            simd_float2(x: 0.0, y: radius),
            simd_float2(x: -xd, y: -yd),
            simd_float2(x: xd, y: -yd)
        ]
    }()

    private func scaleMatrix(for view: MTKView) -> float4x4 {
        let k = Float(view.bounds.width / max(0.001, view.bounds.height))
        let xk: Float = k < 1.0 ? 1.0 : 1 / k
        let yk: Float = k < 1.0 ? k : 1.0
        return float4x4(diagonal: SIMD4<Float>(x: 1, y: yk, z: 1.0, w: 1.0))
    }

    private func rotationMatrix() -> float4x4 {
        let period: Double = 5.0
        let h = 2.0 * .pi * CACurrentMediaTime().truncatingRemainder(dividingBy: period) / period
        return float4x4(AffineTransform3D(rotation: .init(angle: .radians(h), axis: .z)))
    }

    private func clearColor() -> MTLClearColor {
        let period: Double = 5.0
        let h = 360.0 * CACurrentMediaTime().truncatingRemainder(dividingBy: period) / period
        return MTLClearColor(L: 0.75, C: 0.2, h: h)
    }
}

extension MTLClearColor {

    init(L: Double, C: Double, h: Double, alpha: Double = 1) {
        // OKLCH → OKLab
        let hr = h * .pi / 180.0
        let a = C * cos(hr)
        let b = C * sin(hr)
        
        // OKLab → LMS (нелинейный)
        let l_ = L + 0.3963377774 * a + 0.2158037573 * b
        let m_ = L - 0.1055613458 * a - 0.0638541728 * b
        let s_ = L - 0.0894841775 * a - 1.2914855480 * b
        
        // кубим
        let l = l_ * l_ * l_
        let m = m_ * m_ * m_
        let s = s_ * s_ * s_
        
        // LMS → linear sRGB
        let linear = SIMD3<Double>(
            4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
            -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
            -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
        )

        // linear → sRGB (гамма) + клэмп
        func clamp(_ x: Double) -> Double { min(max(x, 0), 1) }
        self.init(red: clamp(linear.x), green: clamp(linear.y), blue: clamp(linear.z), alpha: alpha)
    }
}
