import UIKit

enum DeviceCapabilities {
    static let modelIdentifier: String = {
        if let sim = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return sim
        }
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var buffer = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &buffer, &size, nil, 0)
        return String(cString: buffer)
    }()

    static let hasDynamicIsland: Bool = {
        guard UIDevice.current.userInterfaceIdiom == .phone,
              modelIdentifier.hasPrefix("iPhone") else { return false }
        let numbers = modelIdentifier.dropFirst("iPhone".count).split(separator: ",")
        guard let major = numbers.first.flatMap({ Int($0) }) else { return false }
        return major >= 15
    }()
}