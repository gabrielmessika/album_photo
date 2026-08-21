import Foundation

public enum StickerCatalogCategory: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case travel
    case transport
    case nature
    case weather
    case symbols

    public var localizedName: String {
        switch self {
        case .travel: "Voyage"
        case .transport: "Transport"
        case .nature: "Nature"
        case .weather: "Météo"
        case .symbols: "Symboles"
        }
    }
}
public struct StickerCatalogDefinition: Sendable, Equatable, Hashable, Identifiable {
    public let catalogID: String
    public let localizedName: String
    public let localizedTags: [String]
    public let category: StickerCatalogCategory
    public let dataAssetName: String
    public let contentHash: String
    public let byteCount: Int64
    public let pixelWidth: Int
    public let pixelHeight: Int

    public var id: String { catalogID }
    public var intrinsicAspectRatio: Double { Double(pixelWidth) / Double(pixelHeight) }
    public var reference: CatalogResourceReference {
        CatalogResourceReference(catalogID: catalogID, fallbackContentHash: contentHash)
    }
    public var descriptor: CatalogResourceDescriptor {
        CatalogResourceDescriptor(
            catalogID: catalogID,
            catalogVersion: 1,
            category: .sticker,
            payload: .asset(contentHash: contentHash, mimeType: "image/png", byteCount: byteCount),
            sourceLicense: "OpenAI generated project asset"
        )
    }
}

