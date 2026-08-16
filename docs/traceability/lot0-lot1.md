# Matrice de traçabilité — lots 0 et 1

Cette matrice relie les exigences du périmètre des lots 0 et 1 à des points de
contrôle identifiables. Elle complète, sans le remplacer, le registre
exécutable [`suivi_tests.md`](../../suivi_tests.md). Elle répond à `TST-001` et
`TST-005` au niveau permis par le candidat actuel.

Une référence à un test indique seulement où l'exigence est contrôlée. Elle ne
constitue pas une preuve de réussite. Les résultats, l'environnement et le
commit exact restent ceux enregistrés dans `suivi_tests.md` et
`SUIVI_PROJET.md`. La première campagne iPad `063…093` possède des résultats,
mais le candidat correctif rend les preuves concernées insuffisantes. Le commit
`06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` a échoué à la compilation Apple ;
les régressions `109…131`, la fiche `102` et le nouveau contrôle de compilation
`132` ciblent désormais le correctif figé
`84ec71e1a66df4676e3c388e9d4f87a5a7e06e4e` et restent ⚪ `NON TESTÉ`. Aucun
scénario d'acceptation n'est donc déclaré réussi par ce document.

## Convention et frontière des lots

| Repère | Signification |
|---|---|
| `A-*` | Test automatisé ou validateur déterministe ; emplacement détaillé ci-dessous. |
| `IPAD-L1-*` | Procédure manuelle détaillée dans `suivi_tests.md`; résultat à enregistrer par candidat et environnement. |
| `APPLE-*` | Qualification différée nécessitant Xcode, Instruments, signature, injection ou inspection Apple. |
| Partiel | Seul le sous-périmètre livré ou prototypé est contrôlé ; l'exigence complète ne peut pas être déclarée satisfaite. |
| Écart | Aucun contrôle suffisant n'existe encore dans les lots 0 et 1. |

La frontière appliquée est celle de `DEC-38` et de l’ordre de réalisation de
la section 31 :

- le lot 0 livre des prototypes internes et des contrats, sans rendre publiques
  les commandes des lots ultérieurs ;
- le lot 1 rend publiques la bibliothèque, la corbeille, l'éditeur à une page,
  la vue globale, les pages, fonds, couvertures, photos, cadres photo, cadrage,
  sauvegarde, presse-papiers photo, navigation et annulation ;
- modèles, dé, Auto, texte, stickers, formes et cadres décoratifs restent des
  prototypes ou contrats internes jusqu'au lot 2 ; package, lecture, diaporama
  et PDF restent au lot 3 ; CloudKit public et historique restent au lot 4.

Une ligne marquée Partiel ne doit donc jamais être transformée en réussite de
l'exigence ou du scénario complet.

## Répertoire des contrôles automatisés

