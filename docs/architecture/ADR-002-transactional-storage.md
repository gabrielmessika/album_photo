# ADR-002 — Stockage local 3.0 et journal transactionnel

- Statut : accepté pour les lots 0 et 1
- Date : 2026-08-06
- Exigences : `3:DEC-24`, `3:DEC-33`, `3:LOC-001` à `3:LOC-031`,
  `3:ARC-004`, `3:ARC-007`, `3:APP-002`, `3:APP-005`, `3:FMT-002`,
  `3:DAT-010`, `3:DAT-017`, `3:DAT-033`, `3:UND-011`, `3:UND-012`

## Décision

La génération 3.0 utilise exclusivement
`Application Support/AlbumPhotoCanvasV1/`. Elle ne cherche jamais l’ancien
store 2.1. Le snapshot racine porte obligatoirement :

```text
modelGeneration = album-photo-canvas-v1
schemaVersion = 1
```

Le dépôt local est un acteur. Pour le lot 1, une transaction journalise un
snapshot post-commande complet, ce qui privilégie une reprise simple et
idempotente avant d’optimiser la taille des deltas.

L’isolation d’un acteur Swift n’empêche pas sa réentrance pendant un `await`.
Le service applicatif place donc toute enveloppe `load`–validation–`commit`
dans un verrou FIFO unique, cohérent avec la révision globale du snapshot. Deux
commandes rapides, y compris sur des albums distincts, lisent ainsi des
révisions successives au lieu de perdre la seconde avec `staleRevision`.

Les commandes de bibliothèque qui modifient un album prennent, à l’intérieur
de cette enveloppe FIFO, une barrière auprès du gestionnaire de baux. La
barrière refuse un album déjà édité ou en fermeture et empêche l’acquisition
d’un nouveau bail jusqu’au commit. Renommage, couverture, corbeille et
Annuler/Rétablir bibliothèque suivent cette règle. Fermer la bibliothèque fait
d’abord réussir le flush, puis vide ses deux piles et persiste le registre de
références recalculé avant de permettre l’ouverture de l’éditeur.

Ordre de validation :

1. construire et valider le nouvel état en mémoire ;
2. écrire atomiquement le journal avec `commandID` et révision attendue ;
3. remplacer atomiquement le snapshot validé ;
4. supprimer le journal ;
5. publier seulement alors le nouvel état à l’interface.

Au démarrage, un journal plus récent est rejoué une seule fois. Si le snapshot
porte déjà son `commandID`, seul le journal résiduel est nettoyé. Les tests
injectent une interruption après chaque étape.

Les originaux sont immuables et adressés par SHA-256 sous `Assets/`. Les
identifiants métier restent propres à un album : une réutilisation interalbum
crée un nouvel `assetID` mais conserve le même `contentHash` et les mêmes
octets. Un RAW décodable conserve cet original et référence en plus un PNG
statique immuable, possédant son propre SHA-256 et sa propre entrée d’index sous
`Assets/`. Original et dérivé sont enregistrés ensemble dans la transaction
logique, comptés dans le quota et le registre de rétention, et revérifiés tous
les deux avant une réutilisation interalbum. Les variantes dimensionnées sous
`Thumbnails/` ne sont que des caches régénérables et ne figurent ni dans le
modèle ni dans l’empreinte logique `3:DAT-027`.

Le lot 1 n’expose volontairement aucune purge physique : les octets
devenus orphelins restent conservés. Une future purge devra d’abord compléter
le registre de rétention puis revérifier transactionnellement toutes les
références de `3:LOC-008` et `3:LOC-025` immédiatement avant toute suppression.

## Alternatives écartées

- Réutiliser ou migrer le JSON 2.1 : interdit par `3:DEC-33`.
- Publier l’état avant le flush : contredit `3:APP-005` et rend les erreurs de
  sauvegarde ambiguës.
- Enregistrer les originaux dans le JSON ou dans le temporaire : incompatible
  avec la taille, la reprise et `3:LOC-003`.

## Validation requise

Les tests Linux couvrent l’idempotence, les coupures et les invariants. La
racine Application Support, la protection de fichiers et le passage en
arrière-plan restent à vérifier dans Swift Playgrounds sur iPad puis dans
Xcode. Le registre actuel couvre les snapshots et index du lot 1, mais pas
encore toutes les références récupérables des futurs lots (révisions,
branches, conflits et tombstones synchronisés) : aucune purge ne peut être
activée avant cette extension.
