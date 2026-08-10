# Format `.photoalbum` version 1

Un document `.photoalbum` est un répertoire package natif Apple, non compressé
et non authentifié. Les empreintes détectent une corruption ; elles ne prouvent
pas l’identité de l’auteur.

Le lecteur doit vérifier `formatGeneration` avant toute autre donnée métier,
puis valider le manifeste avec
[`photoalbum-format-v1.schema.json`](photoalbum-format-v1.schema.json). Il doit
ensuite normaliser et borner chaque chemin, rejeter liens et fichiers spéciaux,
comparer taille et SHA-256 de chaque fichier déclaré et seulement alors créer
une transaction d’import.

Le package contient `manifest.json`, `checksums.json`, et selon le document des
dossiers `photos/`, `catalog-resources/` et `previews/`. Les photos et ressources
`asset` doivent être autonomes. Une ressource `nativeVector` ne contient jamais
un pseudo-fichier : elle doit être connue par son identifiant, sa version et son
`rendererID` publics.

Le champ `mimeType` d’une photo emploie le vocabulaire persistant fermé du
schéma. Tout RAW décodable nouvellement importé est normalisé en
`image/x-raw`; les sous-types RAW historiques explicitement énumérés restent
lisibles. Le package v1 embarque et décrit uniquement les octets de l’original
RAW dans `photos/` : le manifeste ne les remplace jamais par un aperçu et
n’ajoute pas le dérivé local dans `photos[]`. Après validation de l’original,
le lecteur doit produire avant affichage un PNG statique non destructif,
l’enregistrer sous `Assets/` avec sa propre empreinte et l’indexer séparément
dans son store local. Les variantes de taille sous `Thumbnails/` restent des
caches régénérables. Cette représentation locale ne modifie ni le contrat du
package ni l’empreinte logique de l’album.

Les deux formes de `catalogResources` sont exclusives. Un payload `asset`
déclare obligatoirement chemin relatif sûr, type, longueur et SHA-256, sans
`rendererID`. Un payload `nativeVector` déclare obligatoirement son
`rendererID` et ne peut porter aucun champ de fichier de secours.

L’exemple [`Minimal.photoalbum`](examples/Minimal.photoalbum/) illustre un album
sans photo ni ressource de catalogue. Il sert à la validation du contrat du lot
0 ; l’export/import public complet appartient au lot 3.