| Repère | Fichier et classe | Méthodes ou contrôle déterministe |
|---|---|---|
| `A-ALB` | [`AlbumApplicationServiceTests.swift`](../../Tests/AlbumPhotoCoreTests/AlbumApplicationServiceTests.swift), `AlbumApplicationServiceTests`; [`DomainValidationTests.swift`](../../Tests/AlbumPhotoCoreTests/DomainValidationTests.swift), `DomainValidationTests` | `testCreateAlbumTrimsNameAllowsDuplicatesAndSortsByUpdatedAt`, `testActiveAlbumsSortByRecencyLocalizedNameThenUUIDBytes`, `testLibraryRenameHasIndependentUndoRedo`, `testTrashRestoreAndPermanentDeletionPreserveCorrectTarget`, `testPermanentDeletionCreatesOneValidatedTombstoneAndKeepsBlob`, `testTrashExpiresAtExactlyThirtyPeriodsOfTwentyFourHours`, `testTrashExpirationEvaluatesAtLaunchThenAtMostOnceBeforeDailyBoundary`, `testInitialAlbumUsesGenerationOnePageAndClassicBackground`, `testAlbumNameRejectsWhitespaceOnlyAndTrimsValidName`, `testDeletionTombstoneRequiresValidHashDatesReasonAndNoLiveAlbum`. |
| `A-PAGE` | [`AlbumApplicationServiceTests.swift`](../../Tests/AlbumPhotoCoreTests/AlbumApplicationServiceTests.swift), `AlbumApplicationServiceTests` | `testPageAddReorderDeleteAndTwoUndosRestoreInitialOrder`, `testOnlyPageCannotBeDeleted`, `testBackgroundPerPageApplyAllAndUndoAreAtomic`, `testManualCoverTracksElementThenFallsBackAfterContentRemoval`. |
| `A-PHOTO` | [`AlbumApplicationServiceTests.swift`](../../Tests/AlbumPhotoCoreTests/AlbumApplicationServiceTests.swift), `AlbumApplicationServiceTests` | `testMultipleRegistrationPreservesSelectionOrderAsOneUndoAction`, `testRegistrationDeduplicatesContentHashWithinAlbumWithoutExtraUndo`, `testAddMultipleFramesCreatesIndependentOccurrencesAtOneX`, `testRemoveContentKeepsFrameAndAssetDeletionRequiresZeroOccurrences`, `testReuseAcrossAlbumsCreatesNewLogicalIDWithSameBlobAndLeavesSourceUntouched`, `testReuseRetryWithoutInjectedDestinationIDsReturnsSameLogicalResult`, `testCropIsOnePersistedUndoableCommand`. |
| `A-CLIP` | [`AlbumApplicationServiceTests.swift`](../../Tests/AlbumPhotoCoreTests/AlbumApplicationServiceTests.swift), `AlbumApplicationServiceTests` | `testCopyPasteUsesNewElementIDAndIndependentCropThenCutUndoRestores`, `testCutRetryIsIdempotentAndCreatesOnlyOneUndoCommand`, `testCutRetryDoesNotOverwriteClipboardChangedAfterFirstSuccess`, `testFailedCutPreservesAlbumUndoHistoryAndPreviousClipboard`, `testClipboardRejectsCrossAlbumPasteWithoutCreatingAssetOrRevision`, `testDepthCommandsRenumberWithConstantStep`, `testPasteDepthIsImmediatelyAboveSourceOnSamePageAndFrontOnAnotherPage`, `testNewModificationAfterUndoClearsRedoBranch`, `testSemanticNoOpsDoNotChangeRevisionUpdatedAtOrUndoStacks`. |
| `A-CONC` | [`ConcurrencyAndRAWTests.swift`](../../Tests/AlbumPhotoCoreTests/ConcurrencyAndRAWTests.swift), `LibraryConcurrencyTests`; [`AlbumApplicationServiceTests.swift`](../../Tests/AlbumPhotoCoreTests/AlbumApplicationServiceTests.swift), `AlbumApplicationServiceTests` | `testConcurrentAlbumCommandsKeepEveryMutationWithoutStaleRevision`, `testLeaseBlocksEveryLibraryAlbumMutationWithoutChangingSnapshot`, `testLibraryUndoCannotOverwriteAnAlbumWithAnEditingLease`, `testAppliedLibraryMutationAndUndoRetriesRemainIdempotentWhileLeased`, `testLibraryBarrierBlocksLeaseAndClosingLibraryClearsBothStacks`, `testRapidLibraryCommandsAndUndosAreSerialised`, plus `testEditLeaseAllowsOnlyOneWriterPerAlbumAndReleasesByScene`, `testStaleSceneCloseCannotClearNewOwnersUndoHistory`, `testLibraryUndoRedoRetriesDoNotMoveAnotherHistoryEntry`. |
| `A-DOM` | [`DomainValidationTests.swift`](../../Tests/AlbumPhotoCoreTests/DomainValidationTests.swift), `DomainValidationTests` | `testGenerationIsValidatedBeforeSchema`, `testPageRejectsDuplicateElementAndIncompleteAccessibilityOrder`, `testGeometryRequiresSelectableCenterMinimumSizeAndNormalizedRotation`, `testPhotoPlacementRejectsNonFiniteOutOfRangeAndTooLongDescription`, `testPhotoMetadataAcceptsEveryPersistedStaticAndRAWType`, `testPhotoMetadataRejectsInvalidDimensionsAnimatedMimeAndOver200Megapixels`, `testLayoutStateRejectsImpossibleProvenanceCombinations`, `testBackgroundCasesRemainDistinctAndSolidMustBeOpaque`, `testCatalogReferencesResolveExactVersionPayloadAndHash`, `testSnapshotRejectsReferencedFallbackWithoutVerifiedBlobIndexEntry`, `testTextUsesSwiftCharacterLimit`. |
| `A-GEOM` | [`GeometryEngineTests.swift`](../../Tests/AlbumPhotoCoreTests/GeometryEngineTests.swift), `GeometryEngineTests` | Les seize méthodes de la classe : fixtures `1×` et `0,5×`, borne dynamique, transformations, cadre initial, hit-testing, guides, zoom/panoramique composés de fenêtre et seuils qualité. |
| `A-CAP` | [`CapacityPolicyTests.swift`](../../Tests/AlbumPhotoCoreTests/CapacityPolicyTests.swift), `CapacityPolicyTests` | `testWarnsOnlyAfterGuaranteedPageAndElementEnvelopes`, `testAlbumBytesAreDeduplicatedByContentHash`. |
| `A-STORE` | [`PersistenceAndHashTests.swift`](../../Tests/AlbumPhotoCoreTests/PersistenceAndHashTests.swift), `PersistenceAndHashTests` | Vecteurs SHA-256 et flux borné (`testIncrementalSHA256MatchesStandardVectorsAcrossUnevenChunks`, `testFileFingerprintStreamsMultipleChunksWithExactByteCount`), JSON canonique, hash logique, persistance après relance, tombstone, initialisation de génération, rejeu/nettoyage du journal, coupures injectées dont le succès durable après publication (`testPostPublicationCleanupFaultIsSuccessWithSameServiceRetryAndUndo`), dépôt adressé par contenu avec rejet d’une corruption de même taille (`testContentAddressedStoreRejectsSameSizeCorruptionDuringVerificationAndDeduplication`) et bootstrap des ressources de catalogue. |
| `A-RAW` | [`ConcurrencyAndRAWTests.swift`](../../Tests/AlbumPhotoCoreTests/ConcurrencyAndRAWTests.swift), `RAWDerivativeTests` | `testRAWMissingDerivativeMetadataOrRegistrationIsRejectedAtomically`, `testRAWIndexesCountsAndPhysicallyVerifiesOriginalAndDerivativeForReuse`, `testRAWDerivativeParticipatesInDeduplicatedCapacity`, `testLogicalHashIsIndependentFromRAWDisplayDerivativeEncoding`. |
| `A-REUSE` | [`VerifiedPhotoReuseTests.swift`](../../Tests/AlbumPhotoCoreTests/VerifiedPhotoReuseTests.swift), `VerifiedPhotoReuseTests` | Vérification physique en flux borné avant toute mutation : `testVerifiedReuseChecksBytesThenCreatesIndependentLogicalAsset`, `testMissingBlobRejectsReuseWithoutCreatingMembership`, `testCorruptBlobRejectsReuseWithoutCreatingMembership`. |
| `A-MANIFEST` | [`ManifestContractTests.swift`](../../Tests/AlbumPhotoCoreTests/ManifestContractTests.swift), `ManifestContractTests`; [`validate_contracts.pl`](../../tools/validate_contracts.pl) | Manifeste des 32 modèles, schémas et exemples `.photoalbum`, MIME persistés, exclusivité `asset`/`nativeVector`, chemins hostiles, empreintes et fixtures de package. |
| `A-CATALOG` | [`CatalogContractTests.swift`](../../Tests/AlbumPhotoCoreTests/CatalogContractTests.swift), `CatalogContractTests`; [`validate_contracts.pl`](../../tools/validate_contracts.pl) | Registre public exact, trois fonds, six formes, contrats renderer structurés, champs futurs sticker/cadre, dimensions, MIME, longueurs, SHA-256 et invariants croisés. |
| `A-SHAPE` | [`CatalogShapeRendererTests.swift`](../../Tests/AlbumPhotoCoreTests/CatalogShapeRendererTests.swift), `CatalogShapeRendererTests` | Six golden masks 64 × 48 exacts, distinction cercle/ovale, remplissage non nul, rognage, valeurs adversariales et IDs inconnus. |
| `A-LAYOUT` | [`PrototypeEngineTests.swift`](../../Tests/AlbumPhotoCoreTests/PrototypeEngineTests.swift), `PrototypeEngineTests` | `testTemplateCatalogRejectsDuplicateVersionAndMultipleActiveVersions`, `testSmallerTemplateRequiresConfirmationAndPreservesSurvivingCrop`, `testTemplateNeverSilentlyRemovesNonemptyText`, `testShuffleBagUsesOnlyExactCompatibleSetWithoutImmediateRepeat`, `testAutomaticGeneratorIsDeterministicAndValidForZeroThroughTwenty`, `testAutomaticGeneratorPrefersBestExactTemplateBeforeFallbackGrid`, `testAutoRecomposeRemovesEmptyFramesAndPreservesCropInAccessibilityOrder`. Prototype interne uniquement. |
| `A-TEXT` | [`TextEditingPrototypeTests.swift`](../../Tests/AlbumPhotoCoreTests/TextEditingPrototypeTests.swift), `TextEditingPrototypeTests` | Les sept méthodes de la classe : sélection partielle, styles de frappe et paragraphes, collage filtré, limite en `Character`, débordement, annulation et sérialisation. Prototype interne uniquement. |
| `A-NAV-CLOUD` | [`PrototypeEngineTests.swift`](../../Tests/AlbumPhotoCoreTests/PrototypeEngineTests.swift), `PrototypeEngineTests` | `testPageTurnThresholdVelocityDirectionBoundsAndSingleTransition` et `testCloudPlannerChangesOnePageIndependentlyAndQueuesThroughProtocol`. Prototypes internes uniquement. |

