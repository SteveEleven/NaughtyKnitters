//
//  Vendor.swift
//  NaughtyKnitters
//

import CoreLocation
import Foundation
import SwiftUI

enum VendorType: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case retailStore = "retail_store"
    case farmGate = "farm_gate"
    case indieDyer = "indie_dyer"
    case mill = "mill"
    case guild = "guild"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .retailStore: return "Retail Store"
        case .farmGate: return "Farm Gate"
        case .indieDyer: return "Indie Dyer"
        case .mill: return "Mill"
        case .guild: return "Guild"
        }
    }

    var systemImage: String {
        switch self {
        case .retailStore: return "storefront.fill"
        case .farmGate: return "leaf.fill"
        case .indieDyer: return "paintpalette.fill"
        case .mill: return "gearshape.2.fill"
        case .guild: return "person.3.fill"
        }
    }

    var mapColor: Color {
        switch self {
        case .retailStore: return .pink
        case .farmGate: return .green
        case .indieDyer: return .purple
        case .mill: return .orange
        case .guild: return .blue
        }
    }
}

enum CraftCategory: String, CaseIterable, Identifiable, Hashable, Sendable {
    case knitting = "Knitting"
    case crochet = "Crochet"
    case needleWetFelting = "Needle & Wet Felting"
    case handspinning = "Handspinning"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .knitting: return "circle.grid.cross"
        case .crochet: return "circle.hexagongrid.fill"
        case .needleWetFelting: return "cloud.fill"
        case .handspinning: return "arrow.triangle.2.circlepath"
        }
    }
}

