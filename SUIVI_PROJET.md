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
| Date du suivi | 2026-08-16 |
| Phase courante | Corrections du Lot 1 après première campagne iPad |
| Base avant reconstruction | `06aaa59` |
| Candidat de première campagne | implémentation `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a` ; copie iPad `aeae5c439c461e7994117067d81a416591d348bd`, déclarée identique |
| Candidat correctif rejeté | `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` — deux erreurs de compilation Apple signalées |
| Correctif de compilation | arbre de travail basé sur `530e87dbcb1a3332537facdc9902c06c24a034b0` ; empreinte à figer après commit |
| Spécification de première campagne | `031d2e46c70128c7e633db1f04663949e4531309` |
| Spécification du correctif | `spec.md` inclus dans `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` |
| Enveloppe iPad conservée | `Albumzh.swiftpm` ; son `Package.swift` généré n’a pas été recréé |
| Sources | Anciennes sources 2.1 supprimées, nouvelles sources 3.0 écrites from scratch |
| Stockage 3.0 | Nouvelle génération `AlbumPhotoCanvasV1` ; aucun parcours de migration 2.1 |
| Plateformes cibles | iPhone/iPad, iOS/iPadOS 26 minimum, portrait et paysage |
| Validation disponible | Noyau Swift multiplateforme sous WSL |
| Validation indispensable restante | Figer puis compiler le correctif minimal dans Swift Playgrounds sur iPad, puis rejouer les régressions et la qualification Apple différée |
| État global | 🟡 **Erreurs de compilation du premier correctif corrigées et validées syntaxiquement sous WSL ; nouvelle compilation iPad requise** |

## Légende

| Repère | État | Règle d’emploi |
|---|---|---|
| ⬜ | Non commencé | Aucun travail vérifiable n’a débuté |
| 🟡 | En cours / à valider | Code ou contrat présent, mais preuve de sortie incomplète |
| 🟠 | Bloqué / à risque | Dépendance, ambiguïté normative ou environnement manquant |
| 🟢 | Terminé | Implémentation et toutes les preuves applicables sont acquises |
| ⏸️ | Différé | Travail appartenant explicitement à un lot ultérieur |

Aucun lot ni parcours d’interface de ce candidat n’est marqué 🟢 avant une
preuve Apple/iPad reproductible. Les 123 tests Core réussis prouvent le noyau
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
| Lot 1 — Création locale | 🟡 | Nouvelle bibliothèque et nouvel éditeur une page implémentés ; première campagne `063…093` enregistrée ; erreurs de type-check signalées sur `06c30b9…` corrigées | Figer le correctif, exécuter d’abord `IPAD-L1-132`, puis `102` et les régressions `109…131` |
| Lot 2 — Parité de composition | ⏸️ | Moteurs purs ou schéma préparatoires seulement ; aucune commande publique Lot 2 | Démarrer après validation du Lot 1 ; sortie `ACPT-123`, `ACPT-125`, `ACPT-126`, `ACPT-128`, `ACPT-130` |
| Lot 3 — Consultation/documents | ⏸️ | Schéma `.photoalbum` préparatoire seulement | Démarrer après le lot 2 |
| Lots 4 à 6 | ⏸️ | Plan CloudKit pur uniquement ; aucune capacité publique | Versions ultérieures et qualification dédiée |

**Résultat d’acceptation actuel :** sur `IPAD-L1-063` à `IPAD-L1-093`, la
campagne du 16 août enregistre 18 réussites, 8 échecs, 4 blocages matériels ou
de fixture et 1 fiche non applicable. Ces preuves visent la copie
`aeae5c439c461e7994117067d81a416591d348bd` et ne valideront pas le prochain
candidat correctif. Les sorties `ACPT-100`, `ACPT-102` à `ACPT-104`,
`ACPT-124` et `ACPT-129` restent donc 🟡 jusqu’aux régressions applicables.

## Première campagne iPad du 16 août 2026

