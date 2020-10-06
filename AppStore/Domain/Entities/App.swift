//
//  App.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/16.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import Foundation
import UIKit

struct App: Codable {
    var name: String
    var artistName: String
    var sellerName: String
    var genres: [String]
    var genre: String {
        get {
            return genres[0]
        }
    }

    var iconUrl: String
    var screenshotUrls: [String]
    var ipadScreenshotUrls: [String]

    var description: String
    var contentAdvisoryRating: String // 권장 연령

    var version: String
    var minimumOsVersion: String
    var supportedDevices: [String]
    var releaseNotes: String?
    var releaseDate: String
    var formattedReleaseDate: String {
        get {
            if let currentDate = releaseDate.toDate(format: "yyyy-MM-dd'T'HH:mm:ssZ") {
                return Date().offset(from: currentDate)
            }
            return ""
        }
    }

    var averageUserRating: Double
    var userRatingCount: Int

    var languageCodes: [String]
    var languages: String {
        get {
            let locale: Locale = Locale.current
            var result = ""

            for code in languageCodes {
                let language = locale.localizedString(forIdentifier: code) ?? ""

                if result.isEmpty {
                    result = language
                } else {
                    result += ", \(language)"
                }
            }
            return result
        }
    }

    var fileSizeBytes: String
    var fileSizeMegaBytes: String {
        get {
            if let bytes = Float(fileSizeBytes) {
                return "\(round(bytes / 1024.0 / 1024.0 * 10) / 10)MB"
            } else {
                return "\(fileSizeBytes)Byte"
            }
        }
    }

    var shareUrl: String
    var sellerUrl: String?
    var artistViewUrl: String

    enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case genres = "genres"
        case iconUrl = "artworkUrl512"
        case screenshotUrls = "screenshotUrls"
        case ipadScreenshotUrls = "ipadScreenshotUrls"
        case description = "description"
        case contentAdvisoryRating = "contentAdvisoryRating"
        case artistName = "artistName"
        case version = "version"
        case minimumOsVersion = "minimumOsVersion"
        case supportedDevices = "supportedDevices"
        case releaseNotes = "releaseNotes"
        case averageUserRating = "averageUserRating"
        case releaseDate = "currentVersionReleaseDate"
        case sellerName = "sellerName"
        case languageCodes = "languageCodesISO2A"
        case fileSizeBytes = "fileSizeBytes"
        case userRatingCount = "userRatingCount"
        case shareUrl = "trackViewUrl"
        case sellerUrl = "sellerUrl"
        case artistViewUrl = "artistViewUrl"
    }

    func getScreenshotDatas(device: Device) -> [Data] {
        var urls: [String] {
            if device == .IPHONE {
                return screenshotUrls
            }
            return ipadScreenshotUrls
        }

        let screenshoturls = urls.compactMap { URL(string: $0) }
        var datas: [Data] = []
        screenshoturls.forEach { url in
            do {
                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                datas.append(data)
            } catch {
                print(error)
            }
        }

        return datas
    }

    func getAppIconData() -> Data {
        // for icon image
        let iconUrl = URL(string: self.iconUrl)
        var iconData: Data = Data()
        if let url = iconUrl {
            do {
                iconData = try Data(contentsOf: url)
            } catch {
                print(error)
            }
        }

        return iconData
    }

    func informationContent(type: DetailInformationContent) -> String {
        switch type {
        case .Seller:
            return self.sellerName
        case .Size: return self.fileSizeMegaBytes
        case .Category:
            return self.genres.joined(separator: ", ")
        case .SupportedDevice:
            return self.getCompatibility()
        case .Language:
            return self.languages
        case .AdvisoryRating:
            return self.contentAdvisoryRating
        case .CopyRight:
            return "©️ \(self.sellerName)"
        default:
            return  ""
        }
    }

    func getCompatibility() -> String {
        var existingDevices: [SupportedDevices: Bool] = [:]
        for value in self.supportedDevices {
            if value.contains(SupportedDevices.iPhone.rawValue) {
                existingDevices[SupportedDevices.iPhone] = true
            }
            if value.contains(SupportedDevices.iPad.rawValue) {
                existingDevices[SupportedDevices.iPad] = true
            }
            if value.contains(SupportedDevices.iPod.rawValue) {
                existingDevices[SupportedDevices.iPod] = true
            }
        }

        var enableDevice: [SupportedDevices] {
            let mappedArray = existingDevices.map { $0.0 }
            return Array(Set(mappedArray))
        }

        var deviceDesc: String = ""
        if enableDevice.count == 1 {
            deviceDesc = enableDevice.first?.getDeviceTitle() ?? ""
        } else {
            for index in stride(from: 0, to: enableDevice.count - 1, by: 1) {
                if deviceDesc.isEmpty {
                    deviceDesc = enableDevice[index].getDeviceTitle()
                } else {
                    deviceDesc += ", \(enableDevice[index].getDeviceTitle())"
                }
            }
            deviceDesc += " 및 \(enableDevice.last?.getDeviceTitle() ?? "")와(과) 호환."
        }

        return "iOS \(self.minimumOsVersion) 버전 이상이 필요. " + deviceDesc
    }
}

enum DetailInformationContent: CaseIterable {
    case Seller
    case Size
    case Category
    case SupportedDevice
    case Language
    case AdvisoryRating
    case CopyRight
    case DeveloperWebsite
    case PrivacyPolicy

    func getTitle() -> String {
        switch self {
        case .Seller:
            return "제공자"
        case .Size:
            return "크기"
        case .Category:
            return "카테고리"
        case .SupportedDevice:
            return "호환성"
        case .Language:
            return "언어"
        case .AdvisoryRating:
            return "연령 등급"
        case .CopyRight:
            return "저작권"
        case .DeveloperWebsite:
            return "개발자 웹 사이트"
        case .PrivacyPolicy:
            return "개인정보 처리방침"
        }
    }
}

enum SupportedDevices: String {
    case iPhone = "iPhone"
    case iPad = "iPad"
    case iPod = "iPod"

    func getDeviceTitle() -> String {
        switch self {
        case .iPhone:
            return "iPhone"
        case .iPad:
            return "iPad"
        case .iPod:
            return "iPod touch"
        }
    }
}

enum Device {
    case IPHONE
    case IPAD
}
