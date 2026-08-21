# ADR-003 — Alignement du texte riche avec SwiftUI iOS 26

- Statut : amendé — rendu justifié public intégré, qualification Apple restante
- Date : 2026-08-20
- Exigences : `TXA-001` à `TXA-004`, `TBX-011`, `TBX-023`, `TBX-024`

## Contexte

L’éditeur de texte doit reposer prioritairement sur les API SwiftUI publiques
d’iOS 26 et conserver un domaine indépendant d’`AttributedString`. Le type
public `AttributedString.TextAlignment` expose les alignements gauche, centré
et droit, mais pas l’alignement justifié exigé par `TBX-011`.

## Décision

L’édition continue d’utiliser `TextEditor`, `AttributedTextSelection`,
`transformAttributes` et un `AttributedTextFormattingDefinition` SwiftUI. Elle
n’introduit ni API Apple privée ni dépendance externe.

Les commandes gauche, centré, droit et justifié sont exposées. Pour les pages
persistées, l’éditeur, les miniatures et Prévisualiser partagent
`AlbumRenderedTextView`, un adaptateur ponctuel `UIViewRepresentable` fondé sur
`UILabel`/TextKit public et `NSMutableParagraphStyle.alignment = .justified`.
L’élément reste mesuré, positionné, tourné et composé par le renderer commun de
page ; aucune seconde représentation métier n’est créée.

La surface de saisie SwiftUI conserve un aperçu gauche lorsque la valeur métier
est `justified`, car l’API `AttributedString.TextAlignment` d’iOS 26 ne propose
toujours pas ce cas. La boîte de dialogue n’est donc pas une preuve visuelle de
la justification ; la page située derrière elle et Prévisualiser le sont après
qualification Apple.

## Conséquences

- le modèle et les tests Core restent indépendants de SwiftUI ;
- l’éditeur bénéficie de la sélection et des attributs de saisie natifs
  d’iOS 26 ;
- l’intégration UIKit est isolée au rendu de page et n’écrit jamais dans le
  domaine, conformément à `TXA-003` ;
- la compilation et le comportement des API iOS 26 doivent être qualifiés dans
  Swift Playgrounds ou Xcode, l’analyse syntaxique WSL n’étant pas un
  type-check Apple.

## Références publiques

- [Create a rich text editor with SwiftUI](https://developer.apple.com/videos/play/wwdc2025/280/)
- [AttributedString.TextAlignment](https://developer.apple.com/documentation/foundation/attributedstring/textalignment)
