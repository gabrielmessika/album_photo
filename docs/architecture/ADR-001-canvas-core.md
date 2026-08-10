# ADR-001 — Canevas canonique et frontière Core/Apple

- Statut : accepté
- Date : 2026-08-06
- Exigences : `3:CAN-001` à `3:CAN-009`, `3:ZOM-001` à `3:ZOM-008`,
  `3:CRP-001` à `3:CRP-007`, `3:ARC-001` à `3:ARC-008`

## Contexte

Le prototype 2.1 associait implicitement une photo à une page et mélangeait
échelle d’écran, cadrage et navigation. Le modèle 3.0 doit rendre plusieurs
éléments libres sur une seule page, à l’identique dans une miniature, sur
iPhone, sur iPad et dans les futures sorties documentaires.

## Décision

Le domaine `AlbumPhotoCore` est indépendant de SwiftUI. Il persiste toutes les
géométries dans un repère normalisé `0...1` et calcule les photos dans une page
canonique de `2 400 × 3 000` unités. Le rendu Apple transforme ensuite cette
composition vers la destination sans réinterpréter les valeurs métier.

À `1×`, un pixel orienté vaut une unité canonique. Pour un cadre rectangulaire
local `Fw × Fh` et une photo orientée `Rw × Rh` :

```text
containScale = min(Fw / Rw, Fh / Rh)
calculatedMinimum = min(1, containScale)
sessionMinimum = min(nativeScaleAtEntry, calculatedMinimum)
```

La persistance accepte `0 < nativeScale <= 8`. Le minimum de session ne
modifie donc jamais un cadrage existant après un changement de cadre, de forme,
de modèle ou d’automatisme.

Le zoom du canevas est un état de scène non persistant. Les transformations
d’élément et le cadrage produisent un brouillon visuel pendant le geste puis
une seule commande métier à sa validation.

Les vues SwiftUI appellent exclusivement un modèle d’application
`@MainActor`. Les accès fichiers, imports et miniatures sont isolés derrière
des services ou acteurs. Un rendu de page commun reçoit un mode
`editor`, `thumbnail`, `preview` ou `cover`; seul le mode éditeur ajoute les
aides d’édition.

## Arbitrage des gestes

L’interaction possède un état exclusif : repos, déplacement/redimensionnement/
rotation d’un élément, cadrage, zoom/déplacement de fenêtre, navigation ou
interaction avec un panneau. Le sous-arbre de gestes de cadrage n’existe que
pendant ce mode. Un balayage de navigation ne peut commencer que sur une zone
vide, avec une dominante horizontale stricte `|dx| > 1,25 × |dy|`.

Cette décision évite notamment les reconnaisseurs de cadrage résiduels qui
avaient neutralisé la navigation dans le prototype 2.1.

## Conséquences

- Les modèles du domaine sont testables sous Linux.
- UIKit, PhotosUI, ImageIO et UniformTypeIdentifiers restent dans AppModule.
- Une compilation Linux ne vaut jamais validation iOS.
- Les fonctionnalités de lots ultérieurs peuvent exister dans le schéma et les
  prototypes internes, mais ne sont pas rendues publiques avant leur lot.

