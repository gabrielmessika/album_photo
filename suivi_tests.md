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
| `IPAD-L1-006` | Lot 1 | Compilation et régression du groupe bibliothèque | `LOT-001`, `ACPT-100` | `35c9f12` | 🟢 `RÉUSSI` |
| `IPAD-L1-007` | Lot 1 | Renommage, annulation et rétablissement | `ALB-007`, `ALB-011`, `ALB-021`, `UND-011` | `35c9f12` | 🔴 `ÉCHOUÉ` |
| `IPAD-L1-008` | Lot 1 | Confirmation et mise en corbeille | `ALB-008`, `ALB-017`, `ALB-019`, `ACPT-102` | `35c9f12` | 🔴 `ÉCHOUÉ` |
| `IPAD-L1-009` | Lot 1 | Restauration durable depuis la corbeille | `ALB-018`, `ALB-019`, `ACPT-102` | `35c9f12` | 🟠 `BLOQUÉ` |
| `IPAD-L1-010` | Lot 1 | Régression du renommage corrigé | `ALB-007`, `ALB-011`, `ALB-021`, `UND-011` | `a44a4f1` | 🟢 `RÉUSSI` |
| `IPAD-L1-011` | Lot 1 | Régression de la mise en corbeille corrigée | `ALB-008`, `ALB-017`, `ALB-019`, `ACPT-102` | `a44a4f1` | 🟢 `RÉUSSI` |
| `IPAD-L1-012` | Lot 1 | Restauration après correction | `ALB-018`, `ALB-019`, `ACPT-102` | `a44a4f1` | 🟢 `RÉUSSI` |
| `IPAD-L1-013` | Lot 1 | Compilation et régression du groupe pages | `LOT-001`, `ACPT-100`, `ACPT-102` | `3338b7d` | 🟢 `RÉUSSI` |
| `IPAD-L1-014` | Lot 1 | Suppression et protection des pages | `PAG-006` à `PAG-008`, `PAG-010` | `3338b7d` | 🟢 `RÉUSSI` |
| `IPAD-L1-015` | Lot 1 | Annulation et rétablissement de session | `UND-001` à `UND-004`, `UND-010`, `UND-012` | `3338b7d` | 🟢 `RÉUSSI` |
| `IPAD-L1-016` | Lot 1 | Réorganisation durable des pages | `ACPT-104`, `PAG-003` à `PAG-005`, `PAG-011` | `3338b7d` | 🟢 `RÉUSSI` |
| `IPAD-L1-017` | Lot 1 | Compilation et régression apparence/navigation | `LOT-001` | `e2405c9` | 🟢 `RÉUSSI` |
| `IPAD-L1-018` | Lot 1 | Catalogue des trois fonds | `BG-001` à `BG-004`, `BG-009`, `BG-011` | `e2405c9` | 🔴 `ÉCHOUÉ` |
| `IPAD-L1-019` | Lot 1 | Changement de fond, persistance et annulation | `BG-005` à `BG-008`, `BG-010` | `e2405c9` | 🟢 `RÉUSSI` |
| `IPAD-L1-020` | Lot 1 | Préférence Une/Deux pages | `DSP-001` à `DSP-003` | `e2405c9` | 🟢 `RÉUSSI` |
| `IPAD-L1-021` | Lot 1 | Adaptation à la largeur et groupement | `DSP-004` à `DSP-011` | `e2405c9` | 🟢 `RÉUSSI` |
| `IPAD-L1-022` | Lot 1 | Navigation Précédent/Suivant | `NAV-001` à `NAV-003` | `e2405c9` | 🟢 `RÉUSSI` |
| `IPAD-L1-023` | Lot 1 | Navigation par balayage horizontal | `NAV-004` à `NAV-006` | `e2405c9` | 🔴 `ÉCHOUÉ` |
| `IPAD-L1-024` | Lot 1 | Numéros et identification des pages | `PAG-003`, `DSP-010` | `35e6741` | 🔴 `ÉCHOUÉ` |
| `IPAD-L1-025` | Lot 1 | Reliure classique simple et double page | `BG-002`, `BG-007`, `BG-010` | `35e6741` | 🟢 `RÉUSSI` |
| `IPAD-L1-026` | Lot 1 | Proportions de la miniature classique | `BG-002`, `BG-009` | `16c7a37` | 🔴 `ÉCHOUÉ` |
| `IPAD-L1-027` | Lot 1 | Navigation gestuelle sans retour implicite | `NAV-004` à `NAV-006` | `16c7a37` | 🔴 `ÉCHOUÉ` |
| `IPAD-L1-028` | Lot 1 | Contraste du numéro sur tous les fonds | `PAG-003`, `BG-001` à `BG-004` | `16c7a37` | 🟢 `RÉUSSI` |
| `IPAD-L1-029` | Lot 1 | Miniature classique réellement adaptative | `BG-002`, `BG-009` | `00d7c69` | ⚪ `NON TESTÉ` |
| `IPAD-L1-030` | Lot 1 | Balayage déterministe simple et double page | `NAV-004` à `NAV-006`, `DSP-010` | `00d7c69` | ⚪ `NON TESTÉ` |

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

