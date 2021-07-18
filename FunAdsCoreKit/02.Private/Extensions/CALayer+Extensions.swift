
import QuartzCore

extension CALayer {
    func findAnimation(forKeyPath keyPath: String) -> CABasicAnimation? {
        return animationKeys()?
            .compactMap({ animation(forKey: $0) as? CABasicAnimation })
            .filter({ $0.keyPath == keyPath })
            .first
    }
}
