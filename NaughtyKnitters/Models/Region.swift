//
//  Region.swift
//  NaughtyKnitters
//

import Foundation

enum RegionPack: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case vancouverIslandCore = "vancouver_island_core"
    case lowerMainlandFraserValley = "lower_mainland_fraser_valley"
    case thompsonOkanagan = "thompson_okanagan"
    case kootenaysNorthernBc = "kootenays_northern_bc"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vancouverIslandCore:
            return "Vancouver Island Core"
        case .lowerMainlandFraserValley:
            return "Lower Mainland & Fraser Valley"
        case .thompsonOkanagan:
            return "Thompson–Okanagan"
        case .kootenaysNorthernBc:
            return "Kootenays & Northern BC"
        }
    }
}

struct Region: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var subArea: String?
    var isGulfIsland: Bool
    var ferryTerminal: String?
    var regionPack: RegionPack
    var isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case subArea = "sub_area"
        case isGulfIsland = "is_gulf_island"
        case ferryTerminal = "ferry_terminal"
        case regionPack = "region_pack"
        case isActive = "is_active"
    }

    init(
        id: UUID = UUID(),
        name: String,
        subArea: String? = nil,
        isGulfIsland: Bool = false,
        ferryTerminal: String? = nil,
        regionPack: RegionPack = .vancouverIslandCore,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.subArea = subArea
        self.isGulfIsland = isGulfIsland
        self.ferryTerminal = ferryTerminal
        self.regionPack = regionPack
        self.isActive = isActive
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        subArea = try container.decodeIfPresent(String.self, forKey: .subArea)
        isGulfIsland = try container.decodeIfPresent(Bool.self, forKey: .isGulfIsland) ?? false
        ferryTerminal = try container.decodeIfPresent(String.self, forKey: .ferryTerminal)
        regionPack = try container.decodeIfPresent(RegionPack.self, forKey: .regionPack) ?? .vancouverIslandCore
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
    }
}

extension Region {
    static let victoriaID = UUID(uuidString: "A1000001-0000-4000-8000-000000000001")!
    static let sookeID = UUID(uuidString: "A1000001-0000-4000-8000-000000000002")!
    static let metchosinID = UUID(uuidString: "A1000001-0000-4000-8000-000000000003")!
    static let saltSpringID = UUID(uuidString: "A1000001-0000-4000-8000-000000000004")!

    static let sampleData: [Region] = [
        Region(
            id: victoriaID,
            name: "Greater Victoria",
            subArea: "Downtown & Fernwood",
            regionPack: .vancouverIslandCore
        ),
        Region(
            id: sookeID,
            name: "Sooke",
            subArea: "West Shore Coast",
            regionPack: .vancouverIslandCore
        ),
        Region(
            id: metchosinID,
            name: "Metchosin",
            subArea: "West Shore Farms",
            regionPack: .vancouverIslandCore
        ),
        Region(
            id: saltSpringID,
            name: "Salt Spring Island",
            subArea: "Southern Gulf Islands",
            isGulfIsland: true,
            ferryTerminal: "Fulford Harbour",
            regionPack: .vancouverIslandCore
        )
    ]
}
