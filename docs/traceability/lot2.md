# Traçabilité — Lot 2

Cette matrice couvre le premier incrément interne du Lot 2 figé par le commit
`d427d4e747dd2de56235341bd661d537a9a31c8e`. La source normative reste
[`spec.md`](../../spec.md), le statut opérationnel
[`SUIVI_PROJET.md`](../../SUIVI_PROJET.md) et les procédures manuelles
[`suivi_tests.md`](../../suivi_tests.md).

Elle ne déclare pas `ACPT-125` réussi : Remplir l’album (`AUT-009…011`) et la
qualification Apple manquent. Les zones de texte éditables, stickers, cadres
décoratifs et presse-papiers multi-types appartiennent aux incréments suivants.

## Contrôles automatisés

| Repère | Sources et tests | Exigences couvertes | Limite |
|---|---|---|---|
| `A-L2-MANIFEST` | `BuiltInLayoutTemplateCatalog.generated.swift`, `ManifestContractTests.testPublishedTemplateManifestHashAndFourVariantsForOneThroughEightPhotos`, `tools/generate_layout_template_catalog.pl` | `TPL-002`, `TPL-003`, `TPL-019`, `TPL-020` | Identité byte à byte et décodage Core ; pas chargement dans Swift Playgrounds |
| `A-L2-PROVENANCE` | `DomainValidator.validateTemplateProvenance`, `DomainValidationTests.testTemplateProvenanceResolvesManifestAndRequiresExactPhotoSlotBijection` | `TPL-022`, `TPL-023`, `DAT-040`, `DAT-042` | Validation de snapshot uniquement ; pas rendu Apple |
| `A-L2-TEMPLATE` | `LayoutTemplateEngine`, cinq tests de `PrototypeEngineTests`, `AlbumApplicationServiceTests.testApplyingBuiltInTemplateIsOneValidatedUndoableCommand`, `testSmallerBuiltInTemplateRequiresConfirmationWithoutPartialCommit`, `testMovingTemplateTextOnlyFreesThatTextProvenance` | `TPL-004…018`, `TPL-021…023`, `RND-002…006` | Transition pure et transaction mémoire ; dialogue, miniatures et toucher restent manuels |
| `A-L2-AUTO` | `AutoLayoutEngine`, `AlbumApplicationService.setAutomaticLayoutEnabled`, commandes structurelles Auto et tests `testAutomaticLayoutRecomposesStructuralPhotoCommandsAndIsUndoable`, `testEnablingAutoOnExistingTemplateRequiresConfirmationAndClearsSlots` | `AUT-001…008`, `AUT-012…019`, `PHO-014`, `DAT-037`, `DAT-043` | `AUT-009…011` non implémentés ; UI et persistance Apple non prouvées |
| `A-L2-UI-PARSE` | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` | structure de `EDT-001…004`, `EDT-019`, `RND-001`, `AUT-001` | Syntaxe seulement, sans type-check SwiftUI ni disponibilité des SF Symbols |

La suite WSL complète compte 131 tests sans échec sur ce candidat. Les
contrats publiés et leurs dix empreintes sont également valides. Ces résultats
ne remplacent aucune fiche iPad.

## Contrôles manuels du candidat

| ID | Objet | Exigences principales | État |
|---|---|---|---|
| `IPAD-L2-001` | Compilation, store Lot 1 et nouvelle interface | `ENV-001…005`, `LOT-003`, `DAT-042`, `DONE-005` | ⚪ `NON TESTÉ` |
| `IPAD-L2-002` | Panneau adaptatif, groupes, filtres et miniatures | `EDT-001`, `EDT-002`, `EDT-006`, `TPL-001…003`, `ACC-021` | ⚪ `NON TESTÉ` |
| `IPAD-L2-003` | Modèle plus grand et commande unique | `TPL-004…006`, `TPL-009`, `TPL-010`, `TPL-014…017`, `DAT-042` | ⚪ `NON TESTÉ` |
| `IPAD-L2-004` | Modèle plus petit et confirmation exacte | `TPL-005…010`, `TPL-016`, `ERR-022` | ⚪ `NON TESTÉ` |
| `IPAD-L2-005` | Dé compatible, cycle et persistance | `RND-001…006`, `TPL-018`, `DAT-042` | ⚪ `NON TESTÉ` |
| `IPAD-L2-006` | Auto, occurrences et transformation manuelle | `AUT-001…008`, `AUT-012…019`, `PHO-014`, `FRM-003` | ⚪ `NON TESTÉ` |
| `IPAD-L2-007` | Densité, portée par page et relance | `AUT-001`, `AUT-003…005`, `AUT-012`, `AUT-015…018`, `DAT-037` | ⚪ `NON TESTÉ` |
| `IPAD-L2-008` | Commandes incompatibles et frontière | `AUT-019`, `EDT-003`, `EDT-004`, `EDT-019`, `ARC-014`, `CAT-009` | ⚪ `NON TESTÉ` |

Les réponses attendues sont `IPAD-L2-nnn OK`, `BLOQUÉ : …` ou `BUG : …`.
Une réussite fonctionnelle peut prouver la compilation indirectement, mais ne
qualifie ni iPhone, ni Xcode, ni Release, ni TestFlight.

## Écarts connus de l’incrément

- Les variantes avec un slot texte sont listées pour vérifier le catalogue,
  mais désactivées jusqu’à l’intégration de `TBX-004` et `TPL-012`.
- Remplir l’album (`AUT-009…011`) n’est pas exposé ; `ACPT-125` reste donc
  incomplet même si `IPAD-L2-001…008` réussissent.
- Aucun sticker ni cadre décoratif n’est persisté avant le gel des assets,
  licences et goldens exigé par `CAT-009`.
- Les textes français sont encore codés dans les vues ; `L10N-002` reste
  ouvert jusqu’au catalogue de chaînes du lot Qualité.