| Groupe | Résultat confirmé | Suite |
|---|---|---|
| Bibliothèque, pages, fonds, couverture et cadrage principal | Parcours métier largement fonctionnels | Corriger lancement, retour post-création, dates de corbeille, insertion de page et page active après Rétablir |
| Photos | Imports et placements de base fonctionnels | Corriger grilles carrées, déduplication intra-album, compteurs, annonce d’usage et modes Ajouter/Remplir/Remplacer |
| Sélection et interface | Transformations réussies | Installer l’inspecteur droit, rendre les choix non ambigus, séparer qualité/commandes, ajouter poignées hybrides et aperçu de rotation |
| Gestes et sauvegarde | Pincement et persistance de base observés | Corriger panoramique à deux doigts, réinitialisation du balayage et fin de geste après Sauvegarder |
| Environnement | iPad 8e génération, iPadOS 26.5.2, Swift Playgrounds 4.7, français (France), Paris | Multi-fenêtre et haptique restent bloqués ; RAW différé jusqu’à une fixture décodable |

Le RAW synthétique `raw.dng` reste volontairement hors de ce correctif : son
refus ne permet pas de distinguer une anomalie applicative d’une fixture non
décodable par ImageIO. `IPAD-L1-076` demeure bloqué et aucun résultat RAW n’est
extrapolé.

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
| Traçabilité | 🟡 | Matrice détaillée par familles, méthodes automatisées, 70 contrôles iPad, 13 validations Apple différées et 24 scénarios `ACPT` | Figer le correctif puis compléter avec les résultats manuels de `132`, `102` et `109…131` |

### Sortie du lot 0

Le lot 0 n’est pas terminé au sens de `DONE-002`. Les prototypes portables et
les contrats existent, mais le projet n’est pas encore démontré dans Swift
Playgrounds, le type de document n’est pas validé et CloudKit reste bloqué sur
la chaîne Apple.

## Lot 1 — Création locale