public enum BuiltInStickerCatalog {
    public static let definitions: [StickerCatalogDefinition] = [
        StickerCatalogDefinition(
            catalogID: "sticker.travel.compass",
            localizedName: "Boussole",
            localizedTags: ["voyage", "boussole", "orientation"],
            category: .travel,
            dataAssetName: "StickerTravelCompassData",
            contentHash: "6418c4bc9fa96b5fd380bfa303a5b11ca89bca10dc4fa360cd9304c6a0091dc0",
            byteCount: 349763,
            pixelWidth: 406,
            pixelHeight: 502
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.travel.suitcase",
            localizedName: "Valise",
            localizedTags: ["voyage", "valise", "bagage"],
            category: .travel,
            dataAssetName: "StickerTravelSuitcaseData",
            contentHash: "c1cb2535e6425838ad479da29a7d066d4a842226277bb656cf3475c8eb5bccad",
            byteCount: 510243,
            pixelWidth: 512,
            pixelHeight: 486
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.travel.passport",
            localizedName: "Carnet de voyage",
            localizedTags: ["voyage", "carnet", "passeport"],
            category: .travel,
            dataAssetName: "StickerTravelPassportData",
            contentHash: "d121470a8ffbde1314331ce6b85df76f05a5087331821e07303ba16f0732b886",
            byteCount: 392876,
            pixelWidth: 454,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.travel.mapPin",
            localizedName: "Carte et repère",
            localizedTags: ["voyage", "carte", "destination"],
            category: .travel,
            dataAssetName: "StickerTravelMapPinData",
            contentHash: "b38a2b4b78a49b1299718fb6a6d24bda7023685f8135b87948b5850a0827b5f0",
            byteCount: 310895,
            pixelWidth: 477,
            pixelHeight: 483
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.travel.camera",
            localizedName: "Appareil photo",
            localizedTags: ["voyage", "photo", "souvenir"],
            category: .travel,
            dataAssetName: "StickerTravelCameraData",
            contentHash: "d66d9ef902caeba1b2ce27986642b5ab567c98b4a7dad5f84e4fd2211ccdafeb",
            byteCount: 427111,
            pixelWidth: 512,
            pixelHeight: 461
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.travel.globe",
            localizedName: "Globe",
            localizedTags: ["voyage", "globe", "monde"],
            category: .travel,
            dataAssetName: "StickerTravelGlobeData",
            contentHash: "3f629389f94c5cac3124c65f2aabe4a57ed474e334f4dcf2ff78d5518600b00b",
            byteCount: 396136,
            pixelWidth: 408,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.travel.tent",
            localizedName: "Tente",
            localizedTags: ["voyage", "camping", "tente"],
            category: .travel,
            dataAssetName: "StickerTravelTentData",
            contentHash: "8e96e19a2cef63e445be6bccac8adb1c1120cc92102af6fd4341974492e51c1a",
            byteCount: 322699,
            pixelWidth: 512,
            pixelHeight: 424
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.travel.mountains",
            localizedName: "Paysage de montagne",
            localizedTags: ["voyage", "montagne", "paysage"],
            category: .travel,
            dataAssetName: "StickerTravelMountainsData",
            contentHash: "21e169896bbc6f0eddea6324fd3beb08de4b62a861981e9d721aebf236865ac2",
            byteCount: 506360,
            pixelWidth: 512,
            pixelHeight: 496
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.transport.bicycle",
            localizedName: "Vélo",
            localizedTags: ["transport", "vélo", "bicyclette"],
            category: .transport,
            dataAssetName: "StickerTransportBicycleData",
            contentHash: "3eb4a8490fbf14a79a13dc64caf13999ad318727f7bafbf2083a11b7b977b1f7",
            byteCount: 332669,
            pixelWidth: 512,
            pixelHeight: 430
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.transport.train",
            localizedName: "Train",
            localizedTags: ["transport", "train", "rail"],
            category: .transport,
            dataAssetName: "StickerTransportTrainData",
            contentHash: "fd71b09741edbe03f707e28fe5d4c450d3d836d82e547c2608d4d23b4c31b2c0",
            byteCount: 460619,
            pixelWidth: 512,
            pixelHeight: 458
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.transport.sailboat",
            localizedName: "Voilier",
            localizedTags: ["transport", "bateau", "voilier"],
            category: .transport,
            dataAssetName: "StickerTransportSailboatData",
            contentHash: "441967d8d8802909c2d1cc217cf82b27f4239371be94dc07bb38c19e3f2e0fa4",
            byteCount: 309734,
            pixelWidth: 431,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.transport.airplane",
            localizedName: "Avion",
            localizedTags: ["transport", "avion", "vol"],
            category: .transport,
            dataAssetName: "StickerTransportAirplaneData",
            contentHash: "16e263a340b26cc8cf96b8156f409265d8e9c5e5e90513394fad8680c8d8c3d8",
            byteCount: 226622,
            pixelWidth: 512,
            pixelHeight: 420
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.transport.camper",
            localizedName: "Camping-car",
            localizedTags: ["transport", "camping-car", "route"],
            category: .transport,
            dataAssetName: "StickerTransportCamperData",
            contentHash: "698f15be2639cb6813920c18133ec30a14ae334a6e605d084ffb3f72da81fbab",
            byteCount: 449985,
            pixelWidth: 512,
            pixelHeight: 450
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.transport.car",
            localizedName: "Voiture",
            localizedTags: ["transport", "voiture", "route"],
            category: .transport,
            dataAssetName: "StickerTransportCarData",
            contentHash: "06dffde1a2a300fd05fa59c1c81de86a228df5db160aa6b2fd9d6cb150424045",
            byteCount: 332204,
            pixelWidth: 512,
            pixelHeight: 386
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.transport.balloon",
            localizedName: "Montgolfière",
            localizedTags: ["transport", "montgolfière", "ciel"],
            category: .transport,
            dataAssetName: "StickerTransportBalloonData",
            contentHash: "03317fb774869e1afc226648c7b2a2d1220f42aa909d6f70ee70dbb77e245e03",
            byteCount: 295803,
            pixelWidth: 376,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.transport.scooter",
            localizedName: "Scooter",
            localizedTags: ["transport", "scooter", "deux-roues"],
            category: .transport,
            dataAssetName: "StickerTransportScooterData",
            contentHash: "9c8ca83e3bb6fb2c7374407e712cc584e1958e21c752a043c2abdbe506473311",
            byteCount: 314148,
            pixelWidth: 512,
            pixelHeight: 497
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.nature.leaf",
            localizedName: "Feuille",
            localizedTags: ["nature", "feuille", "végétal"],
            category: .nature,
            dataAssetName: "StickerNatureLeafData",
            contentHash: "d7b45e757453150eb27e909e5e9e3f0b889845494ec70ebf093363b782c2ff03",
            byteCount: 322389,
            pixelWidth: 447,
            pixelHeight: 495
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.nature.flower",
            localizedName: "Fleur",
            localizedTags: ["nature", "fleur", "jardin"],
            category: .nature,
            dataAssetName: "StickerNatureFlowerData",
            contentHash: "db852c242dcf650a7db339c5c2035b469dc7eb988e25700234af01993d2758ee",
            byteCount: 342177,
            pixelWidth: 407,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.nature.pine",
            localizedName: "Sapin",
            localizedTags: ["nature", "sapin", "forêt"],
            category: .nature,
            dataAssetName: "StickerNaturePineData",
            contentHash: "e19b2d4e9ea4dfa74511e72651afaade4dd3714e0de89c5c320ceebba64cb12d",
            byteCount: 256768,
            pixelWidth: 385,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.nature.seashell",
            localizedName: "Coquillage",
            localizedTags: ["nature", "coquillage", "mer"],
            category: .nature,
            dataAssetName: "StickerNatureSeashellData",
            contentHash: "05ee6ec1894947723e81c4272df1a23dfa93d415fc6d8c61f0c7cf99b4bba37c",
            byteCount: 338395,
            pixelWidth: 432,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.nature.mountains",
            localizedName: "Montagnes",
            localizedTags: ["nature", "montagne", "rivière"],
            category: .nature,
            dataAssetName: "StickerNatureMountainsData",
            contentHash: "68e0a0b271f17b248994e6133142622e8b181de57732507bf5e16ac2633670cc",
            byteCount: 456838,
            pixelWidth: 512,
            pixelHeight: 434
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.nature.mushroom",
            localizedName: "Champignon",
            localizedTags: ["nature", "champignon", "forêt"],
            category: .nature,
            dataAssetName: "StickerNatureMushroomData",
            contentHash: "4e2a452f0afcc53ebf6f8513380614a8368f3fe5e6876a9b988e9f2975502429",
            byteCount: 411330,
            pixelWidth: 425,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.nature.butterfly",
            localizedName: "Papillon",
            localizedTags: ["nature", "papillon", "insecte"],
            category: .nature,
            dataAssetName: "StickerNatureButterflyData",
            contentHash: "a9c645fa16aa6c7e935472c8dad313f124b3ae6d1e661ccd23cc6e6caa7fb4ac",
            byteCount: 431131,
            pixelWidth: 512,
            pixelHeight: 437
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.nature.cactus",
            localizedName: "Cactus",
            localizedTags: ["nature", "cactus", "désert"],
            category: .nature,
            dataAssetName: "StickerNatureCactusData",
            contentHash: "0a2cfb14a5e7ddd3451bcb2f1b0b4078ee49fc04a02ab59f64c0a564414e7f71",
            byteCount: 328780,
            pixelWidth: 370,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.weather.sun",
            localizedName: "Soleil",
            localizedTags: ["météo", "soleil", "beau temps"],
            category: .weather,
            dataAssetName: "StickerWeatherSunData",
            contentHash: "0649e3961e2a74fb16cfe754f3d7aa8b1ebde8b3ec44deb41385c8dab1a273c2",
            byteCount: 421613,
            pixelWidth: 512,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.weather.cloud",
            localizedName: "Nuage",
            localizedTags: ["météo", "nuage", "ciel"],
            category: .weather,
            dataAssetName: "StickerWeatherCloudData",
            contentHash: "ee65c047282702756b427267a2c73093273cb3db061010d0ac22aec024ff167d",
            byteCount: 211594,
            pixelWidth: 512,
            pixelHeight: 338
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.weather.rain",
            localizedName: "Pluie",
            localizedTags: ["météo", "pluie", "averse"],
            category: .weather,
            dataAssetName: "StickerWeatherRainData",
            contentHash: "946e5459e8586965735b3e1693304fb0d0128261ac4a1d93ea218f2a0976aade",
            byteCount: 280213,
            pixelWidth: 477,
            pixelHeight: 502
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.weather.rainbow",
            localizedName: "Arc-en-ciel",
            localizedTags: ["météo", "arc-en-ciel", "couleurs"],
            category: .weather,
            dataAssetName: "StickerWeatherRainbowData",
            contentHash: "5ccf8a22ffb4e972617283d4f2e691794b874a43617aadf9e9da2addb8a2c598",
            byteCount: 264218,
            pixelWidth: 512,
            pixelHeight: 351
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.weather.snowflake",
            localizedName: "Flocon",
            localizedTags: ["météo", "neige", "hiver"],
            category: .weather,
            dataAssetName: "StickerWeatherSnowflakeData",
            contentHash: "4f1080f4f4766d726f6ec0b13a57ec381f0d7e83e8f481672194ea32e5c1c5fe",
            byteCount: 265637,
            pixelWidth: 466,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.weather.lightning",
            localizedName: "Orage",
            localizedTags: ["météo", "orage", "éclair"],
            category: .weather,
            dataAssetName: "StickerWeatherLightningData",
            contentHash: "d52b39a3a2c5802253f17352e506dbfadcd72b7d2503b188cc75089f58d35088",
            byteCount: 297193,
            pixelWidth: 482,
            pixelHeight: 486
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.weather.moon",
            localizedName: "Lune",
            localizedTags: ["météo", "lune", "nuit"],
            category: .weather,
            dataAssetName: "StickerWeatherMoonData",
            contentHash: "34b9a781ac7aa30b8ce6b31d582d792f2284af4c061b4c1b53f8866797926960",
            byteCount: 194975,
            pixelWidth: 435,
            pixelHeight: 470
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.weather.wind",
            localizedName: "Vent",
            localizedTags: ["météo", "vent", "brise"],
            category: .weather,
            dataAssetName: "StickerWeatherWindData",
            contentHash: "770577882daa63224c7ac03ab9c4bcc2fa5a4dca91a5bc68c262531166ad1c0f",
            byteCount: 282281,
            pixelWidth: 488,
            pixelHeight: 466
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.symbols.heart",
            localizedName: "Cœur",
            localizedTags: ["symbole", "cœur", "amour"],
            category: .symbols,
            dataAssetName: "StickerSymbolsHeartData",
            contentHash: "b6548ff505d1ec0191fecd13e9470f825bc760ea93cfe7391e2d913e4c231f28",
            byteCount: 337918,
            pixelWidth: 512,
            pixelHeight: 482
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.symbols.star",
            localizedName: "Étoile",
            localizedTags: ["symbole", "étoile", "favori"],
            category: .symbols,
            dataAssetName: "StickerSymbolsStarData",
            contentHash: "af5c1e11a9788a5daf04828df0b5435cdad65f3f84fbeb6c2cfedb47c8acb799",
            byteCount: 331579,
            pixelWidth: 512,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.symbols.confetti",
            localizedName: "Confettis",
            localizedTags: ["symbole", "confettis", "fête"],
            category: .symbols,
            dataAssetName: "StickerSymbolsConfettiData",
            contentHash: "1d790023ed4227bce4b135ea018a80248715e91b1542b41ae21ee8b26d784acb",
            byteCount: 264019,
            pixelWidth: 449,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.symbols.music",
            localizedName: "Musique",
            localizedTags: ["symbole", "musique", "note"],
            category: .symbols,
            dataAssetName: "StickerSymbolsMusicData",
            contentHash: "e762014b8a54b3d6d92e30c2625c5a25114523f9d363abd25edc41a9fce2d1b8",
            byteCount: 183153,
            pixelWidth: 406,
            pixelHeight: 489
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.symbols.check",
            localizedName: "Validation",
            localizedTags: ["symbole", "validation", "coche"],
            category: .symbols,
            dataAssetName: "StickerSymbolsCheckData",
            contentHash: "ab710939f9bcf9e106dd13ec4f5b2b804a8f28c51b7c84807e5ef97da7403bc1",
            byteCount: 432796,
            pixelWidth: 512,
            pixelHeight: 512
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.symbols.gift",
            localizedName: "Cadeau",
            localizedTags: ["symbole", "cadeau", "anniversaire"],
            category: .symbols,
            dataAssetName: "StickerSymbolsGiftData",
            contentHash: "3ad459db9eb5055228c94c0e8a5c647f02d813f07c58e167786ab4a99d99f35f",
            byteCount: 397424,
            pixelWidth: 467,
            pixelHeight: 496
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.symbols.speech",
            localizedName: "Bulle",
            localizedTags: ["symbole", "bulle", "message"],
            category: .symbols,
            dataAssetName: "StickerSymbolsSpeechData",
            contentHash: "4bdeb378362b642c7b44dab4ec6f6c88f4fe14136387fdc6a397815984731547",
            byteCount: 252655,
            pixelWidth: 438,
            pixelHeight: 392
        ),
        StickerCatalogDefinition(
            catalogID: "sticker.symbols.paw",
            localizedName: "Patte",
            localizedTags: ["symbole", "patte", "animal"],
            category: .symbols,
            dataAssetName: "StickerSymbolsPawData",
            contentHash: "238b4c7cd8b97d3447fbd580c01b1b587e5631228f40ffd5c63cad7b12664411",
            byteCount: 383574,
            pixelWidth: 505,
            pixelHeight: 462
        )
    ]

