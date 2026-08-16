# Registre 3.0 des tests manuels — Lot 1

Ce registre est la campagne neuve de validation du candidat 3.0 sur iPad. La
source normative reste [`spec.md`](spec.md) et l’état général du projet reste
dans [`SUIVI_PROJET.md`](SUIVI_PROJET.md).

Les identifiants `IPAD-L1-001` à `IPAD-L1-062` appartiennent exclusivement au
prototype 2.1. Ils restent consultables dans l’historique Git au commit
`06aaa59`, ne sont pas recopiés ici et ne constituent aucune preuve du code
3.0. Aucun de ces identifiants ne doit être réutilisé.

## Candidat figé avant exécution

| Information | Valeur obligatoire |
|---|---|
| Commit d’implémentation | `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a` |
| Spécification | 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`) |
| App Playground | `Albumzh.swiftpm` |
| Build ou copie testée | `aeae5c439c461e7994117067d81a416591d348bd` ; sources applicatives identiques au commit d’implémentation figé |
| Appareil | iPad 8e génération (déclaré « iPad 8 ») |
| iPadOS | 26.5.2 |
| Swift Playgrounds | 4.7 |
| Orientation initiale | Portrait |
| Réseau initial | Connecté, sauf test hors ligne |
| Date et lieu de la campagne | 16 août 2026 — Paris, France |
| Langue et région | Français — France |

Le code d’implémentation reste figé par l’empreinte Git exacte
`314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`. La spécification 3.0 et
l’arbitrage normatif des lots sont figés par
`031d2e46c70128c7e633db1f04663949e4531309`. Si le code ou une exigence
applicable change ensuite, créer un nouvel identifiant de régression, sans
réutiliser ni modifier rétroactivement l’identité d’une preuve exécutée.

## Mode de réponse

Exécuter une fiche à la fois, puis répondre avec exactement l’une des formes
suivantes :

```text
IPAD-L1-063 OK
IPAD-L1-063 BLOQUÉ : raison
IPAD-L1-063 BUG : résultat observé, étapes et capture éventuelle
```

Codex enregistrera ensuite le résultat observé, la preuve, l’environnement et
l’effet éventuel dans `SUIVI_PROJET.md`. Un retour global ne valide jamais
implicitement plusieurs fiches.

| Repère | État enregistré | Usage |
|---|---|---|
| 🟢 | `RÉUSSI` | Toutes les étapes et attentes ont été observées sur l’environnement indiqué. |
| 🔴 | `ÉCHOUÉ` | Une étape a produit un écart reproductible. |
| 🟠 | `BLOQUÉ` | L’environnement ou une dépendance empêche de conclure. |
| ⚪ | `NON TESTÉ` | La fiche n’a pas encore été exécutée sur ce candidat. |
| ⚫ | `NON APPLICABLE` | Le contrôle ne concerne pas la configuration, avec justification écrite. |

## Périmètre et allocation normative

Cette campagne teste uniquement les fonctions publiques du Lot 1 :
bibliothèque, albums et corbeille, éditeur à une page, pages et vue globale,
fonds, couverture, photos et cadres photo, cadrage, zoom du canevas,
sauvegarde, presse-papiers de cadres photo, navigation et annulation.

Elle ne teste pas les fonctions publiques des Lots 2 et 3 : modèles, dé,
automatisme, zones de texte, stickers, formes et cadres décoratifs, lecture,
diaporama, animation de page finalisée, export/import `.photoalbum` et PDF.
Les types ou prototypes internes correspondants ne doivent pas devenir des
commandes visibles pour cette campagne, conformément à `3:ARC-014`.

`3:DEC-38` et `3:ARC-014` fixent désormais la frontière sans ambiguïté :
`3:ACPT-123` et `3:ACPT-130` sont des sorties du Lot 2, tandis que
`3:ACPT-127` est une sortie du Lot 3. Ils ne sont donc pas des critères de
réussite de cette campagne. Les exigences transversales suivantes restent
contrôlées uniquement dans leur sous-périmètre Lot 1 :

- pour `3:ALB-007`, seules Renommer, Choisir la couverture et Supprimer sont
  contrôlées ; Exporter relève du Lot 3. Pour `3:ALB-009`, seule l'action Créer
  un album est contrôlée ; Importer un package relève du Lot 3 ;
- pour `3:EDT-003`, la barre est contrôlée dans son ordre relatif après retrait
  de Mise en page auto et Exporter. Pour `3:EDT-008` et `3:EDT-020`, seule
  Ajouter une photo est publique ; Ajouter du texte relève du Lot 2. Pour
  `3:EDT-018`, aucun contrôle d'export n'est possible avant le Lot 3 ;
- pour `3:COV-002`, le Lot 1 contrôle le cadrage du contenu, le masque
  rectangulaire, la transparence et le fond révélé ; formes, contours et cadres
  décoratifs seront complétés au Lot 2. `3:COV-007` nécessite en plus une
  preuve instrumentée du cache, inscrite dans les validations différées ;
- les clauses texte de `3:BG-011` et `3:BG-016` sont différées au Lot 2. La
  présente campagne contrôle les fonds et la stabilité des éléments existants,
  mais ne crée pas de zone de texte ;
- `3:FMT-008` ne peut être validée sans PDF au Lot 3. Pour `3:QLT-006`, seul le
  caractère non bloquant pour l'édition et la sauvegarde est vérifié au Lot 1 ;
  l'avertissement et la poursuite de l'export restent différés ;
- `3:TST-010` est rejouée seulement pour ses fonctions Lot 1 : les textes,
  stickers, modèles, dé, Auto, lecture, diaporama et exports n'entrent pas dans
  cette campagne. Pour `3:TST-012`, la relance, l'annulation d'une suppression
  d'asset, la non-purge d'un blob partagé et les cas injectables localement sont
  contrôlés ; packages, export/import autonome et package dégradé relèvent du
  Lot 3, tandis que le manque d'espace ou une interruption non injectable est
  réservé à la qualification différée ;

Chaque fiche nomme explicitement le sous-périmètre transversal observé. Les
contrôles complets de `3:ACPT-123`, `3:ACPT-127` et `3:ACPT-130` recevront de
nouveaux identifiants stables dans les campagnes de leurs lots respectifs ;
aucun résultat Lot 1 ne sera extrapolé à ces scénarios.

## Corpus non personnel

Copier les quatre PNG versionnés depuis `docs/test-fixtures/photos/` vers
Fichiers sur l’iPad sans les réencoder. Vérifier leurs dimensions et leurs
empreintes avant transfert ou sur la machine source.

| Fichier | Dimensions | SHA-256 attendu | Usage |
|---|---:|---|---|
| `small-landscape-600x400.png` | 600 × 400 px | `407edaf04f5fd921e8e4bca7359d55e6d87b3f2876ebd99caead085a285a6ecc` | Taille native `1×`, fond visible |
| `medium-landscape-2400x1800.png` | 2 400 × 1 800 px | `08dff2054c238e1299214ef579407b880b3f01bf509c4b67d231555aaa6bc841` | Corpus `3:TST-011`, import et placement statiques |
| `large-portrait-4800x6000.png` | 4 800 × 6 000 px | `f3547f764f7eec40178bd1f3602863e0ed35bc6fe30777acde91b2f5d95903ca` | Borne dynamique `0,5×` en pleine page |
| `square-1200x1200.png` | 1 200 × 1 200 px | `494a22dff3b8765d5e62ffca306434e314323c97a41e5108dbbc563c3bd4b360` | Rotation, retournement et déplacement |

Compléter le corpus ci-dessous avec des médias synthétiques ou librement
redistribuables. Enregistrer le nom, les dimensions et le SHA-256 de chaque
fichier effectivement utilisé dans la preuve de `IPAD-L1-076` ou
`IPAD-L1-077`.

| Type requis | Cas attendu | Référence locale avant test |
|---|---|---|
| HEIC/HEIF statique | Accepté | À renseigner |
| JPEG statique | Accepté | À renseigner |
| PNG statique | Accepté ; les quatre fixtures ci-dessus conviennent | Voir empreintes ci-dessus |
| RAW décodable par iPadOS | Original conservé, dérivé statique affiché | Différé : `raw.dng` synthétique, modèle `OpenAI iOS Test RAW`, 1 600 × 1 200, 16 bits RGGB, 3 840 384 octets, SHA-256 `6e5b0c9a1a19c698a2f393d53ee2dd50c7abca30f5405fe730a8ebd45d6321eb`, refusé par ImageIO ; nouveau test avec un RAW décodable à fournir |
| Live Photo | Seule la composante fixe est importée | À créer dans Photos sans contenu personnel |
| HDR statique | Accepté si décodable | À renseigner |
| GIF animé | Refusé | À renseigner |
| APNG animé | Refusé | À renseigner |
| Vidéo courte | Refusée | À renseigner |
| Fichier image corrompu | Refusé sans altérer l’album | À renseigner |
| Image déclarant plus de 200 MP | Refusée avant décodage intégral | À renseigner |

## Registre synthétique

Les fiches exécutées ou rendues obsolètes parmi `IPAD-L1-063…108` ciblent le
candidat d’origine `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a` (copie iPad
`aeae5c…`). Les régressions `IPAD-L1-109…131` ciblent le correctif en cours et
restent « À figer » jusqu’à son commit exact. La fiche indépendante
`IPAD-L1-102`, jamais exécutée, conserve son ID et son état ⚪ `NON TESTÉ`, mais
sera figée sur le même correctif avant son exécution.

| ID | Objet | Exigences principales | État |
|---|---|---|---|
| `IPAD-L1-063` | Compilation et lancement sur racine 3.0 neuve | `3:LOT-001`, `3:LOC-029`, `3:LOC-031` | 🟢 `RÉUSSI` — performance de lancement à corriger séparément |
| `IPAD-L1-064` | État vide, noms, création et durabilité | `3:ALB-004`, sous-périmètre création de `3:ALB-009`, `3:ALB-011` à `3:ALB-016`, `3:ACPT-100` | 🟢 `RÉUSSI` — anomalie de retour post-création séparée |
| `IPAD-L1-065` | Grille, cartes, tri et durabilité | `3:ALB-001`, `3:ALB-002`, `3:ALB-003`, `3:APP-005` | 🟢 `RÉUSSI` |
| `IPAD-L1-066` | Renommage ciblé et Annuler/Rétablir | sous-périmètre Renommer de `3:ALB-007`, `3:ALB-021`, `3:UND-011` | 🟢 `RÉUSSI` |
| `IPAD-L1-067` | Corbeille, impossibilité d'éditer et restauration | `3:ALB-008`, `3:ALB-017`, `3:ALB-018`, `3:ALB-019`, `3:ACPT-102` | 🔴 `ÉCHOUÉ` — dates et localisation |
| `IPAD-L1-068` | Suppression définitive ciblée et blob partagé | `3:ALB-018`, `3:LOC-008`, `3:LOC-022` | 🟢 `RÉUSSI` — compteur `×2` incohérent séparé |
| `IPAD-L1-069` | Bail d’édition multi-fenêtre | `3:APP-002`, `3:APP-010`, `3:APP-011` | 🟠 `BLOQUÉ` — Swift Playgrounds sans multi-fenêtre sur cet iPad |
| `IPAD-L1-070` | Ajout, suppression et restauration d'une page remplie | `3:PAG-001`, `3:PAG-002`, `3:PAG-006`, `3:PAG-007`, `3:PAG-008`, `3:PAG-009`, `3:PAG-010` | 🟢 `RÉUSSI` |
| `IPAD-L1-071` | Déplacer la page 5, la supprimer puis annuler | `3:PAG-003`, `3:PAG-004`, `3:PAG-005`, `3:PAG-011`, `3:GLO-003`, `3:GLO-004`, `3:GLO-005`, `3:ACPT-104` | 🟢 `RÉUSSI` — indicateur d’insertion demandé |
| `IPAD-L1-072` | Une seule page et fidélité globale | `3:GLO-001` à `3:GLO-009` | 🟢 `RÉUSSI` |
| `IPAD-L1-073` | Fonds par page, portée globale et hors ligne | `3:BG-001` à `3:BG-005`, sous-périmètre Lot 1 de `3:BG-006`, `3:BG-010`, `3:BG-012`, `3:BG-013`, `3:BG-014`, `3:BG-015` | 🟢 `RÉUSSI` |
| `IPAD-L1-074` | Couverture automatique, manuelle, identité et repli | `3:COV-001`, sous-périmètre Lot 1 de `3:COV-002`, `3:COV-003`, `3:COV-004`, `3:COV-005`, `3:COV-006`, `3:DAT-005`, `3:ACPT-103` | 🟢 `RÉUSSI` |
| `IPAD-L1-075` | PhotosPicker multiple, ordre, hors ligne et annulation | `3:PHO-007`, `3:PHO-008`, `3:APL-001`, `3:APL-002`, `3:APL-003`, `3:APL-004`, `3:APL-005`, `3:APL-007`, `3:ERR-001` | 🟢 `RÉUSSI` |
| `IPAD-L1-076` | Fichiers : formats statiques acceptés | `3:FMT-001`, `3:FMT-002`, `3:FMT-003`, `3:FMT-005`, `3:FMT-007`, `3:TST-011` | 🟠 `BLOQUÉ` — fixture RAW non décodable ; grille à corriger séparément |
| `IPAD-L1-077` | Refus, échec partiel et nouvelle tentative | `3:PHO-007`, `3:PHO-008`, `3:FMT-004`, `3:FMT-006`, `3:APL-008` | 🟢 `RÉUSSI` — déduplication intra-album ajoutée séparément |
| `IPAD-L1-078` | Panneau Photos, tri, compteur et suppression | `3:PHO-001` à `3:PHO-003`, `3:PHO-009`, `3:PHO-010` | 🔴 `ÉCHOUÉ` — annonce « Utilisée 2 fois » absente |
| `IPAD-L1-079` | Réutilisation, annulation et indépendance interalbum | `3:PHO-015`, `3:PHO-016`, `3:PHO-017`, `3:PHO-018`, `3:LOC-008` | 🔴 `ÉCHOUÉ` — grille source inutilisable |
| `IPAD-L1-080` | Placement par pression et album sans photo | `3:PHO-004`, `3:PHO-005`, `3:PHO-006`, `3:PHO-011`, `3:PHO-012`, `3:PHO-013` | 🔴 `ÉCHOUÉ` — mode de choix invisible |
| `IPAD-L1-081` | Placement par glisser-déposer | `3:PHO-004`, `3:PHO-005`, `3:ACC-020` | 🟠 `BLOQUÉ` — largeur compacte et glisser inter-apps indisponibles |
| `IPAD-L1-082` | Remplacer, retirer et supprimer distinctement | `3:FRM-001` à `3:FRM-009` | 🟢 `RÉUSSI` — ergonomie de l’inspecteur à corriger |
| `IPAD-L1-083` | Dupliquer et presse-papiers compatible/incompatible | `3:ELM-009`, `3:CLP-001`, `3:CLP-002`, `3:CLP-003`, `3:CLP-004` | ⚫ `NON APPLICABLE` — étapes 8–9 contraires à la portée de session confirmée |
| `IPAD-L1-084` | Sélection, chevauchement et profondeur | `3:ELM-001`, `3:ELM-008`, `3:ELM-014` | 🔴 `ÉCHOUÉ` — choix « Photo » ambigus |
| `IPAD-L1-085` | Déplacement, huit poignées et rotation | `3:ELM-002` à `3:ELM-004`, `3:ELM-007`, `3:ELM-013` | 🟢 `RÉUSSI` — ergonomie poignées/aperçu à améliorer |
| `IPAD-L1-086` | Guides, accrochage, haptique et bornes | `3:CAN-005`, `3:CAN-006`, `3:ELM-005`, `3:ELM-006` | 🟠 `BLOQUÉ` — haptique indisponible sur l’iPad 8 |
| `IPAD-L1-087` | Petite photo 600 × 400 à `1×` | `3:DEC-07`, `3:CRP-001`, `3:CRP-004`, `3:CRP-006` | 🟢 `RÉUSSI` |
| `IPAD-L1-088` | Commande Pleine page et grande photo à `0,5×` | `3:DEC-07`, `3:CRP-001`, `3:CRP-004` | 🟢 `RÉUSSI` |
| `IPAD-L1-089` | Cadrage indépendant et original non destructif | `3:CRP-002`, `3:CRP-003`, `3:CRP-004`, `3:CRP-005`, `3:CRP-006`, `3:CRP-007`, `3:DAT-006` à `3:DAT-010` | 🟢 `RÉUSSI` |
| `IPAD-L1-090` | Paliers du zoom du canevas | `3:ZOM-001`, `3:ZOM-002`, `3:ZOM-007` | 🟢 `RÉUSSI` — page active après Rétablir à corriger séparément |
| `IPAD-L1-091` | Pincement ancré, panoramique et mémoire par page | `3:ZOM-003` à `3:ZOM-008` | 🔴 `ÉCHOUÉ` — panoramique à deux doigts inaccessible |
| `IPAD-L1-092` | Navigation et priorité des gestes | `3:NAV-001` à `3:NAV-007`, `3:ZOM-005` | 🔴 `ÉCHOUÉ` — balayage inopérant après retour page 1 |
| `IPAD-L1-093` | Sauvegarde pendant geste, arrière-plan et relance | `3:APP-005`, `3:APP-006`, `3:APP-008`, `3:APP-009`, `3:SAV-001`, `3:SAV-002`, sous-périmètre réussite de `3:SAV-003` | 🔴 `ÉCHOUÉ` — saut et double commande après Sauvegarder |
| `IPAD-L1-094` | Interruption après commande validée | `3:LOC-011` à `3:LOC-014`, `3:LOC-026` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-109` |
| `IPAD-L1-095` | Prévisualisation et rendu commun | `3:CAN-003`, `3:CAN-004`, `3:CAN-008`, `3:GLO-007`, `3:GLO-008` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-110` |
| `IPAD-L1-096` | Cadre vide et alertes de miniature | `3:FRM-001`, `3:FRM-008`, `3:GLO-006` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-111` |
| `IPAD-L1-097` | Qualité, seuils exacts et format régional | `3:QLT-001`, `3:QLT-002`, `3:QLT-003`, `3:QLT-004`, `3:QLT-005`, sous-périmètre édition/sauvegarde de `3:QLT-006`, `3:L10N-005` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-112` |
| `IPAD-L1-098` | Interface régulière/compacte, orientations et apparence | `3:EDT-002`, `3:EDT-004`, `3:EDT-005`, `3:EDT-006`, `3:EDT-011`, `3:EDT-016`, sous-périmètre photo de `3:EDT-020`, `3:ACC-021` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-113` |
| `IPAD-L1-099` | Dynamic Type, description accessible et VoiceOver | `3:ACC-001` à `3:ACC-005`, `3:ACC-007`, `3:ACC-008`, `3:ACC-011`, `3:ACC-012`, `3:ACC-017`, `3:ACC-020`, `3:EDT-010` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-114` |
| `IPAD-L1-100` | Clavier, Option + flèches et aide | `3:EDT-009`, `3:ELM-011`, `3:ELM-012`, `3:ELM-013`, `3:ACC-005`, `3:ACC-013`, `3:ACC-014`, `3:ACC-015` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-115` |
| `IPAD-L1-101` | Fonctionnement local hors ligne | `3:LOC-001`, `3:SEC-001`, `3:ERR-008` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-116` |
| `IPAD-L1-102` | Store du prototype 2.1 ignoré | `3:DEC-33`, `3:LOC-029` à `3:LOC-031` | ⚪ `NON TESTÉ` |
| `IPAD-L1-103` | Enveloppe 100 pages et 20 occurrences photo | `3:PAG-012`, sous-périmètre photo de `3:LOC-018`, `3:PERF-008`, `3:PERF-015`, `3:PERF-017` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-117` |
| `IPAD-L1-104` | Matrice commandes, icônes et états en largeurs régulière/compacte | sous-périmètre Lot 1 de `3:EDT-003`, `3:EDT-004`, `3:EDT-007`, `3:EDT-010`, `3:EDT-012`, `3:EDT-013`, `3:EDT-014`, `3:EDT-015`, `3:EDT-016`, `3:EDT-017`, `3:FRM-005`, `3:FRM-006` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-118` |
| `IPAD-L1-105` | Réduire les animations | `3:ACC-006`, sous-périmètre Lot 1 de `3:TST-010` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-119` |
| `IPAD-L1-106` | Aide contextuelle disponible hors ligne | sous-périmètre Lot 1 de `3:EDT-019`, `3:ARC-014`, `3:DEC-38` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-120` |
| `IPAD-L1-107` | Progression, annulation et nettoyage d’un import long | `3:APL-006`, `3:PERF-009`, `3:PERF-011`, `3:APP-006`, `3:SEC-008` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-121` |
| `IPAD-L1-108` | Commandes rapides sérialisées sans perte ni erreur de révision | `3:APP-002`, `3:APP-005`, `3:LOC-011` à `3:LOC-014`, `3:UND-011` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-131` |
| `IPAD-L1-109` | Interruption et sauvegarde après correctifs gestuels | `3:SAV-001`, `3:LOC-011` à `3:LOC-014`, `3:LOC-026` | ⚪ `NON TESTÉ` |
| `IPAD-L1-110` | Prévisualisation et fonds mis en cache | `3:CAN-003`, `3:CAN-004`, `3:CAN-008`, `3:PERF-016` | ⚪ `NON TESTÉ` |
| `IPAD-L1-111` | Cadre vide et mode de choix explicite | `3:FRM-001`, `3:FRM-008`, `3:PHO-011` à `3:PHO-013` | ⚪ `NON TESTÉ` |
| `IPAD-L1-112` | Qualité informative et format régional | `3:QLT-001` à `3:QLT-006`, `3:EDT-021`, `3:L10N-005` | ⚪ `NON TESTÉ` |
| `IPAD-L1-113` | Inspecteur droit et adaptation compacte | `3:EDT-002`, `3:EDT-006`, `3:EDT-021`, `3:ACC-021` | ⚪ `NON TESTÉ` |
| `IPAD-L1-114` | Dynamic Type, choix non ambigu et VoiceOver | `3:ELM-002`, `3:ELM-014`, `3:ACC-001` à `3:ACC-020` | ⚪ `NON TESTÉ` |
| `IPAD-L1-115` | Pointeur, poignées hybrides et rotation directe | `3:ELM-002`, `3:ELM-011` à `3:ELM-013`, `3:ACC-013` à `3:ACC-015` | ⚪ `NON TESTÉ` |
| `IPAD-L1-116` | Relance locale et cache des fonds hors ligne | `3:LOC-001`, `3:SEC-001`, `3:PERF-007`, `3:PERF-016` | ⚪ `NON TESTÉ` |
| `IPAD-L1-117` | Cent pages, compteurs et déplacement continu | `3:PAG-012`, `3:PHO-002`, `3:PERF-008`, `3:PERF-015`, `3:PERF-017` | ⚪ `NON TESTÉ` |
| `IPAD-L1-118` | Matrice des commandes dans le nouvel inspecteur | `3:EDT-010` à `3:EDT-017`, `3:EDT-021`, `3:FRM-005`, `3:FRM-006` | ⚪ `NON TESTÉ` |
| `IPAD-L1-119` | Réduire les animations avec inspecteur droit | `3:ACC-006`, `3:EDT-002`, sous-périmètre Lot 1 de `3:TST-010` | ⚪ `NON TESTÉ` |
| `IPAD-L1-120` | Aide contextuelle depuis le nouvel inspecteur | `3:EDT-019`, `3:EDT-021`, `3:ARC-014`, `3:DEC-38` | ⚪ `NON TESTÉ` |
| `IPAD-L1-121` | Import long, annulation et déduplication | `3:APL-006`, `3:PHO-019`, `3:PERF-009`, `3:PERF-011`, `3:SEC-008` | ⚪ `NON TESTÉ` |
| `IPAD-L1-122` | Lancement et réouverture rapide des Fonds | `3:PERF-004`, `3:PERF-007`, `3:PERF-016`, `3:BG-008` | ⚪ `NON TESTÉ` |
| `IPAD-L1-123` | Retour après création et dates de corbeille | `3:ALB-006`, `3:ALB-017` à `3:ALB-025` | ⚪ `NON TESTÉ` |
| `IPAD-L1-124` | Compteur exact et grilles photo carrées | `3:PHO-002`, `3:PHO-009`, `3:PHO-015`, `3:PHO-019` | ⚪ `NON TESTÉ` |
| `IPAD-L1-125` | Modes Ajouter, Remplir et Remplacer explicites | `3:PHO-004`, `3:PHO-011` à `3:PHO-013`, `3:FRM-004` | ⚪ `NON TESTÉ` |
| `IPAD-L1-126` | Insertion de page et activation après Rétablir | `3:PAG-004`, `3:PAG-005`, `3:PAG-010`, `3:PAG-016` | ⚪ `NON TESTÉ` |
| `IPAD-L1-127` | Sélection non ambiguë, poignées hybrides et rotation | `3:ELM-002`, `3:ELM-013`, `3:ELM-014`, `3:EDT-021` | ⚪ `NON TESTÉ` |
| `IPAD-L1-128` | Pincement, panoramique et balayage après retour | `3:ZOM-003` à `3:ZOM-006`, `3:NAV-001` à `3:NAV-007` | ⚪ `NON TESTÉ` |
| `IPAD-L1-129` | Sauvegarde au milieu d’un déplacement | `3:ELM-007`, `3:SAV-001` à `3:SAV-003`, `3:UND-007` | ⚪ `NON TESTÉ` |
| `IPAD-L1-130` | Presse-papiers strictement limité à la session | `3:CLP-001` à `3:CLP-006`, `3:UND-012` | ⚪ `NON TESTÉ` |
| `IPAD-L1-131` | Commandes rapides après correction des transitions d’interface | `3:ALB-006`, `3:APP-002`, `3:APP-005`, `3:EDT-021`, `3:LOC-011` à `3:LOC-014`, `3:UND-011` | ⚪ `NON TESTÉ` |

## Fiches détaillées

### `IPAD-L1-063` — Compilation et lancement sur racine 3.0 neuve

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:LOT-001`, `3:ENV-002`, `3:ENV-005`, `3:LOC-029`,
  `3:LOC-031`, `3:DONE-005`.
