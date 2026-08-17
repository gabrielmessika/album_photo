# Traçabilité — Lot 2

Cette matrice couvre le premier incrément interne du Lot 2, d’abord testé au
commit `d427d4e747dd2de56235341bd661d537a9a31c8e`, puis corrigé dans le candidat
`024a60bcd7b7a837497a5d6a00e8e42cacfd9366`. L’ajustement de navigation est
figé dans `b86c4b323e0b8d2cfe2fc2e0394ff9d5f3e4e0b4` et réussi sous
`IPAD-L2-013`. L’évolution suivante ajoute en fin d’album avec une confirmation
désactivable pour la seule session ; elle est figée dans
`02430b16f2853c01dbcafc88d48cd40c48373c4c` et sa régression
`IPAD-L2-014` échoue sur la taille et le défilement de la fenêtre, malgré les
autres comportements déclarés corrects. La correction d’adaptation est figée
dans `8aa7f566de775c15ddf5a9e702a01ed5e9fdb640`, mais `IPAD-L2-015` échoue :
la fenêtre est minuscule et illisible. La seconde correction, à cadre iPad
explicite et présentation compacte native, est figée dans
`7d8772c6d87a769a239b4f9eafabe74c8c126681`, mais `IPAD-L2-016` échoue :
l’app se fige et la confirmation ne s’affiche pas. Le correctif suivant retire
la feuille système au profit d’un dialogue interne centré et bloquant. Il est
figé dans `57afa71e3eeac8b48f05e0aaa719cf77e8a97834` et `IPAD-L2-017` réussit
selon le retour global « c’est ok ». Remplir l’album (`AUT-009…011`) est
maintenant implémenté dans le Core, le service et le panneau Photos au commit
`781539603d6b98523fe48326ee49e24288dfa09b` ; `IPAD-L2-018` le qualifie sur
l’iPad déclaré selon le retour global « les tests sont ok », sans capture ni
détail par étape. Le retour demande ensuite une action compacte ouvrant le
choix de densité et le compteur dans un dialogue, ainsi qu’un cadrage initial
couvrant pour toute nouvelle affectation. L’adaptation est figée dans
`3944fae199b2eb37c7b1f0a1aae5558197455b87`, passe 139 tests Core et réussit
`IPAD-L2-019` selon le retour global « tout est ok ». Le candidat suivant,
`d882183d31de7ed6078c70f9e79a80d6ba994dd6`, active les zones de texte et
passe 146 tests Core, mais `IPAD-L2-020` échoue dès la compilation Apple. Le
correctif `0f4b16c6c6435c29ca44da4e2726fac210add520` adopte une portée métier imbriquée et une contrainte par
attribut modifiable ; `IPAD-L2-021` reprend la qualification complète. La
source normative reste
[`spec.md`](../../spec.md), le statut opérationnel
[`SUIVI_PROJET.md`](../../SUIVI_PROJET.md) et les procédures manuelles
[`suivi_tests.md`](../../suivi_tests.md).

Elle ne déclare pas `ACPT-125` réussi : Remplir l’album, son dialogue compact et
le cadrage couvrant sont qualifiés jusqu’à `IPAD-L2-019`, mais les zones de
texte et les autres sorties du lot restent à valider ; `IPAD-L2-008` reste
bloqué pour la seule largeur compacte. Les échecs
historiques `IPAD-L2-002` et `004` sont couverts par les régressions réussies
`010` et `011`. Les stickers, cadres décoratifs et le presse-papiers
multi-types appartiennent aux incréments suivants.

## Contrôles automatisés