| Fonction | État | Réalisation candidate | Validation restante |
|---|---|---|---|
| Bibliothèque | 🟡 | Création avec nom obligatoire, tri, cartes adaptatives et ouverture post-création différée jusqu’à la fermeture complète de la feuille (`ALB-006`, `ACPT-100`) | Compiler puis vérifier Retour immédiatement après création (`IPAD-L1-123`) |
| Renommage, corbeille et restauration | 🟡 | Cibles typées, confirmation, restauration, suppression définitive, Annuler/Rétablir et deux dates absolues localisées (`ALB-017` à `ALB-025`, `ACPT-102`) | Rejouer la corbeille en français et la durée exacte sur iPad (`IPAD-L1-123`) |
| Bail d’édition | 🟡 | Un éditeur modifiable par album, seconde scène en lecture seule (`DEC-29`) | Test multi-fenêtre iPad |
| Éditeur à une page | 🟡 | Une page active sur toutes les tailles ; ancien `AlbumSpreadView` supprimé (`DEC-05`, `GLO-001`, `GLO-002`) | Portrait, paysage, Split View et iPhone réel |
| Pages et vue globale | 🟡 | Ajouter/supprimer/réorganiser, indicateur d’insertion clignotant ou fixe avec Réduire les animations, et activation de la page recréée par Rétablir (`PAG-001` à `PAG-016`) | Vérifier dépôt et page active sur iPad (`IPAD-L1-126`) |
| Fonds par page | 🟡 | Trois fonds, application ciblée/globale, bootstrap absent différé après le premier contenu, miniatures asynchrones dimensionnées et caches mémoire/disque (`BG-001` à `BG-016`, `PERF-007`, `PERF-016`) | Chronométrer relances et réouvertures de Fonds hors ligne (`IPAD-L1-110`, `116`, `122`) |
| Couverture | 🟡 | Choix automatique de la première occurrence ou choix manuel par `pageID + elementID`, empreinte logique et cache de rendu préchargé (`ACPT-103`, `COV-001` à `COV-007`) | Transparence, cadrage, invalidation/suppression de l’occurrence et instrumentation du cache |
| Assets et transactions | 🟡 | Copie locale adressée par SHA-256 en flux borné, index global, dérivé RAW immuable, reprise de journal, commandes atomiques sérialisées et contrôle d’espace (`LOC-001` à `LOC-031`, section 22.8) | Interruption forcée et volume réel sur iPad |
| Import Apple multiple | 🟡 | PhotosPicker ordonné, import Fichiers multiple, progression/annulation/nettoyage, erreurs partielles et déduplication intra-album par `contentHash` sans commande vide (`PHO-001` à `PHO-019`, `APL-001` à `APL-008`, `SEC-008`) | Rejouer imports répétés/lot/annulation ; RAW explicitement différé (`IPAD-L1-121`) |
| Réutilisation interalbum | 🟡 | Vérification physique avant nouvel `assetID`, grilles source carrées, détection Déjà ajoutée par hash et compteurs `×N` limités à l’`assetID` de l’album courant (`DEC-37`, `PHO-002`, `PHO-015` à `PHO-019`) | Parcours complet, grille à quatre colonnes et suppression indépendante (`IPAD-L1-124`) |
| Cadres multiples | 🟡 | Création, modes Ajouter/Remplir/Remplacer annoncés, retrait, suppression, duplication, profondeur, glisser-déposer et choix non ambigus par nom/position/profondeur (`FRM-001` à `FRM-009`, `PHO-011` à `PHO-013`, `ELM-014`) | Vérifier les trois modes et VoiceOver (`IPAD-L1-111`, `114`, `125`) |
| Cadrage photo | 🟡 | `1×` natif centré, fond visible, borne basse dynamique, zoom continu, déplacement, rotation/retournement, Réinitialiser/Annuler/Terminé (`CRP-001` à `CRP-007`) | Cas 600×400 et 4 800×6 000, masque, persistance et priorité des gestes |
| Manipulation des éléments | 🟡 | Contour et poignées visuelles sur les bordures réelles avec cibles de secours distinctes, aperçu direct de Rotation…, inspecteur droit Contenu/Cadre et Supprimer rapide (`ELM-001` à `ELM-014`, `EDT-021`) | Cibles, rotation, haptique, clavier/pointeur et VoiceOver sur iPad (`IPAD-L1-115`, `127`) |
| Zoom du canevas | 🟡 | Reconnaisseur UIKit unifié composant pincement et panoramique à deux doigts, moteur pur testé, état par page en session (`ZOM-001` à `ZOM-008`) | Vérifier arbitrage tactile et mémoire de page (`IPAD-L1-128`) |
| Qualité photo | 🟡 | Calcul trois états conservé ; présentation transformée en libellé informatif non interactif dans l’inspecteur (`QLT-001` à `QLT-006`, `EDT-021`) | Contrôler seuils, région et VoiceOver (`IPAD-L1-112`) |
| Sauvegarde et annulation | 🟡 | Sauvegarde explicite finalise une géométrie en cours puis ignore le reste de l’ancien flux tactile ; page recréée activée après Rétablir (`SAV-001` à `SAV-004`, `PAG-016`, `UND-001` à `UND-012`) | Vérifier absence de saut/double commande, interruption et commandes rapides (`IPAD-L1-109`, `129`, `131`) |
| Presse-papiers | 🟡 | Couper/Copier/Coller limités à la session et à l’album ; fermeture ou arrière-plan invalide définitivement le payload (`CLP-001` à `CLP-006`) | Revalider collage intrasession et invalidation (`IPAD-L1-130`) |
| Navigation | 🟡 | Compteur forcé sur une ligne ; identité des sous-vues et états gestuels réinitialisés à chaque page ; priorités contenu/canevas/page renforcées (`NAV-001` à `NAV-007`) | Rejouer les allers-retours page 1 et les gestes combinés (`IPAD-L1-128`) |
| Prévisualisation et aide | 🟡 | Rendu sans aides d’édition, alerte de cadre vide et aide hors ligne contextuelle pour les panneaux exposés | Comparer rendu éditeur/global/prévisualisation et accessibilité |
| Adaptation/accessibilité | 🟡 | Inspecteur fixé à droite en largeur régulière, panneau compact dans la même fenêtre, commandes séparées Contenu/Cadre, libellés distinctifs avec position/profondeur, placeholders et Réduire les animations (`EDT-002`, `EDT-021`, `ACC-001` à `ACC-021`) | Campagnes `IPAD-L1-113…120`, puis iPhone/Xcode |