- Préconditions : transférer exactement `Albumzh.swiftpm` du candidat ; choisir
  un appareil où aucune donnée 3.0 n’est requise, ou désinstaller uniquement
  l’app de test après avoir confirmé que son bac à sable est jetable ; ne pas
  supprimer le package source dans Swift Playgrounds.
- Étapes :
  1. ouvrir `Albumzh.swiftpm` dans Swift Playgrounds ;
  2. lancer la compilation sans modifier les sources ni le manifeste généré ;
  3. démarrer l’app en plein écran ;
  4. attendre l’affichage complet de la bibliothèque ;
  5. fermer l’app depuis le sélecteur d’apps puis la relancer une fois.
- Résultat attendu : compilation et lancement sans erreur, écran racine « Mes
  albums », état vide utilisable, aucune donnée exemple ni erreur de stockage,
  et second lancement identique. Seule une racine 3.0 valide est présentée ;
  une initialisation partielle n’est jamais affichée comme réussie.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Compilation et deux lancements réussis. Anomalie hors verdict : environ 15 s avant la bibliothèque à chaque relance.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-064` — État vide, noms, création et durabilité

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ALB-004`, sous-périmètre Créer de `3:ALB-009`,
  `3:ALB-011` à `3:ALB-016`, `3:APP-005`, `3:LOC-011`, `3:LOC-012`,
  `3:LOC-013`, `3:ACPT-100`.
- Préconditions : `IPAD-L1-063` réussi ; bibliothèque vide.
- Étapes :
  1. vérifier l’état vide et l’action « Créer un album » ;
  2. ouvrir la création, saisir seulement trois espaces et vérifier que Créer
     reste désactivé ;
  3. saisir `  Guatemala  ` puis valider ;
  4. vérifier l’ouverture immédiate de l’éditeur sur sa première page vide et
     son fond Album classique à spirales ;
  5. ajouter une page, attendre l’état Enregistré, puis interrompre le processus
     depuis le sélecteur d’apps sans revenir à la bibliothèque ;
  6. relancer, ouvrir `Guatemala` et vérifier ses deux pages ainsi que leur fond
     Album classique sans message de récupération ou corruption ;
  7. revenir aux albums et créer successivement deux albums nommés exactement
     `Voyage`.
- Résultat attendu : le nom vide est refusé ; les espaces extérieurs sont
  retirés ; l’album existe durablement avant l’ouverture ; après interruption,
  `Guatemala`, ses deux pages et leurs fonds réapparaissent sans corruption ;
  deux albums homonymes sont acceptés et restent deux objets distincts.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Toutes les étapes prévues ont réussi. Après la création et l’ouverture automatique, « Retour aux albums » est resté sans effet ; le retour fonctionne après relance et ouverture manuelle.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-065` — Grille, cartes, tri et durabilité de la bibliothèque

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ALB-001` à `3:ALB-003`, `3:ALB-006`, `3:ALB-010`,
  `3:APP-001`, `3:APP-005`, `3:L10N-005`.
- Préconditions : disposer de `Guatemala` et des deux albums `Voyage` créés en
  `IPAD-L1-064` ; créer un quatrième album `Famille test`.
- Étapes :
  1. observer pour chaque carte la couverture, le nom, le nombre de pages et
     la date de modification formatée par le système ;
  2. ouvrir l’un des albums `Voyage`, ajouter une page, puis revenir ;
  3. vérifier que cet album passe en tête sans confondre l’autre homonyme ;
  4. forcer la fermeture de l’app puis la relancer ;
  5. rouvrir les trois albums, même si une miniature tarde à apparaître.
