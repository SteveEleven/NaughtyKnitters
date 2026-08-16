//
//  CommunityEvent.swift
//  NaughtyKnitters
//

import Foundation

struct CommunityEvent: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var vendorId: UUID?
    var regionId: UUID?
    var title: String
    var eventType: String
    var venueName: String?
    var startTime: Date?
    var isSponsored: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case vendorId = "vendor_id"
        case regionId = "region_id"
        case title
        case eventType = "event_type"
        case venueName = "venue_name"
        case startTime = "start_time"
        case isSponsored = "is_sponsored"
    }

    init(
        id: UUID = UUID(),
        vendorId: UUID? = nil,
        regionId: UUID? = nil,
        title: String,
        eventType: String,
        venueName: String? = nil,
        startTime: Date? = nil,
        isSponsored: Bool = false
    ) {
        self.id = id
        self.vendorId = vendorId
        self.regionId = regionId
        self.title = title
        self.eventType = eventType
        self.venueName = venueName
        self.startTime = startTime
        self.isSponsored = isSponsored
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        vendorId = try container.decodeIfPresent(UUID.self, forKey: .vendorId)
        regionId = try container.decodeIfPresent(UUID.self, forKey: .regionId)
        title = try container.decode(String.self, forKey: .title)
        eventType = try container.decode(String.self, forKey: .eventType)
        venueName = try container.decodeIfPresent(String.self, forKey: .venueName)
        startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
        isSponsored = try container.decodeIfPresent(Bool.self, forKey: .isSponsored) ?? false
    }
}

extension CommunityEvent {
    static let sampleData: [CommunityEvent] = [
        CommunityEvent(
            vendorId: Vendor.beehiveID,
            regionId: Region.victoriaID,
            title: "Wednesday Night Knit Circle",
            eventType: "sit_and_knit",
            venueName: "Beehive Wool Shop",
            startTime: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            isSponsored: false
        ),
        CommunityEvent(
            vendorId: Vendor.sookeYarnID,
            regionId: Region.sookeID,
            title: "Beginner Crochet Workshop",
            eventType: "workshop",
            venueName: "Sooke Yarn & Fibre",
            startTime: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
            isSponsored: true
        ),
        CommunityEvent(
            vendorId: Vendor.parryBayID,
            regionId: Region.metchosinID,
            title: "Farm Gate Fibre Day",
            eventType: "market",
            venueName: "Parry Bay Sheep Farm",
            startTime: Calendar.current.date(byAdding: .day, value: 9, to: Date()),
            isSponsored: false
        ),
        CommunityEvent(
            vendorId: Vendor.saltSpringWoolID,
            regionId: Region.saltSpringID,
            title: "Gulf Islands Yarn Crawl Kickoff",
            eventType: "market",
            venueName: "Ganges Market Square",
            startTime: Calendar.current.date(byAdding: .day, value: 14, to: Date()),
            isSponsored: true
        )
    ]
}