## Exigences transversales

| Exigences | Point de contrôle | Limite |
|---|---|---|
| `SPEC-001` à `SPEC-003`, `DEV-001` à `DEV-009` | Historique Git, `AGENTS.md`, cette matrice, fiches détaillées de `suivi_tests.md`, `IPAD-L1-063`, `APPLE-L1-001`, `APPLE-L1-009` | Revue de processus ; aucune réussite runtime n'en est déduite. |
| `SCP-001`, `REL-001` à `REL-005` | Frontière de lots ci-dessus, absence des commandes futures contrôlée par `IPAD-L1-098`, `IPAD-L1-104`, `IPAD-L1-106`; scénarios futurs indexés plus bas | La non-exposition complète doit encore être observée sur Apple. |
| `DEC-00` à `DEC-38` | Chaque décision fonctionnelle est routée vers la famille correspondante ci-dessous ; `A-PAGE`, `A-GEOM`, `A-TEXT`, `A-LAYOUT`, `A-CATALOG`, `A-STORE`, `A-CONC`, puis la campagne iPad | `DEC-38` est contrôlée structurellement par les sorties de lots et le registre ; les décisions des Lots 2 à 5 ne disposent encore que de prototypes, contrats ou écarts explicités dans l’index ACPT. |
| `CFG-001` à `CFG-006` | Revue statique du dépôt ; `APPLE-L0-008`, `APPLE-L1-001`, `APPLE-L1-009` | Configuration CloudKit/Google et contrôle d'archive différés ; aucun secret ne peut être réputé absent sur la seule base de cette ligne. |

## Matrice des exigences du lot 0

| Exigences | Contrôle automatisé | Contrôle Apple ou manuel | Limite de preuve |
|---|---|---|---|
| `ENV-001` à `ENV-005`, `LOT-001`, `LOT-003`, `DONE-005` | Manifeste Swift conservé, `A-MANIFEST` pour les contrats vérifiables | `IPAD-L1-063`, `IPAD-L1-132`, registre entier `IPAD-L1-063` à `IPAD-L1-132` | L'environnement et le statut ne sont prouvés qu'après exécution sur le commit candidat. |
| `ENV-006` à `ENV-009`, `LOT-002`, `LOT-004`, `DONE-001` à `DONE-004` | Aucun test Linux ne peut qualifier ces clauses de publication | `APPLE-L1-001`, `APPLE-L1-002`, `APPLE-L1-009` | Différé ; aucune version ou lot n'est déclaré terminé. |
| Architecture locale, indépendance du domaine et absence de dépendance privée : `ARC-001` à `ARC-017` | `A-STORE`, `A-CONC`, `A-NAV-CLOUD`; inspection de `Package.swift` et des ADR dans `docs/architecture/` | `APPLE-L0-008`, `APPLE-L1-001`, `APPLE-L1-012` | Les clauses d'architecture sans comportement observable restent des revues statiques, pas des succès fonctionnels. |
| Canevas multiélément et géométrie : `CAN-001` à `CAN-009`, `ELM-001` à `ELM-014`, `DAT-011` à `DAT-013`, `DAT-030`, `DAT-035` | `A-GEOM`, `A-DOM`, `A-CLIP` | `IPAD-L1-084` à `IPAD-L1-086`, `IPAD-L1-095`, `IPAD-L1-099`, `IPAD-L1-100`, `APPLE-L1-003`, `APPLE-L1-007` | Les gestes, poignées, haptique et rendu Apple restent manuels. |
| Prototype texte `TXA-005`; sous-ensemble `TBX-006`, `TBX-007`, `TBX-010`, `TBX-011`, `TBX-018` à `TBX-023`, `DAT-038` | `A-TEXT`, `A-DOM` | Aucun contrôle public Lot 1, conformément à la frontière | Partiel : risque moteur prototypé, interface et rendu final Lot 2 non couverts. |
| Architecture du prototype texte `TXA-001` à `TXA-004` | Revue statique de `TextEditingPrototype.swift`; indépendance Linux exercée par `A-TEXT` | `APPLE-L1-001` pour la compilation iOS 26 | `TXA-001` à `TXA-003` exigent encore la preuve de l'intégration UI du Lot 2. |
| Modèles : `TPL-001` à `TPL-023`, `DAT-034`, `DAT-040`, `DAT-042` | `A-MANIFEST`, `A-LAYOUT` | Aucun contrôle public Lot 1 | Partiel : catalogue, confirmation et conservation ont des tests purs ; UI, persistance réelle et matrice complète restent Lot 2. |
| Dé : `RND-001` à `RND-006` | `A-LAYOUT` | Aucun contrôle public Lot 1 | Prototype pur seulement. |
| Auto : `AUT-001` à `AUT-019`, `DAT-037`, `DAT-043` applicable | `A-LAYOUT`, `A-DOM` | Aucun contrôle public Lot 1 | Partiel : déterminisme et recomposition pure couverts ; commandes UI, remplissage complet et charge restent Lot 2. |
| Animation/navigation prototype : `NAV-004` à `NAV-007`, `ANI-002` à `ANI-008` | `A-NAV-CLOUD` | `IPAD-L1-092`, `IPAD-L1-105`, `APPLE-L1-003` | Le moteur de seuil est automatisé ; animation visuelle, interruption et Réduire les animations restent à observer. |
| Modèle et sérialisation : `DAT-001` à `DAT-013`, `DAT-017`, `DAT-018`, `DAT-020` à `DAT-028`, `DAT-030` à `DAT-043` selon les types des lots 0/1 | `A-DOM`, `A-GEOM`, `A-STORE`, `A-RAW`, `A-CATALOG`, `A-LAYOUT`, `A-TEXT` | `IPAD-L1-064`, `IPAD-L1-070` à `IPAD-L1-074`, `IPAD-L1-087` à `IPAD-L1-089`, `IPAD-L1-102` | Les champs exclusivement historique/synchronisation/diaporama (`DAT-014` à `DAT-016`, `DAT-019`, `DAT-029`) relèvent de lots ultérieurs ; le prototype Cloud couvre seulement une partie de leur risque. |
| Transactions et stockage : `LOC-001` à `LOC-020`, `LOC-022` à `LOC-031` | `A-STORE`, `A-RAW`, `A-REUSE`, `A-CONC`, `A-CAP`, `A-CLIP` | `IPAD-L1-068`, `IPAD-L1-079`, `IPAD-L1-093`, `IPAD-L1-102`, `IPAD-L1-109`, `IPAD-L1-116`, `IPAD-L1-121`, `IPAD-L1-131`, `APPLE-L1-004`, `APPLE-L1-005` | Le Core distingue désormais l’échec avant publication du nettoyage post-publication et vérifie les blobs en flux ; `LOC-006`, `LOC-019`, `LOC-020` et la purge physique exigent encore les injections Apple différées. `LOC-021` concerne l'export Lot 3. |
| Contrat `.photoalbum` de sortie Lot 0 : `PKG-003`, `PKG-005` à `PKG-007`, `PKG-016` à `PKG-021`; invariants de génération applicables | `A-MANIFEST`, `A-CATALOG`, `validate_contracts.pl` | `APPLE-L1-001`, `APPLE-L1-004` | Schéma et exemples sont contrôlés ; export/import réel et sécurité exhaustive appartiennent au Lot 3. |
| Registre public : `CAT-001` à `CAT-009`, `SHR-010` à `SHR-013` pour le contrat publié | `A-CATALOG`, `A-SHAPE`, `A-MANIFEST` | `APPLE-L1-010` | Les trois fonds et six formes sont figés. Les 40 stickers, six cadres et goldens neuf zones doivent être ajoutés avant leur build Lot 2. |
| Prototype CloudKit page par page : `SYN-001` à `SYN-007` | `A-NAV-CLOUD` | `APPLE-L0-008` | Planificateur pur seulement ; entitlements, zone CloudKit et comportement réseau restent différés. |
| Registre et discipline de test : `TST-001`, `TST-002`, `TST-005` à `TST-007`, `TST-011`, `TST-012`, `TST-016` | Cette matrice, suites `Tests/AlbumPhotoCoreTests`, `A-MANIFEST` | Corpus et `IPAD-L1-063` à `IPAD-L1-132`; `APPLE-L1-004` | La présence du lien satisfait la traçabilité structurelle, pas le résultat du test. |
| Procédures et qualification Apple : `TST-003`, `TST-004`, `TST-008` à `TST-010`, `TST-013` à `TST-015` | Les fiches détaillées satisfont la structure de `TST-004`; l'exécution Apple n'est pas réalisable sous Linux | `IPAD-L1-063` à `IPAD-L1-132`, `APPLE-L1-001` à `APPLE-L1-007`, `APPLE-L1-009` | Différé et explicitement non réussi sur le correctif. |