- Résultat attendu : grille adaptative, tri décroissant par modification,
  cartes homonymes distinctes, quatre albums et ordre conservés après relance ;
  une miniature absente ou en chargement ne bloque jamais l’ouverture.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-066` — Renommage ciblé et pile Annuler/Rétablir

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : sous-périmètre Renommer de `3:ALB-007`, `3:ALB-011`,
  `3:ALB-021`, `3:UND-011`. Choisir la couverture est couvert par
  `IPAD-L1-074` ; Exporter reste différé au Lot 3.
- Préconditions : deux albums homonymes `Voyage` et un album `Famille test` ;
  rester dans la bibliothèque.
- Étapes :
  1. ouvrir le menu contextuel du second `Voyage` et choisir Renommer ;
  2. saisir `Voyage B` puis confirmer ;
  3. vérifier que seul l’album ciblé a changé ;
  4. toucher Annuler et vérifier le retour à `Voyage` ;
  5. toucher Rétablir et vérifier `Voyage B` ;
  6. lancer le renommage de `Famille test`, puis annuler la feuille ;
  7. fermer et relancer l’app.
- Résultat attendu : aucune action ne touche la mauvaise carte ; Annuler et
  Rétablir agissent sur le même identifiant malgré les noms identiques ;
  annuler la feuille ne crée aucune commande ; `Voyage B` persiste après
  relance.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-067` — Corbeille, impossibilité d’éditer et restauration

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ALB-008`, `3:ALB-017`, `3:ALB-018`, `3:ALB-019`,
  `3:ACPT-102`, `3:DEC-16`, `3:DEC-25`.
- Préconditions : albums `Voyage`, `Voyage B` et `Famille test` présents ;
  `Voyage B` contient une seconde page, un fond distinct et une occurrence de
  `small-landscape-600x400.png`, afin que sa restauration soit vérifiable.
- Étapes :
  1. demander la mise en corbeille de `Voyage B` ;
  2. vérifier que la confirmation cite exactement `Voyage B`, puis Annuler ;
  3. confirmer lors d’une seconde tentative ;
  4. vérifier que `Voyage B` disparaît de la bibliothèque ;
  5. ouvrir Corbeille et vérifier le nom de l’album ainsi que sa date de
     suppression ;
  6. vérifier que la carte en corbeille ne propose ni Ouvrir ni Modifier et
     qu’une pression ne donne pas accès à l’éditeur ;
  7. restaurer `Voyage B`, fermer la corbeille et rouvrir l’album ;
  8. vérifier la seconde page, son fond et la photo, puis fermer et relancer
     l’app.
- Résultat attendu : Annuler ne modifie rien ; confirmer déplace uniquement
  la cible ; l’album en corbeille est non modifiable et absent de la liste
  active ; Restaurer rend son contenu intact et durable.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : Parcours métier réussi, mais Fonds prend environ 6 s à chaque ouverture, même après Photos dans le même album ; la corbeille affiche une échéance relative mêlant français et anglais et omet la date de mise à la corbeille.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-068` — Suppression définitive ciblée et blob partagé

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ALB-018`, `3:LOC-008`, `3:LOC-022`.
- Préconditions : créer `À supprimer A`, y importer et placer
  `small-landscape-600x400.png` ; créer `À supprimer B`, y réutiliser cette
  photo depuis A puis la placer. Les deux albums doivent donc posséder des
  assets logiques distincts résolvant le même `contentHash`. Mettre ensuite A
  et B dans la corbeille.
- Étapes :
  1. demander « Supprimer définitivement » pour `À supprimer A` ;
  2. vérifier que le dialogue cite A, puis Annuler ;
  3. vérifier que A et B sont toujours présents ;
  4. recommencer pour A et confirmer ;
  5. vérifier que B reste présent, puis le restaurer ;
  6. passer hors ligne, fermer et relancer l’app ;
  7. ouvrir B et vérifier que son occurrence affiche toujours exactement la
     fixture partagée.
- Résultat attendu : la confirmation cible l’identifiant choisi ; Annuler est
  sans effet ; confirmer retire définitivement A seulement ; B demeure intact
  après relance et sa photo reste résolue hors ligne. La suppression directe
  d’A ne purge donc pas le blob encore référencé par B. L’expiration automatique
  à trente jours de `3:ALB-020` n’est pas couverte par cette fiche.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Suppression ciblée et conservation du blob partagé réussies. Anomalie séparée : B ne contient qu’une occurrence visible mais sa miniature indique `×2`.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-069` — Bail d’édition multi-fenêtre

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:APP-002`, `3:APP-010`, `3:APP-011`, `3:DEC-29`.
- Préconditions : iPad permettant deux scènes de l’app ; album `Bail test` avec
  deux pages. Si Swift Playgrounds ne permet pas deux scènes, arrêter et
  répondre `BLOQUÉ` avec la limitation observée.
- Étapes :
  1. ouvrir `Bail test` dans une première fenêtre et laisser l’éditeur actif ;
  2. ouvrir le même album dans une seconde fenêtre ;
  3. tenter d’ajouter une page et de renommer depuis la seconde ;
  4. vérifier le message Lecture seule et l’action Réessayer ;
  5. fermer complètement la première scène ;
  6. toucher Réessayer dans la seconde, puis effectuer une modification ;
  7. terminer toutes les scènes, relancer l’app et rouvrir l’album.
- Résultat attendu : une seule scène modifie l’album ; la seconde explique la
  cause et ne propose aucune écriture effective ; Réessayer acquiert le bail
  après fermeture de la première ; le bail ne survit pas au processus et la
  modification persiste.
- Résultat : 🟠 `BLOQUÉ`.
- Preuve : Swift Playgrounds ne permet pas le multi-fenêtre sur cet iPad ; le bail concurrent ne peut pas être exercé.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-070` — Ajout, suppression et restauration d’une page remplie

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PAG-001`, `3:PAG-002`, `3:PAG-006`, `3:PAG-007`,
  `3:PAG-008`, `3:PAG-009`, `3:PAG-010`, `3:PAG-013`, `3:PAG-015`,
  `3:UND-004`.
- Préconditions : nouvel album `Pages test` sur sa seule page ; la fixture
  petite est disponible dans le panneau Photos.
- Étapes :
  1. vérifier `Page 1 sur 1` et l’indisponibilité de la suppression de la
     dernière page ;
  2. ajouter deux pages depuis la vue globale ;
  3. sur la page 2, choisir un fond distinct, ajouter un cadre rempli avec la
     fixture petite puis ajouter aussi un cadre vide reconnaissable ;
  4. demander la suppression de la page 2, puis Annuler ;
  5. recommencer et confirmer ;
  6. vérifier que la nouvelle page active est l’ancienne page 3 ;
  7. toucher Annuler et vérifier que la page 2 restaurée possède son fond, son
     cadre rempli, son placement photo et son cadre vide ;
  8. toucher Rétablir, vérifier leur disparition avec la page, puis fermer et
     relancer.
- Résultat attendu : chaque ajout est inséré après la page active avec fond
  Album classique et sans copie implicite ; la suppression exige une
  confirmation, retire tous les éléments de la page seulement, choisit la page
  suivante, reste annulable avec restauration exacte de ses deux cadres et du
  placement photo, puis rétablissable ; il reste toujours au moins une page et
  l’état final persiste.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-071` — Déplacer la page 5, la supprimer puis annuler

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PAG-003`, `3:PAG-004`, `3:PAG-005`, `3:PAG-011`,
  `3:PAG-014`, `3:GLO-003`, `3:GLO-004`, `3:GLO-005`, `3:UND-004`,
  `3:ACPT-104`.
- Préconditions : album de cinq pages portant chacune un marqueur distinct
  visible dans sa miniature, notés A, B, C, D et E dans l’ordre initial.
- Étapes :
  1. ouvrir Organiser — Vue globale et vérifier les miniatures numérotées ;
  2. glisser E, actuellement page 5, avant B pour obtenir A, E, B, C, D ;
  3. supprimer E, désormais page 2, et confirmer ;
  4. toucher Annuler une fois : E doit réapparaître en page 2 ;
  5. toucher Annuler une seconde fois : l’ordre initial A, B, C, D, E doit être
     restauré ;
  6. toucher Rétablir deux fois : le déplacement puis la suppression de E
     doivent être rejoués dans cet ordre ;
  7. toucher Annuler pour restaurer E, puis utiliser son menu contextuel et
     l’alternative « Déplacer avant B » ; vérifier le même ordre A, E, B, C, D ;
  8. toucher Annuler, vérifier l’ordre A, B, C, D, E, fermer et relancer.
- Résultat attendu : déplacement et suppression forment deux commandes
  distinctes ; deux Annuler restaurent successivement la page supprimée puis
  l’ordre initial exact ; les contenus suivent leur identité, les numéros sont
  recalculés, Rétablir rejoue les deux commandes, l’alternative contextuelle
  produit le même ordre que le glisser et l’ordre final persiste.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Réorganisation, suppression et annulation réussies ; amélioration demandée : indicateur d’insertion visible pendant le déplacement.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-072` — Une seule page active et fidélité de la vue globale

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEC-05`, `3:GLO-001` à `3:GLO-009`, `3:CAN-004`,
  `3:UND-006`.
- Préconditions : album de trois pages, chacune avec fond et photo distincts ;
  sélectionner un cadre sur la page 2.
- Étapes :
  1. vérifier qu’une seule page est visible en Vue page ;
  2. chercher dans l’interface tout réglage Une/Deux pages ;
  3. ouvrir Vue globale et comparer les trois miniatures aux pages ;
  4. essayer de déplacer ou redimensionner un cadre depuis une miniature ;
  5. toucher la miniature de page 3 ;
  6. vérifier le retour en Vue page sur page 3 seulement ;
  7. revenir en vue globale, puis en Vue page sans choisir une autre miniature.
- Résultat attendu : aucun réglage deux pages, aucune paire de pages actives ;
  les miniatures sont fidèles mais non éditables ; toucher page 3 l’active et
  le retour sans sélection conserve la dernière page active ; changer de vue
  ne crée aucune commande Annuler.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-073` — Fonds par page, portée globale, annulation et hors ligne

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:BG-001` à `3:BG-005`, sous-périmètre Lot 1 de `3:BG-006`,
  `3:BG-010`, `3:BG-012`, `3:BG-013`, `3:BG-014`, `3:BG-015`,
  `3:DAT-039`. Le fond manquant de
  `3:BG-008` est testé par `APPLE-L1-010` ; `3:BG-011` et `3:BG-016` sont
  différées avec le texte du Lot 2.
- Préconditions : album de trois pages, une photo placée sur chaque page ; les
  trois fonds intégrés doivent être visibles dans le panneau Fonds.
- Étapes :
  1. appliquer Album classique à la page 1, Carnet de voyage à la page 2 et
     Nuit minimaliste à la page 3 ;
  2. vérifier que chaque pression ne change que la page active et ne déplace
     aucune photo ;
  3. appliquer aussi « Aucun » puis une couleur unie sur une page et vérifier
     leur opacité stable en clair/sombre ;
  4. sur page 2, toucher « Appliquer à toutes les pages » ; vérifier que le
     dialogue annonce trois pages, puis Annuler ;
  5. recommencer et confirmer, puis toucher Annuler une seule fois ;
  6. vérifier le retour aux trois fonds distincts en Vue page, Vue globale et
     Prévisualiser ;
  7. fermer l’app, activer le mode Avion, relancer et vérifier les trois fonds.
- Résultat attendu : catalogue de trois motifs avec noms et miniatures fidèles,
  spirale toujours à gauche, fond propre à chaque page ; l’application globale
  est une commande unique et n’altère aucun élément ; Annuler restaure les
  trois fonds ; relance hors ligne identique. Lecture et PDF ne sont pas
  couverts ici car ils appartiennent au Lot 3.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-074` — Couverture automatique, manuelle, identité et repli

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:COV-001`, sous-périmètre Lot 1 de `3:COV-002`, `3:COV-003`,
  `3:COV-004`, `3:COV-005`, `3:COV-006`, `3:DAT-005`, `3:ALB-021`,
  `3:ACPT-103`. Le cache de `3:COV-007` est réservé à `APPLE-L1-013`.
- Préconditions : album `Couverture test` de quatre pages repérables. Les
  pages 1, 3 et 4 contiennent chacune au moins deux occurrences photo. En page
  1, deux cadres superposés rendent l’ordre de profondeur évident ; en page 4,
  une occurrence cible possède un cadrage et une rotation reconnaissables avec
  du fond visible dans son masque rectangulaire.
- Étapes :
  1. revenir à la bibliothèque et vérifier que la couverture automatique est
     l’occurrence arrière de la page 1, première selon pages puis profondeur ;
  2. dans le menu de la carte, choisir Choisir la couverture, sélectionner
     précisément l’occurrence cible de la page 4, puis terminer ;
  3. vérifier son cadrage, sa rotation et le fond de sa page révélé autour de
     la photo ; toucher Annuler puis Rétablir dans la bibliothèque ;
  4. rouvrir l’album, déplacer la page 4 en deuxième position depuis Vue
     globale, puis revenir à la bibliothèque ;
  5. vérifier que la couverture reste la même occurrence malgré son nouveau
     numéro de page ;
  6. rouvrir l’album, supprimer uniquement cette occurrence cible, puis
     revenir à la bibliothèque ;
  7. vérifier le repli sur la première occurrence disponible selon le nouvel
     ordre des pages et la profondeur ;
  8. supprimer toutes les occurrences restantes, revenir à la bibliothèque,
     puis fermer et relancer l’app.
- Résultat attendu : automatique choisit la première occurrence par ordre des
  pages puis profondeur ; le choix manuel identifie page et élément, sans
  import dédié, et suit le même `elementID` après réorganisation ; dans le
  sous-périmètre rectangulaire du Lot 1, cadrage, rotation, transparence et fond
  révélé restent fidèles ; supprimer la cible revient à la première occurrence,
  puis l’absence de toute occurrence affiche le nom sur le fond de la première
  page ; Annuler/Rétablir et chaque état durable ciblent la bonne occurrence.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-075` — PhotosPicker multiple, ordre, hors ligne et annulation

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PHO-007`, `3:PHO-008`, `3:APL-001`, `3:APL-002`,
  `3:APL-003`, `3:APL-004`, `3:APL-005`, `3:APL-007`, `3:ERR-001`.
  La progression dépassant 500 ms de `3:APL-006` est isolée dans
  `IPAD-L1-107`.
- Préconditions : ajouter dans Photos trois images non personnelles portant
  visuellement les numéros 1, 2 et 3 ; album cible sans photo.
- Étapes :
  1. ouvrir Photos > Ajouter des photos > Photothèque ;
  2. sélectionner les images dans l’ordre 3, 1, 2 et valider ;
  3. observer les états En attente, Import en cours et Disponible ;
  4. vérifier l’ordre 3, 1, 2 dans le panneau ;
  5. activer le mode Avion ; sur trois cadres vides distincts, sélectionner un
     cadre, presser la miniature correspondante, puis désélectionner avant de
     recommencer pour placer 3, 1 et 2 sans remplacement involontaire ;
  6. toucher Annuler trois fois et vérifier que les photos restent Disponibles
     dans le panneau malgré le retrait des trois placements ;
  7. fermer et relancer toujours hors ligne, replacer une miniature et vérifier
     son rendu ;
  8. réactiver le réseau, rouvrir PhotosPicker, sélectionner une quatrième
     image puis annuler le sélecteur système.
- Résultat attendu : PhotosPicker public, sélection multiple ordonnée, copie
  locale avant Disponible, miniatures orientées, images plaçables hors ligne
  et persistantes indépendamment du sélecteur ; annuler les placements ne
  supprime pas les assets importés et l’annulation finale du sélecteur ne
  modifie ni photothèque interne ni page.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-076` — Import Fichiers et placements statiques distincts

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:APL-001`, `3:APL-002`, `3:APL-004`, `3:APL-005`,
  `3:APL-007`, `3:FMT-001`, `3:FMT-002`, `3:FMT-003`, `3:FMT-005`,
  `3:FMT-007`, `3:DAT-043`, `3:TST-011`. `3:FMT-008` est différée au PDF
  du Lot 3.
- Préconditions : corpus accepté HEIC, JPEG, PNG, RAW, Live Photo fixe et HDR
  décrit plus haut ; noter dimensions et SHA-256 de chaque fichier. Pour Live
  Photo, utiliser la source Photothèque si Fichiers ne préserve pas le couple.
- Étapes :
  1. choisir Photos > Ajouter des photos > Fichiers ;
  2. sélectionner ensemble HEIC, JPEG, les quatre PNG versionnés et HDR ;
  3. vérifier que chaque entrée devient Disponible avec miniature correctement
     orientée et couleurs plausibles ;
  4. importer le RAW décodable et vérifier son affichage statique ;
  5. importer la Live Photo depuis PhotosPicker ;
  6. pour chaque format, toucher une zone vide afin de désélectionner le cadre
     précédent, puis presser sa miniature pour créer un nouveau cadre ; ne
     jamais laisser un cadre rempli sélectionné entre deux formats ;
  7. vérifier notamment le placement de
     `medium-landscape-2400x1800.png`, fermer et relancer hors ligne ;
  8. vérifier que chaque cadre distinct conserve son format, que la Live Photo
     n’est jamais animée et que le RAW reste rendu.
- Résultat attendu : tous les contenus statiques décodables sont acceptés sans
  plafond arbitraire ; original RAW conservé avec dérivé d’affichage ; seule la
  composante fixe de la Live Photo est copiée ; orientation/profil appliqués au
  rendu sans réécriture visible de l’original ; toutes les occurrences
  persistent hors ligne.
- Résultat : 🟠 `BLOQUÉ`.
- Preuve : Les formats statiques testés hors RAW ont réussi. `raw.dng` est refusé avec « dimensions invalides » et n’est pas établi décodable par ImageIO ; la vérification RAW est différée. Anomalie séparée : les miniatures sont tronquées lorsque la grille atteint quatre colonnes.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-077` — Refus, échec partiel et nouvelle tentative sûre

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PHO-007`, `3:PHO-008`, `3:APL-008`, `3:FMT-004`,
  `3:FMT-006`, `3:ERR-002` à `3:ERR-004`, `3:ERR-021`, `3:TST-011`.
- Préconditions : album contenant déjà un cadre rempli ; corpus JPEG valide,
  GIF, APNG, vidéo, fichier corrompu et fichier de test dont l’en-tête déclare
  plus de 200 MP sans contenir un bitmap géant. Noter nom, taille et SHA-256 de
  chaque entrée ; les fichiers interdits ou invalides restent volontairement
  invalides pendant toute la fiche.
- Étapes :
  1. lancer un import Fichiers multiple contenant le JPEG valide et autant de
     fichiers interdits que le sélecteur autorise à choisir ;
  2. noter les fichiers filtrés avant sélection et ceux refusés après
     sélection ;
  3. vérifier que le JPEG reste Disponible malgré les autres échecs ;
  4. vérifier chaque état détaillé : Format non pris en charge ou Fichier
     inaccessible, avec explication actionnable ;
  5. vérifier que le cadre déjà rempli n’a pas été remplacé ;
  6. noter le nombre et la position du JPEG Disponible, puis toucher
     « Réessayer » sans modifier les fichiers invalides ;
  7. vérifier que seuls les échecs repassent par En attente/Import en cours et
     que le JPEG réussi n’est ni relu ni dupliqué ;
  8. toucher Ignorer pour les erreurs persistantes, puis fermer et relancer
     l’album.
- Résultat attendu : GIF/APNG/vidéo refusés comme contenus non statiques,
  fichier corrompu refusé, > 200 MP refusée avant décodage intégral ; succès
  partiel conservé à sa position, aucun contenu existant remplacé, Réessayer ne
  relance que les erreurs et ne duplique aucun succès, Ignorer conserve le JPEG
  réussi et la relance reste cohérente.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Refus, succès partiel et reprise ont fonctionné. Écart produit séparé : réimporter exactement le JPEG déjà présent crée immédiatement une seconde miniature `×0` au lieu de réutiliser l’asset existant.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-078` — Panneau Photos, tri, compteur et suppression logique

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEC-34`, `3:PHO-001` à `3:PHO-003`, `3:PHO-009`,
  `3:PHO-010`, `3:UND-004`, `3:UND-010`.
- Préconditions : album avec au moins trois photos ayant noms, dates de prise
  et dates d’import différents ; une photo placée deux fois, une placée une
  fois et une inutilisée.
- Étapes :
  1. vérifier les compteurs `×2`, `×1`, `×0` ;
  2. trier successivement par date de prise de vue, nom et date d’import, en
     ordre croissant puis décroissant ;
  3. activer « Masquer les photos utilisées », puis les réafficher ;
  4. ouvrir le menu de la photo `×2` et vérifier « Supprimer de cet album »
     désactivé avec l’annonce « Utilisée 2 fois » ;
  5. retirer les deux occurrences sans supprimer l’original ;
  6. demander la suppression à `×0`, Annuler la confirmation, puis confirmer ;
  7. toucher Annuler et vérifier la restauration à son indice d’origine ;
  8. toucher Rétablir, fermer et relancer.
- Résultat attendu : tri stable, masquage exact, compteur actualisé ; aucune
  suppression tant qu’une occurrence existe ; retrait d’occurrence conserve
  l’original ; confirmation identifie la photo ; suppression logique n’affecte
  ni Fichiers ni Photos ; Annuler restaure métadonnées et position, Rétablir
  retire de nouveau, état final durable.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : Les étapes non signalées ont réussi, mais le menu de la photo `×2` n’affiche pas l’annonce « Utilisée 2 fois ».
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-079` — Réutilisation, annulation et indépendance interalbum

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEC-37`, `3:PHO-015`, `3:PHO-016`, `3:PHO-017`,
  `3:PHO-018`, `3:LOC-007`, `3:LOC-008`, `3:LOC-015`, `3:LOC-016`,
  `3:UND-004`.
- Préconditions : trois albums sources actifs, dont `Source récente`,
  `Alpha source` et `Zulu source`, avec dates de modification identifiables ;
  Alpha et Zulu sont préparés avec la même date affichée afin d’observer le
  départage par nom. `Source récente` contient les fixtures petite et carrée
  dans cet ordre, dont une non placée. L’album cible `Cible reuse` ne contient
  aucune de ces photos.
- Étapes :
  1. dans la cible, ouvrir Ajouter des photos > Depuis vos autres albums ;
  2. vérifier que la corbeille et l’album courant sont absents ; contrôler
     l’ordre par date de modification décroissante puis, pour Alpha et Zulu à
     date affichée égale, par nom localisé croissant ;
  3. ouvrir `Source récente`, vérifier que la photo non placée est incluse,
     sélectionner dans l’ordre la carrée puis la petite et
     valider « Ajouter 2 photos » ;
  4. vérifier qu’elles apparaissent dans la cible sans être placées ;
  5. immédiatement, avant tout placement ou autre commande, toucher Annuler et
     vérifier que les deux ajouts disparaissent de la cible sans modifier la
     source ; toucher Rétablir et vérifier leur retour dans l’ordre ;
  6. rouvrir la source de réutilisation et vérifier l’état « Déjà ajoutée » et
     la désactivation des deux photos ;
  7. placer la petite dans la cible, fermer et relancer hors ligne ;
  8. mettre `Source récente` en corbeille puis la supprimer définitivement ;
  9. rouvrir la cible et vérifier le rendu hors ligne des deux photos.
- Résultat attendu : sélection multiple et ordre conservés, nouveaux assets
  logiques autonomes dans la cible, mêmes octets/empreintes sans nouvelle copie
  binaire observable, aucune modification de la source, photos non placées
  arbitrairement, détection des doublons, commande d’ajout annulable/rétablissable
  en une fois et cible intacte après suppression de la source et relance. Le
  dernier départage par octets UUID de `3:PHO-015`, invisible entre cartes
  distinctes, reste couvert par les tests Core.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : À l’étape 3, les photos de l’album source sont énormes, très zoomées ou superposées ; sélection et poursuite impossibles.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-080` — Placement par pression et album sans photo

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PHO-004`, `3:PHO-005`, `3:PHO-006`, `3:PHO-011`,
  `3:PHO-012`, `3:PHO-013`, `3:FRM-004`, `3:FRM-009`.
- Préconditions : deux albums neufs et sans photo : `Choix cadre`, dont la page
  contient un cadre vide, et `Choix page`, composé de deux pages vides. Les
  fixtures petite, carrée et moyenne sont disponibles dans Fichiers mais pas
  encore dans les panneaux Photos de ces albums.
- Étapes :
  1. dans `Choix cadre`, sélectionner le cadre vide et toucher Ajouter une
     photo ; vérifier que le mode de choix propose le sélecteur système ;
  2. importer en une fois petite et carrée ; vérifier que les deux miniatures
     sont ajoutées au panneau, qu’aucune n’est placée arbitrairement et que le
     mode cible toujours le même cadre ;
  3. presser la petite et vérifier que ce cadre précis est rempli sans second
     cadre ; relever sa géométrie, puis presser la carrée et vérifier que seule
     sa photo est remplacée avec géométrie inchangée ;
  4. ouvrir `Choix page`, toucher l’action locale Ajouter une photo et vérifier
     que le sélecteur système est proposé faute de photo disponible ;
  5. importer carrée et moyenne ; vérifier leur ajout sans placement
     arbitraire, puis presser la moyenne ;
  6. vérifier la création d’un cadre au centre et au premier plan dans une boîte
     maximale `0,45 × 0,45`, centré à `1×` sans rotation ni retournement ;
  7. toucher de nouveau Ajouter une photo, puis utiliser explicitement Annuler
     dans le mode de choix ; vérifier qu’aucun cadre n’est créé ;
  8. rouvrir ce mode, fermer le panneau Photos sans choisir ; vérifier qu’aucun
     cadre n’est créé ;
  9. rouvrir ce mode une troisième fois, passer à la page 2 avant de choisir ;
     vérifier qu’aucun cadre n’est créé sur aucune page ;
  10. sur la page 2 sans sélection, ouvrir normalement Photos et presser la
      miniature carrée ; vérifier la création d’un nouveau cadre centré.
- Résultat attendu : pression sans cadre crée un cadre libre dans une boîte
  maximale 0,45 × 0,45 conservant le rapport ; pression avec cadre vide le
  remplit après retour du sélecteur ; l’import multiple alimente le panneau sans
  placement arbitraire ; pression avec cadre rempli remplace uniquement le
  contenu ; chaque nouveau placement est centré à `1×`, sans rotation ni
  retournement ; Annuler, fermer le choix ou changer de page ne crée rien.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : Étapes 1 à 3 réussies. À partir de l’étape 4, l’action locale « Ajouter une photo » ne produit aucun retour visible, contrairement à « Ajouter des photos » du panneau.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-081` — Placement par glisser-déposer sur iPad

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PHO-004`, `3:PHO-005`, `3:PHO-006`, `3:ACC-020`.
- Préconditions : iPad, panneau Photos ouvert, une page contenant un cadre
  vide, un cadre rempli et une grande zone libre ; trois photos disponibles.
- Étapes :
  1. glisser une miniature sur le cadre vide ;
  2. glisser une autre miniature sur le cadre rempli ;
  3. glisser la troisième sur une position précise de la zone vide ;
  4. vérifier sélection et contenu après chaque dépôt ;
  5. annuler successivement les trois commandes ;
  6. réduire la fenêtre de l’iPad jusqu’à la largeur compacte, ouvrir le
     panneau Photos intégré sous le canevas et répéter un dépôt vers le cadre
     vide puis vers la page sans fermer le panneau ;
  7. reproduire les trois effets par pression/menu, sans glisser-déposer.
- Résultat attendu : le cadre vide est rempli, le cadre rempli conserve sa
  géométrie et remplace seulement sa photo, la page crée un cadre centré sur le
  dépôt et au premier plan ; les trois opérations sont annulables séparément ;
  en largeur compacte iPad, source et cible restent dans la même fenêtre et le
  panneau ne masque pas le canevas ; l’alternative sans glisser produit les
  mêmes états métier.
- Résultat : 🟠 `BLOQUÉ`.
- Preuve : Étapes 1 à 5 réussies. Étapes 6 et 7 non conclues : aucune présentation multi-fenêtre Swift Playgrounds ni glisser-déposer entre applications sur cet iPad ; la fiche mélangeait cette limite avec l’alternative par pression.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-082` — Remplacer, retirer et supprimer : trois opérations distinctes

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:FRM-001` à `3:FRM-009`, `3:ELM-010`, `3:UND-004`.
- Préconditions : cadre rempli par la fixture carrée, déplacé, redimensionné et
  cadré de façon reconnaissable ; seconde photo disponible.
- Étapes :
  1. sélectionner le cadre et relever sa géométrie visuelle ;
  2. choisir Remplacer et affecter la seconde photo ;
  3. vérifier géométrie/style conservés mais contenu réinitialisé centré à
     `1×`, sans rotation ni retournement ;
  4. choisir « Retirer la photo » ;
  5. vérifier la trame neutre, l’icône `+` et « Ajouter une photo » dans le
     même cadre ;
  6. toucher Annuler puis Rétablir ;
  7. choisir Supprimer sur le cadre vide ;
  8. vérifier l’absence de confirmation, puis Annuler la suppression ;
  9. fermer et relancer.
- Résultat attendu : Remplacer ne transforme pas le cadre ; Retirer conserve
  cadre/styles et original dans Photos ; Supprimer retire le cadre et son
  contenu sans confirmation ; chaque action est distincte, annulable et
  durable ; l’aide du cadre vide n’est qu’une aide d’édition.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Les effets métier Remplacer, Retirer et Supprimer ont réussi. Le bouton Remplacer n’annonce aucun mode ; un badge vert `OK` ressemble à un bouton inactif et les commandes horizontales sont difficiles à parcourir.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-083` — Dupliquer et presse-papiers compatible/incompatible

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ELM-009`, `3:FRM-007`, `3:CLP-001`, `3:CLP-002`,
  `3:CLP-003`, `3:CLP-004`, `3:UND-001` à `3:UND-007`.
- Préconditions : album source de deux pages ; page 1 avec trois cadres
  superposés et celui du milieu sélectionné, page 2 avec un cadre existant.
  Une quatrième photo, utilisée par une seule occurrence distincte, servira au
  test de restauration d’asset. Un second album actif est disponible.
- Étapes :
  1. avant toute copie, désélectionner puis vérifier que Coller est désactivé ;
  2. resélectionner le cadre du milieu, choisir Dupliquer et vérifier une copie
     sélectionnée décalée de 12 points
     vers le bas/droite, juste au-dessus de l’original ;
  3. modifier le cadrage de la copie et vérifier que l’original ne change pas ;
     Annuler puis Rétablir la duplication ;
  4. Copier la copie, passer page 2, Coller et vérifier un nouvel élément
     sélectionné au premier plan avec un cadrage indépendant ;
  5. revenir page 1, sélectionner l’original et Couper ; vérifier sa disparition
     sans confirmation, puis Annuler et Rétablir ;
  6. sélectionner l’occurrence de la quatrième photo, la Copier, supprimer
     cette unique occurrence, puis supprimer de l’album son asset désormais à
     `×0` ;
  7. toucher Coller sans effectuer une nouvelle copie et vérifier que la même
     commande restaure l’asset à la fin du panneau puis crée une occurrence au
     nouvel identifiant ;
  8. Copier l’occurrence restaurée, revenir à la bibliothèque, ouvrir le second
     album et vérifier que Coller y est désactivé comme contenu incompatible ;
  9. rouvrir l’album source, vérifier que Coller y est de nouveau activé, le
     déclencher, puis fermer et relancer.
- Résultat attendu : chaque collage/duplication possède un nouvel identifiant
  observable par indépendance des modifications ; même page = juste au-dessus,
  autre page = premier plan ; décalage réduit seulement si nécessaire pour
  garder le centre sélectionnable ; Couper est atomique et annulable ; Coller
  restaure atomiquement les métadonnées de l’asset retiré ; le collage sans
  contenu et le payload photo dans un autre album restent désactivés ; état
  final durable. Texte et sticker ne sont pas testés, car ils relèvent du Lot 2.
- Résultat : ⚫ `NON APPLICABLE`.
- Preuve : Étapes 1 à 7 compatibles avec la session réussies. Les étapes 8–9 exigeaient à tort une réactivation après fermeture ; l’utilisateur confirme que le presse-papiers doit rester limité à la session et à l’album.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-084` — Sélection, chevauchement et profondeur des cadres

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:CAN-002`, `3:CAN-003`, `3:ELM-001`, `3:ELM-008`,
  `3:ELM-014`, `3:EDT-017`.
- Préconditions : trois cadres photo qui se chevauchent fortement ; petite
  photo à `1×` dans l’un pour laisser une partie transparente du masque.
- Étapes :
  1. toucher une zone couverte par les trois cadres ;
  2. vérifier que le cadre de premier plan est sélectionné ;
  3. toucher une partie du masque non couverte par les pixels de la petite
     photo ;
  4. utiliser « Sélectionner un élément » sur le point de chevauchement et
     choisir le cadre arrière ;
  5. vérifier que le choix n’a pas changé la profondeur ;
  6. exercer Avancer, Premier plan, Reculer et Arrière-plan ;
  7. vérifier qu’à chaque extrémité seules les directions impossibles sont
     désactivées ;
  8. toucher une zone vide de la page.
- Résultat attendu : un seul cadre sélectionné ; tout le masque participe au
  hit-testing ; sélecteur ordonné du premier plan vers l’arrière et descriptions
  non ambiguës ; profondeur modifiée uniquement sur commande ; zone vide
  désélectionne ; les cadres partagent une pile unique.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : À l’étape 4, le sélecteur propose trois choix identiques « Photo », rendant le cadre arrière impossible à identifier. Les autres étapes ont réussi ; l’inspecteur contextuel horizontal est jugé difficile d’accès.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-085` — Déplacement, huit poignées, rotation et gestes à deux doigts

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ELM-002` à `3:ELM-004`, `3:ELM-007`, `3:ELM-012`,
  `3:ELM-013`, `3:ACC-005`, `3:ACC-013`.
- Préconditions : un cadre photo sélectionné, sans mode cadrage.
- Étapes :
  1. compter quatre poignées d’angle, quatre latérales et une poignée de
     rotation extérieure ;
  2. glisser l’intérieur pour déplacer le cadre ;
  3. utiliser chaque poignée latérale puis chaque poignée d’angle et vérifier
     la possibilité de changer le rapport ;
  4. tourner avec la poignée extérieure et vérifier qu’elle suit le doigt sans
     saut ni décalage ;
  5. appliquer simultanément pincement et rotation à deux doigts sur le cadre ;
  6. annuler une fois chaque geste continu et vérifier qu’il revient d’un seul
     coup ;
  7. ouvrir Position et taille > Rotation…, tester `−90°`, `+90°`, une valeur
     de `179°`, puis Réinitialiser `0°` et valider ;
  8. utiliser les alternatives de déplacement et Agrandir/Réduire du menu.
- Résultat attendu : toutes les poignées sont opérantes ; cadre redimensionnable
  librement ; transformation deux doigts agit sur le cadre, pas sur la photo
  interne ni le canevas ; chaque geste continu produit une seule commande ;
  Rotation… est bornée dans `[-180, 180)`, au pas de 1°, distincte des quarts
  de tour du contenu ; toutes les actions ont une alternative accessible.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Toutes les transformations prévues ont réussi. Améliorations demandées : poignées visuelles sur les bordures réelles lorsque visibles et aperçu immédiat de Rotation…, avec Annuler restaurant l’angle initial.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-086` — Guides, accrochage, haptique et bornes géométriques

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:CAN-005`, `3:CAN-006`, `3:ELM-005` à `3:ELM-007`,
  `3:PERF-017`.
- Préconditions : deux cadres de tailles différentes ; retour haptique activé
  dans les réglages iPad.
- Étapes :
  1. déplacer lentement un cadre vers les bords et centres de la page ;
  2. observer les guides et sentir le retour à l’entrée dans le seuil ;
  3. rester dans le même seuil puis en sortir et y revenir ;
  4. aligner le cadre avec les bords et centres du second cadre ;
  5. vérifier l’absence totale de guide de marge de sécurité ;
  6. tenter de réduire sous 5 % de la largeur/hauteur de page ;
  7. déplacer le cadre hors page jusqu’à la limite autorisée ;
  8. relâcher, toucher Annuler une fois et vérifier le retour avant le geste.
- Résultat attendu : accrochage à six points écran ou moins, guide clair et un
  seul haptique léger par entrée dans un guide ; nouvel haptique seulement
  après sortie/rentrée ; aucun guide de sécurité ; taille minimale respectée ;
  le centre reste dans la page même si le cadre déborde et le débordement est
  rogné ; une seule commande est persistée au relâchement.
- Résultat : 🟠 `BLOQUÉ`.
- Preuve : Les contrôles autres que l’haptique ont réussi ; aucun retour haptique n’est disponible sur l’iPad 8, donc la fiche complète ne peut pas conclure.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-087` — Petite photo 600 × 400 centrée à `1×`

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEC-07`, section 3.1, `3:CAN-009`, `3:CRP-001`,
  `3:CRP-004`, `3:CRP-006`, `3:FRM-009`, `3:ACPT-124`.
- Préconditions : importer exactement
  `small-landscape-600x400.png`, SHA-256
  `407edaf04f5fd921e8e4bca7359d55e6d87b3f2876ebd99caead085a285a6ecc` ;
  page sur fond Carnet de voyage ; créer un cadre nettement plus grand que
  600 × 400 unités canoniques.
- Étapes :
  1. remplir le cadre avec la petite photo ;
  2. ouvrir Recadrer et lire la valeur initiale `1,00×` ;
  3. vérifier que la photo est centrée, non agrandie, et que le fond reste
     visible tout autour dans le masque ;
  4. tenter de descendre sous `1×` avec le curseur et par pincement ;
  5. déplacer la photo puis choisir Réinitialiser ;
  6. choisir Terminé, fermer et relancer ;
  7. comparer Vue page, Vue globale, Prévisualiser et couverture si cette
     occurrence est choisie.
- Résultat attendu : à `1×`, 600 pixels correspondent à 600 unités de largeur
  et 400 à 400 unités de hauteur, centrées ; aucune couverture automatique du
  cadre ; borne basse `1×` puisque la photo tient déjà ; fond visible normal,
  sans alerte de cadre vide ; Réinitialiser et relance gardent `1×` centré ;
  rendu utile cohérent dans toutes les sorties Lot 1.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-088` — Commande Pleine page et borne dynamique `0,5×`

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEC-07`, section 3.1, `3:CAN-009`, `3:CRP-001`,
  `3:CRP-004`, `3:CRP-006`, `3:DAT-006`, `3:ACPT-124`.
- Préconditions : importer exactement
  `large-portrait-4800x6000.png`, SHA-256
  `f3547f764f7eec40178bd1f3602863e0ed35bc6fe30777acde91b2f5d95903ca` ;
  la page ne contient initialement aucun cadre.
- Étapes :
  1. presser la miniature sans sélection pour créer un cadre libre, puis
     sélectionner Position et taille > Pleine page ;
  2. vérifier que la commande fixe exactement le cadre rectangulaire aux limites
     du canevas 4:5 canonique, centré et sans rotation ; vérifier que les huit
     poignées et la commande de rotation restent entièrement visibles et
     activables, la rotation étant rentrée dans la page faute d’espace extérieur ;
  3. ouvrir Recadrer et vérifier la valeur initiale `1,00×`, avec une photo deux
     fois plus large et
     haute que la page canonique ;
  4. descendre progressivement le contrôle accessible jusqu’à sa borne basse ;
  5. vérifier qu’elle vaut exactement `0,50×` à la précision affichée ;
  6. à `0,50×`, vérifier la visibilité exacte de l’image entière dans le cadre
     2 400 × 3 000 ;
  7. tenter de descendre sous `0,50×` avec le contrôle et par pincement ;
  8. valider, fermer, relancer et rouvrir Recadrer.
- Résultat attendu : minimum calculé par
  `min(2400/4800, 3000/6000) = 0,5`, sans constante fixe ; curseur et pincement
  refusent une valeur inférieure ; `0,50×` persiste exactement et ne se
  confond jamais avec le zoom du canevas. Les contrôles du cadre pleine page ne
  sont ni rognés ni placés hors de la zone tactile visible.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-089` — Cadrage indépendant et original non destructif

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:CRP-002` à `3:CRP-007`, `3:DAT-006` à `3:DAT-010`,
  `3:EDT-015`, `3:UND-004`.
- Préconditions : deux occurrences distinctes du même asset
  `square-1200x1200.png`, SHA-256
  `494a22dff3b8765d5e62ffca306434e314323c97a41e5108dbbc563c3bd4b360`,
  possèdent au départ le même cadrage. Conserver le fichier fixture dans
  Fichiers comme référence de provenance.
- Étapes :
  1. ouvrir le cadrage par double toucher, puis annuler et le rouvrir par
     Recadrer ;
  2. vérifier cadre fixe, extérieur du masque assombri, panneaux/navigation et
     zoom du canevas désactivés ;
  3. sur la première occurrence seulement, glisser la photo, la pincer, pivoter
     à gauche puis à droite et la retourner horizontalement ;
  4. vérifier que la photo ne peut devenir entièrement introuvable et que la
     seconde occurrence reste visuellement identique à son état initial ;
  5. toucher Annuler dans le mode cadrage et vérifier l’état d’entrée exact des
     deux occurrences ;
  6. recommencer sur la première, toucher Réinitialiser et vérifier `1×`,
     centrage, orientation d’origine et absence de retournement ;
  7. créer un troisième état et toucher Terminé ;
  8. vérifier encore la seconde occurrence, puis toucher Annuler une seule fois
     et Rétablir ;
  9. redimensionner le premier cadre et vérifier que zoom, point focal, quarts de tour
     et retournement restent exactement inchangés ;
  10. fermer et relancer ; vérifier les deux cadrages indépendants et comparer
      visuellement leur contenu à la fixture de référence dans Fichiers.
- Résultat attendu : gestes modifient uniquement le contenu, jamais le cadre ni
  l’original ; Annuler restaure l’entrée ; Réinitialiser impose `1×` centré ;
  Terminé crée une seule commande ; redimensionner ne recadre pas
  automatiquement ; placement persistant absolu et seconde occurrence non
  modifiée. La comparaison Fichiers prouve l’absence de modification de la
  source externe ; l’immutabilité des octets stockés et leur hash avant/après
  restent prouvés par les tests Core, pas par cette observation UI.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-090` — Paliers et commandes du zoom du canevas

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ZOM-001`, `3:ZOM-002`, `3:ZOM-007`, `3:EDT-010`.
- Préconditions : page avec un cadre sélectionné ; sortir du mode cadrage.
- Étapes :
  1. toucher Ajuster et vérifier `100 %`, page entière centrée en aspect-fit ;
  2. toucher Zoom avant jusqu’à parcourir `125`, `150`, `200`, `300`, `400 %` ;
  3. vérifier Zoom avant désactivé à `400 %` ;
  4. toucher Zoom arrière jusqu’à `300`, `200`, `150`, `125`, `100`, `75`,
     `50 %` ;
  5. vérifier Zoom arrière désactivé à `50 %` ;
  6. revenir à une valeur intermédiaire par pincement, puis vérifier que les
     boutons choisissent les paliers strictement inférieur/supérieur ;
  7. vérifier qu’Annuler/Rétablir et la date de modification ne changent pas à
     cause de ces commandes.
- Résultat attendu : plage 50–400 %, paliers et états désactivés exacts ;
  Ajuster revient à 100 % centré ; contours et page changent seulement comme
  fenêtre visuelle ; aucune mutation métier ni commande d’annulation.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Paliers et commandes de zoom réussis. Anomalie séparée : après Annuler puis Rétablir une suppression de page, la page recréée ne devient pas active.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-091` — Pincement ancré, déplacement de fenêtre et mémoire par page

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ZOM-003` à `3:ZOM-008`, `3:GLO-008`.
- Préconditions : album de deux pages avec détails placés dans des coins
  distincts ; aucun élément sélectionné au début.
- Étapes :
  1. pincer sur une zone vide autour d’un détail proche du coin supérieur
     droit et vérifier que ce point reste sous le milieu du pincement ;
  2. relâcher à une valeur intermédiaire, par exemple environ 163 %, et vérifier
     l’absence d’arrondi ;
  3. déplacer la fenêtre à deux doigts ; vérifier que la page ne peut pas être
     entièrement perdue et reste centrée sur un axe où elle tient ;
  4. sélectionner un cadre et vérifier que poignées/cibles gardent une taille
     écran constante pendant le zoom ;
  5. régler page 1 à un zoom/centre A, page 2 à un zoom/centre B ;
  6. passer par Vue globale puis Prévisualiser et revenir à chaque page ;
  7. fermer complètement l’app puis relancer.
- Résultat attendu : zoom continu ancré au point médian, panoramique borné à
  deux doigts, aides constantes en points écran ; A et B restaurés pendant la
  scène malgré les changements de vue ; après relance, chaque page revient à
  `100 %` centrée et le document est inchangé.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : Le pincement fonctionne, mais le déplacement à deux doigts est interprété comme un pincement et ne permet pas de déplacer la fenêtre.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-092` — Navigation par boutons/balayage et priorité des gestes

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:NAV-001` à `3:NAV-007`, `3:ZOM-005`, `3:PAG-013`,
  `3:UND-005`.
- Préconditions : album de trois pages reconnaissables ; page 2 contient un
  cadre rempli ; zoom canevas supérieur à 100 %.
- Étapes :
  1. vérifier Précédent désactivé page 1 et Suivant désactivé page 3 ;
  2. parcourir 1→2→3→2 avec les boutons et vérifier `Page N sur 3` ;
  3. depuis une zone vide, balayer à gauche pour Suivant et à droite pour
     Précédent ;
  4. tenter un geste plutôt vertical et un geste diagonal ne dépassant pas le
     ratio horizontal 1,25 ;
  5. déplacer puis transformer le cadre : aucun de ces gestes ne change de
     page ;
  6. en mode cadrage, glisser/pincer la photo : aucune navigation ;
  7. sur zone vide, pincer puis déplacer à deux doigts : seule la fenêtre
     change ;
  8. interagir avec le panneau Photos puis effectuer un balayage depuis ce
     panneau ;
  9. atteindre une borne par balayage et vérifier l’absence de changement ;
  10. vérifier que la navigation n’a ajouté aucune entrée Annuler.
- Résultat attendu : boutons et balayages ciblent les mêmes pages ; gauche =
  Suivant, droite = Précédent ; reconnaissance horizontale seulement au ratio
  > 1,25 ; priorité déterministe contenu > élément > fenêtre > navigation ;
  panneau et bornes ne naviguent pas ; jamais deux pages actives.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : Après navigation puis retour à la page 1, le balayage horizontal sur zone vide ne fonctionne plus ; les autres contrôles non signalés ont réussi.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-093` — Sauvegarde pendant geste, arrière-plan et relance

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:APP-005`, `3:APP-006`, `3:APP-008`, `3:APP-009`,
  `3:SAV-001`, `3:SAV-002`, sous-périmètre réussite de `3:SAV-003`,
  `3:LOC-011`, `3:LOC-026`, `3:UND-012`. `3:APP-007` est exclue car elle
  cible la version 1.1 ; l’échec de sauvegarde est testé par `APPLE-L1-011`.
- Préconditions : album à deux pages avec au moins une photo ; noter l’état
  initial.
- Étapes :
  1. déplacer un cadre et relâcher ; observer Enregistrement… puis Enregistré ;
  2. changer de fond et de page sans toucher Sauvegarder ;
  3. mettre immédiatement l’app en arrière-plan, attendre cinq secondes, puis
     revenir ;
  4. commencer à déplacer un cadre avec un premier doigt et, sans le relever,
     toucher Sauvegarder avec un second doigt ; relever ensuite le premier ;
  5. vérifier que la position courante au moment de Sauvegarder est validée
     comme une seule commande, qu’aucun saut n’a lieu au relâchement et que
     l’état revient à Enregistré avec une heure ;
  6. toucher Annuler une fois puis Rétablir une fois pour confirmer qu’une seule
     commande de déplacement a été créée ;
  7. revenir à la bibliothèque, rouvrir l’album et vérifier les changements ;
  8. fermer l’app depuis le sélecteur, relancer et vérifier de nouveau ;
  9. vérifier que les piles Annuler/Rétablir de l’ancienne session sont vides.
- Résultat attendu : chaque commande validée est persistée sans dépendre du
  bouton Sauvegarder ; arrière-plan consolide immédiatement le journal ;
  Sauvegarder n’annule pas le geste ; retour, fermeture et relance retrouvent le
  dernier état annoncé Enregistré ; nouvelle session sans anciennes piles.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : Toucher Sauvegarder pendant un déplacement valide une première position, puis le relâchement provoque un saut et une seconde commande au lieu d’ignorer la fin du flux tactile déjà validé.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-094` — Interruption après une commande validée et reprise locale

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:APP-009`, `3:LOC-004`, `3:LOC-005`, `3:LOC-011` à
  `3:LOC-014`, `3:LOC-023`, `3:ERR-014`, `3:TST-012`.
- Préconditions : album jetable avec un état A connu ; aucun test de manque
  d’espace dangereux ; l’interruption manuelle ne remplace pas l’injection de
  crash réservée à Xcode.
- Étapes :
  1. ajouter une page et attendre que l’interface confirme la commande ;
  2. forcer immédiatement la fermeture de l’app sans revenir à la bibliothèque ;
  3. relancer et vérifier la page ajoutée ;
  4. importer la fixture carrée, attendre Disponible, la placer puis forcer de
     nouveau la fermeture ;
  5. relancer et vérifier métadonnée, binaire et occurrence ;
  6. commencer un déplacement sans relâcher puis interrompre si le système le
     permet ;
  7. relancer et vérifier soit l’état avant le geste non validé, soit le geste
     complet, jamais une géométrie invalide ou un album illisible.
- Résultat attendu : commandes validées rejouées/consolidées ; aucun asset
  annoncé Disponible sans transaction valide ; dernière version valide jamais
  remplacée par une écriture partielle ; au plus le geste continu non validé
  est perdu ; aucun staging ou message technique brut ne bloque le lancement.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-109`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-095` — Prévisualisation et rendu commun du sous-périmètre Lot 1

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:CAN-003`, `3:CAN-004`, `3:CAN-008`, `3:CAN-009`,
  `3:GLO-007`, `3:GLO-008`.
