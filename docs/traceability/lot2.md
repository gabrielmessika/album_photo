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
correctif `0f4b16c6c6435c29ca44da4e2726fac210add520` adopte une portée métier
imbriquée et une contrainte par attribut modifiable. Il compile et lance l’app,
mais `IPAD-L2-021` échoue sur l’ajout superposé, le fond de l’éditeur, la
palette, l’échelle et l’opacité. Le correctif
`7bc495ec623e5b12301569d0108fbccadb978630` introduit le panneau Texte et les
formats dans l’inspecteur, mais `IPAD-L2-022` échoue car la saisie est rendue à
une taille pratiquement invisible. Le correctif
`f0a0ccaa4f580a5d602dfc9432228fdf5115ce59` applique la
conversion typographique 300/72 et les fiches courtes `IPAD-L2-023…029`
réutilisent progressivement le même album. La campagne du 19 août 2026 compte
deux réussites (`028`, `029`) et cinq échecs (`023…027`) : compilation et
frappe visible acquises, mais descendantes, composition des motifs,
organisation des panneaux, sélection/palette en paysage et Police/Italique
restent à reprendre sur le candidat testé. Le correctif courant réserve la
métrique normale aux interlignes neutres, borne et place le motif sous
l’éditeur, conserve la sélection sans clavier, rend la palette défilable,
explicite les trois portées de format et applique l’ordre visible Photos,
Texte, séparation simple sans titre, Mise en page, Fonds. Après clarification,
`EDT-001` fixe l’ordre complet Photos, Texte, Stickers, séparation simple sans
titre, Mise en page, Fonds, Cadres et formes. La campagne du 20 août sur
`cb7786259cc85cbe5fd7017ed2f4c9ae3ba823aa` réussit `IPAD-L2-031…032` mais
échoue `030` sur les trois motifs et `033` sur la faible distinction
Système/Arrondie ainsi que l’italique Arrondie. Le second correctif, figé au
commit `3102cda0e6b2c483576585ec2f97fc947f87c96f`, attache le motif comme
arrière-plan strict du `TextEditor`, renforce le profil arrondi et son
inclinaison, puis matérialise tous les choix actifs selon `TBX-026`.
`IPAD-L2-034…035` réussissent globalement sur l'iPad déclaré, sans capture ni
détail par étape. Le retour demande toutefois de réduire la largeur des boutons
de format : `TBX-027` conserve un état courant visible tout en imposant un
libellé court, une valeur abrégée ou un indicateur compact.
L'ajout du bouton Info à la Bibliothèque produit ensuite le candidat combiné
`60930587da16707dbb57eada9881f6fefcedd51e`. Son archive Git embarque son hash
exact et les fiches `IPAD-L2-036…038` remplacent les deux fiches historiques
pour qualifier Info, motifs et formats sur ce nouveau package. La campagne du
20 août 2026 réussit `037…038`, mais `036` échoue : Info affiche
`Non estampillé` au lieu du commit exact, dont la sélection et la copie ne sont
donc pas prouvées. La révision de travail suivante ajoute un producteur de ZIP
qui refuse toute archive non estampillée, ainsi que l’action GitHub **Paquet
candidat iPad**. Elle termine aussi le périmètre de code du lot 2 : boutons de
texte compacts, justification dans le renderer commun de page, commandes de
saisie regroupées à 750 ms, quarante stickers originaux, six cadres décoratifs,
formes/contours à portée multiple et presse-papiers photo/texte/sticker. Cette
révision a été figée dans le candidat fonctionnel
`fce5d92879a5a654778b02ec17a3707590554cd7`. `IPAD-L2-039` échoue toutefois
dès la compilation : le type-checker de Swift Playgrounds ne résout pas dans
un délai raisonnable la concaténation des segments UUID d’`AppModel` ligne 256.
Les fiches `040…054` ne sont pas exécutées et restent attachées à ce candidat
rejeté ; de nouveaux identifiants qualifieront le correctif. Info demeure
volontairement exclu. `APPLE-L2-002…005` couvrent ensuite largeur compacte,
Xcode/Release, Instruments et TestFlight.
La source normative reste
[`spec.md`](../../spec.md), le statut opérationnel
[`SUIVI_PROJET.md`](../../SUIVI_PROJET.md) et les procédures manuelles
[`suivi_tests.md`](../../suivi_tests.md).

