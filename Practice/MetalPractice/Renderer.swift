import MetalKit

final class Renderer: NSObject, MTKViewDelegate {
	init(view: MTKView) {
		super.init()
		view.delegate = self
	}

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

	func draw(in view: MTKView) {}
}