- Préconditions : page avec fond, trois cadres remplis superposés, rotations,
  une petite photo laissant le fond visible ; sélectionner le cadre supérieur
  et régler le canevas à environ 175 % décentré.
- Étapes :
  1. prendre une capture de la composition en éditeur ;
  2. ouvrir Vue globale et comparer ordre, rotation, masque rectangulaire,
     zones transparentes et fond ;
  3. revenir, ouvrir Prévisualiser et comparer les mêmes points ;
  4. vérifier l’absence de sélection, huit poignées, poignée de rotation,
     guides, boutons locaux et panneaux ;
  5. quitter la prévisualisation ;
  6. vérifier restauration de la page, du cadre sélectionné et du zoom/centre ;
  7. vérifier qu’aucune entrée Annuler n’a été créée par ces changements de vue.
- Résultat attendu : même composition canonique et même profondeur dans
  éditeur, miniature et prévisualisation ; seules les aides d’édition sont
  absentes des sorties ; transparence révèle exactement les éléments inférieurs
  puis le fond ; état de session restauré sans mutation du document. Lecture,
  diaporama et PDF restent hors Lot 1.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-110`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-096` — Cadre vide et alertes dans la vue globale/prévisualisation

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:FRM-001`, `3:FRM-008`, `3:CAN-004`, `3:GLO-006`,
  `3:GLO-007`.
- Préconditions : page 1 avec un cadre vide ; page 2 avec une petite photo
  remplie à `1×` laissant du fond visible.
- Étapes :
  1. vérifier sur page 1 la trame neutre, l’icône photo `+` et le libellé
     « Ajouter une photo » ;
  2. ouvrir Vue globale et vérifier l’alerte accessible de cadre vide sur page
     1 seulement ;
  3. ouvrir page 1 en Prévisualiser et vérifier l’avertissement non bloquant,
     sans rendre le cadre vide comme contenu final ;
  4. ouvrir page 2 et vérifier qu’aucune alerte Cadre vide n’est déclenchée par
     le fond visible autour de la petite photo ;
  5. remplir le cadre de page 1 et vérifier la disparition de l’alerte.
- Résultat attendu : aides du cadre vide présentes seulement en édition ;
  miniature signale clairement le vide ; prévisualisation avertit sans bloquer
  et masque l’aide ; un cadre métier rempli reste rempli même sans couvrir son
  masque ; l’alerte disparaît après remplissage.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-111`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-097` — Qualité, seuils exacts et format régional

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:QLT-001`, `3:QLT-002`, `3:QLT-003`, `3:QLT-004`,
  `3:QLT-005`, sous-périmètre édition/sauvegarde de `3:QLT-006`,
  `3:L10N-005`, `3:GLO-006`.
