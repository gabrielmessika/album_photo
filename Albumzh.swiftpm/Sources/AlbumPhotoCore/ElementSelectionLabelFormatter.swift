import Foundation

public enum ElementSelectionLabelFormatter {
    public static func compact(
        type: String,
        detail: String?,
        position: String,
        depth: String,
        maximumLabelCharacters: Int = 45
    ) -> String {
        let separator = " — "
        let trimmedDetail = detail?.trimmingCharacters(in: .whitespacesAndNewlines)
        let fixedCharacters = [type, position, depth]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).count }
            .reduce(0, +)
            + separator.count * 3
        let availableDetailCharacters = max(
            1,
            maximumLabelCharacters - fixedCharacters
        )

        return joined(
            type: type,
            detail: trimmedDetail.map {
                truncated($0, maximumCharacters: availableDetailCharacters)
            },
            position: position,
            depth: depth
        )
    }

    public static func accessible(
        type: String,
        detail: String?,
        position: String,
        depth: String
    ) -> String {
        joined(type: type, detail: detail, position: position, depth: depth)
    }

    private static func joined(
        type: String,
        detail: String?,
        position: String,
        depth: String
    ) -> String {
        [type, detail, position, depth]
            .compactMap { value in
                guard let value else { return nil }
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? nil : trimmed
            }
            .joined(separator: " — ")
    }

    private static func truncated(
        _ value: String,
        maximumCharacters: Int
    ) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let limit = max(1, maximumCharacters)
        guard trimmed.count > limit else { return trimmed }
        guard limit > 1 else { return "…" }
        return "\(trimmed.prefix(limit - 1))…"
    }
}
