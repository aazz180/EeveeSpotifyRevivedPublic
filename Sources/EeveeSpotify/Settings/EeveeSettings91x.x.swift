import Orion
import SwiftUI
import UIKit

// Settings integration for 9.1.x - adds a button to SPTRootSettingsView
struct V91SettingsIntegrationGroup: HookGroup { }

class SPTRootSettingsViewHook: ClassHook<UIView> {
    typealias Group = V91SettingsIntegrationGroup
    static let targetName = "SPTRootSettingsView"
    
    // Track if we've already added our button to avoid duplicates
    static var hasAddedButton = false
    
    func didMoveToWindow() {
        orig.didMoveToWindow()
        
        // Only add button once
        guard !Self.hasAddedButton, self.window != nil else { return }
        Self.hasAddedButton = true
        
        // Create a button in the top-right corner
        let button = UIButton(type: .system)
        button.setTitle("ℹ️", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showVersionInfo), for: .touchUpInside)
        
        self.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func showVersionInfo() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        // Find the top-most view controller
        var topController = rootViewController
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        let alert = UIAlertController(
            title: "🎵 EeveeSpotify",
            message: """
            Tweak Version: \(EeveeSpotify.version)
            Spotify Version: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
            
            ⚠️ Limited functionality on Spotify 9.1.x:
            • Premium patching: ✓ Active
            • Lyrics: ✗ Not available
            • Full settings: ✗ Not available
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        alert.addAction(UIAlertAction(title: "Open GitHub", style: .default) { _ in
            if let url = URL(string: "https://github.com/Meeep1/EeveeSpotifyReborn2-swift") {
                UIApplication.shared.open(url)
            }
        })
        
        topController.present(alert, animated: true)
    }
}