- Préconditions : région iPad initiale France ; grande fixture placée dans un
  cadre ; le mode Recadrer expose un contrôle accessible Zoom photo permettant
  de saisir ou d’atteindre des valeurs exactes sans estimer un pincement. Noter
  que le calcul se base sur le canevas 4:5 ajusté dans la zone imprimable
  régionale.
- Étapes :
  1. avec le contrôle accessible Zoom photo, fixer exactement `1,00×`, valider
     et vérifier le badge `OK` avec icône et libellé accessible ;
  2. fixer exactement `1,50×`, valider et vérifier `Acceptable` ;
  3. fixer exactement `3,00×`, valider et vérifier `Insuffisante` ;
  4. vérifier les alertes Acceptable/Insuffisante en Vue globale ;
  5. saisir exactement `1,08×` en région France et noter l’état attendu `OK`
     (environ 303 ppp sur le canevas A4 par défaut) ;
  6. fermer l’app, passer temporairement la région système à États-Unis,
     relancer et rouvrir la même occurrence ;
  7. vérifier à `1,08×` l’état attendu `Acceptable` (environ 294 ppp sur le
     canevas Letter par défaut) ;
  8. revenir à `3,00×`, déplacer le cadre puis toucher Sauvegarder ; vérifier
     que l’état Insuffisante ne bloque ni la modification ni la réussite de la
     sauvegarde ; restaurer enfin la région d’origine.
- Résultat attendu : seuils `OK ≥ 300`, `Acceptable ≥ 150 et < 300`,
  `Insuffisante < 150` ; recalcul dérivé après zoom et changement régional,
  jamais persisté ; forme/icône/libellé en plus de la couleur ; avertissement
  non bloquant pour édition et sauvegarde. L’avertissement avant export et le
  recalcul du format PDF choisi de `3:QLT-006` restent hors Lot 1.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-112`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-098` — Interface régulière/compacte, orientations et apparence

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEC-05`, `3:DEC-17`, `3:EDT-002`, `3:EDT-004`,
  `3:EDT-005`, `3:EDT-006`, `3:EDT-011`, `3:EDT-016`, sous-périmètre
  Ajouter une photo de `3:EDT-020`, `3:GLO-001`, `3:ACC-021`, `3:TST-008`.
- Préconditions : album de trois pages avec un cadre sélectionné ; iPad
  autorisant portrait, paysage et fenêtre étroite/Split View.
- Étapes :
  1. en portrait plein écran, relever barre, rail/inspecteur, commandes Photos
     puis Fonds et sélecteur Créer/Organiser/Prévisualiser ;
  2. tourner en paysage et vérifier sélection/page conservées ;
  3. réduire la fenêtre jusqu’à la présentation compacte ;
  4. vérifier la barre inférieure/feuille adaptative, l’ordre Photos puis Fonds,
     et les commandes trop larges dans le menu intitulé exactement « Plus »,
     sans changement de libellé, d’effet ou d’ordre relatif ;
  5. vérifier qu’Ajouter une photo reste visible ou accessible via Ajouter en
     deux activations au plus, sans exposer Ajouter du texte avant le Lot 2 ;
  6. basculer clair puis sombre dans chaque largeur ;
  7. replier/réafficher l’inspecteur ;
  8. vérifier à chaque étape qu’une seule page est affichée et que la sélection
     ne change pas en ouvrant/fermant un panneau ;
  9. vérifier l’absence de marge de sécurité, prix, Commander et de toute
     commande commerciale.
- Résultat attendu : aucune superposition ou commande inaccessible, ordre et
  libellés stables, état actif non indiqué par couleur seule, page aspect-fit
  centrée, une seule page ; adaptation conserve sélection et contenu ; fonds
  Aucun/couleurs restent opaques et identiques en clair/sombre.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-113`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-099` — Dynamic Type, description accessible et VoiceOver

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ACC-001`, `3:ACC-002`, `3:ACC-003`, `3:ACC-004`,
  `3:ACC-005`, `3:ACC-007`, `3:ACC-008`, `3:ACC-011`, `3:ACC-012`,
  `3:ACC-017`, `3:ACC-020`, `3:EDT-010`, `3:TST-008`.