### Sortie du lot 1

Le code candidat couvre le périmètre d’implémentation retenu, mais le lot reste
🟡. Le correctif `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` n’a pas compilé
avec le SDK Apple. Les deux diagnostics signalés sont corrigés dans l’arbre de
travail ; il reste à figer ce correctif, réussir `IPAD-L1-132`, puis exécuter
`IPAD-L1-102` et `IPAD-L1-109…131`. Aucun comportement corrigé n’est déclaré
durable ou tactilement valide sur la seule base des tests Linux.

## Arbitrage normatif appliqué

L’utilisateur a validé le 10 août 2026 la frontière stricte formalisée par
`DEC-38` :

- le Lot 1 reste la création photo locale avec les panneaux Photos et Fonds ;
- `ACPT-123` et `ACPT-130` deviennent des sorties du Lot 2, avec les cinq
  panneaux et le presse-papiers commun photo/texte/sticker ;
- `ACPT-127` devient une sortie du Lot 3, lorsque lecture et PDF sont livrés.

La base `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a` et le correctif figé
`06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` conservent cette frontière. Aucun
comportement des lots 2 ou 3 n’est rendu public par les corrections de la
campagne iPad.

## Garde-fous contre les erreurs du prototype 2.1

| Risque historique | Garde-fou 3.0 | Preuve encore nécessaire |
|---|---|---|
| Mauvaise portée d’un modificateur SwiftUI et imports Apple manquants | Vues réécrites en sous-vues plus petites, imports explicites, analyse syntaxique de toutes les sources AppModule | Type-check et compilation avec le SDK Apple |
| Expression SwiftUI trop complexe à compiler | Éditeur, canevas, panneaux, vue globale et composants de bibliothèque séparés | Compilation réelle dans Swift Playgrounds |
| Dialogue agissant sur la mauvaise cible ou perdant la cible avant confirmation | États de commandes et cibles typés ; la cible vit jusqu’à la résolution | Renommage, corbeille et suppression définitive manuels |
| Aperçu non rafraîchi, doubles sources de vérité ou réponses asynchrones réordonnées | `EditorViewModel` et service d’application centralisent les mutations ; les vues ne persistent rien directement ; files FIFO Core et interface | Changement rapide, fermeture, relance et multi-fenêtre (`IPAD-L1-131`) |
| Commande annoncée en échec après publication durable | La frontière de publication est explicite : les défauts de nettoyage post-snapshot sont récupérés de manière idempotente et ne provoquent pas une seconde action utilisateur | Injection équivalente sur le système de fichiers Apple |
| Import annulé laissant des temporaires ou terminant hors ordre | La barrière commence avant le transfert PhotosPicker ; la tâche est annulable et nettoie ses temporaires au `defer` et au lancement | Import long, fermeture de l’éditeur et relance (`IPAD-L1-107`) |
| Photo débordant de son cadre | Rendu masqué et geometry engine commun ; cadrage non destructif persistant | Cas réels rectangulaires, transparence et couverture |
| Reconnaisseurs de cadrage actifs hors mode | Sous-arbre et commandes de cadrage conditionnels ; navigation et transformation désactivées pendant le cadrage | Gestes tactiles imbriqués sur iPad |
| Navigation cassée par les gestes de cadrage | Priorités explicites, reconnaisseur deux doigts unifié qui annule les touches de navigation concurrentes, identité de page et drapeaux de balayage réinitialisés | Balayages et gestes combinés de `IPAD-L1-128` |
| Pincement qui saute ou empêche le panoramique | Zoom et translation composés depuis une origine commune autour du point médian ; calcul pur couvert par `testCanvasTwoFingerTransformComposesScaleAndTranslation` | Vérifier tactilement l’ancrage continu à 50–400 % |
| Rotation difficile ou décalée du doigt | Poignée dédiée, alternative Rotation… et calcul géométrique indépendant du rendu | Toucher, Apple Pencil, pointeur et VoiceOver |
| Poignées trompeuses sur un cadre débordant | La poignée visuelle reste sur la bordure réelle ; une cible de secours distincte, pointillée et accessible est recalée uniquement si nécessaire | Vérifier cadre débordant et tourné (`IPAD-L1-115`, `IPAD-L1-127`) |
| Complexité du mode deux pages | Anciennes vues de double page supprimées ; une seule page logique et visuelle partout | Portrait, paysage et Split View |