## Matrice des exigences fonctionnelles du lot 1

| Exigences | Automatisation | Contrôles manuels/différés | Qualification actuelle |
|---|---|---|---|
| Navigation applicative `APP-001`, `APP-002`, `APP-005`, `APP-006`, `APP-008` à `APP-011` | `A-CONC`, `A-STORE` | `IPAD-L1-063`, `IPAD-L1-065`, `IPAD-L1-069`, `IPAD-L1-093`, `IPAD-L1-109`, `IPAD-L1-131`, `APPLE-L1-003` | En attente des régressions Apple. `APP-003`/`APP-004` sont Lot 3 et `APP-007` Lot 4. |
| Bibliothèque et création `ALB-001` à `ALB-004`, `ALB-006`, `ALB-009`, `ALB-011` à `ALB-016`, `ALB-021` | `A-ALB`, `A-CONC` | `IPAD-L1-064` à `IPAD-L1-066`, `IPAD-L1-074`, `IPAD-L1-123`, `IPAD-L1-131` | `ALB-005`, la partie Importer de `ALB-009` et Exporter de `ALB-007` sont Lot 3. |
| Miniature non bloquante `ALB-010` | Aucun test automatisé dédié | `APPLE-L1-013` est le contrôle le plus proche, sans couvrir explicitement une miniature en cours de génération | Écart de procédure dédié à créer si `IPAD-L1-074` ne permet pas d'observer ce cas. |
| Corbeille `ALB-008`, `ALB-017` à `ALB-020`, `ALB-023` à `ALB-025` | `A-ALB`, `A-STORE` | `IPAD-L1-067`, `IPAD-L1-068`, `IPAD-L1-123`, `APPLE-L1-004` | Les deux dates localisées attendent la régression iPad ; suppression physique sûre et injections exhaustives restent non qualifiées. `ALB-022` est Lot 4. |
| Pages `PAG-001` à `PAG-016` | `A-PAGE`, `A-CAP` | `IPAD-L1-070` à `IPAD-L1-072`, `IPAD-L1-117`, `IPAD-L1-126` | Indicateur de dépôt, focus, alertes et performances restent manuels. |
| Vue globale `GLO-001` à `GLO-009` | `A-PAGE`, `A-GEOM` pour l'état sans mutation | `IPAD-L1-071`, `IPAD-L1-072`, `IPAD-L1-095`, `IPAD-L1-096` | Miniatures et restitution visuelle attendent l'iPad. |
| Fonds `BG-001` à `BG-010`, `BG-012` à `BG-015`, `DAT-039` | `A-PAGE`, `A-DOM`, `A-CATALOG`, `A-STORE` | `IPAD-L1-073`, `IPAD-L1-095`, `APPLE-L1-010` | `BG-006`, `BG-008` sont partiels jusqu'aux injections ; clauses texte de `BG-011`/`BG-016` attendent Lot 2. |
| Couverture `COV-001` à `COV-007`, `DAT-005` | `A-PAGE`, `A-STORE` | `IPAD-L1-074`, `APPLE-L1-013` | Cache et fidélité composite sont différés ; styles Lot 2 de `COV-002` restent hors interface. |
| Photothèque interne `PHO-001` à `PHO-013`, `PHO-015` à `PHO-019`, `DAT-036`, `DAT-043` | `A-PHOTO`, `A-REUSE`, `A-DOM`, `A-RAW`, `A-STORE` | `IPAD-L1-075`, `IPAD-L1-077` à `IPAD-L1-081`, `IPAD-L1-111`, `IPAD-L1-121`, `IPAD-L1-124`, `IPAD-L1-125`, `APPLE-L1-005` | Déduplication couverte dans le Core ; grilles, modes de choix, sélecteurs, glisser-déposer et corpus réels attendent Apple. `PHO-014`, couplé à Auto, reste Lot 2. |
| Sources Apple `APL-001` à `APL-008` | Ordre et atomicité : `A-PHOTO`; validation metadata : `A-DOM`/`A-RAW` | `IPAD-L1-075` à `IPAD-L1-077`, `IPAD-L1-107` | Sélecteurs, progression et nouvelles tentatives sont manuels. |
| Formats `FMT-001` à `FMT-007`, `DAT-010`, `DAT-043` | `A-DOM`, `A-RAW`, `A-MANIFEST` | `IPAD-L1-076`, `IPAD-L1-077`, `APPLE-L1-005` | `FMT-008` dépend du PDF Lot 3. |
| Cadres photo `FRM-001` à `FRM-009` | `A-PHOTO`, `A-GEOM` | `IPAD-L1-080` à `IPAD-L1-083`, `IPAD-L1-096`, `IPAD-L1-104` | Rendu, libellés et commandes sont à vérifier sur iPad. |
| Cadrage `CRP-001` à `CRP-007`, `DAT-006` à `DAT-010` | `A-GEOM`, `A-PHOTO`, `A-DOM`, `A-RAW` | `IPAD-L1-087` à `IPAD-L1-089` | Gestes UIKit/SwiftUI et pixels réels restent manuels. |
| Canevas/éléments `CAN-001` à `CAN-009`, `ELM-001` à `ELM-014` applicables aux cadres photo | `A-GEOM`, `A-CLIP`, `A-DOM` | `IPAD-L1-083` à `IPAD-L1-086`, `IPAD-L1-114`, `IPAD-L1-115`, `IPAD-L1-127`, `APPLE-L1-003`, `APPLE-L1-007` | Sous-périmètre photo seulement ; gestes et poignées corrigés attendent l’iPad, texte/sticker le Lot 2. |
| Zoom de fenêtre `ZOM-001` à `ZOM-008` | `A-GEOM` | `IPAD-L1-090` à `IPAD-L1-092`, `IPAD-L1-128`, `APPLE-L1-003` | La composition mathématique zoom/panoramique est automatisée ; l'arbitrage tactile attend l'iPad. |
| Navigation `NAV-001` à `NAV-007`; réduction de mouvement applicable | `A-NAV-CLOUD` pour seuil/direction/bornes | `IPAD-L1-092`, `IPAD-L1-105`, `APPLE-L1-003`, `APPLE-L1-007` | L'animation finalisée `ANI-001` à `ANI-009` appartient au Lot 3 ; seul son prototype Lot 0 existe. |
| Annuler/Rétablir `UND-001` à `UND-012` | `A-ALB`, `A-PAGE`, `A-PHOTO`, `A-CLIP`, `A-CONC`, `A-TEXT` pour le prototype texte | preuves initiales applicables, puis `IPAD-L1-118`, `IPAD-L1-126`, `IPAD-L1-129` à `IPAD-L1-131` | Types publics Lot 1 seulement ; régressions correctives non testées. |
| Sauvegarde `SAV-001` à `SAV-004` | Journal et clôture : `A-STORE`, `A-CONC` | `IPAD-L1-093`, `IPAD-L1-109`, `IPAD-L1-129`, `APPLE-L1-011` | La fin de flux tactile corrigée et l’échec durable injecté ne sont pas encore prouvés sur Apple. |
| Presse-papiers `CLP-001` à `CLP-006` | `A-CLIP` | `IPAD-L1-083`, `IPAD-L1-130` | Portée de session à revalider ; cadre photo public, texte/sticker Lot 2. |
| Qualité `QLT-001` à `QLT-006` | `A-GEOM` | `IPAD-L1-097`, `APPLE-L1-006` | Export de `QLT-006` attend Lot 3. |
| Interface éditeur `EDT-001` à `EDT-021` applicable aux panneaux Photos/Fonds | État métier indirect : `A-PHOTO`, `A-PAGE`, `A-GEOM` | `IPAD-L1-113`, `IPAD-L1-118` à `IPAD-L1-120`, `IPAD-L1-127`, `IPAD-L1-131`, `APPLE-L1-003` | Inspecteur droit et séparation Contenu/Cadre nécessitent une preuve Apple ; panneaux et commandes Lots 2/3 exclus. |
| Accessibilité `ACC-001` à `ACC-008`, `ACC-011` à `ACC-017`, `ACC-020`, `ACC-021` | Description et géométrie : `A-DOM`, `A-PHOTO`, `A-GEOM` | `IPAD-L1-081`, `IPAD-L1-089`, `IPAD-L1-098` à `IPAD-L1-100`, `IPAD-L1-105`, `APPLE-L1-007` | Inspection exhaustive non exécutée. |
| Localisation `L10N-001` à `L10N-005` | Aucun test de catalogue de chaînes | `IPAD-L1-097` à `IPAD-L1-100`, `APPLE-L1-002` | Écart explicite pour `L10N-002`; les autres preuves restent partielles/manuelles. |
| Capacité/performance Lot 1 : `PAG-012`, `LOC-017`, `LOC-018`, `PERF-007` à `PERF-009`, `PERF-011`, `PERF-015` à `PERF-017` | `A-CAP`, hachage/vérification en flux `A-STORE`/`A-REUSE`, plus tests de déduplication `A-PHOTO`/`A-RAW` | `IPAD-L1-116`, `IPAD-L1-117`, `IPAD-L1-121`, `IPAD-L1-122`, `APPLE-L1-005`, `APPLE-L1-006` | Le cache asynchrone de fonds et les seuils de lancement/panneau ne sont qualifiables que sur Apple. |
| Sécurité locale/offline applicable : `SEC-001`, `SEC-007`, `SEC-008`, `SEC-010`, `SEC-011` | `A-REUSE`, `A-STORE`; revue statique | `IPAD-L1-101`, `IPAD-L1-107`, `APPLE-L1-005`, `APPLE-L1-012` | Nettoyage des temporaires à contrôler dans `IPAD-L1-107`; capture réseau, protection de fichiers et pression disque restent différées. |
| Erreurs Lot 1 applicables, notamment `ERR-001`, `ERR-008`, `ERR-014`, `ERR-017`, `ERR-021` | Rejets domaine/dépôt : `A-DOM`, `A-STORE`, `A-REUSE` | `IPAD-L1-075`, `IPAD-L1-077`, `IPAD-L1-093`, `IPAD-L1-101`, `APPLE-L1-010`, `APPLE-L1-011` | Formulation exacte et récupération UI attendent Apple. |