    public static func definition(id: String, version: Int = 1) -> StickerCatalogDefinition? {
        guard version == 1 else { return nil }
        return definitions.first { $0.catalogID == id }
    }
}

public struct CatalogPixelInsets: Sendable, Equatable, Hashable {
    public let top: Int
    public let left: Int
    public let bottom: Int
    public let right: Int
}

public struct CatalogFractionalInsets: Sendable, Equatable, Hashable {
    public let top: Double
    public let left: Double
    public let bottom: Double
    public let right: Double
}

public struct DecorativeFrameCatalogDefinition: Sendable, Equatable, Hashable, Identifiable {
    public let catalogID: String
    public let localizedName: String
    public let dataAssetName: String
    public let contentHash: String
    public let byteCount: Int64
    public let pixelWidth: Int
    public let pixelHeight: Int
    public let sourceCapInsetsPixels: CatalogPixelInsets
    public let destinationCapInsets: CatalogFractionalInsets

    public var id: String { catalogID }
    public var reference: CatalogResourceReference {
        CatalogResourceReference(catalogID: catalogID, fallbackContentHash: contentHash)
    }
    public var descriptor: CatalogResourceDescriptor {
        CatalogResourceDescriptor(
            catalogID: catalogID,
            catalogVersion: 1,
            category: .decorativeFrame,
            payload: .asset(contentHash: contentHash, mimeType: "image/png", byteCount: byteCount),
            sourceLicense: "OpenAI generated project asset"
        )
    }
}