struct Vendor: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var regionId: UUID?
    var name: String
    var vendorType: VendorType
    var accessModel: String
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var phone: String?
    var email: String?
    var websiteUrl: String?
    var instagramHandle: String?
    var craftTags: [String]
    var isFeatured: Bool
    var affiliateCode: String?

    enum CodingKeys: String, CodingKey {
        case id
        case regionId = "region_id"
        case name
        case vendorType = "vendor_type"
        case accessModel = "access_model"
        case address
        case latitude
        case longitude
        case phone
        case email
        case websiteUrl = "website_url"
        case instagramHandle = "instagram_handle"
        case craftTags = "craft_tags"
        case isFeatured = "is_featured"
        case affiliateCode = "affiliate_code"
    }

    init(
        id: UUID = UUID(),
        regionId: UUID? = nil,
        name: String,
        vendorType: VendorType,
        accessModel: String = "Walk-in",
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        phone: String? = nil,
        email: String? = nil,
        websiteUrl: String? = nil,
        instagramHandle: String? = nil,
        craftTags: [String] = [],
        isFeatured: Bool = false,
        affiliateCode: String? = nil
    ) {
        self.id = id
        self.regionId = regionId
        self.name = name
        self.vendorType = vendorType
        self.accessModel = accessModel
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.phone = phone
        self.email = email
        self.websiteUrl = websiteUrl
        self.instagramHandle = instagramHandle
        self.craftTags = craftTags
        self.isFeatured = isFeatured
        self.affiliateCode = affiliateCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        regionId = try container.decodeIfPresent(UUID.self, forKey: .regionId)
        name = try container.decode(String.self, forKey: .name)
        vendorType = try container.decode(VendorType.self, forKey: .vendorType)
        accessModel = try container.decodeIfPresent(String.self, forKey: .accessModel) ?? "Walk-in"
        address = try container.decodeIfPresent(String.self, forKey: .address)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        websiteUrl = try container.decodeIfPresent(String.self, forKey: .websiteUrl)
        instagramHandle = try container.decodeIfPresent(String.self, forKey: .instagramHandle)
        craftTags = try container.decodeIfPresent([String].self, forKey: .craftTags) ?? []
        isFeatured = try container.decodeIfPresent(Bool.self, forKey: .isFeatured) ?? false
        affiliateCode = try container.decodeIfPresent(String.self, forKey: .affiliateCode)
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Vendor {
    static let beehiveID = UUID(uuidString: "B2000001-0000-4000-8000-000000000001")!
    static let sookeYarnID = UUID(uuidString: "B2000001-0000-4000-8000-000000000002")!
    static let parryBayID = UUID(uuidString: "B2000001-0000-4000-8000-000000000003")!
    static let aguaDulceID = UUID(uuidString: "B2000001-0000-4000-8000-000000000004")!
    static let saltSpringWoolID = UUID(uuidString: "B2000001-0000-4000-8000-000000000005")!

    static let sampleData: [Vendor] = [
        Vendor(
            id: beehiveID,
            regionId: Region.victoriaID,
            name: "Beehive Wool Shop",
            vendorType: .retailStore,
            accessModel: "Walk-in",
            address: "450 Fort St, Victoria, BC",
            latitude: 48.4248,
            longitude: -123.3656,
            phone: "250-388-6494",
            email: "info@beehivewool.com",
            websiteUrl: "https://www.beehivewool.com",
            instagramHandle: "beehivewoolshop",
            craftTags: [
                CraftCategory.knitting.rawValue,
                CraftCategory.crochet.rawValue,
                CraftCategory.handspinning.rawValue
            ],
            isFeatured: true,
            affiliateCode: "NK-BEEHIVE"
        ),
        Vendor(
            id: sookeYarnID,
            regionId: Region.sookeID,
            name: "Sooke Yarn & Fibre",
            vendorType: .retailStore,
            accessModel: "Walk-in",
            address: "6671 Sooke Rd, Sooke, BC",
            latitude: 48.3761,
            longitude: -123.7275,
            phone: "250-642-0272",
            email: "hello@sookeyarn.ca",
            websiteUrl: "https://www.sookeyarn.ca",
            instagramHandle: "sookeyarnfibre",
            craftTags: [
                CraftCategory.knitting.rawValue,
                CraftCategory.crochet.rawValue,
                CraftCategory.needleWetFelting.rawValue
            ],
            isFeatured: true
        ),
        Vendor(
            id: parryBayID,
            regionId: Region.metchosinID,
            name: "Parry Bay Sheep Farm",
            vendorType: .farmGate,
            accessModel: "Farm gate / appointment",
            address: "Metchosin, BC",
            latitude: 48.3819,
            longitude: -123.5320,
            phone: "250-478-2345",
            email: "visit@parrybay.ca",
            websiteUrl: "https://www.parrybay.ca",
            instagramHandle: "parrybaysheep",
            craftTags: [
                CraftCategory.handspinning.rawValue,
                CraftCategory.needleWetFelting.rawValue,
                CraftCategory.knitting.rawValue
            ],
            isFeatured: false
        ),
        Vendor(
            id: aguaDulceID,
            regionId: Region.saltSpringID,
            name: "Agua Dulce Farm",
            vendorType: .farmGate,
            accessModel: "Farm gate / seasonal markets",
            address: "Salt Spring Island, BC",
            latitude: 48.8120,
            longitude: -123.5080,
            email: "hello@aguadulcefarm.ca",
            websiteUrl: "https://www.aguadulcefarm.ca",
            instagramHandle: "aguadulcefarm",
            craftTags: [
                CraftCategory.handspinning.rawValue,
                CraftCategory.knitting.rawValue
            ],
            isFeatured: false
        ),
        Vendor(
            id: saltSpringWoolID,
            regionId: Region.saltSpringID,
            name: "Salt Spring Island Wool Co",
            vendorType: .mill,
            accessModel: "Retail + mill tours by appointment",
            address: "Ganges, Salt Spring Island, BC",
            latitude: 48.8550,
            longitude: -123.5050,
            phone: "250-537-4111",
            email: "wool@saltspringwool.ca",
            websiteUrl: "https://www.saltspringwool.ca",
            instagramHandle: "saltspringwoolco",
            craftTags: [
                CraftCategory.knitting.rawValue,
                CraftCategory.crochet.rawValue,
                CraftCategory.handspinning.rawValue,
                CraftCategory.needleWetFelting.rawValue
            ],
            isFeatured: true,
            affiliateCode: "NK-SSIWOOL"
        )
    ]
}