| Repère | Sources et tests | Exigences couvertes | Limite |
|---|---|---|---|
| `A-L2-MANIFEST` | `BuiltInLayoutTemplateCatalog.generated.swift`, `ManifestContractTests.testPublishedTemplateManifestHashAndFourVariantsForOneThroughEightPhotos`, `tools/generate_layout_template_catalog.pl` | `TPL-002`, `TPL-003`, `TPL-019`, `TPL-020` | Identité byte à byte et décodage Core ; pas chargement dans Swift Playgrounds |
| `A-L2-PROVENANCE` | `DomainValidator.validateTemplateProvenance`, `DomainValidationTests.testTemplateProvenanceResolvesManifestAndRequiresExactPhotoSlotBijection` | `TPL-022`, `TPL-023`, `DAT-040`, `DAT-042` | Validation de snapshot uniquement ; pas rendu Apple |
| `A-L2-TEMPLATE` | `LayoutTemplateEngine`, cinq tests de `PrototypeEngineTests`, `AlbumApplicationServiceTests.testApplyingBuiltInTemplateIsOneValidatedUndoableCommand`, `testSmallerBuiltInTemplateRequiresConfirmationWithoutPartialCommit`, `testMovingTemplateTextOnlyFreesThatTextProvenance` | `TPL-004…018`, `TPL-021…023`, `RND-002…006` | Transition pure et transaction mémoire ; dialogue, miniatures et toucher restent manuels |
| `A-L2-AUTO` | `AutoLayoutEngine`, `AlbumFillEngine`, `PhotoCropGeometry.initialPlacement`, `AlbumApplicationService.setAutomaticLayoutEnabled`/`fillAlbum`, commandes structurelles Auto et tests de recomposition, remplissage, cadrage couvrant et transaction | `AUT-001…019`, `PHO-014`, `FRM-004`, `FRM-009`, `CRP-001`, `CRP-005`, `TPL-005`, `UND-001`, `DAT-037`, `DAT-043` | Tri, groupes, pages, assets, cadrage après géométrie finale et transaction prouvés dans le Core ; nouvelle UI et persistance Apple non prouvées |
| `A-L2-UI-PARSE` | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` | structure de `EDT-001…004`, `EDT-019`, `RND-001`, `AUT-001` | Syntaxe seulement, sans type-check SwiftUI ni disponibilité des SF Symbols |
| `A-L2-UI-CONTRACT` | `ManifestContractTests.testPageWorkspaceUsesConfirmedAppendAndExplicitPageManagementLabel`, `testPhotosPanelExposesConfirmedAlbumFillWithEveryDensity` | `EDT-001`, `EDT-003`, `EDT-008`, `EDT-016`, `EDT-020`, `PAG-002`, `PAG-013`, `PAG-017`, `AUT-009…011` | Vérifie le bouton compact, l’absence de groupe permanent, le dialogue interne, les trois densités, Annuler/Valider et le service de remplissage ; pas le rendu Apple |
| `A-L2-SELECTION-LABEL` | `ElementSelectionLabelFormatter`, `ElementSelectionLabelFormatterTests` | `ELM-014`, `ACC-002` | Prouve que seule la partie nom/extrait est bornée et que le libellé accessible reste complet ; rendu du menu Apple manuel |
| `A-L2-TEXT-DOMAIN` | `BuiltInTextFontCatalog`, `TextPrototypeEngine`, `TextInitialStyleEngine`, `TextEditingPrototypeTests`, tests de service et de modèles | `TBX-001…020`, `TBX-023…025`, `TXA-004`, `TXA-005`, `TPL-012`, `TPL-013`, `TPL-017` | Prouve les primitives de modèles, styles persistants, contraste initial, limite, hauteur/débordement, géométrie et atomicité dans le Core ; pas l’éditeur Apple ni les exigences intégrées complètes |
| `A-L2-TEXT-UI` | `AlbumTextEditorView`, `PageCanvasView`, `EditorViewModel`, `ManifestContractTests.testTextEditorUsesNativeAttributedSelectionAndActivatesTextTemplates` | `TBX-002…017`, `TBX-020`, `TBX-021`, `TBX-024`, `TXA-001`, `TXA-002` | Le contrat source vérifie notamment la portée métier imbriquée et une contrainte par `AttributeKey`, et le parse reste syntaxique ; API riches, clavier, sélection, collage, rendu et accessibilité doivent compiler et être testés sur Apple |

La suite WSL complète compte 146 tests sans échec après l’ajout du texte,
du cadrage couvrant et du dialogue compact. Les
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
| `IPAD-L2-014` | Ajout en fin, confirmation et réglage temporaire | `ENV-001…005`, `EDT-008`, `EDT-012`, `EDT-016`, `PAG-002`, `PAG-013…017`, `UND-001`, `UND-002`, `SAV-001`, `ACC-002`, `ACC-006`, `ACC-021` | 🔴 `ÉCHOUÉ` — fenêtre trop large et trop basse ; pied de texte après défilement |
| `IPAD-L2-015` | Taille intrinsèque et lisibilité de la confirmation | `ENV-001…005`, `PAG-017`, `ACC-002`, `ACC-006`, `ACC-021` | 🔴 `ÉCHOUÉ` — fenêtre minuscule et illisible |
| `IPAD-L2-016` | Cadre lisible de la confirmation | `ENV-001…005`, `PAG-017`, `ACC-002`, `ACC-006`, `ACC-021` | 🔴 `ÉCHOUÉ` — app figée, aucune confirmation affichée |
| `IPAD-L2-017` | Dialogue interne sans gel | `ENV-001…005`, `PAG-017`, `ACC-002`, `ACC-006`, `ACC-021` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-018` | Remplir l’album, trois densités et commande unique | `AUT-009…012`, `FRM-009`, `TPL-005`, `UND-001`, `ACC-002`, `ACC-006`, `ACC-021` | 🟢 `RÉUSSI` — candidat `7815396…`, retour global sans capture ni détail par étape |
| `IPAD-L2-019` | Bouton compact, dialogue de densité et cadrage couvrant | `DEC-07`, section 3.1, `AUT-002`, `AUT-004`, `AUT-009…011`, `PHO-005`, `PHO-006`, `PHO-014`, `FRM-004`, `FRM-009`, `CRP-001`, `CRP-004…007`, `ACC-002`, `ACC-006`, `ACC-021` | 🟢 `RÉUSSI` — candidat `3944fae…`, retour global sans capture ni détail par étape |
| `IPAD-L2-020` | Création, édition riche et rendu des zones de texte | `TBX-001…010`, `TBX-012…020`, `TBX-023…025`, `TPL-012`, `TPL-013`, `TPL-017`, `TXA-001`, `TXA-002`, `TXA-004`, `ACC-002`, `ACC-006`, `ACC-021` | 🔴 `ÉCHOUÉ` — compilation d’`AlbumTextEditorView` impossible sur `d882183…` |
| `IPAD-L2-021` | Compilation corrigée et qualification complète des zones de texte | `TBX-001…010`, `TBX-012…020`, `TBX-023…025`, `TPL-012`, `TPL-013`, `TPL-017`, `TXA-001`, `TXA-002`, `TXA-004`, `ACC-002`, `ACC-006`, `ACC-021` | ⚪ `NON TESTÉ` — correctif `0f4b16c…` |

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
`02430b1…` sans modifier le verdict historique de `013`. Son retour confirme
le parcours fonctionnel mais impose une nouvelle régression d’adaptation après
suppression du formulaire défilant et de la hauteur fixe.

