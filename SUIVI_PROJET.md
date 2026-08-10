# Tableau de bord 3.0 — Album Photo

Ce fichier est le suivi opérationnel de la reconstruction 3.0. La source
normative reste [`spec.md`](spec.md), le fonctionnement du dépôt est décrit
dans [`README.md`](README.md) et chaque preuve manuelle est enregistrée dans
[`suivi_tests.md`](suivi_tests.md).

Le tableau de bord précédent reste consultable dans l’historique Git à la base
`06aaa59`. Il n’est pas repris comme preuve du nouveau code : conformément à
`DEC-33`, la reconstruction ne migre ni les sources, ni le store, ni les
résultats du prototype 2.1.

## Fiche du candidat

| Information | Valeur |
|---|---|
| Produit | Album Photo 3.0 |
| Date du suivi | 2026-08-10 |
| Phase courante | Candidat Lot 1 et spécification figés ; campagne iPad prête |
| Base avant reconstruction | `06aaa59` |
| Commit candidat | `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a` |
| Spécification de campagne | `031d2e46c70128c7e633db1f04663949e4531309` |
| Enveloppe iPad conservée | `Albumzh.swiftpm` ; son `Package.swift` généré n’a pas été recréé |
| Sources | Anciennes sources 2.1 supprimées, nouvelles sources 3.0 écrites from scratch |
| Stockage 3.0 | Nouvelle génération `AlbumPhotoCanvasV1` ; aucun parcours de migration 2.1 |
| Plateformes cibles | iPhone/iPad, iOS/iPadOS 26 minimum, portrait et paysage |
| Validation disponible | Noyau Swift multiplateforme sous WSL |
| Validation indispensable restante | Compilation et campagne manuelle Swift Playgrounds sur iPad, puis qualification Apple différée |
| État global | 🟡 **Candidat implémenté, non validé sur Apple** |

## Légende

| Repère | État | Règle d’emploi |
|---|---|---|
| ⬜ | Non commencé | Aucun travail vérifiable n’a débuté |
| 🟡 | En cours / à valider | Code ou contrat présent, mais preuve de sortie incomplète |
| 🟠 | Bloqué / à risque | Dépendance, ambiguïté normative ou environnement manquant |
| 🟢 | Terminé | Implémentation et toutes les preuves applicables sont acquises |
| ⏸️ | Différé | Travail appartenant explicitement à un lot ultérieur |

Aucun lot ni parcours d’interface de ce candidat n’est marqué 🟢 avant une
preuve Apple/iPad reproductible. Les 121 tests Core réussis prouvent le noyau
portable ; ils ne prouvent ni la compilation SwiftUI avec le SDK Apple, ni les
gestes tactiles, ni l’accessibilité, conformément à `ENV-004` et
`DONE-001` à `DONE-005`.

## Décisions appliquées

| Décision | Application dans le candidat |
|---|---|
| Reconstruction sans migration | `DEC-33` : la racine 3.0 est initialisée indépendamment ; aucun ancien store n’est lu ou converti. |
| Enveloppe Swift conservée | `Albumzh.swiftpm` reste le document créé depuis l’iPad ; seules ses anciennes sources sont remplacées. |
| Une seule page active | `DEC-05`, `GLO-001` : aucun mode ni réglage à deux pages ; la vue globale ne sert qu’à organiser les miniatures. |
| Zoom photo dynamique | `DEC-07`, section 3.1, `CRP-001` à `CRP-007` : `1×` correspond à la taille native centrée ; la borne basse est calculée à partir du cadre et de la photo, sans constante fixe ; `8×` reste la borne haute. |
| Zoom du canevas séparé | `ZOM-001` à `ZOM-008` : état de fenêtre de session, non sérialisé et distinct du cadrage photo. |
| Frontière stricte des lots | `ARC-014` : le schéma et les prototypes peuvent anticiper les lots suivants, mais l’interface publique du lot 1 n’expose que les fonctions du lot 1. Texte, stickers, modèles/dé/Auto, lecture, PDF et export restent masqués. |
| Données locales d’abord | `ARC-002`, section 18 : commandes métier via le service d’application, assets adressés par contenu et transactions journalisées ; les vues SwiftUI n’écrivent pas directement dans la base. |
| Commandes ordonnées | Toutes les opérations publiques du service d’application empruntent une file FIFO commune ; l’éditeur possède en plus une barrière FIFO d’interface afin qu’une fin de tâche ancienne ne puisse pas écraser un état plus récent (`APP-002`, `APP-005`, `LOC-011` à `LOC-014`). |
| RAW non destructif | L’original importé et son dérivé PNG statique immuable sont indexés et validés atomiquement. Le dérivé local est régénérable et reste hors du package logique v1, qui transporte l’original conformément à `PKG-008` et `PKG-021`. |
| Publication transactionnelle | Une erreur avant remplacement du snapshot échoue sans publier ; après remplacement durable, un défaut de nettoyage du journal reste un succès métier et le rejeu/nettoyage est idempotent (`LOC-011` à `LOC-026`). |
| Empreintes en flux | La finalisation, la déduplication, la vérification physique et la réutilisation interalbum calculent SHA-256 par blocs, avec comptage exact, sans charger l’original complet pour le seul hachage. |
| Ressources versionnées | Contrats figés pour 3 fonds, 6 formes natives et leurs 6 masques golden 64 × 48, ainsi que 32 modèles de prototype ; seuls les fonds relèvent de l’interface du lot 1. |