## Validations exécutées

| Environnement | Commande ou contrôle | Résultat connu | Portée et limite |
|---|---|---|---|
| WSL, Swift 6.3.3, 2026-08-16 | `swift test --quiet` après correction de compilation | **123 tests, 0 échec**, 8,055 s | Noyau portable ; la correction ne change pas le domaine et ne valide pas SwiftUI/iOS |
| WSL, frontend Swift, 2026-08-16 | `find Albumzh.swiftpm/Sources/AppModule -name '*.swift' -print0 \| xargs -0 swiftc -frontend -parse` | **OK** sur toutes les sources AppModule corrigées | Syntaxe seulement ; ni type-check SwiftUI, ni disponibilité SDK Apple |
| iPad 8, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-16 | Compilation des sources applicatives de `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` | **ÉCHEC** : argument `maximumPixelSize` manquant dans `AlbumCoverView` ; paramètre générique non inféré dans `AppModel` | Retour utilisateur ; aucun test fonctionnel du correctif n’est validé |
| WSL, contrats, 2026-08-16 | `perl tools/validate_contracts.pl` puis `sha256sum -c catalog-checksums-v1.sha256` dans `docs/` | **OK** : 32 modèles, 3 fonds, 6 formes, schémas/package ; **10/10 empreintes OK** | Contrats et intégrité du dépôt, pas chargement/cache sur iPad |
| Dépôt, registre et diff, 2026-08-16 | Comptage des IDs synthétiques/détaillés, doublons, références nouvelles, espaces invisibles et `git diff --check` | **OK** : 70 IDs synthétiques, 70 fiches détaillées, aucun doublon ni espace U+200B ; diff propre | Contrôle structurel ; ne transforme aucune régression iPad en réussite |
| WSL, Swift 6.3.3, 2026-08-10 | `timeout 240 /home/gmessika/.local/share/swiftly/toolchains/6.3.3/usr/bin/swift test` | **121 tests, 0 échec**, 6,696 s | Noyau `AlbumPhotoCore` uniquement ; ne valide pas SwiftUI/iOS |
| WSL | `perl tools/validate_contracts.pl` | **OK** : 32 modèles, 3 fonds, 6 formes, schémas et package exemple | Contrats statiques uniquement |
| WSL | `(cd docs && sha256sum -c catalog-checksums-v1.sha256)` | **10/10 OK** : modèles, catalogue, schéma, contrat du renderer et 6 masques | Intégrité des fichiers du dépôt, pas leur chargement Apple |
| WSL, Swift 6.3.3 | Compilation puis exécution de `tools/generate_shape_goldens.swift` dans un répertoire temporaire | **OK** : les 6 PBM régénérés sont identiques byte à byte | Reproductibilité du renderer pur, pas le rendu SwiftUI |
| WSL, frontend Swift, 2026-08-10 | `find Albumzh.swiftpm/Sources/AppModule -name '*.swift' -print0 \| xargs -0 /home/gmessika/.local/share/swiftly/toolchains/6.3.3/usr/bin/swiftc -frontend -parse` | **OK** sur toutes les sources AppModule | Analyse syntaxique seulement, sans SDK ni type-check SwiftUI |
| WSL, C | `cc -Wall -Wextra -pedantic -fsyntax-only tools/generate_photo_fixture.c tools/normalize_png_4x5.c` | **OK** | Syntaxe des générateurs seulement |
| Dépôt, registre manuel, 2026-08-10 | Contrôle de continuité, champs obligatoires, états et références normatives | **OK historique** : 46 fiches détaillées `063…108`, alors toutes ⚪, 13 validations Apple, 276 références résolues | État du registre avant la première campagne ; remplacé par le contrôle du 16 août ci-dessus |
| Dépôt, traçabilité, 2026-08-16 | Contrôle des identifiants, méthodes, classes et liens de `docs/traceability/lot0-lot1.md` | **OK structurel** : 70 contrôles iPad avec `IPAD-L1-132`, 13 Apple et 24 `ACPT` | Ne transforme aucune couverture structurelle en réussite fonctionnelle |
| Dépôt, arbitrage des lots, 2026-08-10 | Vérification de `DEC-38`, des trois lots de validation, des sorties de la section 31 et du registre manuel | **OK** : Lot 1 = six sorties photo locales ; `ACPT-123`/`130` au Lot 2 ; `ACPT-127` au Lot 3 ; 276 références manuelles résolues | Documentation uniquement ; tests Core non relancés car aucune source ni ressource n’a changé |
| Dépôt | `git diff --exit-code -- Albumzh.swiftpm/Package.swift Package.swift` | **OK** : les deux manifestes sont inchangés | Confirme la conservation de l’enveloppe, pas sa compilation Apple |
| Dépôt | `git diff --check` | **OK** après écriture du code, des contrats et du registre manuel ; à rejouer après fixation des hashes | Contrôle des espaces et marqueurs de conflit, pas une preuve fonctionnelle |

