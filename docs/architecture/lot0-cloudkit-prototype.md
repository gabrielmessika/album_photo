# Prototype CloudKit page par page — lot 0

Ce document décrit le contrat différé de la version 1.1 sans l’exposer dans la
version lot 1. Il couvre la réduction de risque demandée par `3:SYN-001` à
`3:SYN-004` et respecte la séparation `3:ARC-004`/`3:ARC-006`.

## Découpage proposé

| Type de record | Identité | Contenu principal |
|---|---|---|
| `AlbumRecord` | `albumID` | nom, couverture, ordre des pages, corbeille |
| `PageRecord` | `pageID` | fond, état de mise en page, éléments, ordre accessible |
| `AssetRecord` | `assetID` | métadonnées et `contentHash` |
| `BlobRecord` | `contentHash` | fichier immuable ou référence CloudKit Asset |
| `RevisionRecord` | `revisionID` | snapshot logique et parents |

Une modification de page ne réécrit pas les autres pages. Les octets sont
dédupliqués par empreinte, tandis que les appartenances restent des identités
métier distinctes. Le service CloudKit conforme au protocole du noyau sera
injecté en version 1.1 ; le lot 1 utilise un service désactivé explicite.

## Risques restant à qualifier sur Apple

- entitlements et conteneur indisponibles ou non configurables dans l’App
  Playground ;
- atomicité entre records et CKAsset ;
- notifications silencieuses, quotas et changement de compte ;
- reproduction déterministe des conflits hors ligne.

Aucun de ces points n’est déclaré réussi sous WSL. Un échec reproductible sur
iPad doit devenir un blocage documenté pour la campagne Xcode, pas une preuve
de conformité.