- Préconditions : récupérer le commit `35c9f12` et ouvrir
  `Albumzh.swiftpm` dans Swift Playgrounds.
- Étapes :
  1. compiler et lancer l’application ;
  2. vérifier que les albums existants apparaissent ;
  3. ouvrir un album et vérifier ses pages et son fond ;
  4. revenir à la bibliothèque.
- Résultat attendu : aucune erreur de compilation ou de lancement et aucune
  régression visible sur les fonctions précédemment validées.
- Résultat : 🟢 `RÉUSSI`, confirmé par l’utilisateur le 28 juillet 2026.

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
- Résultat : 🔴 `ÉCHOUÉ` le 28 juillet 2026.
- Observation : la saisie et la validation fonctionnent, mais le nouveau nom
  n’apparaît pas dans la grille ; Annuler et Rétablir restent désactivés.

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
- Résultat : 🔴 `ÉCHOUÉ` le 28 juillet 2026.
- Observation : l’alerte s’annule en touchant à l’extérieur mais n’affiche pas
  de bouton « Annuler » ; après confirmation l’album reste dans la
  bibliothèque et la corbeille est vide.

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
- Résultat : 🟠 `BLOQUÉ` le 28 juillet 2026, car `IPAD-L1-008` n’a pas placé
  l’album dans la corbeille.

### `IPAD-L1-010` — Régression du renommage corrigé

- Préconditions : récupérer le commit `a44a4f1`, compiler
  l’application et disposer d’un album nommé « Guatemala ».
- Étapes :
  1. renommer l’album en « Voyage Guatemala » ;
  2. vérifier immédiatement le nouveau nom dans la grille ;
  3. utiliser « Annuler le renommage » puis vérifier « Guatemala » ;
  4. utiliser « Rétablir le renommage » puis vérifier « Voyage Guatemala » ;
  5. relancer l’application.
- Résultat attendu : les trois changements de nom apparaissent immédiatement
  et « Voyage Guatemala » persiste après relance.
- Résultat : 🟢 `RÉUSSI`, confirmé par l’utilisateur le 28 juillet 2026.

### `IPAD-L1-011` — Régression de la mise en corbeille corrigée

- Préconditions : disposer de « Voyage Guatemala » dans la bibliothèque.
- Étapes :
  1. choisir « Supprimer » dans le menu contextuel ;
  2. vérifier la présence du bouton « Annuler », le toucher et confirmer que
     l’album reste visible ;
  3. recommencer, confirmer « Placer dans la corbeille » et vérifier que
     l’album disparaît immédiatement ;
  4. ouvrir la corbeille puis relancer l’application.
- Résultat attendu : l’annulation explicite ne modifie rien ; la confirmation
  déplace l’album dans la corbeille où il reste après relance.
- Résultat : 🟢 `RÉUSSI`, confirmé par l’utilisateur le 28 juillet 2026.

### `IPAD-L1-012` — Restauration après correction

