import CoreFoundation
import Foundation

public enum CanonicalJSONError: Error, Equatable {
    case invalidTopLevel
    case unsupportedValue
    case nonFiniteNumber
}

/// RFC 8785-oriented canonical encoder for the domain's JSON subset.
/// UUID-looking strings are normalized to lowercase to enforce 3:DAT-020.
public enum CanonicalJSON {
    public static func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder.albumPhotoEncoder
        let source = try encoder.encode(value)
        let object = try JSONSerialization.jsonObject(with: source, options: [.fragmentsAllowed])
        return Data(try render(object, keyContext: nil).utf8)
    }

    public static func sha256<T: Encodable>(_ value: T) throws -> String {
        SHA256.hexDigest(try encode(value))
    }

    private static func render(_ value: Any, keyContext: String?) throws -> String {
        if value is NSNull { return "null" }
        if let string = value as? String {
            return try renderString(normalizedIdentifierString(string, key: keyContext))
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return number.boolValue ? "true" : "false"
            }
            let double = number.doubleValue
            guard double.isFinite else { throw CanonicalJSONError.nonFiniteNumber }
            if double == 0 { return "0" }
            let encoded = try JSONSerialization.data(withJSONObject: [number])
            guard var string = String(data: encoded, encoding: .utf8) else {
                throw CanonicalJSONError.unsupportedValue
            }
            string.removeFirst()
            string.removeLast()
            return normalizeNumber(string)
        }
        if let array = value as? [Any] {
            return "[" + (try array.map { try render($0, keyContext: keyContext) })
                .joined(separator: ",") + "]"
        }
        if let dictionary = value as? [String: Any] {
            let keys = dictionary.keys.sorted { lhs, rhs in
                lhs.utf16.lexicographicallyPrecedes(rhs.utf16)
            }
            let pairs = try keys.map { key in
                try renderString(key) + ":" + render(dictionary[key]!, keyContext: key)
            }
            return "{" + pairs.joined(separator: ",") + "}"
        }
        throw CanonicalJSONError.unsupportedValue
    }

    private static func renderString(_ value: String) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: [value])
        guard var result = String(data: data, encoding: .utf8) else {
            throw CanonicalJSONError.unsupportedValue
        }
        result.removeFirst()
        result.removeLast()
        return result.replacingOccurrences(of: "\\/", with: "/")
    }

    /// Bridges Foundation's exponent thresholds to ECMAScript Number/JSON
    /// spelling required by RFC 8785: fixed notation for 1e-6...<1e21.
    private static func normalizeNumber(_ value: String) -> String {
        let lowercase = value.replacingOccurrences(of: "E", with: "e")
        guard let exponentIndex = lowercase.firstIndex(of: "e") else { return lowercase }
        let mantissa = String(lowercase[..<exponentIndex])
        let rawExponent = String(lowercase[lowercase.index(after: exponentIndex)...])
        guard let exponentValue = Int(rawExponent) else { return lowercase }
        let unsignedMantissa = mantissa.first == "-" ? String(mantissa.dropFirst()) : mantissa
        let pieces = unsignedMantissa.split(separator: ".", omittingEmptySubsequences: false)
        let integerDigits = String(pieces[0])
        let fractionalDigits = pieces.count > 1 ? String(pieces[1]) : ""
        let scientificExponent = exponentValue + integerDigits.count - 1
        if scientificExponent >= -6 && scientificExponent < 21 {
            let sign = mantissa.first == "-" ? "-" : ""
            let digits = integerDigits + fractionalDigits
            let decimalIndex = integerDigits.count + exponentValue
            if decimalIndex <= 0 {
                return sign + "0." + String(repeating: "0", count: -decimalIndex) + digits
            }
            if decimalIndex >= digits.count {
                return sign + digits + String(repeating: "0", count: decimalIndex - digits.count)
            }
            let split = digits.index(digits.startIndex, offsetBy: decimalIndex)
            return sign + digits[..<split] + "." + digits[split...]
        }

        let exponentSign = exponentValue >= 0 ? "+" : "-"
        return mantissa + "e" + exponentSign + String(abs(exponentValue))
    }

    private static func normalizedIdentifierString(_ value: String, key: String?) -> String {
        guard let key,
              key == "id" || key.hasSuffix("ID") || key.hasSuffix("IDs")
                || key == "accessibilityOrder" || key == "appliedCommandIDs",
              value.count == 36,
              UUID(uuidString: value) != nil else { return value }
        return value.lowercased()
    }
}

extension JSONEncoder {
    static var albumPhotoEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(AlbumPhotoDateCoding.string(from: date))
        }
        return encoder
    }
}

extension JSONDecoder {
    static var albumPhotoDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = AlbumPhotoDateCoding.date(from: string) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Date RFC 3339 UTC avec millisecondes attendue"
                )
            }
            return date
        }
        return decoder
    }
}

enum AlbumPhotoDateCoding {
    private static func formatter() -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime,
            .withTimeZone
        ]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }

    static func string(from date: Date) -> String {
        formatter().string(from: date)
    }

    static func date(from string: String) -> Date? {
        formatter().date(from: string)
    }
}
