# Suivi des tests manuels — Album Photo

Ce document est la checklist détaillée des validations réalisées hors des
tests automatisés, en particulier dans Swift Playgrounds sur iPad. Le tableau
de bord général reste [`SUIVI_PROJET.md`](SUIVI_PROJET.md) et les exigences
normatives restent dans [`spec.md`](spec.md).

## Mode d’emploi

Chaque test possède un identifiant unique et immuable. Pour transmettre un
résultat, indiquer l’identifiant suivi de l’état ou du problème observé :

```text
IPAD-L1-003 OK
IPAD-L1-004 BUG : les spirales disparaissent après la relance
```

Codex met alors à jour ce fichier et, en cas d’anomalie, le registre de
`SUIVI_PROJET.md`.

Les seuls états autorisés sont :

| Repère | État | Signification |
|---|---|---|
| 🟢 | `RÉUSSI` | Le résultat attendu a été observé sur l’environnement indiqué |
| 🔴 | `ÉCHOUÉ` | Le test a été exécuté et un écart a été observé |
| 🟠 | `BLOQUÉ` | Une dépendance ou l’environnement empêche l’exécution |
| ⚪ | `NON TESTÉ` | Le test n’a pas encore été exécuté pour le commit indiqué |
| ⚫ | `NON APPLICABLE` | Le test ne concerne pas le périmètre du commit |

Un résultat vaut uniquement pour le commit, l’appareil et les versions
enregistrés. Une modification touchant le comportement peut imposer une
nouvelle ligne de régression avec un nouvel identifiant.

## Environnement iPad connu

| Information | Valeur |
|---|---|
| Appareil | iPad — modèle non communiqué |
| iPadOS | Version non communiquée |
| Swift Playgrounds | Version non communiquée |
| Méthode de transfert | Non communiquée |

## Registre synthétique

| ID | Lot | Objet | Exigences principales | Commit | État |
|---|---|---|---|---|---|
| `IPAD-L1-001` | Lot 1 | Compilation de l’App Playground | `LOT-001`, `ENV-005` | `ec8842a` | 🟢 `RÉUSSI` |
| `IPAD-L1-002` | Lot 1 | Création et persistance d’un album | `ACPT-100`, `ALB-011` à `ALB-016`, `APP-005` | `ec8842a` | 🟢 `RÉUSSI` |
| `IPAD-L1-003` | Lot 1 | Ajout et persistance d’une page | `ACPT-100`, `PAG-001`, `PAG-002`, `APP-005` | `2030d7c` | 🟢 `RÉUSSI` |
| `IPAD-L1-004` | Lot 1 | Rendu du fond Album classique | `ALB-014`, `BG-002`, `BG-003`, `BG-007`, `BG-010` | `9a35365` | 🟢 `RÉUSSI` |
| `IPAD-L1-005` | Lot 1 | Identification du mode édition | `APP-002` | `9a35365` | 🟢 `RÉUSSI` |
| `IPAD-L1-006` | Lot 1 | Compilation et régression du groupe bibliothèque | `LOT-001`, `ACPT-100` | `COMMIT-LOT1-BATCH-ALBUM` | ⚪ `NON TESTÉ` |
| `IPAD-L1-007` | Lot 1 | Renommage, annulation et rétablissement | `ALB-007`, `ALB-011`, `ALB-021`, `UND-011` | `COMMIT-LOT1-BATCH-ALBUM` | ⚪ `NON TESTÉ` |
| `IPAD-L1-008` | Lot 1 | Confirmation et mise en corbeille | `ALB-008`, `ALB-017`, `ALB-019`, `ACPT-102` | `COMMIT-LOT1-BATCH-ALBUM` | ⚪ `NON TESTÉ` |
| `IPAD-L1-009` | Lot 1 | Restauration durable depuis la corbeille | `ALB-018`, `ALB-019`, `ACPT-102` | `COMMIT-LOT1-BATCH-ALBUM` | ⚪ `NON TESTÉ` |

## Détail des tests

### `IPAD-L1-001` — Compilation de l’App Playground

- Préconditions : récupérer le commit `ec8842a` et ouvrir
  `Albumzh.swiftpm` dans Swift Playgrounds.
- Étapes :
  1. lancer la compilation ;
  2. démarrer l’application ;
  3. vérifier que la bibliothèque s’affiche.
- Résultat attendu : aucune erreur de compilation ou de lancement et la
  bibliothèque devient utilisable.
- Résultat : 🟢 `RÉUSSI`, confirmé par l’utilisateur le 28 juillet 2026.
- Limite de preuve : modèle d’iPad et versions logicielles non communiqués.

### `IPAD-L1-002` — Création et persistance d’un album

- Préconditions : application compilée au commit `ec8842a`.
- Étapes :
  1. créer un album nommé « Guatemala » ;
  2. vérifier sa présence dans la bibliothèque ;
  3. fermer complètement l’application ;
  4. relancer l’application.
- Résultat attendu : « Guatemala » réapparaît sans corruption après relance.
- Résultat : 🟢 `RÉUSSI`, confirmé par l’utilisateur le 28 juillet 2026.

