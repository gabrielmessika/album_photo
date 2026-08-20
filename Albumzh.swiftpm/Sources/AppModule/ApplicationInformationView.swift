import Foundation
import SwiftUI

enum ApplicationBuildInformation {
    // Git remplace cette balise dans les ZIP/tarballs grâce à export-subst.
    // Un build Xcode peut fournir la même valeur via AlbumGitCommit.
    static let archivedGitCommit = "$Format:%H$"

    static var versionNumber: String {
        bundleValue(for: "CFBundleShortVersionString") ?? "0.1.0"
    }

    static var buildNumber: String {
        bundleValue(for: "CFBundleVersion") ?? "1"
    }

    static var gitCommit: String {
        normalizedCommit(bundleValue(for: "AlbumGitCommit"))
            ?? normalizedCommit(archivedGitCommit)
            ?? "Non estampillé"
    }

    static var versionAndBuild: String {
        "\(versionNumber) (\(buildNumber))"
    }

    private static func bundleValue(for key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return value
    }

    private static func normalizedCommit(_ value: String?) -> String? {
        guard let value,
              value.count == 40,
              value.allSatisfy(\.isHexDigit) else {
            return nil
        }
        return value.lowercased()
    }
}

struct ApplicationInformationView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Application") {
                    LabeledContent("Version") {
                        Text(ApplicationBuildInformation.versionAndBuild)
                            .monospacedDigit()
                    }
                }

                Section("Code source") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Commit")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(ApplicationBuildInformation.gitCommit)
                            .font(.system(.footnote, design: .monospaced))
                            .textSelection(.enabled)
                            .accessibilityLabel(
                                "Commit \(ApplicationBuildInformation.gitCommit)"
                            )
                    }
                }
            }
            .navigationTitle("Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