- Préconditions : `IPAD-L1-011` réussi avec l’album dans la corbeille.
- Étapes :
  1. restaurer l’album ;
  2. vérifier son retour dans la bibliothèque et son absence de la corbeille ;
  3. ouvrir l’album et vérifier son nom, ses pages et son fond ;
  4. relancer l’application et refaire les vérifications.
- Résultat attendu : l’album complet reste restauré après relance.
- Résultat : 🟢 `RÉUSSI`, confirmé par l’utilisateur le 28 juillet 2026.

### `IPAD-L1-013` — Compilation et régression du groupe pages

- Préconditions : récupérer le commit `3338b7d` et ouvrir
  `Albumzh.swiftpm` dans Swift Playgrounds.
- Étapes :
  1. compiler et lancer l’application ;
  2. vérifier la bibliothèque, le renommage et la corbeille ;
  3. ouvrir un album existant et vérifier ses pages et son fond.
- Résultat attendu : aucune erreur de compilation ou de lancement et aucune
  régression sur les fonctions déjà validées.
- Résultat : 🟢 `RÉUSSI`, confirmé par l’utilisateur le 29 juillet 2026.

### `IPAD-L1-014` — Suppression et protection des pages

- Préconditions : ouvrir un album contenant trois pages.
- Étapes :
  1. sélectionner la page 2 puis toucher « Supprimer la page » ;
  2. vérifier la confirmation et toucher « Annuler » ;
  3. vérifier que les trois pages sont toujours présentes ;
  4. recommencer et confirmer la suppression ;
  5. vérifier que l’ancienne page 3 devient la page active et est renumérotée
     page 2 ;
  6. supprimer une autre page pour n’en conserver qu’une ;
  7. vérifier que « Supprimer la page » est désactivé ;
  8. relancer l’application.
- Résultat attendu : aucune suppression sans confirmation, la page suivante
  devient active, la dernière page est protégée et l’état persiste.
- Résultat : 🟢 `RÉUSSI`, confirmé par l’utilisateur le 29 juillet 2026.

### `IPAD-L1-015` — Annulation et rétablissement de session

- Préconditions : ouvrir un album contenant au moins deux pages.
- Étapes :
  1. vérifier que « Annuler » et « Rétablir » sont initialement désactivés ;
  2. ajouter une page et vérifier que « Annuler » devient actif ;
  3. annuler puis vérifier la disparition de la page ajoutée ;
  4. rétablir puis vérifier son retour ;
  5. annuler de nouveau, effectuer une nouvelle modification et vérifier que
     « Rétablir » redevient désactivé ;
  6. passer l’application en arrière-plan puis revenir ;
  7. vérifier que les deux boutons sont désactivés sans perte des commandes
     déjà validées.
- Résultat attendu : la pile suit les actions de la session, une nouvelle
  branche supprime le rétablissement et l’arrière-plan clôt la pile.
- Résultat : 🟢 `RÉUSSI`, confirmé par l’utilisateur le 29 juillet 2026.

### `IPAD-L1-016` — Réorganisation durable des pages

- Préconditions : disposer exactement de cinq pages.
- Étapes :
  1. ouvrir « Gérer les pages » ;
  2. déplacer la page 5 en deuxième position avec la poignée de déplacement ;
  3. vérifier la renumérotation immédiate puis fermer le gestionnaire ;
  4. sélectionner la deuxième page et la supprimer ;
  5. toucher une fois « Annuler » et vérifier que la page revient en deuxième
     position ;
  6. toucher une seconde fois « Annuler » et vérifier l’ordre initial ;
  7. relancer l’application et vérifier les cinq pages dans l’ordre initial.
- Résultat attendu : la réorganisation constitue une action unique, les deux
  annulations restaurent successivement la page puis l’ordre, et le résultat
  final persiste après relance.
- Résultat : 🟢 `RÉUSSI`, confirmé par l’utilisateur le 29 juillet 2026.

## Prochaine campagne

Pour `IPAD-L1-017` à `023`, récupérer le commit indiqué, compiler, puis :