## Index des contrôles manuels iPad

Chaque ID ci-dessous possède une fiche détaillée dans `suivi_tests.md`. La
colonne automatisation associée facilite le diagnostic mais ne remplace jamais
les étapes manuelles.

| ID | Exigences principalement reliées | Automatisation associée |
|---|---|---|
| `IPAD-L1-063` | `LOT-001`, `ENV-002`, `ENV-005`, `LOC-029`, `LOC-031`, `DONE-005` | `A-STORE`, `A-MANIFEST` |
| `IPAD-L1-064` | `ALB-004`, création de `ALB-009`, `ALB-011` à `ALB-016`, `ACPT-100` | `A-ALB`, `A-STORE` |
| `IPAD-L1-065` | `ALB-001` à `ALB-003`, `APP-005` | `A-ALB`, `A-STORE` |
| `IPAD-L1-066` | renommage de `ALB-007`, `ALB-021`, `UND-011` | `A-ALB`, `A-CONC` |
| `IPAD-L1-067` | `ALB-008`, `ALB-017` à `ALB-019`, `ACPT-102` | `A-ALB`, `A-STORE` |
| `IPAD-L1-068` | `ALB-018`, `LOC-008`, `LOC-022` | `A-ALB`, `A-STORE` |
| `IPAD-L1-069` | `APP-002`, `APP-010`, `APP-011` | `A-CONC` |
| `IPAD-L1-070` | `PAG-001`, `PAG-002`, `PAG-006` à `PAG-010` | `A-PAGE` |
| `IPAD-L1-071` | `PAG-003` à `PAG-005`, `PAG-011`, `GLO-003` à `GLO-005`, `ACPT-104` | `A-PAGE` |
| `IPAD-L1-072` | `GLO-001` à `GLO-009` | `A-PAGE`, `A-GEOM` |
| `IPAD-L1-073` | `BG-001` à `BG-006` Lot 1, `BG-010`, `BG-012` à `BG-015` | `A-PAGE`, `A-DOM`, `A-CATALOG` |
| `IPAD-L1-074` | `COV-001` à `COV-006` Lot 1, `DAT-005`, `ACPT-103` | `A-PAGE` |
| `IPAD-L1-075` | `PHO-007`, `PHO-008`, `APL-001` à `APL-005`, `APL-007`, `ERR-001` | `A-PHOTO`, `A-DOM` |
| `IPAD-L1-076` | `FMT-001` à `FMT-003`, `FMT-005`, `FMT-007`, `TST-011` | `A-DOM`, `A-RAW`, `A-MANIFEST` |
| `IPAD-L1-077` | `PHO-007`, `PHO-008`, `FMT-004`, `FMT-006`, `APL-008` | `A-DOM`, `A-RAW` |
| `IPAD-L1-078` | `PHO-001` à `PHO-003`, `PHO-009`, `PHO-010` | `A-PHOTO` |
| `IPAD-L1-079` | `PHO-015` à `PHO-018`, `LOC-008` | `A-PHOTO`, `A-REUSE`, `A-STORE` |
| `IPAD-L1-080` | `PHO-004` à `PHO-006`, `PHO-011` à `PHO-013` | `A-PHOTO`, `A-GEOM` |
| `IPAD-L1-081` | `PHO-004`, `PHO-005`, `ACC-020` | `A-PHOTO` |
| `IPAD-L1-082` | `FRM-001` à `FRM-009` | `A-PHOTO`, `A-GEOM` |
| `IPAD-L1-083` | `ELM-009`, `CLP-001` à `CLP-004` | `A-CLIP` |
| `IPAD-L1-084` | `ELM-001`, `ELM-008`, `ELM-014` | `A-GEOM`, `A-CLIP` |
| `IPAD-L1-085` | `ELM-002` à `ELM-004`, `ELM-007`, `ELM-013` | `A-GEOM` pour invariants ; gestes manuels |
| `IPAD-L1-086` | `CAN-005`, `CAN-006`, `ELM-005`, `ELM-006` | `A-GEOM`, `A-DOM` |
| `IPAD-L1-087` | `DEC-07`, `CRP-001`, `CRP-004`, `CRP-006` | `A-GEOM` |
| `IPAD-L1-088` | `DEC-07`, `CRP-001`, `CRP-004` | `A-GEOM` |
| `IPAD-L1-089` | `CRP-002` à `CRP-007`, `DAT-006` à `DAT-010` | `A-GEOM`, `A-PHOTO`, `A-DOM`, `A-RAW` |
| `IPAD-L1-090` | `ZOM-001`, `ZOM-002`, `ZOM-007` | `A-GEOM` |
| `IPAD-L1-091` | `ZOM-003` à `ZOM-008` | `A-GEOM` |
| `IPAD-L1-092` | `NAV-001` à `NAV-007`, `ZOM-005` | `A-NAV-CLOUD`, `A-GEOM` |
| `IPAD-L1-093` | `APP-005`, `APP-006`, `APP-008`, `APP-009`, `SAV-001` à `SAV-003` partiel | `A-STORE`, `A-CONC` |
| `IPAD-L1-094` | `LOC-011` à `LOC-014`, `LOC-026` | `A-STORE`, `A-CONC` |
| `IPAD-L1-095` | `CAN-003`, `CAN-004`, `CAN-008`, `GLO-007`, `GLO-008` | `A-GEOM` pour composition logique |
| `IPAD-L1-096` | `FRM-001`, `FRM-008`, `GLO-006` | `A-PHOTO` |
| `IPAD-L1-097` | `QLT-001` à `QLT-006` partiel, `L10N-005` | `A-GEOM` |
| `IPAD-L1-098` | `EDT-002`, `EDT-004` à `EDT-006`, `EDT-011`, `EDT-016`, `EDT-020` photo, `ACC-021` | Revue UI ; pas d'équivalent Linux |
| `IPAD-L1-099` | `ACC-001` à `ACC-005`, `ACC-007`, `ACC-008`, `ACC-011`, `ACC-012`, `ACC-017`, `ACC-020`, `EDT-010` | `A-DOM`, `A-GEOM` partiels |
| `IPAD-L1-100` | `EDT-009`, `ELM-011` à `ELM-013`, `ACC-005`, `ACC-013` à `ACC-015` | `A-GEOM` pour pas de transformation |
| `IPAD-L1-101` | `LOC-001`, `SEC-001`, `ERR-008` | `A-STORE` |
| `IPAD-L1-102` | `DEC-33`, `LOC-029` à `LOC-031` | `A-STORE`, `A-DOM` |
| `IPAD-L1-103` | `PAG-012`, `LOC-018` photo, `PERF-008`, `PERF-015`, `PERF-017` | `A-CAP` |
| `IPAD-L1-104` | `EDT-003`, `EDT-004`, `EDT-007`, `EDT-010`, `EDT-012` à `EDT-017`, `FRM-005`, `FRM-006` dans le sous-périmètre Lot 1 | Revue UI ; états métier via `A-PHOTO` |
| `IPAD-L1-105` | `ACC-006`, sous-périmètre Lot 1 de `TST-010` | `A-NAV-CLOUD` pour l'automate seulement |
| `IPAD-L1-106` | aide du sous-périmètre Lot 1 de `EDT-019` | Aucun équivalent Linux |
| `IPAD-L1-107` | `APL-006`, `PERF-009`, `PERF-011`, `APP-006`, `SEC-008` | Atomicité via `A-PHOTO`; empreinte en flux via `A-STORE`; progression, annulation et nettoyage UI manuels |
| `IPAD-L1-108` | `APP-002`, `APP-005`, `LOC-011` à `LOC-014`, `UND-011` | `A-CONC` |
| `IPAD-L1-109` | `SAV-001`, `APP-009`, `LOC-011` à `LOC-014`, `LOC-026` | `A-STORE`, `A-CONC` ; fin tactile manuelle |
| `IPAD-L1-110` | `CAN-003`, `CAN-004`, `CAN-008`, `GLO-007`, `PERF-016` | `A-GEOM`, `A-CATALOG` ; rendu/cache Apple manuel |
| `IPAD-L1-111` | `FRM-001`, `FRM-008`, `GLO-006`, `PHO-011` à `PHO-013` | `A-PHOTO` ; mode de choix UI manuel |
| `IPAD-L1-112` | `QLT-001` à `QLT-006`, `EDT-021`, `L10N-005` | `A-GEOM` ; présentation UI manuelle |
| `IPAD-L1-113` | `EDT-002`, `EDT-006`, `EDT-011`, `EDT-016`, `EDT-021`, `ACC-021` | Revue UI Apple |
| `IPAD-L1-114` | `ELM-002`, `ELM-014`, `ACC-001` à `ACC-020` applicables | `A-DOM`, `A-GEOM` partiels ; VoiceOver manuel |
| `IPAD-L1-115` | `ELM-002`, `ELM-011` à `ELM-013`, `ACC-013` à `ACC-015` | `A-GEOM` ; toucher/pointeur manuels |
| `IPAD-L1-116` | `LOC-001`, `SEC-001`, `ERR-008`, `PERF-007`, `PERF-016` | `A-STORE`, `A-CATALOG` ; chronométrage Apple |
| `IPAD-L1-117` | `PAG-012`, `PHO-002`, `PERF-008`, `PERF-015`, `PERF-017` | `A-CAP`, `A-PHOTO` ; charge Apple manuelle |
| `IPAD-L1-118` | `EDT-010` à `EDT-017`, `EDT-021`, `FRM-005`, `FRM-006` | `A-PHOTO` partiel ; matrice UI manuelle |
| `IPAD-L1-119` | `ACC-006`, `EDT-002`, sous-périmètre Lot 1 de `TST-010` | `A-NAV-CLOUD` partiel ; animation Apple manuelle |
| `IPAD-L1-120` | `EDT-019`, `EDT-021`, `ARC-014`, `DEC-38` | Revue UI hors ligne |
| `IPAD-L1-121` | `APL-006`, `PHO-019`, `PERF-009`, `PERF-011`, `SEC-008` | `A-PHOTO`, `A-STORE` ; progression/annulation manuelles |
| `IPAD-L1-122` | `PERF-004`, `PERF-007`, `PERF-016`, `BG-008` | `A-CATALOG`, `A-STORE` ; chronométrage Apple |
| `IPAD-L1-123` | `ALB-006`, `ALB-017` à `ALB-025` | `A-ALB`, `A-STORE` ; localisation UI manuelle |
| `IPAD-L1-124` | `PHO-002`, `PHO-009`, `PHO-015`, `PHO-019` | `A-PHOTO`, `A-REUSE` ; grilles UI manuelles |
| `IPAD-L1-125` | `PHO-004`, `PHO-011` à `PHO-013`, `FRM-004` | `A-PHOTO`, `A-GEOM` ; modes UI manuels |
| `IPAD-L1-126` | `PAG-004`, `PAG-005`, `PAG-010`, `PAG-016` | `A-PAGE` ; glisser-déposer manuel |
| `IPAD-L1-127` | `ELM-002`, `ELM-013`, `ELM-014`, `EDT-021` | `A-GEOM` partiel ; gestes/UI manuels |
| `IPAD-L1-128` | `ZOM-003` à `ZOM-006`, `NAV-001` à `NAV-007` | `A-GEOM`, `A-NAV-CLOUD` ; arbitrage tactile manuel |
| `IPAD-L1-129` | `ELM-007`, `SAV-001` à `SAV-003`, `UND-007` | `A-STORE`, `A-CONC` ; flux tactile manuel |
| `IPAD-L1-130` | `CLP-001` à `CLP-006`, `UND-012` | `A-CLIP` |
| `IPAD-L1-131` | `ALB-006`, `APP-002`, `APP-005`, `EDT-021`, `LOC-011` à `LOC-014`, `UND-011` | `A-ALB`, `A-CONC`, `A-STORE` ; transitions UI manuelles |
| `IPAD-L1-132` | `ENV-001` à `ENV-005`, `LOT-001`, `DONE-005` | Parse AppModule et manifestes sous WSL ; compilation Swift Playgrounds manuelle indispensable |