public enum BuiltInDecorativeFrameCatalog {
    public static let definitions: [DecorativeFrameCatalogDefinition] = [
        DecorativeFrameCatalogDefinition(
            catalogID: "frame.whiteBorder",
            localizedName: "Bord blanc",
            dataAssetName: "FrameWhiteBorderData",
            contentHash: "d860107656a6006308885ee32e2394efdd06cdab0a08b57b664faee83b70a85b",
            byteCount: 109207,
            pixelWidth: 512,
            pixelHeight: 512,
            sourceCapInsetsPixels: CatalogPixelInsets(top: 128, left: 128, bottom: 128, right: 128),
            destinationCapInsets: CatalogFractionalInsets(top: 0.2, left: 0.2, bottom: 0.2, right: 0.2)
        ),
        DecorativeFrameCatalogDefinition(
            catalogID: "frame.blackBorder",
            localizedName: "Bord noir",
            dataAssetName: "FrameBlackBorderData",
            contentHash: "7d569d8954ed4b6a79f2da3c0983c7e5aef75207108dd910f8b8fe0aee1a2a2d",
            byteCount: 97667,
            pixelWidth: 512,
            pixelHeight: 512,
            sourceCapInsetsPixels: CatalogPixelInsets(top: 128, left: 128, bottom: 128, right: 128),
            destinationCapInsets: CatalogFractionalInsets(top: 0.2, left: 0.2, bottom: 0.2, right: 0.2)
        ),
        DecorativeFrameCatalogDefinition(
            catalogID: "frame.kraftTape",
            localizedName: "Ruban kraft",
            dataAssetName: "FrameKraftTapeData",
            contentHash: "03f7508cf6fad8784720f99cf54655e3acf94c88cd8cbe8178440c94b106db9a",
            byteCount: 272142,
            pixelWidth: 512,
            pixelHeight: 512,
            sourceCapInsetsPixels: CatalogPixelInsets(top: 128, left: 128, bottom: 128, right: 128),
            destinationCapInsets: CatalogFractionalInsets(top: 0.2, left: 0.2, bottom: 0.2, right: 0.2)
        ),
        DecorativeFrameCatalogDefinition(
            catalogID: "frame.travelStamp",
            localizedName: "Tampon voyage",
            dataAssetName: "FrameTravelStampData",
            contentHash: "b538e43249d95cf2c8a49aae6f2b109887ca60b2efcd22e496ef2477d98efa6b",
            byteCount: 243510,
            pixelWidth: 512,
            pixelHeight: 512,
            sourceCapInsetsPixels: CatalogPixelInsets(top: 128, left: 128, bottom: 128, right: 128),
            destinationCapInsets: CatalogFractionalInsets(top: 0.2, left: 0.2, bottom: 0.2, right: 0.2)
        ),
        DecorativeFrameCatalogDefinition(
            catalogID: "frame.botanical",
            localizedName: "Feuillage",
            dataAssetName: "FrameBotanicalData",
            contentHash: "681830fec16c90fa19d92e3d7e3d58c0c9dd64aa8a758e9f5a60263dc14cbd90",
            byteCount: 336018,
            pixelWidth: 512,
            pixelHeight: 512,
            sourceCapInsetsPixels: CatalogPixelInsets(top: 128, left: 128, bottom: 128, right: 128),
            destinationCapInsets: CatalogFractionalInsets(top: 0.2, left: 0.2, bottom: 0.2, right: 0.2)
        ),
        DecorativeFrameCatalogDefinition(
            catalogID: "frame.instantPhoto",
            localizedName: "Photo instantanée",
            dataAssetName: "FrameInstantPhotoData",
            contentHash: "51d7992db7ef3f9793cc1fa83a8ffec03ea0dbf6aef1631aec61d1daa26209ce",
            byteCount: 139477,
            pixelWidth: 512,
            pixelHeight: 512,
            sourceCapInsetsPixels: CatalogPixelInsets(top: 128, left: 128, bottom: 128, right: 128),
            destinationCapInsets: CatalogFractionalInsets(top: 0.2, left: 0.2, bottom: 0.2, right: 0.2)
        )
    ]

    public static func definition(id: String, version: Int = 1) -> DecorativeFrameCatalogDefinition? {
        guard version == 1 else { return nil }
        return definitions.first { $0.catalogID == id }
    }
}
