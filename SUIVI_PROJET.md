# Suivi du projet Album Photo

Ce document est le tableau de bord opérationnel du projet. Il complète la
spécification normative [`spec.md`](spec.md) et le guide de développement
[`README.md`](README.md).

Il doit être mis à jour dans le même changement que toute modification du
dépôt, conformément à [`AGENTS.md`](AGENTS.md).

## Fiche projet

| Information | Valeur |
|---|---|
| Produit | Album Photo |
| Dépôt | [gabrielmessika/album_photo](https://github.com/gabrielmessika/album_photo) |
| Branche d’intégration | `main` |
| Spécification | Version 2.1 du 27 juillet 2026 |
| Plateformes | iPhone et iPad |
| Version minimale | iOS 26 et iPadOS 26 |
| Technologies | Swift, SwiftUI et frameworks Apple publics |
| Architecture directrice | Locale d’abord, non destructive, portable et résiliente |
| Environnement principal | Windows 11, VS Code et WSL 2 |
| Build Apple | Phase A sur Swift Playgrounds/iPad ; qualification Xcode/macOS ponctuelle en phase B |
| Distribution | App Store Connect et TestFlight |
| Version publique visée en premier | `1.0` |
| Phase courante | Lot 1 démarré par un incrément `ACPT-100` ; sorties du lot 0 encore incomplètes |
| Dernière mise à jour | 28 juillet 2026 |
| Dernier auteur du suivi | Codex |

## Légende des états

| Symbole | État | Utilisation |
|---|---|---|
| ⬜ | Non commencé | Aucun travail vérifiable n’a débuté |
| 🟡 | En cours | Travail partiel ou validation engagée |
| 🟠 | Bloqué ou à risque | Une décision, une capacité ou une ressource manque |
| 🟢 | Terminé | Critères remplis et preuve enregistrée |
| ⏸️ | Différé | Travail volontairement reporté à une version ultérieure |

Une tâche ne passe à 🟢 que lorsque son implémentation, ses tests applicables et
sa documentation sont terminés. Une implémentation non testée reste 🟡.

## Synthèse d’avancement

| Périmètre | État | Avancement constaté | Prochaine condition |
|---|---|---|---|
| Préparation et documentation | 🟡 En cours | Spécification, README, suivi et squelette App Playground compilé sur iPad | Relever les versions exactes de l’environnement iPad |
| Lot 0 — Prototypes et contrats | 🟡 En cours | Frontière de domaine et premier modèle testable créés ; prototypes à compléter | Valider l’architecture sur iPad et traiter les autres sorties |
| Lot 1 — Création locale | 🟡 En cours | Régression générale iPad réussie ; renommage et corbeille échoués à cause du cycle de vie des dialogues, correctif local à revalider | Exécuter `IPAD-L1-010` à `IPAD-L1-012` |
| Lot 2 — Création enrichie | ⬜ Non commencé | 0 scénario d’acceptation validé | Terminer le lot 1 |
| Lot 3 — Consultation et documents | ⬜ Non commencé | 0 scénario d’acceptation validé | Terminer le lot 2 |
| Qualité et publication `1.0` | ⬜ Non commencé | Aucune build | Lots 0 à 3 terminés |
| Lot 4 — Historique et CloudKit | ⬜ Non commencé | 0 scénario d’acceptation validé | Version 1.0 et faisabilité CloudKit |
| Qualité et publication `1.1` | ⬜ Non commencé | Aucune build | Lot 4 terminé et CloudKit signable |
| Lot 5 — Google Photos | ⬜ Non commencé | 0 scénario d’acceptation validé | Version 1.1 et faisabilité OAuth |
| Qualité et publication `1.2` | ⬜ Non commencé | Aucune build | Lot 5 terminé |

**Avancement fonctionnel global : 0 %.** Aucun scénario d’acceptation de
`ACPT-100` à `ACPT-122` n’est encore validé.

Ce pourcentage mesure uniquement les fonctionnalités livrables. Il n’intègre
pas la rédaction préalable de la spécification ou de la documentation.

## Feuille de route des versions

| Version | Lots requis | Périmètre | État | Build | Publication |
|---|---|---|---|---|---|
| `1.0` | Lots 0 à 3 + qualité | Création locale, médias, commentaires de base, stickers, lecture, diaporama, PDF et `.photoalbum` | ⬜ | — | — |
| `1.1` | Hérite de `1.0` + lot 4 + qualité | Tableaux, listes de contrôle, historique et CloudKit | ⬜ | — | — |
| `1.2` | Hérite de `1.1` + lot 5 + qualité | Google Sign-In et Google Photos Picker | ⬜ | — | — |

## Phase de préparation

| Tâche | État | Preuve ou résultat | Action suivante |
|---|---|---|---|
| Spécification fonctionnelle et technique 2.1 | 🟢 | [`spec.md`](spec.md), sections 2.8, 30.5 et 30.6 | Garder les identifiants normatifs stables |
| Guide du flux Windows/WSL/GitHub/iPad | 🟢 | [`README.md`](README.md), scénario en deux phases | Le réviser après le premier test réel |
| Checklist iPad et registre des validations différées | 🟢 | `TST-009` à `TST-016`, [`suivi_tests.md`](suivi_tests.md) et registre ci-dessous | Ajouter les tests de chaque campagne groupée |
| Tableau de suivi du projet | 🟢 | Ce document | Le maintenir à chaque changement |
| Instructions de travail pour Codex | 🟢 | [`AGENTS.md`](AGENTS.md) | Vérifier leur application à chaque tâche |
| Licence du dépôt | ⬜ | Aucun fichier `LICENSE` | Choisir la licence ou confirmer le caractère privé |
| Bundle ID définitif | ⬜ | Placeholder uniquement dans le README | Choisir et réserver l’identifiant |
| Adhésion Apple Developer | ⬜ | Non vérifiée | Confirmer l’équipe et les contrats |
| App Store Connect record | ⬜ | Non créé ou non vérifié | Créer avant le premier upload |
| iPad et versions logicielles | 🟡 | Un iPad est disponible, versions exactes inconnues | Relever modèle, iPadOS et Swift Playgrounds |
| iPhone de test | 🟠 | Aucun iPhone annoncé | Identifier un testeur TestFlight |
| Working Copy ou méthode ZIP | ⬜ | Deux procédures documentées | Choisir la méthode quotidienne |
| Politique de confidentialité | ⬜ | Absente | Préparer une URL stable avant publication |

## Lot 0 — Prototypes et contrats

Objectif : prouver les risques techniques avant de développer le produit.

| Tâche | État | Exigences ou sortie | Preuve attendue |
|---|---|---|---|
| Créer l’App Playground universel | 🟡 | `DEC-01`, `LOT-001` | `Albumzh.swiftpm` compilé sur iPad au commit `ec8842a` ; familles et orientations à relever |
| Activer iPhone et iPad, portrait et paysage | ⬜ | `DEC-17`, `TST-003` | Exécution et captures |
| Définir l’organisation des modules | 🟡 | `ARC-001` à `ARC-017` | Noyau partagé et AppModule séparés ; ADR et validation Apple manquants |
| Isoler le domaine testable sous WSL | 🟡 | `ARC-002`, `ARC-003`, `DEV-006` | Package Swift partagé compilé et 12 tests réussis sous Linux |
| Prototyper l’édition riche | ⬜ | `TXT-001` à `TXT-006` | Sélection, collage, brouillon, annulation et sérialisation |
| Prototyper l’animation de page interactive | ⬜ | Section 10 | Démonstration gestes et interruption |
| Définir le modèle du domaine | 🟡 | Section 22 | Premier sous-ensemble Album/Page et invariants de création testés |
| Définir la sérialisation canonique | ⬜ | `DAT-020` à `DAT-028` | Golden files et empreintes stables |
| Prototyper le journal transactionnel | 🟡 | `LOC-011` à `LOC-026` | Journal de création et relance testés ; injection d’interruption à ajouter |
| Créer le schéma `.photoalbum` v1 | ⬜ | `PKG-001` à `PKG-021` | Schéma JSON et corpus d’exemples |
| Valider le type de document sur iPad | 🟠 | `PKG-001`, `PKG-002`, `IMP-001` | Ouverture depuis Fichiers et partage |
| Prototyper CloudKit page par page | 🟠 | `SYN-001` à `SYN-003` | Go/no-go sur entitlements et conteneur |
| Vérifier la faisabilité OAuth Google | 🟠 | `CFG-001` à `CFG-003`, lot 5 | Go/no-go sur le schéma de retour |
| Créer la matrice de traçabilité initiale | 🟡 | `TST-001` | Premier registre exigences–tests manuels dans `suivi_tests.md` ; matrice exhaustive à créer |
| Enregistrer les décisions d’architecture | ⬜ | Sortie du lot 0 | ADR datées et approuvées |
| Créer la CI du domaine | ⬜ | Tests unitaires multiplateformes | Workflow GitHub vert |

### Critère de sortie du lot 0

- [ ] Les prototypes prouvent ou réfutent chaque risque principal.
- [ ] Le projet reste compilable et démontrable.
- [ ] Les formats de données sont relus.
- [ ] Les décisions d’architecture sont enregistrées.
- [ ] Les blocages Swift Playgrounds ont un plan de repli décidé.
- [ ] La matrice de traçabilité existe.
- [ ] La première fiche iPad et le registre des validations différées sont renseignés.

## Lot 1 — Création locale

Objectif : rendre possible la création locale et durable d’albums.

| Tâche | État | Scénarios principaux |
|---|---|---|
| Bibliothèque des albums | 🟡 | `ACPT-100` — grille, création, ouverture et relance validées sur iPad ; libellé du mode édition ajouté et à revalider |
| Création et renommage | 🟡 | `ACPT-100`, `ALB-007`, `ALB-021`, `UND-011` — renommage échoué sur iPad dans `IPAD-L1-007` ; correctif du dialogue à revalider |
| Corbeille et restauration des albums | 🟡 | `ACPT-102` — mise en corbeille échouée et restauration bloquée ; alerte corrigée, suppression définitive et expiration non commencées |
| Pages : ajout, suppression et réorganisation | 🟡 | `PAG-001`, `PAG-002` — ajout et persistance validés sous Linux et sur iPad ; suppression et réorganisation non commencées |
| Fonds d’album | 🟡 | `ALB-014`, `BG-002`, `BG-003`, `BG-007`, `BG-008`, `BG-010` — identifiant normatif et rendu à spirales ajoutés ; validation iPad requise |
| Couverture automatique et manuelle | ⬜ | `ACPT-103` |
| Dépôt d’assets adressé par contenu | ⬜ | Section 18 |
| Journal local transactionnel | 🟡 | `ACPT-100`, `ACPT-114` — premier journal JSON rejouable ; campagne d’interruption manquante |
| Import de photos avec PhotosPicker | ⬜ | `ACPT-106` |
| Import et lecture des vidéos | ⬜ | `ACPT-106`, `ACPT-110` |
| Normalisation des formats média | ⬜ | `ACPT-106` |
| Cadrage non destructif | ⬜ | `ACPT-105` |
| Hauteur du commentaire | ⬜ | `ACPT-105` |
| Affichage simple et double page | ⬜ | `ACPT-109` |
| Navigation boutons et gestes | ⬜ | `ACPT-109` |
| Annulation et rétablissement de session | ⬜ | `ACPT-104` |

### Critère de sortie du lot 1

- [ ] `ACPT-100` passe.
- [ ] `ACPT-102` à `ACPT-106` passent.
- [ ] Les commandes validées survivent à une relance.
- [ ] Le lot reste compilable, testable et démontrable.

## Lot 2 — Création enrichie

Objectif : ajouter les commentaires riches et les stickers.

| Tâche | État | Scénarios principaux |
|---|---|---|
| Modèle persistant du commentaire | ⬜ | Section 12.8 |
| Éditeur enrichi de base | ⬜ | `ACPT-107` |
| Styles de paragraphes et caractères | ⬜ | `ACPT-107` |
| Listes, retraits et alignements | ⬜ | `ACPT-107` |
| Brouillon récupérable | ⬜ | `ACPT-101` |
| Limite de 500 caractères par graphème | ⬜ | `TST-006` |
| Hauteur et débordement | ⬜ | Sections 12.7 et 7.4 |
| Catalogue de stickers intégrés | ⬜ | Section 13 |
| Stickers personnalisés depuis une image | ⬜ | `ACPT-108` |
| Stickers GIF | ⬜ | `ACPT-108` |
| Détourage disponible | ⬜ | Section 13.3 |
| Déplacement, rotation et redimensionnement | ⬜ | Section 13.4 |
| Ordre d’affichage des stickers | ⬜ | `TST-006` |
| Clavier, pointeur et trackpad | ⬜ | `ACPT-115` |

### Critère de sortie du lot 2

- [ ] `ACPT-101` passe.
- [ ] `ACPT-107` passe.
- [ ] `ACPT-108` passe.
- [ ] Les brouillons et commandes validées résistent à une interruption.
- [ ] Le lot reste compilable, testable et démontrable.

## Lot 3 — Consultation et documents

Objectif : terminer le périmètre fonctionnel de la version publique 1.0.

| Tâche | État | Scénarios principaux |
|---|---|---|
| Mode lecture | ⬜ | Sections 14 et 29 |
| Diaporama | ⬜ | `ACPT-110` |
| Animation de page finalisée | ⬜ | `ACPT-109` |
| Export `.photoalbum` | ⬜ | `ACPT-111` |
| Import sécurisé `.photoalbum` | ⬜ | `ACPT-111`, `ACPT-112` |
| Import dégradé avec média absent | ⬜ | `IMP-014` à `IMP-016` |
| Corpus de packages valides et malveillants | ⬜ | `TST-007` |
| Export PDF | ⬜ | `ACPT-113` |
| PDF balisé et accessible | ⬜ | `ACPT-113` |
| Enveloppe de performance 1.0 | ⬜ | `ACPT-114` |
| Accessibilité iPad | ⬜ | `ACPT-115` |

### Critère de sortie du lot 3

- [ ] `ACPT-109` à `ACPT-115` passent.
- [ ] Le format `.photoalbum` v1 est documenté publiquement.
- [ ] Les imports hostiles sont rejetés sans écriture durable.
- [ ] Après le lot Qualité, le produit est candidat à la version 1.0.

## Lot 4 — Commentaires avancés, historique et CloudKit

Objectif : produire la version publique 1.1.

| Tâche | État | Scénarios principaux |
|---|---|---|
| Listes de contrôle | ⬜ | `ACPT-116` |
| Tableaux | ⬜ | `ACPT-116` |
| Révisions persistantes | ⬜ | `ACPT-117` |
| Restauration et purge à 50 révisions | ⬜ | `ACPT-117` |
| Zone CloudKit `AlbumZone` | 🟠 | `SYN-003` |
| Records CloudKit granulaires | 🟠 | Section 19.1.1 |
| File de synchronisation locale d’abord | 🟠 | `SYN-001` |
| Fusion de pages distinctes | ⬜ | `ACPT-118` |
| Conflits sur une même page | ⬜ | `ACPT-119` |
| Changement de compte et mode hors ligne | ⬜ | `ACPT-120` |
| Corbeille synchronisée | ⬜ | `ACPT-121` |
| Téléchargement des médias à la demande | ⬜ | Section 19 |

### Critère de sortie du lot 4

- [ ] La capacité CloudKit est disponible dans la chaîne de signature retenue.
- [ ] `ACPT-116` à `ACPT-121` passent.
- [ ] Les conflits conservent toutes les branches.
- [ ] Après le lot Qualité, le produit est candidat à la version 1.1.

## Lot 5 — Google Photos

Objectif : produire la version publique 1.2.

| Tâche | État | Scénarios principaux |
|---|---|---|
| Configuration OAuth par environnement | 🟠 | `CFG-001` à `CFG-006` |
| Google Sign-In | ⬜ | `ACPT-122` |
| Création d’une session Picker | ⬜ | Section 11.3 |
| Sélection unique `maxItemCount = 1` | ⬜ | `DEC-10` |
| Import d’une photo | ⬜ | `ACPT-122` |
| Import d’une vidéo | ⬜ | `ACPT-122` |
| Reprise d’un téléchargement interrompu | ⬜ | `ACPT-122` |
| Expiration de session | ⬜ | `ERR-006` |
| Déconnexion sans perte des médias | ⬜ | `ERR-007` |
| Documentation sans secret embarqué | ⬜ | `DEL-001` |

### Critère de sortie du lot 5

- [ ] Le retour OAuth fonctionne avec une build signée.
- [ ] `ACPT-122` passe.
- [ ] Les médias déjà importés restent disponibles hors ligne.
- [ ] Après le lot Qualité, le produit est candidat à la version 1.2.

## Lot 6 — Qualité et publication

Ce lot est répété avant chaque version publique.

| Chantier | État `1.0` | État `1.1` | État `1.2` | Preuve attendue |
|---|---|---|---|---|
| Tests unitaires | ⬜ | ⬜ | ⬜ | Rapport de suite |
| Tests d’intégration | ⬜ | ⬜ | ⬜ | Rapport et corpus |
| Tests d’interface | ⬜ | ⬜ | ⬜ | Rapport ou procédures manuelles |
| Tests iPhone | 🟠 | 🟠 | 🟠 | Résultats TestFlight |
| Tests iPad | ⬜ | ⬜ | ⬜ | Résultats appareil réel |
| Accessibilité et VoiceOver | ⬜ | ⬜ | ⬜ | Procédure et preuves |
| PDF balisé | ⬜ | ⬜ | ⬜ | Inspection d’accessibilité |
| Localisation française et anglaise | ⬜ | ⬜ | ⬜ | Revue des libellés |
| Performance et charge | ⬜ | ⬜ | ⬜ | Mesures sur enveloppe garantie |
| Migrations | ⬜ | ⬜ | ⬜ | Fixtures d’anciennes versions |
| Sécurité des packages | ⬜ | ⬜ | ⬜ | Corpus hostile et résultats |
| Reprise après interruption | ⬜ | ⬜ | ⬜ | Injection à chaque étape |
| Confidentialité | ⬜ | ⬜ | ⬜ | Politique et déclaration App Store |
| Matrice de traçabilité | ⬜ | ⬜ | ⬜ | Couverture de toutes les exigences |
| Limitations connues | ⬜ | ⬜ | ⬜ | Document de release |
| Build TestFlight | ⬜ | ⬜ | ⬜ | Numéro et hash Git |
| Qualification macOS/Xcode ponctuelle | ⏸️ | ⏸️ | ⏸️ | Rapports `TST-014`, environnement et commit exacts |
| Validation App Review | ⬜ | ⬜ | ⬜ | Statut App Store Connect |

## Chantiers transverses

| Chantier | État | Référence | Remarque |
|---|---|---|---|
| Architecture et injection | 🟡 | Section 23 | Vue → ViewModel → service injecté → dépôt actor pour le premier incrément |
| Persistance locale | 🟡 | Section 18 | Snapshot atomique et journal rejouable pour la création ; périmètre incomplet |
| Gestion des assets | ⬜ | Sections 18 et 22.8 | SHA-256 et déduplication |
| Sécurité des imports | ⬜ | Section 20.5 | Validation avant staging |
| Confidentialité | ⬜ | Section 25 | Aucun secret ni média personnel dans Git |
| Accessibilité | ⬜ | Section 26 | À intégrer dès chaque composant |
| Performance | ⬜ | Section 27 | Mesurer, ne pas supposer |
| Localisation | ⬜ | Section 28 | Français et anglais |
| Documentation d’architecture | ⬜ | `DEL-001` | ADR et README technique |
| Traçabilité | 🟡 | `TST-001` | Registre manuel initial dans `suivi_tests.md` ; couverture exhaustive à créer |
| CI Linux | ⬜ | Tests du domaine | Ne couvre pas les SDK Apple |
| CI ou build macOS | ⏸️ | `ENV-006`, `TST-014` | Différée jusqu’à une version viable sur iPad, obligatoire avant publication |

## Livrables

| Livrable attendu par `DEL-001` | État | Emplacement ou action |
|---|---|---|
| Projet compilable | 🟡 | Noyau compilé sous Linux et App Playground compilé sur iPad au commit `ec8842a` ; nouvel incrément à revalider |
| Application iPhone et iPad | 🟡 | Bibliothèque et premier éditeur validés partiellement sur iPad ; iPhone non testé |
| Code Swift formaté | 🟡 | Premier incrément Swift présent ; contrôle de format automatisé absent |
| Tests unitaires, intégration et interface | 🟡 | 12 tests Linux réussis ; iPad : `006` réussi, `007`–`008` échoués, `009` bloqué, régressions `010`–`012` à exécuter |
| Assets de démonstration libres de droits | ⬜ | À sourcer et documenter |
| Schéma CloudKit documenté | ⬜ | Lot 4 |
| Configuration Google sans secret | ⬜ | Lot 5 |
| README d’installation | 🟢 | [`README.md`](README.md) |
| README d’architecture | ⬜ | À créer après les ADR du lot 0 |
| Format `.photoalbum` documenté | ⬜ | Lot 0 puis lot 3 |
| Stratégie de migration | ⬜ | À définir au lot 0 |
| Liste des limitations connues | 🟡 | Limites initiales dans le README, document de release absent |
| Données d’exemple | ⬜ | À créer |
| Matrice de traçabilité | ⬜ | À créer au lot 0 |
| Corpus de packages | ⬜ | À créer aux lots 0 et 3 |
| Décisions d’architecture | ⬜ | À créer au lot 0 |

## Registre des risques et blocages

| ID | Risque ou blocage | Probabilité | Impact | État | Réponse prévue |
|---|---|---|---|---|---|
| `RSK-001` | CloudKit n’est pas exposé parmi les capacités Swift Playgrounds actuelles | Élevée | Critique pour `1.1` | 🟠 | Tenter le prototype iPad, enregistrer le blocage puis qualifier avec Xcode en phase B |
| `RSK-002` | Le type de document package `.photoalbum` n’est pas déclarable entièrement | Moyenne | Critique pour `1.0` | 🟠 | Prototype d’ouverture, export et import au lot 0 |
| `RSK-003` | Le retour OAuth Google exige une configuration absente de Swift Playgrounds | Moyenne | Critique pour `1.2` | 🟠 | Prototype signé et décision de chaîne de build |
| `RSK-004` | Aucun iPhone physique n’est disponible pour les tests | Élevée | Élevé | 🟠 | Recruter un testeur TestFlight avant la release `1.0` |
| `RSK-005` | WSL ne compile pas SwiftUI ni les frameworks Apple | Certain | Moyen | Accepté | Isoler le domaine ; compiler l’app sur iPad ou macOS |
| `RSK-006` | Swift Playgrounds ne couvre pas toute l’automatisation demandée par la spécification | Élevée | Élevé | 🟠 | Tenir le registre différé puis exécuter une campagne macOS/Xcode groupée |
| `RSK-007` | Les copies PC et iPad divergent | Moyenne | Élevé | Surveillé | GitHub source de vérité, pas d’édition parallèle |
| `RSK-008` | Volumes média de 5 Go difficiles à tester et transférer | Moyenne | Élevé | ⬜ | Corpus dédié, espace réservé et tests de charge progressifs |
| `RSK-009` | Perte ou corruption pendant une commande | Moyenne | Critique | ⬜ | Journal transactionnel et injection d’interruption dès le lot 0 |
| `RSK-010` | Dépendances ou assets non libres | Moyenne | Élevé | ⬜ | Revue de licence avant intégration |
| `RSK-011` | Une validation est oubliée entre deux sessions de vacances | Élevée | Élevé | Surveillé | Fiche iPad obligatoire, cinq états explicites et registre différé cumulatif |
| `RSK-012` | La première ouverture tardive dans Xcode révèle un écart d’architecture ou de configuration | Moyenne | Élevé | Surveillé | Versionner les réglages, isoler les services Apple et réserver la phase B dès le premier candidat viable |

## Décisions de projet

Les décisions d’architecture détaillées devront être créées dans
`docs/decisions/`.

| ID | Date | Décision | Statut |
|---|---|---|---|
| `ADR-PROJ-001` | 2026-07-27 | GitHub est l’unique source de vérité du code | Acceptée |
| `ADR-PROJ-002` | 2026-07-27 | Le développement principal se fait dans VS Code sous WSL | Acceptée |
| `ADR-PROJ-003` | 2026-07-27 | L’iPad et Swift Playgrounds sont la chaîne Apple temporaire de build et de validation manuelle des premières versions | Acceptée pour la phase A |
| `ADR-PROJ-004` | 2026-07-27 | Aucun contournement par API privée n’est autorisé | Acceptée |
| `ADR-PROJ-005` | 2026-07-27 | L’accès macOS/Xcode est différé jusqu’à une version viable sur iPad, puis utilisé ponctuellement pour la qualification obligatoire avant publication | Acceptée |
| `ADR-PROJ-006` | 2026-07-27 | Aucun abonnement ou location continue de Mac n’est requis pendant la phase A | Acceptée |

## Environnements et accès

Ne jamais inscrire de secret, token, identifiant privé ou mot de passe dans ce
tableau.

| Élément | Développement | Production | État |
|---|---|---|---|
| Dépôt GitHub | Public, branche `main` | Tags de release | 🟢 |
| WSL 2 et VS Code | Développement effectué sous WSL ; version de VS Code non relevée | Sans objet | 🟡 |
| Swift Linux | Swift 6.3.3 vérifié | Sans objet | 🟢 |
| Swift Playgrounds | Version à relever | Version stable validée | 🟡 |
| Bundle ID | À choisir | À réserver | ⬜ |
| Équipe Apple | À confirmer | Adhésion active requise | ⬜ |
| Conteneur CloudKit | Développement distinct | Production distincte | 🟠 |
| OAuth Google | Client de développement | Client de production | 🟠 |
| App Store Connect | Record à créer | Contrats et métadonnées | ⬜ |
| TestFlight | Groupes à créer | Build candidate | ⬜ |

## Historique des builds et validations

| Date | Version | Build | Commit | Environnement | Résultat | Preuve |
|---|---|---|---|---|---|---|
| 2026-07-28 | Groupe bibliothèque Lot 1 | — | `35c9f12` | iPad, versions appareil/iPadOS/Swift Playgrounds non communiquées | ÉCHOUÉ — compilation et régression réussies ; renommage non appliqué, corbeille vide, restauration bloquée | `IPAD-L1-006` à `IPAD-L1-009` |
| 2026-07-28 | Correctif visuel Lot 1 | — | `9a35365` | iPad, versions appareil/iPadOS/Swift Playgrounds non communiquées | RÉUSSI avec preuve globale — fond et mode édition jugés améliorés | Retour utilisateur « c’est mieux maintenant » ; limites détaillées dans `IPAD-L1-004` et `IPAD-L1-005` |
| 2026-07-28 | Incrément pages Lot 1 | — | Copie iPad de la branche, commit non communiqué | iPad, versions appareil/iPadOS/Swift Playgrounds non communiquées | ÉCHOUÉ — album et pages persistent, mais fond à spirales absent et mode édition non identifiable | Compte rendu utilisateur du 28 juillet 2026 ; correctif local à revalider |
| 2026-07-28 | Incrément création Lot 1 | — | `ec8842a` | iPad, versions appareil/iPadOS/Swift Playgrounds non communiquées | RÉUSSI — compilation, création d’un album, fermeture et relance avec album retrouvé | Compte rendu utilisateur du 28 juillet 2026 |
| 2026-07-28 | Noyau Lot 1 | — | Branche `feature/lot1-creation-locale` | WSL, Swift 6.3.3, x86_64 Linux | RÉUSSI — 8 tests ; ne valide pas l’app iOS | Sortie `swift test` |

## Registre des validations différées

Ce registre accumule les contrôles impossibles pendant la phase A. Une ligne
ne passe à 🟢 qu’avec une preuve sur le commit candidat ; une nouvelle ligne
doit être ajoutée dès qu’un test iPad reçoit l’état `BLOQUÉ`.

| ID | Validation à reprendre | Déclencheur | État | Preuve ou résultat |
|---|---|---|---|---|
| `VAL-DIF-001` | Ouvrir le package dans Xcode et compiler Debug/Release | Première version viable sur iPad | ⏸️ | Environnement macOS non encore réservé |
| `VAL-DIF-002` | Exécuter les tests unitaires, d’intégration et d’interface Apple | Campagne Xcode | ⏸️ | Aucun projet ni test à ce jour |
| `VAL-DIF-003` | Exécuter la matrice de simulateurs iPhone/iPad de `TST-003` | Campagne Xcode | ⏸️ | Indisponible sur iPad seul |
| `VAL-DIF-004` | Tester la build TestFlight sur un iPhone physique compatible | Candidat `1.0` | 🟠 | Testeur iPhone à identifier |
| `VAL-DIF-005` | Valider signature, entitlements, `.photoalbum`, CloudKit et OAuth applicables | Lots 0, 4 et 5 selon version | ⏸️ | Capacités à prototyper d’abord sur iPad |
| `VAL-DIF-006` | Injecter interruptions, migrations et packages hostiles | Lot Qualité | ⏸️ | Nécessite harnais et tests Apple |
| `VAL-DIF-007` | Mesurer mémoire, CPU, énergie, stockage et lancement dans Instruments | Lot Qualité | ⏸️ | Instruments indisponible sur iPad |
| `VAL-DIF-008` | Inspecter le balisage et l’accessibilité des PDF | Candidat `1.0` | ⏸️ | Inspecteur à sélectionner en phase B |
| `VAL-DIF-009` | Archiver Release, valider l’archive et qualifier la build distribuée | Avant publication | ⏸️ | Aucune build candidate |

## Anomalies actives

| ID | Exigence | Sévérité | État | Description | Lien |
|---|---|---|---|---|---|
| `ANO-001` | `ALB-014`, `BG-002`, `BG-003`, `BG-007`, `BG-010`, `APP-002` | Moyenne | 🟢 Corrigée | L’éditeur iPad ne rendait pas le fond à spirales et n’identifiait pas le mode édition ; correctif jugé meilleur sur iPad, avec limites de preuve consignées | `IPAD-L1-004`, `IPAD-L1-005` |
| `ANO-002` | `ALB-007`, `ALB-021`, `UND-011` | Élevée | 🟡 Correctif à valider | Le dialogue libérait l’album avant l’exécution asynchrone : le nom restait inchangé et la pile demeurait vide | `IPAD-L1-007`, régression `IPAD-L1-010` |
| `ANO-003` | `ALB-008`, `ALB-017` à `ALB-019`, `ACPT-102` | Élevée | 🟡 Correctif à valider | La confirmation libérait l’album avant la commande et le dialogue iPad n’affichait pas Annuler ; alerte explicite et sélection durable ajoutées | `IPAD-L1-008`, régressions `IPAD-L1-011`, `IPAD-L1-012` |

Les risques de faisabilité sont suivis dans le registre `RSK` et ne doivent pas
être transformés en anomalies applicatives avant qu’un prototype les reproduise.

## Prochaines actions prioritaires

1. Exécuter la campagne de régression `IPAD-L1-010` à `IPAD-L1-012` sur le commit
   indiqué dans `suivi_tests.md`.
2. Relever le modèle d’iPad, la version d’iPadOS et la version de Swift
   Playgrounds dans la fiche de validation.
3. Ajouter l’injection d’interruption au journal local.
4. Créer la matrice de traçabilité initiale et l’ADR d’organisation des modules.
5. Commencer `ACPT-102` avec la mise en corbeille et la restauration.
6. Choisir le bundle ID définitif et confirmer l’adhésion Apple Developer.
7. Prototyper la déclaration et l’ouverture du document `.photoalbum`.
8. Prototyper l’éditeur riche défini par `TXT-006`.
9. Enregistrer comme bloquée toute capacité Swift Playgrounds indisponible.
10. Après une première version viable, identifier un iPhone de test et
   réserver une campagne macOS/Xcode ponctuelle.

## Journal des mises à jour

Ajouter une ligne pour chaque changement du dépôt, y compris documentation,
configuration, code, tests ou assets. Les entrées les plus récentes restent en
haut.

| Date | Auteur | Changement | Exigences ou phase | Validation |
|---|---|---|---|---|
| 2026-07-28 | Codex | Enregistrement des résultats `IPAD-L1-006` à `IPAD-L1-009` et correction du cycle de vie des sélections dans les dialogues de renommage et de corbeille ; alerte de suppression avec Annuler explicite | `ALB-007`, `ALB-008`, `ALB-017` à `ALB-019`, `ALB-021`, `UND-011`, `ACPT-102` | `006` RÉUSSI, `007` et `008` ÉCHOUÉS, `009` BLOQUÉ sur iPad ; tests Linux et analyse SwiftUI à reprendre après correctif ; `010` à `012` NON TESTÉS |
| 2026-07-28 | Codex | Groupe bibliothèque : renommage avec Annuler/Rétablir, confirmation de suppression, corbeille locale durable et restauration ; ajout de quatre contrôles iPad | `ALB-007`, `ALB-008`, `ALB-011`, `ALB-017` à `ALB-019`, `ALB-021`, `UND-011`, `ACPT-102`, `APP-005`, `LOC-011` | Commit `35c9f12` ; `swift test` sous WSL/Swift 6.3.3 : 12 tests réussis ; analyse SwiftUI réussie ; campagne `IPAD-L1-006` à `IPAD-L1-009` à exécuter |
| 2026-07-28 | Codex | Ajout de repères colorés aux cinq états et à chaque résultat de `suivi_tests.md`, avec règle correspondante dans `AGENTS.md` | Suivi des campagnes manuelles, sans changement fonctionnel | Relecture du registre et `git diff --check` ; aucun test applicatif requis |
| 2026-07-28 | Codex | Création du registre `suivi_tests.md` avec identifiants stables et adoption de campagnes iPad regroupant plusieurs fonctionnalités ; mise à jour des instructions et du README | `TST-001`, `TST-005`, `TST-009` à `TST-016`, méthode de validation du lot 1 | Relecture croisée de `AGENTS.md`, `README.md`, `SUIVI_PROJET.md` et `suivi_tests.md` ; aucun test applicatif requis pour ce changement documentaire |
| 2026-07-28 | Codex | Correction du rendu absent du fond Album classique et ajout d’un indicateur explicite du mode édition ; normalisation de l’identifiant du thème avec repli visuel pour les anciennes données | `APP-002`, `ALB-014`, `BG-002`, `BG-003`, `BG-007`, `BG-008`, `BG-010`, `ACPT-100` | Persistance des deux pages RÉUSSIE sur iPad d’après l’utilisateur ; correctif analysé syntaxiquement et tests Linux exécutés ; rendu corrigé NON TESTÉ sur iPad |
| 2026-07-28 | Codex | Ajout de l’ouverture d’un album et de la création persistante d’une page après la page active ; enregistrement de la première validation iPad | `ACPT-100`, `ALB-006`, `PAG-001`, `PAG-002`, `APP-005`, `LOC-011` | `swift test` sous WSL/Swift 6.3.3 : 8 tests réussis ; création et relance du commit `ec8842a` réussies sur iPad ; ajout de page NON TESTÉ sur iPad |
| 2026-07-28 | Codex | Démarrage du lot 1 : noyau partagé, modèle Album/Page, création persistante journalisée, bibliothèque SwiftUI et tests | `ACPT-100`, `ALB-001` à `ALB-004`, `ALB-009`, `ALB-011` à `ALB-016`, `APP-001`, `APP-005`, `ARC-001` à `ARC-005`, `LOC-002`, `LOC-004`, `LOC-011`, `DAT-001` à `DAT-004` | `swift test` sous WSL/Swift 6.3.3 : 5 tests réussis ; build et validation iPad/iPhone/macOS NON TESTÉES |
| 2026-07-27 | Codex | Passage de la spécification en 2.1 et formalisation du scénario temporaire iPad, de la checklist manuelle et de la qualification macOS/Xcode différée | `DEV-007` à `DEV-009`, `ENV-001` à `ENV-009`, `TST-009` à `TST-016` | Relecture documentaire et `git diff --check` ; aucun build ni test applicatif, implémentation non commencée |
| 2026-07-27 | Codex | Création et revue du suivi de projet et des instructions `AGENTS.md` ; ajout du lien depuis le README | Préparation | Contrôle des identifiants normatifs et `git diff --check` ; aucun test applicatif, changement documentaire uniquement |
| 2026-07-27 | Codex | Rédaction du guide détaillé Windows/WSL/GitHub/iPad | Préparation, outillage et publication | Relecture documentaire et `git diff --check` |
| 2026-07-27 | Projet | Spécification fonctionnelle et technique 2.0 | Toutes les versions | Document déclaré prêt pour développement |

## Règle de mise à jour

À chaque modification du dépôt :

1. mettre à jour la date et, si nécessaire, la phase courante ;
2. modifier l’état des tâches réellement touchées ;
3. ajouter les preuves de test ou signaler explicitement les tests non exécutés ;
4. enregistrer toute nouvelle décision, anomalie, dépendance ou risque ;
5. réordonner les prochaines actions si la priorité change ;
6. ajouter une entrée concise au journal des mises à jour ;
7. ne jamais déclarer un lot ou une fonctionnalité terminé sans satisfaire
   `DONE-001` à `DONE-005`.