1. `017` : vérifier les fonctions précédentes sans régression.
2. `018` : ouvrir « Choisir le fond » et vérifier les trois noms et miniatures.
3. `019` : appliquer chaque fond, annuler/rétablir, relancer et vérifier la
   persistance sur toutes les pages.
4. `020` : sélectionner Une page puis Deux pages et vérifier la persistance.
5. `021` : en Deux pages, vérifier les groupes 1–2, 3–4 et la dernière page
   seule ; réduire la largeur et vérifier le repli à une page sans changer la
   préférence.
6. `022` : vérifier Précédent/Suivant et leur désactivation aux extrémités.
7. `023` : balayer horizontalement dans les deux sens ; un geste surtout
   vertical ne doit pas naviguer.

Résultat attendu pour chacun : comportement décrit observé après relance.
Résultat initial : ⚪ `NON TESTÉ`.

Retour partiel du 29 juillet 2026 :

- `IPAD-L1-019` 🔴 `ÉCHOUÉ` pour le placement de la reliure classique ;
- `IPAD-L1-021` 🔴 `ÉCHOUÉ` car l’absence de numéros rend le groupement
  invérifiable ;
- les autres contrôles restent ⚪ `NON TESTÉ`, le retour global « semble ok »
  ne détaillant pas leurs étapes.

Pour la régression :

### `IPAD-L1-024` — Numéros et identification des pages

- Commit : `35e6741`.
- Préconditions : créer ou ouvrir un album contenant au moins cinq pages.
- Étapes :
  1. sélectionner le mode Une page et parcourir l’album avec les boutons puis
     par balayage ;
  2. vérifier que le libellé visible suit la page active (`Page 1`, `Page 2`,
     etc.) ;
  3. sélectionner le mode Deux pages et vérifier que deux numéros consécutifs
     sont visibles ;
  4. réorganiser au moins deux pages et vérifier que les numéros reflètent le
     nouvel ordre ;
  5. fermer puis rouvrir l’album et contrôler de nouveau la numérotation.
- Résultat attendu : chaque feuille est identifiable, la numérotation est
  cohérente avec l’ordre courant et permet de vérifier la navigation.
- Résultat : ⚪ `NON TESTÉ`.

### `IPAD-L1-025` — Reliure classique simple et double page

- Commit : `35e6741`.
- Préconditions : sélectionner le fond Album classique à spirales dans un album
  contenant au moins trois pages.
- Étapes :
  1. en mode Une page, vérifier qu’une seule reliure longe le bord gauche de la
     feuille ;
  2. parcourir plusieurs pages et vérifier que ce placement reste stable ;
  3. en mode Deux pages et avec une largeur suffisante, vérifier qu’une seule
     reliure est dessinée entre les deux feuilles, sans reliure supplémentaire
     sur leur bord gauche ;
  4. atteindre la dernière page isolée d’un album impair et vérifier que la
     reliure revient sur son bord gauche ;
  5. changer temporairement de fond puis revenir au fond classique.
- Résultat attendu : la reliure est à gauche d’une feuille isolée et uniquement
  dans la gouttière centrale d’une double page, conformément aux références
  visuelles fournies.
- Résultat : 🟢 `RÉUSSI`, confirmé par l’utilisateur le 29 juillet 2026.

## Retour iPad du 29 juillet 2026 — `IPAD-L1-017` à `025`

- `017`, `019`, `020`, `021`, `022` et `025` : 🟢 `RÉUSSI`.
- `018` : 🔴 `ÉCHOUÉ`, les spirales de la miniature classique occupent environ
  trois quarts de sa largeur.
- `023` : 🔴 `ÉCHOUÉ`, un balayage destiné à revenir à la page précédente
  déclenche parfois le retour à la bibliothèque.
- `024` : 🔴 `ÉCHOUÉ`, la numérotation et son suivi sont corrects mais le
  libellé blanc manque de contraste sur le fond classique beige.
- Environnement : iPad et Swift Playgrounds ; versions exactes non
  communiquées.

### `IPAD-L1-026` — Proportions de la miniature classique

