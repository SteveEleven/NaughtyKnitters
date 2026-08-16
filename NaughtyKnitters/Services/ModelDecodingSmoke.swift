//
//  ModelDecodingSmoke.swift
//  NaughtyKnitters
//
//  Verifies snake_case Postgres payloads decode into app models.
//

import Foundation

enum ModelDecodingSmoke: Sendable {
    nonisolated static func verify() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(iso8601Flexible)

        _ = try decoder.decode(Region.self, from: Data(regionJSON.utf8))
        _ = try decoder.decode(Vendor.self, from: Data(vendorJSON.utf8))
        _ = try decoder.decode(RetailPerk.self, from: Data(perkJSON.utf8))
        _ = try decoder.decode(CommunityEvent.self, from: Data(eventJSON.utf8))
    }

    nonisolated private static func iso8601Flexible(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: value) { return date }

        let basic = ISO8601DateFormatter()
        basic.formatOptions = [.withInternetDateTime]
        if let date = basic.date(from: value) { return date }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Unrecognized date: \(value)"
        )
    }

    nonisolated private static let regionJSON = """
    {
      "id": "A1000001-0000-4000-8000-000000000001",
      "name": "Greater Victoria",
      "sub_area": "Downtown & Fernwood",
      "is_gulf_island": false,
      "ferry_terminal": null,
      "region_pack": "vancouver_island_core",
      "is_active": true
    }
    """

    nonisolated private static let vendorJSON = """
    {
      "id": "B2000001-0000-4000-8000-000000000001",
      "region_id": "A1000001-0000-4000-8000-000000000001",
      "name": "Beehive Wool Shop",
      "vendor_type": "retail_store",
      "access_model": "Walk-in",
      "address": "450 Fort St, Victoria, BC",
      "latitude": 48.4248,
      "longitude": -123.3656,
      "phone": "250-388-6494",
      "email": "info@beehivewool.com",
      "website_url": "https://www.beehivewool.com",
      "instagram_handle": "beehivewoolshop",
      "craft_tags": ["Knitting", "Crochet", "Handspinning"],
      "is_featured": true,
      "affiliate_code": "NK-BEEHIVE"
    }
    """

    nonisolated private static let perkJSON = """
    {
      "id": "C3000001-0000-4000-8000-000000000001",
      "vendor_id": "B2000001-0000-4000-8000-000000000001",
      "offer_title": "10% off local hand-dyed skeins",
      "perk_type": "discount",
      "spend_threshold": 40,
      "promo_code": "NAUGHTY10",
      "redemption_mode": "Show app at counter",
      "valid_until": "2026-12-31T23:59:59Z"
    }
    """

    nonisolated private static let eventJSON = """
    {
      "id": "D4000001-0000-4000-8000-000000000001",
      "vendor_id": "B2000001-0000-4000-8000-000000000001",
      "region_id": "A1000001-0000-4000-8000-000000000001",
      "title": "Wednesday Night Knit Circle",
      "event_type": "sit_and_knit",
      "venue_name": "Beehive Wool Shop",
      "start_time": "2026-08-20T18:30:00Z",
      "is_sponsored": false
    }
    """
}
