# Contrats publics du registre de ressources — version 1

Ce document complète `catalog-resources-v1.json` et son schéma JSON. Il est
normatif pour les lecteurs indépendants du code Swift (`CAT-009`, `SHR-012`,
`SHR-013`). Le registre version 1 contient maintenant exactement trois fonds
`asset`, six formes `nativeVector`, quarante stickers `asset` et six cadres
décoratifs `asset`. Leurs métadonnées, octets, licences et contrats de rendu
sont figés avant la première build du lot 2 qui les persiste.

## Coordonnées et remplissage des formes

`coordinateSpace = unitBoundingBoxTopLeft` signifie que `(0, 0)` est le coin
supérieur gauche, `(1, 1)` le coin inférieur droit, x croît vers la droite et y
vers le bas. Une coordonnée normalisée est mise à l'échelle séparément par la
largeur et la hauteur non tournées de l'élément. Les mesures déclarées comme
`minElementDimension` sont cependant calculées dans ce repère physique après
mise à l'échelle.

Chaque chemin est fermé, rempli avec la règle non nulle, sans contour
intrinsèque, puis découpé aux limites de l'élément. `rendererID` est exactement
égal à `catalogID`. Le champ structuré `rendererContract` publie la primitive et
tous ses paramètres :

- `bounds` couvre `(0, 0, 1, 1)` ;
- `roundedBounds` utilise un rayon `0,12 × min(largeur, hauteur)` ;
- `centeredCircle` utilise le centre `(0,5, 0,5)` et un rayon
  `0,5 × min(largeur, hauteur)` ;
- `ellipseInBounds` est tangente aux quatre limites ;
- `svgCubicPath` interprète `M`, `C` et `Z` comme une suite absolue de courbes
  de Bézier cubiques dans le repère normalisé ;
- `alternatingRadialPolygon` produit les dix sommets d'indice `k = 0...9` à
  l'angle `startAnglePi × π + k × angularStepPi × π`, autour du centre publié,
  avec le rayon pair ou impair publié.

La chaîne du cœur dans le manifeste est le chemin exact de `SHR-012`; elle ne
doit subir ni simplification ni substitution par un symbole de plateforme.

## Golden masks

Chaque `goldenMask.relativePath` est relatif au dossier `docs/`. Les fichiers
sont des Netpbm PBM ASCII `P1`, sans commentaire : en-tête, dimensions, puis
une ligne par rangée de haut en bas. `1` signifie intérieur et `0` extérieur.
Les 64 × 48 échantillons sont pris au centre de chaque pixel, soit
`((x + 0,5) / 64, (y + 0,5) / 48)`. Le rapport non carré distingue notamment
le cercle fondé sur la plus petite dimension de l'ovale tangent aux limites.

Les octets, longueurs et SHA-256 des six fichiers sont figés dans le manifeste
et dans `catalog-checksums-v1.sha256`. Ils sont régénérés par
`tools/generate_shape_goldens.swift` à partir du moteur Swift pur
`CatalogShapeRenderer`; le test compare ensuite les octets régénérés aux
goldens. Le maillage déterministe des courbes utilisé pour cet oracle raster ne
remplace pas le chemin vectoriel exact publié dans le manifeste.

## Métadonnées des stickers

Une entrée `category = sticker` est un payload `asset` et publie en plus :

- `localizedTags.fr`, liste non vide de tags français non dupliqués ;
- `stickerCategory`, parmi `travel`, `transport`, `nature`, `weather` et
  `symbols` (respectivement Voyage, Transport, Nature, Météo et Symboles) ;
- `intrinsicAspectRatio.width` et `.height`, deux entiers strictement positifs.

Le rapport est exact :
`intrinsicAspectRatio.width × pixelHeight == intrinsicAspectRatio.height × pixelWidth`.
Le validateur vérifie aussi les quarante entrées publiées, huit par catégorie,
au moins trois tags français distincts par entrée, le rapport intrinsèque, le
PNG RGBA et sa transparence effective.

## Métadonnées et rendu des cadres décoratifs

Une entrée `category = decorativeFrame` est un payload `asset`, publie ses
dimensions orientées `pixelWidth` et `pixelHeight`, puis :

- `sourceCapInsetsPixels` en pixels entiers positifs ou nuls ;
- `destinationCapInsets` en fractions finies positives ou nulles des limites
  non tournées de l'élément ;
- `nineSliceContract`, qui fixe l'algorithme, les repères, l'interpolation, la
  composition, le suivi des transformations et une image golden vérifiable.

Les contraintes croisées suivantes sont normatives et sont contrôlées par
`tools/validate_contracts.pl`, car JSON Schema ne sait pas exprimer une somme
liée à une autre propriété :

```text
source.left + source.right   < pixelWidth
source.top  + source.bottom  < pixelHeight
0 <= destination.{top,left,bottom,right} < 0.5
destination.left + destination.right  < 1
destination.top  + destination.bottom < 1
```

Les quatre coins source sont mis à l'échelle vers leurs rectangles destination.
Les bords ne sont étirés que sur leur axe longitudinal et le centre sur les deux
axes, avec interpolation bilinéaire. L'alpha est conservé. Le résultat remplit
les limites de l'élément, est composé en source-over au-dessus de la photo
masquée et du contour intérieur, puis suit la rotation et le rognage de
l'élément.

Les six sorties de référence 64 × 48 sont versionnées sous
`docs/golden/frame-nine-slice-v1/`. Leurs empreintes figurent dans
`catalog-checksums-v1.sha256`; `tools/normalize_catalog_png.pl --validate-only`
contrôle aussi que les payloads source restent des PNG RGBA réellement
transparents.

## Résolution des chemins

Le `relativePath` d'un payload `asset` intégré est relatif à
`Albumzh.swiftpm/`. Un `goldenMask.relativePath` ou le chemin d'une image golden
de contrat est relatif à `docs/`. Aucun champ de fichier, MIME, longueur ou hash
de payload n'est admis sur une entrée `nativeVector`.