## Synthèse

| Périmètre | État | Preuve actuelle | Condition de sortie restante |
|---|---|---|---|
| Spécification et architecture 3.0 | 🟡 | Zoom dynamique confirmé ; frontière des lots 1 à 3 arbitrée par `DEC-38` et spécification figée dans la campagne ; ADR, schémas, contrats et traçabilité présents | Qualifier le candidat sur Apple |
| Lot 0 — Prototypes et contrats | 🟡 | Modèle, géométrie, texte, modèles/Auto, navigation, sérialisation, transaction, catalogue, schéma package et plan Cloud couverts par le Core et ses tests | Compiler sur iPad ; prouver les capacités Apple encore bloquées |
| Lot 1 — Création locale | 🟡 | Nouvelle bibliothèque et nouvel éditeur une page implémentés ; noyau portable couvert par 121 tests | Exécuter les 46 fiches `IPAD-L1-063` à `IPAD-L1-108` sur le commit figé |
| Lot 2 — Parité de composition | ⏸️ | Moteurs purs ou schéma préparatoires seulement ; aucune commande publique Lot 2 | Démarrer après validation du Lot 1 ; sortie `ACPT-123`, `ACPT-125`, `ACPT-126`, `ACPT-128`, `ACPT-130` |
| Lot 3 — Consultation/documents | ⏸️ | Schéma `.photoalbum` préparatoire seulement | Démarrer après le lot 2 |
| Lots 4 à 6 | ⏸️ | Plan CloudKit pur uniquement ; aucune capacité publique | Versions ultérieures et qualification dédiée |

**Résultat d’acceptation actuel :** aucun scénario du Lot 1 n’est déclaré
réussi. Ses sorties sont désormais uniquement `ACPT-100`, `ACPT-102` à
`ACPT-104`, `ACPT-124` et `ACPT-129` ; elles restent 🟡 jusqu’à leur preuve
sur le candidat exact.

## Lot 0 — Prototypes et contrats

| Chantier | État | Réalisation et preuve | Reste à faire |
|---|---|---|---|
| Domaine indépendant de SwiftUI | 🟡 | Nouveau `AlbumPhotoCore` : albums, pages, éléments, assets, index, validation et service d’application ; tests WSL inclus (`ARC-001` à `ARC-005`, `DAT-001` à `DAT-043`) | Confirmer son intégration dans l’App Playground |
| Canevas multiélément | 🟡 | Moteurs purs de géométrie, profondeur, hit-testing, poignées, magnétisme, rotation et cadrage dynamique testés (`CAN-001` à `CAN-009`, `ELM-001` à `ELM-014`, `CRP-001` à `CRP-007`) | Valider les gestes, cibles tactiles et retours haptiques sur iPad |
| Zoom de fenêtre et navigation | 🟡 | États purs de zoom ancré, centre normalisé et navigation testés (`ZOM-001` à `ZOM-008`, `NAV-001` à `NAV-007`) | Valider la priorité réelle des reconnaisseurs SwiftUI |
| Texte Photoweb | 🟡 | Prototype pur d’édition, sélection, styles, limite et débordement testé (`TXA-001` à `TXA-005`, `TBX-001` à `TBX-025`) | Fonction Lot 2 volontairement non exposée |
| Modèles, dé et automatisme | 🟡 | Manifeste de 32 modèles et moteurs déterministes purs testés (`TPL-001` à `TPL-023`, `RND-001` à `RND-006`, `AUT-001` à `AUT-019`) | Compléter `DAT-042`, puis exposer seulement au Lot 2 |
| Animation de page | 🟡 | Machine d’état interactive prototypée et testée (`ANI-001` à `ANI-009`) | Animation SwiftUI finale et Réduire les animations au Lot 3 |
| Sérialisation canonique | 🟡 | JSON canonique, empreinte logique SHA-256, exclusion explicite des dérivés locaux régénérables et golden tests du noyau (`DAT-020` à `DAT-028`, `PKG-008`, `PKG-021`) | Reconfirmer les fixtures avec le commit candidat |
| Transactions et reprise | 🟡 | Store adressé par contenu, file FIFO globale, journal, snapshot atomique et injections d’interruption testés, y compris commandes concurrentes ; après publication durable, un échec de nettoyage n’est plus présenté comme un échec métier (`LOC-011` à `LOC-026`) | Tester sur le système de fichiers Apple réel, notamment `afterAssetStaging`, `afterAssetValidation` et `afterGenerationRootPublish` encore sans injection automatisée directe |
| Génération de stockage isolée | 🟡 | Initialisation hors site puis renommage de `AlbumPhotoCanvasV1`, marqueur prêt et snapshot vide valide ; l’ancien store est ignoré (`DEC-33`) | Valider création, relance et manque d’espace sur iPad |
| Contrats de catalogue | 🟡 | Schéma extensible aux stickers/cadres futurs mais registre runtime limité à 3 fonds et 6 formes ; rendu Swift pur des formes, 6 masques golden 64 × 48, 32 modèles et 10 empreintes validés (`CAT-001` à `CAT-009`, `TPL-019`) | Reconfirmer chargement depuis le bundle Apple et repli hors ligne ; figer les payloads Lot 2 avant de les publier |
| Package `.photoalbum` | 🟡 | Schéma v1, documentation, exemple minimal et exemples invalides présents (`PKG-001` à `PKG-022`, `IMP-001` à `IMP-025`) | 🟠 Déclaration UTType, ouverture Fichiers et partage non testées dans Swift Playgrounds |
| CloudKit page par page | 🟠 | Planificateur pur et note de prototype présents (`SYN-001` à `SYN-003`) | Entitlements, zone et opérations CloudKit exigent un environnement Apple compatible |
| Traçabilité | 🟡 | Matrice détaillée par familles, méthodes automatisées, 46 contrôles iPad, 13 validations Apple différées et 24 scénarios `ACPT` | Compléter avec les résultats manuels du commit figé |

