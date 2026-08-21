import SwiftUI

enum HelpContext: String, Identifiable {
    case editor
    case photos
    case layouts
    case text
    case stickers
    case backgrounds
    case frames
    case crop
    case globalPages

    var id: String { rawValue }
}

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    let context: HelpContext

    private var sections: [HelpSection] {
        var result = [HelpSection.title(for: context)]
        result.append(contentsOf: [
            HelpSection(
                title: "Sélectionner et placer",
                symbol: "hand.tap",
                text: "Touchez un cadre pour le sélectionner. Faites-le glisser pour le déplacer. Les poignées redimensionnent ou tournent le cadre. Les commandes accessibles proposent les mêmes transformations sans geste multipoint."
            ),
            HelpSection(
                title: "Ajouter des photos",
                symbol: "photo.badge.plus",
                text: "Le panneau Photos importe plusieurs images depuis Photothèque ou Fichiers. Vous pouvez aussi réutiliser les photos d’un autre album. Touchez une miniature pour remplir le cadre sélectionné ou créer un nouveau cadre. Le bouton Remplir l’album ouvre le choix de densité, indique le nombre de photos inutilisées et les répartit seulement après validation."
            ),
            HelpSection(
                title: "Cadre vide",
                symbol: "rectangle.dashed",
                text: "Retirer une photo conserve son cadre. Supprimer retire le cadre entier. Une photo retirée reste disponible dans le panneau tant que vous ne choisissez pas explicitement Supprimer de cet album."
            ),
            HelpSection(
                title: "Cadrer la photo",
                symbol: "crop",
                text: "Une nouvelle photo est centrée et agrandie ou réduite pour couvrir son cadre. En mode Recadrer, glissez-la, pincez pour modifier son échelle ou utilisez Zoom photo. Vous pouvez dézoomer pour révéler le fond ; Réinitialiser restaure la couverture centrée. Annuler abandonne le brouillon et Terminé crée une seule action annulable."
            ),
            HelpSection(
                title: "Modèles, dé et Auto",
                symbol: "rectangle.3.group",
                text: "Le panneau Mise en page applique un modèle à la page active, y compris ses emplacements de texte. Le dé parcourt les autres modèles compatibles sans changer le nombre d’éléments. Auto réorganise les cadres photo remplis après chaque ajout ou retrait ; une transformation manuelle d’un cadre photo le désactive pour cette page."
            ),
            HelpSection(
                title: "Zones de texte",
                symbol: "textformat",
                text: "Le panneau Texte ajoute une zone centrée. L’inspecteur affiche le texte sélectionné et les formats applicables à toute la zone. Modifier le texte et le format ouvre l’éditeur pour agir sur une sélection de caractères. La fenêtre reprend le fond et l’échelle de la page ; Terminer enregistre une seule action et Annuler restaure le contenu initial."
            ),
            HelpSection(
                title: "Stickers",
                symbol: "face.smiling",
                text: "Le panneau Stickers propose les récents, cinq catégories et une recherche par nom ou tag. Touchez pour ajouter au centre ou faites glisser sur la page. Remplacer conserve la transformation ; l’opacité et le retournement restent annulables."
            ),
            HelpSection(
                title: "Fonds",
                symbol: "paintpalette",
                text: "Un fond s’applique immédiatement à la page active. Appliquer à toutes les pages est une commande distincte et annulable."
            ),
            HelpSection(
                title: "Cadres et formes",
                symbol: "square.on.circle",
                text: "Sélectionnez un cadre photo pour choisir son masque, son contour ou un cadre décoratif. La portée Sélection, Page ou Album annonce le nombre de cadres concernés et s’annule en une seule action."
            ),
            HelpSection(
                title: "Ajouter et gérer les pages",
                symbol: "square.grid.2x2",
                text: "Gérer les pages sert à ajouter une page à la fin de l’album, supprimer et réorganiser les pages. Touchez une miniature pour revenir à cette page. Le réglage Ne plus demander désactive la confirmation d’ajout jusqu’à la fermeture de l’album."
            ),
            HelpSection(
                title: "Alertes de qualité",
                symbol: "exclamationmark.triangle",
                text: "Une alerte orange signale une qualité encore acceptable et une alerte rouge une qualité insuffisante pour la taille du cadre. Réduisez le cadre ou rapprochez le zoom photo de sa taille native ; l’original n’est jamais modifié."
            ),
            HelpSection(
                title: "Clavier et précision",
                symbol: "keyboard",
                text: "Avec un cadre sélectionné, les flèches le déplacent de 1 % de la page. Option + flèche utilise le pas précis de 0,25 %. Commande-Z annule, Majuscule-Commande-Z rétablit, Commande-X/C/V coupe, copie ou colle et Commande-S sauvegarde un brouillon à consolider."
            ),
            HelpSection(
                title: "Sauvegarde",
                symbol: "externaldrive.badge.checkmark",
                text: "Chaque commande validée est enregistrée localement. Sauvegarder consolide immédiatement le journal. En cas d’échec, utilisez Réessayer sans fermer l’éditeur."
            )
        ])
        return result
    }

    var body: some View {
        NavigationStack {
            List(sections) { section in
                Section {
                    Text(section.text)
                        .fixedSize(horizontal: false, vertical: true)
                } header: {
                    Label(section.title, systemImage: section.symbol)
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .navigationTitle("Aide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}

private struct HelpSection: Identifiable {
    let id = UUID()
    let title: String
    let symbol: String
    let text: String

    static func title(for context: HelpContext) -> HelpSection {
        switch context {
        case .photos:
            return HelpSection(
                title: "Panneau Photos",
                symbol: "photo.on.rectangle",
                text: "Importez d’abord les originaux dans la photothèque interne de l’album, puis placez chaque occurrence librement ou utilisez le bouton Remplir l’album. Sa fenêtre permet de choisir la densité et de vérifier le nombre de photos inutilisées avant validation, sans supprimer les originaux."
            )
        case .layouts:
            return HelpSection(
                title: "Panneau Mise en page",
                symbol: "rectangle.3.group",
                text: "Filtrez les modèles par nombre de photos et par présence d’une zone de texte. Une zone vide affiche Ajouter du texte uniquement dans l’éditeur et reste absente de la prévisualisation."
            )
        case .text:
            return HelpSection(
                title: "Panneau Texte",
                symbol: "textformat",
                text: "Ajoutez une zone sans recouvrir le canevas. Son contenu et les réglages de toute la zone apparaissent dans l’inspecteur de l’élément ; ouvrez Modifier le texte et le format pour cibler seulement certains caractères ou paragraphes."
            )
        case .stickers:
            return HelpSection(
                title: "Panneau Stickers",
                symbol: "face.smiling",
                text: "Parcourez Récents ou une catégorie, recherchez un nom ou un tag, puis touchez un sticker pour l’ajouter au centre. Sur iPad, vous pouvez aussi le déposer à l’endroit voulu."
            )
        case .backgrounds:
            return HelpSection(
                title: "Panneau Fonds",
                symbol: "paintpalette",
                text: "Chaque page possède son propre fond et reste indépendante des autres pages."
            )
        case .frames:
            return HelpSection(
                title: "Panneau Cadres et formes",
                symbol: "square.on.circle",
                text: "Ce panneau s’active pour un cadre photo sélectionné. Choisissez d’abord la portée, puis une forme, un contour ou un cadre décoratif ; chaque application multiple reste une seule commande."
            )
        case .crop:
            return HelpSection(
                title: "Mode Recadrer",
                symbol: "crop",
                text: "Le cadre reste fixe : seuls le zoom, le point focal, les quarts de tour et le retournement de son contenu changent."
            )
        case .globalPages:
            return HelpSection(
                title: "Gérer les pages",
                symbol: "square.grid.2x2",
                text: "Les miniatures représentent une seule page chacune. Une nouvelle page est toujours ajoutée à la fin de l’album. Il n’existe aucun affichage ni réglage en double page."
            )
        case .editor:
            return HelpSection(
                title: "Éditeur d’album",
                symbol: "rectangle.portrait",
                text: "Composez une seule page active, puis passez à la vue globale ou à la prévisualisation sans modifier le document."
            )
        }
    }
}
