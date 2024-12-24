//
//  FlutterCarplayPluginSceneDelegate.swift
//  Pods
//
//  Created by dev on 18/12/24.
//


import CarPlay
import UIKit

@available(iOS 14.0, *)
class FlutterCarplaySceneDelegate: NSObject {
    // MARK: UISceneDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options _: UIScene.ConnectionOptions) {
        if scene is CPTemplateApplicationScene, session.configuration.name == "CarPlayConfiguration" {
            MemoryLogger.shared.appendEvent("STEMConnect applicaiton scene will connect.")
        } else if scene is CPTemplateApplicationDashboardScene, session.configuration.name == "CarPlayDashboardConfiguration" {
            MemoryLogger.shared.appendEvent("STEMConnect applicaiton dashboard scene will connect.")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        var carplayConnectionStatus = FCPTemplateManager.shared.carplayConnectionStatus
        var dashboardConnectionStatus = FCPTemplateManager.shared.dashboardConnectionStatus

        if scene.session.configuration.name == "CarPlayConfiguration" {
            MemoryLogger.shared.appendEvent("STEMConnect applicaiton scene did disconnect.")
            carplayConnectionStatus = FCPConnectionTypes.disconnected
        } else if scene.session.configuration.name == "CarPlayDashboardConfiguration" {
            MemoryLogger.shared.appendEvent("STEMConnect applicaiton dashboard scene did disconnect.")
            dashboardConnectionStatus = FCPConnectionTypes.disconnected
        }

        if carplayConnectionStatus == FCPConnectionTypes.disconnected, dashboardConnectionStatus == FCPConnectionTypes.disconnected {
            FCPTemplateManager.shared.fcpConnectionStatus = FCPConnectionTypes.disconnected
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        var carplayConnectionStatus = FCPTemplateManager.shared.carplayConnectionStatus
        var dashboardConnectionStatus = FCPTemplateManager.shared.dashboardConnectionStatus

        if scene.session.configuration.name == "CarPlayConfiguration" {
            MemoryLogger.shared.appendEvent("STEMConnect applicaiton scene did become active.")
            carplayConnectionStatus = FCPConnectionTypes.connected
            FCPTemplateManager.shared.setActiveMapViewController(with: scene)
        } else if scene.session.configuration.name == "CarPlayDashboardConfiguration" {
            MemoryLogger.shared.appendEvent("STEMConnect applicaiton dashboard scene did become active.")
            dashboardConnectionStatus = FCPConnectionTypes.connected
            FCPTemplateManager.shared.setActiveMapViewController(with: scene)
        }

        if carplayConnectionStatus == FCPConnectionTypes.connected || dashboardConnectionStatus == FCPConnectionTypes.connected {
            FCPTemplateManager.shared.fcpConnectionStatus = FCPConnectionTypes.connected
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        var carplayConnectionStatus = FCPTemplateManager.shared.carplayConnectionStatus
        var dashboardConnectionStatus = FCPTemplateManager.shared.dashboardConnectionStatus

        if scene.session.configuration.name == "CarPlayConfiguration" {
            MemoryLogger.shared.appendEvent("STEMConnect applicaiton scene did enter background.")
            carplayConnectionStatus = FCPConnectionTypes.background
        } else if scene.session.configuration.name == "CarPlayDashboardConfiguration" {
            MemoryLogger.shared.appendEvent("STEMConnect application Dashboard scene did enter background.")
            dashboardConnectionStatus = FCPConnectionTypes.background
        }

        if carplayConnectionStatus == FCPConnectionTypes.background, dashboardConnectionStatus == FCPConnectionTypes.background {
            FCPTemplateManager.shared.fcpConnectionStatus = FCPConnectionTypes.background
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if scene.session.configuration.name == "CarPlayConfiguration" {
            MemoryLogger.shared.appendEvent("STEMConnect applicaiton scene will resign active.")
        } else if scene.session.configuration.name == "CarPlayDashboardConfiguration" {
            MemoryLogger.shared.appendEvent("STEMConnect applicaiton dashboard scene will resign active.")
        }
    }
}

// MARK: CPTemplateApplicationSceneDelegate

@available(iOS 14.0, *)
extension FlutterCarplaySceneDelegate: CPTemplateApplicationSceneDelegate {
    func templateApplicationScene(_: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController, to window: CPWindow)
    {
        MemoryLogger.shared.appendEvent("Connected to CarPlay.")
        FCPTemplateManager.shared.interfaceController(interfaceController, didConnectWith: window)
    }

    func templateApplicationScene(_: CPTemplateApplicationScene,
                                  didDisconnect interfaceController: CPInterfaceController, from window: CPWindow)
    {
        FCPTemplateManager.shared.interfaceController(interfaceController, didDisconnectWith: window)
        MemoryLogger.shared.appendEvent("Disconnected from CarPlay.")
    }
}

@available(iOS 14, *)
extension FlutterCarplaySceneDelegate: CPTemplateApplicationDashboardSceneDelegate {
    func templateApplicationDashboardScene(
        _: CPTemplateApplicationDashboardScene,
        didConnect dashboardController: CPDashboardController,
        to window: UIWindow
    ) {
        MemoryLogger.shared.appendEvent("Connected to CarPlay dashboard.")
        FCPTemplateManager.shared.dashboardController(dashboardController, didConnectWith: window)
    }

    func templateApplicationDashboardScene(
        _: CPTemplateApplicationDashboardScene,
        didDisconnect dashboardController: CPDashboardController,
        from window: UIWindow
    ) {
        FCPTemplateManager.shared.dashboardController(dashboardController, didDisconnectWith: window)
        MemoryLogger.shared.appendEvent("Disconnected from CarPlay dashboard.")
    }
}

// MARK: - Public Functions

@available(iOS 14.0, *)
extension FlutterCarplaySceneDelegate {
    /// Forces an update of the root template.
    /// - Parameter completion: A closure to be executed upon completion of the update.
    public static func forceUpdateRootTemplate(completion: ((Bool, Error?) -> Void)? = nil) {
        if let rootTemplate = VietmapAutomotiveFlutterPlugin.rootTemplate {
            let animated = VietmapAutomotiveFlutterPlugin.animated
            FCPTemplateManager.shared.carplayInterfaceController?.setRootTemplate(rootTemplate, animated: animated, completion: completion)
        } else {
            completion?(false, nil)
        }
    }

    /// Pops the current template from the navigation hierarchy.
    public static func pop(animated: Bool, completion: ((Bool, Error?) -> Void)? = nil) {
        MemoryLogger.shared.appendEvent("Pop Template.")
        FCPTemplateManager.shared.carplayInterfaceController?.popTemplate(animated: animated, completion: completion)
    }

    /// Pops to the root template in the navigation hierarchy.
    public static func popToRootTemplate(animated: Bool, completion: ((Bool, Error?) -> Void)? = nil) {
        MemoryLogger.shared.appendEvent("Pop to Root Template.")
        FCPTemplateManager.shared.carplayInterfaceController?.popToRootTemplate(animated: animated, completion: completion)
    }

    /// Pushes a new template onto the navigation hierarchy.
    /// - Parameters:
    ///   - template: The template to push onto the navigation hierarchy.
    ///   - animated: A Boolean value that indicates whether the transition should be animated.
    ///   - completion: A closure to be executed upon completion of the push operation.
    public static func push(template: CPTemplate, animated: Bool, completion: ((Bool, Error?) -> Void)? = nil) {
        guard (FCPTemplateManager.shared.carplayInterfaceController?.templates.count ?? 0) <= 4 else {
            MemoryLogger.shared.appendEvent("Template navigation hierarchy exceeded")
            let error = NSError(domain: "FlutterCarplay", code: 0, userInfo: ["LocalizedDescriptionKey": "CarPlay cannot have more than 5 templates on navigation hierarchy."])
            completion?(false, error)
            return
        }
        MemoryLogger.shared.appendEvent("Push to \(template).")
        FCPTemplateManager.shared.carplayInterfaceController?.pushTemplate(template, animated: animated, completion: completion)
    }

    /// Closes the currently presented template.
    public static func closePresent(animated: Bool, completion: ((Bool, Error?) -> Void)? = nil) {
        MemoryLogger.shared.appendEvent("Close the presented template")
        FCPTemplateManager.shared.carplayInterfaceController?.dismissTemplate(animated: animated, completion: completion)
    }

    /// Presents a new template.
    /// - Parameters:
    ///   - template: The template to present.
    ///   - animated: A Boolean value that indicates whether the presentation should be animated.
    ///   - completion: A closure to be executed upon completion of the presentation.
    public static func presentTemplate(template: CPTemplate, animated: Bool, completion: ((Bool, Error?) -> Void)? = nil) {
        MemoryLogger.shared.appendEvent("Present \(template)")
        FCPTemplateManager.shared.carplayInterfaceController?.presentTemplate(template, animated: animated, completion: completion)
    }
}