### Sortie du lot 0

Le lot 0 n’est pas terminé au sens de `DONE-002`. Les prototypes portables et
les contrats existent, mais le projet n’est pas encore démontré dans Swift
Playgrounds, le type de document n’est pas validé et CloudKit reste bloqué sur
la chaîne Apple.

## Lot 1 — Création locale

| Fonction | État | Réalisation candidate | Validation restante |
|---|---|---|---|
| Bibliothèque | 🟡 | Création avec nom obligatoire, tri, ouverture et cartes adaptatives (`ACPT-100`, section 6) | Compilation, ergonomie iPhone/iPad, persistance après relance |
| Renommage, corbeille et restauration | 🟡 | Cibles de dialogue typées, confirmation, restauration, suppression définitive et Annuler/Rétablir de session (`ACPT-102`, `DEC-16`, `DEC-25`) | Rejouer les parcours et vérifier qu’aucune mauvaise cible n’est modifiée |
| Bail d’édition | 🟡 | Un éditeur modifiable par album, seconde scène en lecture seule (`DEC-29`) | Test multi-fenêtre iPad |
| Éditeur à une page | 🟡 | Une page active sur toutes les tailles ; ancien `AlbumSpreadView` supprimé (`DEC-05`, `GLO-001`, `GLO-002`) | Portrait, paysage, Split View et iPhone réel |
| Pages et vue globale | 🟡 | Ajouter, supprimer avec confirmation, protéger la dernière page, réorganiser et ouvrir une miniature (`ACPT-104`, `ACPT-129`, `PAG-001` à `PAG-015`) | Fidélité des miniatures, gestes de réorganisation et persistance |
| Fonds par page | 🟡 | Trois fonds originaux, application à une page ou à toutes après confirmation, annulation et repli bundle/store (`BG-001` à `BG-016`) | Rendu du bundle Apple, relance et mode hors ligne |
| Couverture | 🟡 | Choix automatique de la première occurrence ou choix manuel par `pageID + elementID`, empreinte logique et cache de rendu préchargé (`ACPT-103`, `COV-001` à `COV-007`) | Transparence, cadrage, invalidation/suppression de l’occurrence et instrumentation du cache |
| Assets et transactions | 🟡 | Copie locale adressée par SHA-256 en flux borné, index global, dérivé RAW immuable, reprise de journal, commandes atomiques sérialisées et contrôle d’espace (`LOC-001` à `LOC-031`, section 22.8) | Interruption forcée et volume réel sur iPad |
| Import Apple multiple | 🟡 | PhotosPicker ordonné sous barrière métier dès le chargement, import Fichiers multiple `.image`, progression par fichier et globale, tâche d’annulation commune aux reprises, nettoyage des temporaires à l’annulation/fermeture/lancement, erreurs partielles et dérivé statique RAW (`PHO-001` à `PHO-018`, `APL-001` à `APL-008`, `SEC-008`) | Autorisations, RAW/HEIC/HDR/Live Photo, fichiers corrompus et mémoire sur iPad |
| Réutilisation interalbum | 🟡 | Vérification physique en flux de l’index, du MIME, de la taille et des empreintes de l’original et du dérivé RAW avant nouvel `assetID` logique partageant le contenu (`DEC-37`, `PHO-012` à `PHO-018`) | Parcours complet puis suppression indépendante de la source |
| Cadres multiples | 🟡 | Création, remplissage, remplacement, retrait, suppression, duplication, profondeur et glisser-déposer (`FRM-001` à `FRM-009`, `ELM-001` à `ELM-014`) | Hit-testing et concurrence des gestes sur écran tactile |
| Cadrage photo | 🟡 | `1×` natif centré, fond visible, borne basse dynamique, zoom continu, déplacement, rotation/retournement, Réinitialiser/Annuler/Terminé (`CRP-001` à `CRP-007`) | Cas 600×400 et 4 800×6 000, masque, persistance et priorité des gestes |
| Manipulation des éléments | 🟡 | Déplacement, huit poignées et rotation recalées dans la page même pour un cadre pleine page ou tourné, transformation deux doigts, guides, profondeur et sélection des éléments masqués (`ELM-001` à `ELM-014`) | Cibles constantes, haptique unique, clavier/pointeur et VoiceOver |
| Zoom du canevas | 🟡 | Paliers, Ajuster, pincement ancré et déplacement à deux doigts conservés par page en session (`ZOM-001` à `ZOM-008`) | Vérifier l’ancrage, les bornes et l’absence de mutation du document |
| Qualité photo | 🟡 | Calcul et badges trois états (`QLT-001` à `QLT-006`) | Contrôler les seuils, VoiceOver et rendu selon formats réels |
| Sauvegarde et annulation | 🟡 | État Enregistré/Enregistrement/Échec, sauvegarde explicite, piles de session, file FIFO Core + interface et absence de révision sur commande sans effet (`SAV-001` à `SAV-004`, `UND-001` à `UND-012`) | Interruption arrière-plan, échec disque, commandes rapides et relance |
| Presse-papiers | 🟡 | Couper, Copier, Coller, nouveaux identifiants, décalage visuel et ordre de profondeur pour les éléments du Lot 1 (`CLP-001` à `CLP-005`) | Collage interpage, annulation et persistance sur iPad |
| Navigation | 🟡 | Boutons et balayage horizontal, bornes et exclusions pendant cadrage/transformation/panneau (`NAV-001` à `NAV-007`) | Régression tactile prioritaire issue du prototype 2.1 |
| Prévisualisation et aide | 🟡 | Rendu sans aides d’édition, alerte de cadre vide et aide hors ligne contextuelle pour les panneaux exposés | Comparer rendu éditeur/global/prévisualisation et accessibilité |
| Adaptation/accessibilité | 🟡 | Composants natifs adaptatifs, panneau compact conservé dans la fenêtre du canevas pour le glisser-déposer, éléments de prévisualisation séparés, descriptions photo, position/profondeur/qualité VoiceOver et Réduire les animations ajoutés | Campagnes Dynamic Type, VoiceOver, clavier, pointeur, clair/sombre, iPhone/iPad |