- Commit : `16c7a37`.
- Préconditions : ouvrir « Choisir le fond ».
- Étapes :
  1. comparer les trois miniatures ;
  2. vérifier que la reliure classique reste fine et proportionnée à la largeur
     de sa miniature ;
  3. sélectionner le fond classique et vérifier que la reliure de la page
     principale conserve ses dimensions normales.
- Résultat attendu : la reliure n’occupe plus la majeure partie de la
  miniature et le rendu pleine page ne régresse pas.
- Résultat : 🔴 `ÉCHOUÉ`, aucun changement visible dans la miniature selon le
  retour utilisateur du 29 juillet 2026.

### `IPAD-L1-027` — Navigation gestuelle sans retour implicite

- Commit : `16c7a37`.
- Préconditions : ouvrir un album contenant au moins cinq pages.
- Étapes :
  1. répéter dix balayages vers la droite et vérifier le passage à la page
     suivante ;
  2. répéter dix balayages vers la gauche et vérifier le passage à la page
     précédente ;
  3. commencer plusieurs gestes près du bord de l’écran ;
  4. vérifier qu’aucun geste ne revient à la bibliothèque ;
  5. utiliser le bouton « Albums » en haut à gauche et vérifier qu’il reste le
     seul moyen prévu de revenir à la bibliothèque.
- Résultat attendu : les gestes naviguent uniquement entre les pages ; le
  retour à la bibliothèque exige le bouton.
- Résultat : 🔴 `ÉCHOUÉ` le 29 juillet 2026 : le retour à la bibliothèque est
  bien supprimé, mais les directions et changements de pages sont incohérents.

### `IPAD-L1-028` — Contraste du numéro de page

- Commit : `16c7a37`.
- Préconditions : ouvrir un album contenant plusieurs pages.
- Étapes :
  1. appliquer successivement chacun des trois fonds ;
  2. parcourir plusieurs pages en modes Une page et Deux pages ;
  3. vérifier la lisibilité immédiate de chaque numéro, notamment sur le fond
     classique beige et en apparence sombre d’iPadOS.
- Résultat attendu : le numéro sombre sur pastille claire reste lisible sur les
  fonds clairs, et le numéro clair sur pastille sombre sur le fond Nuit.
- Résultat : 🟢 `RÉUSSI`, confirmé par l’utilisateur le 29 juillet 2026.

### `IPAD-L1-029` — Miniature classique réellement adaptative

- Commit : `00d7c69`.
- Préconditions : ouvrir « Choisir le fond ».
- Étapes :
  1. observer la miniature « Album classique » ;
  2. vérifier que chaque anneau est contenu dans la largeur étroite allouée à
     la reliure et ne déborde pas sur les trois quarts de la miniature ;
  3. sélectionner ce fond et vérifier que la reliure pleine page et la reliure
     centrale en double page restent correctement proportionnées.
- Résultat attendu : la largeur réelle des anneaux s’adapte à leur conteneur ;
  la miniature montre une reliure fine à gauche.
- Résultat : ⚪ `NON TESTÉ`.

### `IPAD-L1-030` — Balayage déterministe simple et double page

- Commit : `00d7c69`.
- Préconditions : ouvrir un album d’au moins six pages.
- Étapes :
  1. en mode Une page, commencer alternativement les gestes sur une page et sur
     la zone noire autour ;
  2. vérifier dix fois qu’un balayage vers la droite passe à la page suivante,
     si elle existe ;
  3. vérifier dix fois qu’un balayage vers la gauche passe à la page
     précédente, si elle existe ;
  4. en mode Deux pages, répéter les mêmes gestes et vérifier les passages
     `1–2` → `3–4` → `5–6` vers la droite, puis l’ordre inverse vers la gauche ;
  5. vérifier qu’aux extrémités le geste reste dans l’album et qu’aucun geste ne
     revient à la bibliothèque.
- Résultat attendu : la direction seule détermine la navigation, quel que soit
  le point de départ ; une double page avance ou recule comme un groupe.
- Résultat : ⚪ `NON TESTÉ`.
