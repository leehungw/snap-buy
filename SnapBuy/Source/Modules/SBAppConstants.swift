import Foundation
import RswiftResources

let RString = R.string
let RLocalizable = RString.localizable
let RImage = R.image
let RFile = R.file
let RBundle = R.bundle
let RFont = R.font

typealias SBVoidAction = () -> Void
typealias SBValueAction<Value> = (Value) -> Void

struct SBAppConstant {
    
    static let sidePadding: CGFloat = 16.0
    static let nullString = "null"
    static let apiBaseURL = "https://3bd54531-949e-4e3c-86f4-11a9b69edcd0.mock.pstmn.io"
    
    struct App {
        static let appName = "Snap Buy"
    }
    
    struct Layout {
        static let sidePadding: CGFloat = 16.0
    }
}