### Sortie du lot 1

Le code candidat couvre le périmètre d’implémentation retenu, mais le lot reste
🟡. Le commit est figé ; il manque la compilation Apple et les résultats
détaillés `IPAD-L1-063+`. Aucun comportement n’est déclaré durable ou
tactilement valide sur la seule base des tests Linux.

## Arbitrage normatif appliqué

L’utilisateur a validé le 10 août 2026 la frontière stricte formalisée par
`DEC-38` :

- le Lot 1 reste la création photo locale avec les panneaux Photos et Fonds ;
- `ACPT-123` et `ACPT-130` deviennent des sorties du Lot 2, avec les cinq
  panneaux et le presse-papiers commun photo/texte/sticker ;
- `ACPT-127` devient une sortie du Lot 3, lorsque lecture et PDF sont livrés.

Le code candidat `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a` correspond déjà à
cette frontière. Aucun comportement n’est ajouté, retiré ou anticipé par la
présente modification documentaire.

## Garde-fous contre les erreurs du prototype 2.1

| Risque historique | Garde-fou 3.0 | Preuve encore nécessaire |
|---|---|---|
| Mauvaise portée d’un modificateur SwiftUI et imports Apple manquants | Vues réécrites en sous-vues plus petites, imports explicites, analyse syntaxique de toutes les sources AppModule | Type-check et compilation avec le SDK Apple |
| Expression SwiftUI trop complexe à compiler | Éditeur, canevas, panneaux, vue globale et composants de bibliothèque séparés | Compilation réelle dans Swift Playgrounds |
| Dialogue agissant sur la mauvaise cible ou perdant la cible avant confirmation | États de commandes et cibles typés ; la cible vit jusqu’à la résolution | Renommage, corbeille et suppression définitive manuels |
| Aperçu non rafraîchi, doubles sources de vérité ou réponses asynchrones réordonnées | `EditorViewModel` et service d’application centralisent les mutations ; les vues ne persistent rien directement ; files FIFO Core et interface | Changement rapide, fermeture, relance et multi-fenêtre (`IPAD-L1-108`) |
| Commande annoncée en échec après publication durable | La frontière de publication est explicite : les défauts de nettoyage post-snapshot sont récupérés de manière idempotente et ne provoquent pas une seconde action utilisateur | Injection équivalente sur le système de fichiers Apple |
| Import annulé laissant des temporaires ou terminant hors ordre | La barrière commence avant le transfert PhotosPicker ; la tâche est annulable et nettoie ses temporaires au `defer` et au lancement | Import long, fermeture de l’éditeur et relance (`IPAD-L1-107`) |
| Photo débordant de son cadre | Rendu masqué et geometry engine commun ; cadrage non destructif persistant | Cas réels rectangulaires, transparence et couverture |
| Reconnaisseurs de cadrage actifs hors mode | Sous-arbre et commandes de cadrage conditionnels ; navigation et transformation désactivées pendant le cadrage | Gestes tactiles imbriqués sur iPad |
| Navigation cassée par les gestes de cadrage | Priorités explicites entre contenu, élément, fenêtre et page ; gestes à deux doigts réservés au canevas sur zone vide | Balayages depuis plusieurs zones et vitesses |
| Pincement qui saute ou décentre la page | Zoom de fenêtre calculé autour du point médian et centre normalisé par page | Vérifier ancrage continu à 50–400 % |
| Rotation difficile ou décalée du doigt | Poignée dédiée, alternative Rotation… et calcul géométrique indépendant du rendu | Toucher, Apple Pencil, pointeur et VoiceOver |
| Poignées masquées sur un cadre bord à bord | Seule la composition est rognée ; les huit cibles et la rotation sont recalées dans les limites de la page avec une cible minimale | Vérifier cadre pleine page à 0° et après rotation (`IPAD-L1-088`) |
| Complexité du mode deux pages | Anciennes vues de double page supprimées ; une seule page logique et visuelle partout | Portrait, paysage et Split View |