## Index des validations Apple différées

| ID | Exigences reliées | Motif du différé |
|---|---|---|
| `APPLE-L1-001` | `ENV-006` à `ENV-009`, `TST-014` à `TST-016` | Compilation/tests Debug et Release avec SDK Apple. |
| `APPLE-L1-002` | `TST-003`, `TST-008` | Matrice iPhone/iPad, orientations et systèmes. |
| `APPLE-L1-003` | `EDT-010`, `ZOM-005`, `NAV-005`, `APP-010` | XCTest UI, focus, gestes et multi-fenêtre. |
| `APPLE-L1-004` | `LOC-004` à `LOC-026`, `TST-012` | Coupures injectées à chaque étape et purge sûre. |
| `APPLE-L1-005` | `LOC-006`, `LOC-019`, `LOC-020`, `SEC-011`, `PERF-004` | Disque, protection des fichiers, RAW volumineux et mémoire. |
| `APPLE-L1-006` | `PERF-001` à `PERF-009`, `ACPT-114` | Instruments indisponible sous WSL/iPad. |
| `APPLE-L1-007` | exigences Lot 1 de `ACC-001` à `ACC-021` | Accessibility Inspector et matrice matérielle. |
| `APPLE-L0-008` | `ENV-003`, `ARC-004`, `ARC-011`, prototype CloudKit | Entitlements, signature et zone privée CloudKit. |
| `APPLE-L1-009` | `DONE-005`, `TST-014`, `TST-015` | Archive, validation et TestFlight après campagne iPad. |
| `APPLE-L1-010` | `BG-008`, `ERR-017` | Ressource absente et fallback altéré par injection. |
| `APPLE-L1-011` | `SAV-003`, `SAV-004`, `ERR-014` | Erreur durable de dépôt contrôlée. |
| `APPLE-L1-012` | `SEC-001`, `SEC-010` | Capture réseau et inspection statique attribuée au processus. |
| `APPLE-L1-013` | `COV-007` | Instrumentation du cache composite de couverture. |