## Validations non exécutées

| Validation | État | Motif |
|---|---|---|
| Compilation du correctif minimal dans Swift Playgrounds | ⚪ Non testée | Le candidat `06c30b9…` a échoué ; `IPAD-L1-132` visera le prochain commit figé |
| Régressions manuelles du correctif | ⚪ Non testées | `IPAD-L1-102` et `IPAD-L1-109…131` seront retargetés sur le correctif de compilation |
| iPhone réel | ⚪ Non testé | Aucun appareil ni build TestFlight qualifié dans cette remise |
| Xcode/macOS et simulateurs | ⚪ Non testés | SDK Apple absent de WSL ; campagne différée selon `ENV-006` à `ENV-009` |
| VoiceOver, Dynamic Type, clavier, pointeur et Réduire les animations | ⚪ Non testés | Comportements impossibles à conclure par analyse Linux |
| Performance lancement/Fonds, 100 pages/5 Go et mémoire | ⚪ Non testée | Chronométrage iPad pour `116`, `117`, `122` et instrumentation Apple nécessaires |
| Import RAW réel | 🟠 Différé | La fixture synthétique fournie n’est pas décodable par ImageIO ; l’utilisateur refera ultérieurement un test avec un autre RAW |
| UTType/package `.photoalbum`, partage, PDF | ⚪ Non testés | Déclarations et fonctions Lot 3 non exposées dans le candidat Lot 1 |
| CloudKit | 🟠 Bloqué | Entitlements et conteneur non disponibles sous WSL |

## Risques et blocages