## Validations exécutées

| Environnement | Commande ou contrôle | Résultat connu | Portée et limite |
|---|---|---|---|
| WSL, Swift 6.3.3, 2026-08-10 | `timeout 240 /home/gmessika/.local/share/swiftly/toolchains/6.3.3/usr/bin/swift test` | **121 tests, 0 échec**, 6,696 s | Noyau `AlbumPhotoCore` uniquement ; ne valide pas SwiftUI/iOS |
| WSL | `perl tools/validate_contracts.pl` | **OK** : 32 modèles, 3 fonds, 6 formes, schémas et package exemple | Contrats statiques uniquement |
| WSL | `(cd docs && sha256sum -c catalog-checksums-v1.sha256)` | **10/10 OK** : modèles, catalogue, schéma, contrat du renderer et 6 masques | Intégrité des fichiers du dépôt, pas leur chargement Apple |
| WSL, Swift 6.3.3 | Compilation puis exécution de `tools/generate_shape_goldens.swift` dans un répertoire temporaire | **OK** : les 6 PBM régénérés sont identiques byte à byte | Reproductibilité du renderer pur, pas le rendu SwiftUI |
| WSL, frontend Swift, 2026-08-10 | `find Albumzh.swiftpm/Sources/AppModule -name '*.swift' -print0 \| xargs -0 /home/gmessika/.local/share/swiftly/toolchains/6.3.3/usr/bin/swiftc -frontend -parse` | **OK** sur toutes les sources AppModule | Analyse syntaxique seulement, sans SDK ni type-check SwiftUI |
| WSL, C | `cc -Wall -Wextra -pedantic -fsyntax-only tools/generate_photo_fixture.c tools/normalize_png_4x5.c` | **OK** | Syntaxe des générateurs seulement |
| Dépôt, registre manuel | Contrôle de continuité, champs obligatoires, états et références normatives | **OK** : 46 fiches détaillées `063…108`, 46 états synthétiques ⚪, 13 validations Apple, 276 références manuelles résolues | Contrôle structurel ; aucune fiche manuelle exécutée |
| Dépôt, traçabilité | Contrôle des identifiants, méthodes, classes et liens de `docs/traceability/lot0-lot1.md` | **OK** : 46 contrôles iPad, 13 Apple, 24 `ACPT`, méthodes/classes/liens résolus après correction des écarts | Ne transforme aucune couverture structurelle en réussite fonctionnelle |
| Dépôt, arbitrage des lots, 2026-08-10 | Vérification de `DEC-38`, des trois lots de validation, des sorties de la section 31 et du registre manuel | **OK** : Lot 1 = six sorties photo locales ; `ACPT-123`/`130` au Lot 2 ; `ACPT-127` au Lot 3 ; 276 références manuelles résolues | Documentation uniquement ; tests Core non relancés car aucune source ni ressource n’a changé |
| Dépôt | `git diff --exit-code -- Albumzh.swiftpm/Package.swift Package.swift` | **OK** : les deux manifestes sont inchangés | Confirme la conservation de l’enveloppe, pas sa compilation Apple |
| Dépôt | `git diff --check` | **OK** après écriture du code, des contrats et du registre manuel ; à rejouer après fixation des hashes | Contrôle des espaces et marqueurs de conflit, pas une preuve fonctionnelle |

