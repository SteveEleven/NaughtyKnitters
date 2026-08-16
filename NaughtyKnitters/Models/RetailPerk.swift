//
//  RetailPerk.swift
//  NaughtyKnitters
//

import Foundation

struct RetailPerk: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var vendorId: UUID
    var offerTitle: String
    var perkType: String
    var spendThreshold: Double
    var promoCode: String?
    var redemptionMode: String
    var validUntil: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case vendorId = "vendor_id"
        case offerTitle = "offer_title"
        case perkType = "perk_type"
        case spendThreshold = "spend_threshold"
        case promoCode = "promo_code"
        case redemptionMode = "redemption_mode"
        case validUntil = "valid_until"
    }

    init(
        id: UUID = UUID(),
        vendorId: UUID,
        offerTitle: String,
        perkType: String,
        spendThreshold: Double = 0,
        promoCode: String? = nil,
        redemptionMode: String = "In-store counter",
        validUntil: Date? = nil
    ) {
        self.id = id
        self.vendorId = vendorId
        self.offerTitle = offerTitle
        self.perkType = perkType
        self.spendThreshold = spendThreshold
        self.promoCode = promoCode
        self.redemptionMode = redemptionMode
        self.validUntil = validUntil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        vendorId = try container.decode(UUID.self, forKey: .vendorId)
        offerTitle = try container.decode(String.self, forKey: .offerTitle)
        perkType = try container.decode(String.self, forKey: .perkType)
        spendThreshold = try container.decodeIfPresent(Double.self, forKey: .spendThreshold) ?? 0
        promoCode = try container.decodeIfPresent(String.self, forKey: .promoCode)
        redemptionMode = try container.decodeIfPresent(String.self, forKey: .redemptionMode) ?? "In-store counter"
        validUntil = try container.decodeIfPresent(Date.self, forKey: .validUntil)
    }

    var isActive: Bool {
        guard let validUntil else { return true }
        return validUntil >= Date()
    }
}

extension RetailPerk {
    static let sampleData: [RetailPerk] = [
        RetailPerk(
            vendorId: Vendor.beehiveID,
            offerTitle: "10% off local hand-dyed skeins",
            perkType: "discount",
            spendThreshold: 40,
            promoCode: "NAUGHTY10",
            redemptionMode: "Show app at counter",
            validUntil: Calendar.current.date(byAdding: .month, value: 3, to: Date())
        ),
        RetailPerk(
            vendorId: Vendor.sookeYarnID,
            offerTitle: "Free needle felting starter kit with $75+",
            perkType: "gift_with_purchase",
            spendThreshold: 75,
            redemptionMode: "In-store counter",
            validUntil: Calendar.current.date(byAdding: .month, value: 2, to: Date())
        ),
        RetailPerk(
            vendorId: Vendor.saltSpringWoolID,
            offerTitle: "Mill tour punch card — 5th visit free",
            perkType: "loyalty",
            spendThreshold: 0,
            promoCode: "MILLTOUR",
            redemptionMode: "Stamp card in app",
            validUntil: Calendar.current.date(byAdding: .year, value: 1, to: Date())
        )
    ]
}
