//
//  FavouritedRepository+Platform.swift
//  GitReads

extension FavouritedRepo {
    var platform: RepoPlatform {
        get {
            RepoPlatform(rawValue: self.platformValue ?? "")!
        }
        set {
            self.platformValue = newValue.rawValue
        }
    }

    var key: String {
        "\(platform)-\(owner ?? "")-\(name ?? "")"
    }

    var fullName: String {
        "\(owner ?? "")/\(name ?? "")"
    }
}
