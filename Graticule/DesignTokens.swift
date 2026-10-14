import SwiftUI
import UIKit

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #DFE4D3
    static let bg = Color(red: 0.874510, green: 0.894118, blue: 0.827451)
    static let bgHex = "#DFE4D3"
    /// #EEF0EA
    static let surface = Color(red: 0.933333, green: 0.941176, blue: 0.917647)
    static let surfaceHex = "#EEF0EA"
    /// #1E240F
    static let ink = Color(red: 0.117647, green: 0.141176, blue: 0.058824)
    static let inkHex = "#1E240F"
    /// #6B8924
    static let accent = Color(red: 0.419608, green: 0.537255, blue: 0.141176)
    static let accentHex = "#6B8924"
    /// #5C6549
    static let muted = Color(red: 0.360784, green: 0.396078, blue: 0.286275)
    static let mutedHex = "#5C6549"
    static let fontFamily = "Copperplate"

    static let bgColor = UIColor(red: 0.874510, green: 0.894118, blue: 0.827451, alpha: 1)
    static let surfaceColor = UIColor(red: 0.933333, green: 0.941176, blue: 0.917647, alpha: 1)
    static let inkColor = UIColor(red: 0.117647, green: 0.141176, blue: 0.058824, alpha: 1)
    static let accentColor = UIColor(red: 0.419608, green: 0.537255, blue: 0.141176, alpha: 1)
    static let mutedColor = UIColor(red: 0.360784, green: 0.396078, blue: 0.286275, alpha: 1)
}