### `IPAD-L1-003` — Ajout et persistance d’une page

- Préconditions : récupérer le commit `2030d7c` et disposer de l’album
  « Guatemala ».
- Étapes :
  1. ouvrir l’album ;
  2. sélectionner sa première page ;
  3. toucher « Ajouter une page » ;
  4. vérifier que deux pages numérotées sont visibles ;
  5. fermer complètement puis relancer l’application ;
  6. rouvrir l’album.
- Résultat attendu : les deux pages réapparaissent dans le même ordre.
- Résultat : 🟢 `RÉUSSI`, confirmé par l’utilisateur le 28 juillet 2026.

### `IPAD-L1-004` — Rendu du fond Album classique

- Préconditions : récupérer le commit `9a35365` et ouvrir un album existant.
- Étapes :
  1. observer la première page ;
  2. ajouter une page et observer la seconde ;
  3. fermer complètement puis relancer l’application ;
  4. rouvrir l’album et observer de nouveau les pages.
- Résultat attendu : chaque page affiche le papier de l’Album classique et sa
  reliure à spirales sur le bord gauche, y compris après relance.
- Résultat : 🟢 `RÉUSSI`, retour utilisateur « c’est mieux maintenant » du
  28 juillet 2026.
- Limite de preuve : le détail des quatre étapes n’a pas été fourni séparément.

### `IPAD-L1-005` — Identification du mode édition

- Préconditions : récupérer le commit `9a35365` et ouvrir un album.
- Étapes :
  1. vérifier la présence du libellé « Mode édition » et de l’icône crayon ;
  2. sélectionner une page ;
  3. vérifier que l’action « Ajouter une page » est disponible.
- Résultat attendu : le mode édition est identifiable et permet une
  modification persistante.
- Résultat : 🟢 `RÉUSSI`, retour utilisateur « c’est mieux maintenant » du
  28 juillet 2026.
- Limite de preuve : le détail des trois étapes n’a pas été fourni séparément.

### `IPAD-L1-006` — Compilation et régression du groupe bibliothèque

- Préconditions : récupérer le commit `COMMIT-LOT1-BATCH-ALBUM` et ouvrir
  `Albumzh.swiftpm` dans Swift Playgrounds.
- Étapes :
  1. compiler et lancer l’application ;
  2. vérifier que les albums existants apparaissent ;
  3. ouvrir un album et vérifier ses pages et son fond ;
  4. revenir à la bibliothèque.
- Résultat attendu : aucune erreur de compilation ou de lancement et aucune
  régression visible sur les fonctions précédemment validées.
- Résultat : ⚪ `NON TESTÉ`.

### `IPAD-L1-007` — Renommage, annulation et rétablissement

- Préconditions : disposer dans la bibliothèque d’un album nommé
  « Guatemala ».
- Étapes :
  1. effectuer un appui long sur la carte et choisir « Renommer » ;
  2. saisir « Voyage Guatemala » et valider ;
  3. vérifier le nouveau nom dans la grille ;
  4. utiliser « Annuler le renommage » et vérifier le retour à « Guatemala » ;
  5. utiliser « Rétablir le renommage » et vérifier « Voyage Guatemala » ;
  6. fermer complètement puis relancer l’application.
- Résultat attendu : chaque nom apparaît au moment attendu et
  « Voyage Guatemala » persiste après relance.
- Résultat : ⚪ `NON TESTÉ`.

### `IPAD-L1-008` — Confirmation et mise en corbeille

- Préconditions : disposer de l’album « Voyage Guatemala » avec au moins deux
  pages.
- Étapes :
  1. effectuer un appui long sur sa carte et choisir « Supprimer » ;
  2. vérifier qu’une confirmation explicite apparaît puis annuler ;
  3. vérifier que l’album est toujours dans la bibliothèque ;
  4. recommencer et confirmer « Placer dans la corbeille » ;
  5. vérifier que l’album disparaît de la bibliothèque ;
  6. ouvrir « Corbeille » et vérifier que l’album y apparaît ;
  7. fermer complètement puis relancer l’application et rouvrir la corbeille.
- Résultat attendu : l’annulation ne change rien ; après confirmation l’album
  est absent de la bibliothèque, non modifiable et toujours présent dans la
  corbeille après relance.
- Résultat : ⚪ `NON TESTÉ`.

### `IPAD-L1-009` — Restauration durable depuis la corbeille

- Préconditions : `IPAD-L1-008` terminé avec « Voyage Guatemala » dans la
  corbeille.
- Étapes :
  1. toucher « Restaurer » sur l’album ;
  2. vérifier sa disparition de la corbeille ;
  3. revenir à la bibliothèque et ouvrir l’album ;
  4. vérifier son nom, ses pages et son fond ;
  5. fermer complètement puis relancer l’application ;
  6. vérifier que l’album est toujours dans la bibliothèque et absent de la
  corbeille.
- Résultat attendu : l’album et tout son contenu sont restaurés sans perte et
  le résultat persiste après relance.
- Résultat : ⚪ `NON TESTÉ`.

## Prochaine campagne

Les contrôles suivants recevront de nouveaux identifiants après le prochain
groupe cohérent de fonctionnalités.