## Scénarios d'acceptation et TST-005

Chaque scénario individuel de la section 29 est relié ci-dessous. « Prototype »
ou « contrat » ne signifie jamais que le scénario utilisateur complet passe.

| Scénario | Version / lot de sortie | Tests et contrôles reliés | Conclusion autorisée |
|---|---|---|---|
| `ACPT-100` | 1.0 / Lot 1 | `A-ALB`, `A-PAGE`, `A-STORE`; `IPAD-L1-064`, `IPAD-L1-093`, `IPAD-L1-094` | Non conclu : contrôles manuels non exécutés. |
| `ACPT-102` | 1.0 / Lot 1 | `A-ALB`, `A-STORE`; `IPAD-L1-067`, `IPAD-L1-068` | Non conclu. |
| `ACPT-103` | 1.0 / Lot 1 | `A-PAGE`; `IPAD-L1-074`, `APPLE-L1-013` | Non conclu ; cache différé. |
| `ACPT-104` | 1.0 / Lot 1 | `A-PAGE`; `IPAD-L1-070`, `IPAD-L1-071` | Non conclu. |
| `ACPT-111` | 1.0 / Lot 3 | `A-MANIFEST` contrôle seulement schéma/exemples | Écart pour export/réimport autonome ; hors Lot 1 public. |
| `ACPT-112` | 1.0 / Lot 3 | `A-MANIFEST`, `A-CATALOG`; `APPLE-L1-004` pour les injections | Contrat partiel seulement, pas d'import utilisateur. |
| `ACPT-113` | 1.0 / Lot 3 | `A-GEOM` pour le calcul qualité uniquement | Écart PDF explicite ; aucun scénario PDF ne peut réussir au Lot 1. |
| `ACPT-114` | 1.0 / sortie Lot 3 puis Lot Qualité | `A-CAP`; `IPAD-L1-103`, `APPLE-L1-005`, `APPLE-L1-006` | Non conclu ; mesures instrumentées différées. |
| `ACPT-115` | 1.0 / sortie Lot 3 puis Lot Qualité | `A-DOM`, `A-GEOM`; `IPAD-L1-099`, `IPAD-L1-100`, `IPAD-L1-105`, `APPLE-L1-007` | Non conclu. |
| `ACPT-117` | 1.1 / Lot 4 | Aucun test fonctionnel Lot 0/1 | Hors périmètre ; écart attendu jusqu'au Lot 4. |
| `ACPT-118` | 1.1 / Lot 4 | `A-NAV-CLOUD` pour le prototype de plan de pages; `APPLE-L0-008` | Prototype partiel, aucune fusion CloudKit qualifiée. |
| `ACPT-119` | 1.1 / Lot 4 | Aucun test fonctionnel Lot 0/1 | Hors périmètre ; écart attendu. |
| `ACPT-120` | 1.1 / Lot 4 | `APPLE-L0-008` ne couvre que la faisabilité CloudKit | Hors périmètre ; écart attendu. |
| `ACPT-121` | 1.1 / Lot 4 | `A-ALB` couvre la corbeille locale seulement | Pas de corbeille synchronisée qualifiée. |
| `ACPT-122` | 1.2 / Lot 5 | Aucun test fonctionnel Lot 0/1 | Hors périmètre ; écart attendu. |
| `ACPT-123` | 1.0 / Lot 2 | `A-GEOM`, `A-NAV-CLOUD` et les contrôles Lot 1 prouvent des préconditions seulement | Non conclu : le scénario complet des cinq panneaux recevra de nouveaux contrôles Lot 2. |
| `ACPT-124` | 1.0 / Lot 1 | `A-PHOTO`, `A-GEOM`, `A-RAW`, `A-REUSE`; `IPAD-L1-075` à `IPAD-L1-089`, `IPAD-L1-097`, `APPLE-L1-005` | Non conclu. |
| `ACPT-125` | 1.0 / Lot 2 | `A-MANIFEST`, `A-LAYOUT` | Prototype interne uniquement ; aucune validation UI Lot 1. |
| `ACPT-126` | 1.0 / Lot 2 | `A-TEXT`, `A-DOM` | Prototype interne uniquement. |
| `ACPT-127` | 1.0 / Lot 3 | `A-PAGE`, `A-CATALOG`; `IPAD-L1-073`, `IPAD-L1-095`, `APPLE-L1-010` prouvent les préconditions de fonds | Non conclu : lecture et PDF recevront les contrôles de sortie Lot 3. |
| `ACPT-128` | 1.0 / Lot 2 | `A-CATALOG`, `A-SHAPE` | Contrat des six formes seulement ; stickers et cadres non publiés. |
| `ACPT-129` | 1.0 / Lot 1 | `A-PAGE`; `IPAD-L1-070` à `IPAD-L1-072`, `IPAD-L1-095`, `IPAD-L1-096` | Non conclu. |
| `ACPT-130` | 1.0 / Lot 2 | `A-CLIP`, `A-CONC`, `A-STORE` prouvent le sous-périmètre photo et la durabilité | Non conclu : photo, texte et sticker seront validés ensemble par de nouveaux contrôles Lot 2. |
| `ACPT-131` | 1.0 / Lots 1 à 3 | `A-GEOM`, `A-NAV-CLOUD`; `IPAD-L1-084` à `IPAD-L1-086`, `IPAD-L1-092`, `IPAD-L1-095` à `IPAD-L1-097`, `IPAD-L1-105`, `APPLE-L1-006`, `APPLE-L1-007` | Partiel : rendu/alertes Lot 1 et automate prototype ; lecture, diaporama, PDF et animation finale absents. |