- Préconditions : album de deux pages avec un cadre vide, deux cadres remplis
  superposés, une occurrence photo sans description en page 2 et une alerte
  qualité ; mémoriser la géométrie avant réglages.
- Étapes :
  1. sélectionner l’occurrence de page 2, ouvrir l’action Description
     accessible, saisir `Plage au coucher du soleil` et valider ;
  2. régler Dynamic Type sur une taille d’accessibilité élevée ;
  3. parcourir bibliothèque, éditeur, panneau Photos, Fonds, vue globale,
     corbeille et confirmations ;
  4. vérifier absence de texte essentiel tronqué ou commande hors écran sans
     défilement possible ;
  5. activer VoiceOver et parcourir tous les boutons graphiques ;
  6. vérifier libellé, état et aide pour sauvegarde, panneaux, zoom, navigation,
     cadres et qualité ;
  7. parcourir l’occurrence décrite et vérifier que VoiceOver annonce
     `Plage au coucher du soleil` avec son type, sa position approximative et
     son ordre ;
  8. désactiver temporairement VoiceOver, effacer et valider la description,
     le réactiver puis vérifier le repli exact « Photo, page 2 » ;
  9. vérifier numéro de page, nombre de cadres dont cadres vides et alertes en
     vue globale ;
  10. sélectionner un cadre masqué via « Sélectionner un élément », puis le
     déplacer/redimensionner/réordonner par actions ou menus accessibles ;
  11. réorganiser une page et placer une photo sans glisser-déposer ;
  12. désactiver VoiceOver/Dynamic Type élevé et vérifier la géométrie du
      canevas inchangée.
- Résultat attendu : libellé/hint pour toute icône, cibles tactiles utilisables,
  états jamais uniquement colorés, lecture individuelle non ambiguë,
  alternatives complètes aux gestes, aucune modification de géométrie due à
  Dynamic Type et parcours principal réalisable sans vue inaccessible.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-114`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-100` — Clavier, Option + flèches et aide

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:EDT-009`, `3:ELM-011`, `3:ELM-012`, `3:ELM-013`,
  `3:ACC-005`, `3:ACC-013`, `3:ACC-014`, `3:ACC-015`, `3:TST-008`.
- Préconditions : clavier matériel ou compatible, trackpad/pointeur ; page avec
  deux cadres, l’un sélectionné.
- Étapes :
  1. utiliser les flèches pour déplacer la sélection et vérifier le pas 0,01
     de la dimension de page ;
  2. utiliser Option+flèches et vérifier le pas fin 0,0025 ;
  3. tester `⌘C`, `⌘V`, `⌘X`, Supprimer, `⌘Z`, `⇧⌘Z` ;
  4. vérifier que Coller crée une nouvelle occurrence et que Couper reste une
     commande atomique ;
  5. ouvrir Renommer l’album, placer le curseur dans le champ puis presser les
     flèches, Option + flèches, `⌘C`, `⌘V` et `⌘X` ; vérifier que le champ
     consomme ses commandes de texte et qu’aucun cadre ne bouge ; annuler le
     renommage ;
  6. ouvrir Aide avec le clavier connecté et vérifier qu’elle documente au
     minimum `⌘Z`, `⇧⌘Z`, `⌘X`, `⌘C`, `⌘V`, Supprimer, flèches et Option +
     flèches ;
  7. utiliser le pointeur sur huit poignées et la poignée de rotation ;
  8. exécuter les mêmes transformations avec Position et taille et Rotation… ;
  9. déplacer une page par son menu accessible sans glissement ;
  10. réduire la fenêtre et vérifier qu’aucune cible nécessaire au pointeur ou
      au clavier ne devient inaccessible.
- Résultat attendu : raccourcis conformes, pas normalisés exacts, aucune
  commande consommée par erreur hors contexte, champ de texte prioritaire sur
  les raccourcis d’élément, raccourcis documentés dans l’aide,
  pointeur/trackpad utilisables, toutes transformations et réorganisations
  possibles sans geste multipoint.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-115`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-101` — Fonctionnement local hors ligne

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEV-005`, `3:LOC-001` à `3:LOC-005`, `3:SEC-001`,
  `3:ERR-008`, `3:ACPT-100`.
- Préconditions : deux albums avec fonds intégrés, photos importées depuis
  Photos, Fichiers et un autre album ; toutes affichées Disponible ; fermer
  les sélecteurs système.
- Étapes :
  1. activer le mode Avion et couper Wi-Fi/Bluetooth si nécessaire ;
  2. relancer l’app ;
  3. ouvrir les deux albums et chaque page ;
  4. afficher toutes les photos, fonds, miniatures et couvertures ;
  5. créer un album, ajouter une page, changer un fond, placer/recadrer une
     photo déjà locale, renommer et enregistrer ;
  6. fermer et relancer toujours hors ligne ;
  7. restaurer le réseau et vérifier qu’aucun contenu local n’est remplacé.
- Résultat attendu : toutes les données déjà locales restent lisibles et
  modifiables, aucune photo envoyée vers un serveur propriétaire, aucune erreur
  réseau bloquante ; les commandes hors ligne persistent après relance ; le
  retour réseau ne change rien silencieusement.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-116`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-102` — Ancien store 2.1 laissé intact et ignoré

- Candidat : **À figer sur le commit correctif avant exécution**.
- Spécification : 3.0, empreinte du correctif à figer avant exécution.
- Exigences : `3:DEC-33`, `3:DAT-025`, `3:DAT-026`, `3:LOC-010`,
  `3:LOC-029` à `3:LOC-031`, `3:ERR-024`.
- Préconditions : copie de l’app contenant réellement un store du prototype
  2.1 avec au moins un album reconnaissable ; sauvegarder le projet et ne pas
  utiliser de donnée personnelle non sauvegardée. Si le bac à sable 2.1 ne peut
  pas être conservé lors du remplacement dans Swift Playgrounds, répondre
  `BLOQUÉ` et décrire la limite.
- Étapes :
  1. relever sans modifier le contenu visible du prototype 2.1 ;
  2. installer/lancer exactement le candidat 3.0 sur le même conteneur selon le
     parcours disponible ;
  3. observer le premier lancement ;
  4. vérifier qu’aucun album 2.1 n’est affiché, importé, converti ou proposé à
     la migration ;
  5. créer un album 3.0, fermer et relancer ;
  6. si l’environnement permet une inspection non destructive, vérifier que
     les anciens fichiers n’ont été ni déplacés, ni renommés, ni supprimés.
- Résultat attendu : nouvelle bibliothèque 3.0 indépendante sous sa propre
  génération ; aucun décodage ou migration 2.1 ; album 3.0 durable ; ancien
  contenu intact. Un échec de création 3.0 ne présente jamais un état partiel
  comme valide.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — captures avant/après et, si possible, inventaire
  non destructif des fichiers ; sinon noter explicitement la limite.
- Environnement : à renseigner — méthode de conservation du conteneur.

### `IPAD-L1-103` — Enveloppe 100 pages et 20 occurrences photo

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PAG-012`, sous-périmètre occurrence photo de `3:LOC-018`,
  `3:PERF-008`, `3:PERF-015`, `3:PERF-017`.
- Préconditions : album de stress non personnel ; alimentation branchée ; ne
  pas remplir artificiellement le disque ; chronomètre disponible. Cette fiche
  mesure l’expérience iPad, pas le pic mémoire Instruments.
- Étapes :
  1. créer ou préparer exactement 100 pages et vérifier que l’ajout reste
     possible ;
  2. fermer et relancer, chronométrer de la pression sur la carte à l’affichage
     de la première page locale ;
  3. ouvrir Vue globale, faire défiler du début à la fin et ouvrir les pages 1,
     50 et 100 ;
  4. sur une page de test, importer une fixture puis créer exactement vingt
     occurrences photo remplies, par placements ou duplications ; vérifier le
     compteur `×20` et l’absence de cadre vide compté à leur place ;
  5. demander une vingt-et-unième occurrence remplie, relever l’avertissement
     non bloquant, puis choisir Continuer si l’appareil ne signale aucun risque
     de cohérence, stockage ou décodage ;
  6. déplacer un cadre plusieurs secondes et observer fluidité, absence de
     décodages clignotants et sauvegarde seulement à la validation ;
  7. ajouter une 101e page, relever l’avertissement non bloquant puis choisir
     Continuer si l’opération reste sûre ;
  8. fermer et relancer, vérifier 101 pages et le contenu de la page de stress.
- Résultat attendu : 100 pages garanties, premier contenu local visé en moins
  de deux secondes et navigation globale sans crash ; 21e occurrence photo
  remplie et 101e page avertissent sans limite arbitraire si l’opération est
  sûre ; le mouvement reste interactif sans signe de décodage plein format ni
  état Enregistrement… à chaque image, puis la commande finale est persistée ;
  état final durable.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-117`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-104` — Matrice commandes, icônes et états en largeurs régulière/compacte

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : sous-périmètre Lot 1 de `3:EDT-003`, `3:EDT-004`, tableaux
  7.2.1 et 7.2.2, `3:EDT-007`, `3:EDT-010`, `3:EDT-012`, `3:EDT-013`,
  `3:EDT-014`, `3:EDT-015`, `3:EDT-016`, `3:EDT-017`, `3:FRM-005`,
  `3:FRM-006`.
- Préconditions : iPad permettant une largeur régulière puis compacte ; album
  de deux pages avec un cadre vide, un cadre rempli, une photo de remplacement
  disponible et un presse-papiers initialement vide. Fermer puis rouvrir
  l’album afin de commencer sur Enregistré avec les piles Annuler/Rétablir
  vides. Activer VoiceOver pour relever les libellés accessibles, puis le
  désactiver entre les relevés si nécessaire.
- Étapes :
  1. en largeur régulière et sans sélection, relever dans l’ordre Retour, Aide,
     nom/Renommer, état de sauvegarde, Sauvegarder, Annuler, Rétablir, Couper,
     Copier, Coller, Créer — Vue page, Organiser — Vue globale et
     Prévisualiser ; vérifier les symboles du tableau 7.2.1, Sauvegarder,
     Annuler et Rétablir désactivés dans cet état initial, Créer indiqué actif
     autrement que par la couleur, et l’absence des commandes Lots 2/3 Mise en
     page auto et Exporter ;
  2. vérifier Couper/Copier désactivés sans sélection, Coller désactivé sans
     payload compatible, Photos et Fonds accessibles, et l’état actif combinant
     forme/libellé/indicateur avec la couleur ;
  3. sélectionner le cadre vide : relever Ajouter une photo
     (`photo.badge.plus`), Rotation…, Dupliquer,
     Premier plan/Avancer/Reculer/Arrière-plan, Position et taille puis
     Supprimer dans cet ordre ; vérifier Recadrer et toutes les
     transformations de contenu absentes ou désactivées ;
  4. remplir puis sélectionner ce cadre : vérifier Couper et Copier activés,
     puis relever exactement Remplacer,
     Retirer la photo, Recadrer, Pivoter à gauche, Pivoter à droite, Retourner
     horizontalement, Description accessible…, Rotation…, Dupliquer, Premier
     plan, Avancer, Reculer, Arrière-plan, Position et taille puis Supprimer ;
     vérifier leurs symboles, libellés VoiceOver et états aux deux extrémités
     de profondeur, ainsi que Pleine page dans Position et taille ;
  5. toucher Copier, désélectionner et vérifier Coller activé ; toucher Coller,
     attendre Enregistré, puis vérifier Annuler activé/Rétablir désactivé ;
     toucher Annuler et vérifier Rétablir activé ; toucher Rétablir ;
  6. sélectionner une photo et entrer en mode Recadrer : vérifier que panneaux, navigation de page et
     transformations du cadre sont désactivés ; relever Zoom photo avec valeur
     en `×`, Annuler, Réinitialiser et Terminé, tandis que les trois commandes
     de zoom du canevas restent distinctes et désactivées ;
  7. quitter le cadrage, réduire la fenêtre en largeur compacte et recréer
     successivement les états sans sélection, cadre vide, cadre rempli et mode
     cadrage pour répéter la même matrice ; vérifier que le débordement
     s’intitule « Plus », conserve libellés, états et ordre relatif, et que
     Créer, Organiser et Prévisualiser ne sont pas enfouis dans Plus ;
  8. revenir en largeur régulière et vérifier que page, sélection et état de
     chaque commande sont conservés.
- Résultat attendu : chaque état de sélection expose uniquement la barre
  fonctionnelle prévue, dans l’ordre exact, avec SF Symbol de référence ou
  équivalent natif, libellé accessible inchangé et désactivation exacte ; la
  largeur compacte ne change aucun effet ni ordre métier. Les commandes Lots 2
  et 3 ne sont pas exposées conformément à `3:ARC-014`.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-118`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-105` — Réduire les animations

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ACC-006`, sous-périmètre Lot 1 de `3:TST-010`.
- Préconditions : album de trois pages reconnaissables ; enregistrer une courte
  vidéo de référence avec Réduire les animations désactivé, puis activer
  Réglages > Accessibilité > Mouvement > Réduire les animations et relancer
  l’app.
- Étapes :
  1. ouvrir et fermer successivement Photos, Fonds et Aide ;
  2. passer de Vue page à Vue globale, ouvrir une miniature puis ouvrir et
     fermer Prévisualiser ;
  3. naviguer avec Précédent/Suivant et avec un balayage sur zone vide ;
  4. ouvrir puis annuler une confirmation et une feuille de sélection ;
  5. vérifier après chaque transition la page active, la sélection, le zoom et
     l’absence de nouvelle commande Annuler ;
  6. comparer la vidéo au parcours de référence et restaurer le réglage système.
- Résultat attendu : les transitions publiques du Lot 1 respectent le réglage,
  évitent tout mouvement ample ou désorientant et utilisent une transition
  réduite cohérente ; aucun état métier ni géométrie ne change. Le fondu de
  page final de `3:ANI-009` reste réservé à l’animation livrée au Lot 3 et n’est
  pas déclaré validé ici.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-119`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-106` — Aide contextuelle disponible hors ligne

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : sous-périmètre Lot 1 de `3:EDT-019`, `3:ARC-014`, `3:DEC-38`.
- Préconditions : album avec un cadre vide, un cadre rempli et une alerte de
  qualité ; activer le mode Avion avant de lancer l’app.
- Étapes :
  1. depuis Vue page sans panneau, ouvrir Aide et vérifier les rubriques de
     sélection, ajout photo, cadre vide et navigation ;
  2. ouvrir Photos puis Aide et vérifier que le contenu d’ajout, import,
     placement et suppression logique est présenté en premier ;
  3. ouvrir Fonds puis Aide et vérifier que le choix par page, Appliquer à
     toutes les pages et Annuler sont contextualisés ;
  4. sélectionner la photo, entrer en cadrage puis ouvrir Aide par la commande
     disponible et vérifier cadrage, Zoom photo, Annuler, Réinitialiser et
     Terminé ;
  5. depuis Vue globale avec l’alerte qualité, ouvrir Aide et vérifier pages,
     réorganisation et signification des alertes ;
  6. vérifier que toutes ces pages s’ouvrent sans réseau, utilisent une
     présentation iOS native, ne reprennent ni marque ni texte Photoweb et
     n’exposent aucune commande des Lots 2/3.