Le candidat final ne déclare encore aucun nouveau scénario de sortie réussi : Remplir l’album, son dialogue
compact et le cadrage couvrant sont qualifiés jusqu’à `IPAD-L2-019`, mais la
révision qui rassemble les autres sorties du lot reste à valider par `039…054` ;
`IPAD-L2-008` reste bloqué pour la seule largeur compacte. Les échecs
historiques `IPAD-L2-002` et `004` sont couverts par les régressions réussies
`010` et `011`.

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
| `A-L2-TEXT-DOMAIN` | `BuiltInTextFontCatalog`, `TextPrototypeEngine`, `TextInitialStyleEngine`, `TextEditingPrototypeTests`, `AlbumApplicationServiceTests.testTextEditingSequencesAreIndividuallyUndoableAndCancelRestoresBaseline` | `TBX-001…020`, `TBX-022…025`, `TXA-004`, `TXA-005`, `TPL-012`, `TPL-013`, `TPL-017`, `UND-008` | Prouve les primitives, styles persistants, limite, hauteur/débordement et checkpoints durables à 750 ms/perte de focus dans le Core ; pas l’éditeur Apple ni le collage riche externe complet |
| `A-L2-TEXT-UI` | `AlbumTextEditorView`, `TextPanelView`, `PageCanvasView`, `EditorViewModel`, `ManifestContractTests.testTextEditorUsesNativeAttributedSelectionAndActivatesTextTemplates` | `EDT-001`, `EDT-008`, `EDT-012`, `EDT-014`, `EDT-021`, `TBX-002…017`, `TBX-020…027`, `TXA-001…003` | Vérifie structurellement les libellés compacts, le menu Justifié, le délai 750 ms, le blocage de Prévisualiser et le renderer TextKit partagé ; parse seulement, sans type-check ni rendu Apple |
| `A-L2-CATALOG` | `BuiltInAssetCatalogs`, `catalog-resources-v1.json`, `CatalogContractTests`, `ManifestContractTests.testPublishedCatalogMatchesRuntimePayloadContractsExactly`, `tools/validate_contracts.pl` | `CAT-001…009`, `STK-009…013`, `SHR-005`, `SHR-010…013` | Prouve 40 stickers/5 catégories, 6 cadres, 6 formes, hashes, PNG RGBA transparents, insets et goldens ; chargement du bundle Apple non prouvé |
| `A-L2-STICKERS` | `StickerGeometryEngine`, `StickerPanelView`, `PageCanvasView`, tests de géométrie, validation et service | `STK-001…016`, `STK-021…024`, `DAT-041` | Prouve recherche/catalogue, récents, transactions, rapport intrinsèque, remplacement, opacité/retournement, ordre et avertissement structurel ; glisser-déposer, rendu et fluidité Apple manuels |
| `A-L2-SHAPES-FRAMES` | `FrameAndShapePanelView`, `NineSliceDecorativeFrameView`, `AlbumApplicationServiceTests.testPhotoStyleScopesAreAtomicValidatedAndUndoable` | `SHR-001…014` | Prouve les trois portées et leur commande atomique, le contour canonique et les références ; masques/contours/neuf zones doivent être comparés sur Apple |
| `A-L2-CLIPBOARD` | `AlbumApplicationServiceTests.testClipboardPreservesLot2TextAndStickerPayloads` et tests photo existants | `CLP-001…006`, `UND-001…012` | Prouve type, style, transform, nouveaux IDs, ordre, couper/coller et portée session/album pour photo, texte et sticker dans le Core ; commandes SwiftUI Apple à requalifier |
| `A-L2-CANDIDATE` | `tools/create_ipad_candidate.sh`, `.github/workflows/ipad-candidate.yml`, `ManifestContractTests.testLibraryExposesVersionAndStampedCommitInformation` | `APP-012`, `ENV-001…005`, `DONE-005` | L’archive contrôlée contient le hash exact et refuse le marqueur brut ; téléchargement et exécution du nouvel artefact iPad non testés |

