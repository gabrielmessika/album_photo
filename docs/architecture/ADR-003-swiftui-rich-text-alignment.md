# ADR-003 — Alignement du texte riche avec SwiftUI iOS 26

- Statut : accepté pour l’incrément texte du Lot 2
- Date : 2026-08-17
- Exigences : `TXA-001` à `TXA-004`, `TBX-011`, `TBX-023`, `TBX-024`

## Contexte

L’éditeur de texte doit reposer prioritairement sur les API SwiftUI publiques
d’iOS 26 et conserver un domaine indépendant d’`AttributedString`. Le type
public `AttributedString.TextAlignment` expose les alignements gauche, centré
et droit, mais pas l’alignement justifié exigé par `TBX-011`.

## Décision

L’incrément utilise `TextEditor`, `AttributedTextSelection`,
`transformAttributes` et un `AttributedTextFormattingDefinition` SwiftUI. Il
n’introduit ni moteur TextKit parallèle, ni API Apple privée, ni dépendance
externe.

Les commandes gauche, centré et droit sont exposées. La valeur métier
`justified` reste décodable et sérialisable pour préserver le contrat de
données, mais elle est rendue à gauche dans cette première intégration et
n’est pas proposée dans l’interface. `TBX-011` reste donc partiellement ouvert
et aucune validation ne doit revendiquer l’alignement justifié.

## Conséquences

- le modèle et les tests Core restent indépendants de SwiftUI ;
- l’éditeur bénéficie de la sélection et des attributs de saisie natifs
  d’iOS 26 ;
- une intégration UIKit ponctuelle ne pourra être envisagée qu’après un
  prototype séparé et une nouvelle décision d’architecture conformément à
  `TXA-003` ;
- la compilation et le comportement des API iOS 26 doivent être qualifiés dans
  Swift Playgrounds ou Xcode, l’analyse syntaxique WSL n’étant pas un
  type-check Apple.

## Références publiques

- [Create a rich text editor with SwiftUI](https://developer.apple.com/videos/play/wwdc2025/280/)
- [AttributedString.TextAlignment](https://developer.apple.com/documentation/foundation/attributedstring/textalignment)
