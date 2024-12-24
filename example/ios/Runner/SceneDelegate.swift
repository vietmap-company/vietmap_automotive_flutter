//
//  SceneDelegate.swift
//  Runner
//
//  Created by dev on 23/12/24.
//


@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        let controller = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }
}