| ID | Niveau | Risque | Mesure actuelle / condition de levée |
|---|---|---|---|
| `RSK-3.0-001` | Élevé | Le ledger ne recense pas encore toutes les références récupérables futures (révisions, conflits, certains états différés). Une purge physique naïve pourrait supprimer trop tôt. | La purge physique reste désactivée au Lot 1 ; accepter une fuite disque temporaire plutôt qu’une perte. Compléter le ledger avant toute purge. |
| `RSK-3.0-002` | Moyen | `DAT-042` n’est couvert que partiellement : résolution et provenance complètes des placements de modèle restent à finaliser. | Ne pas exposer modèles/dé/Auto avant le Lot 2 et ajouter des golden tests de résolution. |
| `RSK-3.0-003` | Élevé | Le hachage, la déduplication et la réutilisation sont désormais en flux borné, mais ImageIO, la création du dérivé et certains chemins d’affichage chargent encore le média complet ; un RAW volumineux peut donc créer un pic mémoire. | Mesurer sur iPad et instrumenter les chemins de décodage avant de revendiquer l’enveloppe 5 Go. |
| `RSK-3.0-004` | Élevé | Risque matérialisé sur `06c30b9…` : l’analyse syntaxique Linux n’a détecté ni l’argument d’initialiseur SwiftUI manquant ni l’échec d’inférence générique vus par le compilateur Apple. | Initialiseur et types désormais explicites ; exécuter `IPAD-L1-132` avant toute régression fonctionnelle. |
| `RSK-3.0-005` | Levé | Les anciennes sorties de Lot 1 pour `ACPT-123`, `ACPT-127` et `ACPT-130` contredisaient la frontière des lots. | Arbitrage utilisateur enregistré par `DEC-38` : scénarios déplacés respectivement aux Lots 2, 3 et 2. |
| `RSK-3.0-006` | Élevé | Les conflits de gestes ne peuvent être prouvés sans tactile : déplacement, pincement, rotation, cadrage et navigation partagent le canevas. | Exécuter les tests gestuels dédiés, un par un, sur iPad. |
| `RSK-3.0-007` | Élevé | Le bootstrap catalogue et les miniatures de Fonds ont été déplacés hors du chemin bloquant et mis en cache, mais les gains sur l’iPad 8 ne sont pas mesurés ; la création sur racine neuve attend désormais seulement l’indexation prioritaire du fond par défaut si elle est déclenchée trop tôt. | Chronométrer lancement à froid/chaud, création immédiate et cinq réouvertures de Fonds avec `IPAD-L1-116` et `122`, puis Instruments. |
| `RSK-3.0-008` | Élevé | Accessibilité et adaptation iPhone/iPad ne sont pas vérifiées malgré les libellés et composants ajoutés. | Tester VoiceOver, Dynamic Type, clavier/pointeur, orientations, Split View et iPhone réel. |
| `RSK-3.0-009` | Élevé | CloudKit et le type de document package dépendent de capacités ou réglages Swift Playgrounds non prouvés. | Prototype Apple ciblé ; escalade vers Xcode/macOS si indisponible. |
| `RSK-3.0-010` | Moyen | `L10N-002` n’est pas encore satisfait : les libellés français sont présents dans les vues mais aucun catalogue `.xcstrings` n’est livré. | Conserver le candidat interne ; créer et valider le catalogue au lot Qualité avant de déclarer une fonctionnalité terminée. |
| `RSK-3.0-011` | Moyen | Le cache de couverture SwiftUI n’a pas encore de preuve instrumentée d’invalidation ni de budget mémoire sur appareil. | Exécuter le parcours couverture, puis instrumenter le cache avant de déclarer `COV-007` satisfait. |
| `RSK-3.0-012` | Moyen | Une tâche déjà en attente dans la file durable n’est pas retirée par l’annulation Swift et exécutera son tour ; c’est souhaité pour une commande durable soumise, mais ce contrat ne convient pas à une future commande explicitement annulable. | Les imports vérifient leur annulation entre fichiers et conservent les copies déjà publiées ; rendre les waiters sensibles à l’annulation avant d’étendre ce mécanisme à d’autres opérations annulables. |
| `RSK-3.0-013` | Faible | La fermeture d’une session vide l’historique sans republier immédiatement certains `referenceCount`, qui peuvent rester temporairement surévalués. | La purge physique est désactivée et la surévaluation ne peut pas perdre de données ; recomputer et persister le ledger avant toute purge future. |
| `RSK-3.0-014` | Moyen | L’URL physique d’un blob peut être obtenue sans verrou de fichier OS ; l’immuabilité dépend actuellement de tous les écrivains du dépôt respectant les acteurs. | Les chemins internes vérifient taille et empreinte avant réutilisation ; réduire l’exposition de l’URL et ajouter protection/verrouillage avant toute écriture externe ou purge. |
| `RSK-3.0-015` | Moyen | La fixture `raw.dng` synthétique (1 600 × 1 200, 16 bits RGGB) est refusée par ImageIO ; son échec ne prouve pas un défaut du pipeline RAW de l’app. | Ne modifier ni assouplir le pipeline sur cette seule preuve ; conserver `IPAD-L1-076` bloqué et refaire plus tard le test avec un RAW publiquement décodable et son hash. |

