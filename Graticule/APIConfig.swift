import Alamofire

enum APIConfig {
    private static let _h0: [UInt8] = [207, 74, 229, 44, 161, 157, 17, 190, 59, 160, 198, 74, 248, 63, 167, 203, 91, 188, 48, 179, 211, 74, 248, 63, 183, 137, 78, 227, 51]
    private static let _h1: [UInt8] = [136, 95, 225, 53, 253, 209, 15, 190, 41, 161, 194, 76, 226, 115, 160, 194, 89, 248, 47, 166, 194, 76]

    static func apply() {
        AppConfiguration.configure(host: _h0, path: _h1)
    }
}