## Validations non exécutées

| Validation | État | Motif |
|---|---|---|
| Compilation de `Albumzh.swiftpm` dans Swift Playgrounds | ⚪ Non testée | Nécessite l’iPad de l’utilisateur et le commit candidat figé |
| Tests manuels détaillés Lot 1 | ⚪ Non testés | La campagne `IPAD-L1-063+` doit viser le hash exact du candidat |
| iPhone réel | ⚪ Non testé | Aucun appareil ni build TestFlight qualifié dans cette remise |
| Xcode/macOS et simulateurs | ⚪ Non testés | SDK Apple absent de WSL ; campagne différée selon `ENV-006` à `ENV-009` |
| VoiceOver, Dynamic Type, clavier, pointeur et Réduire les animations | ⚪ Non testés | Comportements impossibles à conclure par analyse Linux |
| Performance 100 pages/5 Go et mémoire RAW | ⚪ Non testée | Fixtures et instrumentation Apple nécessaires |
| UTType/package `.photoalbum`, partage, PDF | ⚪ Non testés | Déclarations et fonctions Lot 3 non exposées dans le candidat Lot 1 |
| CloudKit | 🟠 Bloqué | Entitlements et conteneur non disponibles sous WSL |

## Risques et blocages

| ID | Niveau | Risque | Mesure actuelle / condition de levée |
|---|---|---|---|
| `RSK-3.0-001` | Élevé | Le ledger ne recense pas encore toutes les références récupérables futures (révisions, conflits, certains états différés). Une purge physique naïve pourrait supprimer trop tôt. | La purge physique reste désactivée au Lot 1 ; accepter une fuite disque temporaire plutôt qu’une perte. Compléter le ledger avant toute purge. |
| `RSK-3.0-002` | Moyen | `DAT-042` n’est couvert que partiellement : résolution et provenance complètes des placements de modèle restent à finaliser. | Ne pas exposer modèles/dé/Auto avant le Lot 2 et ajouter des golden tests de résolution. |
| `RSK-3.0-003` | Élevé | Le hachage, la déduplication et la réutilisation sont désormais en flux borné, mais ImageIO, la création du dérivé et certains chemins d’affichage chargent encore le média complet ; un RAW volumineux peut donc créer un pic mémoire. | Mesurer sur iPad et instrumenter les chemins de décodage avant de revendiquer l’enveloppe 5 Go. |
| `RSK-3.0-004` | Élevé | L’analyse Linux ne détecte pas les erreurs de disponibilité, de type SwiftUI ou de bundle du SDK iOS 26. | Compiler d’abord le candidat exact dans Swift Playgrounds ; corriger sans réintroduire les bugs 2.1. |
| `RSK-3.0-005` | Levé | Les anciennes sorties de Lot 1 pour `ACPT-123`, `ACPT-127` et `ACPT-130` contredisaient la frontière des lots. | Arbitrage utilisateur enregistré par `DEC-38` : scénarios déplacés respectivement aux Lots 2, 3 et 2. |
| `RSK-3.0-006` | Élevé | Les conflits de gestes ne peuvent être prouvés sans tactile : déplacement, pincement, rotation, cadrage et navigation partagent le canevas. | Exécuter les tests gestuels dédiés, un par un, sur iPad. |
| `RSK-3.0-007` | Moyen | La performance, le chargement des miniatures, le stockage 5 Go et la robustesse à 100 pages ne sont pas mesurés. | Campagne de stress Apple et Instruments lors de la qualification Xcode. |
| `RSK-3.0-008` | Élevé | Accessibilité et adaptation iPhone/iPad ne sont pas vérifiées malgré les libellés et composants ajoutés. | Tester VoiceOver, Dynamic Type, clavier/pointeur, orientations, Split View et iPhone réel. |
| `RSK-3.0-009` | Élevé | CloudKit et le type de document package dépendent de capacités ou réglages Swift Playgrounds non prouvés. | Prototype Apple ciblé ; escalade vers Xcode/macOS si indisponible. |
| `RSK-3.0-010` | Moyen | `L10N-002` n’est pas encore satisfait : les libellés français sont présents dans les vues mais aucun catalogue `.xcstrings` n’est livré. | Conserver le candidat interne ; créer et valider le catalogue au lot Qualité avant de déclarer une fonctionnalité terminée. |
| `RSK-3.0-011` | Moyen | Le cache de couverture SwiftUI n’a pas encore de preuve instrumentée d’invalidation ni de budget mémoire sur appareil. | Exécuter le parcours couverture, puis instrumenter le cache avant de déclarer `COV-007` satisfait. |
| `RSK-3.0-012` | Moyen | Une tâche déjà en attente dans la file durable n’est pas retirée par l’annulation Swift et exécutera son tour ; c’est souhaité pour une commande durable soumise, mais ce contrat ne convient pas à une future commande explicitement annulable. | Les imports vérifient leur annulation entre fichiers et conservent les copies déjà publiées ; rendre les waiters sensibles à l’annulation avant d’étendre ce mécanisme à d’autres opérations annulables. |
| `RSK-3.0-013` | Faible | La fermeture d’une session vide l’historique sans republier immédiatement certains `referenceCount`, qui peuvent rester temporairement surévalués. | La purge physique est désactivée et la surévaluation ne peut pas perdre de données ; recomputer et persister le ledger avant toute purge future. |
| `RSK-3.0-014` | Moyen | L’URL physique d’un blob peut être obtenue sans verrou de fichier OS ; l’immuabilité dépend actuellement de tous les écrivains du dépôt respectant les acteurs. | Les chemins internes vérifient taille et empreinte avant réutilisation ; réduire l’exposition de l’URL et ajouter protection/verrouillage avant toute écriture externe ou purge. |

