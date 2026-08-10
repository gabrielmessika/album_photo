# Fixtures `.photoalbum` invalides

Ces fichiers ne sont pas des documents importables. Ils figent deux rejets qui
doivent intervenir avant toute écriture durable :

- `wrong-generation-manifest.json` : génération du prototype 2.1 ; le lecteur
  doit la refuser avant de décoder `album` (`3:DEC-33`, `3:PKG-017`) ;
- `path-traversal-manifest.json` : chemin sortant du package ; le validateur
  doit le refuser (`3:IMP-003`, `3:SEC-005`). Cette fixture est autrement
  conforme au schéma ; remplacer uniquement `../outside.jpg` par un chemin sûr
  la rend valide et garantit que le test cible bien la traversée de chemin.

Les tests de domaine peuvent charger ces fixtures comme octets non fiables. Ils
ne doivent jamais les copier vers Application Support.
