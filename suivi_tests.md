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

## Prochaine campagne

Les tests du prochain groupe de fonctionnalités seront ajoutés ici avec l’état
⚪ `NON TESTÉ`, les étapes exactes et le commit à récupérer avant la prochaine
demande de validation iPad.