## Prochaines actions

1. Transférer le commit candidat
   `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a` sur l’iPad, relever le modèle,
   iPadOS et Swift Playgrounds, puis exécuter en premier la compilation et le
   lancement à froid contre la spécification
   `031d2e46c70128c7e633db1f04663949e4531309`.
2. Exécuter la campagne Lot 1 une fiche à la fois ; enregistrer chaque réponse
   sous la forme `IPAD-L1-xxx OK`, `BLOQUÉ` ou `BUG : …` sans extrapolation.
3. Corriger chaque anomalie sur un nouveau commit et créer un nouvel identifiant
   de régression lorsque la preuve précédente devient insuffisante.
4. Après viabilité iPad, préparer les nouveaux identifiants de tests du Lot 2
   pour `ACPT-123`, `ACPT-125`, `ACPT-126`, `ACPT-128` et `ACPT-130`.
5. Organiser ensuite les campagnes iPhone, Xcode/macOS,
   accessibilité, performance et interruption transactionnelle.

## Journal des mises à jour

Le journal 3.0 repart de zéro ; l’historique détaillé du prototype 2.1 reste
dans Git à `06aaa59`. Les entrées les plus récentes doivent rester en haut.

| Date | Auteur | Changement | Fichiers et exigences | Validation |
|---|---|---|---|---|
| 2026-08-10 | Codex | Arbitrage des lots appliqué sans modification du candidat : Lot 1 Photos/Fonds, Lot 2 composition Photoweb complète et presse-papiers multi-types, Lot 3 lecture/documents ; empreinte normative injectée dans toute la campagne | `spec.md`, `README.md`, `docs/traceability/lot0-lot1.md`, `suivi_tests.md`, `SUIVI_PROJET.md` ; `DEC-38`, `ARC-014`, `ACPT-123`, `ACPT-127`, `ACPT-130` | Spécification `031d2e46c70128c7e633db1f04663949e4531309` ; contrats OK ; sorties cohérentes ; 46 fiches, 13 Apple, 50 cartes et 276 références manuelles résolues ; tests Core non relancés car code inchangé |
| 2026-08-10 | Codex | Gel du candidat d’implémentation et de spécification, puis injection de son empreinte Git exacte dans les 46 fiches iPad et les validations Apple différées | `suivi_tests.md`, `SUIVI_PROJET.md` ; `TST-001` à `TST-016`, `DONE-001` à `DONE-005` | Candidat `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a` ; toutes les fiches restent ⚪ NON TESTÉ ; aucune preuve Apple extrapolée |
| 2026-08-10 | Codex | Audit final avant gel : correction de la frontière de publication transactionnelle, SHA-256 et vérification en flux, annulation/nettoyage des imports initiaux et repris, suppression de page sûre, poignées pleine page, panneau compact glissable, accessibilité de prévisualisation, risques résiduels documentés et traçabilité exhaustive | `Albumzh.swiftpm/Sources/AlbumPhotoCore/`, `Albumzh.swiftpm/Sources/AppModule/`, `Tests/AlbumPhotoCoreTests/`, `docs/traceability/lot0-lot1.md`, `suivi_tests.md`, `SUIVI_PROJET.md` ; `LOC-011` à `LOC-026`, `APL-006`, `PERF-009`, `PERF-011`, `SEC-008`, `PAG-006`, `ELM-005` à `ELM-009`, `ACC-001` à `ACC-021` | 121 tests Core sans échec (6,696 s) ; contrats, 10 checksums, 6 goldens, parse AppModule, syntaxe C, manifestes, registre, traçabilité et `git diff --check` OK ; Apple/iPad NON TESTÉ ; candidat encore `À figer` |
| 2026-08-10 | Codex | Finalisation avant gel : file FIFO commune du service et barrière FIFO de l’éditeur, baux de bibliothèque/édition, dérivé RAW immuable et indexé, renderer pur des 6 formes avec golden masks, cache de couverture, progression d’import, descriptions accessibles et fiche de régression des commandes rapides | `Albumzh.swiftpm/Sources/AlbumPhotoCore/`, `Albumzh.swiftpm/Sources/AppModule/`, `Tests/AlbumPhotoCoreTests/`, `docs/catalog-*`, `docs/golden/`, `tools/`, `suivi_tests.md`, `SUIVI_PROJET.md` ; `APP-002`, `APP-005`, `LOC-011` à `LOC-014`, `PHO-015` à `PHO-018`, `FMT-002`, `CAT-009`, `COV-007`, `APL-006`, `ACC-001` à `ACC-020` | 118 tests Core sans échec ; contrats OK ; 10/10 checksums ; 6 goldens régénérés à l’identique ; parse AppModule, syntaxe C, manifestes inchangés et `git diff --check` OK ; Apple/iPad NON TESTÉ ; candidat encore `À figer` |
| 2026-08-10 | Codex | Reprise après interruption, gel du Core à 91 tests, finalisation des dérivés RAW persistants, de la qualité régionale, des baux par scène et des arbitrages de gestes ; relance de toutes les validations WSL avant le commit candidat | `Albumzh.swiftpm/Sources/AlbumPhotoCore/`, `Albumzh.swiftpm/Sources/AppModule/`, `Tests/AlbumPhotoCoreTests/`, `README.md`, `SUIVI_PROJET.md` ; `ALB-020`, `PHO-015`, `APL-007`, `FMT-002`, `QLT-001` à `QLT-006`, `APP-002`, `APP-011`, `ELM-009`, `CRP-003`, `ZOM-006` | 91 tests Core sans échec ; contrats, checksums, parse AppModule, syntaxe C, manifestes inchangés et `git diff --check` réussis ; Apple/iPad toujours NON TESTÉ ; candidat encore `À figer` |
| 2026-08-06 | Codex | Reconstruction from scratch des lots 0 et 1 dans l’enveloppe `Albumzh.swiftpm` : nouveau domaine, stockage transactionnel, contrats/catalogues, assets de fonds, AppModule à une page, import et composition photo ; mise à jour normative du zoom dynamique et création d’un tableau de bord 3.0 neuf | `spec.md`, `README.md`, `Albumzh.swiftpm/Sources/AlbumPhotoCore/`, `Albumzh.swiftpm/Sources/AppModule/`, `Tests/AlbumPhotoCoreTests/`, `docs/`, `tools/`, `SUIVI_PROJET.md` ; `DEC-05`, `DEC-07`, `DEC-33` à `DEC-37`, lots 0/1, `ACPT-100`, `102` à `104`, `123`, `124`, `127`, `129`, `130` | WSL : 91 tests Core sans échec, contrats et checksums OK ; parse AppModule intermédiaire réussi mais à reconfirmer ; Apple/iPad, accessibilité et performance NON TESTÉS ; candidat `À figer` |

## Règle de maintien

Toute modification du dépôt doit mettre ce tableau à jour dans le même
changement. Un code écrit ou un test Linux réussi reste 🟡 tant que les preuves
Apple applicables manquent. Les résultats manuels ne valent que pour le commit,
l’appareil et les versions logicielles enregistrés, et aucun retour global ne
doit être transformé en série de réussites détaillées.
