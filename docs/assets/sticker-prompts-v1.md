# Sources visuelles du catalogue Lot 2 — version 1

Ce document fige la provenance des quarante stickers et des six cadres
décoratifs publiés par `docs/catalog-resources-v1.json` (`CAT-001`, `CAT-009`,
`STK-009` à `STK-012`, `SHR-005`, `SHR-011`).

## Provenance et droit de distribution

- Mode : générations originales réalisées pour ce dépôt avec OpenAI ImageGen,
  le 20 août 2026 ; aucun média utilisateur ni asset tiers n'a été fourni au
  modèle.
- Licence enregistrée dans le manifeste : `project-generated-original`, comme
  pour les fonds version 1 du projet.
- Exclusions communes : aucun personnage connu, logo, marque, texte, filigrane,
  asset Photoweb ou imitation d'un asset Photoweb.
- Les PNG livrés sont des dérivés déterministes des générations : décodage
  RGBA, recadrage des seules marges transparentes avec 24 pixels de garde,
  réduction bilinéaire à 512 pixels maximum, conservation d'un alpha réel et
  encodage PNG par `tools/normalize_catalog_png.pl`. Ce recadrage publie le
  rapport intrinsèque utile de chaque sticker au lieu d'un canevas carré
  artificiel.
- L'avion contenait deux petits chiffres parasites générés dans les réacteurs.
  Ils ont été retirés par deux remplissages circulaires locaux avec le même
  outil, sans ajouter de contenu externe.

## Prompt commun des stickers

> Original polished hand-painted digital scrapbook sticker of **SUBJECT**,
> isolated and fully visible on a square transparent canvas with generous
> transparent padding, soft neutral light, muted harmonious colors, clean
> readable silhouette, no text, no logo, no watermark, no brand, no character,
> no cropped edge and no cast shadow outside the object.

`SUBJECT` a pris successivement les valeurs suivantes :

| Catégorie | Sujets générés |
|---|---|
| Voyage | boussole, valise, carnet de voyage de type passeport sans marque, carte et repère, appareil photo rétro, globe, tente, paysage de montagne |
| Transport | vélo, train, voilier, avion, camping-car, voiture, montgolfière, scooter |
| Nature | feuille de chêne, fleur sauvage corail, sapin, coquillage, paysage de montagne et rivière, champignon, papillon, cactus |
| Météo | soleil, nuage, nuage de pluie, arc-en-ciel, flocon, nuage d'orage, lune et étoiles, volutes de vent et feuilles |
| Symboles | cœur, étoile, confettis, note de musique, badge de validation, cadeau, bulle de message, empreinte de patte |

Les noms français et trois tags distinctifs de chaque entrée sont figés dans le
registre JSON et dans `BuiltInStickerCatalog`.

## Prompt commun des cadres

> Original square transparent photo-frame overlay with a large transparent
> center and transparent exterior. Decoration only on the border, balanced
> corners, stretch-friendly straight edge zones for deterministic nine-slice
> rendering, no photo content, no text, no logo, no watermark, no brand and no
> character.

Les six variantes demandées étaient : bord blanc sobre, bord noir sobre, ruban
kraft, marques abstraites de voyage et de courrier sans texte lisible, feuillage
botanique et papier de photo instantanée sans marque. Les insets source
`128/128/128/128`, les insets destination `0,2/0,2/0,2/0,2` et les rendus de
référence `64 × 48` sont figés dans le registre.

## Emplacements livrés

- Stickers : `Albumzh.swiftpm/Sources/AppModule/Resources/Stickers.xcassets`.
- Cadres : `Albumzh.swiftpm/Sources/AppModule/Resources/Frames.xcassets`.
- Goldens neuf zones : `docs/golden/frame-nine-slice-v1`.
