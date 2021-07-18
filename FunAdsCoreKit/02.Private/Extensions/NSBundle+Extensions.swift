
import Foundation

private class BundleToken {}

extension Bundle {
    // This is copied method from SPM generated Bundle.module for CocoaPods support
    static func sm_frameworkBundle() -> Bundle {
        return Bundle(identifier: "vn.funads.ios")!
    }
}