| ID Apple différé | Objet | Exigences principales | État |
|---|---|---|---|
| `APPLE-L2-001` | Barre compacte, Gérer les pages, confirmation et menu Plus sur iPhone/Xcode | `EDT-003`, `EDT-004`, `EDT-008`, `EDT-016`, `EDT-020`, `PAG-013`, `PAG-017`, `ACC-002`, `ACC-021` | ⚪ `NON TESTÉ` |

## Écarts connus de l’incrément

- Les variantes avec un slot texte et l’éditeur sont actives. Leur premier
  candidat échoue à la compilation sous `IPAD-L2-020` ; le correctif reste à
  compiler et qualifier sous `IPAD-L2-021`.
- Remplir l’album (`AUT-009…011`) de `7815396…` est validé globalement par
  `IPAD-L2-018`. Sa nouvelle présentation compacte et le cadrage couvrant de
  `3944fae…` sont qualifiés sous `IPAD-L2-019`, mais `ACPT-125` demeure
  incomplet jusqu’aux autres sorties et qualifications Apple applicables.
- L’ADR-003 documente l’absence d’alignement justifié dans l’API SwiftUI
  publique utilisée : `TBX-011` reste partiel, comme `TBX-007`, `TBX-021` et
  le regroupement de frappe `TBX-022`.
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
  `IPAD-L2-013`. `IPAD-L2-014` confirme ensuite l’ajout en fin, la case et la
  réinitialisation, mais échoue sur la taille de la fenêtre et le défilement de
  son pied de texte. `IPAD-L2-015` échoue ensuite car l’ajustement fitted
  comprime toute la fenêtre. `IPAD-L2-016` échoue enfin parce que l’ouverture
  de la feuille de `7d8772c…` fige l’app sans rien afficher ; le dialogue
  interne de `57afa71…` est validé par `IPAD-L2-017`, d’après le retour global
  « c’est ok » sans capture ni détail par étape.