La suite WSL complète compte 157 tests sans échec. Les contrats publiés des
55 ressources et leurs seize empreintes sont également valides, et toutes les
sources AppModule passent l’analyse syntaxique. Ces résultats ne remplacent
aucune fiche iPad.

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
| `IPAD-L2-021` | Compilation corrigée et qualification complète des zones de texte | `TBX-001…010`, `TBX-012…020`, `TBX-023…025`, `TPL-012`, `TPL-013`, `TPL-017`, `TXA-001`, `TXA-002`, `TXA-004`, `ACC-002`, `ACC-006`, `ACC-021` | 🔴 `ÉCHOUÉ` — compilation réussie, cinq défauts d’interface/rendu sur `0f4b16c…` |
| `IPAD-L2-022` | Panneau Texte, palette, échelle et opacité | `EDT-001`, `EDT-002`, `EDT-006`, `EDT-008`, `EDT-012`, `EDT-014`, `EDT-021`, `TBX-001…020`, `TBX-023…025`, `TPL-012`, `TPL-013`, `TPL-017`, `TXA-001`, `TXA-002`, `TXA-004`, `ACC-002`, `ACC-006`, `ACC-021` | 🔴 `ÉCHOUÉ` — saisie pratiquement invisible sur `7bc495e…` |
| `IPAD-L2-023` | Compilation et saisie visible | `ENV-001…005`, `TBX-002…005`, `TBX-014`, `TBX-025`, `DONE-005` | 🔴 `ÉCHOUÉ` — compilation et étapes 1 à 3 réussies ; descendantes rognées et motif parfois devant l’éditeur à l’étape 4 |
| `IPAD-L2-024` | Panneau Texte, raccourcis et inspecteur | `EDT-001`, `EDT-006`, `EDT-008`, `EDT-012`, `EDT-014`, `EDT-021`, `TBX-002`, `TBX-009`, `UND-001` | 🔴 `ÉCHOUÉ` — organisation de l’étape 1 rejetée ; étapes 2 à 4 réussies, menu `+` accepté |
| `IPAD-L2-025` | Taille et opacité cohérentes | `TBX-010`, `TBX-012`, `TBX-014`, `TBX-024` | 🔴 `ÉCHOUÉ` — sélection perdue sans clavier et portée des formats insuffisamment explicite ; l’opacité zone entière reste conforme à `TBX-012` |
| `IPAD-L2-026` | Fond réel et palette colorée | `TBX-010`, `TBX-015`, `TBX-016`, `TBX-025`, `BG-011`, `BG-016` | 🔴 `ÉCHOUÉ` — palette non défilable et sélection perdue sans clavier en paysage ; étapes 3 et 4 sans verdict |
| `IPAD-L2-027` | Sélections, paragraphes et limite | `TBX-006…011`, `TBX-013`, `TBX-017`, `TBX-023`, `TXA-001`, `TXA-002`, `TXA-004` | 🔴 `ÉCHOUÉ` — Système/Arrondie identiques et Italique sans effet perceptible ; étapes 2 à 4 déclarées conformes |
| `IPAD-L2-028` | Géométrie, débordement et modèle texte | `TBX-018…021`, `TPL-012`, `TPL-013`, `TPL-017` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-029` | Profondeur, persistance et accessibilité | `TBX-001`, `TBX-004`, `TBX-023`, `TBX-024`, `UND-001`, `SAV-001`, `ACC-002`, `ACC-006`, `ACC-021` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-030` | Compilation, descendantes et motifs intégrés | `ENV-001…005`, `CAN-003`, `BG-007`, `TBX-002…005`, `TBX-019`, `TBX-020`, `TBX-024`, `TBX-025`, `DONE-005` | 🔴 `ÉCHOUÉ` — étapes 1 à 3 réussies ; les trois motifs recouvrent encore l’éditeur, couleurs unies conformes |
| `IPAD-L2-031` | Ordre et séparation sans titre des panneaux | `DEC-32`, `EDT-001`, `EDT-002`, `EDT-006`, `EDT-012`, `EDT-021`, `ACC-021` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-032` | Sélection, palette et portées en paysage | `TBX-005`, `TBX-010…012`, `TBX-015`, `TBX-016`, `ACC-002`, `ACC-006`, `ACC-021` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-033` | Polices, italique et persistance de la sélection | `TBX-010`, `TBX-013`, `TBX-023`, `TBX-024`, `SAV-001`, `ACC-002` | 🔴 `ÉCHOUÉ` — Système/Arrondie trop proches et Italique absent sur Arrondie ; étapes 3 et 4 déclarées conformes |
| `IPAD-L2-034` | Motifs strictement bornés dans l'éditeur | `ENV-001…005`, `CAN-003`, `BG-007`, `TBX-024`, `TBX-025`, `DONE-005` | 🟢 `RÉUSSI` — retour global sur `3102cda…`, sans capture ni détail par étape |
| `IPAD-L2-035` | Arrondie, italique et choix actifs | `TBX-009…016`, `TBX-023`, `TBX-024`, `TBX-026`, `SAV-001`, `ACC-002`, `ACC-004` | 🟢 `RÉUSSI` — retour global sur `3102cda…` ; compacité des boutons reprise sous `TBX-027` |
| `IPAD-L2-036` | Info, version et commit exact du candidat | `ENV-001…005`, `APP-001`, `APP-012`, `ACC-001…004`, `ACC-008`, `DONE-005` | 🔴 `ÉCHOUÉ` — Commit affiche `Non estampillé` ; hash exact et copie non prouvés |
| `IPAD-L2-037` | Motifs strictement bornés sur le candidat Info | `CAN-003`, `BG-007`, `TBX-024`, `TBX-025` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-038` | Arrondie, italique et choix actifs sur le candidat Info | `TBX-009…016`, `TBX-023`, `TBX-024`, `TBX-026`, `SAV-001`, `ACC-002`, `ACC-004` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-039` | Compilation, lancement et surface finale | `ENV-001…005`, `EDT-001`, `EDT-002`, `EDT-006`, `EDT-012`, `EDT-021`, `DONE-005` | 🔴 `ÉCHOUÉ` à la compilation sur `fce5d92…` (`AppModel` ligne 256) |
| `IPAD-L2-040` | Boutons texte compacts et justification | `TBX-009…016`, `TBX-023…027`, `CAN-008`, `ACC-002`, `ACC-004` | ⚪ `NON TESTÉ` |
| `IPAD-L2-041` | Sessions de frappe et historique 750 ms | `TBX-002…005`, `TBX-022`, `TBX-025`, `UND-001`, `UND-008`, `SAV-001` | ⚪ `NON TESTÉ` |
| `IPAD-L2-042` | Limite et collage riche filtré | `TBX-006…010`, `TBX-017`, `TBX-023`, `CLP-005`, `ACC-002` | ⚪ `NON TESTÉ` |
| `IPAD-L2-043` | Débordement et blocage Prévisualiser | `TBX-018…021`, `TBX-024`, `CAN-008`, `ACC-002`, `ACC-006` | ⚪ `NON TESTÉ` — Exporter reste Lot 3 |
| `IPAD-L2-044` | Catalogue, recherche et récents | `STK-001…003`, `STK-006`, `STK-009…012`, `CAT-001`, `CAT-009` | ⚪ `NON TESTÉ` |
| `IPAD-L2-045` | Ajout, dépôt et géométrie sticker | `STK-004`, `STK-005`, `STK-008`, `STK-015`, `STK-023`, `STK-024`, `ELM-001…004` | ⚪ `NON TESTÉ` |
| `IPAD-L2-046` | Remplacement et commandes sticker | `STK-007`, `STK-014…016`, `STK-022`, `ELM-008`, `UND-001` | ⚪ `NON TESTÉ` |
| `IPAD-L2-047` | Rendu, profondeur et persistance sticker | `STK-009`, `STK-024`, `CAN-008`, `SAV-001`, `ACC-006` | ⚪ `NON TESTÉ` |
| `IPAD-L2-048` | Six formes et conservation du cadrage | `SHR-001…003`, `SHR-006`, `SHR-010`, `SHR-012`, `CRP-001`, `CRP-007` | ⚪ `NON TESTÉ` |
| `IPAD-L2-049` | Contours et six cadres décoratifs | `SHR-004`, `SHR-005`, `SHR-009`, `SHR-011`, `SHR-013`, `SHR-014`, `CAN-008` | ⚪ `NON TESTÉ` |
| `IPAD-L2-050` | Portées Sélection, Page et Album | `SHR-007`, `SHR-008`, `UND-001`, `SAV-001`, `ACC-002` | ⚪ `NON TESTÉ` |
| `IPAD-L2-051` | Copier/coller photo, texte et sticker | `CLP-001`, `CLP-003`, `CLP-004`, `ELM-009`, `FRM-007`, `SAV-001` | ⚪ `NON TESTÉ` |
| `IPAD-L2-052` | Couper, annuler et invalider le clipboard | `CLP-002`, `CLP-004`, `CLP-006`, `UND-001`, `UND-002`, `SAV-001` | ⚪ `NON TESTÉ` |
| `IPAD-L2-053` | Aide et accessibilité Lot 2 | `EDT-019`, `STK-022`, `ACC-001…008`, `ACC-020`, `ACC-021` | ⚪ `NON TESTÉ` |
| `IPAD-L2-054` | Fluidité à vingt stickers | `STK-021`, `PERF-005`, `PERF-015`, `PERF-017`, `ACC-002` | ⚪ `NON TESTÉ` |

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
`APPLE-L2-001` conserve cette dette historique ; `APPLE-L2-002` requalifiera
l’interface finale complète sur iPhone ou dans un environnement Xcode
réellement compact.

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
| `APPLE-L2-002` | Interface finale en largeur compacte | `EDT-001…004`, `EDT-008`, `EDT-012`, `EDT-014`, `EDT-016`, `EDT-020`, `EDT-021`, `TBX-005`, `TBX-027`, `ACC-002`, `ACC-021` | ⚪ `NON TESTÉ` sur `fce5d92…` |
| `APPLE-L2-003` | Debug/Release et tests Apple | `ENV-006…009`, `TST-014…016`, `DONE-005` | ⚪ `NON TESTÉ` |
| `APPLE-L2-004` | Instruments et enveloppe maximale | `STK-021`, `PERF-001…009`, `PERF-015…017` | ⚪ `NON TESTÉ` |
| `APPLE-L2-005` | TestFlight distinct | `TST-003`, `TST-005`, `TST-015`, `DONE-001…005` | ⚪ `NON TESTÉ` |