- Résultat attendu : Aide est consultable entièrement hors ligne et son premier
  contenu dépend de la vue, du panneau ou du mode actif ; elle couvre les
  fonctions publiques Lot 1 sans marque tierce. Modèles, dé, Auto, texte et
  stickers exigés par l’intégralité de `3:EDT-019` seront ajoutés et testés au
  Lot 2 : cette fiche ne valide que l’aide des fonctions publiques du Lot 1.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-120`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-107` — Progression, annulation et nettoyage d’un import long

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:APL-006`, `3:PERF-009`, `3:PERF-011`, `3:APP-006`,
  `3:SEC-008`.
- Préconditions : préparer au moins deux photos statiques non personnelles,
  dont un RAW ou JPEG assez volumineux pour que sa copie mesurée dépasse
  500 ms sur l’iPad testé, plus deux fichiers volumineux distincts réservés au
  sous-cas d’annulation. Noter noms, formats, tailles, dimensions et SHA-256.
  Si aucune copie ne dépasse 500 ms, la fiche ne peut pas réussir : répondre
  `BLOQUÉ` avec les durées observées.
- Étapes :
  1. démarrer un enregistrement d’écran avec horodatage puis lancer un import
     Fichiers multiple des deux photos ;
  2. pendant que le premier fichier est copié et que le suivant reste en
     attente, vérifier une ligne propre à chaque fichier et une progression
     globale de l’opération ;
  3. vérifier que la ligne courante passe de Copie en cours à Copie terminée,
     que la ligne suivante passe ensuite à Copie en cours, et que le compteur
     global avance sans régresser ni confondre un échec avec un succès ;
  4. vérifier qu’aucune ligne n’est annoncée Disponible avant la validation
     atomique finale de l’import ;
  5. attendre la disparition de la progression, vérifier les deux photos
     Disponibles dans le panneau, fermer et relancer hors ligne, puis les
     afficher ;
  6. lancer l’import des deux fichiers réservés, attendre Copie en cours puis
     toucher « Annuler l’import » avant la fin globale ;
  7. vérifier que l’annulation est annoncée, que la progression disparaît, que
     seules les copies annoncées comme déjà enregistrées peuvent rester
     Disponibles et qu’aucune entrée En attente ou fantôme ne subsiste ;
  8. revenir à la bibliothèque pendant un troisième import long, puis rouvrir
     l’album, relancer hors ligne et réimporter les fichiers non enregistrés.
- Résultat attendu : toute copie dépassant 500 ms montre simultanément sa
  activité individuelle et la progression globale ; les états restent
  attribués au bon fichier, « Copie terminée » ne signifie pas encore
  « Disponible », la fin globale correspond au traitement de toutes les
  copies et les deux ressources ne deviennent Disponibles qu’après la
  transaction finale, puis restent durables hors ligne. Annuler attend la fin
  de l’appel système indivisible en cours, conserve uniquement les copies déjà
  validées, nettoie les temporaires, ne laisse aucun état partiel et permet une
  nouvelle tentative. La fermeture ne libère pas la session sous un transfert
  PhotosPicker encore actif.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-121`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-108` — Commandes rapides sérialisées sans perte ni erreur de révision

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:APP-002`, `3:APP-005`, `3:LOC-011` à `3:LOC-014`,
  `3:UND-011`, `3:ARC-007`.
- Préconditions : album `Commandes rapides` enregistré, contenant une première
  page et au moins une photo disponible ; aucun import ni geste de cadrage en
  cours. Activer l’enregistrement d’écran afin de distinguer les pressions.
- Étapes :
  1. dans Vue globale, toucher très rapidement deux fois Ajouter une page ;
  2. attendre Enregistré, vérifier que les deux commandes acceptées sont
     présentes, qu’aucune alerte de révision obsolète ou d’action occupée
     n’apparaît et que les identifiants/pages ne sont pas dupliqués ;
  3. revenir en Vue page, déclencher presque simultanément un changement de
     fond puis Ajouter une page, attendre Enregistré et vérifier les deux
     effets ;
  4. revenir à la bibliothèque, renommer successivement le même album deux
     fois aussi vite que les dialogues le permettent ; attendre chaque
     fermeture et vérifier le dernier nom ;
  5. toucher rapidement Annuler deux fois dans la bibliothèque, attendre la
     fin des deux commandes puis vérifier le retour au nom initial ;
  6. toucher rapidement Rétablir deux fois, vérifier le dernier nom, ouvrir
     aussitôt l’album et confirmer que l’ouverture attend la clôture durable
     de la session bibliothèque sans écran modifiable concurrent ;
  7. fermer et relancer l’app, puis vérifier le nombre de pages, le fond et le
     nom obtenus à l’étape 6.
- Résultat attendu : toutes les commandes effectivement déclenchées sont
  traitées dans un ordre durable, sans `staleRevision`, message Occupé, perte
  silencieuse ni écrasement d’un état plus récent ; Annuler/Rétablir conserve
  l’ordre de session, l’ouverture ne chevauche pas une mutation bibliothèque
  et la relance retrouve exactement l’état annoncé Enregistré.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ;
  remplacée par `IPAD-L1-131`.
- Preuve : non exécutée avant modification ; le scénario traverse désormais la
  transition post-création et l’inspecteur Fonds corrigés.
- Environnement : sans objet.

## Campagne de régression après retours du 16 août 2026

Les fiches ci-dessous ciblent le prochain commit correctif. Elles sont préparées
mais ne doivent pas être exécutées avant que « À figer » soit remplacé par son
empreinte Git exacte et que la copie transférée porte cette même empreinte.

### `IPAD-L1-109` — Interruption et sauvegarde après correctifs gestuels

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:SAV-001`, `3:APP-009`, `3:LOC-011` à `3:LOC-014`,
  `3:LOC-026`.
- Préconditions : album jetable avec deux pages et un cadre rempli.
- Étapes : ajouter une page puis forcer la fermeture après confirmation ;
  relancer ; déplacer ensuite un cadre, toucher Sauvegarder avant de relever le
  doigt, relever le doigt, fermer de force puis relancer.
- Résultat attendu : page et position validées retrouvées ; aucun saut après
  Sauvegarder, une seule commande de déplacement et aucun état partiel.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : vidéo continue et captures après chaque relance.
- Environnement : à renseigner intégralement.

### `IPAD-L1-110` — Prévisualisation et fonds mis en cache

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:CAN-003`, `3:CAN-004`, `3:CAN-008`, `3:GLO-007`,
  `3:PERF-016`.
- Préconditions : page avec motif intégré et trois cadres superposés ; canevas
  décentré à environ 175 %.
- Étapes : comparer éditeur, Vue globale et Prévisualiser ; revenir à la page ;
  ouvrir Photos puis Fonds trois fois sans quitter l’album et chronométrer le
  premier retour visuel de chaque ouverture.
- Résultat attendu : composition identique hors aides d’édition, état de fenêtre
  restauré ; structure de Fonds visible en moins de 200 ms et aucune attente de
  plusieurs secondes lors des réouvertures.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : captures comparatives et trois durées mesurées.
- Environnement : à renseigner intégralement.

### `IPAD-L1-111` — Cadre vide et mode de choix explicite

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:FRM-001`, `3:FRM-008`, `3:GLO-006`, `3:PHO-011` à
  `3:PHO-013`.
- Préconditions : page 1 avec cadre vide, page 2 vide, deux photos disponibles.
- Étapes : toucher Ajouter une photo dans le cadre vide, vérifier l’annonce de
  la cible puis Annuler ; recommencer et remplir ; page 2, utiliser l’ajout local,
  vérifier « nouveau cadre », changer de page avant le choix puis recommencer.
- Résultat attendu : modes visibles et annulables ; aucune création à
  l’annulation ou au changement de page ; choix final remplit ou crée uniquement
  la cible annoncée ; alertes de cadre vide restent cohérentes.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : captures de chaque bandeau de mode et des pages finales.
- Environnement : à renseigner intégralement.

### `IPAD-L1-112` — Qualité informative et format régional

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:QLT-001` à `3:QLT-006`, `3:EDT-021`, `3:L10N-005`.
- Préconditions : grande fixture dans un cadre ; région France.
- Étapes : valider successivement `1,00×`, `1,50×` et `3,00×`, puis refaire le
  contrôle `1,08×` en France et aux États-Unis ; sélectionner le cadre dans les
  deux largeurs d’interface.
- Résultat attendu : états `OK`, `Acceptable`, `Insuffisante` et bascule
  régionale attendus ; la qualité est un libellé informatif distinct des boutons,
  accessible, et ne bloque ni édition ni sauvegarde.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : captures des états et régions.
- Environnement : à renseigner intégralement.

### `IPAD-L1-113` — Inspecteur droit et adaptation compacte

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:EDT-002`, `3:EDT-006`, `3:EDT-011`, `3:EDT-016`,
  `3:EDT-021`, `3:ACC-021`.
- Préconditions : iPad en largeur régulière puis compacte ; cadre rempli
  sélectionné.
- Étapes : ouvrir Photos et Fonds ; vérifier l’inspecteur à droite, ses groupes
  Contenu/Cadre et son repli ; tourner l’iPad, passer si possible en largeur
  compacte, ouvrir/fermer le panneau et retrouver la largeur régulière.
- Résultat attendu : aucune commande inaccessible ou superposée ; sélection et
  page conservées ; présentation compacte dans la même fenêtre et inspecteur
  droit restauré en largeur régulière.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : captures régulière/compacte et orientations réellement disponibles.
- Environnement : à renseigner intégralement.

### `IPAD-L1-114` — Dynamic Type, choix non ambigu et VoiceOver

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:ELM-014`, `3:ACC-001` à `3:ACC-005`, `3:ACC-007`,
  `3:ACC-008`, `3:ACC-011`, `3:ACC-012`, `3:ACC-017`, `3:ACC-020`.
- Préconditions : trois cadres photo fortement superposés, avec noms ou
  descriptions distincts ; Dynamic Type élevé et VoiceOver disponibles.
- Étapes : ouvrir Sélectionner un élément depuis la barre et le canevas ; lire
  les trois choix ; sélectionner successivement arrière, milieu et avant ;
  parcourir ensuite Photos, Fonds, corbeille et confirmations avec VoiceOver.
- Résultat attendu : chaque choix annonce type, repère distinctif, position et
  profondeur ; aucun libellé essentiel tronqué sans défilement et aucune
  sélection ne change la profondeur.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : enregistrement VoiceOver avec audio.
- Environnement : à renseigner intégralement.

### `IPAD-L1-115` — Pointeur, poignées hybrides et rotation directe

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:ELM-002`, `3:ELM-011` à `3:ELM-013`, `3:ACC-005`,
  `3:ACC-013` à `3:ACC-015`.
- Préconditions : clavier/pointeur si disponibles ; cadre partiellement hors
  page puis cadre dont une bordure sort de la fenêtre.
- Étapes : contrôler les neuf poignées aux bordures visibles et les cibles de
  secours lorsque la bordure sort ; ouvrir Rotation…, déplacer le curseur et
  utiliser `±90°`, Annuler, puis recommencer et Valider.
- Résultat attendu : bordures et poignées visuelles coïncident lorsqu’elles sont
  visibles ; les secours restent activables ; rotation visible en direct ;
  Annuler restaure l’entrée et Valider crée une seule commande.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : vidéo avec pointeur ou doigt et un Annuler/Rétablir.
- Environnement : à renseigner intégralement.

### `IPAD-L1-116` — Relance locale et cache des fonds hors ligne

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:LOC-001`, `3:SEC-001`, `3:ERR-008`, `3:PERF-007`,
  `3:PERF-016`.
- Préconditions : deux albums utilisant les trois motifs intégrés ; mode Avion.
- Étapes : relancer trois fois et chronométrer jusqu’au premier contenu ; ouvrir
  chaque album et chaque fond ; alterner Photos/Fonds cinq fois ; modifier un
  fond, enregistrer et relancer toujours hors ligne.
- Résultat attendu : premier contenu en moins de deux secondes dans l’enveloppe
  visée, aucune revalidation bloquante du catalogue, réouvertures immédiates et
  état durable sans réseau.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : six durées et vidéo du parcours hors ligne.
- Environnement : à renseigner intégralement.

### `IPAD-L1-117` — Cent pages, compteurs et déplacement continu

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:PAG-012`, `3:PHO-002`, `3:PERF-008`, `3:PERF-015`,
  `3:PERF-017`.
- Préconditions : album de 100 pages et une fixture locale.
- Étapes : chronométrer l’ouverture ; créer vingt occurrences du même asset et
  vérifier `×20` ; déplacer un cadre plusieurs secondes ; créer la 21e
  occurrence puis la 101e page et relancer.
- Résultat attendu : compte exact des seuls cadres de l’album, avertissements
  non bloquants, aucune écriture ou redécodage visible pendant le mouvement et
  état final durable.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : durée, vidéo du déplacement et captures des compteurs/alertes.
- Environnement : à renseigner intégralement.

### `IPAD-L1-118` — Matrice des commandes dans le nouvel inspecteur

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:EDT-010` à `3:EDT-017`, `3:EDT-021`, `3:FRM-005`,
  `3:FRM-006`.
- Préconditions : cadre vide, cadre rempli, seconde photo et presse-papiers
  vide ; largeurs régulière puis compacte.
- Étapes : relever les états sans sélection, cadre vide, cadre rempli et
  cadrage ; en régulier contrôler les groupes verticaux Contenu puis Cadre et
  Supprimer à côté de Copier/Coller ; en compact contrôler les mêmes effets et
  l’ordre relatif ; exercer Supprimer.
- Résultat attendu : matrice complète, qualité non interactive, actions de
  contenu séparées des transformations du cadre et Supprimer immédiatement
  accessible sans ambiguïté.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : captures annotées des états.
- Environnement : à renseigner intégralement.

### `IPAD-L1-119` — Réduire les animations avec inspecteur droit

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:ACC-006`, `3:EDT-002`, sous-périmètre Lot 1 de `3:TST-010`.
- Préconditions : album de trois pages ; vidéos de référence avec Réduire les
  animations désactivé puis activé.
- Étapes : replier/afficher l’inspecteur, alterner Photos/Fonds, ouvrir/fermer
  Aide, Vue globale et Prévisualiser, puis naviguer par boutons et balayage.
- Résultat attendu : transitions réduites cohérentes, aucun mouvement ample et
  aucun changement de page, sélection, zoom ou historique causé par l’interface.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : vidéos comparatives.
- Environnement : à renseigner intégralement.

### `IPAD-L1-120` — Aide contextuelle depuis le nouvel inspecteur

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:EDT-019`, `3:EDT-021`, `3:ARC-014`, `3:DEC-38`.
- Préconditions : mode Avion ; cadre vide, cadre rempli et alerte qualité.
- Étapes : ouvrir Aide sans panneau, depuis Photos, depuis Fonds, pendant le
  cadrage, depuis l’inspecteur de cadre puis depuis Vue globale.
- Résultat attendu : aide locale contextualisée sur le panneau ou mode courant,
  incluant la séparation Contenu/Cadre sans exposer les lots 2/3.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : captures de chaque contexte.
- Environnement : à renseigner intégralement.

### `IPAD-L1-121` — Import long, annulation et déduplication

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:APL-006`, `3:PHO-019`, `3:PERF-009`, `3:PERF-011`,
  `3:APP-006`, `3:SEC-008`.
- Préconditions : deux JPEG distincts dont la copie dépasse 500 ms et une copie
  exacte du premier ; noms, tailles et SHA-256 notés.
- Étapes : importer les deux distincts et suivre chaque état ; réimporter le
  premier seul puis dans un lot où il apparaît deux fois ; lancer enfin un
  import long et l’annuler avant la fin.
- Résultat attendu : progression attribuée au bon fichier ; aucune seconde
  miniature ni commande de contenu pour les empreintes déjà présentes ; ordre
  des nouveautés conservé ; annulation nettoyée et relance cohérente.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : vidéo, hashes et ordre du panneau avant/après.
- Environnement : à renseigner intégralement.

### `IPAD-L1-122` — Lancement et réouverture rapide des Fonds

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:PERF-004`, `3:PERF-007`, `3:PERF-016`, `3:BG-008`.
- Préconditions : stockage 3.0 existant avec au moins un album et les trois
  fonds déjà utilisés une fois.
- Étapes : relancer trois fois en chronométrant le premier contenu ; dans le
  même album, alterner cinq fois Photos et Fonds.
- Résultat attendu : lancement sous la cible de deux secondes, structure de
  Fonds sous 200 ms, aucun blocage d’environ 6 ou 15 secondes et motifs chargés
  progressivement sans écran figé.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : tableau des huit durées et vidéo.
- Environnement : à renseigner intégralement.

### `IPAD-L1-123` — Retour après création et dates de corbeille

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:ALB-006`, `3:ALB-017` à `3:ALB-025`.
- Préconditions : bibliothèque ouverte ; date système connue.
- Étapes : créer un album, attendre son ouverture automatique puis toucher
  immédiatement Retour aux albums ; le mettre à la corbeille et l’ouvrir.
- Résultat attendu : retour fonctionnel sans relance ; deux dates absolues en
  français, « Mise à la corbeille » et « Suppression définitive prévue »,
  séparées de trente périodes de 24 h.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : vidéo création/retour et capture de la corbeille.
- Environnement : à renseigner intégralement.

### `IPAD-L1-124` — Compteur exact et grilles photo carrées

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:PHO-002`, `3:PHO-009`, `3:PHO-015`, `3:PHO-019`.
- Préconditions : deux albums partageant les mêmes octets sous deux `assetID` ;
  cible avec exactement une occurrence et au moins huit photos sources.
- Étapes : vérifier `×1` dans la cible après suppression définitive de la
  source ; ouvrir le menu et l’annonce d’usage ; afficher le panneau puis la
  grille Depuis vos autres albums en largeur permettant quatre colonnes.
- Résultat attendu : compte limité à l’`assetID` courant ; miniatures carrées,
  non superposées et compteur entièrement visible dans toutes les colonnes.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : captures des deux grilles et du compteur.
- Environnement : à renseigner intégralement.

### `IPAD-L1-125` — Modes Ajouter, Remplir et Remplacer explicites

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:PHO-004`, `3:PHO-011` à `3:PHO-013`, `3:FRM-004`.
- Préconditions : page vide, cadre vide, cadre rempli et deux photos disponibles.
- Étapes : lancer successivement l’ajout local, l’ajout du cadre vide et
  Remplacer ; pour chaque mode vérifier la cible, Annuler puis refaire et choisir
  une miniature.
- Résultat attendu : le panneau annonce respectivement Nouveau cadre, Remplir
  ce cadre et Remplacer la photo ; Annuler est sans effet ; un seul objet cible
  change après le choix.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : captures des trois annonces et états avant/après.
- Environnement : à renseigner intégralement.

### `IPAD-L1-126` — Insertion de page et activation après Rétablir

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:PAG-004`, `3:PAG-005`, `3:PAG-010`, `3:PAG-016`.
- Préconditions : album de cinq pages reconnaissables.
- Étapes : glisser la page 5 avant les pages 2 puis 4 et après la dernière en
  observant l’indicateur ; supprimer la page active, Annuler puis Rétablir.