## Écarts de traçabilité restant ouverts

- Les résultats `IPAD-L1-063…093` visent l’ancienne copie ; les fiches
  `094…101` et `103…108` devenues obsolètes ne prouvent pas le correctif.
  `IPAD-L1-102` reste non testé, les 23 régressions `109…131` ciblent
  `84ec71e1a66df4676e3c388e9d4f87a5a7e06e4e` et `IPAD-L1-132` doit d’abord en
  prouver la compilation.
- Les validations Apple listées ci-dessus sont différées et ne peuvent pas être
  remplacées par les tests Linux.
- `L10N-002` n'a pas de test de catalogue de chaînes identifié.
- Les exigences de package, PDF, lecture et diaporama disposent au mieux de
  contrats ou de moteurs partiels ; leurs parcours publics attendent le Lot 3.
- Les modèles, texte, stickers, formes et cadres disposent de prototypes ou
  contrats Lot 0, mais leur parité UI et leurs scénarios complets attendent le
  Lot 2.
- CloudKit, conflits et historique ne sont pas couverts fonctionnellement : le
  seul planificateur pur ne qualifie aucun scénario du Lot 4.
- Une exigence modifiée, une correction de code ou un nouveau candidat rend la
  preuve manuelle antérieure insuffisante et impose un nouvel ID de régression
  dans `suivi_tests.md`.
