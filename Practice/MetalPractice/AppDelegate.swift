// @ai-generated(solo)

import AppKit
import MetalKit

final class AppDelegate: NSObject, NSApplicationDelegate {
	private var window: NSWindow!
	private var renderer: Renderer!

	func applicationDidFinishLaunching(_ notification: Notification) {
		NSApp.mainMenu = makeMainMenu()

		let view = MTKView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
		renderer = Renderer(view: view)

		window = NSWindow(
			contentRect: view.frame,
			styleMask: [.titled, .closable, .miniaturizable, .resizable],
			backing: .buffered,
			defer: false
		)
		window.title = "Metal Practice"
		window.contentView = view
		window.center()
		window.makeKeyAndOrderFront(nil)
		NSApp.activate()
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		true
	}

	// No storyboard, so Cmd+Q needs a menu built by hand.
	private func makeMainMenu() -> NSMenu {
		let appMenu = NSMenu()
		appMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
		let appItem = NSMenuItem()
		appItem.submenu = appMenu
		let mainMenu = NSMenu()
		mainMenu.addItem(appItem)
		return mainMenu
	}
}