## Prochaines actions

1. Relire et commiter le correctif de compilation, puis injecter son empreinte
   exacte dans `IPAD-L1-102` et `IPAD-L1-109…132`.
2. Transférer ce commit sur l’iPad 8 et exécuter d’abord `IPAD-L1-132` ; après
   compilation réussie, exécuter
   `IPAD-L1-122` (lancement/Fonds), `123` (création/retour), `128`
   (gestes/navigation) et `129` (Sauvegarder pendant geste).
3. Exécuter ensuite `IPAD-L1-102`, resté inchangé et NON TESTÉ, puis les autres
   régressions `109…131` une fiche à la fois ; enregistrer `OK`, `BLOQUÉ` ou
   `BUG : …` sans extrapolation. Le RAW reste hors de cette campagne immédiate.
4. Après viabilité du correctif iPad, préparer les nouveaux identifiants de tests du Lot 2
   pour `ACPT-123`, `ACPT-125`, `ACPT-126`, `ACPT-128` et `ACPT-130`.
5. Organiser ensuite les campagnes iPhone, Xcode/macOS,
   accessibilité, performance et interruption transactionnelle.

## Journal des mises à jour

Le journal 3.0 repart de zéro ; l’historique détaillé du prototype 2.1 reste
dans Git à `06aaa59`. Les entrées les plus récentes doivent rester en haut.

| Date | Auteur | Changement | Fichiers et exigences | Validation |
|---|---|---|---|---|
| 2026-08-16 | Codex | Correction des deux diagnostics de compilation Apple : initialiseur explicite de fond avec taille par défaut et ensembles de catalogue typés | `AlbumPageBackground.swift`, `AppModel.swift`, `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot0-lot1.md` ; `ENV-001` à `ENV-005`, `PERF-007`, `PERF-016`, `DONE-005` | WSL : 123 tests, 0 échec ; parse AppModule OK ; type-check Apple à rejouer par `IPAD-L1-132` |
| 2026-08-16 | Codex | Gel documentaire du correctif et de sa spécification pour la seconde campagne iPad | `README.md`, `suivi_tests.md`, `SUIVI_PROJET.md`, `docs/traceability/lot0-lot1.md` ; `TST-001` à `TST-005`, `DONE-001` à `DONE-005` | Candidat exact `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` injecté dans `IPAD-L1-102` et `109…131` ; aucune preuve Apple extrapolée |
| 2026-08-16 | Codex | Analyse de la première campagne iPad et correctif regroupé : lancement/catalogue asynchrone avec priorité sûre au fond par défaut, retour post-création, dates de corbeille, déduplication, grilles et compteurs photo, modes de choix, inspecteur droit et suppression rapide, insertion de page, sélection/poignées/rotation, gestes canevas/navigation, sauvegarde en cours de geste et registre de régression ; RAW différé | `spec.md`, `suivi_tests.md`, `SUIVI_PROJET.md`, `docs/traceability/lot0-lot1.md`, `AlbumApplicationService.swift`, `GeometryEngines.swift`, `AppModel.swift`, `LibraryView.swift`, `TrashView.swift`, `MediaAssetStore.swift`, `PhotosPanelView.swift`, `AlbumEditorView.swift`, `EditorViewModel.swift`, `PageCanvasView.swift`, `GlobalPagesView.swift`, tests ; `ALB-025`, `EDT-021`, `PAG-016`, `PHO-019`, `CLP-006`, `PERF-007`, `PERF-016` et exigences reliées | Commit `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` ; WSL : 123 tests Core, 0 échec ; parse AppModule OK ; contrats OK ; 10/10 empreintes OK ; compilation/gestes/performance Apple NON TESTÉS ; `094…101`, `103…108` obsolètes, `102` NON TESTÉ, régressions `109…131` préparées |
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
