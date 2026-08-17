# Traçabilité — Lot 2

Cette matrice couvre le premier incrément interne du Lot 2, d’abord testé au
commit `d427d4e747dd2de56235341bd661d537a9a31c8e`, puis corrigé dans le candidat
`024a60bcd7b7a837497a5d6a00e8e42cacfd9366`. L’ajustement de navigation est
figé dans `b86c4b323e0b8d2cfe2fc2e0394ff9d5f3e4e0b4` et réussi sous
`IPAD-L2-013`. L’évolution suivante ajoute en fin d’album avec une confirmation
désactivable pour la seule session ; elle est figée dans
`02430b16f2853c01dbcafc88d48cd40c48373c4c` et sa régression
`IPAD-L2-014` reste à exécuter. La source normative reste
[`spec.md`](../../spec.md), le statut opérationnel
[`SUIVI_PROJET.md`](../../SUIVI_PROJET.md) et les procédures manuelles
[`suivi_tests.md`](../../suivi_tests.md).

Elle ne déclare pas `ACPT-125` réussi : Remplir l’album (`AUT-009…011`) manque,
et `IPAD-L2-008` reste bloqué pour la seule largeur compacte. Les échecs
historiques `IPAD-L2-002` et `004` sont couverts par les régressions réussies
`010` et `011`. Les zones de texte éditables, stickers, cadres décoratifs et
presse-papiers multi-types appartiennent aux incréments suivants.

## Contrôles automatisés