- Résultat attendu : indicateur clignotant avant la cible ou en fin (fixe et
  visible avec Réduire les animations), ordre conforme ; la
  page recréée par Rétablir devient immédiatement active.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : vidéo du curseur d’insertion et du Rétablir.
- Environnement : à renseigner intégralement.

### `IPAD-L1-127` — Sélection non ambiguë, poignées hybrides et rotation

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:ELM-002`, `3:ELM-013`, `3:ELM-014`, `3:EDT-021`.
- Préconditions : trois cadres superposés nommés distinctement ; l’un déborde de
  la page.
- Étapes : identifier chaque cadre par Sélectionner un élément ; vérifier les
  poignées sur les bordures visibles et les secours ; modifier Rotation… sans
  valider, Annuler, puis modifier et Valider ; Annuler une fois.
- Résultat attendu : choix non ambigus, commandes à droite séparées, aperçu en
  direct, restauration exacte à Annuler et une seule commande après Valider.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : vidéo continue.
- Environnement : à renseigner intégralement.

### `IPAD-L1-128` — Pincement, panoramique et balayage après retour

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:ZOM-003` à `3:ZOM-006`, `3:NAV-001` à `3:NAV-007`.
- Préconditions : album de trois pages ; page 1 ajustée puis zoomée à 200 %.
- Étapes : pincer seul, déplacer deux doigts à distance constante, combiner
  zoom et translation ; naviguer 1→2→1 par boutons puis 1→2→1 par balayage sur
  zone vide ; répéter après ouverture/fermeture de Photos.
- Résultat attendu : zoom et translation tous deux utilisables et composables ;
  aucun geste à deux doigts ne tourne la page ; le balayage reste disponible à
  chaque retour page 1.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : vidéo des trajectoires.
- Environnement : à renseigner intégralement.

### `IPAD-L1-129` — Sauvegarde au milieu d’un déplacement

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:ELM-007`, `3:SAV-001` à `3:SAV-003`, `3:UND-007`.
- Préconditions : cadre sélectionné et position initiale repérée.
- Étapes : commencer un déplacement, toucher Sauvegarder d’un second doigt,
  continuer légèrement puis relever le premier ; toucher Annuler une fois puis
  Rétablir une fois ; fermer et relancer.
- Résultat attendu : position capturée au toucher Sauvegarder, aucun saut ni
  seconde commande après le relâchement ; Annuler/Rétablir unique et état
  durable après relance.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : vidéo image par image et positions avant/après.
- Environnement : à renseigner intégralement.

### `IPAD-L1-130` — Presse-papiers strictement limité à la session

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:CLP-001` à `3:CLP-006`, `3:UND-012`.
- Préconditions : album A avec cadre rempli et album B actif.
- Étapes : copier dans A et coller sur une autre page de A ; copier de nouveau,
  quitter vers la bibliothèque, ouvrir B puis A et relever Coller ; répéter avec
  un passage en arrière-plan.
- Résultat attendu : collage intrasession dans A réussi ; Coller désactivé dans
  B et toujours désactivé au retour dans A ou après arrière-plan, sans
  réactivation d’un ancien payload.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : vidéo des états de Coller.
- Environnement : à renseigner intégralement.

### `IPAD-L1-131` — Commandes rapides après correction des transitions d’interface

- Candidat : **À figer après validation WSL du correctif**.
- Exigences : `3:ALB-006`, `3:APP-002`, `3:APP-005`, `3:EDT-021`,
  `3:LOC-011` à `3:LOC-014`, `3:UND-011`.
- Préconditions : album A de trois pages avec photos et fonds distincts ;
  bibliothèque prête à créer un album B.
- Étapes : dans A, déclencher rapidement Ajouter une page, changer de fond,
  Annuler puis Rétablir depuis le nouvel inspecteur ; revenir à la bibliothèque,
  créer B, attendre son ouverture automatique, revenir immédiatement aux albums
  puis rouvrir A ; renommer enfin A tout en enchaînant Annuler/Rétablir selon les
  états activés, fermer et relancer.
- Résultat attendu : chaque commande acceptée est exécutée une fois dans son
  ordre durable, sans `staleRevision`, perte ni écrasement ; aucun chevauchement
  de feuille et d’éditeur ne bloque Retour ; fonds, nombre de pages et nom final
  correspondent aux commandes observées après relance.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : vidéo continue, ordre des états activés, nom, fond et nombre final de
  pages avant/après relance.
- Environnement : à renseigner intégralement.

## Qualification différée Apple/macOS/Xcode

Ces contrôles ne valident aucun Lot 2 ou Lot 3. Ils complètent les preuves du
Lot 0/Lot 1 que Swift Playgrounds ou un seul iPad ne peut pas fournir. Ils
restent ⚪ `NON TESTÉ` jusqu’à une campagne séparée visant le même candidat ou
un nouveau candidat explicitement enregistré.

| ID différé | Contrôle | Exigences | État | Motif du report |
|---|---|---|---|---|
| `APPLE-L1-001` | Ouvrir le package sans état local, compiler Debug et Release avec les SDK iOS/iPadOS 26, exécuter tests Core et Apple | `3:ENV-006` à `3:ENV-009`, `3:TST-014` à `3:TST-016` | ⚪ `NON TESTÉ` | Xcode/macOS absent de WSL et non prouvé sur iPad |
| `APPLE-L1-002` | Matrice iPhone portrait/paysage, iPad portrait/paysage, plus anciens appareils compatibles et dernière version système, limitée aux fonctions Lot 1 | `3:TST-003`, `3:TST-008` | ⚪ `NON TESTÉ` | Un seul iPad ne couvre pas la matrice |
| `APPLE-L1-003` | Tests UI automatisés des commandes, états désactivés, focus, gestes et multi-fenêtre | `3:EDT-010`, `3:ZOM-005`, `3:NAV-005`, `3:APP-010` | ⚪ `NON TESTÉ` | Nécessite XCTest/SDK Apple |
| `APPLE-L1-004` | Injections d’interruption à chaque étape du journal, staging, import, restauration et purge future sûre | `3:LOC-004` à `3:LOC-026`, `3:TST-012` | ⚪ `NON TESTÉ` | Interruption déterministe impossible manuellement ; purge physique non exposée au Lot 1 |
| `APPLE-L1-005` | Manque d’espace contrôlé, protection des fichiers, import RAW volumineux et mémoire | `3:LOC-006`, `3:LOC-019`, `3:LOC-020`, `3:SEC-011`, `3:PERF-004` | ⚪ `NON TESTÉ` | Reproduction sûre et mesures nécessitent environnement instrumenté |
| `APPLE-L1-006` | Instruments : mémoire, CPU, énergie, temps de lancement, 100 pages/5 Go et fluidité des transformations | `3:PERF-001` à `3:PERF-009`, `3:ACPT-114` | ⚪ `NON TESTÉ` | Instruments indisponible dans Swift Playgrounds |
| `APPLE-L1-007` | Accessibility Inspector, VoiceOver sur iPhone/iPad, contrastes, filtres de couleur et cibles 44 × 44 pour les fonctions Lot 1 | `3:ACC-001` à `3:ACC-008`, `3:ACC-011` à `3:ACC-017`, `3:ACC-020`, `3:ACC-021` | ⚪ `NON TESTÉ` | Inspection exhaustive et matrice matérielle différées |
| `APPLE-L0-008` | Prototype CloudKit : entitlements, zone privée et comportement local d’erreur, sans publier une fonction Lot 4 | `3:ENV-003`, `3:ARC-004`, `3:ARC-011` | ⚪ `NON TESTÉ` | Configuration CloudKit/signature requise ; fonction publique différée |
| `APPLE-L1-009` | Archive, validation de l’archive et build TestFlight du candidat viable, puis nouvelle campagne distincte | `3:DONE-005`, `3:TST-014`, `3:TST-015` | ⚪ `NON TESTÉ` | À faire seulement après correction des résultats iPad |
| `APPLE-L1-010` | Ressource de fond absente puis copie de secours invalide | `3:BG-008`, `3:ERR-017` | ⚪ `NON TESTÉ` | Nécessite une build de test avec injection de catalogue et vidage contrôlé des caches |
| `APPLE-L1-011` | Échec durable de sauvegarde, Réessayer et tentative de fermeture | `3:SAV-003`, `3:SAV-004`, `3:ERR-014` | ⚪ `NON TESTÉ` | Nécessite une erreur de dépôt déterministe sans remplir dangereusement le disque |
| `APPLE-L1-012` | Preuve réseau qu’aucune photo ne quitte l’app vers un serveur propriétaire | `3:SEC-001`, `3:SEC-010` | ⚪ `NON TESTÉ` | Nécessite capture réseau attribuée au processus et inspection statique |
| `APPLE-L1-013` | Rendu composite et cache de miniature de couverture | `3:COV-007` | ⚪ `NON TESTÉ` | Hits, misses et invalidations du cache ne sont pas observables dans l’interface publique |

### `APPLE-L1-010` — Fond manquant et repli validé

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Type : test Apple instrumenté avec catalogue et stockage injectables ; aucun
  crochet de test ne doit être compilé dans la version publique.
- Exigences : `3:BG-008`, `3:ERR-017`.
- Préconditions : dans un bac à sable jetable, créer une page utilisant un
  motif intégré non par défaut et vérifier que sa copie de secours a été
  validée et enregistrée. Mémoriser l’identifiant/version d’origine et le hash
  du rendu de référence ; désactiver ou vider le cache de rendu avant chaque
  sous-cas.
- Étapes :
  1. injecter un catalogue courant où la ressource d’origine est absente mais
     conserver sa copie de secours valide ; relancer et rendre la page dans
     éditeur, Vue globale et Prévisualiser ;
  2. vérifier que les trois sorties utilisent la copie de secours et produisent
     le hash de rendu attendu sans remplacer l’identifiant enregistré ;
  3. dans une nouvelle copie du bac à sable initial, rendre également absente
     ou invalide la copie de secours ; relancer ;
  4. vérifier le fond par défaut provisoire dans les trois sorties, la
     conservation de l’identifiant/version d’origine dans le diagnostic et
     l’état interne bloquant une sortie documentaire future ;
  5. rétablir catalogue et secours, relancer et vérifier que le fond d’origine
     réapparaît sans migration destructive du document.
- Résultat attendu : ressource bundle absente = secours validé fidèle ; bundle
  et secours invalides = fond par défaut seulement provisoire, diagnostic
  conservé et aucune réécriture silencieuse de la référence. La commande
  Exporter reste non publique au Lot 1 ; son blocage est vérifié par l’état
  instrumenté, puis sera rejoué par l’UI au Lot 3.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — logs structurés, hashes des rendus, référence
  persistée avant/après et capture des trois vues.
- Environnement : à renseigner — macOS, Xcode, SDK, simulateur/appareil et
  configuration exacte de l’injection.

### `APPLE-L1-011` — Échec de sauvegarde, Réessayer et fermeture

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Type : test Apple avec dépôt/journal injecté en échec déterministe.
- Exigences : `3:SAV-003`, `3:SAV-004`, `3:ERR-014`.
- Préconditions : album possédant un snapshot durable A et un hash canonique
  connu ; le double de test peut faire échouer précisément journal, consolidation
  ou flush puis rétablir les écritures sans simuler un disque réellement plein.
- Étapes :
  1. modifier le document vers B, injecter l’échec au prochain flush et toucher
     Sauvegarder ;
  2. vérifier l’état visible « Échec de sauvegarde », l’action Réessayer et la
     conservation de la commande B dans le journal récupérable ;
  3. toucher Réessayer pendant que l’échec persiste et vérifier qu’A n’est ni
     remplacé ni corrompu et que l’erreur reste actionnable ;
  4. tenter de revenir à la bibliothèque ; vérifier un avertissement explicite
     de fermeture pendant échec, puis choisir de rester dans l’éditeur ;
  5. rétablir les écritures et toucher Réessayer ; attendre « Enregistré » avec
     l’heure, fermer normalement et relancer ;
  6. vérifier que le document B et son hash canonique sont durables, sans état
     partiel ni disparition du dernier snapshot valide.
- Résultat attendu : l’échec est visible, le journal récupérable est conservé,
  Réessayer ne duplique aucune commande, fermer avertit tant que l’échec dure,
  A reste intact jusqu’au succès et B devient le nouveau snapshot seulement
  après flush réussi.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — vidéo UI, chronologie des points d’injection, hashes
  A/B, contenu du journal et assertions du double de dépôt.
- Environnement : à renseigner.

### `APPLE-L1-012` — Preuve réseau de confidentialité des photos

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Type : capture réseau sur appareil/simulateur et inspection statique du
  binaire/configuration du candidat.
- Exigences : `3:SEC-001`, `3:SEC-010`.
- Préconditions : utiliser les fixtures non personnelles, réseau actif, capture
  capable d’attribuer les connexions au processus de l’app ; séparer le trafic
  système éventuel du sélecteur Photos du trafic émis par l’application.
- Étapes :
  1. démarrer la capture avant lancement, puis importer depuis Fichiers les
     fixtures petite, moyenne et grande ;
  2. placer, recadrer, dupliquer, générer miniatures/couvertures, sauvegarder,
     fermer et relancer ;
  3. répéter avec une photo déjà téléchargée choisie via PhotosPicker, en
     distinguant l’activité du service système ;
  4. inspecter domaines, adresses, méthodes, tailles et corps attribués au
     processus ; rechercher les signatures binaires et hashes des fixtures dans
     toute requête sortante ;
  5. inspecter le binaire, les dépendances et la configuration pour tout SDK
     d’analyse ou endpoint propriétaire non décidé.
- Résultat attendu : aucune donnée photo, dérivé, miniature ni extrait d’album
  n’est envoyé par l’app vers un serveur propriétaire ; aucun SDK d’analyse
  comportementale ni endpoint implicite n’est présent. Un trafic Apple du
  sélecteur système doit être isolé et ne constitue pas une preuve d’envoi par
  le processus.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — fichier de capture, filtre par processus, inventaire
  des destinations, recherche de signatures et rapport d’inspection statique.
- Environnement : à renseigner — outil/proxy, OS, appareil, build et réseau.

### `APPLE-L1-013` — Rendu composite et cache de couverture

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Type : test du moteur de rendu avec compteur injecté de compositions et
  métriques explicites de hit/miss/invalidation du cache.
- Exigences : `3:COV-007`.
- Préconditions : album à quatre pages conforme à `IPAD-L1-074` ; couverture
  manuelle sur une occurrence laissant voir le fond, avec cadrage et rotation
  reconnaissables ; taille de miniature et échelle fixées.
- Étapes :
  1. demander la miniature une première fois et vérifier un miss suivi d’une
     seule composition par le moteur commun de page ;
  2. comparer son image au rendu de page de référence recadré au centre à la
     taille demandée ;
  3. redemander plusieurs fois la même clé logique, taille et échelle ; vérifier
     des hits sans nouvelle composition ;
  4. modifier successivement le cadrage de l’occurrence cible, puis le fond de
     sa page et enfin choisir une autre occurrence ; après chaque mutation,
     vérifier l’invalidation concernée, une seule recomposition et un nouveau
     rendu fidèle ;
  5. redemander chaque nouvel état inchangé et vérifier de nouveaux hits ;
  6. modifier un autre album et vérifier que l’entrée de couverture test n’est
     pas invalidée globalement.
- Résultat attendu : miniature produite par le moteur commun, recadrage centré
  exact, réutilisation du composite inchangé, invalidation sur chaque donnée
  visuelle de la couverture et absence d’invalidation par une mutation sans
  rapport.
- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — images de référence, hashes, clés anonymisées et
  compteurs hit/miss/composition/invalidation.
- Environnement : à renseigner.

Les documents `.photoalbum`, la lecture, le diaporama, l’animation finale,
l’export et le PDF ne figurent pas dans cette qualification Lot 1 : ils seront
testés avec de nouveaux identifiants lors du Lot 3. Les modèles, le dé, Auto,
le texte, les stickers, formes et cadres décoratifs recevront leurs propres
identifiants lors du Lot 2.

## Résultats de session

| ID exécuté | Date/heure | Résultat observé | Preuve | Anomalie liée | Appareil / OS / Playgrounds |
|---|---|---|---|---|---|
| `IPAD-L1-063…093` | 16 août 2026 | 31 fiches retranscrites individuellement ci-dessus : 18 réussies, 8 échouées, 4 bloquées et 1 non applicable | Réponses et observations consignées dans chaque fiche ; aucune réussite extrapolée | Correctif regroupé et régressions `109…131` | iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` |

## Règle de clôture

La campagne ne permet de déclarer une fiche réussie que si toutes ses étapes
ont été exécutées sur le commit et l’environnement inscrits. Une compilation
WSL du Core ne valide pas SwiftUI/iOS ; un test iPad ne valide pas iPhone,
Xcode, Release, TestFlight, Instruments ni une sortie de Lot 2/3. Toute
anomalie corrigée impose un nouveau commit et, lorsque la preuve antérieure ne
s’applique plus, un nouvel identifiant de régression.