## Écarts connus de l’incrément

- Les variantes avec un slot texte et l'éditeur sont actives. Leur premier
  candidat échoue à la compilation sous `IPAD-L2-020`; `IPAD-L2-021` puis
  `022` échouent fonctionnellement. `f0a0cca…` compile et `IPAD-L2-028…029`
  valident globalement modèle, profondeur, persistance et accessibilité. Les
  correctifs suivants ferment sur `3102cda…` les écarts de motifs,
  Arrondie/Italique et d'états actifs par les réussites globales `034…035`.
  Le package combiné `6093058…` réussit `037…038`, ce qui confirme les motifs,
  Arrondie/Italique et les états actifs sur ce candidat. `036` échoue sur la
  valeur Commit `Non estampillé`. Le producteur d’artefact contrôlé corrige le
  transport ; ce contrôle est différé sur décision utilisateur. `TBX-027` est
  implémenté dans `fce5d92…`, dont la compilation a échoué avant le contrôle ;
  il attend une nouvelle fiche sur le correctif puis `APPLE-L2-002`.
- Remplir l’album (`AUT-009…011`) de `7815396…` est validé globalement par
  `IPAD-L2-018`. Sa nouvelle présentation compacte et le cadrage couvrant de
  `3944fae…` sont qualifiés sous `IPAD-L2-019`, mais `ACPT-125` demeure
  incomplet jusqu’aux autres sorties et qualifications Apple applicables.
- L’ADR-003 isole la limite SwiftUI : la saisie prévisualise Justifié à gauche,
  tandis que le renderer de page TextKit public le compose réellement. Le
  collage riche externe de `TBX-007` et la partie Exporter de `TBX-021`, prévue
  au Lot 3, restent partiels ; le regroupement `TBX-022` est implémenté.
- Les 40 stickers et 6 cadres décoratifs sont persistables après validation des
  payloads, licences, insets et goldens de `CAT-009`; `IPAD-L2-039` a échoué
  avant le lancement et de nouvelles fiches doivent encore prouver leur
  première build et leur rendu Apple.
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