| Repère | Sources et tests | Exigences couvertes | Limite |
|---|---|---|---|
| `A-L2-MANIFEST` | `BuiltInLayoutTemplateCatalog.generated.swift`, `ManifestContractTests.testPublishedTemplateManifestHashAndFourVariantsForOneThroughEightPhotos`, `tools/generate_layout_template_catalog.pl` | `TPL-002`, `TPL-003`, `TPL-019`, `TPL-020` | Identité byte à byte et décodage Core ; pas chargement dans Swift Playgrounds |
| `A-L2-PROVENANCE` | `DomainValidator.validateTemplateProvenance`, `DomainValidationTests.testTemplateProvenanceResolvesManifestAndRequiresExactPhotoSlotBijection` | `TPL-022`, `TPL-023`, `DAT-040`, `DAT-042` | Validation de snapshot uniquement ; pas rendu Apple |
| `A-L2-TEMPLATE` | `LayoutTemplateEngine`, cinq tests de `PrototypeEngineTests`, `AlbumApplicationServiceTests.testApplyingBuiltInTemplateIsOneValidatedUndoableCommand`, `testSmallerBuiltInTemplateRequiresConfirmationWithoutPartialCommit`, `testMovingTemplateTextOnlyFreesThatTextProvenance` | `TPL-004…018`, `TPL-021…023`, `RND-002…006` | Transition pure et transaction mémoire ; dialogue, miniatures et toucher restent manuels |
| `A-L2-AUTO` | `AutoLayoutEngine`, `AlbumApplicationService.setAutomaticLayoutEnabled`, commandes structurelles Auto et tests `testAutomaticLayoutRecomposesStructuralPhotoCommandsAndIsUndoable`, `testEnablingAutoOnExistingTemplateRequiresConfirmationAndClearsSlots` | `AUT-001…008`, `AUT-012…019`, `PHO-014`, `DAT-037`, `DAT-043` | `AUT-009…011` non implémentés ; UI et persistance Apple non prouvées |
| `A-L2-UI-PARSE` | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` | structure de `EDT-001…004`, `EDT-019`, `RND-001`, `AUT-001` | Syntaxe seulement, sans type-check SwiftUI ni disponibilité des SF Symbols |
| `A-L2-UI-CONTRACT` | `ManifestContractTests.testPageWorkspaceUsesConfirmedAppendAndExplicitPageManagementLabel` | `EDT-003`, `EDT-008`, `EDT-016`, `EDT-020`, `PAG-002`, `PAG-013`, `PAG-017` | Vérifie les deux raccords à la confirmation, le réglage temporaire et l’ajout Core en fin ; pas le rendu ni le toucher Apple |
| `A-L2-SELECTION-LABEL` | `ElementSelectionLabelFormatter`, `ElementSelectionLabelFormatterTests` | `ELM-014`, `ACC-002` | Prouve que seule la partie nom/extrait est bornée et que le libellé accessible reste complet ; rendu du menu Apple manuel |

La suite WSL complète compte 134 tests sans échec après l’ajout en fin d’album
et le nouveau parcours de confirmation. Les
contrats publiés et leurs dix empreintes sont également valides. Ces résultats
ne remplacent aucune fiche iPad.

## Contrôles manuels du candidat

| ID | Objet | Exigences principales | État |
|---|---|---|---|
| `IPAD-L2-001` | Compilation, store Lot 1 et nouvelle interface | `ENV-001…005`, `LOT-003`, `DAT-042`, `DONE-005` | 🟢 `RÉUSSI` |
| `IPAD-L2-002` | Panneau adaptatif, groupes, filtres et miniatures | `EDT-001`, `EDT-002`, `EDT-006`, `TPL-001…003`, `ACC-021` | 🔴 `ÉCHOUÉ` — panneaux légèrement rognés en portrait |
| `IPAD-L2-003` | Modèle plus grand et commande unique | `TPL-004…006`, `TPL-009`, `TPL-010`, `TPL-014…017`, `DAT-042` | 🟢 `RÉUSSI` |
| `IPAD-L2-004` | Modèle plus petit et confirmation exacte | `TPL-005…010`, `TPL-016`, `ERR-022` | 🔴 `ÉCHOUÉ` — Appliquer sans effet |
| `IPAD-L2-005` | Dé compatible, cycle et persistance | `RND-001…006`, `TPL-018`, `DAT-042` | 🟢 `RÉUSSI` — ergonomie du dé à revoir |
| `IPAD-L2-006` | Auto, occurrences et transformation manuelle | `AUT-001…008`, `AUT-012…019`, `PHO-014`, `FRM-003` | 🟢 `RÉUSSI` |
| `IPAD-L2-007` | Densité, portée par page et relance | `AUT-001`, `AUT-003…005`, `AUT-012`, `AUT-015…018`, `DAT-037` | 🟢 `RÉUSSI` |
| `IPAD-L2-008` | Commandes incompatibles et frontière | `AUT-019`, `EDT-003`, `EDT-004`, `EDT-019`, `ARC-014`, `CAT-009` | 🟠 `BLOQUÉ` — largeur compacte inaccessible sur cet iPad dans Swift Playgrounds |
| `IPAD-L2-009` | Compilation du correctif et compatibilité du store | `ENV-001…005`, `LOT-003`, `DAT-042`, `DONE-005` | 🟢 `RÉUSSI` |
| `IPAD-L2-010` | Marges, panneau droit et replis indépendants | `EDT-002`, `EDT-006`, `EDT-021`, `ACC-006`, `ACC-021` | 🟢 `RÉUSSI` |
| `IPAD-L2-011` | Confirmation Appliquer pour un modèle plus petit | `TPL-005…010`, `TPL-016`, `ERR-022` | 🟢 `RÉUSSI` |
| `IPAD-L2-012` | Sélection à nom long et commande aléatoire explicite | `ELM-014`, `ACC-002`, `RND-001…005`, `TPL-018`, `EDT-020` | 🟢 `RÉUSSI` |
| `IPAD-L2-013` | Ajouter une page sous le canevas et Gérer les pages | `EDT-003`, `EDT-008`, `EDT-012`, `EDT-016`, `EDT-020`, `PAG-002`, `PAG-013…015`, `PHO-004`, `PHO-011`, `ACC-002`, `ACC-021` | 🟢 `RÉUSSI` |
| `IPAD-L2-014` | Ajout en fin, confirmation et réglage temporaire | `ENV-001…005`, `EDT-008`, `EDT-012`, `EDT-016`, `PAG-002`, `PAG-013…017`, `UND-001`, `UND-002`, `SAV-001`, `ACC-002`, `ACC-006`, `ACC-021` | ⚪ `NON TESTÉ` |

Les réponses attendues sont `IPAD-L2-nnn OK`, `BLOQUÉ : …` ou `BUG : …`.
Une réussite fonctionnelle peut prouver la compilation indirectement, mais ne
qualifie ni iPhone, ni Xcode, ni Release, ni TestFlight.

Le correctif `024a60b…` ne change aucun verdict historique `001…008`. Il
capture la requête et le `pageID` du dialogue Appliquer, ajoute les marges et
les replis indépendants du panneau droit, borne uniquement le détail visible du
sélecteur d’élément et déplace le dé dans Mise en page. Les contrôles
`009…012` le qualifient désormais sur iPad par le retour global « tous les
tests sont ok », sans capture ni détail par étape. Cette preuve est limitée à
ces quatre fiches. Le menu Plus n’est pas demandé au plein écran iPad :
`APPLE-L2-001` reste ⚪ et vérifiera `EDT-004`, Ajouter une page et Gérer les
pages sur iPhone ou dans un environnement Xcode réellement compact.

Le candidat `b86c4b3…` modifie ensuite la barre sous le canevas et le libellé
du mode pages. `IPAD-L2-013` réussit cette surface modifiée sur le retour
« tests ok » ; les réussites `009…012` restent limitées à leurs surfaces.
L’évolution ultérieure vers l’ajout en fin avec confirmation rend cette preuve
insuffisante pour le nouveau parcours ; `IPAD-L2-014` vise exactement
`02430b1…` sans modifier le verdict historique de `013`.

| ID Apple différé | Objet | Exigences principales | État |
|---|---|---|---|
| `APPLE-L2-001` | Barre compacte, Gérer les pages, confirmation et menu Plus sur iPhone/Xcode | `EDT-003`, `EDT-004`, `EDT-008`, `EDT-016`, `EDT-020`, `PAG-013`, `PAG-017`, `ACC-002`, `ACC-021` | ⚪ `NON TESTÉ` |

## Écarts connus de l’incrément

- Les variantes avec un slot texte sont listées pour vérifier le catalogue,
  mais désactivées jusqu’à l’intégration de `TBX-004` et `TPL-012`.
- Remplir l’album (`AUT-009…011`) n’est pas exposé ; `ACPT-125` reste donc
  incomplet même si `IPAD-L2-001…008` réussissent.
- Aucun sticker ni cadre décoratif n’est persisté avant le gel des assets,
  licences et goldens exigé par `CAT-009`.
- Les textes français sont encore codés dans les vues ; `L10N-002` reste
  ouvert jusqu’au catalogue de chaînes du lot Qualité.
- Le candidat initial gardait un rail et un inspecteur légèrement rognés en
  portrait ; `IPAD-L2-010` valide les marges et replis du correctif.
- La confirmation Appliquer du candidat initial ne publiait aucun changement ;
  `IPAD-L2-011` valide désormais la requête capturée du correctif.
- La troncature ciblée du nom et la nouvelle commande de dé dans Mise en page
  sont validées sur l’iPad par `IPAD-L2-012` ; la matrice iPhone/Xcode reste
  différée.
- L’action rapide et le libellé Gérer les pages de `b86c4b3…` sont validés par
  `IPAD-L2-013`. L’ajout désormais placé en fin d’album, la nouvelle fenêtre,
  sa case et la réinitialisation à la fermeture restent à requalifier sur iPad
  par `IPAD-L2-014` sur `02430b1…`.
