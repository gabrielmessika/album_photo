# Registre 3.0 des tests manuels — Lots 1 et 2

Ce registre est la campagne neuve de validation du candidat 3.0 sur iPad. La
source normative reste [`spec.md`](spec.md) et l’état général du projet reste
dans [`SUIVI_PROJET.md`](SUIVI_PROJET.md).

Les identifiants `IPAD-L1-001` à `IPAD-L1-062` appartiennent exclusivement au
prototype 2.1. Ils restent consultables dans l’historique Git au commit
`06aaa59`, ne sont pas recopiés ici et ne constituent aucune preuve du code
3.0. Aucun de ces identifiants ne doit être réutilisé.

## Candidats figés par campagne

| Information | Valeur obligatoire |
|---|---|
| Commit d’implémentation de la première campagne | `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a` |
| Spécification de la première campagne | 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`) |
| Correctif rejeté à la compilation Apple | `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` — argument `maximumPixelSize` manquant et inférence générique impossible dans `AppModel` |
| Second candidat rejeté à la compilation Apple | `84ec71e1a66df4676e3c388e9d4f87a5a7e06e4e` — deux appels de préchargement dans `AlbumCoverView` omettaient encore `maximumPixelSize` |
| Correctif compilé et testé lors de la deuxième campagne | `638c659925e1b036570484a98c0fc016602687c9` |
| Correctif compilé et testé lors de la troisième campagne | `7a0f2a442f5f13a98663c5c02a97b8110bd943d6` — 6 réussites, 1 échec |
| Candidat testé lors de la quatrième campagne ciblée | `48e9fef9c317835f605df430c4112320d8cb66c3` — `141` réussi implicitement, `142` échoué en portrait |
| Candidat d’adaptation validé lors de la cinquième campagne ciblée | `101e2948252f51991933b8d61f767f52aa6b629d` — `143…144` réussis |
| Premier candidat Lot 2 testé | `d427d4e747dd2de56235341bd661d537a9a31c8e` — modèles sans texte, dé et Auto ; 5 réussites, 2 échecs, 1 blocage |
| Candidat de correction Lot 2 testé | `024a60bcd7b7a837497a5d6a00e8e42cacfd9366` — `IPAD-L2-009…012` réussis ; confirmation Appliquer, adaptation des panneaux, sélection à nom borné et dé déplacé validés sur iPad |
| Candidat de navigation Lot 2 testé | `b86c4b323e0b8d2cfe2fc2e0394ff9d5f3e4e0b4` — Ajouter une page sous le canevas et mode Gérer les pages ; `IPAD-L2-013` réussi sur iPad |
| Candidat d’ajout de page Lot 2 testé | `02430b16f2853c01dbcafc88d48cd40c48373c4c` — ajout au dernier rang, confirmation commune et réglage temporaire fonctionnels ; `IPAD-L2-014` échoué car la fenêtre est trop large, trop basse et impose un défilement pour son pied de texte |
| Premier correctif de fenêtre testé | `8aa7f566de775c15ddf5a9e702a01ed5e9fdb640` — `IPAD-L2-015` échoué : le dimensionnement ajusté comprime toute la fenêtre, devenue minuscule et illisible |
| Second correctif de fenêtre testé | `7d8772c6d87a769a239b4f9eafabe74c8c126681` — `IPAD-L2-016` échoué : le bouton fige l’app sans afficher la confirmation |
| Correctif de gel testé | `57afa71e3eeac8b48f05e0aaa719cf77e8a97834` — dialogue interne centré, sur fond assombri et sans négociation de taille de feuille ; `IPAD-L2-017` réussi selon le retour global « c’est ok » |
| Candidat Remplir l’album testé | `781539603d6b98523fe48326ee49e24288dfa09b` — trois densités, plan déterministe, confirmation chiffrée et commande unique ; `IPAD-L2-018` réussi selon le retour global « les tests sont ok » |
| Candidat compact et cadrage testé | `3944fae199b2eb37c7b1f0a1aae5558197455b87` — bouton compact, dialogue Densité/compteur/Annuler/Valider et cadrage initial couvrant ; `IPAD-L2-019` réussi selon le retour global « tout est ok » |
| Candidat zones de texte rejeté à la compilation | `d882183d31de7ed6078c70f9e79a80d6ba994dd6` — `IPAD-L2-020` échoue à l’étape 1 : les contraintes de formatage tentaient d’écrire des attributs autres que leur `AttributeKey` |
| Correctif de compilation texte testé | `0f4b16c6c6435c29ca44da4e2726fac210add520` — compilation réussie indirectement, mais `IPAD-L2-021` échoue sur l’emplacement de l’ajout, le fond de l’éditeur, les pastilles couleur, l’échelle et l’opacité |
| Correctif ergonomie et rendu texte testé | `7bc495ec623e5b12301569d0108fbccadb978630` — compilation et ouverture de l’éditeur réussies, mais `IPAD-L2-022` échoue car la saisie est pratiquement invisible |
| Correctif de lisibilité typographique testé | `f0a0ccaa4f580a5d602dfc9432228fdf5115ce59` — compilation et saisie visible confirmées, mais campagne `IPAD-L2-023…029` limitée à 2 réussites (`028`, `029`) et 5 échecs (`023…027`) : descendantes rognées, motif devant l’éditeur, organisation des panneaux rejetée, sélection/palette inadaptées au paysage et styles Police/Italique sans effet perceptible |
| Correctif groupé texte testé | `cb7786259cc85cbe5fd7017ed2f4c9ae3ba823aa` — `IPAD-L2-031…032` réussissent ; `030` échoue uniquement sur les trois motifs intégrés et `033` sur la faible distinction Système/Arrondie ainsi que l’italique Arrondie ; les autres étapes déclarées conformes |
| Second correctif texte testé | `3102cda0e6b2c483576585ec2f97fc947f87c96f` — `IPAD-L2-034…035` réussis globalement ; motifs, Arrondie/Italique, états actifs, persistance et VoiceOver déclarés conformes sans capture |
| Candidat Info et correctifs texte testé | `60930587da16707dbb57eada9881f6fefcedd51e` — `IPAD-L2-037…038` réussis ; `IPAD-L2-036` échoue car Info affiche `Non estampillé` au lieu du commit exact |
| Candidat de fin de développement Lot 2 rejeté à la compilation | `fce5d92879a5a654778b02ec17a3707590554cd7` — `IPAD-L2-039` échoue dans `AppModel` ligne 256, le type-checker ne résolvant pas la concaténation des cinq segments UUID ; `040…054` non exécutés |
| Correctif de compilation Lot 2 testé | `64f53424a0fc479c4fdea79c401d0b227d52eebd` — construction UUID découpée en cinq `String` ; sources applicatives identiques dans le paquet documentaire `94deaf2937123fe22ab579c193543f547768fde9` ; 157 tests WSL réussis, puis campagne iPad reportée de `039…054` vers `055…070` : 12 réussites et 4 échecs (`058`, `061`, `062`, `065`) |
| Candidat de régression des quatre échecs fonctionnels | `9bc11e7423178b66c48446c59abc5a912de5c26f` — collage riche et limite, dépôt/remplacement/miniature/commandes sticker et alignement des cadres ; 157 tests WSL, parse, 55 contrats et 16 empreintes réussis ; `IPAD-L2-071…074` à exécuter |
| App Playground | `Albumzh.swiftpm` |
| Copie testée lors de la première campagne | `aeae5c439c461e7994117067d81a416591d348bd` ; sources applicatives identiques au commit d’implémentation initial |
| Copie validée après la nouvelle adaptation | `101e2948252f51991933b8d61f767f52aa6b629d` |
| Appareil | iPad 8e génération (déclaré « iPad 8 ») |
| iPadOS | 26.5.2 |
| Swift Playgrounds | 4.7 |
| Orientation initiale | Portrait |
| Réseau initial | Connecté, sauf test hors ligne |
| Date et lieu de la campagne | Début le 16 août 2026 — Paris, France ; campagne finale Lot 2 préparée le 21 août 2026, lieu d’exécution à confirmer |
| Langue et région | Français — France |

Le code de la première campagne reste figé par l’empreinte Git exacte
`314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`. La spécification 3.0 et
l’arbitrage normatif des lots sont figés par
`031d2e46c70128c7e633db1f04663949e4531309`. Le correctif
`06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` n’a pas compilé avec le SDK Apple ;
aucune fiche fonctionnelle ne peut donc le viser. Le candidat
`84ec71e1a66df4676e3c388e9d4f87a5a7e06e4e` a également échoué à la
compilation sur un appel restant dans `AlbumCoverView` ; `IPAD-L1-132` en
conserve la preuve. Le candidat `638c659925e1b036570484a98c0fc016602687c9`
a ensuite compilé et les procédures `IPAD-L1-102`, `IPAD-L1-109…131` et
`IPAD-L1-133` ont été exécutées. La campagne compte 19 réussites, 4 échecs et
2 blocages de procédure. Les nouvelles fiches `IPAD-L1-134…140` ciblent les
corrections issues de ces retours dans le candidat exact
`7a0f2a442f5f13a98663c5c02a97b8110bd943d6`. Ce candidat a ensuite réussi
`134` et `136…140` ; `135` reste en échec sur la grille et l’action locale.
Les remplacements `141…142` visent le candidat exact
`48e9fef9c317835f605df430c4112320d8cb66c3`. L’ouverture fonctionnelle de
l’éditeur prouve indirectement `141`, mais `142` échoue encore en portrait :
la troisième colonne est presque entièrement hors écran, le bouton local est
coupé à gauche et l’accès permettant de choisir Photos ou Fonds n’est plus
affiché dans l’état signalé. Les remplacements `143…144` visent le candidat
exact `101e2948252f51991933b8d61f767f52aa6b629d`. Les régressions
`IPAD-L2-009…012` visent le correctif exact
`024a60bcd7b7a837497a5d6a00e8e42cacfd9366`. Elles ne demandent plus de faire
apparaître le menu Plus sur l’iPad plein écran : ce contrôle de largeur
compacte est reporté séparément à `APPLE-L2-001`.
Le retour global « tous les tests sont ok » reçu après remise de la campagne
corrective valide `IPAD-L2-009…012` uniquement. Il ne s’étend à aucun contrôle
`APPLE-*`, qui reste différé et non testé.
La régression `IPAD-L2-013` vise ensuite exactement le candidat
`b86c4b323e0b8d2cfe2fc2e0394ff9d5f3e4e0b4` et est réussie. Elle reste
indépendante des contrôles Apple différés et ne prouve pas le nouveau parcours
d’ajout en fin d’album avec confirmation, demandé après son exécution.
La régression `IPAD-L2-014` vise exactement le candidat
`02430b16f2853c01dbcafc88d48cd40c48373c4c` et échoue uniquement sur
l’adaptation de sa fenêtre de confirmation. Les autres comportements ont été
déclarés corrects, sans détail par étape ; la correction recevra un nouvel ID.
La régression ciblée `IPAD-L2-015` vise exactement le candidat
`8aa7f566de775c15ddf5a9e702a01ed5e9fdb640` et échoue dès son contrôle de
lisibilité : la présentation ajustée comprime le `NavigationStack`. Une seconde
correction à taille explicite recevra un nouvel ID.
La régression `IPAD-L2-016` vise exactement le candidat
`7d8772c6d87a769a239b4f9eafabe74c8c126681` et remplace `015` uniquement pour
la lisibilité et l’adaptation de la fenêtre. Elle échoue dès l’ouverture : le
bouton fige l’app et aucune confirmation n’apparaît. Le correctif suivant
retire ce parcours de feuille système. La régression `IPAD-L2-017` vise
exactement `57afa71e3eeac8b48f05e0aaa719cf77e8a97834` et réussit selon le retour
global « c’est ok » reçu après remise de cette seule fiche. Cette preuve ne
contient ni capture ni observation par étape et ne couvre aucun contrôle
`APPLE-*`.
La régression `IPAD-L2-018` vise exactement le candidat
`781539603d6b98523fe48326ee49e24288dfa09b`. Elle qualifie séparément Remplir
l’album et réussit selon le retour global « les tests sont ok » reçu après
remise de cette seule fiche. Cette preuve ne contient ni capture ni observation
par étape, ne couvre aucun contrôle `APPLE-*` et ne qualifie pas les changements
de présentation et de cadrage demandés avec ce retour.
La régression `IPAD-L2-019` vise exactement le candidat
`3944fae199b2eb37c7b1f0a1aae5558197455b87`. Elle qualifie uniquement le
bouton compact, son dialogue interne, le cadrage couvrant des nouvelles
affectations et la conservation des cadrages déjà persistés ; elle ne modifie
aucun verdict historique. Elle réussit selon le retour global « tout est ok »
reçu après remise de cette seule fiche. Cette preuve ne contient ni capture ni
observation par étape et ne couvre aucun contrôle `APPLE-*`.
La régression `IPAD-L2-020` vise exactement le candidat
`d882183d31de7ed6078c70f9e79a80d6ba994dd6`. Elle
qualifie le premier incrément public des zones de texte ; l’alignement justifié,
le regroupement de frappe après 750 ms, l’export et le presse-papiers commun
restent explicitement hors de cette preuve. Elle échoue dès la compilation :
les diagnostics des captures `IMG_4188.HEIC` et `IMG_4189.HEIC` montrent que les
proxies de `AttributedTextValueConstraint` refusent les écritures de police,
couleur, alignement et interligne lorsque ces clés ne sont pas l’`AttributeKey`
de la contrainte. Aucune étape fonctionnelle n’est attribuée à ce candidat.
La régression `IPAD-L2-021` reprend toute la qualification sur le correctif
exact `0f4b16c6c6435c29ca44da4e2726fac210add520`. Son lancement prouve
indirectement la compilation, mais le retour et `IMG_4191.jpg` signalent un
bouton superposé au canevas, un éditeur noir sur noir, des choix de couleur
blancs, une échelle de taille différente entre fenêtre et page et une opacité
sans effet visible. Les étapes non commentées ne sont pas transformées en
réussites. `IPAD-L2-022` compile et atteint ensuite l’éditeur, mais échoue à
l’étape 4 : les caractères tapés sont rendus à environ `N × H / 3000` au lieu
de la conversion typographique `N × H / 720` et deviennent pratiquement
invisibles. Les régressions `IPAD-L2-023…029` remplacent sa fiche monolithique
par des contrôles courts qui réutilisent progressivement le même album. Leur
retour du 19 août 2026 confirme la compilation, la frappe visible, la
géométrie/débordement/modèle et la profondeur/persistance/accessibilité, mais
révèle cinq échecs détaillés dans les fiches et la table de session ; aucun
verdict historique antérieur n’est modifié. Les quatre régressions Texte-B
`IPAD-L2-030…033` visent ensuite `cb7786259cc85cbe5fd7017ed2f4c9ae3ba823aa`.
Le retour du 20 août réussit `031` et `032`, confirme les étapes 1 à 3 de `030`
et les étapes 3 à 4 de `033`, mais échoue sur les trois motifs intégrés, la
faible distinction Système/Arrondie et l’italique Arrondie. La demande de
matérialiser chaque choix actif est enregistrée sous `3:TBX-026`. Le second
correctif est figé au commit exact
`3102cda0e6b2c483576585ec2f97fc947f87c96f` et est qualifié globalement par
les réussites `IPAD-L2-034…035`, sans rejouer les surfaces déjà réussies sous
`031…032`. Le retour ajoute une demande ergonomique distincte : raccourcir les
boutons de format dont le libellé principal inclut désormais la valeur active.
Elle est enregistrée sous `3:TBX-027` pour le prochain développement et ne
transforme pas rétroactivement `035` en échec. Ces deux fiches restent liées à
ce commit et ne sont pas retargetées. L’ajout
ultérieur du bouton Info produit le candidat combiné exact
`60930587da16707dbb57eada9881f6fefcedd51e`; `IPAD-L2-036…038` remplacent
`034…035` pour toute campagne exécutée sur ce nouveau package. Leur retour du
20 août 2026 réussit globalement `037` et `038`, mais `036` échoue : la valeur
Commit affiche `Non estampillé`. Le reste de `036` est déclaré conforme
globalement, sans pouvoir prouver la sélection et la copie des 40 caractères
absents.

La correction utilise désormais l’action GitHub **Paquet candidat iPad**, qui
fabrique et vérifie l’archive estampillée depuis le commit choisi. Une copie
directe Working Copy reste `Non estampillé`. Le candidat fonctionnel suivant a
été figé dans `fce5d92879a5a654778b02ec17a3707590554cd7`, mais `IPAD-L2-039`
échoue dès la compilation : Swift Playgrounds ne parvient pas à type-checker la
concaténation des cinq segments UUID dans `AppModel` ligne 256. Les fiches
`040…054` n’ont donc pas été exécutées. Elles restent attachées à ce candidat
rejeté et seront remplacées par de nouveaux identifiants sur le correctif. Les
validations Apple hors Playgrounds sont décrites sous `APPLE-L2-002…005`.
Le correctif exact `64f53424a0fc479c4fdea79c401d0b227d52eebd` est qualifié
par `IPAD-L2-055…070`. Le retour du 21 août a utilisé par erreur les libellés
`039…054` de la première campagne ; il est reporté un pour un sur les fiches
de remplacement (`nouvel ID = ancien ID + 16`) puisque le paquet testé porte
le correctif et que les sources applicatives de `94deaf2…` sont identiques à
`64f5342…`. Les anciennes fiches restent historiques : elles ne sont ni
supprimées ni transformées en preuve du candidat qui ne compilait pas. Cette
campagne compte 12 réussites et 4 échecs (`058`, `061`, `062`, `065`). Les
validations Apple `006…009` restent attachées à ce correctif incomplet.
Le correctif de ces quatre échecs est figé dans
`9bc11e7423178b66c48446c59abc5a912de5c26f`. Les fiches courtes
`IPAD-L2-071…074` et `APPLE-L2-010…013` le qualifient sans modifier les
verdicts historiques ni rejouer les douze surfaces déjà réussies.

## Mode de réponse

Exécuter une fiche à la fois, puis répondre avec exactement l’une des formes
suivantes :

```text
IPAD-L1-063 OK
IPAD-L1-063 BLOQUÉ : raison
IPAD-L1-063 BUG : résultat observé, étapes et capture éventuelle
IPAD-L2-001 OK
IPAD-L2-001 BLOQUÉ : raison
IPAD-L2-001 BUG : résultat observé, étapes et capture éventuelle
```

Codex enregistrera ensuite le résultat observé, la preuve, l’environnement et
l’effet éventuel dans `SUIVI_PROJET.md`. Un retour global ne valide jamais
implicitement plusieurs fiches. Pour signaler un écart dans une fiche en
tableau, préciser aussi l’ID numérique de la ligne, par exemple
`IPAD-L2-010 BUG étape 3 : …`.

| Repère | État enregistré | Usage |
|---|---|---|
| 🟢 | `RÉUSSI` | Toutes les étapes et attentes ont été observées sur l’environnement indiqué. |
| 🔴 | `ÉCHOUÉ` | Une étape a produit un écart reproductible. |
| 🟠 | `BLOQUÉ` | L’environnement ou une dépendance empêche de conclure. |
| ⚪ | `NON TESTÉ` | La fiche n’a pas encore été exécutée sur ce candidat. |
| ⚫ | `NON APPLICABLE` | Le contrôle ne concerne pas la configuration, avec justification écrite. |

## Périmètre et allocation normative

La campagne historique `IPAD-L1` teste uniquement les fonctions publiques du Lot 1 :
bibliothèque, albums et corbeille, éditeur à une page, pages et vue globale,
fonds, couverture, photos et cadres photo, cadrage, zoom du canevas,
sauvegarde, presse-papiers de cadres photo, navigation et annulation.

La nouvelle campagne `IPAD-L2-001…008` vise uniquement le premier incrément du
Lot 2 : panneau Mise en page, modèles sans texte, dé et Auto. Elle ne valide
pas encore les zones de texte éditables, Remplir l’album, stickers, formes,
cadres décoratifs, lecture, diaporama, export/import `.photoalbum` ni PDF.
Les types ou prototypes internes correspondants ne doivent pas devenir des
commandes visibles pour cette campagne, conformément à `3:ARC-014`.

`3:DEC-38` et `3:ARC-014` fixent désormais la frontière sans ambiguïté :
`3:ACPT-123` et `3:ACPT-130` sont des sorties du Lot 2, tandis que
`3:ACPT-127` est une sortie du Lot 3. Ils ne sont donc pas des critères de
réussite de cette campagne. Les exigences transversales suivantes restent
contrôlées uniquement dans leur sous-périmètre Lot 1 :

- pour `3:ALB-007`, seules Renommer, Choisir la couverture et Supprimer sont
  contrôlées ; Exporter relève du Lot 3. Pour `3:ALB-009`, seule l'action Créer
  un album est contrôlée ; Importer un package relève du Lot 3 ;
- pour `3:EDT-003`, la barre est contrôlée dans son ordre relatif après retrait
  de Mise en page auto et Exporter. Pour `3:EDT-008` et `3:EDT-020`, seule
  Ajouter une photo est publique ; Ajouter du texte relève du Lot 2. Pour
  `3:EDT-018`, aucun contrôle d'export n'est possible avant le Lot 3 ;
- pour `3:COV-002`, le Lot 1 contrôle le cadrage du contenu, le masque
  rectangulaire, la transparence et le fond révélé ; formes, contours et cadres
  décoratifs seront complétés au Lot 2. `3:COV-007` nécessite en plus une
  preuve instrumentée du cache, inscrite dans les validations différées ;
- les clauses texte de `3:BG-011` et `3:BG-016` sont différées au Lot 2. La
  présente campagne contrôle les fonds et la stabilité des éléments existants,
  mais ne crée pas de zone de texte ;
- `3:FMT-008` ne peut être validée sans PDF au Lot 3. Pour `3:QLT-006`, seul le
  caractère non bloquant pour l'édition et la sauvegarde est vérifié au Lot 1 ;
  l'avertissement et la poursuite de l'export restent différés ;
- `3:TST-010` est rejouée seulement pour ses fonctions Lot 1 : les textes,
  stickers, modèles, dé, Auto, lecture, diaporama et exports n'entrent pas dans
  cette campagne. Pour `3:TST-012`, la relance, l'annulation d'une suppression
  d'asset, la non-purge d'un blob partagé et les cas injectables localement sont
  contrôlés ; packages, export/import autonome et package dégradé relèvent du
  Lot 3, tandis que le manque d'espace ou une interruption non injectable est
  réservé à la qualification différée ;

Chaque fiche nomme explicitement le sous-périmètre transversal observé. Les
contrôles complets de `3:ACPT-123`, `3:ACPT-127` et `3:ACPT-130` recevront de
nouveaux identifiants stables dans les campagnes de leurs lots respectifs ;
aucun résultat Lot 1 ne sera extrapolé à ces scénarios.

## Corpus non personnel

Copier les quatre PNG versionnés depuis `docs/test-fixtures/photos/` vers
Fichiers sur l’iPad sans les réencoder. Vérifier leurs dimensions et leurs
empreintes avant transfert ou sur la machine source.

| Fichier | Dimensions | SHA-256 attendu | Usage |
|---|---:|---|---|
| `small-landscape-600x400.png` | 600 × 400 px | `407edaf04f5fd921e8e4bca7359d55e6d87b3f2876ebd99caead085a285a6ecc` | Taille native `1×`, fond visible |
| `medium-landscape-2400x1800.png` | 2 400 × 1 800 px | `08dff2054c238e1299214ef579407b880b3f01bf509c4b67d231555aaa6bc841` | Corpus `3:TST-011`, import et placement statiques |
| `large-portrait-4800x6000.png` | 4 800 × 6 000 px | `f3547f764f7eec40178bd1f3602863e0ed35bc6fe30777acde91b2f5d95903ca` | Borne dynamique `0,5×` en pleine page |
| `square-1200x1200.png` | 1 200 × 1 200 px | `494a22dff3b8765d5e62ffca306434e314323c97a41e5108dbbc563c3bd4b360` | Rotation, retournement et déplacement |

Compléter le corpus ci-dessous avec des médias synthétiques ou librement
redistribuables. Enregistrer le nom, les dimensions et le SHA-256 de chaque
fichier effectivement utilisé dans la preuve de `IPAD-L1-076` ou
`IPAD-L1-077`.

| Type requis | Cas attendu | Référence locale avant test |
|---|---|---|
| HEIC/HEIF statique | Accepté | À renseigner |
| JPEG statique | Accepté | À renseigner |
| PNG statique | Accepté ; les quatre fixtures ci-dessus conviennent | Voir empreintes ci-dessus |
| RAW décodable par iPadOS | Original conservé, dérivé statique affiché | Différé : `raw.dng` synthétique, modèle `OpenAI iOS Test RAW`, 1 600 × 1 200, 16 bits RGGB, 3 840 384 octets, SHA-256 `6e5b0c9a1a19c698a2f393d53ee2dd50c7abca30f5405fe730a8ebd45d6321eb`, refusé par ImageIO ; nouveau test avec un RAW décodable à fournir |
| Live Photo | Seule la composante fixe est importée | À créer dans Photos sans contenu personnel |
| HDR statique | Accepté si décodable | À renseigner |
| GIF animé | Refusé | À renseigner |
| APNG animé | Refusé | À renseigner |
| Vidéo courte | Refusée | À renseigner |
| Fichier image corrompu | Refusé sans altérer l’album | À renseigner |
| Image déclarant plus de 200 MP | Refusée avant décodage intégral | À renseigner |

## Registre synthétique

Les fiches exécutées ou rendues obsolètes parmi `IPAD-L1-063…108` ciblent le
candidat d’origine `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a` (copie iPad
`aeae5c…`). Le correctif
`06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` a échoué à la compilation Apple.
Les fiches `IPAD-L1-102`, `IPAD-L1-109…131` et `IPAD-L1-133` ont été exécutées
sur `638c659925e1b036570484a98c0fc016602687c9`. Les réponses explicites donnent
19 réussites, 4 échecs et 2 blocages : `112` n’a pas été compris et `124` n’a
pas satisfait sa précondition d’une occurrence dans la cible. `IPAD-L1-132`
conserve l’échec de `84ec71e…`. Sur
`7a0f2a442f5f13a98663c5c02a97b8110bd943d6`, les fiches `134` et `136…140`
sont réussies ; `135` échoue encore sur l’adaptation. Les nouvelles fiches
`141…142` ont été exécutées sur
`48e9fef9c317835f605df430c4112320d8cb66c3` : `141` est réussi par preuve
indirecte de lancement et `142` échoue en portrait. Sur
`101e2948252f51991933b8d61f767f52aa6b629d`, `143` et `144` sont réussis :
la compilation, le rail Photos/Fonds, l’inspecteur, les trois colonnes et les
commandes adaptatives sont confirmés par le retour « tout est ok maintenant ».
Le candidat Lot 2 `d427d4e747dd2de56235341bd661d537a9a31c8e`
a été exécuté sous `IPAD-L2-001…008`. La campagne compte cinq réussites
(`001`, `003`, `005`, `006`, `007`), deux échecs (`002`, `004`) et un blocage
(`008`). Le retour « `002` : ok » n’est pas converti en réussite, car
l’observation globale de panneaux encore rognés en portrait contredit son
résultat attendu. Pour `008`, les contrôles accessibles sont déclarés bons,
mais le menu Plus de largeur compacte n’a pas pu être atteint dans Swift
Playgrounds sur cet iPad.

| ID | Objet | Exigences principales | État |
|---|---|---|---|
| `IPAD-L1-063` | Compilation et lancement sur racine 3.0 neuve | `3:LOT-001`, `3:LOC-029`, `3:LOC-031` | 🟢 `RÉUSSI` — performance de lancement à corriger séparément |
| `IPAD-L1-064` | État vide, noms, création et durabilité | `3:ALB-004`, sous-périmètre création de `3:ALB-009`, `3:ALB-011` à `3:ALB-016`, `3:ACPT-100` | 🟢 `RÉUSSI` — anomalie de retour post-création séparée |
| `IPAD-L1-065` | Grille, cartes, tri et durabilité | `3:ALB-001`, `3:ALB-002`, `3:ALB-003`, `3:APP-005` | 🟢 `RÉUSSI` |
| `IPAD-L1-066` | Renommage ciblé et Annuler/Rétablir | sous-périmètre Renommer de `3:ALB-007`, `3:ALB-021`, `3:UND-011` | 🟢 `RÉUSSI` |
| `IPAD-L1-067` | Corbeille, impossibilité d'éditer et restauration | `3:ALB-008`, `3:ALB-017`, `3:ALB-018`, `3:ALB-019`, `3:ACPT-102` | 🔴 `ÉCHOUÉ` — dates et localisation |
| `IPAD-L1-068` | Suppression définitive ciblée et blob partagé | `3:ALB-018`, `3:LOC-008`, `3:LOC-022` | 🟢 `RÉUSSI` — compteur `×2` incohérent séparé |
| `IPAD-L1-069` | Bail d’édition multi-fenêtre | `3:APP-002`, `3:APP-010`, `3:APP-011` | 🟠 `BLOQUÉ` — Swift Playgrounds sans multi-fenêtre sur cet iPad |
| `IPAD-L1-070` | Ajout, suppression et restauration d'une page remplie | `3:PAG-001`, `3:PAG-002`, `3:PAG-006`, `3:PAG-007`, `3:PAG-008`, `3:PAG-009`, `3:PAG-010` | 🟢 `RÉUSSI` |
| `IPAD-L1-071` | Déplacer la page 5, la supprimer puis annuler | `3:PAG-003`, `3:PAG-004`, `3:PAG-005`, `3:PAG-011`, `3:GLO-003`, `3:GLO-004`, `3:GLO-005`, `3:ACPT-104` | 🟢 `RÉUSSI` — indicateur d’insertion demandé |
| `IPAD-L1-072` | Une seule page et fidélité globale | `3:GLO-001` à `3:GLO-009` | 🟢 `RÉUSSI` |
| `IPAD-L1-073` | Fonds par page, portée globale et hors ligne | `3:BG-001` à `3:BG-005`, sous-périmètre Lot 1 de `3:BG-006`, `3:BG-010`, `3:BG-012`, `3:BG-013`, `3:BG-014`, `3:BG-015` | 🟢 `RÉUSSI` |
| `IPAD-L1-074` | Couverture automatique, manuelle, identité et repli | `3:COV-001`, sous-périmètre Lot 1 de `3:COV-002`, `3:COV-003`, `3:COV-004`, `3:COV-005`, `3:COV-006`, `3:DAT-005`, `3:ACPT-103` | 🟢 `RÉUSSI` |
| `IPAD-L1-075` | PhotosPicker multiple, ordre, hors ligne et annulation | `3:PHO-007`, `3:PHO-008`, `3:APL-001`, `3:APL-002`, `3:APL-003`, `3:APL-004`, `3:APL-005`, `3:APL-007`, `3:ERR-001` | 🟢 `RÉUSSI` |
| `IPAD-L1-076` | Fichiers : formats statiques acceptés | `3:FMT-001`, `3:FMT-002`, `3:FMT-003`, `3:FMT-005`, `3:FMT-007`, `3:TST-011` | 🟠 `BLOQUÉ` — fixture RAW non décodable ; grille à corriger séparément |
| `IPAD-L1-077` | Refus, échec partiel et nouvelle tentative | `3:PHO-007`, `3:PHO-008`, `3:FMT-004`, `3:FMT-006`, `3:APL-008` | 🟢 `RÉUSSI` — déduplication intra-album ajoutée séparément |
| `IPAD-L1-078` | Panneau Photos, tri, compteur et suppression | `3:PHO-001` à `3:PHO-003`, `3:PHO-009`, `3:PHO-010` | 🔴 `ÉCHOUÉ` — annonce « Utilisée 2 fois » absente |
| `IPAD-L1-079` | Réutilisation, annulation et indépendance interalbum | `3:PHO-015`, `3:PHO-016`, `3:PHO-017`, `3:PHO-018`, `3:LOC-008` | 🔴 `ÉCHOUÉ` — grille source inutilisable |
| `IPAD-L1-080` | Placement par pression et album sans photo | `3:PHO-004`, `3:PHO-005`, `3:PHO-006`, `3:PHO-011`, `3:PHO-012`, `3:PHO-013` | 🔴 `ÉCHOUÉ` — mode de choix invisible |
| `IPAD-L1-081` | Placement par glisser-déposer | `3:PHO-004`, `3:PHO-005`, `3:ACC-020` | 🟠 `BLOQUÉ` — largeur compacte et glisser inter-apps indisponibles |
| `IPAD-L1-082` | Remplacer, retirer et supprimer distinctement | `3:FRM-001` à `3:FRM-009` | 🟢 `RÉUSSI` — ergonomie de l’inspecteur à corriger |
| `IPAD-L1-083` | Dupliquer et presse-papiers compatible/incompatible | `3:ELM-009`, `3:CLP-001`, `3:CLP-002`, `3:CLP-003`, `3:CLP-004` | ⚫ `NON APPLICABLE` — étapes 8–9 contraires à la portée de session confirmée |
| `IPAD-L1-084` | Sélection, chevauchement et profondeur | `3:ELM-001`, `3:ELM-008`, `3:ELM-014` | 🔴 `ÉCHOUÉ` — choix « Photo » ambigus |
| `IPAD-L1-085` | Déplacement, huit poignées et rotation | `3:ELM-002` à `3:ELM-004`, `3:ELM-007`, `3:ELM-013` | 🟢 `RÉUSSI` — ergonomie poignées/aperçu à améliorer |
| `IPAD-L1-086` | Guides, accrochage, haptique et bornes | `3:CAN-005`, `3:CAN-006`, `3:ELM-005`, `3:ELM-006` | 🟠 `BLOQUÉ` — haptique indisponible sur l’iPad 8 |
| `IPAD-L1-087` | Petite photo 600 × 400 à `1×` | `3:DEC-07`, `3:CRP-001`, `3:CRP-004`, `3:CRP-006` | 🟢 `RÉUSSI` |
| `IPAD-L1-088` | Commande Pleine page et grande photo à `0,5×` | `3:DEC-07`, `3:CRP-001`, `3:CRP-004` | 🟢 `RÉUSSI` |
| `IPAD-L1-089` | Cadrage indépendant et original non destructif | `3:CRP-002`, `3:CRP-003`, `3:CRP-004`, `3:CRP-005`, `3:CRP-006`, `3:CRP-007`, `3:DAT-006` à `3:DAT-010` | 🟢 `RÉUSSI` |
| `IPAD-L1-090` | Paliers du zoom du canevas | `3:ZOM-001`, `3:ZOM-002`, `3:ZOM-007` | 🟢 `RÉUSSI` — page active après Rétablir à corriger séparément |
| `IPAD-L1-091` | Pincement ancré, panoramique et mémoire par page | `3:ZOM-003` à `3:ZOM-008` | 🔴 `ÉCHOUÉ` — panoramique à deux doigts inaccessible |
| `IPAD-L1-092` | Navigation et priorité des gestes | `3:NAV-001` à `3:NAV-007`, `3:ZOM-005` | 🔴 `ÉCHOUÉ` — balayage inopérant après retour page 1 |
| `IPAD-L1-093` | Sauvegarde pendant geste, arrière-plan et relance | `3:APP-005`, `3:APP-006`, `3:APP-008`, `3:APP-009`, `3:SAV-001`, `3:SAV-002`, sous-périmètre réussite de `3:SAV-003` | 🔴 `ÉCHOUÉ` — saut et double commande après Sauvegarder |
| `IPAD-L1-094` | Interruption après commande validée | `3:LOC-011` à `3:LOC-014`, `3:LOC-026` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-109` |
| `IPAD-L1-095` | Prévisualisation et rendu commun | `3:CAN-003`, `3:CAN-004`, `3:CAN-008`, `3:GLO-007`, `3:GLO-008` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-110` |
| `IPAD-L1-096` | Cadre vide et alertes de miniature | `3:FRM-001`, `3:FRM-008`, `3:GLO-006` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-111` |
| `IPAD-L1-097` | Qualité, seuils exacts et format régional | `3:QLT-001`, `3:QLT-002`, `3:QLT-003`, `3:QLT-004`, `3:QLT-005`, sous-périmètre édition/sauvegarde de `3:QLT-006`, `3:L10N-005` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-112` |
| `IPAD-L1-098` | Interface régulière/compacte, orientations et apparence | `3:EDT-002`, `3:EDT-004`, `3:EDT-005`, `3:EDT-006`, `3:EDT-011`, `3:EDT-016`, sous-périmètre photo de `3:EDT-020`, `3:ACC-021` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-113` |
| `IPAD-L1-099` | Dynamic Type, description accessible et VoiceOver | `3:ACC-001` à `3:ACC-005`, `3:ACC-007`, `3:ACC-008`, `3:ACC-011`, `3:ACC-012`, `3:ACC-017`, `3:ACC-020`, `3:EDT-010` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-114` |
| `IPAD-L1-100` | Clavier, Option + flèches et aide | `3:EDT-009`, `3:ELM-011`, `3:ELM-012`, `3:ELM-013`, `3:ACC-005`, `3:ACC-013`, `3:ACC-014`, `3:ACC-015` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-115` |
| `IPAD-L1-101` | Fonctionnement local hors ligne | `3:LOC-001`, `3:SEC-001`, `3:ERR-008` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-116` |
| `IPAD-L1-102` | Store du prototype 2.1 ignoré | `3:DEC-33`, `3:LOC-029` à `3:LOC-031` | 🟢 `RÉUSSI` |
| `IPAD-L1-103` | Enveloppe 100 pages et 20 occurrences photo | `3:PAG-012`, sous-périmètre photo de `3:LOC-018`, `3:PERF-008`, `3:PERF-015`, `3:PERF-017` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-117` |
| `IPAD-L1-104` | Matrice commandes, icônes et états en largeurs régulière/compacte | sous-périmètre Lot 1 de `3:EDT-003`, `3:EDT-004`, `3:EDT-007`, `3:EDT-010`, `3:EDT-012`, `3:EDT-013`, `3:EDT-014`, `3:EDT-015`, `3:EDT-016`, `3:EDT-017`, `3:FRM-005`, `3:FRM-006` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-118` |
| `IPAD-L1-105` | Réduire les animations | `3:ACC-006`, sous-périmètre Lot 1 de `3:TST-010` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-119` |
| `IPAD-L1-106` | Aide contextuelle disponible hors ligne | sous-périmètre Lot 1 de `3:EDT-019`, `3:ARC-014`, `3:DEC-38` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-120` |
| `IPAD-L1-107` | Progression, annulation et nettoyage d’un import long | `3:APL-006`, `3:PERF-009`, `3:PERF-011`, `3:APP-006`, `3:SEC-008` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-121` |
| `IPAD-L1-108` | Commandes rapides sérialisées sans perte ni erreur de révision | `3:APP-002`, `3:APP-005`, `3:LOC-011` à `3:LOC-014`, `3:UND-011` | ⚫ `NON APPLICABLE` — fiche obsolète, remplacée par `IPAD-L1-131` |
| `IPAD-L1-109` | Interruption et sauvegarde après correctifs gestuels | `3:SAV-001`, `3:LOC-011` à `3:LOC-014`, `3:LOC-026` | 🟢 `RÉUSSI` |
| `IPAD-L1-110` | Prévisualisation et fonds mis en cache | `3:CAN-003`, `3:CAN-004`, `3:CAN-008`, `3:PERF-016` | 🟢 `RÉUSSI` |
| `IPAD-L1-111` | Cadre vide et mode de choix explicite | `3:FRM-001`, `3:FRM-008`, `3:PHO-011` à `3:PHO-013` | 🟢 `RÉUSSI` — annonce visuelle à renforcer |
| `IPAD-L1-112` | Qualité informative et format régional | `3:QLT-001` à `3:QLT-006`, `3:EDT-021`, `3:L10N-005` | 🟠 `BLOQUÉ` — procédure régionale non comprise |
| `IPAD-L1-113` | Inspecteur droit et adaptation compacte | `3:EDT-002`, `3:EDT-006`, `3:EDT-021`, `3:ACC-021` | 🔴 `ÉCHOUÉ` — grille tronquée et ajout local étiré |
| `IPAD-L1-114` | Dynamic Type, choix non ambigu et VoiceOver | `3:ELM-002`, `3:ELM-014`, `3:ACC-001` à `3:ACC-020` | 🟢 `RÉUSSI` |
| `IPAD-L1-115` | Pointeur, poignées hybrides et rotation directe | `3:ELM-002`, `3:ELM-011` à `3:ELM-013`, `3:ACC-013` à `3:ACC-015` | 🟢 `RÉUSSI` |
| `IPAD-L1-116` | Relance locale et cache des fonds hors ligne | `3:LOC-001`, `3:SEC-001`, `3:PERF-007`, `3:PERF-016` | 🟢 `RÉUSSI` |
| `IPAD-L1-117` | Cent pages, compteurs et déplacement continu | `3:PAG-012`, `3:PHO-002`, `3:PERF-008`, `3:PERF-015`, `3:PERF-017` | 🟢 `RÉUSSI` |
| `IPAD-L1-118` | Matrice des commandes dans le nouvel inspecteur | `3:EDT-010` à `3:EDT-017`, `3:EDT-021`, `3:FRM-005`, `3:FRM-006` | 🟢 `RÉUSSI` |
| `IPAD-L1-119` | Réduire les animations avec inspecteur droit | `3:ACC-006`, `3:EDT-002`, sous-périmètre Lot 1 de `3:TST-010` | 🟢 `RÉUSSI` |
| `IPAD-L1-120` | Aide contextuelle depuis le nouvel inspecteur | `3:EDT-019`, `3:EDT-021`, `3:ARC-014`, `3:DEC-38` | 🟢 `RÉUSSI` |
| `IPAD-L1-121` | Import long, annulation et déduplication | `3:APL-006`, `3:PHO-019`, `3:PERF-009`, `3:PERF-011`, `3:SEC-008` | 🟢 `RÉUSSI` |
| `IPAD-L1-122` | Lancement et réouverture rapide des Fonds | `3:PERF-004`, `3:PERF-007`, `3:PERF-016`, `3:BG-008` | 🟢 `RÉUSSI` |
| `IPAD-L1-123` | Retour après création et dates de corbeille | `3:ALB-006`, `3:ALB-017` à `3:ALB-025` | 🔴 `ÉCHOUÉ` — dates en anglais |
| `IPAD-L1-124` | Compteur exact et grilles photo carrées | `3:PHO-002`, `3:PHO-009`, `3:PHO-015`, `3:PHO-019` | 🟠 `BLOQUÉ` — occurrence cible non créée |
| `IPAD-L1-125` | Modes Ajouter, Remplir et Remplacer explicites | `3:PHO-004`, `3:PHO-011` à `3:PHO-013`, `3:FRM-004` | 🟢 `RÉUSSI` |
| `IPAD-L1-126` | Insertion de page et activation après Rétablir | `3:PAG-004`, `3:PAG-005`, `3:PAG-010`, `3:PAG-016` | 🔴 `ÉCHOUÉ` — signaux visuels insuffisants |
| `IPAD-L1-127` | Sélection non ambiguë, poignées hybrides et rotation | `3:ELM-002`, `3:ELM-013`, `3:ELM-014`, `3:EDT-021` | 🟢 `RÉUSSI` |
| `IPAD-L1-128` | Pincement, panoramique et balayage après retour | `3:ZOM-003` à `3:ZOM-006`, `3:NAV-001` à `3:NAV-007` | 🔴 `ÉCHOUÉ` — canevas sans réponse hors sélection |
| `IPAD-L1-129` | Sauvegarde au milieu d’un déplacement | `3:ELM-007`, `3:SAV-001` à `3:SAV-003`, `3:UND-007` | 🟢 `RÉUSSI` |
| `IPAD-L1-130` | Presse-papiers strictement limité à la session | `3:CLP-001` à `3:CLP-006`, `3:UND-012` | 🟢 `RÉUSSI` |
| `IPAD-L1-131` | Commandes rapides après correction des transitions d’interface | `3:ALB-006`, `3:APP-002`, `3:APP-005`, `3:EDT-021`, `3:LOC-011` à `3:LOC-014`, `3:UND-011` | 🟢 `RÉUSSI` |
| `IPAD-L1-132` | Compilation du correctif dans Swift Playgrounds | `3:ENV-001` à `3:ENV-005`, `3:LOT-001`, `3:DONE-005` | 🔴 `ÉCHOUÉ` — appel `catalogImage(for:)` incomplet dans `AlbumCoverView` |
| `IPAD-L1-133` | Recompilation après correction de tous les appels catalogue | `3:ENV-001` à `3:ENV-005`, `3:LOT-001`, `3:DONE-005` | 🟢 `RÉUSSI` |
| `IPAD-L1-134` | Compilation du candidat `7a0f2a4…` | `3:ENV-001` à `3:ENV-005`, `3:LOT-001`, `3:DONE-005` | 🟢 `RÉUSSI` |
| `IPAD-L1-135` | Bannière de choix et inspecteur adaptatif | `3:EDT-002`, `3:EDT-020`, `3:PHO-011`, `3:ACC-021` | 🔴 `ÉCHOUÉ` — miniatures et action locale encore tronquées |
| `IPAD-L1-136` | Dates françaises de corbeille | `3:ALB-025`, `3:L10N-005` | 🟢 `RÉUSSI` |
| `IPAD-L1-137` | Page active et insertion entre miniatures | `3:GLO-003`, `3:PAG-016`, `3:ACC-006` | 🟢 `RÉUSSI` |
| `IPAD-L1-138` | Gestes canevas sur vide et cadres non sélectionnés | `3:ZOM-003` à `3:ZOM-006`, `3:NAV-005` | 🟢 `RÉUSSI` |
| `IPAD-L1-139` | Qualité et séparateurs régionaux explicités | `3:QLT-001` à `3:QLT-006`, `3:L10N-005` | 🟢 `RÉUSSI` |
| `IPAD-L1-140` | Compteur autonome après réutilisation interalbum | `3:PHO-002`, `3:PHO-015` à `3:PHO-019` | 🟢 `RÉUSSI` — présentation de grille désormais à rejouer sous `144` |
| `IPAD-L1-141` | Compilation du candidat `48e9fef…` | `3:ENV-001` à `3:ENV-005`, `3:LOT-001`, `3:DONE-005` | 🟢 `RÉUSSI` — preuve indirecte par l’exécution fonctionnelle de `142` |
| `IPAD-L1-142` | Trois colonnes contraintes et action locale adaptative | `3:EDT-002`, `3:EDT-020`, `3:PHO-002`, `3:PHO-011`, `3:PHO-019`, `3:ACC-021` | 🔴 `ÉCHOUÉ` — portrait toujours débordant, accès Photos/Fonds absent |
| `IPAD-L1-143` | Compilation du correctif de largeur globale | `3:ENV-001` à `3:ENV-005`, `3:LOT-001`, `3:DONE-005` | 🟢 `RÉUSSI` — preuve indirecte par l’exécution fonctionnelle de `144` |
| `IPAD-L1-144` | Rail, inspecteur et commandes du canevas entièrement adaptatifs | `3:EDT-002`, `3:EDT-020`, `3:PHO-002`, `3:PHO-011`, `3:PHO-019`, `3:ACC-021` | 🟢 `RÉUSSI` |
| `IPAD-L2-001` | Compilation, ouverture du store Lot 1 et nouvelle interface | `3:ENV-001` à `3:ENV-005`, `3:LOT-003`, `3:DAT-042`, `3:DONE-005` | 🟢 `RÉUSSI` |
| `IPAD-L2-002` | Panneau Mise en page adaptatif, groupes et miniatures | `3:EDT-001`, `3:EDT-002`, `3:EDT-006`, `3:TPL-001` à `3:TPL-003`, `3:ACC-021` | 🔴 `ÉCHOUÉ` — rail et inspecteur encore légèrement rognés en portrait |
| `IPAD-L2-003` | Modèle plus grand, conservation et Annuler/Rétablir | `3:TPL-004` à `3:TPL-006`, `3:TPL-009`, `3:TPL-010`, `3:TPL-014` à `3:TPL-017`, `3:DAT-042` | 🟢 `RÉUSSI` |
| `IPAD-L2-004` | Modèle plus petit, confirmation exacte et atomicité | `3:TPL-005` à `3:TPL-010`, `3:TPL-016`, `3:ERR-022` | 🔴 `ÉCHOUÉ` — Appliquer dans la confirmation ne produit aucun changement |
| `IPAD-L2-005` | Dé compatible, sac sans répétition et persistance | `3:RND-001` à `3:RND-006`, `3:TPL-018`, `3:DAT-042` | 🟢 `RÉUSSI` — découvrabilité et emplacement du dé à revoir séparément |
| `IPAD-L2-006` | Activation Auto, ajouts/retraits et désactivation manuelle | `3:AUT-001` à `3:AUT-008`, `3:AUT-012` à `3:AUT-019`, `3:PHO-014` | 🟢 `RÉUSSI` |
| `IPAD-L2-007` | Densité, portée par page, relance et Annuler/Rétablir | `3:AUT-001`, `3:AUT-003` à `3:AUT-005`, `3:AUT-012`, `3:AUT-015` à `3:AUT-018`, `3:DAT-037` | 🟢 `RÉUSSI` |
| `IPAD-L2-008` | Commandes incompatibles, aide et non-exposition du reste du Lot 2 | `3:AUT-019`, `3:EDT-003`, `3:EDT-004`, `3:EDT-019`, `3:ARC-014`, `3:CAT-009` | 🟠 `BLOQUÉ` — menu Plus compact inaccessible dans Swift Playgrounds sur cet iPad |
| `IPAD-L2-009` | Compilation du correctif et compatibilité du store Lot 1 | `3:ENV-001` à `3:ENV-005`, `3:LOT-003`, `3:DAT-042`, `3:DONE-005` | 🟢 `RÉUSSI` |
| `IPAD-L2-010` | Marges portrait, panneau droit et replis indépendants | `3:EDT-002`, `3:EDT-006`, `3:EDT-021`, `3:ACC-006`, `3:ACC-021` | 🟢 `RÉUSSI` |
| `IPAD-L2-011` | Régression de la confirmation Appliquer pour un modèle plus petit | `3:TPL-005` à `3:TPL-010`, `3:TPL-016`, `3:ERR-022` | 🟢 `RÉUSSI` |
| `IPAD-L2-012` | Nom long dans la sélection et nouvelle commande de disposition aléatoire | `3:ELM-014`, `3:ACC-002`, `3:RND-001` à `3:RND-005`, `3:TPL-018`, `3:EDT-020` | 🟢 `RÉUSSI` |
| `IPAD-L2-013` | Ajouter une page sous le canevas et mode Gérer les pages | `3:EDT-003`, `3:EDT-008`, `3:EDT-012`, `3:EDT-016`, `3:EDT-020`, `3:PAG-002`, `3:PAG-013` à `3:PAG-015`, `3:PHO-004`, `3:PHO-011`, `3:ACC-002`, `3:ACC-021` | 🟢 `RÉUSSI` |
| `IPAD-L2-014` | Ajout en fin, confirmation et réglage temporaire | `3:ENV-001` à `3:ENV-005`, `3:EDT-008`, `3:EDT-012`, `3:EDT-016`, `3:PAG-002`, `3:PAG-013` à `3:PAG-017`, `3:UND-001`, `3:UND-002`, `3:SAV-001`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` | 🔴 `ÉCHOUÉ` — fenêtre trop large et trop basse ; pied de texte visible seulement après défilement |
| `IPAD-L2-015` | Taille intrinsèque et lisibilité de la confirmation d’ajout | `3:ENV-001` à `3:ENV-005`, `3:PAG-017`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` | 🔴 `ÉCHOUÉ` — fenêtre minuscule et illisible |
| `IPAD-L2-016` | Cadre lisible de la confirmation d’ajout | `3:ENV-001` à `3:ENV-005`, `3:PAG-017`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` | 🔴 `ÉCHOUÉ` — le bouton fige l’app et aucune confirmation n’apparaît |
| `IPAD-L2-017` | Dialogue interne sans gel pour l’ajout de page | `3:ENV-001` à `3:ENV-005`, `3:PAG-017`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` | 🟢 `RÉUSSI` |
| `IPAD-L2-018` | Remplir l’album, trois densités et commande unique | `3:AUT-009` à `3:AUT-012`, `3:FRM-009`, `3:TPL-005`, `3:UND-001`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-019` | Bouton compact, dialogue de densité et cadrage initial couvrant | `3:DEC-07`, section 3.1, `3:AUT-002`, `3:AUT-004`, `3:AUT-009` à `3:AUT-011`, `3:PHO-005`, `3:PHO-006`, `3:PHO-014`, `3:FRM-004`, `3:FRM-009`, `3:CRP-001`, `3:CRP-004` à `3:CRP-007`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-020` | Création, édition riche et rendu des zones de texte | `3:TBX-001` à `3:TBX-010`, `3:TBX-012` à `3:TBX-020`, `3:TBX-023` à `3:TBX-025`, `3:TPL-012`, `3:TPL-013`, `3:TPL-017`, `3:TXA-001`, `3:TXA-002`, `3:TXA-004`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` | 🔴 `ÉCHOUÉ` — compilation impossible dans `AlbumTextEditorView` |
| `IPAD-L2-021` | Compilation corrigée et qualification complète des zones de texte | `3:TBX-001` à `3:TBX-010`, `3:TBX-012` à `3:TBX-020`, `3:TBX-023` à `3:TBX-025`, `3:TPL-012`, `3:TPL-013`, `3:TPL-017`, `3:TXA-001`, `3:TXA-002`, `3:TXA-004`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` | 🔴 `ÉCHOUÉ` — compilation réussie, cinq défauts d’interface/rendu |
| `IPAD-L2-022` | Panneau Texte, palette, échelle et opacité | `3:EDT-001`, `3:EDT-002`, `3:EDT-006`, `3:EDT-008`, `3:EDT-012`, `3:EDT-014`, `3:EDT-021`, `3:TBX-001` à `3:TBX-020`, `3:TBX-023` à `3:TBX-025`, `3:TPL-012`, `3:TPL-013`, `3:TPL-017`, `3:TXA-001`, `3:TXA-002`, `3:TXA-004`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` | 🔴 `ÉCHOUÉ` — saisie pratiquement invisible dans l’éditeur à l’étape 4 |
| `IPAD-L2-023` | Compilation et saisie visible | `3:ENV-001` à `3:ENV-005`, `3:TBX-002` à `3:TBX-005`, `3:TBX-014`, `3:TBX-025`, `3:DONE-005` | 🔴 `ÉCHOUÉ` — étape 4 : descendantes rognées sur une seule ligne ; motif parfois rendu devant l’éditeur |
| `IPAD-L2-024` | Panneau Texte, raccourcis et inspecteur | `3:EDT-001`, `3:EDT-006`, `3:EDT-008`, `3:EDT-012`, `3:EDT-014`, `3:EDT-021`, `3:TBX-002`, `3:TBX-009`, `3:UND-001` | 🔴 `ÉCHOUÉ` — étape 1 rejetée : éléments à ajouter demandés dans un groupe distinct ; étapes 2 à 4 réussies |
| `IPAD-L2-025` | Taille et opacité cohérentes | `3:TBX-010`, `3:TBX-012`, `3:TBX-014`, `3:TBX-024` | 🔴 `ÉCHOUÉ` — sélection perdue à la fermeture du clavier et portée des formats insuffisamment explicite |
| `IPAD-L2-026` | Fond réel et palette colorée | `3:TBX-010`, `3:TBX-015`, `3:TBX-016`, `3:TBX-025`, `3:BG-011`, `3:BG-016` | 🔴 `ÉCHOUÉ` — étapes 1 et 2 : palette non défilable et sélection perdue sans clavier en paysage |
| `IPAD-L2-027` | Sélections, paragraphes et limite | `3:TBX-006` à `3:TBX-011`, `3:TBX-013`, `3:TBX-017`, `3:TBX-023`, `3:TXA-001`, `3:TXA-002`, `3:TXA-004` | 🔴 `ÉCHOUÉ` — étape 1 : Système/Arrondie identiques et Italique sans effet perceptible |
| `IPAD-L2-028` | Géométrie, débordement et modèle texte | `3:TBX-018` à `3:TBX-021`, `3:TPL-012`, `3:TPL-013`, `3:TPL-017` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-029` | Profondeur, persistance et accessibilité | `3:TBX-001`, `3:TBX-004`, `3:TBX-023`, `3:TBX-024`, `3:UND-001`, `3:SAV-001`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-030` | Compilation, descendantes et motifs intégrés | `3:ENV-001` à `3:ENV-005`, `3:CAN-003`, `3:BG-007`, `3:TBX-002` à `3:TBX-005`, `3:TBX-019`, `3:TBX-020`, `3:TBX-024`, `3:TBX-025`, `3:DONE-005` | 🔴 `ÉCHOUÉ` — étapes 1 à 3 réussies ; les trois motifs recouvrent encore l’éditeur à l’étape 4, couleurs unies conformes |
| `IPAD-L2-031` | Ordre et séparation sans titre des panneaux | `3:DEC-32`, `3:EDT-001`, `3:EDT-002`, `3:EDT-006`, `3:EDT-012`, `3:EDT-021`, `3:ACC-021` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-032` | Sélection, palette et portées en paysage | `3:TBX-005`, `3:TBX-010` à `3:TBX-012`, `3:TBX-015`, `3:TBX-016`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-033` | Polices, italique et persistance de la sélection | `3:TBX-010`, `3:TBX-013`, `3:TBX-023`, `3:TBX-024`, `3:SAV-001`, `3:ACC-002` | 🔴 `ÉCHOUÉ` — Système/Arrondie trop proches et Italique sans effet sur Arrondie ; étapes 3 et 4 déclarées conformes |
| `IPAD-L2-034` | Motifs strictement bornés dans l’éditeur | `3:ENV-001` à `3:ENV-005`, `3:CAN-003`, `3:BG-007`, `3:TBX-024`, `3:TBX-025`, `3:DONE-005` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-035` | Arrondie, italique et choix actifs | `3:TBX-009` à `3:TBX-016`, `3:TBX-023`, `3:TBX-024`, `3:TBX-026`, `3:SAV-001`, `3:ACC-002`, `3:ACC-004` | 🟢 `RÉUSSI` — retour global ; boutons de format jugés trop larges, reprise future `TBX-027` |
| `IPAD-L2-036` | Info, version et commit exact du candidat | `3:ENV-001` à `3:ENV-005`, `3:APP-001`, `3:APP-012`, `3:ACC-001` à `3:ACC-004`, `3:ACC-008`, `3:DONE-005` | 🔴 `ÉCHOUÉ` — Commit affiche `Non estampillé` ; le hash exact et sa copie ne sont pas prouvés, reste déclaré conforme globalement |
| `IPAD-L2-037` | Motifs strictement bornés sur le candidat Info | `3:CAN-003`, `3:BG-007`, `3:TBX-024`, `3:TBX-025` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-038` | Arrondie, italique et choix actifs sur le candidat Info | `3:TBX-009` à `3:TBX-016`, `3:TBX-023`, `3:TBX-024`, `3:TBX-026`, `3:SAV-001`, `3:ACC-002`, `3:ACC-004` | 🟢 `RÉUSSI` — retour global sans capture ni détail par étape |
| `IPAD-L2-039` | Compilation, lancement et surface finale Lot 2 | `3:ENV-001` à `3:ENV-005`, `3:EDT-001`, `3:EDT-002`, `3:EDT-006`, `3:EDT-012`, `3:EDT-021`, `3:DONE-005` | 🔴 `ÉCHOUÉ` — compilation impossible dans `AppModel` ligne 256 |
| `IPAD-L2-040` | Boutons texte compacts et justification de page | `3:TBX-009` à `3:TBX-016`, `3:TBX-023` à `3:TBX-027`, `3:CAN-008`, `3:ACC-002`, `3:ACC-004` | ⚪ `NON TESTÉ` — archive ; remplacé par `056` |
| `IPAD-L2-041` | Sessions de frappe, Annuler et historique à 750 ms | `3:TBX-002` à `3:TBX-005`, `3:TBX-022`, `3:TBX-025`, `3:UND-001`, `3:UND-008`, `3:SAV-001` | ⚪ `NON TESTÉ` — archive ; remplacé par `057` |
| `IPAD-L2-042` | Limite et collage riche filtré | `3:TBX-006` à `3:TBX-008`, `3:TBX-010`, `3:TBX-017`, `3:TBX-023`, `3:CLP-005`, `3:ACC-002` | ⚪ `NON TESTÉ` — archive ; remplacé par `058` |
| `IPAD-L2-043` | Débordement et blocage de la prévisualisation | `3:TBX-018` à `3:TBX-021`, `3:TBX-024`, `3:CAN-008`, `3:ACC-002`, `3:ACC-006` | ⚪ `NON TESTÉ` — archive ; remplacé par `059` |
| `IPAD-L2-044` | Catalogue, catégories, recherche et récents des stickers | `3:STK-001` à `3:STK-003`, `3:STK-006`, `3:STK-009` à `3:STK-012`, `3:CAT-001`, `3:CAT-009` | ⚪ `NON TESTÉ` — archive ; remplacé par `060` |
| `IPAD-L2-045` | Ajout, dépôt et géométrie des stickers | `3:STK-004`, `3:STK-005`, `3:STK-008`, `3:STK-015`, `3:STK-023`, `3:STK-024`, `3:ELM-001` à `3:ELM-004` | ⚪ `NON TESTÉ` — archive ; remplacé par `061` |
| `IPAD-L2-046` | Remplacement et commandes d’un sticker | `3:STK-007`, `3:STK-014` à `3:STK-016`, `3:STK-022`, `3:ELM-008`, `3:UND-001` | ⚪ `NON TESTÉ` — archive ; remplacé par `062` |
| `IPAD-L2-047` | Rendu, profondeur et persistance des stickers | `3:STK-009`, `3:STK-024`, `3:CAN-008`, `3:SAV-001`, `3:ACC-006` | ⚪ `NON TESTÉ` — archive ; remplacé par `063` |
| `IPAD-L2-048` | Six formes et conservation du cadrage photo | `3:SHR-001` à `3:SHR-003`, `3:SHR-006`, `3:SHR-010`, `3:SHR-012`, `3:CRP-001`, `3:CRP-007` | ⚪ `NON TESTÉ` — archive ; remplacé par `064` |
| `IPAD-L2-049` | Contours et six cadres décoratifs | `3:SHR-004`, `3:SHR-005`, `3:SHR-009`, `3:SHR-011`, `3:SHR-013`, `3:SHR-014`, `3:CAN-008` | ⚪ `NON TESTÉ` — archive ; remplacé par `065` |
| `IPAD-L2-050` | Portées Sélection, Page et Album | `3:SHR-007`, `3:SHR-008`, `3:UND-001`, `3:SAV-001`, `3:ACC-002` | ⚪ `NON TESTÉ` — archive ; remplacé par `066` |
| `IPAD-L2-051` | Copier et coller photo, texte et sticker | `3:CLP-001`, `3:CLP-003`, `3:CLP-004`, `3:ELM-009`, `3:FRM-007`, `3:SAV-001` | ⚪ `NON TESTÉ` — archive ; remplacé par `067` |
| `IPAD-L2-052` | Couper, annuler et invalider le presse-papiers | `3:CLP-002`, `3:CLP-004`, `3:CLP-006`, `3:UND-001`, `3:UND-002`, `3:SAV-001` | ⚪ `NON TESTÉ` — archive ; remplacé par `068` |
| `IPAD-L2-053` | Aide et accessibilité du périmètre Lot 2 | `3:EDT-019`, `3:STK-022`, `3:ACC-001` à `3:ACC-008`, `3:ACC-020`, `3:ACC-021` | ⚪ `NON TESTÉ` — archive ; remplacé par `069` |
| `IPAD-L2-054` | Fluidité à vingt stickers et avertissement au-delà | `3:STK-021`, `3:PERF-005`, `3:PERF-015`, `3:PERF-017`, `3:ACC-002` | ⚪ `NON TESTÉ` — archive ; remplacé par `070` |
| `IPAD-L2-055` | Compilation corrigée, lancement et surface finale Lot 2 | `3:ENV-001` à `3:ENV-005`, `3:EDT-001`, `3:EDT-002`, `3:EDT-006`, `3:EDT-012`, `3:EDT-021`, `3:DONE-005` | 🟢 `RÉUSSI` — retour fourni sous l’ancien libellé `039` |
| `IPAD-L2-056` | Boutons texte compacts et justification de page | `3:TBX-009` à `3:TBX-016`, `3:TBX-023` à `3:TBX-027`, `3:CAN-008`, `3:ACC-002`, `3:ACC-004` | 🟢 `RÉUSSI` — retour global sans détail par étape |
| `IPAD-L2-057` | Sessions de frappe, Annuler et historique à 750 ms | `3:TBX-002` à `3:TBX-005`, `3:TBX-022`, `3:TBX-025`, `3:UND-001`, `3:UND-008`, `3:SAV-001` | 🟢 `RÉUSSI` — retour global sans détail par étape |
| `IPAD-L2-058` | Limite et collage riche filtré | `3:TBX-006` à `3:TBX-008`, `3:TBX-010`, `3:TBX-017`, `3:TBX-023`, `3:CLP-005`, `3:ACC-002` | 🔴 `ÉCHOUÉ` — Annuler ne restaure pas l’état avant collage ; gras et italique perdus après filtrage |
| `IPAD-L2-059` | Débordement et blocage de la prévisualisation | `3:TBX-018` à `3:TBX-021`, `3:TBX-024`, `3:CAN-008`, `3:ACC-002`, `3:ACC-006` | 🟢 `RÉUSSI` — retour global ; Exporter reste réservé au Lot 3 |
| `IPAD-L2-060` | Catalogue, catégories, recherche et récents des stickers | `3:STK-001` à `3:STK-003`, `3:STK-006`, `3:STK-009` à `3:STK-012`, `3:CAT-001`, `3:CAT-009` | 🟢 `RÉUSSI` — retour global sans détail par étape |
| `IPAD-L2-061` | Ajout, dépôt et géométrie des stickers | `3:STK-004`, `3:STK-005`, `3:STK-008`, `3:STK-015`, `3:STK-023`, `3:STK-024`, `3:ELM-001` à `3:ELM-004`, `3:COV-007`, `3:CAN-008` | 🔴 `ÉCHOUÉ` — dépôt refusé, poignées envahissantes à petite taille et sticker absent de la miniature d’album |
| `IPAD-L2-062` | Remplacement et commandes d’un sticker | `3:STK-007`, `3:STK-014` à `3:STK-016`, `3:STK-022`, `3:ELM-008`, `3:UND-001` | 🔴 `ÉCHOUÉ` — choix incohérent visuellement et ajout au lieu du remplacement |
| `IPAD-L2-063` | Rendu, profondeur et persistance des stickers | `3:STK-009`, `3:STK-024`, `3:CAN-008`, `3:SAV-001`, `3:ACC-006` | 🟢 `RÉUSSI` — retour global ; la miniature d’album hors fiche reste en anomalie |
| `IPAD-L2-064` | Six formes et conservation du cadrage photo | `3:SHR-001` à `3:SHR-003`, `3:SHR-006`, `3:SHR-010`, `3:SHR-012`, `3:CRP-001`, `3:CRP-007` | 🟢 `RÉUSSI` — retour global sans détail par étape |
| `IPAD-L2-065` | Contours et six cadres décoratifs | `3:SHR-004`, `3:SHR-005`, `3:SHR-009`, `3:SHR-011`, `3:SHR-013`, `3:SHR-014`, `3:CAN-008` | 🔴 `ÉCHOUÉ` — cadres décoratifs décalés du bord, photo visible derrière |
| `IPAD-L2-066` | Portées Sélection, Page et Album | `3:SHR-007`, `3:SHR-008`, `3:UND-001`, `3:SAV-001`, `3:ACC-002` | 🟢 `RÉUSSI` — retour global sans détail par étape |
| `IPAD-L2-067` | Copier et coller photo, texte et sticker | `3:CLP-001`, `3:CLP-003`, `3:CLP-004`, `3:ELM-009`, `3:FRM-007`, `3:SAV-001` | 🟢 `RÉUSSI` — retour global sans détail par étape |
| `IPAD-L2-068` | Couper, annuler et invalider le presse-papiers | `3:CLP-002`, `3:CLP-004`, `3:CLP-006`, `3:UND-001`, `3:UND-002`, `3:SAV-001` | 🟢 `RÉUSSI` — retour global sans détail par étape |
| `IPAD-L2-069` | Aide et accessibilité du périmètre Lot 2 | `3:EDT-019`, `3:STK-022`, `3:ACC-001` à `3:ACC-008`, `3:ACC-020`, `3:ACC-021` | 🟢 `RÉUSSI` — retour global sans détail par étape |
| `IPAD-L2-070` | Fluidité à vingt stickers et avertissement au-delà | `3:STK-021`, `3:PERF-005`, `3:PERF-015`, `3:PERF-017`, `3:ACC-002` | 🟢 `RÉUSSI` — retour global sans détail par étape |
| `IPAD-L2-071` | Régression du collage riche et de l’annulation de limite | `3:ENV-001` à `3:ENV-005`, `3:TBX-004`, `3:TBX-006` à `3:TBX-008`, `3:TBX-017`, `3:TBX-023`, `3:CLP-005`, `3:DONE-005` | ⚪ `NON TESTÉ` |
| `IPAD-L2-072` | Régression du dépôt, des commandes et de la miniature sticker | `3:STK-004`, `3:STK-005`, `3:STK-008`, `3:STK-015`, `3:STK-023`, `3:STK-024`, `3:ELM-002`, `3:ACC-003`, `3:COV-007`, `3:CAN-008` | ⚪ `NON TESTÉ` |
| `IPAD-L2-073` | Régression du remplacement réel d’un sticker | `3:STK-007`, `3:STK-014` à `3:STK-016`, `3:STK-022`, `3:ELM-008`, `3:UND-001` | ⚪ `NON TESTÉ` |
| `IPAD-L2-074` | Régression de l’alignement des cadres décoratifs | `3:SHR-004`, `3:SHR-005`, `3:SHR-009`, `3:SHR-011`, `3:SHR-013`, `3:SHR-014`, `3:CAN-008` | ⚪ `NON TESTÉ` |

## Fiches détaillées

### `IPAD-L1-063` — Compilation et lancement sur racine 3.0 neuve

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:LOT-001`, `3:ENV-002`, `3:ENV-005`, `3:LOC-029`,
  `3:LOC-031`, `3:DONE-005`.
- Préconditions : transférer exactement `Albumzh.swiftpm` du candidat ; choisir
  un appareil où aucune donnée 3.0 n’est requise, ou désinstaller uniquement
  l’app de test après avoir confirmé que son bac à sable est jetable ; ne pas
  supprimer le package source dans Swift Playgrounds.
- Étapes :
  1. ouvrir `Albumzh.swiftpm` dans Swift Playgrounds ;
  2. lancer la compilation sans modifier les sources ni le manifeste généré ;
  3. démarrer l’app en plein écran ;
  4. attendre l’affichage complet de la bibliothèque ;
  5. fermer l’app depuis le sélecteur d’apps puis la relancer une fois.
- Résultat attendu : compilation et lancement sans erreur, écran racine « Mes
  albums », état vide utilisable, aucune donnée exemple ni erreur de stockage,
  et second lancement identique. Seule une racine 3.0 valide est présentée ;
  une initialisation partielle n’est jamais affichée comme réussie.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Compilation et deux lancements réussis. Anomalie hors verdict : environ 15 s avant la bibliothèque à chaque relance.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-064` — État vide, noms, création et durabilité

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ALB-004`, sous-périmètre Créer de `3:ALB-009`,
  `3:ALB-011` à `3:ALB-016`, `3:APP-005`, `3:LOC-011`, `3:LOC-012`,
  `3:LOC-013`, `3:ACPT-100`.
- Préconditions : `IPAD-L1-063` réussi ; bibliothèque vide.
- Étapes :
  1. vérifier l’état vide et l’action « Créer un album » ;
  2. ouvrir la création, saisir seulement trois espaces et vérifier que Créer
     reste désactivé ;
  3. saisir `  Guatemala  ` puis valider ;
  4. vérifier l’ouverture immédiate de l’éditeur sur sa première page vide et
     son fond Album classique à spirales ;
  5. ajouter une page, attendre l’état Enregistré, puis interrompre le processus
     depuis le sélecteur d’apps sans revenir à la bibliothèque ;
  6. relancer, ouvrir `Guatemala` et vérifier ses deux pages ainsi que leur fond
     Album classique sans message de récupération ou corruption ;
  7. revenir aux albums et créer successivement deux albums nommés exactement
     `Voyage`.
- Résultat attendu : le nom vide est refusé ; les espaces extérieurs sont
  retirés ; l’album existe durablement avant l’ouverture ; après interruption,
  `Guatemala`, ses deux pages et leurs fonds réapparaissent sans corruption ;
  deux albums homonymes sont acceptés et restent deux objets distincts.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Toutes les étapes prévues ont réussi. Après la création et l’ouverture automatique, « Retour aux albums » est resté sans effet ; le retour fonctionne après relance et ouverture manuelle.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-065` — Grille, cartes, tri et durabilité de la bibliothèque

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ALB-001` à `3:ALB-003`, `3:ALB-006`, `3:ALB-010`,
  `3:APP-001`, `3:APP-005`, `3:L10N-005`.
- Préconditions : disposer de `Guatemala` et des deux albums `Voyage` créés en
  `IPAD-L1-064` ; créer un quatrième album `Famille test`.
- Étapes :
  1. observer pour chaque carte la couverture, le nom, le nombre de pages et
     la date de modification formatée par le système ;
  2. ouvrir l’un des albums `Voyage`, ajouter une page, puis revenir ;
  3. vérifier que cet album passe en tête sans confondre l’autre homonyme ;
  4. forcer la fermeture de l’app puis la relancer ;
  5. rouvrir les trois albums, même si une miniature tarde à apparaître.
- Résultat attendu : grille adaptative, tri décroissant par modification,
  cartes homonymes distinctes, quatre albums et ordre conservés après relance ;
  une miniature absente ou en chargement ne bloque jamais l’ouverture.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-066` — Renommage ciblé et pile Annuler/Rétablir

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : sous-périmètre Renommer de `3:ALB-007`, `3:ALB-011`,
  `3:ALB-021`, `3:UND-011`. Choisir la couverture est couvert par
  `IPAD-L1-074` ; Exporter reste différé au Lot 3.
- Préconditions : deux albums homonymes `Voyage` et un album `Famille test` ;
  rester dans la bibliothèque.
- Étapes :
  1. ouvrir le menu contextuel du second `Voyage` et choisir Renommer ;
  2. saisir `Voyage B` puis confirmer ;
  3. vérifier que seul l’album ciblé a changé ;
  4. toucher Annuler et vérifier le retour à `Voyage` ;
  5. toucher Rétablir et vérifier `Voyage B` ;
  6. lancer le renommage de `Famille test`, puis annuler la feuille ;
  7. fermer et relancer l’app.
- Résultat attendu : aucune action ne touche la mauvaise carte ; Annuler et
  Rétablir agissent sur le même identifiant malgré les noms identiques ;
  annuler la feuille ne crée aucune commande ; `Voyage B` persiste après
  relance.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-067` — Corbeille, impossibilité d’éditer et restauration

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ALB-008`, `3:ALB-017`, `3:ALB-018`, `3:ALB-019`,
  `3:ACPT-102`, `3:DEC-16`, `3:DEC-25`.
- Préconditions : albums `Voyage`, `Voyage B` et `Famille test` présents ;
  `Voyage B` contient une seconde page, un fond distinct et une occurrence de
  `small-landscape-600x400.png`, afin que sa restauration soit vérifiable.
- Étapes :
  1. demander la mise en corbeille de `Voyage B` ;
  2. vérifier que la confirmation cite exactement `Voyage B`, puis Annuler ;
  3. confirmer lors d’une seconde tentative ;
  4. vérifier que `Voyage B` disparaît de la bibliothèque ;
  5. ouvrir Corbeille et vérifier le nom de l’album ainsi que sa date de
     suppression ;
  6. vérifier que la carte en corbeille ne propose ni Ouvrir ni Modifier et
     qu’une pression ne donne pas accès à l’éditeur ;
  7. restaurer `Voyage B`, fermer la corbeille et rouvrir l’album ;
  8. vérifier la seconde page, son fond et la photo, puis fermer et relancer
     l’app.
- Résultat attendu : Annuler ne modifie rien ; confirmer déplace uniquement
  la cible ; l’album en corbeille est non modifiable et absent de la liste
  active ; Restaurer rend son contenu intact et durable.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : Parcours métier réussi, mais Fonds prend environ 6 s à chaque ouverture, même après Photos dans le même album ; la corbeille affiche une échéance relative mêlant français et anglais et omet la date de mise à la corbeille.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-068` — Suppression définitive ciblée et blob partagé

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ALB-018`, `3:LOC-008`, `3:LOC-022`.
- Préconditions : créer `À supprimer A`, y importer et placer
  `small-landscape-600x400.png` ; créer `À supprimer B`, y réutiliser cette
  photo depuis A puis la placer. Les deux albums doivent donc posséder des
  assets logiques distincts résolvant le même `contentHash`. Mettre ensuite A
  et B dans la corbeille.
- Étapes :
  1. demander « Supprimer définitivement » pour `À supprimer A` ;
  2. vérifier que le dialogue cite A, puis Annuler ;
  3. vérifier que A et B sont toujours présents ;
  4. recommencer pour A et confirmer ;
  5. vérifier que B reste présent, puis le restaurer ;
  6. passer hors ligne, fermer et relancer l’app ;
  7. ouvrir B et vérifier que son occurrence affiche toujours exactement la
     fixture partagée.
- Résultat attendu : la confirmation cible l’identifiant choisi ; Annuler est
  sans effet ; confirmer retire définitivement A seulement ; B demeure intact
  après relance et sa photo reste résolue hors ligne. La suppression directe
  d’A ne purge donc pas le blob encore référencé par B. L’expiration automatique
  à trente jours de `3:ALB-020` n’est pas couverte par cette fiche.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Suppression ciblée et conservation du blob partagé réussies. Anomalie séparée : B ne contient qu’une occurrence visible mais sa miniature indique `×2`.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-069` — Bail d’édition multi-fenêtre

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:APP-002`, `3:APP-010`, `3:APP-011`, `3:DEC-29`.
- Préconditions : iPad permettant deux scènes de l’app ; album `Bail test` avec
  deux pages. Si Swift Playgrounds ne permet pas deux scènes, arrêter et
  répondre `BLOQUÉ` avec la limitation observée.
- Étapes :
  1. ouvrir `Bail test` dans une première fenêtre et laisser l’éditeur actif ;
  2. ouvrir le même album dans une seconde fenêtre ;
  3. tenter d’ajouter une page et de renommer depuis la seconde ;
  4. vérifier le message Lecture seule et l’action Réessayer ;
  5. fermer complètement la première scène ;
  6. toucher Réessayer dans la seconde, puis effectuer une modification ;
  7. terminer toutes les scènes, relancer l’app et rouvrir l’album.
- Résultat attendu : une seule scène modifie l’album ; la seconde explique la
  cause et ne propose aucune écriture effective ; Réessayer acquiert le bail
  après fermeture de la première ; le bail ne survit pas au processus et la
  modification persiste.
- Résultat : 🟠 `BLOQUÉ`.
- Preuve : Swift Playgrounds ne permet pas le multi-fenêtre sur cet iPad ; le bail concurrent ne peut pas être exercé.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-070` — Ajout, suppression et restauration d’une page remplie

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PAG-001`, `3:PAG-002`, `3:PAG-006`, `3:PAG-007`,
  `3:PAG-008`, `3:PAG-009`, `3:PAG-010`, `3:PAG-013`, `3:PAG-015`,
  `3:UND-004`.
- Préconditions : nouvel album `Pages test` sur sa seule page ; la fixture
  petite est disponible dans le panneau Photos.
- Étapes :
  1. vérifier `Page 1 sur 1` et l’indisponibilité de la suppression de la
     dernière page ;
  2. ajouter deux pages depuis la vue globale ;
  3. sur la page 2, choisir un fond distinct, ajouter un cadre rempli avec la
     fixture petite puis ajouter aussi un cadre vide reconnaissable ;
  4. demander la suppression de la page 2, puis Annuler ;
  5. recommencer et confirmer ;
  6. vérifier que la nouvelle page active est l’ancienne page 3 ;
  7. toucher Annuler et vérifier que la page 2 restaurée possède son fond, son
     cadre rempli, son placement photo et son cadre vide ;
  8. toucher Rétablir, vérifier leur disparition avec la page, puis fermer et
     relancer.
- Résultat attendu : chaque ajout est inséré après la page active avec fond
  Album classique et sans copie implicite ; la suppression exige une
  confirmation, retire tous les éléments de la page seulement, choisit la page
  suivante, reste annulable avec restauration exacte de ses deux cadres et du
  placement photo, puis rétablissable ; il reste toujours au moins une page et
  l’état final persiste.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-071` — Déplacer la page 5, la supprimer puis annuler

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PAG-003`, `3:PAG-004`, `3:PAG-005`, `3:PAG-011`,
  `3:PAG-014`, `3:GLO-003`, `3:GLO-004`, `3:GLO-005`, `3:UND-004`,
  `3:ACPT-104`.
- Préconditions : album de cinq pages portant chacune un marqueur distinct
  visible dans sa miniature, notés A, B, C, D et E dans l’ordre initial.
- Étapes :
  1. ouvrir Organiser — Vue globale et vérifier les miniatures numérotées ;
  2. glisser E, actuellement page 5, avant B pour obtenir A, E, B, C, D ;
  3. supprimer E, désormais page 2, et confirmer ;
  4. toucher Annuler une fois : E doit réapparaître en page 2 ;
  5. toucher Annuler une seconde fois : l’ordre initial A, B, C, D, E doit être
     restauré ;
  6. toucher Rétablir deux fois : le déplacement puis la suppression de E
     doivent être rejoués dans cet ordre ;
  7. toucher Annuler pour restaurer E, puis utiliser son menu contextuel et
     l’alternative « Déplacer avant B » ; vérifier le même ordre A, E, B, C, D ;
  8. toucher Annuler, vérifier l’ordre A, B, C, D, E, fermer et relancer.
- Résultat attendu : déplacement et suppression forment deux commandes
  distinctes ; deux Annuler restaurent successivement la page supprimée puis
  l’ordre initial exact ; les contenus suivent leur identité, les numéros sont
  recalculés, Rétablir rejoue les deux commandes, l’alternative contextuelle
  produit le même ordre que le glisser et l’ordre final persiste.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Réorganisation, suppression et annulation réussies ; amélioration demandée : indicateur d’insertion visible pendant le déplacement.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-072` — Une seule page active et fidélité de la vue globale

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEC-05`, `3:GLO-001` à `3:GLO-009`, `3:CAN-004`,
  `3:UND-006`.
- Préconditions : album de trois pages, chacune avec fond et photo distincts ;
  sélectionner un cadre sur la page 2.
- Étapes :
  1. vérifier qu’une seule page est visible en Vue page ;
  2. chercher dans l’interface tout réglage Une/Deux pages ;
  3. ouvrir Vue globale et comparer les trois miniatures aux pages ;
  4. essayer de déplacer ou redimensionner un cadre depuis une miniature ;
  5. toucher la miniature de page 3 ;
  6. vérifier le retour en Vue page sur page 3 seulement ;
  7. revenir en vue globale, puis en Vue page sans choisir une autre miniature.
- Résultat attendu : aucun réglage deux pages, aucune paire de pages actives ;
  les miniatures sont fidèles mais non éditables ; toucher page 3 l’active et
  le retour sans sélection conserve la dernière page active ; changer de vue
  ne crée aucune commande Annuler.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-073` — Fonds par page, portée globale, annulation et hors ligne

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:BG-001` à `3:BG-005`, sous-périmètre Lot 1 de `3:BG-006`,
  `3:BG-010`, `3:BG-012`, `3:BG-013`, `3:BG-014`, `3:BG-015`,
  `3:DAT-039`. Le fond manquant de
  `3:BG-008` est testé par `APPLE-L1-010` ; `3:BG-011` et `3:BG-016` sont
  différées avec le texte du Lot 2.
- Préconditions : album de trois pages, une photo placée sur chaque page ; les
  trois fonds intégrés doivent être visibles dans le panneau Fonds.
- Étapes :
  1. appliquer Album classique à la page 1, Carnet de voyage à la page 2 et
     Nuit minimaliste à la page 3 ;
  2. vérifier que chaque pression ne change que la page active et ne déplace
     aucune photo ;
  3. appliquer aussi « Aucun » puis une couleur unie sur une page et vérifier
     leur opacité stable en clair/sombre ;
  4. sur page 2, toucher « Appliquer à toutes les pages » ; vérifier que le
     dialogue annonce trois pages, puis Annuler ;
  5. recommencer et confirmer, puis toucher Annuler une seule fois ;
  6. vérifier le retour aux trois fonds distincts en Vue page, Vue globale et
     Prévisualiser ;
  7. fermer l’app, activer le mode Avion, relancer et vérifier les trois fonds.
- Résultat attendu : catalogue de trois motifs avec noms et miniatures fidèles,
  spirale toujours à gauche, fond propre à chaque page ; l’application globale
  est une commande unique et n’altère aucun élément ; Annuler restaure les
  trois fonds ; relance hors ligne identique. Lecture et PDF ne sont pas
  couverts ici car ils appartiennent au Lot 3.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-074` — Couverture automatique, manuelle, identité et repli

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:COV-001`, sous-périmètre Lot 1 de `3:COV-002`, `3:COV-003`,
  `3:COV-004`, `3:COV-005`, `3:COV-006`, `3:DAT-005`, `3:ALB-021`,
  `3:ACPT-103`. Le cache de `3:COV-007` est réservé à `APPLE-L1-013`.
- Préconditions : album `Couverture test` de quatre pages repérables. Les
  pages 1, 3 et 4 contiennent chacune au moins deux occurrences photo. En page
  1, deux cadres superposés rendent l’ordre de profondeur évident ; en page 4,
  une occurrence cible possède un cadrage et une rotation reconnaissables avec
  du fond visible dans son masque rectangulaire.
- Étapes :
  1. revenir à la bibliothèque et vérifier que la couverture automatique est
     l’occurrence arrière de la page 1, première selon pages puis profondeur ;
  2. dans le menu de la carte, choisir Choisir la couverture, sélectionner
     précisément l’occurrence cible de la page 4, puis terminer ;
  3. vérifier son cadrage, sa rotation et le fond de sa page révélé autour de
     la photo ; toucher Annuler puis Rétablir dans la bibliothèque ;
  4. rouvrir l’album, déplacer la page 4 en deuxième position depuis Vue
     globale, puis revenir à la bibliothèque ;
  5. vérifier que la couverture reste la même occurrence malgré son nouveau
     numéro de page ;
  6. rouvrir l’album, supprimer uniquement cette occurrence cible, puis
     revenir à la bibliothèque ;
  7. vérifier le repli sur la première occurrence disponible selon le nouvel
     ordre des pages et la profondeur ;
  8. supprimer toutes les occurrences restantes, revenir à la bibliothèque,
     puis fermer et relancer l’app.
- Résultat attendu : automatique choisit la première occurrence par ordre des
  pages puis profondeur ; le choix manuel identifie page et élément, sans
  import dédié, et suit le même `elementID` après réorganisation ; dans le
  sous-périmètre rectangulaire du Lot 1, cadrage, rotation, transparence et fond
  révélé restent fidèles ; supprimer la cible revient à la première occurrence,
  puis l’absence de toute occurrence affiche le nom sur le fond de la première
  page ; Annuler/Rétablir et chaque état durable ciblent la bonne occurrence.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-075` — PhotosPicker multiple, ordre, hors ligne et annulation

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PHO-007`, `3:PHO-008`, `3:APL-001`, `3:APL-002`,
  `3:APL-003`, `3:APL-004`, `3:APL-005`, `3:APL-007`, `3:ERR-001`.
  La progression dépassant 500 ms de `3:APL-006` est isolée dans
  `IPAD-L1-107`.
- Préconditions : ajouter dans Photos trois images non personnelles portant
  visuellement les numéros 1, 2 et 3 ; album cible sans photo.
- Étapes :
  1. ouvrir Photos > Ajouter des photos > Photothèque ;
  2. sélectionner les images dans l’ordre 3, 1, 2 et valider ;
  3. observer les états En attente, Import en cours et Disponible ;
  4. vérifier l’ordre 3, 1, 2 dans le panneau ;
  5. activer le mode Avion ; sur trois cadres vides distincts, sélectionner un
     cadre, presser la miniature correspondante, puis désélectionner avant de
     recommencer pour placer 3, 1 et 2 sans remplacement involontaire ;
  6. toucher Annuler trois fois et vérifier que les photos restent Disponibles
     dans le panneau malgré le retrait des trois placements ;
  7. fermer et relancer toujours hors ligne, replacer une miniature et vérifier
     son rendu ;
  8. réactiver le réseau, rouvrir PhotosPicker, sélectionner une quatrième
     image puis annuler le sélecteur système.
- Résultat attendu : PhotosPicker public, sélection multiple ordonnée, copie
  locale avant Disponible, miniatures orientées, images plaçables hors ligne
  et persistantes indépendamment du sélecteur ; annuler les placements ne
  supprime pas les assets importés et l’annulation finale du sélecteur ne
  modifie ni photothèque interne ni page.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-076` — Import Fichiers et placements statiques distincts

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:APL-001`, `3:APL-002`, `3:APL-004`, `3:APL-005`,
  `3:APL-007`, `3:FMT-001`, `3:FMT-002`, `3:FMT-003`, `3:FMT-005`,
  `3:FMT-007`, `3:DAT-043`, `3:TST-011`. `3:FMT-008` est différée au PDF
  du Lot 3.
- Préconditions : corpus accepté HEIC, JPEG, PNG, RAW, Live Photo fixe et HDR
  décrit plus haut ; noter dimensions et SHA-256 de chaque fichier. Pour Live
  Photo, utiliser la source Photothèque si Fichiers ne préserve pas le couple.
- Étapes :
  1. choisir Photos > Ajouter des photos > Fichiers ;
  2. sélectionner ensemble HEIC, JPEG, les quatre PNG versionnés et HDR ;
  3. vérifier que chaque entrée devient Disponible avec miniature correctement
     orientée et couleurs plausibles ;
  4. importer le RAW décodable et vérifier son affichage statique ;
  5. importer la Live Photo depuis PhotosPicker ;
  6. pour chaque format, toucher une zone vide afin de désélectionner le cadre
     précédent, puis presser sa miniature pour créer un nouveau cadre ; ne
     jamais laisser un cadre rempli sélectionné entre deux formats ;
  7. vérifier notamment le placement de
     `medium-landscape-2400x1800.png`, fermer et relancer hors ligne ;
  8. vérifier que chaque cadre distinct conserve son format, que la Live Photo
     n’est jamais animée et que le RAW reste rendu.
- Résultat attendu : tous les contenus statiques décodables sont acceptés sans
  plafond arbitraire ; original RAW conservé avec dérivé d’affichage ; seule la
  composante fixe de la Live Photo est copiée ; orientation/profil appliqués au
  rendu sans réécriture visible de l’original ; toutes les occurrences
  persistent hors ligne.
- Résultat : 🟠 `BLOQUÉ`.
- Preuve : Les formats statiques testés hors RAW ont réussi. `raw.dng` est refusé avec « dimensions invalides » et n’est pas établi décodable par ImageIO ; la vérification RAW est différée. Anomalie séparée : les miniatures sont tronquées lorsque la grille atteint quatre colonnes.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-077` — Refus, échec partiel et nouvelle tentative sûre

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PHO-007`, `3:PHO-008`, `3:APL-008`, `3:FMT-004`,
  `3:FMT-006`, `3:ERR-002` à `3:ERR-004`, `3:ERR-021`, `3:TST-011`.
- Préconditions : album contenant déjà un cadre rempli ; corpus JPEG valide,
  GIF, APNG, vidéo, fichier corrompu et fichier de test dont l’en-tête déclare
  plus de 200 MP sans contenir un bitmap géant. Noter nom, taille et SHA-256 de
  chaque entrée ; les fichiers interdits ou invalides restent volontairement
  invalides pendant toute la fiche.
- Étapes :
  1. lancer un import Fichiers multiple contenant le JPEG valide et autant de
     fichiers interdits que le sélecteur autorise à choisir ;
  2. noter les fichiers filtrés avant sélection et ceux refusés après
     sélection ;
  3. vérifier que le JPEG reste Disponible malgré les autres échecs ;
  4. vérifier chaque état détaillé : Format non pris en charge ou Fichier
     inaccessible, avec explication actionnable ;
  5. vérifier que le cadre déjà rempli n’a pas été remplacé ;
  6. noter le nombre et la position du JPEG Disponible, puis toucher
     « Réessayer » sans modifier les fichiers invalides ;
  7. vérifier que seuls les échecs repassent par En attente/Import en cours et
     que le JPEG réussi n’est ni relu ni dupliqué ;
  8. toucher Ignorer pour les erreurs persistantes, puis fermer et relancer
     l’album.
- Résultat attendu : GIF/APNG/vidéo refusés comme contenus non statiques,
  fichier corrompu refusé, > 200 MP refusée avant décodage intégral ; succès
  partiel conservé à sa position, aucun contenu existant remplacé, Réessayer ne
  relance que les erreurs et ne duplique aucun succès, Ignorer conserve le JPEG
  réussi et la relance reste cohérente.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Refus, succès partiel et reprise ont fonctionné. Écart produit séparé : réimporter exactement le JPEG déjà présent crée immédiatement une seconde miniature `×0` au lieu de réutiliser l’asset existant.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-078` — Panneau Photos, tri, compteur et suppression logique

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEC-34`, `3:PHO-001` à `3:PHO-003`, `3:PHO-009`,
  `3:PHO-010`, `3:UND-004`, `3:UND-010`.
- Préconditions : album avec au moins trois photos ayant noms, dates de prise
  et dates d’import différents ; une photo placée deux fois, une placée une
  fois et une inutilisée.
- Étapes :
  1. vérifier les compteurs `×2`, `×1`, `×0` ;
  2. trier successivement par date de prise de vue, nom et date d’import, en
     ordre croissant puis décroissant ;
  3. activer « Masquer les photos utilisées », puis les réafficher ;
  4. ouvrir le menu de la photo `×2` et vérifier « Supprimer de cet album »
     désactivé avec l’annonce « Utilisée 2 fois » ;
  5. retirer les deux occurrences sans supprimer l’original ;
  6. demander la suppression à `×0`, Annuler la confirmation, puis confirmer ;
  7. toucher Annuler et vérifier la restauration à son indice d’origine ;
  8. toucher Rétablir, fermer et relancer.
- Résultat attendu : tri stable, masquage exact, compteur actualisé ; aucune
  suppression tant qu’une occurrence existe ; retrait d’occurrence conserve
  l’original ; confirmation identifie la photo ; suppression logique n’affecte
  ni Fichiers ni Photos ; Annuler restaure métadonnées et position, Rétablir
  retire de nouveau, état final durable.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : Les étapes non signalées ont réussi, mais le menu de la photo `×2` n’affiche pas l’annonce « Utilisée 2 fois ».
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-079` — Réutilisation, annulation et indépendance interalbum

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEC-37`, `3:PHO-015`, `3:PHO-016`, `3:PHO-017`,
  `3:PHO-018`, `3:LOC-007`, `3:LOC-008`, `3:LOC-015`, `3:LOC-016`,
  `3:UND-004`.
- Préconditions : trois albums sources actifs, dont `Source récente`,
  `Alpha source` et `Zulu source`, avec dates de modification identifiables ;
  Alpha et Zulu sont préparés avec la même date affichée afin d’observer le
  départage par nom. `Source récente` contient les fixtures petite et carrée
  dans cet ordre, dont une non placée. L’album cible `Cible reuse` ne contient
  aucune de ces photos.
- Étapes :
  1. dans la cible, ouvrir Ajouter des photos > Depuis vos autres albums ;
  2. vérifier que la corbeille et l’album courant sont absents ; contrôler
     l’ordre par date de modification décroissante puis, pour Alpha et Zulu à
     date affichée égale, par nom localisé croissant ;
  3. ouvrir `Source récente`, vérifier que la photo non placée est incluse,
     sélectionner dans l’ordre la carrée puis la petite et
     valider « Ajouter 2 photos » ;
  4. vérifier qu’elles apparaissent dans la cible sans être placées ;
  5. immédiatement, avant tout placement ou autre commande, toucher Annuler et
     vérifier que les deux ajouts disparaissent de la cible sans modifier la
     source ; toucher Rétablir et vérifier leur retour dans l’ordre ;
  6. rouvrir la source de réutilisation et vérifier l’état « Déjà ajoutée » et
     la désactivation des deux photos ;
  7. placer la petite dans la cible, fermer et relancer hors ligne ;
  8. mettre `Source récente` en corbeille puis la supprimer définitivement ;
  9. rouvrir la cible et vérifier le rendu hors ligne des deux photos.
- Résultat attendu : sélection multiple et ordre conservés, nouveaux assets
  logiques autonomes dans la cible, mêmes octets/empreintes sans nouvelle copie
  binaire observable, aucune modification de la source, photos non placées
  arbitrairement, détection des doublons, commande d’ajout annulable/rétablissable
  en une fois et cible intacte après suppression de la source et relance. Le
  dernier départage par octets UUID de `3:PHO-015`, invisible entre cartes
  distinctes, reste couvert par les tests Core.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : À l’étape 3, les photos de l’album source sont énormes, très zoomées ou superposées ; sélection et poursuite impossibles.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-080` — Placement par pression et album sans photo

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PHO-004`, `3:PHO-005`, `3:PHO-006`, `3:PHO-011`,
  `3:PHO-012`, `3:PHO-013`, `3:FRM-004`, `3:FRM-009`.
- Préconditions : deux albums neufs et sans photo : `Choix cadre`, dont la page
  contient un cadre vide, et `Choix page`, composé de deux pages vides. Les
  fixtures petite, carrée et moyenne sont disponibles dans Fichiers mais pas
  encore dans les panneaux Photos de ces albums.
- Étapes :
  1. dans `Choix cadre`, sélectionner le cadre vide et toucher Ajouter une
     photo ; vérifier que le mode de choix propose le sélecteur système ;
  2. importer en une fois petite et carrée ; vérifier que les deux miniatures
     sont ajoutées au panneau, qu’aucune n’est placée arbitrairement et que le
     mode cible toujours le même cadre ;
  3. presser la petite et vérifier que ce cadre précis est rempli sans second
     cadre ; relever sa géométrie, puis presser la carrée et vérifier que seule
     sa photo est remplacée avec géométrie inchangée ;
  4. ouvrir `Choix page`, toucher l’action locale Ajouter une photo et vérifier
     que le sélecteur système est proposé faute de photo disponible ;
  5. importer carrée et moyenne ; vérifier leur ajout sans placement
     arbitraire, puis presser la moyenne ;
  6. vérifier la création d’un cadre au centre et au premier plan dans une boîte
     maximale `0,45 × 0,45`, centré à `1×` sans rotation ni retournement ;
  7. toucher de nouveau Ajouter une photo, puis utiliser explicitement Annuler
     dans le mode de choix ; vérifier qu’aucun cadre n’est créé ;
  8. rouvrir ce mode, fermer le panneau Photos sans choisir ; vérifier qu’aucun
     cadre n’est créé ;
  9. rouvrir ce mode une troisième fois, passer à la page 2 avant de choisir ;
     vérifier qu’aucun cadre n’est créé sur aucune page ;
  10. sur la page 2 sans sélection, ouvrir normalement Photos et presser la
      miniature carrée ; vérifier la création d’un nouveau cadre centré.
- Résultat attendu : pression sans cadre crée un cadre libre dans une boîte
  maximale 0,45 × 0,45 conservant le rapport ; pression avec cadre vide le
  remplit après retour du sélecteur ; l’import multiple alimente le panneau sans
  placement arbitraire ; pression avec cadre rempli remplace uniquement le
  contenu ; chaque nouveau placement est centré à `1×`, sans rotation ni
  retournement ; Annuler, fermer le choix ou changer de page ne crée rien.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : Étapes 1 à 3 réussies. À partir de l’étape 4, l’action locale « Ajouter une photo » ne produit aucun retour visible, contrairement à « Ajouter des photos » du panneau.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-081` — Placement par glisser-déposer sur iPad

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PHO-004`, `3:PHO-005`, `3:PHO-006`, `3:ACC-020`.
- Préconditions : iPad, panneau Photos ouvert, une page contenant un cadre
  vide, un cadre rempli et une grande zone libre ; trois photos disponibles.
- Étapes :
  1. glisser une miniature sur le cadre vide ;
  2. glisser une autre miniature sur le cadre rempli ;
  3. glisser la troisième sur une position précise de la zone vide ;
  4. vérifier sélection et contenu après chaque dépôt ;
  5. annuler successivement les trois commandes ;
  6. réduire la fenêtre de l’iPad jusqu’à la largeur compacte, ouvrir le
     panneau Photos intégré sous le canevas et répéter un dépôt vers le cadre
     vide puis vers la page sans fermer le panneau ;
  7. reproduire les trois effets par pression/menu, sans glisser-déposer.
- Résultat attendu : le cadre vide est rempli, le cadre rempli conserve sa
  géométrie et remplace seulement sa photo, la page crée un cadre centré sur le
  dépôt et au premier plan ; les trois opérations sont annulables séparément ;
  en largeur compacte iPad, source et cible restent dans la même fenêtre et le
  panneau ne masque pas le canevas ; l’alternative sans glisser produit les
  mêmes états métier.
- Résultat : 🟠 `BLOQUÉ`.
- Preuve : Étapes 1 à 5 réussies. Étapes 6 et 7 non conclues : aucune présentation multi-fenêtre Swift Playgrounds ni glisser-déposer entre applications sur cet iPad ; la fiche mélangeait cette limite avec l’alternative par pression.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-082` — Remplacer, retirer et supprimer : trois opérations distinctes

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:FRM-001` à `3:FRM-009`, `3:ELM-010`, `3:UND-004`.
- Préconditions : cadre rempli par la fixture carrée, déplacé, redimensionné et
  cadré de façon reconnaissable ; seconde photo disponible.
- Étapes :
  1. sélectionner le cadre et relever sa géométrie visuelle ;
  2. choisir Remplacer et affecter la seconde photo ;
  3. vérifier géométrie/style conservés mais contenu réinitialisé centré à
     `1×`, sans rotation ni retournement ;
  4. choisir « Retirer la photo » ;
  5. vérifier la trame neutre, l’icône `+` et « Ajouter une photo » dans le
     même cadre ;
  6. toucher Annuler puis Rétablir ;
  7. choisir Supprimer sur le cadre vide ;
  8. vérifier l’absence de confirmation, puis Annuler la suppression ;
  9. fermer et relancer.
- Résultat attendu : Remplacer ne transforme pas le cadre ; Retirer conserve
  cadre/styles et original dans Photos ; Supprimer retire le cadre et son
  contenu sans confirmation ; chaque action est distincte, annulable et
  durable ; l’aide du cadre vide n’est qu’une aide d’édition.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Les effets métier Remplacer, Retirer et Supprimer ont réussi. Le bouton Remplacer n’annonce aucun mode ; un badge vert `OK` ressemble à un bouton inactif et les commandes horizontales sont difficiles à parcourir.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-083` — Dupliquer et presse-papiers compatible/incompatible

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ELM-009`, `3:FRM-007`, `3:CLP-001`, `3:CLP-002`,
  `3:CLP-003`, `3:CLP-004`, `3:UND-001` à `3:UND-007`.
- Préconditions : album source de deux pages ; page 1 avec trois cadres
  superposés et celui du milieu sélectionné, page 2 avec un cadre existant.
  Une quatrième photo, utilisée par une seule occurrence distincte, servira au
  test de restauration d’asset. Un second album actif est disponible.
- Étapes :
  1. avant toute copie, désélectionner puis vérifier que Coller est désactivé ;
  2. resélectionner le cadre du milieu, choisir Dupliquer et vérifier une copie
     sélectionnée décalée de 12 points
     vers le bas/droite, juste au-dessus de l’original ;
  3. modifier le cadrage de la copie et vérifier que l’original ne change pas ;
     Annuler puis Rétablir la duplication ;
  4. Copier la copie, passer page 2, Coller et vérifier un nouvel élément
     sélectionné au premier plan avec un cadrage indépendant ;
  5. revenir page 1, sélectionner l’original et Couper ; vérifier sa disparition
     sans confirmation, puis Annuler et Rétablir ;
  6. sélectionner l’occurrence de la quatrième photo, la Copier, supprimer
     cette unique occurrence, puis supprimer de l’album son asset désormais à
     `×0` ;
  7. toucher Coller sans effectuer une nouvelle copie et vérifier que la même
     commande restaure l’asset à la fin du panneau puis crée une occurrence au
     nouvel identifiant ;
  8. Copier l’occurrence restaurée, revenir à la bibliothèque, ouvrir le second
     album et vérifier que Coller y est désactivé comme contenu incompatible ;
  9. rouvrir l’album source, vérifier que Coller y est de nouveau activé, le
     déclencher, puis fermer et relancer.
- Résultat attendu : chaque collage/duplication possède un nouvel identifiant
  observable par indépendance des modifications ; même page = juste au-dessus,
  autre page = premier plan ; décalage réduit seulement si nécessaire pour
  garder le centre sélectionnable ; Couper est atomique et annulable ; Coller
  restaure atomiquement les métadonnées de l’asset retiré ; le collage sans
  contenu et le payload photo dans un autre album restent désactivés ; état
  final durable. Texte et sticker ne sont pas testés, car ils relèvent du Lot 2.
- Résultat : ⚫ `NON APPLICABLE`.
- Preuve : Étapes 1 à 7 compatibles avec la session réussies. Les étapes 8–9 exigeaient à tort une réactivation après fermeture ; l’utilisateur confirme que le presse-papiers doit rester limité à la session et à l’album.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-084` — Sélection, chevauchement et profondeur des cadres

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:CAN-002`, `3:CAN-003`, `3:ELM-001`, `3:ELM-008`,
  `3:ELM-014`, `3:EDT-017`.
- Préconditions : trois cadres photo qui se chevauchent fortement ; petite
  photo à `1×` dans l’un pour laisser une partie transparente du masque.
- Étapes :
  1. toucher une zone couverte par les trois cadres ;
  2. vérifier que le cadre de premier plan est sélectionné ;
  3. toucher une partie du masque non couverte par les pixels de la petite
     photo ;
  4. utiliser « Sélectionner un élément » sur le point de chevauchement et
     choisir le cadre arrière ;
  5. vérifier que le choix n’a pas changé la profondeur ;
  6. exercer Avancer, Premier plan, Reculer et Arrière-plan ;
  7. vérifier qu’à chaque extrémité seules les directions impossibles sont
     désactivées ;
  8. toucher une zone vide de la page.
- Résultat attendu : un seul cadre sélectionné ; tout le masque participe au
  hit-testing ; sélecteur ordonné du premier plan vers l’arrière et descriptions
  non ambiguës ; profondeur modifiée uniquement sur commande ; zone vide
  désélectionne ; les cadres partagent une pile unique.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : À l’étape 4, le sélecteur propose trois choix identiques « Photo », rendant le cadre arrière impossible à identifier. Les autres étapes ont réussi ; l’inspecteur contextuel horizontal est jugé difficile d’accès.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-085` — Déplacement, huit poignées, rotation et gestes à deux doigts

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ELM-002` à `3:ELM-004`, `3:ELM-007`, `3:ELM-012`,
  `3:ELM-013`, `3:ACC-005`, `3:ACC-013`.
- Préconditions : un cadre photo sélectionné, sans mode cadrage.
- Étapes :
  1. compter quatre poignées d’angle, quatre latérales et une poignée de
     rotation extérieure ;
  2. glisser l’intérieur pour déplacer le cadre ;
  3. utiliser chaque poignée latérale puis chaque poignée d’angle et vérifier
     la possibilité de changer le rapport ;
  4. tourner avec la poignée extérieure et vérifier qu’elle suit le doigt sans
     saut ni décalage ;
  5. appliquer simultanément pincement et rotation à deux doigts sur le cadre ;
  6. annuler une fois chaque geste continu et vérifier qu’il revient d’un seul
     coup ;
  7. ouvrir Position et taille > Rotation…, tester `−90°`, `+90°`, une valeur
     de `179°`, puis Réinitialiser `0°` et valider ;
  8. utiliser les alternatives de déplacement et Agrandir/Réduire du menu.
- Résultat attendu : toutes les poignées sont opérantes ; cadre redimensionnable
  librement ; transformation deux doigts agit sur le cadre, pas sur la photo
  interne ni le canevas ; chaque geste continu produit une seule commande ;
  Rotation… est bornée dans `[-180, 180)`, au pas de 1°, distincte des quarts
  de tour du contenu ; toutes les actions ont une alternative accessible.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Toutes les transformations prévues ont réussi. Améliorations demandées : poignées visuelles sur les bordures réelles lorsque visibles et aperçu immédiat de Rotation…, avec Annuler restaurant l’angle initial.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-086` — Guides, accrochage, haptique et bornes géométriques

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:CAN-005`, `3:CAN-006`, `3:ELM-005` à `3:ELM-007`,
  `3:PERF-017`.
- Préconditions : deux cadres de tailles différentes ; retour haptique activé
  dans les réglages iPad.
- Étapes :
  1. déplacer lentement un cadre vers les bords et centres de la page ;
  2. observer les guides et sentir le retour à l’entrée dans le seuil ;
  3. rester dans le même seuil puis en sortir et y revenir ;
  4. aligner le cadre avec les bords et centres du second cadre ;
  5. vérifier l’absence totale de guide de marge de sécurité ;
  6. tenter de réduire sous 5 % de la largeur/hauteur de page ;
  7. déplacer le cadre hors page jusqu’à la limite autorisée ;
  8. relâcher, toucher Annuler une fois et vérifier le retour avant le geste.
- Résultat attendu : accrochage à six points écran ou moins, guide clair et un
  seul haptique léger par entrée dans un guide ; nouvel haptique seulement
  après sortie/rentrée ; aucun guide de sécurité ; taille minimale respectée ;
  le centre reste dans la page même si le cadre déborde et le débordement est
  rogné ; une seule commande est persistée au relâchement.
- Résultat : 🟠 `BLOQUÉ`.
- Preuve : Les contrôles autres que l’haptique ont réussi ; aucun retour haptique n’est disponible sur l’iPad 8, donc la fiche complète ne peut pas conclure.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-087` — Petite photo 600 × 400 centrée à `1×`

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEC-07`, section 3.1, `3:CAN-009`, `3:CRP-001`,
  `3:CRP-004`, `3:CRP-006`, `3:FRM-009`, `3:ACPT-124`.
- Préconditions : importer exactement
  `small-landscape-600x400.png`, SHA-256
  `407edaf04f5fd921e8e4bca7359d55e6d87b3f2876ebd99caead085a285a6ecc` ;
  page sur fond Carnet de voyage ; créer un cadre nettement plus grand que
  600 × 400 unités canoniques.
- Étapes :
  1. remplir le cadre avec la petite photo ;
  2. ouvrir Recadrer et lire la valeur initiale `1,00×` ;
  3. vérifier que la photo est centrée, non agrandie, et que le fond reste
     visible tout autour dans le masque ;
  4. tenter de descendre sous `1×` avec le curseur et par pincement ;
  5. déplacer la photo puis choisir Réinitialiser ;
  6. choisir Terminé, fermer et relancer ;
  7. comparer Vue page, Vue globale, Prévisualiser et couverture si cette
     occurrence est choisie.
- Résultat attendu : à `1×`, 600 pixels correspondent à 600 unités de largeur
  et 400 à 400 unités de hauteur, centrées ; aucune couverture automatique du
  cadre ; borne basse `1×` puisque la photo tient déjà ; fond visible normal,
  sans alerte de cadre vide ; Réinitialiser et relance gardent `1×` centré ;
  rendu utile cohérent dans toutes les sorties Lot 1.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-088` — Commande Pleine page et borne dynamique `0,5×`

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEC-07`, section 3.1, `3:CAN-009`, `3:CRP-001`,
  `3:CRP-004`, `3:CRP-006`, `3:DAT-006`, `3:ACPT-124`.
- Préconditions : importer exactement
  `large-portrait-4800x6000.png`, SHA-256
  `f3547f764f7eec40178bd1f3602863e0ed35bc6fe30777acde91b2f5d95903ca` ;
  la page ne contient initialement aucun cadre.
- Étapes :
  1. presser la miniature sans sélection pour créer un cadre libre, puis
     sélectionner Position et taille > Pleine page ;
  2. vérifier que la commande fixe exactement le cadre rectangulaire aux limites
     du canevas 4:5 canonique, centré et sans rotation ; vérifier que les huit
     poignées et la commande de rotation restent entièrement visibles et
     activables, la rotation étant rentrée dans la page faute d’espace extérieur ;
  3. ouvrir Recadrer et vérifier la valeur initiale `1,00×`, avec une photo deux
     fois plus large et
     haute que la page canonique ;
  4. descendre progressivement le contrôle accessible jusqu’à sa borne basse ;
  5. vérifier qu’elle vaut exactement `0,50×` à la précision affichée ;
  6. à `0,50×`, vérifier la visibilité exacte de l’image entière dans le cadre
     2 400 × 3 000 ;
  7. tenter de descendre sous `0,50×` avec le contrôle et par pincement ;
  8. valider, fermer, relancer et rouvrir Recadrer.
- Résultat attendu : minimum calculé par
  `min(2400/4800, 3000/6000) = 0,5`, sans constante fixe ; curseur et pincement
  refusent une valeur inférieure ; `0,50×` persiste exactement et ne se
  confond jamais avec le zoom du canevas. Les contrôles du cadre pleine page ne
  sont ni rognés ni placés hors de la zone tactile visible.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-089` — Cadrage indépendant et original non destructif

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:CRP-002` à `3:CRP-007`, `3:DAT-006` à `3:DAT-010`,
  `3:EDT-015`, `3:UND-004`.
- Préconditions : deux occurrences distinctes du même asset
  `square-1200x1200.png`, SHA-256
  `494a22dff3b8765d5e62ffca306434e314323c97a41e5108dbbc563c3bd4b360`,
  possèdent au départ le même cadrage. Conserver le fichier fixture dans
  Fichiers comme référence de provenance.
- Étapes :
  1. ouvrir le cadrage par double toucher, puis annuler et le rouvrir par
     Recadrer ;
  2. vérifier cadre fixe, extérieur du masque assombri, panneaux/navigation et
     zoom du canevas désactivés ;
  3. sur la première occurrence seulement, glisser la photo, la pincer, pivoter
     à gauche puis à droite et la retourner horizontalement ;
  4. vérifier que la photo ne peut devenir entièrement introuvable et que la
     seconde occurrence reste visuellement identique à son état initial ;
  5. toucher Annuler dans le mode cadrage et vérifier l’état d’entrée exact des
     deux occurrences ;
  6. recommencer sur la première, toucher Réinitialiser et vérifier `1×`,
     centrage, orientation d’origine et absence de retournement ;
  7. créer un troisième état et toucher Terminé ;
  8. vérifier encore la seconde occurrence, puis toucher Annuler une seule fois
     et Rétablir ;
  9. redimensionner le premier cadre et vérifier que zoom, point focal, quarts de tour
     et retournement restent exactement inchangés ;
  10. fermer et relancer ; vérifier les deux cadrages indépendants et comparer
      visuellement leur contenu à la fixture de référence dans Fichiers.
- Résultat attendu : gestes modifient uniquement le contenu, jamais le cadre ni
  l’original ; Annuler restaure l’entrée ; Réinitialiser impose `1×` centré ;
  Terminé crée une seule commande ; redimensionner ne recadre pas
  automatiquement ; placement persistant absolu et seconde occurrence non
  modifiée. La comparaison Fichiers prouve l’absence de modification de la
  source externe ; l’immutabilité des octets stockés et leur hash avant/après
  restent prouvés par les tests Core, pas par cette observation UI.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Retour utilisateur « ok » pour l’ensemble de la fiche.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-090` — Paliers et commandes du zoom du canevas

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ZOM-001`, `3:ZOM-002`, `3:ZOM-007`, `3:EDT-010`.
- Préconditions : page avec un cadre sélectionné ; sortir du mode cadrage.
- Étapes :
  1. toucher Ajuster et vérifier `100 %`, page entière centrée en aspect-fit ;
  2. toucher Zoom avant jusqu’à parcourir `125`, `150`, `200`, `300`, `400 %` ;
  3. vérifier Zoom avant désactivé à `400 %` ;
  4. toucher Zoom arrière jusqu’à `300`, `200`, `150`, `125`, `100`, `75`,
     `50 %` ;
  5. vérifier Zoom arrière désactivé à `50 %` ;
  6. revenir à une valeur intermédiaire par pincement, puis vérifier que les
     boutons choisissent les paliers strictement inférieur/supérieur ;
  7. vérifier qu’Annuler/Rétablir et la date de modification ne changent pas à
     cause de ces commandes.
- Résultat attendu : plage 50–400 %, paliers et états désactivés exacts ;
  Ajuster revient à 100 % centré ; contours et page changent seulement comme
  fenêtre visuelle ; aucune mutation métier ni commande d’annulation.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : Paliers et commandes de zoom réussis. Anomalie séparée : après Annuler puis Rétablir une suppression de page, la page recréée ne devient pas active.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-091` — Pincement ancré, déplacement de fenêtre et mémoire par page

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ZOM-003` à `3:ZOM-008`, `3:GLO-008`.
- Préconditions : album de deux pages avec détails placés dans des coins
  distincts ; aucun élément sélectionné au début.
- Étapes :
  1. pincer sur une zone vide autour d’un détail proche du coin supérieur
     droit et vérifier que ce point reste sous le milieu du pincement ;
  2. relâcher à une valeur intermédiaire, par exemple environ 163 %, et vérifier
     l’absence d’arrondi ;
  3. déplacer la fenêtre à deux doigts ; vérifier que la page ne peut pas être
     entièrement perdue et reste centrée sur un axe où elle tient ;
  4. sélectionner un cadre et vérifier que poignées/cibles gardent une taille
     écran constante pendant le zoom ;
  5. régler page 1 à un zoom/centre A, page 2 à un zoom/centre B ;
  6. passer par Vue globale puis Prévisualiser et revenir à chaque page ;
  7. fermer complètement l’app puis relancer.
- Résultat attendu : zoom continu ancré au point médian, panoramique borné à
  deux doigts, aides constantes en points écran ; A et B restaurés pendant la
  scène malgré les changements de vue ; après relance, chaque page revient à
  `100 %` centrée et le document est inchangé.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : Le pincement fonctionne, mais le déplacement à deux doigts est interprété comme un pincement et ne permet pas de déplacer la fenêtre.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-092` — Navigation par boutons/balayage et priorité des gestes

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:NAV-001` à `3:NAV-007`, `3:ZOM-005`, `3:PAG-013`,
  `3:UND-005`.
- Préconditions : album de trois pages reconnaissables ; page 2 contient un
  cadre rempli ; zoom canevas supérieur à 100 %.
- Étapes :
  1. vérifier Précédent désactivé page 1 et Suivant désactivé page 3 ;
  2. parcourir 1→2→3→2 avec les boutons et vérifier `Page N sur 3` ;
  3. depuis une zone vide, balayer à gauche pour Suivant et à droite pour
     Précédent ;
  4. tenter un geste plutôt vertical et un geste diagonal ne dépassant pas le
     ratio horizontal 1,25 ;
  5. déplacer puis transformer le cadre : aucun de ces gestes ne change de
     page ;
  6. en mode cadrage, glisser/pincer la photo : aucune navigation ;
  7. sur zone vide, pincer puis déplacer à deux doigts : seule la fenêtre
     change ;
  8. interagir avec le panneau Photos puis effectuer un balayage depuis ce
     panneau ;
  9. atteindre une borne par balayage et vérifier l’absence de changement ;
  10. vérifier que la navigation n’a ajouté aucune entrée Annuler.
- Résultat attendu : boutons et balayages ciblent les mêmes pages ; gauche =
  Suivant, droite = Précédent ; reconnaissance horizontale seulement au ratio
  > 1,25 ; priorité déterministe contenu > élément > fenêtre > navigation ;
  panneau et bornes ne naviguent pas ; jamais deux pages actives.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : Après navigation puis retour à la page 1, le balayage horizontal sur zone vide ne fonctionne plus ; les autres contrôles non signalés ont réussi.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-093` — Sauvegarde pendant geste, arrière-plan et relance

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:APP-005`, `3:APP-006`, `3:APP-008`, `3:APP-009`,
  `3:SAV-001`, `3:SAV-002`, sous-périmètre réussite de `3:SAV-003`,
  `3:LOC-011`, `3:LOC-026`, `3:UND-012`. `3:APP-007` est exclue car elle
  cible la version 1.1 ; l’échec de sauvegarde est testé par `APPLE-L1-011`.
- Préconditions : album à deux pages avec au moins une photo ; noter l’état
  initial.
- Étapes :
  1. déplacer un cadre et relâcher ; observer Enregistrement… puis Enregistré ;
  2. changer de fond et de page sans toucher Sauvegarder ;
  3. mettre immédiatement l’app en arrière-plan, attendre cinq secondes, puis
     revenir ;
  4. commencer à déplacer un cadre avec un premier doigt et, sans le relever,
     toucher Sauvegarder avec un second doigt ; relever ensuite le premier ;
  5. vérifier que la position courante au moment de Sauvegarder est validée
     comme une seule commande, qu’aucun saut n’a lieu au relâchement et que
     l’état revient à Enregistré avec une heure ;
  6. toucher Annuler une fois puis Rétablir une fois pour confirmer qu’une seule
     commande de déplacement a été créée ;
  7. revenir à la bibliothèque, rouvrir l’album et vérifier les changements ;
  8. fermer l’app depuis le sélecteur, relancer et vérifier de nouveau ;
  9. vérifier que les piles Annuler/Rétablir de l’ancienne session sont vides.
- Résultat attendu : chaque commande validée est persistée sans dépendre du
  bouton Sauvegarder ; arrière-plan consolide immédiatement le journal ;
  Sauvegarder n’annule pas le geste ; retour, fermeture et relance retrouvent le
  dernier état annoncé Enregistré ; nouvelle session sans anciennes piles.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : Toucher Sauvegarder pendant un déplacement valide une première position, puis le relâchement provoque un saut et une seconde commande au lieu d’ignorer la fin du flux tactile déjà validé.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` ; 16 août 2026 ; Paris, France ; français (France).
### `IPAD-L1-094` — Interruption après une commande validée et reprise locale

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:APP-009`, `3:LOC-004`, `3:LOC-005`, `3:LOC-011` à
  `3:LOC-014`, `3:LOC-023`, `3:ERR-014`, `3:TST-012`.
- Préconditions : album jetable avec un état A connu ; aucun test de manque
  d’espace dangereux ; l’interruption manuelle ne remplace pas l’injection de
  crash réservée à Xcode.
- Étapes :
  1. ajouter une page et attendre que l’interface confirme la commande ;
  2. forcer immédiatement la fermeture de l’app sans revenir à la bibliothèque ;
  3. relancer et vérifier la page ajoutée ;
  4. importer la fixture carrée, attendre Disponible, la placer puis forcer de
     nouveau la fermeture ;
  5. relancer et vérifier métadonnée, binaire et occurrence ;
  6. commencer un déplacement sans relâcher puis interrompre si le système le
     permet ;
  7. relancer et vérifier soit l’état avant le geste non validé, soit le geste
     complet, jamais une géométrie invalide ou un album illisible.
- Résultat attendu : commandes validées rejouées/consolidées ; aucun asset
  annoncé Disponible sans transaction valide ; dernière version valide jamais
  remplacée par une écriture partielle ; au plus le geste continu non validé
  est perdu ; aucun staging ou message technique brut ne bloque le lancement.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-109`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-095` — Prévisualisation et rendu commun du sous-périmètre Lot 1

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:CAN-003`, `3:CAN-004`, `3:CAN-008`, `3:CAN-009`,
  `3:GLO-007`, `3:GLO-008`.
- Préconditions : page avec fond, trois cadres remplis superposés, rotations,
  une petite photo laissant le fond visible ; sélectionner le cadre supérieur
  et régler le canevas à environ 175 % décentré.
- Étapes :
  1. prendre une capture de la composition en éditeur ;
  2. ouvrir Vue globale et comparer ordre, rotation, masque rectangulaire,
     zones transparentes et fond ;
  3. revenir, ouvrir Prévisualiser et comparer les mêmes points ;
  4. vérifier l’absence de sélection, huit poignées, poignée de rotation,
     guides, boutons locaux et panneaux ;
  5. quitter la prévisualisation ;
  6. vérifier restauration de la page, du cadre sélectionné et du zoom/centre ;
  7. vérifier qu’aucune entrée Annuler n’a été créée par ces changements de vue.
- Résultat attendu : même composition canonique et même profondeur dans
  éditeur, miniature et prévisualisation ; seules les aides d’édition sont
  absentes des sorties ; transparence révèle exactement les éléments inférieurs
  puis le fond ; état de session restauré sans mutation du document. Lecture,
  diaporama et PDF restent hors Lot 1.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-110`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-096` — Cadre vide et alertes dans la vue globale/prévisualisation

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:FRM-001`, `3:FRM-008`, `3:CAN-004`, `3:GLO-006`,
  `3:GLO-007`.
- Préconditions : page 1 avec un cadre vide ; page 2 avec une petite photo
  remplie à `1×` laissant du fond visible.
- Étapes :
  1. vérifier sur page 1 la trame neutre, l’icône photo `+` et le libellé
     « Ajouter une photo » ;
  2. ouvrir Vue globale et vérifier l’alerte accessible de cadre vide sur page
     1 seulement ;
  3. ouvrir page 1 en Prévisualiser et vérifier l’avertissement non bloquant,
     sans rendre le cadre vide comme contenu final ;
  4. ouvrir page 2 et vérifier qu’aucune alerte Cadre vide n’est déclenchée par
     le fond visible autour de la petite photo ;
  5. remplir le cadre de page 1 et vérifier la disparition de l’alerte.
- Résultat attendu : aides du cadre vide présentes seulement en édition ;
  miniature signale clairement le vide ; prévisualisation avertit sans bloquer
  et masque l’aide ; un cadre métier rempli reste rempli même sans couvrir son
  masque ; l’alerte disparaît après remplissage.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-111`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-097` — Qualité, seuils exacts et format régional

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:QLT-001`, `3:QLT-002`, `3:QLT-003`, `3:QLT-004`,
  `3:QLT-005`, sous-périmètre édition/sauvegarde de `3:QLT-006`,
  `3:L10N-005`, `3:GLO-006`.
- Préconditions : région iPad initiale France ; grande fixture placée dans un
  cadre ; le mode Recadrer expose un contrôle accessible Zoom photo permettant
  de saisir ou d’atteindre des valeurs exactes sans estimer un pincement. Noter
  que le calcul se base sur le canevas 4:5 ajusté dans la zone imprimable
  régionale.
- Étapes :
  1. avec le contrôle accessible Zoom photo, fixer exactement `1,00×`, valider
     et vérifier le badge `OK` avec icône et libellé accessible ;
  2. fixer exactement `1,50×`, valider et vérifier `Acceptable` ;
  3. fixer exactement `3,00×`, valider et vérifier `Insuffisante` ;
  4. vérifier les alertes Acceptable/Insuffisante en Vue globale ;
  5. saisir exactement `1,08×` en région France et noter l’état attendu `OK`
     (environ 303 ppp sur le canevas A4 par défaut) ;
  6. fermer l’app, passer temporairement la région système à États-Unis,
     relancer et rouvrir la même occurrence ;
  7. vérifier à `1,08×` l’état attendu `Acceptable` (environ 294 ppp sur le
     canevas Letter par défaut) ;
  8. revenir à `3,00×`, déplacer le cadre puis toucher Sauvegarder ; vérifier
     que l’état Insuffisante ne bloque ni la modification ni la réussite de la
     sauvegarde ; restaurer enfin la région d’origine.
- Résultat attendu : seuils `OK ≥ 300`, `Acceptable ≥ 150 et < 300`,
  `Insuffisante < 150` ; recalcul dérivé après zoom et changement régional,
  jamais persisté ; forme/icône/libellé en plus de la couleur ; avertissement
  non bloquant pour édition et sauvegarde. L’avertissement avant export et le
  recalcul du format PDF choisi de `3:QLT-006` restent hors Lot 1.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-112`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-098` — Interface régulière/compacte, orientations et apparence

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEC-05`, `3:DEC-17`, `3:EDT-002`, `3:EDT-004`,
  `3:EDT-005`, `3:EDT-006`, `3:EDT-011`, `3:EDT-016`, sous-périmètre
  Ajouter une photo de `3:EDT-020`, `3:GLO-001`, `3:ACC-021`, `3:TST-008`.
- Préconditions : album de trois pages avec un cadre sélectionné ; iPad
  autorisant portrait, paysage et fenêtre étroite/Split View.
- Étapes :
  1. en portrait plein écran, relever barre, rail/inspecteur, commandes Photos
     puis Fonds et sélecteur Créer/Organiser/Prévisualiser ;
  2. tourner en paysage et vérifier sélection/page conservées ;
  3. réduire la fenêtre jusqu’à la présentation compacte ;
  4. vérifier la barre inférieure/feuille adaptative, l’ordre Photos puis Fonds,
     et les commandes trop larges dans le menu intitulé exactement « Plus »,
     sans changement de libellé, d’effet ou d’ordre relatif ;
  5. vérifier qu’Ajouter une photo reste visible ou accessible via Ajouter en
     deux activations au plus, sans exposer Ajouter du texte avant le Lot 2 ;
  6. basculer clair puis sombre dans chaque largeur ;
  7. replier/réafficher l’inspecteur ;
  8. vérifier à chaque étape qu’une seule page est affichée et que la sélection
     ne change pas en ouvrant/fermant un panneau ;
  9. vérifier l’absence de marge de sécurité, prix, Commander et de toute
     commande commerciale.
- Résultat attendu : aucune superposition ou commande inaccessible, ordre et
  libellés stables, état actif non indiqué par couleur seule, page aspect-fit
  centrée, une seule page ; adaptation conserve sélection et contenu ; fonds
  Aucun/couleurs restent opaques et identiques en clair/sombre.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-113`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-099` — Dynamic Type, description accessible et VoiceOver

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ACC-001`, `3:ACC-002`, `3:ACC-003`, `3:ACC-004`,
  `3:ACC-005`, `3:ACC-007`, `3:ACC-008`, `3:ACC-011`, `3:ACC-012`,
  `3:ACC-017`, `3:ACC-020`, `3:EDT-010`, `3:TST-008`.
- Préconditions : album de deux pages avec un cadre vide, deux cadres remplis
  superposés, une occurrence photo sans description en page 2 et une alerte
  qualité ; mémoriser la géométrie avant réglages.
- Étapes :
  1. sélectionner l’occurrence de page 2, ouvrir l’action Description
     accessible, saisir `Plage au coucher du soleil` et valider ;
  2. régler Dynamic Type sur une taille d’accessibilité élevée ;
  3. parcourir bibliothèque, éditeur, panneau Photos, Fonds, vue globale,
     corbeille et confirmations ;
  4. vérifier absence de texte essentiel tronqué ou commande hors écran sans
     défilement possible ;
  5. activer VoiceOver et parcourir tous les boutons graphiques ;
  6. vérifier libellé, état et aide pour sauvegarde, panneaux, zoom, navigation,
     cadres et qualité ;
  7. parcourir l’occurrence décrite et vérifier que VoiceOver annonce
     `Plage au coucher du soleil` avec son type, sa position approximative et
     son ordre ;
  8. désactiver temporairement VoiceOver, effacer et valider la description,
     le réactiver puis vérifier le repli exact « Photo, page 2 » ;
  9. vérifier numéro de page, nombre de cadres dont cadres vides et alertes en
     vue globale ;
  10. sélectionner un cadre masqué via « Sélectionner un élément », puis le
     déplacer/redimensionner/réordonner par actions ou menus accessibles ;
  11. réorganiser une page et placer une photo sans glisser-déposer ;
  12. désactiver VoiceOver/Dynamic Type élevé et vérifier la géométrie du
      canevas inchangée.
- Résultat attendu : libellé/hint pour toute icône, cibles tactiles utilisables,
  états jamais uniquement colorés, lecture individuelle non ambiguë,
  alternatives complètes aux gestes, aucune modification de géométrie due à
  Dynamic Type et parcours principal réalisable sans vue inaccessible.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-114`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-100` — Clavier, Option + flèches et aide

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:EDT-009`, `3:ELM-011`, `3:ELM-012`, `3:ELM-013`,
  `3:ACC-005`, `3:ACC-013`, `3:ACC-014`, `3:ACC-015`, `3:TST-008`.
- Préconditions : clavier matériel ou compatible, trackpad/pointeur ; page avec
  deux cadres, l’un sélectionné.
- Étapes :
  1. utiliser les flèches pour déplacer la sélection et vérifier le pas 0,01
     de la dimension de page ;
  2. utiliser Option+flèches et vérifier le pas fin 0,0025 ;
  3. tester `⌘C`, `⌘V`, `⌘X`, Supprimer, `⌘Z`, `⇧⌘Z` ;
  4. vérifier que Coller crée une nouvelle occurrence et que Couper reste une
     commande atomique ;
  5. ouvrir Renommer l’album, placer le curseur dans le champ puis presser les
     flèches, Option + flèches, `⌘C`, `⌘V` et `⌘X` ; vérifier que le champ
     consomme ses commandes de texte et qu’aucun cadre ne bouge ; annuler le
     renommage ;
  6. ouvrir Aide avec le clavier connecté et vérifier qu’elle documente au
     minimum `⌘Z`, `⇧⌘Z`, `⌘X`, `⌘C`, `⌘V`, Supprimer, flèches et Option +
     flèches ;
  7. utiliser le pointeur sur huit poignées et la poignée de rotation ;
  8. exécuter les mêmes transformations avec Position et taille et Rotation… ;
  9. déplacer une page par son menu accessible sans glissement ;
  10. réduire la fenêtre et vérifier qu’aucune cible nécessaire au pointeur ou
      au clavier ne devient inaccessible.
- Résultat attendu : raccourcis conformes, pas normalisés exacts, aucune
  commande consommée par erreur hors contexte, champ de texte prioritaire sur
  les raccourcis d’élément, raccourcis documentés dans l’aide,
  pointeur/trackpad utilisables, toutes transformations et réorganisations
  possibles sans geste multipoint.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-115`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-101` — Fonctionnement local hors ligne

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:DEV-005`, `3:LOC-001` à `3:LOC-005`, `3:SEC-001`,
  `3:ERR-008`, `3:ACPT-100`.
- Préconditions : deux albums avec fonds intégrés, photos importées depuis
  Photos, Fichiers et un autre album ; toutes affichées Disponible ; fermer
  les sélecteurs système.
- Étapes :
  1. activer le mode Avion et couper Wi-Fi/Bluetooth si nécessaire ;
  2. relancer l’app ;
  3. ouvrir les deux albums et chaque page ;
  4. afficher toutes les photos, fonds, miniatures et couvertures ;
  5. créer un album, ajouter une page, changer un fond, placer/recadrer une
     photo déjà locale, renommer et enregistrer ;
  6. fermer et relancer toujours hors ligne ;
  7. restaurer le réseau et vérifier qu’aucun contenu local n’est remplacé.
- Résultat attendu : toutes les données déjà locales restent lisibles et
  modifiables, aucune photo envoyée vers un serveur propriétaire, aucune erreur
  réseau bloquante ; les commandes hors ligne persistent après relance ; le
  retour réseau ne change rien silencieusement.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-116`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-102` — Ancien store 2.1 laissé intact et ignoré

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Spécification : 3.0, incluse dans `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7`.
- Exigences : `3:DEC-33`, `3:DAT-025`, `3:DAT-026`, `3:LOC-010`,
  `3:LOC-029` à `3:LOC-031`, `3:ERR-024`.
- Préconditions : copie de l’app contenant réellement un store du prototype
  2.1 avec au moins un album reconnaissable ; sauvegarder le projet et ne pas
  utiliser de donnée personnelle non sauvegardée. Si le bac à sable 2.1 ne peut
  pas être conservé lors du remplacement dans Swift Playgrounds, répondre
  `BLOQUÉ` et décrire la limite.
- Étapes :
  1. relever sans modifier le contenu visible du prototype 2.1 ;
  2. installer/lancer exactement le candidat 3.0 sur le même conteneur selon le
     parcours disponible ;
  3. observer le premier lancement ;
  4. vérifier qu’aucun album 2.1 n’est affiché, importé, converti ou proposé à
     la migration ;
  5. créer un album 3.0, fermer et relancer ;
  6. si l’environnement permet une inspection non destructive, vérifier que
     les anciens fichiers n’ont été ni déplacés, ni renommés, ni supprimés.
- Résultat attendu : nouvelle bibliothèque 3.0 indépendante sous sa propre
  génération ; aucun décodage ou migration 2.1 ; album 3.0 durable ; ancien
  contenu intact. Un échec de création 3.0 ne présente jamais un état partiel
  comme valide.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-102 : ok` ; aucun inventaire de fichiers
  ni capture n’a été joint au retour.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-103` — Enveloppe 100 pages et 20 occurrences photo

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:PAG-012`, sous-périmètre occurrence photo de `3:LOC-018`,
  `3:PERF-008`, `3:PERF-015`, `3:PERF-017`.
- Préconditions : album de stress non personnel ; alimentation branchée ; ne
  pas remplir artificiellement le disque ; chronomètre disponible. Cette fiche
  mesure l’expérience iPad, pas le pic mémoire Instruments.
- Étapes :
  1. créer ou préparer exactement 100 pages et vérifier que l’ajout reste
     possible ;
  2. fermer et relancer, chronométrer de la pression sur la carte à l’affichage
     de la première page locale ;
  3. ouvrir Vue globale, faire défiler du début à la fin et ouvrir les pages 1,
     50 et 100 ;
  4. sur une page de test, importer une fixture puis créer exactement vingt
     occurrences photo remplies, par placements ou duplications ; vérifier le
     compteur `×20` et l’absence de cadre vide compté à leur place ;
  5. demander une vingt-et-unième occurrence remplie, relever l’avertissement
     non bloquant, puis choisir Continuer si l’appareil ne signale aucun risque
     de cohérence, stockage ou décodage ;
  6. déplacer un cadre plusieurs secondes et observer fluidité, absence de
     décodages clignotants et sauvegarde seulement à la validation ;
  7. ajouter une 101e page, relever l’avertissement non bloquant puis choisir
     Continuer si l’opération reste sûre ;
  8. fermer et relancer, vérifier 101 pages et le contenu de la page de stress.
- Résultat attendu : 100 pages garanties, premier contenu local visé en moins
  de deux secondes et navigation globale sans crash ; 21e occurrence photo
  remplie et 101e page avertissent sans limite arbitraire si l’opération est
  sûre ; le mouvement reste interactif sans signe de décodage plein format ni
  état Enregistrement… à chaque image, puis la commande finale est persistée ;
  état final durable.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-117`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-104` — Matrice commandes, icônes et états en largeurs régulière/compacte

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : sous-périmètre Lot 1 de `3:EDT-003`, `3:EDT-004`, tableaux
  7.2.1 et 7.2.2, `3:EDT-007`, `3:EDT-010`, `3:EDT-012`, `3:EDT-013`,
  `3:EDT-014`, `3:EDT-015`, `3:EDT-016`, `3:EDT-017`, `3:FRM-005`,
  `3:FRM-006`.
- Préconditions : iPad permettant une largeur régulière puis compacte ; album
  de deux pages avec un cadre vide, un cadre rempli, une photo de remplacement
  disponible et un presse-papiers initialement vide. Fermer puis rouvrir
  l’album afin de commencer sur Enregistré avec les piles Annuler/Rétablir
  vides. Activer VoiceOver pour relever les libellés accessibles, puis le
  désactiver entre les relevés si nécessaire.
- Étapes :
  1. en largeur régulière et sans sélection, relever dans l’ordre Retour, Aide,
     nom/Renommer, état de sauvegarde, Sauvegarder, Annuler, Rétablir, Couper,
     Copier, Coller, Créer — Vue page, Organiser — Vue globale et
     Prévisualiser ; vérifier les symboles du tableau 7.2.1, Sauvegarder,
     Annuler et Rétablir désactivés dans cet état initial, Créer indiqué actif
     autrement que par la couleur, et l’absence des commandes Lots 2/3 Mise en
     page auto et Exporter ;
  2. vérifier Couper/Copier désactivés sans sélection, Coller désactivé sans
     payload compatible, Photos et Fonds accessibles, et l’état actif combinant
     forme/libellé/indicateur avec la couleur ;
  3. sélectionner le cadre vide : relever Ajouter une photo
     (`photo.badge.plus`), Rotation…, Dupliquer,
     Premier plan/Avancer/Reculer/Arrière-plan, Position et taille puis
     Supprimer dans cet ordre ; vérifier Recadrer et toutes les
     transformations de contenu absentes ou désactivées ;
  4. remplir puis sélectionner ce cadre : vérifier Couper et Copier activés,
     puis relever exactement Remplacer,
     Retirer la photo, Recadrer, Pivoter à gauche, Pivoter à droite, Retourner
     horizontalement, Description accessible…, Rotation…, Dupliquer, Premier
     plan, Avancer, Reculer, Arrière-plan, Position et taille puis Supprimer ;
     vérifier leurs symboles, libellés VoiceOver et états aux deux extrémités
     de profondeur, ainsi que Pleine page dans Position et taille ;
  5. toucher Copier, désélectionner et vérifier Coller activé ; toucher Coller,
     attendre Enregistré, puis vérifier Annuler activé/Rétablir désactivé ;
     toucher Annuler et vérifier Rétablir activé ; toucher Rétablir ;
  6. sélectionner une photo et entrer en mode Recadrer : vérifier que panneaux, navigation de page et
     transformations du cadre sont désactivés ; relever Zoom photo avec valeur
     en `×`, Annuler, Réinitialiser et Terminé, tandis que les trois commandes
     de zoom du canevas restent distinctes et désactivées ;
  7. quitter le cadrage, réduire la fenêtre en largeur compacte et recréer
     successivement les états sans sélection, cadre vide, cadre rempli et mode
     cadrage pour répéter la même matrice ; vérifier que le débordement
     s’intitule « Plus », conserve libellés, états et ordre relatif, et que
     Créer, Organiser et Prévisualiser ne sont pas enfouis dans Plus ;
  8. revenir en largeur régulière et vérifier que page, sélection et état de
     chaque commande sont conservés.
- Résultat attendu : chaque état de sélection expose uniquement la barre
  fonctionnelle prévue, dans l’ordre exact, avec SF Symbol de référence ou
  équivalent natif, libellé accessible inchangé et désactivation exacte ; la
  largeur compacte ne change aucun effet ni ordre métier. Les commandes Lots 2
  et 3 ne sont pas exposées conformément à `3:ARC-014`.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-118`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-105` — Réduire les animations

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:ACC-006`, sous-périmètre Lot 1 de `3:TST-010`.
- Préconditions : album de trois pages reconnaissables ; enregistrer une courte
  vidéo de référence avec Réduire les animations désactivé, puis activer
  Réglages > Accessibilité > Mouvement > Réduire les animations et relancer
  l’app.
- Étapes :
  1. ouvrir et fermer successivement Photos, Fonds et Aide ;
  2. passer de Vue page à Vue globale, ouvrir une miniature puis ouvrir et
     fermer Prévisualiser ;
  3. naviguer avec Précédent/Suivant et avec un balayage sur zone vide ;
  4. ouvrir puis annuler une confirmation et une feuille de sélection ;
  5. vérifier après chaque transition la page active, la sélection, le zoom et
     l’absence de nouvelle commande Annuler ;
  6. comparer la vidéo au parcours de référence et restaurer le réglage système.
- Résultat attendu : les transitions publiques du Lot 1 respectent le réglage,
  évitent tout mouvement ample ou désorientant et utilisent une transition
  réduite cohérente ; aucun état métier ni géométrie ne change. Le fondu de
  page final de `3:ANI-009` reste réservé à l’animation livrée au Lot 3 et n’est
  pas déclaré validé ici.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-119`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-106` — Aide contextuelle disponible hors ligne

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : sous-périmètre Lot 1 de `3:EDT-019`, `3:ARC-014`, `3:DEC-38`.
- Préconditions : album avec un cadre vide, un cadre rempli et une alerte de
  qualité ; activer le mode Avion avant de lancer l’app.
- Étapes :
  1. depuis Vue page sans panneau, ouvrir Aide et vérifier les rubriques de
     sélection, ajout photo, cadre vide et navigation ;
  2. ouvrir Photos puis Aide et vérifier que le contenu d’ajout, import,
     placement et suppression logique est présenté en premier ;
  3. ouvrir Fonds puis Aide et vérifier que le choix par page, Appliquer à
     toutes les pages et Annuler sont contextualisés ;
  4. sélectionner la photo, entrer en cadrage puis ouvrir Aide par la commande
     disponible et vérifier cadrage, Zoom photo, Annuler, Réinitialiser et
     Terminé ;
  5. depuis Vue globale avec l’alerte qualité, ouvrir Aide et vérifier pages,
     réorganisation et signification des alertes ;
  6. vérifier que toutes ces pages s’ouvrent sans réseau, utilisent une
     présentation iOS native, ne reprennent ni marque ni texte Photoweb et
     n’exposent aucune commande des Lots 2/3.
- Résultat attendu : Aide est consultable entièrement hors ligne et son premier
  contenu dépend de la vue, du panneau ou du mode actif ; elle couvre les
  fonctions publiques Lot 1 sans marque tierce. Modèles, dé, Auto, texte et
  stickers exigés par l’intégralité de `3:EDT-019` seront ajoutés et testés au
  Lot 2 : cette fiche ne valide que l’aide des fonctions publiques du Lot 1.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-120`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-107` — Progression, annulation et nettoyage d’un import long

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:APL-006`, `3:PERF-009`, `3:PERF-011`, `3:APP-006`,
  `3:SEC-008`.
- Préconditions : préparer au moins deux photos statiques non personnelles,
  dont un RAW ou JPEG assez volumineux pour que sa copie mesurée dépasse
  500 ms sur l’iPad testé, plus deux fichiers volumineux distincts réservés au
  sous-cas d’annulation. Noter noms, formats, tailles, dimensions et SHA-256.
  Si aucune copie ne dépasse 500 ms, la fiche ne peut pas réussir : répondre
  `BLOQUÉ` avec les durées observées.
- Étapes :
  1. démarrer un enregistrement d’écran avec horodatage puis lancer un import
     Fichiers multiple des deux photos ;
  2. pendant que le premier fichier est copié et que le suivant reste en
     attente, vérifier une ligne propre à chaque fichier et une progression
     globale de l’opération ;
  3. vérifier que la ligne courante passe de Copie en cours à Copie terminée,
     que la ligne suivante passe ensuite à Copie en cours, et que le compteur
     global avance sans régresser ni confondre un échec avec un succès ;
  4. vérifier qu’aucune ligne n’est annoncée Disponible avant la validation
     atomique finale de l’import ;
  5. attendre la disparition de la progression, vérifier les deux photos
     Disponibles dans le panneau, fermer et relancer hors ligne, puis les
     afficher ;
  6. lancer l’import des deux fichiers réservés, attendre Copie en cours puis
     toucher « Annuler l’import » avant la fin globale ;
  7. vérifier que l’annulation est annoncée, que la progression disparaît, que
     seules les copies annoncées comme déjà enregistrées peuvent rester
     Disponibles et qu’aucune entrée En attente ou fantôme ne subsiste ;
  8. revenir à la bibliothèque pendant un troisième import long, puis rouvrir
     l’album, relancer hors ligne et réimporter les fichiers non enregistrés.
- Résultat attendu : toute copie dépassant 500 ms montre simultanément sa
  activité individuelle et la progression globale ; les états restent
  attribués au bon fichier, « Copie terminée » ne signifie pas encore
  « Disponible », la fin globale correspond au traitement de toutes les
  copies et les deux ressources ne deviennent Disponibles qu’après la
  transaction finale, puis restent durables hors ligne. Annuler attend la fin
  de l’appel système indivisible en cours, conserve uniquement les copies déjà
  validées, nettoie les temporaires, ne laisse aucun état partiel et permet une
  nouvelle tentative. La fermeture ne libère pas la session sous un transfert
  PhotosPicker encore actif.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ; remplacée par `IPAD-L1-121`.
- Preuve : non exécutée avant modification ; aucun résultat extrapolé.
- Environnement : sans objet ; fiche remplacée avant exécution.
### `IPAD-L1-108` — Commandes rapides sérialisées sans perte ni erreur de révision

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Exigences : `3:APP-002`, `3:APP-005`, `3:LOC-011` à `3:LOC-014`,
  `3:UND-011`, `3:ARC-007`.
- Préconditions : album `Commandes rapides` enregistré, contenant une première
  page et au moins une photo disponible ; aucun import ni geste de cadrage en
  cours. Activer l’enregistrement d’écran afin de distinguer les pressions.
- Étapes :
  1. dans Vue globale, toucher très rapidement deux fois Ajouter une page ;
  2. attendre Enregistré, vérifier que les deux commandes acceptées sont
     présentes, qu’aucune alerte de révision obsolète ou d’action occupée
     n’apparaît et que les identifiants/pages ne sont pas dupliqués ;
  3. revenir en Vue page, déclencher presque simultanément un changement de
     fond puis Ajouter une page, attendre Enregistré et vérifier les deux
     effets ;
  4. revenir à la bibliothèque, renommer successivement le même album deux
     fois aussi vite que les dialogues le permettent ; attendre chaque
     fermeture et vérifier le dernier nom ;
  5. toucher rapidement Annuler deux fois dans la bibliothèque, attendre la
     fin des deux commandes puis vérifier le retour au nom initial ;
  6. toucher rapidement Rétablir deux fois, vérifier le dernier nom, ouvrir
     aussitôt l’album et confirmer que l’ouverture attend la clôture durable
     de la session bibliothèque sans écran modifiable concurrent ;
  7. fermer et relancer l’app, puis vérifier le nombre de pages, le fond et le
     nom obtenus à l’étape 6.
- Résultat attendu : toutes les commandes effectivement déclenchées sont
  traitées dans un ordre durable, sans `staleRevision`, message Occupé, perte
  silencieuse ni écrasement d’un état plus récent ; Annuler/Rétablir conserve
  l’ordre de session, l’ouverture ne chevauche pas une mutation bibliothèque
  et la relance retrouve exactement l’état annoncé Enregistré.
- Résultat : ⚫ `NON APPLICABLE` — fiche rendue obsolète par les corrections ;
  remplacée par `IPAD-L1-131`.
- Preuve : non exécutée avant modification ; le scénario traverse désormais la
  transition post-création et l’inspecteur Fonds corrigés.
- Environnement : sans objet.

## Campagne de régression après retours du 16 août 2026

Les fiches fonctionnelles ci-dessous ciblent le nouveau correctif de compilation
`638c659925e1b036570484a98c0fc016602687c9`. Les candidats
`06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` et
`84ec71e1a66df4676e3c388e9d4f87a5a7e06e4e` restent rejetés avant exécution
fonctionnelle. `IPAD-L1-133` a ensuite validé la compilation et les autres
fiches ont été exécutées sur la même copie exacte ; leurs résultats ci-dessous
restent la preuve historique de ce candidat.

### `IPAD-L1-109` — Interruption et sauvegarde après correctifs gestuels

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:SAV-001`, `3:APP-009`, `3:LOC-011` à `3:LOC-014`,
  `3:LOC-026`.
- Préconditions : album jetable avec deux pages et un cadre rempli.
- Étapes : ajouter une page puis forcer la fermeture après confirmation ;
  relancer ; déplacer ensuite un cadre, toucher Sauvegarder avant de relever le
  doigt, relever le doigt, fermer de force puis relancer.
- Résultat attendu : page et position validées retrouvées ; aucun saut après
  Sauvegarder, une seule commande de déplacement et aucun état partiel.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-109 : ok` ; aucune capture jointe.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-110` — Prévisualisation et fonds mis en cache

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:CAN-003`, `3:CAN-004`, `3:CAN-008`, `3:GLO-007`,
  `3:PERF-016`.
- Préconditions : page avec motif intégré et trois cadres superposés ; canevas
  décentré à environ 175 %.
- Étapes : comparer éditeur, Vue globale et Prévisualiser ; revenir à la page ;
  ouvrir Photos puis Fonds trois fois sans quitter l’album et chronométrer le
  premier retour visuel de chaque ouverture.
- Résultat attendu : composition identique hors aides d’édition, état de fenêtre
  restauré ; structure de Fonds visible en moins de 200 ms et aucune attente de
  plusieurs secondes lors des réouvertures.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-110 : ok` ; aucune capture jointe.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-111` — Cadre vide et mode de choix explicite

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:FRM-001`, `3:FRM-008`, `3:GLO-006`, `3:PHO-011` à
  `3:PHO-013`.
- Préconditions : page 1 avec cadre vide, page 2 vide, deux photos disponibles.
- Étapes : toucher Ajouter une photo dans le cadre vide, vérifier l’annonce de
  la cible puis Annuler ; recommencer et remplir ; page 2, utiliser l’ajout local,
  vérifier « nouveau cadre », changer de page avant le choix puis recommencer.
- Résultat attendu : modes visibles et annulables ; aucune création à
  l’annulation ou au changement de page ; choix final remplit ou crée uniquement
  la cible annoncée ; alertes de cadre vide restent cohérentes.
- Résultat : 🟢 `RÉUSSI` — parcours fonctionnel validé ; amélioration visuelle
  demandée puis approuvée pour renforcer les trois annonces sans utiliser le
  rouge. Régression créée sous `IPAD-L1-135`.
- Preuve : retour explicite `IPAD-L1-111 : ok` et observation que l’icône cible
  et le contraste du bandeau étaient trop discrets.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-112` — Qualité informative et format régional

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:QLT-001` à `3:QLT-006`, `3:EDT-021`, `3:L10N-005`.
- Préconditions : grande fixture dans un cadre ; région France.
- Étapes : valider successivement `1,00×`, `1,50×` et `3,00×`, puis refaire le
  contrôle `1,08×` en France et aux États-Unis ; sélectionner le cadre dans les
  deux largeurs d’interface.
- Résultat attendu : états `OK`, `Acceptable`, `Insuffisante` et bascule
  régionale attendus ; la qualité est un libellé informatif distinct des boutons,
  accessible, et ne bloque ni édition ni sauvegarde.
- Résultat : 🟠 `BLOQUÉ` — « format régional » et le changement de région
  attendu n’étaient pas explicités ; aucun verdict ne peut être extrapolé sur
  les séparateurs décimaux. Procédure remplacée par `IPAD-L1-139`.
- Preuve : retour utilisateur « je ne comprends pas le test, je ne sais pas ce
  qu’est le format régional ».
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-113` — Inspecteur droit et adaptation compacte

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:EDT-002`, `3:EDT-006`, `3:EDT-011`, `3:EDT-016`,
  `3:EDT-021`, `3:ACC-021`.
- Préconditions : iPad en largeur régulière puis compacte ; cadre rempli
  sélectionné.
- Étapes : ouvrir Photos et Fonds ; vérifier l’inspecteur à droite, ses groupes
  Contenu/Cadre et son repli ; tourner l’iPad, passer si possible en largeur
  compacte, ouvrir/fermer le panneau et retrouver la largeur régulière.
- Résultat attendu : aucune commande inaccessible ou superposée ; sélection et
  page conservées ; présentation compacte dans la même fenêtre et inspecteur
  droit restauré en largeur régulière.
- Résultat : 🔴 `ÉCHOUÉ` — en portrait, la droite du panneau Photos est
  tronquée au-delà de trois photos ; en paysage, Ajouter une photo se comprime
  sur plusieurs lignes et étire verticalement toute la barre du canevas.
- Preuve : captures utilisateur `IMG_4184.jpg` (portrait) et `IMG_4185.jpg`
  (paysage), conservées hors Git ; remplacement `IPAD-L1-135`.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-114` — Dynamic Type, choix non ambigu et VoiceOver

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:ELM-014`, `3:ACC-001` à `3:ACC-005`, `3:ACC-007`,
  `3:ACC-008`, `3:ACC-011`, `3:ACC-012`, `3:ACC-017`, `3:ACC-020`.
- Préconditions : trois cadres photo fortement superposés, avec noms ou
  descriptions distincts ; Dynamic Type élevé et VoiceOver disponibles.
- Étapes : ouvrir Sélectionner un élément depuis la barre et le canevas ; lire
  les trois choix ; sélectionner successivement arrière, milieu et avant ;
  parcourir ensuite Photos, Fonds, corbeille et confirmations avec VoiceOver.
- Résultat attendu : chaque choix annonce type, repère distinctif, position et
  profondeur ; aucun libellé essentiel tronqué sans défilement et aucune
  sélection ne change la profondeur.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-114 : ok` ; enregistrement non joint.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-115` — Pointeur, poignées hybrides et rotation directe

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:ELM-002`, `3:ELM-011` à `3:ELM-013`, `3:ACC-005`,
  `3:ACC-013` à `3:ACC-015`.
- Préconditions : clavier/pointeur si disponibles ; cadre partiellement hors
  page puis cadre dont une bordure sort de la fenêtre.
- Étapes : contrôler les neuf poignées aux bordures visibles et les cibles de
  secours lorsque la bordure sort ; ouvrir Rotation…, déplacer le curseur et
  utiliser `±90°`, Annuler, puis recommencer et Valider.
- Résultat attendu : bordures et poignées visuelles coïncident lorsqu’elles sont
  visibles ; les secours restent activables ; rotation visible en direct ;
  Annuler restaure l’entrée et Valider crée une seule commande.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-115 : ok` ; vidéo non jointe.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-116` — Relance locale et cache des fonds hors ligne

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:LOC-001`, `3:SEC-001`, `3:ERR-008`, `3:PERF-007`,
  `3:PERF-016`.
- Préconditions : deux albums utilisant les trois motifs intégrés ; mode Avion.
- Étapes : relancer trois fois et chronométrer jusqu’au premier contenu ; ouvrir
  chaque album et chaque fond ; alterner Photos/Fonds cinq fois ; modifier un
  fond, enregistrer et relancer toujours hors ligne.
- Résultat attendu : premier contenu en moins de deux secondes dans l’enveloppe
  visée, aucune revalidation bloquante du catalogue, réouvertures immédiates et
  état durable sans réseau.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-116 : ok` ; durées et vidéo non jointes.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-117` — Cent pages, compteurs et déplacement continu

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:PAG-012`, `3:PHO-002`, `3:PERF-008`, `3:PERF-015`,
  `3:PERF-017`.
- Préconditions : album de 100 pages et une fixture locale.
- Étapes : chronométrer l’ouverture ; créer vingt occurrences du même asset et
  vérifier `×20` ; déplacer un cadre plusieurs secondes ; créer la 21e
  occurrence puis la 101e page et relancer.
- Résultat attendu : compte exact des seuls cadres de l’album, avertissements
  non bloquants, aucune écriture ou redécodage visible pendant le mouvement et
  état final durable.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-117 : ok` ; mesures et captures non jointes.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-118` — Matrice des commandes dans le nouvel inspecteur

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:EDT-010` à `3:EDT-017`, `3:EDT-021`, `3:FRM-005`,
  `3:FRM-006`.
- Préconditions : cadre vide, cadre rempli, seconde photo et presse-papiers
  vide ; largeurs régulière puis compacte.
- Étapes : relever les états sans sélection, cadre vide, cadre rempli et
  cadrage ; en régulier contrôler les groupes verticaux Contenu puis Cadre et
  Supprimer à côté de Copier/Coller ; en compact contrôler les mêmes effets et
  l’ordre relatif ; exercer Supprimer.
- Résultat attendu : matrice complète, qualité non interactive, actions de
  contenu séparées des transformations du cadre et Supprimer immédiatement
  accessible sans ambiguïté.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-118 : ok` ; captures non jointes.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-119` — Réduire les animations avec inspecteur droit

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:ACC-006`, `3:EDT-002`, sous-périmètre Lot 1 de `3:TST-010`.
- Préconditions : album de trois pages ; vidéos de référence avec Réduire les
  animations désactivé puis activé.
- Étapes : replier/afficher l’inspecteur, alterner Photos/Fonds, ouvrir/fermer
  Aide, Vue globale et Prévisualiser, puis naviguer par boutons et balayage.
- Résultat attendu : transitions réduites cohérentes, aucun mouvement ample et
  aucun changement de page, sélection, zoom ou historique causé par l’interface.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-119 : ok` ; vidéos non jointes.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-120` — Aide contextuelle depuis le nouvel inspecteur

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:EDT-019`, `3:EDT-021`, `3:ARC-014`, `3:DEC-38`.
- Préconditions : mode Avion ; cadre vide, cadre rempli et alerte qualité.
- Étapes : ouvrir Aide sans panneau, depuis Photos, depuis Fonds, pendant le
  cadrage, depuis l’inspecteur de cadre puis depuis Vue globale.
- Résultat attendu : aide locale contextualisée sur le panneau ou mode courant,
  incluant la séparation Contenu/Cadre sans exposer les lots 2/3.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-120 : ok` ; captures non jointes.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-121` — Import long, annulation et déduplication

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:APL-006`, `3:PHO-019`, `3:PERF-009`, `3:PERF-011`,
  `3:APP-006`, `3:SEC-008`.
- Préconditions : deux JPEG distincts dont la copie dépasse 500 ms et une copie
  exacte du premier ; noms, tailles et SHA-256 notés.
- Étapes : importer les deux distincts et suivre chaque état ; réimporter le
  premier seul puis dans un lot où il apparaît deux fois ; lancer enfin un
  import long et l’annuler avant la fin.
- Résultat attendu : progression attribuée au bon fichier ; aucune seconde
  miniature ni commande de contenu pour les empreintes déjà présentes ; ordre
  des nouveautés conservé ; annulation nettoyée et relance cohérente.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-121 : ok` ; vidéo et empreintes non jointes.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-122` — Lancement et réouverture rapide des Fonds

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:PERF-004`, `3:PERF-007`, `3:PERF-016`, `3:BG-008`.
- Préconditions : stockage 3.0 existant avec au moins un album et les trois
  fonds déjà utilisés une fois.
- Étapes : relancer trois fois en chronométrant le premier contenu ; dans le
  même album, alterner cinq fois Photos et Fonds.
- Résultat attendu : lancement sous la cible de deux secondes, structure de
  Fonds sous 200 ms, aucun blocage d’environ 6 ou 15 secondes et motifs chargés
  progressivement sans écran figé.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-122 : ok` ; tableau et vidéo non joints.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-123` — Retour après création et dates de corbeille

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:ALB-006`, `3:ALB-017` à `3:ALB-025`.
- Préconditions : bibliothèque ouverte ; date système connue.
- Étapes : créer un album, attendre son ouverture automatique puis toucher
  immédiatement Retour aux albums ; le mettre à la corbeille et l’ouvrir.
- Résultat attendu : retour fonctionnel sans relance ; deux dates absolues en
  français, « Mise à la corbeille » et « Suppression définitive prévue »,
  séparées de trente périodes de 24 h.
- Résultat : 🔴 `ÉCHOUÉ` — le retour après création fonctionne, mais les deux
  dates de corbeille sont en anglais dans une interface française.
- Preuve : observation textuelle explicite de l’utilisateur ; remplacement
  `IPAD-L1-136`.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-124` — Compteur exact et grilles photo carrées

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:PHO-002`, `3:PHO-009`, `3:PHO-015`, `3:PHO-019`.
- Préconditions : deux albums partageant les mêmes octets sous deux `assetID` ;
  cible avec exactement une occurrence et au moins huit photos sources.
- Étapes : vérifier `×1` dans la cible après suppression définitive de la
  source ; ouvrir le menu et l’annonce d’usage ; afficher le panneau puis la
  grille Depuis vos autres albums en largeur permettant quatre colonnes.
- Résultat attendu : compte limité à l’`assetID` courant ; miniatures carrées,
  non superposées et compteur entièrement visible dans toutes les colonnes.
- Résultat : 🟠 `BLOQUÉ` — la photo réutilisée dans B a correctement été ajoutée
  sans placement (`×0`) et la suppression de A n’a pas affecté B, mais la
  précondition « exactement une occurrence dans B » n’a pas été réalisée ; le
  contrôle `×1` ne peut donc pas être conclu. Procédure remplacée par `140`.
- Preuve : `×2` observé dans A, `×0` dans B après ajout, B inchangé après
  suppression de A ; le reste du test, dont les grilles, est déclaré OK.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-125` — Modes Ajouter, Remplir et Remplacer explicites

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:PHO-004`, `3:PHO-011` à `3:PHO-013`, `3:FRM-004`.
- Préconditions : page vide, cadre vide, cadre rempli et deux photos disponibles.
- Étapes : lancer successivement l’ajout local, l’ajout du cadre vide et
  Remplacer ; pour chaque mode vérifier la cible, Annuler puis refaire et choisir
  une miniature.
- Résultat attendu : le panneau annonce respectivement Nouveau cadre, Remplir
  ce cadre et Remplacer la photo ; Annuler est sans effet ; un seul objet cible
  change après le choix.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-125 : ok` ; captures non jointes.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-126` — Insertion de page et activation après Rétablir

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:PAG-004`, `3:PAG-005`, `3:PAG-010`, `3:PAG-016`.
- Préconditions : album de cinq pages reconnaissables.
- Étapes : glisser la page 5 avant les pages 2 puis 4 et après la dernière en
  observant l’indicateur ; supprimer la page active, Annuler puis Rétablir.
- Résultat attendu : indicateur clignotant avant la cible ou en fin (fixe et
  visible avec Réduire les animations), ordre conforme ; la
  page recréée par Rétablir devient immédiatement active.
- Résultat : 🔴 `ÉCHOUÉ` — ordre et activation après Rétablir corrects ; contour
  actif trop fin et terne, indicateur d’insertion superposé à la cible au lieu
  d’être entre les pages. Remplacement `IPAD-L1-137`.
- Preuve : observation textuelle explicite ; proposition contour renforcé,
  badge « Page active » et indicateur intercartes approuvée par l’utilisateur.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-127` — Sélection non ambiguë, poignées hybrides et rotation

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:ELM-002`, `3:ELM-013`, `3:ELM-014`, `3:EDT-021`.
- Préconditions : trois cadres superposés nommés distinctement ; l’un déborde de
  la page.
- Étapes : identifier chaque cadre par Sélectionner un élément ; vérifier les
  poignées sur les bordures visibles et les secours ; modifier Rotation… sans
  valider, Annuler, puis modifier et Valider ; Annuler une fois.
- Résultat attendu : choix non ambigus, commandes à droite séparées, aperçu en
  direct, restauration exacte à Annuler et une seule commande après Valider.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-127 : ok` ; vidéo non jointe.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-128` — Pincement, panoramique et balayage après retour

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:ZOM-003` à `3:ZOM-006`, `3:NAV-001` à `3:NAV-007`.
- Préconditions : album de trois pages ; page 1 ajustée puis zoomée à 200 %.
- Étapes : pincer seul, déplacer deux doigts à distance constante, combiner
  zoom et translation ; naviguer 1→2→1 par boutons puis 1→2→1 par balayage sur
  zone vide ; répéter après ouverture/fermeture de Photos.
- Résultat attendu : zoom et translation tous deux utilisables et composables ;
  aucun geste à deux doigts ne tourne la page ; le balayage reste disponible à
  chaque retour page 1.
- Résultat : 🔴 `ÉCHOUÉ` — à 200 %, aucun pincement, panoramique ni geste
  combiné n’agit quand aucun cadre n’est sélectionné, que le départ soit dans
  une zone vide ou sur l’un des trois cadres non sélectionnés ; sélectionner un
  cadre donne seulement la priorité aux transformations de ce cadre.
- Preuve : observation textuelle précisée par l’utilisateur ; remplacement
  `IPAD-L1-138`.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-129` — Sauvegarde au milieu d’un déplacement

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:ELM-007`, `3:SAV-001` à `3:SAV-003`, `3:UND-007`.
- Préconditions : cadre sélectionné et position initiale repérée.
- Étapes : commencer un déplacement, toucher Sauvegarder d’un second doigt,
  continuer légèrement puis relever le premier ; toucher Annuler une fois puis
  Rétablir une fois ; fermer et relancer.
- Résultat attendu : position capturée au toucher Sauvegarder, aucun saut ni
  seconde commande après le relâchement ; Annuler/Rétablir unique et état
  durable après relance.
- Résultat : 🟢 `RÉUSSI` — toucher Sauvegarder termine le premier geste ; le
  mouvement ultérieur du doigt déjà posé reste sans effet, conformément à
  l’absence de saut ou de seconde commande attendue.
- Preuve : observation explicite de l’utilisateur, puis confirmation demandée
  et reçue pour valider le test.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-130` — Presse-papiers strictement limité à la session

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:CLP-001` à `3:CLP-006`, `3:UND-012`.
- Préconditions : album A avec cadre rempli et album B actif.
- Étapes : copier dans A et coller sur une autre page de A ; copier de nouveau,
  quitter vers la bibliothèque, ouvrir B puis A et relever Coller ; répéter avec
  un passage en arrière-plan.
- Résultat attendu : collage intrasession dans A réussi ; Coller désactivé dans
  B et toujours désactivé au retour dans A ou après arrière-plan, sans
  réactivation d’un ancien payload.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-130 : ok` ; vidéo non jointe.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-131` — Commandes rapides après correction des transitions d’interface

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Exigences : `3:ALB-006`, `3:APP-002`, `3:APP-005`, `3:EDT-021`,
  `3:LOC-011` à `3:LOC-014`, `3:UND-011`.
- Préconditions : album A de trois pages avec photos et fonds distincts ;
  bibliothèque prête à créer un album B.
- Étapes : dans A, déclencher rapidement Ajouter une page, changer de fond,
  Annuler puis Rétablir depuis le nouvel inspecteur ; revenir à la bibliothèque,
  créer B, attendre son ouverture automatique, revenir immédiatement aux albums
  puis rouvrir A ; renommer enfin A tout en enchaînant Annuler/Rétablir selon les
  états activés, fermer et relancer.
- Résultat attendu : chaque commande acceptée est exécutée une fois dans son
  ordre durable, sans `staleRevision`, perte ni écrasement ; aucun chevauchement
  de feuille et d’éditeur ne bloque Retour ; fonds, nombre de pages et nom final
  correspondent aux commandes observées après relance.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-131 : ok` ; vidéo et états détaillés non
  joints.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-132` — Compilation du correctif dans Swift Playgrounds

- Candidat : `84ec71e1a66df4676e3c388e9d4f87a5a7e06e4e`.
- Spécification : 3.0, inchangée depuis
  `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7`.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:LOT-001`, `3:DONE-005`.
- Préconditions : copier exactement le candidat figé dans Swift Playgrounds,
  sans modification locale ; conserver le même appareil et relever la version
  de l’OS et de Swift Playgrounds.
- Étapes : ouvrir `Albumzh.swiftpm`, vider les anciens diagnostics si
  nécessaire, lancer la compilation, puis démarrer l’app et attendre le premier
  contenu de la bibliothèque.
- Résultat attendu : compilation sans erreur, notamment aucun argument
  `maximumPixelSize` manquant dans `AlbumCoverView` et aucune inférence
  générique impossible dans `AppModel` ; l’app démarre sans fermeture
  inattendue. Ce contrôle ne valide aucune autre régression fonctionnelle.
- Résultat : 🔴 `ÉCHOUÉ` — `AlbumCoverView`, ligne 128 : « Missing argument for
  parameter 'maximumPixelSize' in call » sur
  `_ = await imageCache.catalogImage(for: hash)`.
- Preuve : diagnostic exact transmis par l’utilisateur ; l’erreur d’inférence
  générique précédemment signalée dans `AppModel` n’est pas réapparue dans ce
  retour.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  sources applicatives `84ec71e1a66df4676e3c388e9d4f87a5a7e06e4e` ; 16 août
  2026 ; Paris, France ; français (France).

### `IPAD-L1-133` — Recompilation après correction de tous les appels catalogue

- Candidat : `638c659925e1b036570484a98c0fc016602687c9`.
- Spécification : 3.0, inchangée depuis
  `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7`.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:LOT-001`, `3:DONE-005`.
- Préconditions : copier exactement le nouveau candidat figé dans Swift
  Playgrounds, sans modification locale ; relever appareil, OS et version de
  Swift Playgrounds.
- Étapes : rechercher d’abord les anciens diagnostics, ouvrir
  `AlbumCoverView.swift`, puis compiler `Albumzh.swiftpm` et démarrer l’app
  jusqu’au premier contenu de la bibliothèque.
- Résultat attendu : les deux préchargements de fond de couverture appellent
  `catalogImage(for:maximumPixelSize:)` avec `480` ; aucune erreur d’argument
  manquant ni d’inférence générique ne subsiste ; l’app démarre. Ce contrôle ne
  valide aucune autre régression fonctionnelle.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour explicite `IPAD-L1-133 : ok` ; aucune capture jointe ; les
  régressions fonctionnelles ont ensuite pu être exécutées sur la même copie.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

## Campagne ciblée après les résultats `102`, `109…131` et `133`

Les sept fiches suivantes visent toutes le même candidat exact
`7a0f2a442f5f13a98663c5c02a97b8110bd943d6`. Elles ne remettent pas en cause
les réussites acquises sur `638c659…`, mais rejouent chaque comportement dont
le code ou la preuve vient de changer.

### `IPAD-L1-134` — Compilation du correctif d’interface et de gestes

- Candidat : `7a0f2a442f5f13a98663c5c02a97b8110bd943d6`.
- Spécification : 3.0, avec clarification de `3:EDT-002`, `3:PHO-011`,
  `3:PAG-016`, `3:GLO-003` et `3:ZOM-003` à `3:ZOM-005` dans le candidat.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:LOT-001`, `3:DONE-005`.
- Préconditions : récupérer exactement le candidat figé, sans modifier les
  sources dans Swift Playgrounds ; conserver le store de la campagne précédente.
- Étapes : ouvrir `Albumzh.swiftpm`, effacer les anciens diagnostics, compiler,
  lancer l’app et ouvrir un album existant jusqu’au canevas et à Photos.
- Résultat attendu : aucune erreur ni avertissement bloquant ; bibliothèque,
  album, canevas et inspecteur s’affichent avec les données antérieures.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur explicite « tout est ok sauf le
  `IPAD-L1-135` » ; aucune capture de compilation jointe.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-135` — Bannière de choix et inspecteur adaptatif

- Candidat : `7a0f2a442f5f13a98663c5c02a97b8110bd943d6`.
- Exigences : `3:EDT-002`, `3:EDT-006`, sous-périmètre photo de `3:EDT-020`,
  `3:PHO-002`, `3:PHO-011` à `3:PHO-013`, `3:ACC-021`.
- Préconditions : au moins huit photos, un cadre vide et un cadre rempli ;
  iPad d’abord en portrait puis en paysage.
- Étapes : dans les deux orientations, ouvrir Photos et faire défiler toute la
  grille ; lancer successivement Ajouter une photo, Remplir le cadre vide et
  Remplacer, puis Annuler chaque mode ; observer enfin la barre sous le canevas.
- Résultat attendu : aucune colonne ni badge `×N` n’est tronqué ; toutes les
  miniatures restent carrées ; les trois annonces ont un fond orange ou jaune,
  une bordure nette et respectivement une icône d’ajout, de cadre et de
  remplacement, jamais rouge ; Ajouter une photo reste sur une ligne, à hauteur
  normale, sans agrandir la barre de zoom ou la navigation.
- Résultat : 🔴 `ÉCHOUÉ` — la grille n’affiche plus que deux colonnes, mais les
  tuiles agrandies débordent encore et les photos restent tronquées ; la barre
  inférieure a retrouvé une hauteur correcte, mais son bouton gauche reste
  tronqué. Remplacement `IPAD-L1-142`.
- Preuve : observation explicite et captures `IMG_4186.jpg` portrait et
  `IMG_4187.jpg` paysage, conservées hors Git. Les autres attentes de la fiche
  ne sont pas extrapolées séparément.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-136` — Dates françaises de corbeille

- Candidat : `7a0f2a442f5f13a98663c5c02a97b8110bd943d6`.
- Exigences : `3:ALB-017`, `3:ALB-018`, `3:ALB-025`, `3:L10N-005`.
- Préconditions : langue Français, région France et date système connue ; album
  jetable actif.
- Étapes : placer l’album dans la corbeille, ouvrir la corbeille et relever les
  deux dates ; vérifier que la seconde correspond à trente périodes de 24 h.
- Résultat attendu : les libellés et les mois sont en français, par exemple
  « 16 août 2026 », sans mot anglais ; les dates sont absolues et séparées de
  trente périodes de 24 h.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur explicite « tout est ok sauf le
  `IPAD-L1-135` » ; capture dédiée non jointe.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-137` — Page active et insertion entre miniatures

- Candidat : `7a0f2a442f5f13a98663c5c02a97b8110bd943d6`.
- Exigences : `3:PAG-004`, `3:PAG-005`, `3:PAG-010`, `3:PAG-016`,
  `3:GLO-003`, `3:ACC-006`.
- Préconditions : cinq pages reconnaissables ; refaire une fois avec Réduire les
  animations désactivé puis activé.
- Étapes : ouvrir Organiser ; identifier la page active ; glisser la page 5
  avant les pages 2 puis 4 et après la dernière ; supprimer la page active,
  Annuler puis Rétablir.
- Résultat attendu : la page active combine un contour orange épais et le badge
  « Page active » ; l’indicateur est centré dans l’espace avant la cible ou
  après la dernière, jamais sur son contenu ; il clignote normalement et reste
  fixe avec Réduire les animations ; ordre et activation après Rétablir sont
  corrects.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur explicite « tout est ok sauf le
  `IPAD-L1-135` » ; vidéo et capture dédiées non jointes.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-138` — Gestes canevas sur vide et cadres non sélectionnés

- Candidat : `7a0f2a442f5f13a98663c5c02a97b8110bd943d6`.
- Exigences : `3:ZOM-003` à `3:ZOM-006`, `3:ELM-003`, `3:NAV-001` à
  `3:NAV-005`.
- Préconditions : page 1 avec trois cadres vides espacés, aucun sélectionné ;
  page ajustée puis zoomée à 200 % ; deux autres pages.
- Étapes : commencer dans une zone vide puis sur chacun des cadres non
  sélectionnés : pincer, déplacer deux doigts à distance constante et combiner
  les deux gestes ; vérifier qu’aucun cadre n’est sélectionné. Sélectionner
  ensuite un cadre et vérifier que les gestes commencés dedans transforment le
  cadre. Deselecter, naviguer 1→2→1 par boutons puis balayage et répéter après
  ouverture/fermeture de Photos.
- Résultat attendu : les six gestes de canevas modifient immédiatement zoom ou
  centre sans tourner la page ni sélectionner le cadre sous les doigts ; le
  cadre déjà sélectionné garde sa priorité ; navigation et retour page 1
  restent disponibles.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur explicite « tout est ok sauf le
  `IPAD-L1-135` » ; vidéo dédiée non jointe.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-139` — Qualité et séparateurs régionaux explicités

- Candidat : `7a0f2a442f5f13a98663c5c02a97b8110bd943d6`.
- Exigences : `3:QLT-001` à `3:QLT-006`, `3:EDT-021`, `3:L10N-005`.
- Préconditions : grande fixture dans un cadre rempli ; langue Français et
  région France. Ici « format régional » désigne le séparateur décimal choisi
  par Réglages > Général > Langue et région > Région.
- Étapes : relever les états de qualité aux valeurs demandées `1,00×`, `1,50×`
  et `3,00×` ; régler `1,08×` et capturer l’affichage en région France ; passer
  temporairement la région à États-Unis, rouvrir le même album sans modifier
  la langue, capturer la même valeur, puis restaurer France.
- Résultat attendu : les trois états attendus sont respectivement `OK`,
  `Acceptable` et `Insuffisante` ; le libellé Qualité n’a pas l’apparence d’un
  bouton et ne bloque pas la sauvegarde ; la même valeur s’affiche `1,08×` en
  France et `1.08×` aux États-Unis.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur explicite « tout est ok sauf le
  `IPAD-L1-135` » ; captures régionales dédiées non jointes.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-140` — Compteur autonome après réutilisation interalbum

- Candidat : `7a0f2a442f5f13a98663c5c02a97b8110bd943d6`.
- Exigences : `3:PHO-002`, `3:PHO-009`, `3:PHO-015` à `3:PHO-019`.
- Préconditions : album A avec exactement deux occurrences d’une photo ; album
  B sans cette empreinte et avec une page vide.
- Étapes : ajouter la photo à B depuis A et vérifier `×0` ; toucher sa miniature
  une fois dans B et vérifier `×1` ; supprimer définitivement l’album A et
  vérifier que B reste à `×1` avec la photo visible ; retirer l’occurrence dans
  B et vérifier `×0` puis l’état de suppression disponible.
- Résultat attendu : l’ajout interalbum crée un asset autonome disponible mais
  ne le place pas ; chaque compteur ne compte que les cadres du même album et
  du même `assetID` ; supprimer A ne change ni la photo ni le compteur de B ;
  miniatures et badges restent carrés, entiers et non superposés.
- Résultat : 🟢 `RÉUSSI` — le parcours métier et les compteurs sont validés ;
  après l’échec de présentation sous `142`, la grille sera rejouée sous `144`.
- Preuve : retour utilisateur explicite « tout est ok sauf le
  `IPAD-L1-135` » ; captures successives dédiées non jointes.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

## Régression après le second échec d’adaptation de `135`

Les deux fiches suivantes visent le même candidat exact
`48e9fef9c317835f605df430c4112320d8cb66c3`. Elles ne rouvrent pas les
réussites `136…140`, sauf la seule présentation de grille partagée avec `140`
et explicitement reprise par `142`, puis par `144` après son nouvel échec.

### `IPAD-L1-141` — Compilation du correctif adaptatif final

- Candidat : `48e9fef9c317835f605df430c4112320d8cb66c3`.
- Spécification : 3.0, avec clarification de `3:EDT-020` dans le candidat.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:LOT-001`, `3:DONE-005`.
- Préconditions : copier exactement `48e9fef9c317835f605df430c4112320d8cb66c3` dans Swift
  Playgrounds sans modification locale et conserver le store précédent.
- Étapes : effacer les anciens diagnostics, compiler `Albumzh.swiftpm`, lancer
  l’app puis ouvrir un album jusqu’au canevas et à l’inspecteur Photos.
- Résultat attendu : aucune erreur ni avertissement bloquant ; le store et les
  albums précédents restent lisibles.
- Résultat : 🟢 `RÉUSSI` — l’app a nécessairement compilé et démarré pour
  permettre les observations fonctionnelles précises de `142`.
- Preuve : retour utilisateur décrivant le rendu du canevas et du panneau sur
  le candidat ; aucune capture distincte du build n’a été fournie, la preuve de
  compilation reste donc indirecte.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-142` — Trois colonnes contraintes et action locale sans troncature

- Candidat : `48e9fef9c317835f605df430c4112320d8cb66c3`.
- Exigences : `3:EDT-002`, `3:EDT-006`, sous-périmètre photo de `3:EDT-020`,
  `3:PHO-002`, `3:PHO-011` à `3:PHO-013`, `3:PHO-019`, `3:ACC-021`.
- Préconditions : au moins huit photos avec des noms longs et des compteurs
  `×0`, `×1` et `×3` visibles ; un cadre vide et un cadre rempli.
- Étapes : en portrait puis en paysage, ouvrir Photos, faire défiler toute la
  grille et vérifier ses bords ; lancer Ajouter, Remplir et Remplacer puis
  Annuler ; observer et activer enfin le bouton à gauche de la barre du canevas.
- Résultat attendu : l’inspecteur régulier affiche trois colonnes entièrement
  contenues, de largeur égale, avec miniatures carrées, noms tronqués au milieu
  dans leur seule ligne et badges entiers ; aucun contenu ne dépasse à droite.
  Les trois bandeaux restent distincts. Le bouton local affiche le libellé
  complet s’il tient, sinon « Ajouter », sinon l’icône seule, jamais des points
  de suspension ni une forme coupée ; son annonce reste « Ajouter une photo »
  et l’action ouvre bien le mode de choix sans agrandir la barre.
- Résultat : 🔴 `ÉCHOUÉ` — en portrait, la grille revient bien à trois colonnes,
  mais la troisième est presque entièrement hors écran ; le bouton « Ajouter
  une photo » reste légèrement coupé à gauche et l’accès permettant de choisir
  Photos ou Fonds n’est plus affiché dans l’état signalé. Aucun résultat
  paysage distinct n’est extrapolé de ce retour.
- Preuve : retours utilisateur successifs décrivant les trois défauts visibles ;
  les captures antérieures `IMG_4186.jpg` et `IMG_4187.jpg` restent hors Git.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

## Régression après débordement global du candidat `48e9fef…`

Le correctif suivant rend adaptatif le groupe complet situé sous le canevas.
Il conserve les variantes sur une rangée lorsqu’elles tiennent et utilise en
dernier recours deux rangées de hauteur normale : ajout par icône et zoom,
puis navigation. Cette largeur minimale réduite doit empêcher le canevas de
repousser hors écran le rail et l’inspecteur fixe. Le candidat exact est
`101e2948252f51991933b8d61f767f52aa6b629d`.

### `IPAD-L1-143` — Compilation du correctif de largeur globale

- Candidat : `101e2948252f51991933b8d61f767f52aa6b629d`.
- Spécification : 3.0, avec clarification de `3:EDT-002` et `3:EDT-020` dans
  le candidat.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:LOT-001`, `3:DONE-005`.
- Préconditions : copier exactement le commit indiqué dans cette fiche dans
  Swift Playgrounds sans modification locale et conserver le store précédent.
- Étapes : effacer les anciens diagnostics, compiler `Albumzh.swiftpm`, lancer
  l’app puis ouvrir un album jusqu’au canevas et à l’inspecteur Photos.
- Résultat attendu : aucune erreur ni avertissement bloquant ; le store et les
  albums précédents restent lisibles.
- Résultat : 🟢 `RÉUSSI` — l’app a nécessairement compilé et démarré pour
  permettre la validation fonctionnelle de `144`.
- Preuve : retour utilisateur « tout est ok maintenant » après exécution du
  candidat ; aucune capture distincte du build n’a été fournie, la preuve de
  compilation reste donc indirecte.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

### `IPAD-L1-144` — Rail, inspecteur et commandes entièrement contenus

- Candidat : `101e2948252f51991933b8d61f767f52aa6b629d`.
- Exigences : `3:EDT-002`, `3:EDT-006`, sous-périmètre photo de `3:EDT-020`,
  `3:PHO-002`, `3:PHO-011` à `3:PHO-013`, `3:PHO-019`, `3:ACC-021`.
- Préconditions : au moins huit photos avec des noms longs et des compteurs
  `×0`, `×1` et `×3` visibles ; un cadre vide et un cadre rempli.
- Étapes : en portrait, vérifier que le rail Photos/Fonds est visible, ouvrir
  chacun des deux panneaux puis revenir à Photos ; faire défiler toute la
  grille et vérifier ses deux bords. Vérifier sous le canevas l’ajout, le zoom
  et la navigation, puis lancer Ajouter, Remplir et Remplacer et les annuler.
  Tourner enfin l’iPad en paysage et refaire les contrôles de visibilité.
- Résultat attendu : en portrait, le rail Photos/Fonds et l’inspecteur ouvert
  sont entièrement visibles ; les trois colonnes de miniatures sont carrées,
  égales et non coupées. La barre du canevas choisit une variante qui tient,
  si nécessaire deux rangées avec l’icône Ajouter et le zoom au-dessus de la
  navigation ; aucune commande n’est coupée et toutes gardent leur hauteur
  normale. En paysage, le groupe tient sur une rangée et les trois colonnes
  restent entières. L’icône d’ajout est annoncée « Ajouter une photo » et ouvre
  le mode de choix. Noms, badges et trois bandeaux restent entièrement contenus.
- Résultat : 🟢 `RÉUSSI` — toutes les attentes de la fiche sont confirmées.
- Preuve : retour utilisateur explicite « tout est ok maintenant » en réponse
  au correctif ciblé ; aucune capture supplémentaire n’a été jointe.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  16 août 2026 ; Paris, France ; français (France).

## Première campagne du Lot 2 — modèles, dé et Auto

Ces fiches visent exactement le candidat
`d427d4e747dd2de56235341bd661d537a9a31c8e`. Elles forment une campagne
interne autorisée par `LOT-003` et ne constituent pas la sortie complète du
Lot 2. Les variantes avec texte, Remplir l’album, stickers et cadres restent
explicitement hors de ce candidat.

### `IPAD-L2-001` — Compilation, store Lot 1 et nouvelle interface

- Candidat : `d427d4e747dd2de56235341bd661d537a9a31c8e`.
- Spécification : 3.0, `3:TPL`, `3:RND`, `3:AUT` et `3:DAT-042` inchangés.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:LOT-003`, `3:DAT-042`,
  `3:DONE-005`.
- Préconditions : conserver une copie du package et du store validés sous
  `IPAD-L1-143…144`, puis transférer exactement le candidat ci-dessus sans
  modifier son `Package.swift` généré.
- Étapes : effacer les anciens diagnostics, compiler et lancer ; ouvrir un
  album Lot 1 existant contenant plusieurs pages, photos, cadrages et fonds ;
  parcourir Bibliothèque, éditeur et Vue globale puis revenir à la page active.
- Résultat attendu : aucune erreur ni avertissement bloquant ; les données Lot
  1 restent lisibles et inchangées ; le rail ou la barre expose désormais
  Photos, Mise en page et Fonds dans cet ordre ; aucune commande Lot 3
  n’apparaît.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur explicite « `IPAD-L2-001 : ok` » ; aucune
  capture ni journal de compilation joint à ce retour.
- Environnement : 17 août 2026 ; candidat exact ci-dessus. Appareil, iPadOS,
  Swift Playgrounds, lieu, langue et région repris de l’environnement déclaré
  en tête de campagne et non redéclarés dans ce retour.

### `IPAD-L2-002` — Panneau Mise en page adaptatif et catalogue

- Candidat : `d427d4e747dd2de56235341bd661d537a9a31c8e`.
- Exigences : `3:EDT-001`, `3:EDT-002`, `3:EDT-006`, `3:TPL-001` à
  `3:TPL-003`, `3:TPL-019`, `3:TPL-020`, `3:ACC-021`.
- Préconditions : page active quelconque ; commencer en portrait avec le
  panneau Photos ouvert et un élément sélectionné.
- Étapes : ouvrir Mise en page et vérifier que la sélection du canevas reste
  inchangée ; parcourir `1`, `2`, …, `7+` sous Sans texte puis Avec texte ;
  vérifier deux miniatures distinctes par nombre exact de 1 à 8 photos pour
  chaque filtre ; constater que les variantes Avec texte sont visibles mais
  désactivées avec leur explication ; faire défiler jusqu’aux bords ; tourner
  en paysage et recommencer l’ouverture/fermeture de Photos, Mise en page et
  Fonds ; ouvrir l’aide du panneau hors ligne.
- Résultat attendu : aucun rail, panneau, filtre, miniature ni commande du
  canevas n’est coupé ; les miniatures 4:5 reflètent leurs slots et ne sont pas
  des duplicatas trompeurs ; l’ordre des trois panneaux reste stable ; Avec
  texte annonce clairement son report ; l’aide explique modèle, dé et Auto
  sans réseau.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : malgré le retour synthétique « `IPAD-L2-002 : ok` », l’observation
  globale précise qu’en portrait les panneaux de menu à gauche et l’inspecteur
  à droite restent légèrement rognés, quoique lisibles. Cet écart contredit
  directement l’attente « aucun rail ni panneau coupé » ; aucune capture
  jointe.
- Environnement : même environnement déclaré que `IPAD-L2-001` ; non
  redéclaré dans ce retour.

### `IPAD-L2-003` — Modèle plus grand, conservation et commande unique

- Candidat : `d427d4e747dd2de56235341bd661d537a9a31c8e`.
- Exigences : `3:TPL-004` à `3:TPL-006`, `3:TPL-009`, `3:TPL-010`,
  `3:TPL-014` à `3:TPL-017`, `3:DAT-042`.
- Préconditions : page libre avec exactement deux cadres remplis par deux
  photos reconnaissables, cadrages différents, un fond non par défaut et un
  ordre de profondeur connu.
- Étapes : dans Sans texte > `4`, appliquer Grille A ; inspecter les quatre
  emplacements ; noter les deux cadres vides ; vérifier les deux contenus et
  leurs cadrages internes ; toucher Annuler une fois puis Rétablir une fois ;
  fermer l’album, le rouvrir et revenir à la page.
- Résultat attendu : deux cadres existants sont réaffectés de façon stable et
  deux cadres vides sont créés au-dessus, sans changer le fond ni les cadrages ;
  Annuler restaure exactement les deux cadres initiaux en une action ; Rétablir
  restaure les quatre ; après relance, Grille A reste sélectionnée et les
  géométries ne sont pas recalculées aléatoirement.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur explicite « `IPAD-L2-003 : ok` » ; aucune
  capture jointe.
- Environnement : même environnement déclaré que `IPAD-L2-001` ; non
  redéclaré dans ce retour.

### `IPAD-L2-004` — Modèle plus petit et confirmation exacte

- Candidat : `d427d4e747dd2de56235341bd661d537a9a31c8e`.
- Exigences : `3:TPL-005` à `3:TPL-010`, `3:TPL-016`, `3:ERR-022`.
- Préconditions : nouvelle page libre avec exactement quatre cadres remplis ;
  relever leur ordre et vérifier les quatre photos dans le panneau Photos.
- Étapes : choisir Sans texte > `2` puis Grille A ; vérifier le nombre annoncé
  et toucher Annuler ; confirmer que rien n’a changé ; recommencer et toucher
  Appliquer ; vérifier les survivants ; toucher Annuler dans la barre
  principale.
- Résultat attendu : le premier dialogue annonce exactement deux occurrences
  retirées ; son Annuler ne publie aucune modification ; Appliquer conserve les
  deux premières occurrences selon l’ordre accessible, retire les deux autres
  cadres sans supprimer leurs assets de Photos et désactive Auto s’il était
  actif ; un seul Annuler restaure les quatre cadres avec leurs cadrages.
- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : le dialogue s’affiche, mais toucher **Appliquer** ne produit aucun
  changement observable. Le retrait des deux occurrences, la commande unique
  et sa restauration ne peuvent donc pas être validés ; aucune capture jointe.
- Environnement : même environnement déclaré que `IPAD-L2-001` ; non
  redéclaré dans ce retour.

### `IPAD-L2-005` — Dé compatible, cycle et persistance

- Candidat : `d427d4e747dd2de56235341bd661d537a9a31c8e`.
- Exigences : `3:RND-001` à `3:RND-006`, `3:TPL-018`, `3:DAT-042`.
- Préconditions : page libre contenant exactement quatre cadres photo et
  aucune zone de texte ; mémoriser l’ordre et les cadrages des quatre contenus.
- Étapes : vérifier que le bouton dé est actif et annoncé « Changer
  aléatoirement la mise en page » ; le toucher trois fois en notant le modèle
  sélectionné après chaque pression ; vérifier les éléments après chaque
  tirage ; toucher Annuler puis Rétablir ; fermer et rouvrir l’album.
- Résultat attendu : seuls les deux modèles Sans texte à quatre photos sont
  choisis ; aucun tirage ne répète immédiatement le modèle courant et l’autre
  variante est visitée avant répétition ; nombre, ordre des contenus, cadrages,
  fond et assets ne changent pas ; chaque pression est une commande ; le
  dernier résultat, et non un nouveau tirage, persiste après relance.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur explicite « `IPAD-L2-005 : ok` ». Observation
  hors verdict fonctionnel : l’icône actuelle est jugée peu compréhensible ;
  une icône de dé montrant plusieurs faces et un déplacement dans le panneau
  Mise en page avec libellé clair sont demandés. Aucune séquence écrite des
  modèles ni capture jointe.
- Environnement : même environnement déclaré que `IPAD-L2-001` ; non
  redéclaré dans ce retour.

### `IPAD-L2-006` — Auto, occurrences photo et sortie vers le mode libre

- Candidat : `d427d4e747dd2de56235341bd661d537a9a31c8e`.
- Exigences : `3:AUT-001` à `3:AUT-008`, `3:AUT-012` à `3:AUT-019`,
  `3:PHO-014`, `3:FRM-003`, `3:TPL-022`.
- Préconditions : nouvelle page sans cadre et au moins trois photos dans
  Photos.
- Étapes : activer Mise en page auto et vérifier l’absence de confirmation sur
  la page vide ; placer une photo, la dupliquer puis placer une deuxième photo ;
  vérifier la recomposition après chaque action ; retirer la photo d’un cadre ;
  vérifier que son cadre disparaît ; sélectionner un cadre restant et le
  déplacer manuellement ; dans l’avertissement de désactivation, toucher
  Annuler.
- Résultat attendu : Auto est visible et persistant ; chaque ajout produit un
  cadre rempli, sans cadre vide ; Dupliquer et Retirer recomposent dans la même
  action sans changer les cadrages survivants ; Retirer supprime le cadre en
  Auto ; le déplacement désactive Auto et affiche « Mise en page auto
  désactivée pour cette page » ; son action Annuler restaure à la fois Auto et
  la géométrie précédente.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur explicite « `IPAD-L2-006 : ok` » ; aucune vidéo
  ni capture jointe.
- Environnement : même environnement déclaré que `IPAD-L2-001` ; non
  redéclaré dans ce retour.

### `IPAD-L2-007` — Densité, portée par page et relance

- Candidat : `d427d4e747dd2de56235341bd661d537a9a31c8e`.
- Exigences : `3:AUT-001`, `3:AUT-003` à `3:AUT-005`, `3:AUT-012`,
  `3:AUT-015` à `3:AUT-018`, `3:DAT-037`.
- Préconditions : deux pages ; la première contient quatre cadres remplis et
  la seconde est vide.
- Étapes : sur la première page, activer Auto, vérifier l’avertissement puis
  Annuler ; vérifier l’absence de changement ; activer à nouveau et confirmer ;
  choisir successivement Aérée, Dense puis Équilibrée en observant la
  composition ; désactiver Auto ; passer à la seconde page et vérifier son état,
  puis activer Auto sans confirmation ; fermer et relancer.
- Résultat attendu : l’annulation initiale ne change rien ; chaque densité
  produit une composition déterministe et une commande annulable ; désactiver
  Auto conserve exactement la dernière géométrie ; les états Auto et densité
  sont indépendants par page et persistent ; la page vide reste sans cadre.
- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur explicite « `IPAD-L2-007 : ok` » ; aucune
  capture jointe.
- Environnement : même environnement déclaré que `IPAD-L2-001` ; non
  redéclaré dans ce retour.

### `IPAD-L2-008` — Commandes incompatibles et frontière de l’incrément

- Candidat : `d427d4e747dd2de56235341bd661d537a9a31c8e`.
- Exigences : `3:AUT-019`, `3:EDT-003`, `3:EDT-004`, `3:EDT-019`,
  `3:ARC-014`, `3:CAT-009`.
- Préconditions : page possédant un cadre vide ; le copier, puis activer Auto
  et confirmer afin que ce cadre vide soit retiré.
- Étapes : vérifier dans Photos que Ajouter un cadre vide est désactivé ;
  vérifier que Coller est désactivé pour le cadre vide copié ; sur une autre
  page Auto contenant un cadre rempli, vérifier que Dupliquer reste actif ;
  contrôler l’interrupteur Auto et le menu Plus en portrait puis paysage ;
  ouvrir l’aide ; rechercher enfin les commandes Texte éditable, Remplir
  l’album, Stickers et Cadres et formes.
- Résultat attendu : les deux créations de cadre vide sont désactivées avec une
  explication, tandis qu’un cadre rempli peut être dupliqué et recomposé ; Auto
  reste visible hors du menu Plus et toutes les commandes existantes restent
  contenues ; l’aide est locale ; les fonctions Lot 2 non livrées ne sont pas
  actives et aucun asset sticker/cadre n’est persisté.
- Résultat : 🟠 `BLOQUÉ`.
- Preuve : les parties accessibles sont déclarées bonnes, mais le menu Plus
  n’a pas été contrôlé : Swift Playgrounds sur cet iPad ne permet pas de
  réduire suffisamment la fenêtre pour obtenir la largeur compacte. Le retour
  « ok mais menu Plus inaccessible » ne prouve donc pas toute la fiche ; aucune
  capture jointe.
- Environnement : même environnement déclaré que `IPAD-L2-001` ; limitation
  Swift Playgrounds signalée par l’utilisateur.

## Régression du correctif des retours Lot 2

Ces quatre fiches visent exactement le candidat
`024a60bcd7b7a837497a5d6a00e8e42cacfd9366`. Elles remplacent les preuves
devenues insuffisantes pour les surfaces corrigées, sans modifier les verdicts
historiques `IPAD-L2-002`, `004`, `005` et `008`.

### `IPAD-L2-009` — Compilation du correctif et compatibilité du store Lot 1

- Candidat : `024a60bcd7b7a837497a5d6a00e8e42cacfd9366`.
- Spécification : 3.0, avec `EDT-002`, `ELM-014` et `RND-001` inclus dans le
  candidat exact ci-dessus.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:LOT-003`, `3:DAT-042`,
  `3:DONE-005`.
- Préconditions : conserver une copie du package et du store utilisés pour
  `IPAD-L2-001…008`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Transférer exactement le candidat indiqué dans la fiche. | Le package reçu correspond au candidat ; le `Package.swift` généré n’est ni recréé ni modifié. |
| 2 | Effacer les anciens diagnostics, puis compiler et lancer l’application. | La compilation et le lancement se terminent sans erreur ni avertissement bloquant. |
| 3 | Ouvrir l’album Lot 2 déjà utilisé pour `IPAD-L2-001…008`. | Les albums, pages, photos, cadrages, fonds, modèles et états Auto existants sont lisibles et inchangés. |
| 4 | Parcourir Bibliothèque, Vue globale et éditeur, puis revenir à la page active. | La navigation aboutit à la même page active ; Photos, Mise en page et Fonds restent accessibles. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur global explicite « tous les tests sont ok »,
  reçu après la remise de `IPAD-L2-009…012`. Cette preuve valide uniquement
  ces quatre fiches iPad ; aucune capture ni observation par étape n’a été
  jointe et aucun contrôle `APPLE-*` n’est extrapolé.
- Environnement : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  portrait initial ; informations reprises de l’environnement de campagne en
  tête du registre et non redéclarées dans ce retour global.

### `IPAD-L2-010` — Marges portrait, panneau droit et replis indépendants

- Candidat : `024a60bcd7b7a837497a5d6a00e8e42cacfd9366`.
- Exigences : `3:EDT-002`, `3:EDT-006`, `3:EDT-021`, `3:ACC-006`,
  `3:ACC-021`.
- Préconditions : `IPAD-L2-009` réussi ; page contenant au moins une photo
  sélectionnée ; commencer en portrait avec Photos ouvert.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | En portrait, examiner le bord gauche du rail et le bord droit du panneau. | Le rail et le panneau droit disposent d’une marge visible ; aucun bord, titre, contenu ou bouton n’est rogné. |
| 2 | Ouvrir successivement Photos, Mise en page et Fonds. | Chaque panneau s’ouvre sans perdre la photo sélectionnée et son contenu reste entièrement lisible. |
| 3 | Replier uniquement « Inspecteur de l’élément ». | Seul son contenu disparaît ; son titre et le panneau actif restent visibles, et le contenu inférieur gagne de la place. |
| 4 | Redévelopper l’inspecteur, puis replier uniquement la section du panneau actif. | Seul le contenu de la section active disparaît ; son titre et l’inspecteur restent visibles. |
| 5 | Vérifier successivement les quatre combinaisons développé/replié des deux sections. | Chaque section se replie indépendamment sans agir sur l’autre ; les deux titres restent toujours accessibles. |
| 6 | Utiliser « Masquer le panneau droit ». | Le panneau droit entier est masqué ; la sélection et le panneau actif sont conservés. |
| 7 | Utiliser « Panneau » dans le rail pour restaurer le panneau droit. | Le panneau droit réapparaît avec la même sélection et le même panneau actif. |
| 8 | Tourner l’iPad en paysage et répéter l’ouverture et le repli des deux sections. | Aucun bord, titre, contenu ou bouton n’est rogné en paysage ; les replis restent indépendants. |
| 9 | Activer Réduire les animations, puis effectuer un nouveau cycle de repli et de développement. | Le changement d’état reste immédiat et aucune animation forcée n’apparaît. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur global explicite « tous les tests sont ok »,
  attribué à la campagne active `IPAD-L2-009…012` ; aucune capture ni
  observation par étape jointe et aucune qualification Apple extrapolée.
- Environnement : identique à `IPAD-L2-009`, repris de l’en-tête de campagne
  et non redéclaré dans le retour global.

### `IPAD-L2-011` — Confirmation Appliquer pour un modèle plus petit

- Candidat : `024a60bcd7b7a837497a5d6a00e8e42cacfd9366`.
- Exigences : `3:TPL-005` à `3:TPL-010`, `3:TPL-016`, `3:ERR-022`.
- Préconditions : `IPAD-L2-009` réussi ; nouvelle page libre contenant
  exactement quatre cadres remplis par des photos reconnaissables ; relever
  leur ordre et leurs cadrages, puis vérifier les quatre assets dans Photos.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Dans Mise en page, choisir Sans texte > `2`, puis Grille A. | Un dialogue s’affiche avant toute modification et annonce exactement deux occurrences photo retirées. |
| 2 | Dans ce premier dialogue, toucher Annuler. | La page conserve ses quatre cadres, leur ordre et leurs cadrages sans changement visible. |
| 3 | Choisir de nouveau Sans texte > `2`, puis Grille A, et toucher Appliquer. | L’application du modèle produit immédiatement une page à deux cadres. |
| 4 | Examiner les deux cadres survivants et le panneau Photos. | Les deux premières occurrences selon l’ordre accessible sont conservées avec leurs cadrages ; les deux autres cadres sont retirés, mais les quatre assets restent disponibles dans Photos. |
| 5 | Si Auto était actif avant l’application, contrôler son état après Appliquer. | Auto est désactivé dans la même commande et aucun état intermédiaire incohérent n’est visible. |
| 6 | Toucher une seule fois Annuler dans la barre principale. | Les quatre cadres, leur ordre et leurs cadrages sont restaurés en une seule action. |
| 7 | Toucher une seule fois Rétablir. | Le modèle à deux cadres est restauré exactement. |
| 8 | Fermer puis rouvrir l’album et revenir à la page. | L’état rétabli à deux cadres persiste après la relance. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur global explicite « tous les tests sont ok »,
  attribué à la campagne active `IPAD-L2-009…012` ; aucune capture ni
  observation par étape jointe et aucune qualification Apple extrapolée.
- Environnement : identique à `IPAD-L2-009`, repris de l’en-tête de campagne
  et non redéclaré dans le retour global.

### `IPAD-L2-012` — Nom long dans la sélection et commande aléatoire explicite

- Candidat : `024a60bcd7b7a837497a5d6a00e8e42cacfd9366`.
- Exigences : `3:ELM-014`, `3:ACC-002`, `3:RND-001` à `3:RND-005`,
  `3:TPL-018`, `3:EDT-020`.
- Préconditions : `IPAD-L2-009` réussi ; page libre contenant quatre cadres
  photo, dont une photo au nom ou à la description nettement supérieur à
  45 caractères ; au moins deux modèles Sans texte compatibles.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ouvrir « Sélectionner un élément » et examiner toutes les lignes. | Chaque ligne conserve son type, sa position et `plan X sur Y`, y compris pour les éléments situés en fin de liste. |
| 2 | Examiner la ligne de la photo dont le nom ou la description dépasse 45 caractères. | Seul le nom ou l’extrait est abrégé avec une ellipse ; la fin contenant la position et `plan X sur Y` reste visible. |
| 3 | Activer VoiceOver et faire annoncer cette même ligne. | VoiceOver annonce le nom ou la description complète, sans troncature, puis la position et « plan X sur Y ». |
| 4 | Ouvrir Mise en page et repérer « Changer aléatoirement la mise en page ». | La commande est visible avec ce libellé complet, une icône de dé explicite et un libellé accessible identique. |
| 5 | Examiner la barre locale d’ajout, de zoom et de navigation du canevas. | La commande de disposition aléatoire n’apparaît plus dans cette barre. |
| 6 | Noter le modèle courant, puis actionner deux fois la commande aléatoire. | Chaque action choisit un autre modèle Sans texte compatible sans répétition immédiate ; nombre, ordre, contenus, cadrages, fond et assets ne changent pas. |
| 7 | Toucher une seule fois Annuler. | Le modèle obtenu par le dernier tirage est annulé en une seule action et la disposition précédente est restaurée. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur global explicite « tous les tests sont ok »,
  attribué à la campagne active `IPAD-L2-009…012` ; aucune capture ni
  observation par étape jointe et aucune qualification Apple extrapolée.
- Environnement : identique à `IPAD-L2-009`, repris de l’en-tête de campagne
  et non redéclaré dans le retour global ; VoiceOver faisait partie de la
  procédure validée.

## Régression de la navigation locale et de la gestion des pages

Cette fiche vise exactement le candidat
`b86c4b323e0b8d2cfe2fc2e0394ff9d5f3e4e0b4`. Elle remplace la preuve
d’adaptation antérieure uniquement pour la barre sous le canevas et le
sélecteur de mode modifiés.

### `IPAD-L2-013` — Ajouter une page et Gérer les pages

- Candidat : `b86c4b323e0b8d2cfe2fc2e0394ff9d5f3e4e0b4`.
- Spécification : 3.0, avec l’arbitrage `EDT-003`, `EDT-008`, `EDT-016`,
  `EDT-020`, `PAG-002`, `PAG-013`, `PHO-011` inclus dans le candidat exact.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:EDT-003`, `3:EDT-008`,
  `3:EDT-012`, `3:EDT-016`, `3:EDT-020`, `3:PAG-002`, `3:PAG-013` à
  `3:PAG-015`, `3:PHO-004`, `3:PHO-011`, `3:ACC-002`, `3:ACC-021`,
  `3:DONE-005`.
- Préconditions : transférer exactement le candidat ; conserver le store validé
  par `IPAD-L2-009…012` ; ouvrir en portrait un album contenant au moins deux
  pages et une photo disponible dans Photos ; activer la première page et
  relever son contenu, son fond et le compteur `Page 1 sur N`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler, lancer le candidat et ouvrir l’album préparé. | La compilation et le lancement réussissent ; les albums, pages, photos, fonds, modèles et états Auto existants sont lisibles et inchangés. |
| 2 | Dans Créer, examiner en portrait toute la barre située sous le canevas. | Ajouter une page apparaît avant le zoom et la navigation avec l’icône de pile et un libellé entier ou sa variante adaptative ; l’ancien bouton Ajouter une photo est absent de cette barre ; zoom, `Page 1 sur N`, Précédent et Suivant restent entiers. |
| 3 | Sans cadre sélectionné, ouvrir Photos et presser une miniature disponible, puis annuler cette création. | La photo crée toujours un nouveau cadre par le panneau Photos ; une seule action Annuler restaure la page initiale. Le retrait du raccourci sous le canevas n’a pas supprimé l’ajout de photo. |
| 4 | Revenir à la première page, vérifier le compteur, puis presser une fois Ajouter une page dans la barre sous le canevas. | Une seule page vide est insérée immédiatement après la première et devient active ; le compteur passe à `Page 2 sur N+1`, le fond est celui par défaut, aucun élément ni état Auto n’est copié et l’état atteint Enregistré. |
| 5 | Presser une fois Annuler, puis une fois Rétablir. | Annuler retire la nouvelle page et restaure la première page active avec le compteur initial ; Rétablir recrée exactement la page vide, la rend active et restaure le compteur augmenté. |
| 6 | Dans le sélecteur de mode, choisir Gérer les pages, examiner la grille et ouvrir l’aide de cette vue. | Le sélecteur affiche Créer, Gérer les pages et Prévisualiser dans cet ordre, sans ancien libellé Organiser ; la grille montre la nouvelle page active au bon indice et l’aide s’intitule Gérer les pages. |
| 7 | Revenir dans Créer, tourner l’iPad en paysage, puis répéter l’examen de la barre et du sélecteur. | Aucun bouton, libellé, compteur, rail ni panneau n’est rogné ; l’ordre des commandes et la page active sont conservés. |
| 8 | Activer VoiceOver et parcourir Ajouter une page puis les trois modes du sélecteur. | VoiceOver annonce « Ajouter une page » avec l’indication qu’une page vide sera créée après l’actuelle, puis « Créer — Vue page », « Gérer les pages — Vue globale » et « Prévisualiser » sans ambiguïté. |
| 9 | Fermer puis rouvrir l’album et revenir à la page créée. | La page ajoutée, son ordre, son état vide et son fond par défaut persistent ; aucun cadre photo supplémentaire n’a été créé par l’action rapide. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour utilisateur global explicite « tests ok » reçu après la
  remise de cette seule fiche active. Aucune capture ni observation par étape
  n’a été jointe. La preuve reste limitée au candidat et au comportement alors
  spécifié ; la demande suivante d’ajouter en fin d’album avec confirmation
  rend nécessaire un nouvel identifiant de régression.
- Environnement : repris de la fiche de campagne, sans nouvelle déclaration
  dans le retour : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ;
  portrait initial puis paysage ; VoiceOver prévu à l’étape 8 ; Paris, France ;
  français (France). Aucun contrôle `APPLE-*` n’est extrapolé.

## Régression de l’ajout de page en fin d’album

Cette fiche vise exactement le candidat
`02430b16f2853c01dbcafc88d48cd40c48373c4c`. Elle remplace la preuve de
`IPAD-L2-013` uniquement pour le parcours Ajouter une page modifié ; la barre
et le libellé Gérer les pages déjà validés restent historiquement attribués à
leur candidat.

### `IPAD-L2-014` — Ajout en fin, confirmation et réglage temporaire

- Candidat : `02430b16f2853c01dbcafc88d48cd40c48373c4c`.
- Spécification : 3.0 incluse dans le candidat exact, avec `PAG-002`,
  `PAG-014` et `PAG-017` modifiés le 17 août 2026.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:EDT-008`, `3:EDT-012`,
  `3:EDT-016`, `3:PAG-002`, `3:PAG-013` à `3:PAG-017`, `3:UND-001`,
  `3:UND-002`, `3:SAV-001`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` et
  `3:DONE-005`.
- Préconditions : transférer exactement le candidat ; conserver le store
  validé ; ouvrir en portrait un album modifiable d’au moins trois pages ;
  relever leur ordre et leur contenu ; activer une page qui n’est ni la
  première ni la dernière et relever le compteur `Page N sur M`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler, lancer le candidat et ouvrir l’album préparé. | La compilation et le lancement réussissent ; l’album, ses pages, leur ordre et leur contenu existants sont lisibles et inchangés. |
| 2 | Depuis la page intermédiaire, presser Ajouter une page sous le canevas, sans encore agir dans la fenêtre. | Une fenêtre « Ajouter une page ? » apparaît avant toute mutation ; elle annonce l’ajout en fin et propose Annuler, Ajouter la page et la case « Ne plus demander », initialement non cochée ; le compteur et l’ordre restent inchangés. |
| 3 | Presser Annuler, puis examiner le compteur et Gérer les pages. | La fenêtre se ferme ; aucune page n’est créée, la page active et l’ordre restent identiques, et le réglage « Ne plus demander avant d’ajouter une page » reste désactivé. |
| 4 | Revenir à la page intermédiaire, rouvrir Ajouter une page, cocher « Ne plus demander », puis presser Ajouter la page. | Une seule page vide est ajoutée après l’ancienne dernière page, jamais après la page intermédiaire ; elle devient active, le compteur passe à `Page M+1 sur M+1`, elle utilise le fond par défaut, ne copie aucun élément ni état Auto et l’état atteint Enregistré. |
| 5 | Revenir sur la première page et presser Ajouter une page sous le canevas. | Aucune confirmation ne réapparaît ; exactement une seconde page vide est ajoutée au nouveau dernier rang et devient active. |
| 6 | Ouvrir Gérer les pages, vérifier le réglage, le désactiver, puis presser son bouton Ajouter une page. | Le réglage apparaît activé puis accepte la désactivation ; le bouton de cette page ouvre la même fenêtre de confirmation et ne modifie pas encore l’album. |
| 7 | Dans cette fenêtre, laisser « Ne plus demander » décoché et confirmer l’ajout. | Une seule nouvelle page vide est ajoutée au dernier rang et devient la page active dans la grille ; le réglage reste désactivé et un ajout ultérieur redemanderait confirmation. |
| 8 | Presser Annuler une fois, puis Rétablir une fois. | Annuler retire uniquement la dernière page ajoutée ; Rétablir la recrée une seule fois au dernier rang, la rend active et conserve l’ordre de toutes les autres pages. |
| 9 | Dans Gérer les pages, activer de nouveau « Ne plus demander », fermer complètement l’album, le rouvrir et revenir dans Gérer les pages. | Les pages ajoutées et leur ordre persistent, mais le réglage est revenu désactivé : il n’a pas été enregistré dans l’album. |
| 10 | Revenir sur une page non terminale, presser Ajouter une page, puis annuler la fenêtre. | La confirmation réapparaît après la réouverture ; Annuler ne crée aucune page et ne change pas le réglage, ce qui confirme la remise à zéro de session. |
| 11 | Tourner l’iPad en paysage puis revenir en portrait, en examinant la fenêtre et la zone supérieure de Gérer les pages. | Le titre, le texte, la case, les deux actions, le réglage et le bouton restent entièrement visibles, lisibles et utilisables dans les deux orientations ; aucune grille ni commande n’est rognée. |
| 12 | Activer VoiceOver et parcourir Ajouter une page, la fenêtre, sa case, Annuler, Ajouter la page et le réglage de Gérer les pages. | Chaque commande possède un libellé et un état non ambigus ; la case annonce cochée ou non cochée, l’effet d’ajout en fin est compréhensible et la remise à zéro à la fermeture est annoncée pour le réglage. |

- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : retour utilisateur explicite « tout est ok sauf la taille de la
  popup » : elle est jugée trop large, pas assez haute et oblige à faire
  défiler uniquement pour lire la fin de « Ce choix reste modifiable… ». Cette
  observation contredit l’étape 11 ; les autres comportements sont déclarés
  corrects globalement, sans capture ni détail par étape.
- Environnement : repris de la fiche, sans nouvelle déclaration dans le
  retour : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; Paris,
  France ; français (France). Aucun résultat iPhone, Xcode ou `APPLE-*` n’est
  extrapolé.

## Régression ciblée de la fenêtre d’ajout

### `IPAD-L2-015` — Taille intrinsèque et lisibilité de la confirmation

- Candidat : `8aa7f566de775c15ddf5a9e702a01ed5e9fdb640`.
- Spécification : 3.0 incluse dans le candidat exact ; `PAG-017` précise le
  dimensionnement au contenu et l’absence de défilement à la taille standard.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:PAG-017`, `3:ACC-002`,
  `3:ACC-006`, `3:ACC-021` et `3:DONE-005`.
- Préconditions : transférer exactement le candidat ; ouvrir en portrait un
  album modifiable ; vérifier que « Ne plus demander avant d’ajouter une page »
  est désactivé dans Gérer les pages ; utiliser la taille de texte standard.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler, lancer le candidat et ouvrir l’album préparé. | La compilation et le lancement réussissent ; l’album et ses pages précédemment validés sont lisibles et inchangés. |
| 2 | En portrait, depuis Créer, presser Ajouter une page sans agir ensuite dans la fenêtre. | La fenêtre est visiblement ajustée à son contenu et ne conserve pas une grande largeur vide ; son titre, le texte principal, « Ne plus demander », le texte complet commençant par « Ce choix reste modifiable… », Annuler et Ajouter la page sont tous visibles sans défilement. |
| 3 | Cocher puis décocher « Ne plus demander », presser Annuler et contrôler le nombre de pages. | La case change d’état sans modifier la taille ni masquer un texte ; Annuler ferme la fenêtre et ne crée aucune page. |
| 4 | Ouvrir Gérer les pages, presser son bouton Ajouter une page et examiner la fenêtre. | Le même dialogue ajusté apparaît ; sa largeur, sa hauteur et l’absence de défilement sont identiques au dialogue ouvert depuis Créer. |
| 5 | Fermer la fenêtre, tourner l’iPad en paysage, revenir dans Créer et la rouvrir. | La fenêtre reste compacte, centrée et entièrement lisible sans défilement ; aucun texte ni bouton n’est rogné dans cette orientation. |
| 6 | Revenir en portrait, activer VoiceOver et parcourir le texte, la case et les deux actions. | L’ordre de lecture est cohérent ; la case annonce son état et tous les textes et actions restent accessibles sans zone vide ou contenu masqué. |

- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : retour utilisateur explicite « ko, la popup est devenue toute petite
  et illisible ». L’étape 2 échoue immédiatement ; les étapes suivantes ne sont
  pas considérées comme exécutées et aucune capture n’est jointe.
- Environnement : repris de la fiche, sans nouvelle déclaration dans le
  retour : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; taille
  de texte standard ; Paris, France ; français (France). Aucun résultat iPhone,
  Xcode ou `APPLE-*` n’est extrapolé.

## Seconde régression ciblée de la fenêtre d’ajout

### `IPAD-L2-016` — Cadre lisible de la confirmation

- Candidat : `7d8772c6d87a769a239b4f9eafabe74c8c126681`.
- Spécification : 3.0 incluse dans le candidat exact ; `PAG-017` fixe le cadre
  régulier à 400 × 340 points et conserve la présentation native en compact.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:PAG-017`, `3:ACC-002`,
  `3:ACC-006`, `3:ACC-021` et `3:DONE-005`.
- Préconditions : transférer exactement le candidat ; ouvrir en portrait un
  album modifiable ; désactiver « Ne plus demander avant d’ajouter une page » ;
  utiliser la taille de texte standard.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler, lancer le candidat et ouvrir l’album préparé. | La compilation et le lancement réussissent ; l’album et ses pages restent inchangés. |
| 2 | En portrait dans Créer, presser Ajouter une page sans agir ensuite dans la fenêtre. | La fenêtre possède une taille moyenne lisible : elle n’est ni la grande fenêtre vide de `014`, ni la fenêtre minuscule de `015`. Le titre, les deux textes, la case et les actions sont entièrement visibles sans défilement. |
| 3 | Cocher puis décocher « Ne plus demander », presser Annuler et contrôler le nombre de pages. | La case et ses deux états sont lisibles ; Annuler ferme la fenêtre sans créer de page. |
| 4 | Ouvrir Gérer les pages et presser son bouton Ajouter une page. | La même fenêtre de 400 × 340 points apparaît, avec tous les contenus visibles et utilisables. |
| 5 | Fermer la fenêtre, tourner l’iPad en paysage, revenir dans Créer et la rouvrir. | La taille reste identique, centrée et lisible ; aucun texte ni bouton n’est rogné et aucun défilement n’est nécessaire. |
| 6 | Revenir en portrait, activer VoiceOver et parcourir le texte, la case et les deux actions. | L’ordre de lecture est cohérent, la case annonce son état et chaque action est accessible sans contenu masqué. |

- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : retour utilisateur explicite « le bouton fait figer l’app sans popup
  affichée ». L’étape 2 échoue immédiatement ; les étapes 3 à 6 ne sont pas
  considérées comme exécutées et aucune capture n’est jointe.
- Environnement : repris de la fiche, sans nouvelle déclaration dans le
  retour : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; taille
  de texte standard ; portrait ; Paris, France ; français (France). Aucun
  résultat iPhone, Xcode ou `APPLE-*` n’est extrapolé.

## Troisième régression ciblée de la confirmation d’ajout

### `IPAD-L2-017` — Dialogue interne sans gel

- Candidat : `57afa71e3eeac8b48f05e0aaa719cf77e8a97834`.
- Spécification : 3.0 incluse dans le candidat exact ; `PAG-017` impose un
  dialogue centré, borné à 400 points, avec 16 points de marge latérale et un
  éditeur assombri non interactif.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:PAG-017`, `3:ACC-002`,
  `3:ACC-006`, `3:ACC-021` et `3:DONE-005`.
- Préconditions : transférer exactement le candidat ; ouvrir en portrait un
  album modifiable contenant au moins deux pages ; désactiver « Ne plus
  demander avant d’ajouter une page » dans Gérer les pages ; utiliser la taille
  de texte standard.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler, lancer le candidat et ouvrir l’album préparé. | La compilation et le lancement réussissent ; l’album reste lisible et l’app répond normalement. |
| 2 | En portrait dans Créer, presser Ajouter une page et attendre l’affichage sans toucher une autre commande. | L’app ne se fige pas : un dialogue centré apparaît immédiatement sur l’éditeur assombri. Sa largeur ne dépasse pas 400 points, ses marges latérales atteignent au moins 16 points et le titre, les deux textes, la case, Annuler et Ajouter la page sont entièrement visibles sans défilement. |
| 3 | Pendant que le dialogue est ouvert, tenter d’utiliser une commande de l’éditeur derrière lui, puis cocher et décocher « Ne plus demander » et presser Annuler. | Aucune commande située derrière le dialogue ne réagit ; la case réagit à chaque pression, Annuler ferme le dialogue, l’app reste fluide et aucune page n’est créée. |
| 4 | Ouvrir Gérer les pages, presser son bouton Ajouter une page, puis presser Ajouter la page dans le dialogue. | Le même dialogue apparaît sans gel ; la confirmation ajoute exactement une page au dernier rang, la rend active, ferme le dialogue et laisse l’app utilisable. |
| 5 | Revenir en portrait si nécessaire, rouvrir le dialogue, le fermer, tourner l’iPad en paysage et répéter son ouverture. | Dans les deux orientations, le dialogue reste centré, ses marges et tous ses contenus restent visibles sans défilement, et chaque ouverture et fermeture laisse l’app réactive. |
| 6 | En portrait, activer VoiceOver, rouvrir le dialogue et parcourir son titre, ses textes, la case et ses deux actions. | VoiceOver traite le dialogue comme modal, suit un ordre cohérent, annonce l’état de la case et n’atteint pas les commandes de l’éditeur placé derrière. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « c’est ok » reçu après remise de cette seule fiche.
  Les six étapes sont déclarées conformes globalement ; aucune capture ni
  observation distincte par étape n’a été jointe.
- Environnement : repris de la fiche, sans nouvelle déclaration dans le
  retour : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; taille
  de texte standard ; portrait initial, paysage à l’étape 5 ; VoiceOver à
  l’étape 6 ; Paris, France ; français (France). Aucun résultat iPhone, Xcode
  ou `APPLE-*` n’est extrapolé.

## Campagne Remplir l’album

### `IPAD-L2-018` — Trois densités et commande unique

- Candidat : `781539603d6b98523fe48326ee49e24288dfa09b`.
- Spécification : 3.0 incluse dans le candidat exact.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:AUT-009` à `3:AUT-012`,
  `3:FRM-009`, `3:TPL-005`, `3:UND-001`, `3:SAV-001`, `3:ACC-002`,
  `3:ACC-006`, `3:ACC-021` et `3:DONE-005`.
- Préconditions : transférer exactement le candidat ; créer un album jetable
  « Test Remplir » de deux pages ; importer onze images nettement
  reconnaissables nommées visuellement `U`, puis `A…J`, dont les dates de prise
  de vue de `A…J` sont strictement croissantes ; placer seulement `U` dans la
  page 1 ; laisser la page 2 sans photo utilisée, avec exactement deux cadres
  photo vides et un fond noir ; vérifier qu’il n’existe aucune autre page et
  que `A…J` sont les dix seules photos inutilisées.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler, lancer le candidat et ouvrir « Test Remplir » en portrait. | La compilation et le lancement réussissent ; l’album préparé contient deux pages, onze assets et dix photos inutilisées sans altération du store existant. |
| 2 | Ouvrir Photos et examiner le groupe Remplir l’album avant toute action. | Le groupe affiche l’icône baguette `wand.and.stars`, les choix Aérée (1–2), Équilibrée (3–4) et Dense (5–8), le compteur « 10 photos inutilisées » et un bouton actif ; Équilibrée est sélectionnée par défaut. |
| 3 | Avec Équilibrée, presser Remplir l’album, lire toute la confirmation, puis presser Annuler. | La confirmation annonce exactement 10 photos, 2 cadres vides retirés, 1 page existante réutilisée et 2 pages créées, et précise que les photos importées sont conservées ; Annuler ferme l’alerte sans changer pages, cadres, fond, occurrences ni compteur. |
| 4 | Rouvrir la même confirmation et presser Remplir. Examiner successivement les quatre pages produites. | L’opération termine sans gel : la page 1 et `U` restent inchangés ; la page 2 conserve son fond noir, perd ses deux cadres vides et reçoit `A…D` ; deux pages sont ajoutées après la dernière avec `E…H`, puis `I…J`. Elles ne contiennent aucun cadre photo vide, utilisent Équilibrée et Auto, et chaque photo commence à `1×`, centrée et non tournée. |
| 5 | Revenir dans Photos après le remplissage et contrôler les miniatures/assets. | Le compteur indique « Aucune photo inutilisée », Remplir l’album est désactivé, et les onze photos importées sont toujours présentes ; aucun asset n’a été supprimé. |
| 6 | Presser Annuler une seule fois, contrôler l’album, puis presser Rétablir une seule fois. | Un seul Annuler restaure exactement les deux pages initiales, les deux cadres vides, le fond noir et les dix photos inutilisées ; un seul Rétablir restaure exactement les quatre pages et les groupes `A…D`, `E…H`, `I…J`. |
| 7 | Presser de nouveau Annuler, choisir Aérée, ouvrir la confirmation puis confirmer. | La confirmation annonce 10 photos, 2 cadres vides, 1 page réutilisée et 4 pages créées ; le résultat contient six pages au total et cinq groupes ordonnés de deux photos : `A–B`, `C–D`, `E–F`, `G–H`, `I–J`, tous en Auto/Aérée. |
| 8 | Annuler une fois, choisir Dense, ouvrir la confirmation puis confirmer. | La confirmation annonce 10 photos, 2 cadres vides, 1 page réutilisée et 1 page créée ; le résultat contient trois pages au total, `A…H` sur la page 2 et `I…J` sur la nouvelle dernière page, toutes deux en Auto/Dense. |
| 9 | Fermer proprement l’album, le rouvrir et revoir les trois pages ainsi que Photos. | Le résultat Dense, le fond noir, l’ordre `A…H` puis `I…J`, les onze assets et l’absence de photo inutilisée persistent après relance. |
| 10 | En portrait puis paysage, activer VoiceOver et parcourir le groupe, le sélecteur de densité, le compteur et le bouton désactivé. | Aucun contenu utile n’est rogné ; VoiceOver annonce le groupe, les densités, le compteur, le bouton et son état désactivé dans un ordre cohérent ; l’app reste réactive. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « les tests sont ok » reçu après remise de cette seule
  fiche. Les dix étapes sont déclarées conformes globalement ; aucune capture
  ni observation distincte par étape n’a été jointe. Les deux changements
  produit demandés dans le même retour rendent cette preuve insuffisante pour
  leur nouvelle interface et leur nouvelle règle de cadrage.
- Environnement : repris de la fiche, sans nouvelle déclaration dans le
  retour : iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; taille
  de texte standard ; portrait initial, paysage et VoiceOver à l’étape 10 ;
  Paris, France ; français (France). Aucun résultat iPhone, Xcode ou
  `APPLE-*` n’est extrapolé.

## Régression de l’action compacte et du cadrage initial

### `IPAD-L2-019` — Dialogue de densité et couverture des nouveaux placements

- Candidat : `3944fae199b2eb37c7b1f0a1aae5558197455b87`.
- Spécification : 3.0 incluse dans le candidat exact ; `DEC-07`, la section 3.1,
  `AUT-009…011`, `FRM-004`, `FRM-009`, `CRP-001` et `CRP-005` portent la
  nouvelle règle.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:DEC-07`, section 3.1,
  `3:AUT-002`, `3:AUT-004`, `3:AUT-009` à `3:AUT-012`, `3:PHO-005`,
  `3:PHO-006`, `3:PHO-012`, `3:PHO-014`, `3:FRM-004`, `3:FRM-009`,
  `3:CRP-001`, `3:CRP-004` à `3:CRP-007`, `3:UND-001`, `3:SAV-001`,
  `3:ACC-002`, `3:ACC-006`, `3:ACC-021` et `3:DONE-005`.
- Préconditions : avant le transfert, conserver sous `7815396…` un album
  « Test Cadrage » avec une occurrence `O` manuellement cadrée à `1×`, centrée
  ou décentrée de manière reconnaissable, puis importer sans les placer les
  fixtures `small-landscape-600x400.png` (`S`) et
  `large-portrait-4800x6000.png` (`L`). Préparer aussi un album distinct
  « Test Remplir compact » comme pour `018` : deux pages, `U` seule occurrence
  sur la page 1, deux cadres vides et fond noir sur la page 2, puis dix photos
  inutilisées `A…J` aux dates croissantes. Fermer proprement les deux albums,
  transférer exactement le candidat et ne supprimer aucune donnée locale.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler, lancer le candidat et ouvrir « Test Cadrage » en portrait. | La compilation et le lancement réussissent ; l’occurrence historique `O` conserve exactement son échelle, son point focal et le fond éventuellement visible : aucune migration de cadrage n’est appliquée à l’ouverture. |
| 2 | Ouvrir « Test Remplir compact », afficher Photos et examiner la zone sous Ajouter des photos sans presser Remplir l’album. | Un seul bouton compact Remplir l’album apparaît directement sous Ajouter des photos ; aucun grand bloc permanent, sélecteur de densité ni compteur permanent ne réduit la grille. Le bouton est actif et identifiable avec `wand.and.stars`. |
| 3 | Presser Remplir l’album et lire la fenêtre sans valider. | Un dialogue interne centré apparaît sans gel ; il affiche « 10 photos inutilisées », Densité avec Aérée (1–2), Équilibrée (3–4) et Dense (5–8), l’impact exact pour Équilibrée — 2 cadres vides retirés, 1 page réutilisée et 2 pages créées — puis Annuler et Valider entièrement visibles sans défilement. |
| 4 | Dans la même fenêtre, choisir Aérée, puis Dense, puis revenir à Équilibrée et presser Annuler. | Chaque choix actualise immédiatement le plan sans fermer ni figer la fenêtre : Aérée annonce 4 pages créées et Dense 1 page créée, toujours avec 10 photos, 2 cadres retirés et 1 page réutilisée. Annuler ferme le dialogue sans modifier l’album. |
| 5 | Rouvrir le dialogue en Équilibrée, presser Valider et parcourir les quatre pages. | La page 1 et `U` restent inchangés ; la page 2 garde son fond noir, remplace ses cadres vides par `A…D`, puis deux pages finales reçoivent `E…H` et `I…J`. Chaque nouvelle photo est centrée, non tournée et couvre entièrement son cadre final sans bande de fond dans le rectangle. |
| 6 | Presser Annuler une fois, rouvrir le dialogue ; en portrait puis paysage, activer VoiceOver et parcourir titre, compteur, densité, impact et actions ; presser Annuler, puis Rétablir une fois. | Un Annuler restaure les deux pages et les dix photos inutilisées. Le dialogue reste lisible, centré, réactif et dans un ordre vocal cohérent dans les deux orientations. Annuler le dialogue ne change rien ; un seul Rétablir restaure les quatre pages remplies. |
| 7 | Revenir dans « Test Cadrage », contrôler `O`, puis presser la miniature `S` sans cadre sélectionné. | `O` garde encore son cadrage historique. Un nouveau cadre libre est créé pour `S` et la photo 600 × 400 est agrandie, centrée et sans déformation pour couvrir entièrement le cadre ; son zoom initial est supérieur à `1×`. |
| 8 | Recadrer `S`, descendre manuellement à `1×`, puis presser Réinitialiser et Terminé. | À `1×`, le fond devient visible autour de la petite photo sans correction automatique. Réinitialiser restaure le cadrage centré couvrant et un zoom supérieur à `1×` ; Terminé enregistre une seule commande annulable. |
| 9 | Sans cadre sélectionné, presser la miniature `L`, puis ouvrir Recadrer et presser Réinitialiser. | Un nouveau cadre libre est créé ; la grande photo 4 800 × 6 000 est réduite à une valeur inférieure à `1×`, centrée et couvre le cadre sans déformation. Réinitialiser conserve ce facteur couvrant inférieur à `1×`, sans revenir arbitrairement à `1×`. |
| 10 | Ajouter un cadre photo vide, le remplir avec `S`, puis choisir Remplacer et sélectionner `L`; presser ensuite Annuler une fois. | Remplir conserve le cadre et ses styles et cadre `S` pour le couvrir. Remplacer conserve la même géométrie et les mêmes styles et recalcule pour `L` une couverture centrée. Un Annuler restaure `S` avec son cadrage précédent en une seule action. |
| 11 | Ajouter une page vide en confirmant si demandé, activer Auto, ajouter une occurrence de `S`, noter son cadrage, puis ajouter `L`. | La première occurrence couvre sa géométrie Auto finale. Après le second ajout, `L` couvre son propre cadre final ; `S` conserve exactement son échelle et son point focal malgré la recomposition, conformément à `CRP-007`, sans état intermédiaire visible ni cadre vide. |
| 12 | Fermer proprement les deux albums, les rouvrir et revoir `O`, `S`, `L`, la page Auto et le résultat Équilibrée. | Les cadrages historiques et nouveaux, la page Auto, les quatre pages remplies, leurs fonds et leur ordre persistent. L’app reste réactive ; aucune photo importée n’a été supprimée et les anciens placements n’ont pas été réécrits. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « tout est ok » reçu après remise de cette seule fiche.
  Les douze attentes sont acceptées globalement, sans capture ni observation
  distincte par étape ; aucun résultat `APPLE-*` n’est extrapolé.
- Environnement : repris de la fiche, sans nouvelle déclaration dans le retour :
  iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; taille de texte
  standard ; portrait initial, paysage et VoiceOver à l’étape 6 ; Paris,
  France ; français (France).

## Premier incrément des zones de texte

### `IPAD-L2-020` — Création, édition riche et débordement

- Candidat : `d882183d31de7ed6078c70f9e79a80d6ba994dd6`.
- Spécification : 3.0 incluse dans le candidat exact ; l’ADR
  `docs/architecture/ADR-003-swiftui-rich-text-alignment.md` documente la limite
  publique actuelle de l’alignement justifié.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:TBX-001` à `3:TBX-010`,
  `3:TBX-012` à `3:TBX-020`, `3:TBX-023` à `3:TBX-025`, `3:TPL-012`,
  `3:TPL-013`, `3:TPL-017`, `3:TXA-001`, `3:TXA-002`, `3:TXA-004`,
  `3:UND-001`, `3:SAV-001`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` et
  `3:DONE-005`.
- Limites explicites : cette fiche ne valide ni l’alignement justifié de
  `TBX-011`, ni le regroupement à 750 ms de `TBX-022`, ni Exporter de
  `TBX-021`/Lot 3, ni le presse-papiers multi-types.
- Préconditions : transférer exactement `Albumzh.swiftpm` du candidat ; ouvrir
  un album jetable possédant une page claire, une page à fond noir, deux photos
  superposables et au moins un modèle de Mise en page classé Avec texte.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler, lancer le candidat et rouvrir l’album préparé en portrait. | La compilation et le lancement réussissent ; les pages, photos, cadrages et résultats de `IPAD-L2-019` restent lisibles et inchangés. |
| 2 | Sur la page claire, presser le bouton Ajouter du texte placé sur la page. | Une fenêtre Modifier/Ajouter du texte s’ouvre avec le clavier ; « Votre texte » est sélectionné. Annuler immédiatement ne crée aucun élément. |
| 3 | Rouvrir l’ajout depuis le menu Ajouter de la barre supérieure, remplacer l’indication par « Bonjour album », puis presser Terminer. | Une zone centrée, au premier plan, large d’environ 60 % de la page et haute d’au moins 12 % est créée ; son texte est noir, centré, régulier et entièrement visible. |
| 4 | Toucher une fois la zone, puis une seconde fois ; recommencer avec un double toucher. | La première pression sélectionne la zone ; la seconde ou le double toucher rouvre l’éditeur et place le curseur sans déplacer la zone. |
| 5 | Sélectionner seulement « Bonjour », puis utiliser dans l’ordre Police, Taille, Gras, Italique et Couleur ; saisir ensuite quelques caractères sans sélection. | Seuls les caractères sélectionnés changent ; le style de frappe choisi s’applique aux nouveaux caractères. Les commandes apparaissent dans l’ordre demandé et n’exposent ni listes, tableaux, liens actifs, pièces jointes ni styles Notes. |
| 6 | Créer deux paragraphes, centrer le premier, aligner le second à droite, puis régler son interligne à 1,5 et l’opacité de la zone à 50 %. | Les styles de caractères et de paragraphes restent indépendants ; l’opacité s’applique à toute la zone. Gauche, Centré et Droite sont proposés, mais aucun bouton Justifié trompeur n’apparaît dans ce candidat. |
| 7 | Coller une URL mise en forme accompagnée, si possible, d’une image ou pièce jointe. | Le texte reste éditable dans les styles autorisés de l’app ; l’URL n’est pas active et aucune image, pièce jointe, liste, tableau ou métadonnée ne persiste. Cette étape ne ferme pas encore la conservation fine de chaque style externe de `TBX-007`. |
| 8 | Remplacer le contenu par 995 caractères, puis coller au moins 20 caractères supplémentaires. | Le compteur s’arrête exactement à 1 000 `Character`, seuls les caractères excédentaires sont refusés et l’alerte de limite est annoncée ; l’app ne se fige pas. |
| 9 | Terminer, déplacer, tourner et redimensionner manuellement la zone, puis rouvrir le texte et modifier sa longueur. | Déplacement, rotation et profondeur fonctionnent comme pour les autres éléments ; le redimensionnement ne change pas la taille de police et désactive l’ajustement automatique de hauteur. |
| 10 | Créer une nouvelle zone avec plusieurs lignes sans la redimensionner, puis raccourcir et rallonger son contenu. | La hauteur augmente automatiquement quand le contenu l’exige, reste dans la page et aucun caractère n’est tronqué silencieusement. |
| 11 | Réduire manuellement cette zone jusqu’à provoquer un débordement, puis tenter de passer en Prévisualiser. | Un contour rouge, une icône d’alerte et une explication accessible signalent le débordement ; la prévisualisation est bloquée et l’app revient sur la page et la zone concernées. |
| 12 | Corriger le débordement, appliquer un modèle Avec texte, puis toucher sa zone vide « Ajouter du texte ». | La prévisualisation redevient accessible. Le modèle crée une zone vide liée au slot, visible seulement en édition ; la toucher ouvre la saisie et aucun texte vide n’apparaît en prévisualisation. |
| 13 | Sur la page à fond noir, ajouter une zone, saisir un texte, puis changer le fond pour une couleur claire. | Le nouveau texte est initialement blanc pour rester lisible ; le changement de fond ultérieur ne recolore pas automatiquement le texte existant. |
| 14 | Créer une seconde zone, superposer les deux textes et une photo, puis utiliser Premier plan, Avancer, Reculer et Arrière-plan. | Chaque zone reste indépendante et les trois types d’éléments partagent le même ordre de profondeur sans perte de contenu ni de style. |
| 15 | Annuler puis Rétablir les derniers ajouts/modifications, fermer proprement l’album et le rouvrir. | Chaque validation Terminer est une commande cohérente et annulable ; contenu, runs, paragraphes, styles, opacité, géométrie, profondeur et zones de modèle persistent après relance. |
| 16 | Refaire les étapes 2, 5 et 11 en paysage puis parcourir le bouton, l’éditeur, sa barre et l’alerte avec VoiceOver. | Le clavier ne masque pas durablement la sélection ; les commandes restent utilisables et annoncées dans un ordre cohérent, avec libellés explicites et alerte de débordement accessible. |

- Résultat : 🔴 `ÉCHOUÉ` à l’étape 1 ; étapes 2 à 16 non exécutées.
- Preuve : captures `IMG_4188.HEIC` et `IMG_4189.HEIC` reçues le 17 août 2026
  et conservées hors Git. Les diagnostics portent sur `AlbumTextEditorView` :
  le proxy d’une contrainte dont l’`AttributeKey` est le style métier refuse
  l’écriture de `Font` et `Color`; celui de la contrainte paragraphe refuse
  `TextAlignment` et l’interligne, avec erreurs secondaires de sous-script
  dynamique ambigu ou en lecture seule.
- Environnement : repris de la fiche faute de nouvelle déclaration : iPad 8e
  génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; Paris, France ; français
  (France). Aucun comportement fonctionnel ni contrôle `APPLE-*` n’est prouvé.

### `IPAD-L2-021` — Régression de compilation et qualification du texte

- Candidat : `0f4b16c6c6435c29ca44da4e2726fac210add520`.
- Spécification : 3.0 incluse dans le candidat exact ; même périmètre et mêmes
  limites que `IPAD-L2-020`. Le correctif remplace les deux contraintes fautives
  par une portée métier imbriquée et une contrainte par attribut rendu.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:TBX-001` à `3:TBX-010`,
  `3:TBX-012` à `3:TBX-020`, `3:TBX-023` à `3:TBX-025`, `3:TPL-012`,
  `3:TPL-013`, `3:TPL-017`, `3:TXA-001`, `3:TXA-002`, `3:TXA-004`,
  `3:UND-001`, `3:SAV-001`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021` et
  `3:DONE-005`.
- Limites explicites : cette fiche ne valide ni l’alignement justifié de
  `TBX-011`, ni le regroupement à 750 ms de `TBX-022`, ni Exporter de
  `TBX-021`/Lot 3, ni le presse-papiers multi-types.
- Préconditions : repartir du même album jetable que pour `020`, transférer
  exactement le nouveau candidat et ne conserver aucun fichier source modifié
  localement dans Swift Playgrounds.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler et lancer exactement le candidat, puis rouvrir l’album préparé en portrait. | La compilation réussit sans aucun diagnostic dans `AlbumTextEditorView`; l’app se lance et les pages, photos, cadrages et résultats de `IPAD-L2-019` restent lisibles et inchangés. |
| 2 | Sur la page claire, presser le bouton Ajouter du texte placé sur la page. | Une fenêtre Modifier/Ajouter du texte s’ouvre avec le clavier ; « Votre texte » est sélectionné. Annuler immédiatement ne crée aucun élément. |
| 3 | Rouvrir l’ajout depuis le menu Ajouter de la barre supérieure, remplacer l’indication par « Bonjour album », puis presser Terminer. | Une zone centrée, au premier plan, large d’environ 60 % de la page et haute d’au moins 12 % est créée ; son texte est noir, centré, régulier et entièrement visible. |
| 4 | Toucher une fois la zone, puis une seconde fois ; recommencer avec un double toucher. | La première pression sélectionne la zone ; la seconde ou le double toucher rouvre l’éditeur et place le curseur sans déplacer la zone. |
| 5 | Sélectionner seulement « Bonjour », puis utiliser dans l’ordre Police, Taille, Gras, Italique et Couleur ; saisir ensuite quelques caractères sans sélection. | Seuls les caractères sélectionnés changent ; le style de frappe choisi s’applique aux nouveaux caractères. Les commandes apparaissent dans l’ordre demandé et n’exposent ni listes, tableaux, liens actifs, pièces jointes ni styles Notes. |
| 6 | Créer deux paragraphes, centrer le premier, aligner le second à droite, puis régler son interligne à 1,5 et l’opacité de la zone à 50 %. | Les styles de caractères et de paragraphes restent indépendants ; l’opacité s’applique à toute la zone. Gauche, Centré et Droite sont proposés, sans bouton Justifié trompeur. |
| 7 | Coller une URL mise en forme accompagnée, si possible, d’une image ou pièce jointe. | Le texte reste éditable dans les styles autorisés de l’app ; l’URL n’est pas active et aucune image, pièce jointe, liste, tableau ou métadonnée ne persiste. Cette étape ne ferme pas encore la conservation fine de chaque style externe de `TBX-007`. |
| 8 | Remplacer le contenu par 995 caractères, puis coller au moins 20 caractères supplémentaires. | Le compteur s’arrête exactement à 1 000 `Character`, seuls les caractères excédentaires sont refusés et l’alerte de limite est annoncée ; l’app ne se fige pas. |
| 9 | Terminer, déplacer, tourner et redimensionner manuellement la zone, puis rouvrir le texte et modifier sa longueur. | Déplacement, rotation et profondeur fonctionnent comme pour les autres éléments ; le redimensionnement ne change pas la taille de police et désactive l’ajustement automatique de hauteur. |
| 10 | Créer une nouvelle zone avec plusieurs lignes sans la redimensionner, puis raccourcir et rallonger son contenu. | La hauteur augmente automatiquement quand le contenu l’exige, reste dans la page et aucun caractère n’est tronqué silencieusement. |
| 11 | Réduire manuellement cette zone jusqu’à provoquer un débordement, puis tenter de passer en Prévisualiser. | Un contour rouge, une icône d’alerte et une explication accessible signalent le débordement ; la prévisualisation est bloquée et l’app revient sur la page et la zone concernées. |
| 12 | Corriger le débordement, appliquer un modèle Avec texte, puis toucher sa zone vide « Ajouter du texte ». | La prévisualisation redevient accessible. Le modèle crée une zone vide liée au slot, visible seulement en édition ; la toucher ouvre la saisie et aucun texte vide n’apparaît en prévisualisation. |
| 13 | Sur la page à fond noir, ajouter une zone, saisir un texte, puis changer le fond pour une couleur claire. | Le nouveau texte est initialement blanc pour rester lisible ; le changement de fond ultérieur ne recolore pas automatiquement le texte existant. |
| 14 | Créer une seconde zone, superposer les deux textes et une photo, puis utiliser Premier plan, Avancer, Reculer et Arrière-plan. | Chaque zone reste indépendante et les trois types d’éléments partagent le même ordre de profondeur sans perte de contenu ni de style. |
| 15 | Annuler puis Rétablir les derniers ajouts/modifications, fermer proprement l’album et le rouvrir. | Chaque validation Terminer est une commande cohérente et annulable ; contenu, runs, paragraphes, styles, opacité, géométrie, profondeur et zones de modèle persistent après relance. |
| 16 | Refaire les étapes 2, 5 et 11 en paysage puis parcourir le bouton, l’éditeur, sa barre et l’alerte avec VoiceOver. | Le clavier ne masque pas durablement la sélection ; les commandes restent utilisables et annoncées dans un ordre cohérent, avec libellés explicites et alerte de débordement accessible. |

- Résultat : 🔴 `ÉCHOUÉ` après compilation et lancement réussis. Le bouton
  Ajouter du texte est superposé au canevas ; dans la fenêtre, le texte initial
  devient noir sur le fond noir de l’apparence système, les six pastilles de
  couleur apparaissent blanches, la taille visible ne correspond pas à celle du
  canevas et l’opacité ne produit pas d’effet perceptible.
- Preuve : retour utilisateur du 17 août 2026 et `IMG_4191.jpg`, conservée hors
  Git. La capture montre le bouton posé sur la page et un texte de grande taille
  dans l’éditeur rendu beaucoup plus petit sur le canevas. Elle ne montre pas
  la fenêtre ni l’opacité ; ces deux constats restent des observations directes
  du testeur sans capture associée.
- Portée : l’étape 1 est réussie indirectement par l’exécution de l’app. Les
  anomalies concernent le parcours des étapes 2, 3, 5 et 6 ; les étapes 4 et
  7 à 16 ne reçoivent aucun verdict détaillé.
- Environnement : repris de la fiche faute de nouvelle déclaration : iPad 8e
  génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; Paris, France ; français
  (France). Aucun contrôle `APPLE-*` n’est inclus.

### `IPAD-L2-022` — Panneau Texte et rendu cohérent

- Candidat : `7bc495ec623e5b12301569d0108fbccadb978630`.
- Spécification : 3.0 modifiée conformément au retour utilisateur : nouveau
  panneau Texte entre Mise en page et Fonds, ajout hors canevas, contenu et
  formats dans l’inspecteur, palette colorée, fond réel et échelle du canevas
  dans l’éditeur, opacité immédiatement visible.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:EDT-001`, `3:EDT-002`,
  `3:EDT-006`, `3:EDT-008`, `3:EDT-012`, `3:EDT-014`, `3:EDT-021`,
  `3:TBX-001` à `3:TBX-010`, `3:TBX-012` à `3:TBX-020`, `3:TBX-023` à
  `3:TBX-025`, `3:TPL-012`, `3:TPL-013`, `3:TPL-017`, `3:TXA-001`,
  `3:TXA-002`, `3:TXA-004`, `3:UND-001`, `3:SAV-001`, `3:ACC-002`,
  `3:ACC-006`, `3:ACC-021` et `3:DONE-005`.
- Limites explicites : cette fiche ne valide ni l’alignement justifié de
  `TBX-011`, ni le regroupement à 750 ms de `TBX-022`, ni Exporter de
  `TBX-021`/Lot 3, ni le presse-papiers multi-types.
- Préconditions : transférer exactement le nouveau candidat ; ouvrir un album
  jetable avec une page claire, une page utilisant le fond sombre intégré, deux
  photos superposables et un modèle Avec texte. Commencer à un zoom de canevas
  de 100 % et avec l’apparence sombre de l’iPad.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler, lancer le candidat et rouvrir l’album en portrait. | La compilation et le lancement réussissent sans diagnostic ; les contenus validés jusqu’à `IPAD-L2-019` restent présents et lisibles. |
| 2 | Parcourir le rail dans l’ordre, ouvrir Texte puis Fonds, et revenir à Texte sans désélectionner l’élément courant. | Photos, Mise en page, Texte et Fonds apparaissent dans cet ordre ; le panneau droit reste lisible, Texte se replie indépendamment et le changement de panneau conserve la sélection. |
| 3 | Observer la page, puis ouvrir le menu `+` de la barre supérieure. | Aucun bouton Ajouter du texte ne recouvre le canevas. Le menu `+` conserve exactement les raccourcis Ajouter un cadre photo et Ajouter du texte. |
| 4 | Dans le panneau Texte sans zone sélectionnée, presser Ajouter un texte puis Annuler ; recommencer et valider « Bonjour album ». | Le bouton est au niveau du panneau, ouvre l’éditeur avec « Votre texte » sélectionné et Annuler ne crée rien. La validation crée une zone centrée au premier plan, large de 60 % et haute d’au moins 12 %. |
| 5 | Sur la page claire en apparence sombre, rouvrir « Bonjour album ». | La fenêtre affiche le fond réel clair derrière le texte noir ; aucun noir sur noir ne provient de l’apparence système. |
| 6 | Ouvrir Couleur dans la fenêtre, vérifier les six choix puis appliquer successivement Blanc, Rouge, Vert et Bleu à une sélection. | Chaque choix possède une pastille de sa couleur réelle avec un contour visible ; seule la sélection change et la palette ne transforme aucune pastille en blanc générique. |
| 7 | Au zoom 100 %, appliquer 18 puis 96 points à la même sélection et comparer immédiatement la fenêtre au canevas après Terminer. | La taille est rendue dans la fenêtre selon la hauteur affichée de la page ; le rapport entre 18 et 96 points et la taille finale restent visuellement cohérents au retour sur le canevas. |
| 8 | Dans la fenêtre, choisir successivement 25 %, 50 % puis 100 % d’opacité avant de terminer ; refaire 50 % depuis le panneau Texte. | L’effet est visible immédiatement dans la fenêtre, puis sur le canevas. Le réglage du panneau s’applique à toute la zone et sa valeur affichée suit 50 %. |
| 9 | Sélectionner la zone, lire l’inspecteur de l’élément, puis appliquer Police, Taille, Gras, Italique, Couleur, Alignement et Interligne depuis cet inspecteur. | Le texte complet à afficher est lisible dans l’inspecteur ; les options sont dans l’ordre prévu, agissent sur toute la zone en commandes annulables et Modifier le texte et le format permet toujours de cibler une sélection. Le panneau Texte renvoie clairement vers l’inspecteur. |
| 10 | Sur le fond sombre intégré, ajouter une nouvelle zone puis saisir du texte. | La fenêtre reprend le fond sombre et le texte initial est blanc ; aucun blanc sur blanc ou noir sur noir n’apparaît. Un changement ultérieur du fond ne recolore pas la zone existante. |
| 11 | Dans la fenêtre, sélectionner seulement un mot, modifier son format, créer deux paragraphes avec alignements/interlignes distincts, puis dépasser 1 000 caractères par collage. | Seule la sélection change, les paragraphes restent indépendants, le compteur s’arrête à 1 000 `Character` et seuls les caractères excédentaires sont refusés. |
| 12 | Terminer, déplacer, tourner et redimensionner la zone, modifier ensuite sa longueur, puis Annuler/Rétablir. | Les transformations et la profondeur restent communes aux éléments ; redimensionner ne change pas la police, désactive la hauteur automatique et chaque validation reste une commande cohérente. |
| 13 | Créer une zone automatique sur plusieurs lignes, provoquer un débordement par réduction puis tenter Prévisualiser. | La hauteur automatique suit le contenu avant redimensionnement ; le débordement affiche contour rouge, icône et explication, et bloque Prévisualiser en revenant sur la zone. |
| 14 | Corriger le débordement, appliquer un modèle Avec texte et toucher son emplacement vide. | La prévisualisation redevient accessible ; l’emplacement vide n’apparaît qu’en édition et ouvre la même saisie sans produire de texte vide dans la sortie. |
| 15 | Superposer deux textes et une photo, utiliser les quatre commandes de profondeur, fermer proprement puis rouvrir l’album. | Les trois types partagent une pile ; contenu, runs, paragraphes, formats, opacité, géométrie et profondeur persistent après relance. |
| 16 | Refaire les étapes 2, 4, 6, 8 et 13 en paysage, puis parcourir le panneau, la palette, l’éditeur et l’alerte avec VoiceOver. | Aucun panneau ni canevas n’est rogné ; commandes, couleurs, valeurs d’opacité et alerte sont annoncées avec des libellés explicites dans un ordre cohérent. |

- Résultat : 🔴 `ÉCHOUÉ` à l’étape 4. La compilation et le lancement sont
  prouvés indirectement par l’accès à l’éditeur, mais le texte tapé au clavier
  ne devient pas lisible dans la fenêtre ; la campagne ne peut pas continuer.
- Preuve : retour utilisateur du 18 août 2026, sans capture. Les étapes 2 et 3
  ne reçoivent aucun verdict détaillé et les étapes 5 à 16 ne sont pas
  exécutées.
- Diagnostic : la correction précédente projetait directement la valeur
  canonique `N / 3000` sur la hauteur affichée. À 600 points de haut, le style
  initial de 18 points ne mesurait donc que 3,6 points au lieu des 15 points
  issus de la conversion typographique `18 × 600 / 720`.
- Environnement : repris de la fiche faute de nouvelle déclaration : iPad 8e
  génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; Paris, France ; français
  (France). Aucun contrôle `APPLE-*` n’est inclus.

## Jeu de test partagé Texte-A

Les fiches `IPAD-L2-023…029` sont courtes et s’exécutent dans l’ordre. Elles
réutilisent le même album jetable ouvert pour `IPAD-L2-022` ; il ne faut pas le
recréer. Chaque fiche décrit l’état qu’elle laisse à la suivante. En cas
d’échec, arrêter la fiche concernée et ne pas reconstruire l’album : le
correctif suivant repartira du dernier état effectivement obtenu.

### `IPAD-L2-023` — Compilation et saisie visible

- Candidat : `f0a0ccaa4f580a5d602dfc9432228fdf5115ce59`.
- Préconditions : conserver l’album de `IPAD-L2-022` et ouvrir sa page claire à
  100 %. Aucune zone nommée « Bonjour album » n’est requise au départ.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:TBX-002` à `3:TBX-005`,
  `3:TBX-014`, `3:TBX-025`, `3:DONE-005`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler et lancer le candidat, puis rouvrir le même album et sa page claire. | La compilation réussit, l’app s’ouvre et le jeu de test existant est conservé. |
| 2 | Ouvrir Texte, presser Ajouter un texte et vérifier l’indication sélectionnée. | « Votre texte » est visible, sélectionné et le clavier apparaît sans masquer la saisie. |
| 3 | Taper lentement « Bonjour album ». | Chaque caractère apparaît immédiatement en noir à une taille lisible ; aucun caractère n’est seulement présent de façon invisible. |
| 4 | Presser Terminer, rouvrir la zone, ajouter « ! », puis Annuler. | « Bonjour album » est lisible sur la page ; l’éditeur l’affiche à nouveau et Annuler retire seulement le point d’exclamation. La zone « Bonjour album » reste disponible pour `IPAD-L2-024`. |

- Résultat : 🔴 `ÉCHOUÉ` à l’étape 4. Les étapes 1 à 3 sont déclarées
  conformes : le candidat compile, s’ouvre et rend chaque caractère saisi à
  une taille visible. Après Terminer, les descendantes d’une zone d’une seule
  ligne (`j`, `p`, `g`, `q`…) sont toutefois rognées en bas ; ajouter une
  deuxième ligne rétablit le rendu correct des deux lignes. Les contrôles de
  réouverture, du point d’exclamation et d’Annuler ne reçoivent pas de verdict
  distinct.
- Preuve : retour utilisateur du 19 août 2026, sans capture. Une observation
  complémentaire signale qu’avec une couleur unie l’éditeur reste lisible,
  tandis qu’avec un motif intégré le fond passe devant le texte et les outils :
  seuls la barre de titre, Annuler et Terminer restent visibles. Après certaines
  manipulations non reproductibles, cette surimpression devient parfois
  blanche au lieu du motif réel.
- Environnement : repris de `IPAD-L2-022`, faute de nouvelle déclaration :
  iPad 8e génération ; iPadOS 26.5.2 ; Swift Playgrounds 4.7 ; Paris, France ;
  français (France). Aucun contrôle `APPLE-*` n’est inclus.

### `IPAD-L2-024` — Panneau Texte, raccourcis et inspecteur

- Candidat : `f0a0ccaa4f580a5d602dfc9432228fdf5115ce59`.
- Préconditions : reprendre directement la page claire laissée par
  `IPAD-L2-023`, avec la zone « Bonjour album ».
- Exigences : `3:EDT-001`, `3:EDT-006`, `3:EDT-008`, `3:EDT-012`,
  `3:EDT-014`, `3:EDT-021`, `3:TBX-002`, `3:TBX-009`, `3:UND-001`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Parcourir le rail, observer le canevas puis ouvrir le menu `+`. | Dans l’incrément visible, Photos et Texte sont contigus, puis une séparation simple sans titre précède les panneaux distincts Mise en page et Fonds ; le futur Stickers s’insérera entre Texte et cette séparation. Aucun ajout ne recouvre la page et `+` contient Ajouter un cadre photo et Ajouter du texte. |
| 2 | Sélectionner « Bonjour album » puis ouvrir et replier séparément l’inspecteur et le panneau Texte. | La sélection persiste ; le contenu complet et les formats sont dans l’inspecteur, tandis que le panneau Texte conserve l’ajout et renvoie vers l’inspecteur. |
| 3 | Depuis l’inspecteur, appliquer Gras puis Bleu à toute la zone. | Toute la zone devient grasse et bleue en deux commandes visibles sur le canevas. |
| 4 | Utiliser Annuler deux fois puis Rétablir deux fois. | Les deux formats sont retirés puis restaurés séparément. La zone bleue et grasse reste disponible pour `IPAD-L2-025`. |

- Résultat : 🔴 `ÉCHOUÉ` sur l’acceptation de l’étape 1 ; les étapes 2, 3 et 4
  sont déclarées conformes. Le menu `+` est explicitement accepté. Le retour
  demande cependant que Photos, Texte et le futur panneau Stickers soient
  contigus comme éléments à ajouter. La clarification reçue le même jour fixe
  ensuite Photos, Texte, Stickers, une séparation simple sans titre, Mise en
  page, Fonds, puis Cadres et formes. Le candidat place encore Mise en page
  entre Photos et Texte et doit être corrigé selon `3:EDT-001` révisé.
- Preuve : retour utilisateur du 19 août 2026, sans capture ni détail
  supplémentaire pour les trois étapes réussies.
- Environnement : repris de `IPAD-L2-023`, sans changement déclaré. Aucun
  résultat iPhone, Xcode ou `APPLE-*` n’est extrapolé.

### `IPAD-L2-025` — Taille et opacité cohérentes

- Candidat : `f0a0ccaa4f580a5d602dfc9432228fdf5115ce59`.
- Préconditions : reprendre la zone bleue et grasse laissée par
  `IPAD-L2-024`, sur la même page claire à 100 %.
- Exigences : `3:TBX-010`, `3:TBX-012`, `3:TBX-014`, `3:TBX-024`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ouvrir Modifier le texte et le format, sélectionner « Bonjour », puis choisir 18 et 96 points. | La sélection reste visible aux deux tailles ; 96 points est nettement plus grand et utilise la même conversion que le canevas. |
| 2 | Terminer puis comparer la sélection à la fenêtre rouverte. | La taille apparente reste cohérente entre l’éditeur et la page au même zoom. |
| 3 | Dans la fenêtre, choisir 25 %, 50 % puis 100 % d’opacité. | L’effet sur toute la zone est visible immédiatement à chaque valeur. |
| 4 | Terminer, régler 50 % depuis l’inspecteur puis revenir à 100 %. | Le canevas suit chaque valeur et l’inspecteur l’affiche. Laisser finalement la zone à 18 points et 100 % pour `IPAD-L2-026`. |

- Résultat : 🔴 `ÉCHOUÉ` selon le verdict utilisateur de l’étape 3 ; les
  étapes 1, 2 et 4 sont déclarées conformes pour leurs attentes principales.
  Fermer le clavier après avoir sélectionné « Bonjour » fait néanmoins perdre
  la sélection. En paysage, garder le clavier pour préserver cette sélection
  occupe environ la moitié de l’écran. À l’étape 3, l’opacité appliquée à tout
  le texte est le comportement normatif de `3:TBX-012`, mais l’interface ne
  distingue pas suffisamment les formats de caractères, les formats de
  paragraphes et ceux de toute la zone ; ce manque de portée explicite motive
  le verdict d’échec sans conclure que l’opacité doit s’appliquer à un seul mot.
- Preuve : retour utilisateur du 19 août 2026, sans capture.
- Environnement : repris de `IPAD-L2-024`, sans changement déclaré. Aucun
  contrôle `APPLE-*` n’est inclus.

### `IPAD-L2-026` — Fond réel et palette colorée

- Candidat : `f0a0ccaa4f580a5d602dfc9432228fdf5115ce59`.
- Préconditions : conserver la page claire et « Bonjour album ». Réutiliser la
  page sombre de `IPAD-L2-022`; si elle n’existe pas, ajouter une seule page et
  lui appliquer le fond sombre intégré, puis la conserver pour les fiches
  suivantes.
- Exigences : `3:TBX-010`, `3:TBX-015`, `3:TBX-016`, `3:TBX-025`,
  `3:BG-011`, `3:BG-016`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Sur la page claire, rouvrir « Bonjour album » et afficher Couleur. | Le fond clair réel apparaît derrière le texte ; les six pastilles ont leur couleur réelle et un contour visible. |
| 2 | Appliquer Rouge puis Bleu à « Bonjour » seulement et terminer. | Seule la sélection change et les deux couleurs sont visibles dans la fenêtre puis sur la page. |
| 3 | Sur la page sombre conservée, ajouter une zone et taper « Contraste ». | Le fond sombre réel apparaît dans la fenêtre et le nouveau texte est blanc et lisible pendant la frappe. |
| 4 | Terminer puis changer cette page vers un fond clair. | « Contraste » reste blanc : un changement de fond ne recolore pas le texte existant. Conserver cette zone pour `IPAD-L2-029`. |

- Résultat : 🔴 `ÉCHOUÉ` aux étapes 1 et 2 en paysage. Clavier ouvert, les
  dernières couleurs sont hors de l’espace visible et la palette ne défile
  pas ; clavier fermé, la sélection disparaît. Il est donc impossible
  d’appliquer par exemple Bleu à un seul mot dans cette orientation. Les
  étapes 3 et 4 ne reçoivent aucun verdict et ne sont pas transformées en
  réussites.
- Preuve : retour utilisateur du 19 août 2026, sans capture.
- Environnement : repris de `IPAD-L2-025`; le retour précise le paysage, sans
  redéclarer appareil, système ou Playgrounds. Aucun contrôle `APPLE-*` n’est
  inclus.

### `IPAD-L2-027` — Sélections, paragraphes et limite

- Candidat : `f0a0ccaa4f580a5d602dfc9432228fdf5115ce59`.
- Préconditions : revenir à « Bonjour album » sur la page claire, sans recréer
  les deux pages ni leurs zones.
- Exigences : `3:TBX-006` à `3:TBX-011`, `3:TBX-013`, `3:TBX-017`,
  `3:TBX-023`, `3:TXA-001`, `3:TXA-002`, `3:TXA-004`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Sélectionner seulement « Bonjour », changer police, gras et italique, puis taper sans sélection. | Seule la sélection change ; les caractères suivants utilisent le style de frappe courant. |
| 2 | Créer deux paragraphes, centrer le premier et aligner le second à droite avec un interligne de 1,5. | Les formats de caractères et de paragraphes restent indépendants et aucun faux choix Justifié n’est proposé. |
| 3 | Coller une URL mise en forme et, si possible, une pièce jointe. | L’URL reste du texte non actif ; pièces jointes, listes, tableaux et métadonnées ne persistent pas. |
| 4 | Remplacer le contenu par 995 caractères puis en coller au moins 20. | La saisie s’arrête à 1 000 `Character`, annonce la limite et ne fige pas l’app. Conserver cette zone longue pour `IPAD-L2-028`. |

- Résultat : 🔴 `ÉCHOUÉ` à l’étape 1. Avec « Bonjour » sélectionné, les choix
  Système et Arrondie produisent le même rendu et Italique ne provoque aucun
  changement perceptible. Les étapes 2, 3 et 4 sont déclarées conformes
  globalement, sans observation distincte par action.
- Preuve : retour utilisateur du 19 août 2026, sans capture.
- Environnement : repris de `IPAD-L2-026`, sans changement déclaré. Aucun
  contrôle `APPLE-*` n’est inclus.

### `IPAD-L2-028` — Géométrie, débordement et modèle texte

- Candidat : `f0a0ccaa4f580a5d602dfc9432228fdf5115ce59`.
- Préconditions : reprendre la zone longue laissée par `IPAD-L2-027` sur la
  page claire et le modèle Avec texte déjà utilisé pour `IPAD-L2-022`.
- Exigences : `3:TBX-018` à `3:TBX-021`, `3:TPL-012`, `3:TPL-013`,
  `3:TPL-017`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Raccourcir la zone, créer une autre zone sur plusieurs lignes puis modifier sa longueur. | Avant redimensionnement manuel, la hauteur suit le contenu et reste dans la page. |
| 2 | Redimensionner la zone longue jusqu’à provoquer un débordement. | La taille de police ne change pas ; contour rouge, icône et explication signalent le débordement. |
| 3 | Tenter Prévisualiser puis corriger le débordement. | La prévisualisation est bloquée et revient sur la zone ; elle redevient accessible après correction. |
| 4 | Appliquer le modèle Avec texte et toucher son emplacement vide. | L’emplacement ouvre la même saisie, reste absent de la prévisualisation tant qu’il est vide et ne supprime aucun texte existant. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « ok » reçu le 19 août 2026 après identification
  explicite de cette seule fiche. Les quatre étapes sont déclarées conformes
  globalement ; aucune capture ni observation distincte par étape n’est jointe.
- Environnement : repris de `IPAD-L2-027`, sans changement déclaré. Aucun
  résultat iPhone, Xcode ou `APPLE-*` n’est extrapolé.

### `IPAD-L2-029` — Profondeur, persistance et accessibilité

- Candidat : `f0a0ccaa4f580a5d602dfc9432228fdf5115ce59`.
- Préconditions : conserver les pages et zones obtenues jusqu’à
  `IPAD-L2-028`; utiliser une photo déjà présente dans l’album, sans en
  réimporter une.
- Exigences : `3:TBX-001`, `3:TBX-004`, `3:TBX-023`, `3:TBX-024`,
  `3:UND-001`, `3:SAV-001`, `3:ACC-002`, `3:ACC-006`, `3:ACC-021`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Sur la page claire, superposer deux textes existants et la photo, puis utiliser les quatre commandes de profondeur. | Les trois éléments partagent la même pile et chaque direction disponible agit sans perte de contenu. |
| 2 | Annuler et Rétablir les dernières modifications, fermer proprement puis rouvrir l’album. | Contenus, formats, opacité, géométrie, ordre et pages du jeu Texte-A persistent. |
| 3 | En paysage, parcourir Texte, l’inspecteur, la palette et une alerte de débordement avec VoiceOver. | Aucun panneau n’est rogné ; commandes, couleurs, valeurs et alerte ont des libellés explicites et la sélection reste stable. |
| 4 | Revenir en portrait sur « Contraste » sans recréer de page. | La zone est retrouvée avec son texte blanc et son état persistant ; le jeu peut servir au correctif suivant si nécessaire. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « ok » reçu le 19 août 2026 après identification
  explicite de cette seule fiche. Les quatre étapes, dont le parcours paysage
  avec VoiceOver, sont déclarées conformes globalement ; aucune capture ni
  observation distincte par étape n’est jointe.
- Environnement : repris de `IPAD-L2-028`, sans changement déclaré. Le paysage
  et VoiceOver proviennent de la procédure, mais leurs réglages précis n’ont
  pas été redéclarés. Aucun résultat iPhone, Xcode ou autre `APPLE-*` n’est
  extrapolé.

## Régressions du correctif Texte-B

Les fiches `IPAD-L2-030…033` visent exactement le candidat
`cb7786259cc85cbe5fd7017ed2f4c9ae3ba823aa`. Elles réutilisent l’album Texte-A
laissé par `IPAD-L2-029` : aucune migration ni reconstruction du jeu n’est
requise. Arrêter seulement la fiche en défaut ; les autres contrôles restent
attribuables s’ils peuvent être exécutés sans dépendre de son état final.

### `IPAD-L2-030` — Compilation, descendantes et motifs intégrés

- Candidat : `cb7786259cc85cbe5fd7017ed2f4c9ae3ba823aa`.
- Préconditions : transférer exactement ce candidat, conserver l’album
  Texte-A et disposer d’une page claire ainsi que des trois motifs intégrés.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:CAN-003`, `3:BG-007`,
  `3:TBX-002` à `3:TBX-005`, `3:TBX-019`, `3:TBX-020`, `3:TBX-024`,
  `3:TBX-025` et `3:DONE-005`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler, lancer le candidat et rouvrir l’album Texte-A en portrait. | La compilation et le lancement réussissent ; les zones, formats et pages existants sont conservés. |
| 2 | Sur la page claire, créer une zone d’une seule ligne contenant exactement « Bonjour jpgqy », presser Terminer et observer chaque descendante. | Le bas de `j`, `p`, `g`, `q` et `y` est entièrement visible ; aucune lettre ne ressemble à un `i` et aucun faux débordement n’apparaît. |
| 3 | Rouvrir la zone, ajouter une seconde ligne « jpgqy », terminer puis revenir à une seule ligne. | Les glyphes restent complets avec une ou deux lignes ; la hauteur automatique s’adapte sans saut ni rognage. |
| 4 | Ouvrir successivement l’éditeur sur chacun des trois motifs intégrés, saisir quelques caractères, faire défiler la barre et ouvrir Couleur ; alterner plusieurs fois avec une couleur unie. | Le motif reste strictement derrière le texte et les outils. Texte, formats, palette et boutons restent lisibles et tactiles ; aucune couche blanche ou motif ne recouvre l’éditeur. |

- Résultat : 🔴 `ÉCHOUÉ` à l’étape 4. Les étapes 1 à 3 sont déclarées
  conformes : le candidat compile et se lance, les données sont conservées,
  toutes les descendantes sont visibles et la hauteur automatique reste stable
  avec une ou deux lignes. Les trois motifs intégrés recouvrent toutefois
  encore l’éditeur ; l’alternance avec une couleur unie fonctionne.
- Preuve : retour utilisateur du 20 août 2026, sans capture. Le constat
  « toujours ko sur les 3 fonds à motifs, ok pour couleur » ne permet pas de
  distinguer un motif particulier ni une manipulation intermittente.
- Environnement : repris de la fiche faute de différence déclarée : iPad 8e
  génération, iPadOS 26.5.2, Swift Playgrounds 4.7, portrait. Aucun résultat
  iPhone, Xcode ou `APPLE-*` n’est extrapolé.

### `IPAD-L2-031` — Ordre et séparation sans titre des panneaux

- Candidat : `cb7786259cc85cbe5fd7017ed2f4c9ae3ba823aa`.
- Préconditions : reprendre l’album après `IPAD-L2-030`, sur une page contenant
  au moins une photo et une zone de texte.
- Exigences : `3:DEC-32`, `3:EDT-001`, `3:EDT-002`, `3:EDT-006`,
  `3:EDT-012`, `3:EDT-021` et `3:ACC-021`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Parcourir le rail de haut en bas en portrait, sans ouvrir le menu `+`. | Les entrées publiques apparaissent dans l’ordre Photos, Texte, séparation simple, Mise en page, Fonds. La séparation ne porte aucun titre et n’est ni tactile ni annoncée. |
| 2 | Ouvrir successivement Photos, Texte, Mise en page et Fonds, puis ouvrir le menu `+`. | Chaque entrée reste un menu distinct ; Mise en page et Fonds ne sont pas fusionnés. Le menu `+` conserve Ajouter un cadre photo et Ajouter du texte. |
| 3 | Refaire le parcours en paysage avec une zone sélectionnée. | L’ordre et la séparation restent identiques, le rail et le panneau droit ne sont pas rognés et la sélection de l’élément persiste. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « ok » reçu le 20 août 2026 pour cette fiche, sans
  capture ni détail par étape. Les trois étapes sont attribuées à la fiche
  remise, sans qualifier la largeur compacte ni un autre contrôle `APPLE-*`.
- Environnement : repris de `IPAD-L2-030`, avec portrait puis paysage selon la
  procédure ; aucun changement déclaré.

### `IPAD-L2-032` — Sélection, palette et portées en paysage

- Candidat : `cb7786259cc85cbe5fd7017ed2f4c9ae3ba823aa`.
- Préconditions : reprendre la zone « Bonjour jpgqy », l’ouvrir en paysage et
  la remettre en police Système régulière, noire, opacité 100 %.
- Exigences : `3:TBX-005`, `3:TBX-010` à `3:TBX-012`, `3:TBX-015`,
  `3:TBX-016`, `3:ACC-002`, `3:ACC-006` et `3:ACC-021`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Sélectionner seulement « Bonjour » et parcourir horizontalement la barre de formats. | Sélection regroupe Police, Taille, Gras, Italique et Couleur ; Paragraphe regroupe Alignement et Interligne ; Zone contient Opacité. De simples séparations distinguent les trois portées. |
| 2 | Presser Masquer le clavier, puis choisir Bleu. | Le clavier disparaît, « Sélection conservée » apparaît et seule la plage « Bonjour » devient bleue ; « jpgqy » reste noire. |
| 3 | Réafficher le clavier, conserver « Bonjour » comme cible, ouvrir Couleur puis faire défiler la palette jusqu’à chaque choix. | La palette défile malgré la hauteur réduite ; Noir, Blanc, Rouge, Orange, Vert et Bleu sont tous accessibles et annoncés. |
| 4 | Masquer à nouveau le clavier, appliquer un alignement au paragraphe puis 50 % d’opacité. | L’alignement vise le paragraphe complet et l’opacité la zone complète ; la sélection de caractères n’est ni perdue ni utilisée à tort pour limiter l’opacité. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « ok » reçu le 20 août 2026 pour cette fiche, sans
  capture ni détail par étape. La sélection conservée, les portées et les six
  couleurs sont donc confirmées sur l’iPad déclaré seulement.
- Environnement : repris de `IPAD-L2-031`, en paysage selon la procédure ;
  aucun changement déclaré.

### `IPAD-L2-033` — Polices, italique et persistance de la sélection

- Candidat : `cb7786259cc85cbe5fd7017ed2f4c9ae3ba823aa`.
- Préconditions : conserver la même zone en paysage, revenir à 100 %
  d’opacité et sélectionner seulement « Bonjour » avec le clavier masqué.
- Exigences : `3:TBX-010`, `3:TBX-013`, `3:TBX-023`, `3:TBX-024`,
  `3:SAV-001` et `3:ACC-002`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Avec l’indicateur « Sélection conservée » visible, appliquer Système puis Arrondie à « Bonjour ». | Arrondie produit un dessin visiblement arrondi distinct de Système ; seule la sélection change et « jpgqy » conserve sa police. |
| 2 | Activer Italique, le désactiver, puis le réactiver sur la même sélection. | L’inclinaison de « Bonjour » change à chaque action ; le reste du texte ne change pas. |
| 3 | Presser Terminer, rouvrir la zone puis fermer et rouvrir proprement l’album. | Police Arrondie et Italique persistent uniquement sur « Bonjour » ; contenu, opacité et autres formats restent intacts. |
| 4 | Avec VoiceOver, parcourir Sélection, « Sélection conservée », Paragraphe, Zone et les commandes Police/Italique. | Les libellés et portées sont annoncés dans l’ordre visible sans faire passer les séparations pour des commandes. |

- Résultat : 🔴 `ÉCHOUÉ` aux étapes 1 et 2. La différence visuelle entre
  Système et Arrondie reste trop faible pour être identifiée facilement.
  Italique fonctionne avec Système, Sérif et Chasse fixe, mais ne produit pas
  d’effet perceptible avec Arrondie. Les étapes 3 et 4 sont déclarées
  conformes par le retour « le reste est ok » : persistance ciblée et parcours
  VoiceOver ne reçoivent pas d’anomalie distincte.
- Preuve : retour utilisateur du 20 août 2026, sans capture. Une demande
  complémentaire exige que chaque action de formatage à choix — Police,
  Couleur, Taille, Alignement, Interligne, Opacité et états Gras/Italique —
  matérialise sa valeur courante par une coche ou un état visible ; elle est
  enregistrée séparément sous `3:TBX-026` et n’est pas transformée en réussite
  rétroactive de cette fiche.
- Environnement : repris de `IPAD-L2-032`, en paysage avec VoiceOver à l’étape
  4 selon la procédure ; aucun changement déclaré.

## Régressions du second correctif texte

Les deux fiches suivantes visent exactement le candidat
`3102cda0e6b2c483576585ec2f97fc947f87c96f`. Elles réutilisent l’album
Texte-A dans l’état laissé par `IPAD-L2-033`. Exécuter `IPAD-L2-034` avant
`IPAD-L2-035`; aucune reconstruction du jeu ni répétition de `031…032` n’est
requise.

### `IPAD-L2-034` — Motifs strictement bornés dans l’éditeur

- Candidat : `3102cda0e6b2c483576585ec2f97fc947f87c96f`.
- Préconditions : transférer exactement ce candidat dans Swift Playgrounds,
  conserver l’album Texte-A et sa zone « Bonjour jpgqy », puis revenir en
  portrait. Disposer des trois motifs intégrés et d’une couleur unie.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:CAN-003`, `3:BG-007`,
  `3:TBX-024`, `3:TBX-025` et `3:DONE-005`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler, lancer le candidat et rouvrir l’album Texte-A. | La compilation et le lancement réussissent ; pages, zones et formats existants sont conservés. |
| 2 | Appliquer le motif Classique spirale à la page, ouvrir « Bonjour jpgqy », saisir quelques caractères puis ouvrir Couleur. | Le motif reste strictement dans le fond de la zone d’édition ; texte, barre, palette et boutons restent visibles et tactiles. |
| 3 | Remplacer le fond par Voyage kraft et refaire le contrôle de l’étape 2. | Le motif reste derrière l’éditeur sans couche blanche, débordement ni interception tactile. |
| 4 | Remplacer le fond par Minimal sombre et refaire le contrôle de l’étape 2. | Le motif reste derrière l’éditeur ; le texte et toutes les commandes conservent leur contraste et leur toucher. |
| 5 | Alterner chacun des trois motifs avec une couleur unie, puis terminer l’édition. | Aucun fond ne recouvre l’éditeur pendant les transitions ; la couleur unie et les trois motifs restent correctement bornés. |

- Résultat : 🟢 `RÉUSSI`. Les cinq étapes sont déclarées conformes globalement.
- Preuve : retour utilisateur « c’est ok pour les 2 tests » reçu le 20 août
  2026 après désignation explicite de `IPAD-L2-034` et `035`, sans capture ni
  détail distinct par étape.
- Environnement : repris de la fiche faute de différence déclarée : iPad 8e
  génération, iPadOS 26.5.2, Swift Playgrounds 4.7, portrait. Aucun résultat
  du candidat Info `6093058…` n’est extrapolé.

### `IPAD-L2-035` — Arrondie, italique et choix actifs

- Candidat : `3102cda0e6b2c483576585ec2f97fc947f87c96f`.
- Préconditions : partir de l’état final de `IPAD-L2-034`, revenir sur une
  couleur unie, ouvrir « Bonjour jpgqy » en paysage, sélectionner seulement
  « Bonjour » et masquer le clavier en conservant la sélection.
- Exigences : `3:TBX-009` à `3:TBX-016`, `3:TBX-023`, `3:TBX-024`,
  `3:TBX-026`, `3:SAV-001`, `3:ACC-002` et `3:ACC-004`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ouvrir Police, vérifier Système, puis choisir Arrondie. | La police courante porte une coche ou un état distinct et accessible ; Arrondie devient nettement différente de Système sur « Bonjour » seulement. |
| 2 | Ouvrir Italique, l’activer, le désactiver puis le réactiver. | L’état actif est visible ; Arrondie s’incline à chaque activation et revient droite à chaque désactivation sans modifier « jpgqy ». |
| 3 | Ouvrir Taille, relever le choix courant puis choisir 36. | La taille courante est matérialisée avant et après le choix ; seule la sélection passe à 36. |
| 4 | Ouvrir Gras, l’activer puis le désactiver. | L’état Gras est matérialisé à l’activation et disparaît à la désactivation ; seule la sélection change. |
| 5 | Ouvrir Couleur, relever le choix courant puis choisir Rouge. | La couleur courante est indiquée autrement que par sa seule teinte ; seule la sélection devient rouge. |
| 6 | Ouvrir Alignement, relever le choix courant puis choisir Centré. | L’alignement courant est matérialisé ; le paragraphe complet est centré. |
| 7 | Ouvrir Interligne, relever le choix courant puis choisir 1,5. | L’interligne courant est matérialisé ; le paragraphe complet adopte 1,5. |
| 8 | Ouvrir Opacité, relever le choix courant puis choisir 75 %. | L’opacité courante est matérialisée ; toute la zone passe à 75 %. |
| 9 | Presser Terminer, sélectionner la zone sur la page puis parcourir son inspecteur Texte. | Police, Taille, Gras, Italique, Couleur, Alignement, Interligne et Opacité y matérialisent aussi leur valeur active, cohérente avec l’éditeur. |
| 10 | Fermer proprement puis rouvrir l’album et la même zone. | Arrondie, Italique, Taille 36, Rouge, Centré, Interligne 1,5 et Opacité 75 % persistent avec leurs portées respectives. |
| 11 | Avec VoiceOver, parcourir les huit actions de format dans l’éditeur puis dans l’inspecteur. | Chaque commande annonce son libellé, sa valeur et son état actif sans dépendre uniquement d’une couleur. |

- Résultat : 🟢 `RÉUSSI`. Les onze étapes sont déclarées conformes globalement.
  Le retour demande néanmoins de réduire la largeur des boutons de format :
  l’ajout de la valeur courante dans leur libellé principal leur fait occuper
  trop de place. Cette évolution future est enregistrée sous `3:TBX-027` et ne
  contredit aucune attente dimensionnelle de la présente fiche.
- Preuve : retour utilisateur « c’est ok pour les 2 tests » reçu le 20 août
  2026 après désignation explicite de `IPAD-L2-034` et `035`, sans capture ni
  détail distinct par étape.
- Environnement : repris de `IPAD-L2-034`, en paysage puis avec VoiceOver à
  l’étape 11 selon la procédure. Aucun résultat du candidat Info `6093058…`
  n’est extrapolé.

## Régressions du candidat Info et texte

Les trois fiches suivantes visent exactement le candidat
`60930587da16707dbb57eada9881f6fefcedd51e`. Télécharger l’archive de ce commit
précis afin que Git remplace le marqueur `export-subst`; ne pas utiliser le ZIP
d’une branche ayant avancé. Elles remplacent `IPAD-L2-034…035` uniquement pour
ce nouveau candidat et réutilisent l’album Texte-A.

### `IPAD-L2-036` — Info, version et commit exact du candidat

- Candidat : `60930587da16707dbb57eada9881f6fefcedd51e`.
- Préconditions : télécharger ou produire l’archive Git de ce commit exact,
  ouvrir son `Albumzh.swiftpm` dans Swift Playgrounds sans modifier les sources
  et conserver l’album Texte-A.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:APP-001`, `3:APP-012`,
  `3:ACC-001` à `3:ACC-004`, `3:ACC-008` et `3:DONE-005`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler, lancer le candidat et attendre l’affichage de la Bibliothèque en portrait. | La compilation et le lancement réussissent ; les albums existants sont conservés et la Bibliothèque reste l’écran racine. |
| 2 | Repérer puis toucher Info dans la barre principale. | Le bouton Info est visible, possède l’icône d’information, répond au toucher et ouvre une fiche lisible. |
| 3 | Lire les valeurs Version et Commit. | Version affiche `0.1.0 (1)` et Commit affiche exactement `60930587da16707dbb57eada9881f6fefcedd51e`, jamais `Non estampillé`. |
| 4 | Sélectionner le hash, le copier, puis presser Fermer. | Les 40 caractères sont sélectionnables et copiables ; Fermer revient à la Bibliothèque sans modifier les albums. |
| 5 | Refaire l’ouverture en paysage avec une grande taille de texte puis parcourir la fiche avec VoiceOver. | La fiche reste lisible sans contenu inaccessible ; Info, Version, Commit, le hash et Fermer sont annoncés sans dépendre de la seule icône. |

- Résultat : 🔴 `ÉCHOUÉ`. L’étape 3 échoue : la valeur Commit affiche
  `Non estampillé` au lieu de
  `60930587da16707dbb57eada9881f6fefcedd51e`. Le reste est déclaré conforme
  globalement ; la sélection et la copie du hash demandées à l’étape 4 ne
  peuvent toutefois pas être considérées comme prouvées puisque les 40
  caractères ne sont pas affichés.
- Preuve : retour utilisateur « le num du commit n'est pas indiqué, il y a
  écrit \"non estampillé\" ; sinon le reste est ok » reçu le 20 août 2026,
  sans capture ni détail distinct par étape.
- Environnement : campagne déclarée sur l’iPad 8e génération, iPadOS 26.5.2,
  Swift Playgrounds 4.7 ; les orientations et VoiceOver prévus par la fiche ne
  sont pas redéclarés séparément dans ce retour.

### `IPAD-L2-037` — Motifs strictement bornés sur le candidat Info

- Candidat : `60930587da16707dbb57eada9881f6fefcedd51e`.
- Préconditions : après `IPAD-L2-036`, ouvrir l’album Texte-A en portrait et
  retrouver sa zone « Bonjour jpgqy ». Disposer des trois motifs intégrés et
  d’une couleur unie.
- Exigences : `3:CAN-003`, `3:BG-007`, `3:TBX-024` et `3:TBX-025`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Appliquer le motif Classique spirale à la page, ouvrir « Bonjour jpgqy », saisir quelques caractères puis ouvrir Couleur. | Le motif reste strictement dans le fond de la zone d’édition ; texte, barre, palette et boutons restent visibles et tactiles. |
| 2 | Remplacer le fond par Voyage kraft et refaire le contrôle de l’étape 1. | Le motif reste derrière l’éditeur sans couche blanche, débordement ni interception tactile. |
| 3 | Remplacer le fond par Minimal sombre et refaire le contrôle de l’étape 1. | Le motif reste derrière l’éditeur ; le texte et toutes les commandes conservent leur contraste et leur toucher. |
| 4 | Alterner chacun des trois motifs avec une couleur unie, puis terminer l’édition. | Aucun fond ne recouvre l’éditeur pendant les transitions ; la couleur unie et les trois motifs restent correctement bornés. |

- Résultat : 🟢 `RÉUSSI`. Les quatre étapes sont déclarées conformes
  globalement.
- Preuve : retour utilisateur « IPAD-L2-037 ok » reçu le 20 août 2026, sans
  capture ni détail distinct par étape.
- Environnement : repris de `IPAD-L2-036`, portrait selon la procédure ; aucune
  différence réelle n’est redéclarée.

### `IPAD-L2-038` — Arrondie, italique et choix actifs sur le candidat Info

- Candidat : `60930587da16707dbb57eada9881f6fefcedd51e`.
- Préconditions : partir de l’état final de `IPAD-L2-037`, revenir sur une
  couleur unie, ouvrir « Bonjour jpgqy » en paysage, sélectionner seulement
  « Bonjour » et masquer le clavier en conservant la sélection.
- Exigences : `3:TBX-009` à `3:TBX-016`, `3:TBX-023`, `3:TBX-024`,
  `3:TBX-026`, `3:SAV-001`, `3:ACC-002` et `3:ACC-004`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ouvrir Police, vérifier Système, puis choisir Arrondie. | La police courante porte une coche ou un état distinct et accessible ; Arrondie devient nettement différente de Système sur « Bonjour » seulement. |
| 2 | Ouvrir Italique, l’activer, le désactiver puis le réactiver. | L’état actif est visible ; Arrondie s’incline à chaque activation et revient droite à chaque désactivation sans modifier « jpgqy ». |
| 3 | Ouvrir Taille, relever le choix courant puis choisir 36. | La taille courante est matérialisée avant et après le choix ; seule la sélection passe à 36. |
| 4 | Ouvrir Gras, l’activer puis le désactiver. | L’état Gras est matérialisé à l’activation et disparaît à la désactivation ; seule la sélection change. |
| 5 | Ouvrir Couleur, relever le choix courant puis choisir Rouge. | La couleur courante est indiquée autrement que par sa seule teinte ; seule la sélection devient rouge. |
| 6 | Ouvrir Alignement, relever le choix courant puis choisir Centré. | L’alignement courant est matérialisé ; le paragraphe complet est centré. |
| 7 | Ouvrir Interligne, relever le choix courant puis choisir 1,5. | L’interligne courant est matérialisé ; le paragraphe complet adopte 1,5. |
| 8 | Ouvrir Opacité, relever le choix courant puis choisir 75 %. | L’opacité courante est matérialisée ; toute la zone passe à 75 %. |
| 9 | Presser Terminer, sélectionner la zone sur la page puis parcourir son inspecteur Texte. | Police, Taille, Gras, Italique, Couleur, Alignement, Interligne et Opacité y matérialisent aussi leur valeur active, cohérente avec l’éditeur. |
| 10 | Fermer proprement puis rouvrir l’album et la même zone. | Arrondie, Italique, Taille 36, Rouge, Centré, Interligne 1,5 et Opacité 75 % persistent avec leurs portées respectives. |
| 11 | Avec VoiceOver, parcourir les huit actions de format dans l’éditeur puis dans l’inspecteur. | Chaque commande annonce son libellé, sa valeur et son état actif sans dépendre uniquement d’une couleur. |

- Résultat : 🟢 `RÉUSSI`. Les onze étapes sont déclarées conformes
  globalement.
- Preuve : retour utilisateur saisi avec un backtick parasite entre `03` et
  `8`, puis « ok », reçu le 20 août 2026 et interprété comme `IPAD-L2-038`,
  seul identifiant correspondant, sans capture ni détail distinct par étape.
- Environnement : repris de `IPAD-L2-037`, paysage puis VoiceOver à l’étape 11
  selon la procédure ; aucune différence réelle n’est redéclarée.

## Campagne finale fonctionnelle du Lot 2 — Info exclue

> **ARCHIVE — NE PLUS EXÉCUTER.** `IPAD-L2-039` a échoué à la compilation sur
> le candidat ci-dessous et `040…054` n’ont pas été exécutés sur ce candidat.
> Les procédures actives sont leurs remplacements `055…070`. Tout retour saisi
> avec un ancien libellé sur le paquet corrigé doit être reporté sur l’ID `+16`
> sans modifier ce bloc historique.

Les fiches `IPAD-L2-039…054` visent exactement le commit fonctionnel
`fce5d92879a5a654778b02ec17a3707590554cd7`. À la demande de l’utilisateur,
elles ne retestent ni la valeur Commit ni sa copie : un checkout direct par
Working Copy est donc accepté même si Info indique `Non estampillé`. Ce choix
ne change pas le verdict historique de `IPAD-L2-036`.

Le jeu partagé est l’album `Lot2-Final`, en français, avec trois pages et au
moins quatre photos déjà importées depuis les fixtures non personnelles de
`docs/test-fixtures/photos`. La page 1 reçoit le texte et les premiers
stickers ; la page 2 sert aux copies et aux cadres ; la page 3 reste disponible
pour les portées Album. Chaque fiche réutilise l’état final de la précédente.
Si une fiche échoue, arrêter cette fiche au premier défaut, conserver l’album
et exécuter les autres avec leur précondition minimale lorsqu’elle reste
atteignable.

### `IPAD-L2-039` — Compilation, lancement et surface finale Lot 2

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : récupérer exactement ce commit avec Working Copy, ouvrir
  `Albumzh.swiftpm` sans modifier les sources et conserver les données 3.0.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:EDT-001`, `3:EDT-002`,
  `3:EDT-006`, `3:EDT-012`, `3:EDT-021`, `3:DONE-005`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler puis lancer l’application en plein écran et attendre la Bibliothèque. | La compilation et le lancement réussissent sans erreur ; les albums 3.0 existants restent lisibles. |
| 2 | Ouvrir un album existant puis revenir à la Bibliothèque. | L’éditeur et le retour fonctionnent sans perte, gel ni alerte de catalogue. |
| 3 | Créer ou ouvrir `Lot2-Final`, obtenir trois pages et répartir au moins quatre photos dans des cadres sur les trois pages. | L’album partagé est disponible ; chaque page reste éditable et aucune photo originale n’est modifiée. |
| 4 | Parcourir le rail en portrait. | Les entrées sont, dans l’ordre, Photos, Texte, Stickers, une séparation sans titre, Mise en page, Fonds, Cadres et formes. |
| 5 | Sélectionner successivement chaque panneau, puis une photo avant Cadres et formes. | Chaque panneau s’ouvre ; Stickers affiche des miniatures ; Cadres et formes devient utilisable pour le cadre photo sélectionné. |
| 6 | Tourner en paysage puis revenir en portrait. | Le canevas, le rail, le panneau et l’inspecteur restent accessibles sans chevauchement bloquant ni sélection perdue. |

- Résultat : 🔴 `ÉCHOUÉ` à l’étape 1 ; étapes 2 à 6 non exécutées.
- Preuve : diagnostic transmis par l’utilisateur : « The compiler is unable to
  type-check this expression in reasonable time; try breaking up the expression
  into distinct sub-expressions », dans `AppModel` ligne 256 ; aucune capture.
- Environnement : repris de la campagne — iPad 8e génération, iPadOS 26.5.2,
  Swift Playgrounds 4.7 ; mode de transfert, orientation et lieu non redéclarés.

### `IPAD-L2-040` — Boutons texte compacts et justification de page

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : état final de `IPAD-L2-039`, page 1 avec assez d’espace pour
  une zone de texte sur deux paragraphes.
- Exigences : `3:TBX-009` à `3:TBX-016`, `3:TBX-023` à `3:TBX-027`,
  `3:CAN-008`, `3:ACC-002`, `3:ACC-004`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ajouter une zone et saisir deux paragraphes assez longs pour occuper plusieurs lignes. | Le texte est lisible, centré initialement et sa hauteur s’adapte sans rogner les descendantes. |
| 2 | Examiner la barre de format en portrait puis en paysage. | Les libellés principaux restent courts : Police, Taille, Couleur, Alignement, Interligne et Opacité ; ils ne s’élargissent pas avec leur valeur. |
| 3 | Sélectionner le premier paragraphe, choisir Justifié et un interligne de 1,5, puis mettre quelques caractères en gras et en couleur. | L’alignement et l’interligne concernent le paragraphe ; les styles de caractères concernent seulement la sélection ; chaque valeur active est cochée ou sélectionnée. |
| 4 | Presser Terminer et observer la zone sur la page. | Le premier paragraphe est effectivement justifié ; le second conserve son alignement ; aucun caractère n’est déformé ou tronqué. |
| 5 | Ouvrir l’inspecteur de la zone puis Prévisualiser. | L’inspecteur garde les libellés compacts et les valeurs accessibles ; le rendu de page et la prévisualisation ont la même justification, les mêmes styles et la même géométrie. |
| 6 | Revenir en édition et parcourir les formats avec VoiceOver. | Chaque commande annonce son libellé court, sa valeur active et sa portée sans dépendre uniquement de la couleur. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — texte utilisé, portrait/paysage et éventuelle capture
  comparative page/prévisualisation.
- Environnement : repris de `IPAD-L2-039`, différences à renseigner.

### `IPAD-L2-041` — Sessions de frappe, Annuler et historique à 750 ms

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : page 1, aucune autre commande en cours ; conserver une zone
  de texte simple appelée ci-dessous « Séquence ».
- Exigences : `3:TBX-002` à `3:TBX-005`, `3:TBX-022`, `3:TBX-025`,
  `3:UND-001`, `3:UND-008`, `3:SAV-001`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ajouter une zone, remplacer l’indication par `Séquence alpha`, attendre au moins une seconde, saisir ` bêta`, puis Terminer. | Deux séquences séparées par plus de 750 ms sont enregistrées sans doublon ; le texte final est `Séquence alpha bêta`. |
| 2 | Presser Annuler une fois dans l’éditeur d’album. | Seule la dernière séquence ` bêta` disparaît ; `Séquence alpha` reste. |
| 3 | Presser Annuler une seconde fois puis Rétablir deux fois. | La séquence précédente est annulée séparément, puis les deux états reviennent dans le bon ordre. |
| 4 | Modifier le texte et plusieurs styles, masquer le clavier, puis presser Annuler dans la fenêtre de modification. | Le contenu, les styles, l’opacité et la géométrie retrouvent exactement l’état à l’ouverture de la fenêtre. |
| 5 | Ajouter une nouvelle zone puis quitter avec Annuler sans remplacer `Votre texte`. | La zone provisoire est supprimée et ne crée aucune action ou donnée visible résiduelle. |
| 6 | Fermer proprement l’album, le rouvrir et relire « Séquence ». | Le dernier état rétabli est durable et l’historique n’a produit ni texte dupliqué ni état partiel. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — chronologie approximative des pauses et contenu après
  chaque Annuler/Rétablir.
- Environnement : repris de `IPAD-L2-039`, différences à renseigner.

### `IPAD-L2-042` — Limite et collage riche filtré

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : préparer dans Notes un extrait comprenant du gras, de
  l’italique, une URL, une liste et une image jointe, ainsi qu’un texte séparé
  de plus de 1 000 caractères ; ouvrir une nouvelle zone page 1.
- Exigences : `3:TBX-006` à `3:TBX-008`, `3:TBX-010`, `3:TBX-017`,
  `3:TBX-023`, `3:CLP-005`, `3:ACC-002`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Coller l’extrait riche de Notes dans la zone. | Le texte est conservé ; le gras et l’italique pris en charge restent appliqués ; liste, métadonnées et lien actif sont retirés. |
| 2 | Examiner l’emplacement de l’image et toucher l’URL. | Aucune image, pièce jointe ni caractère de remplacement n’apparaît ; l’URL reste du texte et n’ouvre rien. |
| 3 | Vérifier les formats puis Terminer et rouvrir la zone. | Seuls les runs et paragraphes pris en charge persistent ; aucune commande de liste, tableau, pièce jointe ou style Notes n’est proposée. |
| 4 | Dans une autre zone neuve, coller le texte de plus de 1 000 caractères. | Le compteur s’arrête exactement à `1 000 / 1 000 caractères`, la limite est annoncée et seuls les caractères excédentaires sont refusés. |
| 5 | Tenter d’ajouter un caractère, puis supprimer dix caractères et en saisir cinq. | L’ajout au maximum est refusé ; les suppressions restent possibles ; cinq nouveaux caractères sont ensuite acceptés sans dépasser 1 000. |
| 6 | Terminer, fermer puis rouvrir l’album. | Le contenu filtré et le contenu borné persistent exactement, sans image cachée ni troncature supplémentaire. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — contenu source anonymisé, compteur observé et styles
  conservés ou perdus.
- Environnement : repris de `IPAD-L2-039`, version de Notes à renseigner.

### `IPAD-L2-043` — Débordement et blocage de la prévisualisation

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : page 1 avec une zone contenant plusieurs lignes ; mode Créer.
- Exigences : `3:TBX-018` à `3:TBX-021`, `3:TBX-024`, `3:CAN-008`,
  `3:ACC-002`, `3:ACC-006`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Redimensionner manuellement la zone pour rendre son contenu trop grand. | La boîte change sans modifier la taille de police ; un contour rouge, une icône et une explication accessible signalent le débordement. |
| 2 | Choisir Prévisualiser. | La prévisualisation est refusée ; l’application revient sur la page et sélectionne la première zone en défaut avec un message explicite. |
| 3 | Agrandir la boîte jusqu’à supprimer le débordement sans changer le texte. | L’alerte disparaît dès que tous les caractères tiennent ; aucun caractère n’a été supprimé silencieusement. |
| 4 | Prévisualiser puis comparer le texte à la page et à la miniature de la vue globale. | Les trois rendus conservent contenu, styles, justification, opacité, rotation et géométrie ; les poignées et alertes d’édition sont absentes de la prévisualisation. |
| 5 | Revenir en mode Créer. | La page et la sélection d’origine sont restaurées sans mutation du texte. |

- Résultat : ⚪ `NON TESTÉ`. La commande Exporter n’est pas publique dans ce
  candidat et sera testée avec un nouvel identifiant au Lot 3.
- Preuve : à renseigner — message de blocage et comparaison des trois rendus.
- Environnement : repris de `IPAD-L2-039`, différences à renseigner.

### `IPAD-L2-044` — Catalogue, catégories, recherche et récents des stickers

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : page 1 en mode Créer ; panneau Stickers ouvert ; aucun
  remplacement de sticker en cours.
- Exigences : `3:STK-001` à `3:STK-003`, `3:STK-006`, `3:STK-009` à
  `3:STK-012`, `3:CAT-001`, `3:CAT-009`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Parcourir Récents puis Voyage, Transport, Nature, Météo et Symboles. | La bande horizontale et la grille restent utilisables ; chaque catégorie contient huit stickers statiques, soit quarante au total. |
| 2 | Observer noms et miniatures de plusieurs stickers de chaque catégorie. | Chaque tuile possède un nom français et une miniature nette à fond transparent ; aucun logo, personnage connu ou asset Photoweb n’apparaît. |
| 3 | Rechercher successivement `etoile`, `pluie` et un tag visible ou annoncé. | La recherche ignore casse et accents, interroge noms et tags et ne montre que les résultats correspondants. |
| 4 | Rechercher une chaîne absente puis effacer la recherche. | `Aucun résultat` est affiché sans modifier la page ; effacer retrouve la catégorie ou les récents attendus. |
| 5 | Ajouter successivement trois stickers différents, puis réutiliser le premier et ouvrir Récents. | Récents place le premier en tête, ne le duplique pas et conserve les identifiants distincts dans l’ordre du dernier usage. |
| 6 | Inspecter toutes les actions du panneau. | Aucun import, Mes stickers, détourage, création personnalisée ou contenu animé n’est proposé. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — catégories comptées, recherches et ordre de Récents.
- Environnement : repris de `IPAD-L2-039`, différences à renseigner.

### `IPAD-L2-045` — Ajout, dépôt et géométrie des stickers

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : état final de `IPAD-L2-044`, page 1 avec assez d’espace libre.
- Exigences : `3:STK-004`, `3:STK-005`, `3:STK-008`, `3:STK-015`,
  `3:STK-023`, `3:STK-024`, `3:ELM-001` à `3:ELM-004`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Toucher Appareil photo dans le catalogue. | Le sticker est ajouté au centre, au premier plan, sans rotation ni miroir, avec opacité 100 % et une plus grande dimension proche de 20 % du petit côté de page. |
| 2 | Faire glisser Ballon depuis le catalogue vers le quart supérieur gauche de la page. | Le sticker est déposé à la position choisie, entièrement sélectionnable, sans être recentré. |
| 3 | Déplacer, faire pivoter et redimensionner les deux stickers. | Les gestes concernent seulement le sticker sélectionné ; les proportions intrinsèques restent constantes et aucun visuel n’est recadré ni étiré. |
| 4 | Réduire progressivement un sticker jusqu’à la borne minimale. | Le redimensionnement s’arrête avant qu’une dimension passe sous 5 % du petit côté de page ; le sticker reste sélectionnable. |
| 5 | Changer de catégorie, lancer une recherche puis fermer et rouvrir le panneau. | Aucun sticker déjà placé ne change de position, taille, rotation, opacité, miroir ou profondeur. |
| 6 | Déplacer partiellement un sticker hors de page puis Prévisualiser. | Seule la partie hors page est rognée ; la partie visible conserve son alpha et son rapport sans bord opaque ajouté. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — stickers choisis, positions et toute déformation observée.
- Environnement : repris de `IPAD-L2-039`, glisser-déposer iPad requis.

### `IPAD-L2-046` — Remplacement et commandes d’un sticker

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : page 1 avec le Ballon de `IPAD-L2-045`, déplacé, tourné,
  retourné horizontalement et réglé à 60 % d’opacité.
- Exigences : `3:STK-007`, `3:STK-014` à `3:STK-016`, `3:STK-022`,
  `3:ELM-008`, `3:UND-001`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Sélectionner le Ballon et parcourir sa barre locale ou son inspecteur. | Remplacer, Opacité, Retourner horizontalement apparaissent dans cet ordre, puis Rotation, Dupliquer, Profondeur, Position et taille et Supprimer. |
| 2 | Presser Remplacer puis choisir un sticker de rapport très différent. | Le catalogue indique le mode remplacement ; le nouveau sticker garde centre, rotation, opacité, miroir et profondeur, adapte ses dimensions à son rapport et n’est ni recadré ni déformé. |
| 3 | Presser Annuler puis Rétablir. | Annuler restaure exactement le Ballon et sa transformation ; Rétablir remet exactement le remplacement. |
| 4 | Modifier l’opacité, retourner horizontalement deux fois et déplacer la profondeur. | Chaque commande est immédiatement visible, annoncée correctement et ne modifie aucune autre propriété. |
| 5 | Dupliquer le sticker, déplacer la copie puis supprimer l’original. | La copie possède un nouvel élément indépendant avec le même style initial ; seule la cible choisie se déplace ou disparaît. |
| 6 | Annuler puis rétablir la suppression. | Une action restaure uniquement l’original supprimé ; Rétablir le supprime à nouveau sans altérer la copie. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — ancien/nouveau sticker et état avant/après remplacement.
- Environnement : repris de `IPAD-L2-039`, différences à renseigner.

### `IPAD-L2-047` — Rendu, profondeur et persistance des stickers

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : page 1 contenant au moins une photo, une zone de texte et
  deux stickers qui se chevauchent partiellement.
- Exigences : `3:STK-009`, `3:STK-024`, `3:CAN-008`, `3:SAV-001`,
  `3:ACC-006`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Placer successivement un sticker derrière le texte, puis devant la photo avec Profondeur. | La pile commune respecte chaque commande ; aucun type d’élément n’est forcé devant les autres. |
| 2 | Comparer le sticker en mode Créer, vue globale et Prévisualiser. | Le même payload, son alpha, son opacité, son miroir, sa rotation, son rapport et son rognage de page sont rendus de façon cohérente. |
| 3 | Fermer proprement l’album, activer le mode avion, relancer et rouvrir page 1. | Les stickers réapparaissent hors ligne sans téléchargement, remplacement silencieux ni alerte de ressource. |
| 4 | Modifier un sticker hors ligne, sauvegarder, fermer puis rouvrir. | La modification persiste et les autres éléments restent inchangés. |
| 5 | Désactiver le mode avion. | Le retour du réseau ne remplace ni ne réordonne aucune ressource locale. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — comparaison des vues et comportement hors ligne.
- Environnement : repris de `IPAD-L2-039`, état réseau à consigner.

### `IPAD-L2-048` — Six formes et conservation du cadrage photo

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : page 2 avec un cadre photo non carré, rempli par une photo au
  point focal reconnaissable, dézoomée pour révéler un peu de transparence.
- Exigences : `3:SHR-001` à `3:SHR-003`, `3:SHR-006`, `3:SHR-010`,
  `3:SHR-012`, `3:CRP-001`, `3:CRP-007`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Sans sélection puis avec la photo sélectionnée, ouvrir Cadres et formes. | Le panneau demande d’abord une photo, puis affiche Portée, Forme, Contour et Cadre décoratif pour le cadre sélectionné. |
| 2 | Choisir successivement Aucun (rectangle), Rectangle arrondi, Cercle, Ovale, Cœur et Étoile. | Les six silhouettes sont distinctes et correctement fermées ; Cercle reste circulaire dans le cadre non carré tandis qu’Ovale touche ses quatre limites. |
| 3 | Revenir à Cœur et comparer le contenu au cadrage de départ. | Le point focal, l’échelle native, l’orientation et le retournement sont inchangés ; aucun zoom correctif ne remplit automatiquement le nouveau masque. |
| 4 | Choisir Étoile puis Prévisualiser. | Les branches découpent la photo proprement et les zones sans pixel restent transparentes sur le fond. |
| 5 | Choisir Aucun (rectangle). | La forme revient exactement au rectangle procédural ; aucune autre propriété du cadre ou de la photo ne change. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — photos des six formes et cadrage reconnaissable.
- Environnement : repris de `IPAD-L2-039`, différences à renseigner.

### `IPAD-L2-049` — Contours et six cadres décoratifs

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : page 2 avec deux cadres remplis de rapports différents ; le
  premier porte une forme arrondie, le second reste rectangulaire.
- Exigences : `3:SHR-004`, `3:SHR-005`, `3:SHR-009`, `3:SHR-011`,
  `3:SHR-013`, `3:SHR-014`, `3:CAN-008`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Régler un contour coloré à une épaisseur visible puis parcourir toute sa plage. | L’épaisseur varie de 0 à 3 % ; le contour reste entièrement à l’intérieur du masque, au-dessus de la photo, sans agrandir le cadre. |
| 2 | Choisir une autre couleur puis presser Aucun. | La couleur réelle et son état sélectionné sont visibles ; Aucun retire le contour sans modifier masque, cadre décoratif ou cadrage. |
| 3 | Parcourir Aucun, Bord blanc, Bord noir, Ruban kraft, Tampon voyage, Feuillage et Photo instantanée. | Les six cadres possèdent une miniature et un rendu distincts ; un seul cadre décoratif est actif à la fois. |
| 4 | Appliquer le même cadre décoratif aux deux rapports de cadre. | Les coins gardent leur dessin, les bords s’étirent dans leur axe et le centre ne recouvre pas anormalement la photo. |
| 5 | Comparer page, vue globale et Prévisualiser avec masque, contour et cadre combinés. | L’ordre est photo masquée, contour intérieur puis cadre décoratif ; le rendu relatif reste cohérent dans les trois vues. |
| 6 | Choisir Aucun dans Cadre décoratif. | Seul le cadre décoratif disparaît ; masque, contour, photo et cadrage persistent. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — cadres essayés et comparaison entre deux rapports.
- Environnement : repris de `IPAD-L2-039`, différences à renseigner.

### `IPAD-L2-050` — Portées Sélection, Page et Album

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : les trois pages de `Lot2-Final` contiennent ensemble au moins
  quatre cadres photo, dont deux sur la page 2 ; aucun ne porte le même trio de
  styles au départ.
- Exigences : `3:SHR-007`, `3:SHR-008`, `3:UND-001`, `3:SAV-001`,
  `3:ACC-002`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Choisir Portée Sélection puis appliquer Cœur au cadre actif. | La description annonce un cadre ; seul le cadre sélectionné change et une seule action Annuler restaure son état. |
| 2 | Choisir Portée Page puis appliquer un contour rouge visible. | Le nombre annoncé correspond aux cadres de la page 2 ; tous et seulement ceux-ci reçoivent le contour sans changement de géométrie ou cadrage. |
| 3 | Presser Annuler puis Rétablir une fois. | Une seule commande retire puis remet simultanément tous les contours de la page. |
| 4 | Choisir Portée Album puis appliquer Bord blanc. | Le nombre annoncé correspond à tous les cadres des trois pages ; chaque cadre reçoit le style sans modifier photo, point focal, zoom, orientation ou ordre. |
| 5 | Presser Annuler une fois puis parcourir les trois pages. | Le cadre décoratif est retiré partout en une seule action et les styles antérieurs indépendants sont restaurés. |
| 6 | Rétablir, sauvegarder, fermer puis rouvrir l’album. | L’application Album complète persiste exactement sur les trois pages. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — nombres annoncés, pages affectées et historique.
- Environnement : repris de `IPAD-L2-039`, différences à renseigner.

### `IPAD-L2-051` — Copier et coller photo, texte et sticker

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : page 1 avec une photo cadrée et stylée, le texte justifié de
  `IPAD-L2-040` et un sticker transformé ; page 2 disponible.
- Exigences : `3:CLP-001`, `3:CLP-003`, `3:CLP-004`, `3:ELM-009`,
  `3:FRM-007`, `3:SAV-001`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Copier la photo puis Coller sur la même page. | Une nouvelle occurrence apparaît légèrement décalée et au-dessus de la source, avec le même asset, cadrage, masque, contour et cadre décoratif. |
| 2 | Recadrer seulement la copie puis comparer l’original. | Le cadrage de la copie devient indépendant ; l’original et le fichier source ne changent pas. |
| 3 | Copier le texte, aller page 2 puis Coller. | Un nouvel identifiant est créé au premier plan avec contenu, runs, paragraphes, opacité, rotation et boîte identiques. |
| 4 | Copier le sticker transformé, rester page 2 puis Coller. | Le nouveau sticker conserve ressource, rapport, opacité, miroir, rotation et taille, avec un placement distinct. |
| 5 | Modifier puis supprimer chacune des copies. | Les sources de page 1 restent inchangées ; aucune copie ne partage un état mutable avec sa source. |
| 6 | Sans nouvelle copie compatible après réouverture de l’éditeur, observer Coller. | Coller reste désactivé et aucune donnée externe arbitraire n’est interprétée comme élément. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — source/copie de chaque type et indépendance observée.
- Environnement : repris de `IPAD-L2-039`, différences à renseigner.

### `IPAD-L2-052` — Couper, annuler et invalider le presse-papiers

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : page 2 avec au moins un sticker, un texte et une photo ;
  aucune commande asynchrone en cours.
- Exigences : `3:CLP-002`, `3:CLP-004`, `3:CLP-006`, `3:UND-001`,
  `3:UND-002`, `3:SAV-001`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Sélectionner un sticker puis Couper. | Le sticker est copié et supprimé atomiquement ; Coller devient disponible. |
| 2 | Presser Annuler une fois puis Rétablir une fois. | Une seule action restaure le sticker ; une seule action le retire de nouveau sans modifier le presse-papiers de façon incohérente. |
| 3 | Coller puis annuler le collage. | Un nouvel élément est créé, puis une seule action retire uniquement cet élément. |
| 4 | Copier un texte, fermer l’éditeur jusqu’à la Bibliothèque, puis rouvrir le même album. | Le presse-papiers privé est invalidé à la fermeture ; Coller est désactivé et ne se réactive pas au retour. |
| 5 | Copier une photo, placer l’application en arrière-plan, revenir puis attendre la recharge. | La sauvegarde reste cohérente et le presse-papiers privé est invalidé ; Coller est désactivé. |
| 6 | Copier un élément, fermer l’album, ouvrir un autre album puis revenir à `Lot2-Final`. | Aucun collage interalbum n’est possible et le contenu privé ne ressuscite pas dans l’album source. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — disponibilité de Coller à chaque transition et état
  des éléments après Annuler/Rétablir.
- Environnement : repris de `IPAD-L2-039`, transitions d’arrière-plan à noter.

### `IPAD-L2-053` — Aide et accessibilité du périmètre Lot 2

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : `Lot2-Final` contient photo, texte et sticker ; VoiceOver est
  disponible et la taille de texte peut être temporairement augmentée.
- Exigences : `3:EDT-019`, `3:STK-022`, `3:ACC-001` à `3:ACC-008`,
  `3:ACC-020`, `3:ACC-021`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ouvrir successivement Texte, Stickers et Cadres et formes, puis demander l’aide contextuelle depuis chacun. | L’aide s’ouvre directement sur la section correspondante et décrit les commandes réellement publiques, sans fonction Lot 3. |
| 2 | Activer VoiceOver et parcourir le rail, la recherche, trois tuiles sticker et la barre d’un sticker sélectionné. | Chaque contrôle annonce un nom, son rôle ou son état ; Remplacer, Opacité et Retourner horizontalement portent des libellés non ambigus. |
| 3 | Parcourir les six formes, les couleurs de contour, les six cadres et les trois portées. | Chaque choix annonce son nom et son état sélectionné ; la portée annonce le nombre de cadres concernés. |
| 4 | Parcourir une zone débordante puis une zone normale, une photo et un sticker superposés. | L’ordre accessible reste déterministe ; l’alerte de débordement, le type, la position et la profondeur utiles sont annoncés. |
| 5 | Passer à une grande taille de texte puis tourner portrait/paysage. | Les libellés restent lisibles ou défilables, les contrôles tactiles restent atteignables et aucune information ne dépend uniquement de la couleur ou d’une icône. |
| 6 | Désactiver VoiceOver et restaurer la taille de texte. | L’état de l’album et la sélection restent cohérents ; aucun format ni élément n’a été modifié par la navigation accessible. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — annonces VoiceOver ambiguës, taille de texte et
  orientation de chaque défaut éventuel.
- Environnement : repris de `IPAD-L2-039`, réglages d’accessibilité à consigner.

### `IPAD-L2-054` — Fluidité à vingt stickers et avertissement au-delà

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Préconditions : utiliser une nouvelle page de `Lot2-Final` ou vider la page 3
  de ses stickers ; relever approximativement les temps d’attente anormaux.
- Exigences : `3:STK-021`, `3:PERF-005`, `3:PERF-015`, `3:PERF-017`,
  `3:ACC-002`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ajouter exactement vingt stickers variés par pressions et dépôts. | Chaque ajout reste interactif, aucun sticker ne manque et aucun avertissement de dépassement n’est affiché à vingt. |
| 2 | Déplacer, tourner, redimensionner et changer l’opacité de plusieurs stickers, puis annuler/rétablir cinq actions. | Les gestes et commandes restent utilisables sans gel, perte d’entrée ni corruption de la pile. |
| 3 | Ouvrir la vue globale puis Prévisualiser et revenir en création. | Les vingt stickers sont rendus dans chaque vue ; la navigation et le retour restent réactifs. |
| 4 | Ajouter un vingt-et-unième sticker. | L’ajout réussit et un avertissement orange non bloquant indique que l’édition peut être moins fluide au-delà de vingt. |
| 5 | Continuer à déplacer un sticker puis en supprimer un pour revenir à vingt. | L’avertissement ne bloque aucune commande et disparaît lorsque le compte revient à vingt. |
| 6 | Sauvegarder, fermer, relancer et rouvrir la page. | Les vingt stickers et leurs transformations persistent ; le lancement et l’ouverture n’échouent pas faute de mémoire. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — nombre exact, gels ou latences visibles, éventuel
  redémarrage système et capture de l’avertissement.
- Environnement : repris de `IPAD-L2-039`, espace libre et état thermique à
  noter si un ralentissement est observé.


## Campagne corrigée du Lot 2 après `IPAD-L2-039`

Les fiches `IPAD-L2-055…070` visent exactement le correctif
`64f53424a0fc479c4fdea79c401d0b227d52eebd`. `055` remplace le contrôle de
compilation `039`; `056…070` remplacent les fiches fonctionnelles `040…054`,
qui restent attachées au candidat non compilable. Info demeure exclu et un
checkout Working Copy est accepté.

> **Campagne exécutée.** L’utilisateur a suivi les procédures avec les anciens
> libellés `039…054`. Les résultats ci-dessous sont enregistrés sur les IDs
> stables de remplacement `055…070` selon la correspondance `+16`. Les fiches
> `039…054` restent une archive du candidat rejeté et ne doivent plus être
> exécutées. Le retour global « tous les autres tests sont ok » prouve les
> fiches non signalées, sans capture ni détail par étape ; il ne permet pas de
> déclarer conformes les étapes non commentées à l’intérieur des quatre fiches
> en échec.

Le jeu partagé reste l’album `Lot2-Final`, en français, avec trois pages et au
moins quatre photos des fixtures `docs/test-fixtures/photos`. Chaque fiche
réutilise l’état final de la précédente. Si une fiche échoue, arrêter cette
fiche au premier défaut et poursuivre seulement lorsque sa précondition
minimale reste atteignable.

### `IPAD-L2-055` — Compilation, lancement et surface finale Lot 2

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : récupérer exactement ce commit avec Working Copy, ouvrir
  `Albumzh.swiftpm` sans modifier les sources et conserver les données 3.0.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:EDT-001`, `3:EDT-002`,
  `3:EDT-006`, `3:EDT-012`, `3:EDT-021`, `3:DONE-005`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler puis lancer l’application en plein écran et attendre la Bibliothèque. | La compilation et le lancement réussissent sans erreur ; les albums 3.0 existants restent lisibles. |
| 2 | Ouvrir un album existant puis revenir à la Bibliothèque. | L’éditeur et le retour fonctionnent sans perte, gel ni alerte de catalogue. |
| 3 | Créer ou ouvrir `Lot2-Final`, obtenir trois pages et répartir au moins quatre photos dans des cadres sur les trois pages. | L’album partagé est disponible ; chaque page reste éditable et aucune photo originale n’est modifiée. |
| 4 | Parcourir le rail en portrait. | Les entrées sont, dans l’ordre, Photos, Texte, Stickers, une séparation sans titre, Mise en page, Fonds, Cadres et formes. |
| 5 | Sélectionner successivement chaque panneau, puis une photo avant Cadres et formes. | Chaque panneau s’ouvre ; Stickers affiche des miniatures ; Cadres et formes devient utilisable pour le cadre photo sélectionné. |
| 6 | Tourner en paysage puis revenir en portrait. | Le canevas, le rail, le panneau et l’inspecteur restent accessibles sans chevauchement bloquant ni sélection perdue. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « tous les autres tests dans `039…054` sont ok »,
  fourni sous l’ancien libellé `039` et reporté sur `055` ; sans capture ni
  détail par étape.
- Environnement : iPad 8e génération, iPadOS 26.5.2, Swift Playgrounds 4.7 ;
  orientations prévues par la fiche, mode de transfert non redéclaré.

### `IPAD-L2-056` — Boutons texte compacts et justification de page

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : état final de `IPAD-L2-055`, page 1 avec assez d’espace pour
  une zone de texte sur deux paragraphes.
- Exigences : `3:TBX-009` à `3:TBX-016`, `3:TBX-023` à `3:TBX-027`,
  `3:CAN-008`, `3:ACC-002`, `3:ACC-004`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ajouter une zone et saisir deux paragraphes assez longs pour occuper plusieurs lignes. | Le texte est lisible, centré initialement et sa hauteur s’adapte sans rogner les descendantes. |
| 2 | Examiner la barre de format en portrait puis en paysage. | Les libellés principaux restent courts : Police, Taille, Couleur, Alignement, Interligne et Opacité ; ils ne s’élargissent pas avec leur valeur. |
| 3 | Sélectionner le premier paragraphe, choisir Justifié et un interligne de 1,5, puis mettre quelques caractères en gras et en couleur. | L’alignement et l’interligne concernent le paragraphe ; les styles de caractères concernent seulement la sélection ; chaque valeur active est cochée ou sélectionnée. |
| 4 | Presser Terminer et observer la zone sur la page. | Le premier paragraphe est effectivement justifié ; le second conserve son alignement ; aucun caractère n’est déformé ou tronqué. |
| 5 | Ouvrir l’inspecteur de la zone puis Prévisualiser. | L’inspecteur garde les libellés compacts et les valeurs accessibles ; le rendu de page et la prévisualisation ont la même justification, les mêmes styles et la même géométrie. |
| 6 | Revenir en édition et parcourir les formats avec VoiceOver. | Chaque commande annonce son libellé court, sa valeur active et sa portée sans dépendre uniquement de la couleur. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « tous les autres tests dans `039…054` sont ok »,
  fourni sous l’ancien libellé `040` et reporté sur `056` ; sans capture ni
  détail par étape.
- Environnement : repris de `IPAD-L2-055`, sans différence déclarée.

### `IPAD-L2-057` — Sessions de frappe, Annuler et historique à 750 ms

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : page 1, aucune autre commande en cours ; conserver une zone
  de texte simple appelée ci-dessous « Séquence ».
- Exigences : `3:TBX-002` à `3:TBX-005`, `3:TBX-022`, `3:TBX-025`,
  `3:UND-001`, `3:UND-008`, `3:SAV-001`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ajouter une zone, remplacer l’indication par `Séquence alpha`, attendre au moins une seconde, saisir ` bêta`, puis Terminer. | Deux séquences séparées par plus de 750 ms sont enregistrées sans doublon ; le texte final est `Séquence alpha bêta`. |
| 2 | Presser Annuler une fois dans l’éditeur d’album. | Seule la dernière séquence ` bêta` disparaît ; `Séquence alpha` reste. |
| 3 | Presser Annuler une seconde fois puis Rétablir deux fois. | La séquence précédente est annulée séparément, puis les deux états reviennent dans le bon ordre. |
| 4 | Modifier le texte et plusieurs styles, masquer le clavier, puis presser Annuler dans la fenêtre de modification. | Le contenu, les styles, l’opacité et la géométrie retrouvent exactement l’état à l’ouverture de la fenêtre. |
| 5 | Ajouter une nouvelle zone puis quitter avec Annuler sans remplacer `Votre texte`. | La zone provisoire est supprimée et ne crée aucune action ou donnée visible résiduelle. |
| 6 | Fermer proprement l’album, le rouvrir et relire « Séquence ». | Le dernier état rétabli est durable et l’historique n’a produit ni texte dupliqué ni état partiel. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « tous les autres tests dans `039…054` sont ok »,
  fourni sous l’ancien libellé `041` et reporté sur `057` ; sans capture ni
  détail par étape.
- Environnement : repris de `IPAD-L2-055`, sans différence déclarée.

### `IPAD-L2-058` — Limite et collage riche filtré

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : préparer dans Notes un extrait comprenant du gras, de
  l’italique, une URL, une liste et une image jointe, ainsi qu’un texte séparé
  de plus de 1 000 caractères ; ouvrir une nouvelle zone page 1.
- Exigences : `3:TBX-006` à `3:TBX-008`, `3:TBX-010`, `3:TBX-017`,
  `3:TBX-023`, `3:CLP-005`, `3:ACC-002`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Coller l’extrait riche de Notes dans la zone. | Le texte est conservé ; le gras et l’italique pris en charge restent appliqués ; liste, métadonnées et lien actif sont retirés. |
| 2 | Examiner l’emplacement de l’image et toucher l’URL. | Aucune image, pièce jointe ni caractère de remplacement n’apparaît ; l’URL reste du texte et n’ouvre rien. |
| 3 | Vérifier les formats puis Terminer et rouvrir la zone. | Seuls les runs et paragraphes pris en charge persistent ; aucune commande de liste, tableau, pièce jointe ou style Notes n’est proposée. |
| 4 | Dans une autre zone neuve, coller le texte de plus de 1 000 caractères. | Le compteur s’arrête exactement à `1 000 / 1 000 caractères`, la limite est annoncée et seuls les caractères excédentaires sont refusés. |
| 5 | Tenter d’ajouter un caractère, puis supprimer dix caractères et en saisir cinq. | L’ajout au maximum est refusé ; les suppressions restent possibles ; cinq nouveaux caractères sont ensuite acceptés sans dépasser 1 000. |
| 6 | Terminer, fermer puis rouvrir l’album. | Le contenu filtré et le contenu borné persistent exactement, sans image cachée ni troncature supplémentaire. |

- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : retour détaillé fourni sous l’ancien libellé `042` et reporté sur
  `058`, sans capture. Avec moins de 1 000 caractères, les éléments interdits
  sont supprimés mais le gras et l’italique disparaissent. Avec plus de 1 000
  caractères, l’alerte apparaît, mais son action Annuler ne restaure pas l’état
  antérieur au collage. Les autres étapes ne reçoivent pas de verdict détaillé.
- Environnement : repris de `IPAD-L2-055`, version de Notes non redéclarée.

### `IPAD-L2-059` — Débordement et blocage de la prévisualisation

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : page 1 avec une zone contenant plusieurs lignes ; mode Créer.
- Exigences : `3:TBX-018` à `3:TBX-021`, `3:TBX-024`, `3:CAN-008`,
  `3:ACC-002`, `3:ACC-006`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Redimensionner manuellement la zone pour rendre son contenu trop grand. | La boîte change sans modifier la taille de police ; un contour rouge, une icône et une explication accessible signalent le débordement. |
| 2 | Choisir Prévisualiser. | La prévisualisation est refusée ; l’application revient sur la page et sélectionne la première zone en défaut avec un message explicite. |
| 3 | Agrandir la boîte jusqu’à supprimer le débordement sans changer le texte. | L’alerte disparaît dès que tous les caractères tiennent ; aucun caractère n’a été supprimé silencieusement. |
| 4 | Prévisualiser puis comparer le texte à la page et à la miniature de la vue globale. | Les trois rendus conservent contenu, styles, justification, opacité, rotation et géométrie ; les poignées et alertes d’édition sont absentes de la prévisualisation. |
| 5 | Revenir en mode Créer. | La page et la sélection d’origine sont restaurées sans mutation du texte. |

- Résultat : 🟢 `RÉUSSI`. La commande Exporter n’est pas publique dans ce
  candidat et sera testée avec un nouvel identifiant au Lot 3.
- Preuve : retour global « tous les autres tests dans `039…054` sont ok »,
  fourni sous l’ancien libellé `043` et reporté sur `059` ; sans capture ni
  détail par étape.
- Environnement : repris de `IPAD-L2-055`, sans différence déclarée.

### `IPAD-L2-060` — Catalogue, catégories, recherche et récents des stickers

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : page 1 en mode Créer ; panneau Stickers ouvert ; aucun
  remplacement de sticker en cours.
- Exigences : `3:STK-001` à `3:STK-003`, `3:STK-006`, `3:STK-009` à
  `3:STK-012`, `3:CAT-001`, `3:CAT-009`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Parcourir Récents puis Voyage, Transport, Nature, Météo et Symboles. | La bande horizontale et la grille restent utilisables ; chaque catégorie contient huit stickers statiques, soit quarante au total. |
| 2 | Observer noms et miniatures de plusieurs stickers de chaque catégorie. | Chaque tuile possède un nom français et une miniature nette à fond transparent ; aucun logo, personnage connu ou asset Photoweb n’apparaît. |
| 3 | Rechercher successivement `etoile`, `pluie` et un tag visible ou annoncé. | La recherche ignore casse et accents, interroge noms et tags et ne montre que les résultats correspondants. |
| 4 | Rechercher une chaîne absente puis effacer la recherche. | `Aucun résultat` est affiché sans modifier la page ; effacer retrouve la catégorie ou les récents attendus. |
| 5 | Ajouter successivement trois stickers différents, puis réutiliser le premier et ouvrir Récents. | Récents place le premier en tête, ne le duplique pas et conserve les identifiants distincts dans l’ordre du dernier usage. |
| 6 | Inspecter toutes les actions du panneau. | Aucun import, Mes stickers, détourage, création personnalisée ou contenu animé n’est proposé. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « tous les autres tests dans `039…054` sont ok »,
  fourni sous l’ancien libellé `044` et reporté sur `060` ; sans capture ni
  détail par étape.
- Environnement : repris de `IPAD-L2-055`, sans différence déclarée.

### `IPAD-L2-061` — Ajout, dépôt et géométrie des stickers

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : état final de `IPAD-L2-060`, page 1 avec assez d’espace libre.
- Exigences : `3:STK-004`, `3:STK-005`, `3:STK-008`, `3:STK-015`,
  `3:STK-023`, `3:STK-024`, `3:ELM-001` à `3:ELM-004`, `3:COV-007`,
  `3:CAN-008`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Toucher Appareil photo dans le catalogue. | Le sticker est ajouté au centre, au premier plan, sans rotation ni miroir, avec opacité 100 % et une plus grande dimension proche de 20 % du petit côté de page. |
| 2 | Faire glisser Ballon depuis le catalogue vers le quart supérieur gauche de la page. | Le sticker est déposé à la position choisie, entièrement sélectionnable, sans être recentré. |
| 3 | Déplacer, faire pivoter et redimensionner les deux stickers. | Les gestes concernent seulement le sticker sélectionné ; les proportions intrinsèques restent constantes et aucun visuel n’est recadré ni étiré. |
| 4 | Réduire progressivement un sticker jusqu’à la borne minimale. | Le redimensionnement s’arrête avant qu’une dimension passe sous 5 % du petit côté de page ; le sticker reste sélectionnable. |
| 5 | Changer de catégorie, lancer une recherche puis fermer et rouvrir le panneau. | Aucun sticker déjà placé ne change de position, taille, rotation, opacité, miroir ou profondeur. |
| 6 | Déplacer partiellement un sticker hors de page puis Prévisualiser. | Seule la partie hors page est rognée ; la partie visible conserve son alpha et son rapport sans bord opaque ajouté. |

- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : retour détaillé fourni sous l’ancien libellé `045` et reporté sur
  `061`, sans capture. À l’étape 2, le sticker suit le doigt mais l’icône
  d’interdiction empêche son dépôt sur la page. Lorsqu’un sticker est réduit,
  les huit poignées et la commande de rotation masquent presque entièrement le
  visuel sélectionné ; il réapparaît après désélection. Un sticker placé est
  aussi absent de la miniature d’album, ce qui constitue un écart distinct à
  `3:COV-007` et `3:CAN-008`, et non un comportement voulu. Les autres étapes
  ne reçoivent pas de verdict détaillé.
- Environnement : repris de `IPAD-L2-055`, glisser-déposer exécuté sur iPad.

### `IPAD-L2-062` — Remplacement et commandes d’un sticker

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : page 1 avec le Ballon de `IPAD-L2-061`, déplacé, tourné,
  retourné horizontalement et réglé à 60 % d’opacité.
- Exigences : `3:STK-007`, `3:STK-014` à `3:STK-016`, `3:STK-022`,
  `3:ELM-008`, `3:UND-001`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Sélectionner le Ballon et parcourir sa barre locale ou son inspecteur. | Remplacer, Opacité, Retourner horizontalement apparaissent dans cet ordre, puis Rotation, Dupliquer, Profondeur, Position et taille et Supprimer. |
| 2 | Presser Remplacer puis choisir un sticker de rapport très différent. | Le catalogue indique le mode remplacement ; le nouveau sticker garde centre, rotation, opacité, miroir et profondeur, adapte ses dimensions à son rapport et n’est ni recadré ni déformé. |
| 3 | Presser Annuler puis Rétablir. | Annuler restaure exactement le Ballon et sa transformation ; Rétablir remet exactement le remplacement. |
| 4 | Modifier l’opacité, retourner horizontalement deux fois et déplacer la profondeur. | Chaque commande est immédiatement visible, annoncée correctement et ne modifie aucune autre propriété. |
| 5 | Dupliquer le sticker, déplacer la copie puis supprimer l’original. | La copie possède un nouvel élément indépendant avec le même style initial ; seule la cible choisie se déplace ou disparaît. |
| 6 | Annuler puis rétablir la suppression. | Une action restaure uniquement l’original supprimé ; Rétablir le supprime à nouveau sans altérer la copie. |

- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : retour détaillé fourni sous l’ancien libellé `046` et reporté sur
  `062`, sans capture. À l’étape 2, l’indication de choix n’a pas la même
  présentation que celle du remplacement photo et le sticker choisi s’ajoute
  à la page au lieu de remplacer l’ancien. Les autres étapes ne reçoivent pas
  de verdict détaillé.
- Environnement : repris de `IPAD-L2-055`, sans différence déclarée.

### `IPAD-L2-063` — Rendu, profondeur et persistance des stickers

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : page 1 contenant au moins une photo, une zone de texte et
  deux stickers qui se chevauchent partiellement.
- Exigences : `3:STK-009`, `3:STK-024`, `3:CAN-008`, `3:SAV-001`,
  `3:ACC-006`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Placer successivement un sticker derrière le texte, puis devant la photo avec Profondeur. | La pile commune respecte chaque commande ; aucun type d’élément n’est forcé devant les autres. |
| 2 | Comparer le sticker en mode Créer, vue globale et Prévisualiser. | Le même payload, son alpha, son opacité, son miroir, sa rotation, son rapport et son rognage de page sont rendus de façon cohérente. |
| 3 | Fermer proprement l’album, activer le mode avion, relancer et rouvrir page 1. | Les stickers réapparaissent hors ligne sans téléchargement, remplacement silencieux ni alerte de ressource. |
| 4 | Modifier un sticker hors ligne, sauvegarder, fermer puis rouvrir. | La modification persiste et les autres éléments restent inchangés. |
| 5 | Désactiver le mode avion. | Le retour du réseau ne remplace ni ne réordonne aucune ressource locale. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « tous les autres tests dans `039…054` sont ok »,
  fourni sous l’ancien libellé `047` et reporté sur `063` ; sans capture ni
  détail par étape. L’absence du sticker dans la miniature de couverture,
  signalée avec `061`, n’était pas demandée dans cette fiche et reste un écart
  distinct à `3:COV-007` et `3:CAN-008`.
- Environnement : repris de `IPAD-L2-055`, état réseau non redéclaré.

### `IPAD-L2-064` — Six formes et conservation du cadrage photo

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : page 2 avec un cadre photo non carré, rempli par une photo au
  point focal reconnaissable, dézoomée pour révéler un peu de transparence.
- Exigences : `3:SHR-001` à `3:SHR-003`, `3:SHR-006`, `3:SHR-010`,
  `3:SHR-012`, `3:CRP-001`, `3:CRP-007`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Sans sélection puis avec la photo sélectionnée, ouvrir Cadres et formes. | Le panneau demande d’abord une photo, puis affiche Portée, Forme, Contour et Cadre décoratif pour le cadre sélectionné. |
| 2 | Choisir successivement Aucun (rectangle), Rectangle arrondi, Cercle, Ovale, Cœur et Étoile. | Les six silhouettes sont distinctes et correctement fermées ; Cercle reste circulaire dans le cadre non carré tandis qu’Ovale touche ses quatre limites. |
| 3 | Revenir à Cœur et comparer le contenu au cadrage de départ. | Le point focal, l’échelle native, l’orientation et le retournement sont inchangés ; aucun zoom correctif ne remplit automatiquement le nouveau masque. |
| 4 | Choisir Étoile puis Prévisualiser. | Les branches découpent la photo proprement et les zones sans pixel restent transparentes sur le fond. |
| 5 | Choisir Aucun (rectangle). | La forme revient exactement au rectangle procédural ; aucune autre propriété du cadre ou de la photo ne change. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « tous les autres tests dans `039…054` sont ok »,
  fourni sous l’ancien libellé `048` et reporté sur `064` ; sans capture ni
  détail par étape.
- Environnement : repris de `IPAD-L2-055`, sans différence déclarée.

### `IPAD-L2-065` — Contours et six cadres décoratifs

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : page 2 avec deux cadres remplis de rapports différents ; le
  premier porte une forme arrondie, le second reste rectangulaire.
- Exigences : `3:SHR-004`, `3:SHR-005`, `3:SHR-009`, `3:SHR-011`,
  `3:SHR-013`, `3:SHR-014`, `3:CAN-008`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Régler un contour coloré à une épaisseur visible puis parcourir toute sa plage. | L’épaisseur varie de 0 à 3 % ; le contour reste entièrement à l’intérieur du masque, au-dessus de la photo, sans agrandir le cadre. |
| 2 | Choisir une autre couleur puis presser Aucun. | La couleur réelle et son état sélectionné sont visibles ; Aucun retire le contour sans modifier masque, cadre décoratif ou cadrage. |
| 3 | Parcourir Aucun, Bord blanc, Bord noir, Ruban kraft, Tampon voyage, Feuillage et Photo instantanée. | Les six cadres possèdent une miniature et un rendu distincts ; un seul cadre décoratif est actif à la fois. |
| 4 | Appliquer le même cadre décoratif aux deux rapports de cadre. | Les coins gardent leur dessin, les bords s’étirent dans leur axe et le centre ne recouvre pas anormalement la photo. |
| 5 | Comparer page, vue globale et Prévisualiser avec masque, contour et cadre combinés. | L’ordre est photo masquée, contour intérieur puis cadre décoratif ; le rendu relatif reste cohérent dans les trois vues. |
| 6 | Choisir Aucun dans Cadre décoratif. | Seul le cadre décoratif disparaît ; masque, contour, photo et cadrage persistent. |

- Résultat : 🔴 `ÉCHOUÉ`.
- Preuve : retour détaillé fourni sous l’ancien libellé `049` et reporté sur
  `065`, sans capture. Les cadres décoratifs s’appliquent, mais leur décor
  reste en retrait du bord du cadre et laisse apparaître derrière lui les bords
  de la photo. Les autres étapes ne reçoivent pas de verdict détaillé.
- Environnement : repris de `IPAD-L2-055`, sans différence déclarée.

### `IPAD-L2-066` — Portées Sélection, Page et Album

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : les trois pages de `Lot2-Final` contiennent ensemble au moins
  quatre cadres photo, dont deux sur la page 2 ; aucun ne porte le même trio de
  styles au départ.
- Exigences : `3:SHR-007`, `3:SHR-008`, `3:UND-001`, `3:SAV-001`,
  `3:ACC-002`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Choisir Portée Sélection puis appliquer Cœur au cadre actif. | La description annonce un cadre ; seul le cadre sélectionné change et une seule action Annuler restaure son état. |
| 2 | Choisir Portée Page puis appliquer un contour rouge visible. | Le nombre annoncé correspond aux cadres de la page 2 ; tous et seulement ceux-ci reçoivent le contour sans changement de géométrie ou cadrage. |
| 3 | Presser Annuler puis Rétablir une fois. | Une seule commande retire puis remet simultanément tous les contours de la page. |
| 4 | Choisir Portée Album puis appliquer Bord blanc. | Le nombre annoncé correspond à tous les cadres des trois pages ; chaque cadre reçoit le style sans modifier photo, point focal, zoom, orientation ou ordre. |
| 5 | Presser Annuler une fois puis parcourir les trois pages. | Le cadre décoratif est retiré partout en une seule action et les styles antérieurs indépendants sont restaurés. |
| 6 | Rétablir, sauvegarder, fermer puis rouvrir l’album. | L’application Album complète persiste exactement sur les trois pages. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « tous les autres tests dans `039…054` sont ok »,
  fourni sous l’ancien libellé `050` et reporté sur `066` ; sans capture ni
  détail par étape.
- Environnement : repris de `IPAD-L2-055`, sans différence déclarée.

### `IPAD-L2-067` — Copier et coller photo, texte et sticker

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : page 1 avec une photo cadrée et stylée, le texte justifié de
  `IPAD-L2-056` et un sticker transformé ; page 2 disponible.
- Exigences : `3:CLP-001`, `3:CLP-003`, `3:CLP-004`, `3:ELM-009`,
  `3:FRM-007`, `3:SAV-001`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Copier la photo puis Coller sur la même page. | Une nouvelle occurrence apparaît légèrement décalée et au-dessus de la source, avec le même asset, cadrage, masque, contour et cadre décoratif. |
| 2 | Recadrer seulement la copie puis comparer l’original. | Le cadrage de la copie devient indépendant ; l’original et le fichier source ne changent pas. |
| 3 | Copier le texte, aller page 2 puis Coller. | Un nouvel identifiant est créé au premier plan avec contenu, runs, paragraphes, opacité, rotation et boîte identiques. |
| 4 | Copier le sticker transformé, rester page 2 puis Coller. | Le nouveau sticker conserve ressource, rapport, opacité, miroir, rotation et taille, avec un placement distinct. |
| 5 | Modifier puis supprimer chacune des copies. | Les sources de page 1 restent inchangées ; aucune copie ne partage un état mutable avec sa source. |
| 6 | Sans nouvelle copie compatible après réouverture de l’éditeur, observer Coller. | Coller reste désactivé et aucune donnée externe arbitraire n’est interprétée comme élément. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « tous les autres tests dans `039…054` sont ok »,
  fourni sous l’ancien libellé `051` et reporté sur `067` ; sans capture ni
  détail par étape.
- Environnement : repris de `IPAD-L2-055`, sans différence déclarée.

### `IPAD-L2-068` — Couper, annuler et invalider le presse-papiers

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : page 2 avec au moins un sticker, un texte et une photo ;
  aucune commande asynchrone en cours.
- Exigences : `3:CLP-002`, `3:CLP-004`, `3:CLP-006`, `3:UND-001`,
  `3:UND-002`, `3:SAV-001`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Sélectionner un sticker puis Couper. | Le sticker est copié et supprimé atomiquement ; Coller devient disponible. |
| 2 | Presser Annuler une fois puis Rétablir une fois. | Une seule action restaure le sticker ; une seule action le retire de nouveau sans modifier le presse-papiers de façon incohérente. |
| 3 | Coller puis annuler le collage. | Un nouvel élément est créé, puis une seule action retire uniquement cet élément. |
| 4 | Copier un texte, fermer l’éditeur jusqu’à la Bibliothèque, puis rouvrir le même album. | Le presse-papiers privé est invalidé à la fermeture ; Coller est désactivé et ne se réactive pas au retour. |
| 5 | Copier une photo, placer l’application en arrière-plan, revenir puis attendre la recharge. | La sauvegarde reste cohérente et le presse-papiers privé est invalidé ; Coller est désactivé. |
| 6 | Copier un élément, fermer l’album, ouvrir un autre album puis revenir à `Lot2-Final`. | Aucun collage interalbum n’est possible et le contenu privé ne ressuscite pas dans l’album source. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « tous les autres tests dans `039…054` sont ok »,
  fourni sous l’ancien libellé `052` et reporté sur `068` ; sans capture ni
  détail par étape.
- Environnement : repris de `IPAD-L2-055`, transitions d’arrière-plan non
  redéclarées.

### `IPAD-L2-069` — Aide et accessibilité du périmètre Lot 2

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : `Lot2-Final` contient photo, texte et sticker ; VoiceOver est
  disponible et la taille de texte peut être temporairement augmentée.
- Exigences : `3:EDT-019`, `3:STK-022`, `3:ACC-001` à `3:ACC-008`,
  `3:ACC-020`, `3:ACC-021`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ouvrir successivement Texte, Stickers et Cadres et formes, puis demander l’aide contextuelle depuis chacun. | L’aide s’ouvre directement sur la section correspondante et décrit les commandes réellement publiques, sans fonction Lot 3. |
| 2 | Activer VoiceOver et parcourir le rail, la recherche, trois tuiles sticker et la barre d’un sticker sélectionné. | Chaque contrôle annonce un nom, son rôle ou son état ; Remplacer, Opacité et Retourner horizontalement portent des libellés non ambigus. |
| 3 | Parcourir les six formes, les couleurs de contour, les six cadres et les trois portées. | Chaque choix annonce son nom et son état sélectionné ; la portée annonce le nombre de cadres concernés. |
| 4 | Parcourir une zone débordante puis une zone normale, une photo et un sticker superposés. | L’ordre accessible reste déterministe ; l’alerte de débordement, le type, la position et la profondeur utiles sont annoncés. |
| 5 | Passer à une grande taille de texte puis tourner portrait/paysage. | Les libellés restent lisibles ou défilables, les contrôles tactiles restent atteignables et aucune information ne dépend uniquement de la couleur ou d’une icône. |
| 6 | Désactiver VoiceOver et restaurer la taille de texte. | L’état de l’album et la sélection restent cohérents ; aucun format ni élément n’a été modifié par la navigation accessible. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « tous les autres tests dans `039…054` sont ok »,
  fourni sous l’ancien libellé `053` et reporté sur `069` ; sans capture ni
  détail par étape.
- Environnement : repris de `IPAD-L2-055`, réglages d’accessibilité non
  redéclarés.

### `IPAD-L2-070` — Fluidité à vingt stickers et avertissement au-delà

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Préconditions : utiliser une nouvelle page de `Lot2-Final` ou vider la page 3
  de ses stickers ; relever approximativement les temps d’attente anormaux.
- Exigences : `3:STK-021`, `3:PERF-005`, `3:PERF-015`, `3:PERF-017`,
  `3:ACC-002`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ajouter exactement vingt stickers variés par pressions et dépôts. | Chaque ajout reste interactif, aucun sticker ne manque et aucun avertissement de dépassement n’est affiché à vingt. |
| 2 | Déplacer, tourner, redimensionner et changer l’opacité de plusieurs stickers, puis annuler/rétablir cinq actions. | Les gestes et commandes restent utilisables sans gel, perte d’entrée ni corruption de la pile. |
| 3 | Ouvrir la vue globale puis Prévisualiser et revenir en création. | Les vingt stickers sont rendus dans chaque vue ; la navigation et le retour restent réactifs. |
| 4 | Ajouter un vingt-et-unième sticker. | L’ajout réussit et un avertissement orange non bloquant indique que l’édition peut être moins fluide au-delà de vingt. |
| 5 | Continuer à déplacer un sticker puis en supprimer un pour revenir à vingt. | L’avertissement ne bloque aucune commande et disparaît lorsque le compte revient à vingt. |
| 6 | Sauvegarder, fermer, relancer et rouvrir la page. | Les vingt stickers et leurs transformations persistent ; le lancement et l’ouverture n’échouent pas faute de mémoire. |

- Résultat : 🟢 `RÉUSSI`.
- Preuve : retour global « tous les autres tests dans `039…054` sont ok »,
  fourni sous l’ancien libellé `054` et reporté sur `070` ; sans capture ni
  détail par étape.
- Environnement : repris de `IPAD-L2-055`, espace libre et état thermique non
  redéclarés.

## Régressions des quatre échecs fonctionnels du candidat final

Les quatre fiches suivantes visent exactement
`9bc11e7423178b66c48446c59abc5a912de5c26f`. Récupérer ce commit sans édition
locale et réutiliser l’album `Lot2-Final` de la campagne précédente. Une fiche
peut être exécutée indépendamment si sa précondition est reconstruite ; un
échec n’attribue aucun verdict aux étapes suivantes de la même fiche.

### `IPAD-L2-071` — Collage riche et annulation de la limite

- Candidat : `9bc11e7423178b66c48446c59abc5a912de5c26f`.
- Spécification : 3.0 incluse dans le candidat exact.
- Préconditions : Notes contient un extrait inférieur à 1 000 caractères avec
  un mot gras, un mot italique, un lien actif, une liste et une petite image,
  ainsi qu’un second extrait de plus de 1 000 caractères ; `Lot2-Final`
  contient une zone de texte reconnaissable.
- Exigences : `3:ENV-001` à `3:ENV-005`, `3:TBX-004`, `3:TBX-006` à
  `3:TBX-008`, `3:TBX-017`, `3:TBX-023`, `3:CLP-005`, `3:DONE-005`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Compiler, lancer l’app puis ouvrir la zone de texte existante. | La compilation et l’ouverture réussissent sans erreur dans `AlbumTextEditorView` ; le contenu initial est lisible. |
| 2 | Remplacer le contenu par « État avant collage », mettre « avant » en gras et « collage » en italique, puis laisser le curseur à la fin. | Le texte et ses deux styles constituent un état antérieur reconnaissable ; le compteur reste inférieur à 1 000. |
| 3 | Coller l’extrait Notes inférieur à 1 000 caractères. | Le texte et les retours à la ligne sont conservés ; gras et italique restent visibles ; image, pièce jointe, structure de liste, lien actif et métadonnées disparaissent sans supprimer le libellé du lien. |
| 4 | Presser Terminer, rouvrir la zone et comparer le texte collé. | Le contenu filtré et les styles gras/italique autorisés persistent ; aucun élément interdit ne réapparaît. |
| 5 | Sans terminer, noter l’état exact puis coller l’extrait de plus de 1 000 caractères et presser **Annuler** dans l’alerte Limite atteinte. | L’alerte apparaît ; Annuler restaure exactement le contenu et les styles présents juste avant ce collage, sans conserver le texte tronqué. |
| 6 | Refaire le collage long et choisir **Conserver 1 000 caractères**, puis terminer et rouvrir. | Le compteur vaut exactement 1 000 caractères Swift ; seul l’excès est absent et l’état accepté persiste sans crash. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — résultat par étape, origine Notes, capture facultative
  de l’alerte et des styles avant/après.
- Environnement : iPad 8e génération, iPadOS 26.5.2, Swift Playgrounds 4.7 ;
  relever toute différence et le mode de transfert du candidat.

### `IPAD-L2-072` — Dépôt, petites commandes et miniature sticker

- Candidat : `9bc11e7423178b66c48446c59abc5a912de5c26f`.
- Spécification : 3.0 incluse dans le candidat exact.
- Préconditions : page 1 de `Lot2-Final` avec une photo choisie comme
  couverture manuelle ; aucun sticker ne recouvre son centre au départ.
- Exigences : `3:STK-004`, `3:STK-005`, `3:STK-008`, `3:STK-015`,
  `3:STK-023`, `3:STK-024`, `3:ELM-002`, `3:ACC-003`, `3:COV-007`,
  `3:CAN-008`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ouvrir Stickers, maintenir une tuile puis la glisser au centre de la photo de couverture. | Le sticker suit le doigt sans icône d’interdiction, peut être relâché sur la page et apparaît à l’endroit visé plutôt qu’au centre par défaut. |
| 2 | Déplacer et tourner le sticker, puis le réduire progressivement jusqu’à la taille minimale autorisée. | Les huit poignées et la rotation restent présentes, mais leur dessin rétrécit et ne masque plus l’essentiel du sticker sélectionné. |
| 3 | Utiliser deux poignées différentes puis la commande de rotation sur ce petit sticker. | Les cibles restent faciles à toucher malgré leur dessin réduit ; taille, rapport et rotation changent sans saut ni déformation. |
| 4 | Désélectionner puis resélectionner le sticker. | Le visuel garde exactement taille, position et rotation ; aucune commande fantôme ne reste après désélection. |
| 5 | Sauvegarder, revenir à la Bibliothèque et attendre la miniature de `Lot2-Final`. | La miniature d’album rend le sticker superposé à la photo de couverture avec son alpha, sa rotation et son emplacement ; il ne disparaît pas pendant la composition. |
| 6 | Rouvrir l’album puis revenir une seconde fois à la Bibliothèque. | Le sticker persiste et la miniature mise en cache reste identique, sans clignotement durable ni retour à une ancienne couverture. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — résultat par étape et, si possible, captures de la
  petite sélection et de la miniature.
- Environnement : reprendre celui de `IPAD-L2-071` ; préciser si la couverture
  a dû être rechoisie.

### `IPAD-L2-073` — Remplacement réel d’un sticker

- Candidat : `9bc11e7423178b66c48446c59abc5a912de5c26f`.
- Spécification : 3.0 incluse dans le candidat exact.
- Préconditions : page 1 avec le sticker de `IPAD-L2-072`, déplacé, tourné,
  retourné horizontalement, réglé à 60 % d’opacité et placé entre deux autres
  éléments dans la profondeur ; relever le nombre de stickers de la page.
- Exigences : `3:STK-007`, `3:STK-014` à `3:STK-016`, `3:STK-022`,
  `3:ELM-008`, `3:UND-001`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Sélectionner le sticker, presser Remplacer et examiner le haut du catalogue. | Un bandeau orange bordé, cohérent avec le choix de remplacement photo, annonce le remplacement et propose une action d’annulation accessible. |
| 2 | Annuler ce mode depuis son bouton en forme de croix. | Le bandeau disparaît ; le sticker, son nombre et toutes ses propriétés restent inchangés. |
| 3 | Relancer Remplacer puis choisir un sticker de rapport très différent. | L’ancien sticker disparaît et le nouveau prend sa place ; le nombre de stickers ne change pas et aucun second sticker n’est ajouté au centre. |
| 4 | Comparer centre, rotation, opacité, miroir, profondeur et dimensions avant/après. | Centre, rotation, opacité, miroir et profondeur sont identiques ; les dimensions s’adaptent au rapport intrinsèque sans recadrage ni déformation et restent au-dessus du minimum. |
| 5 | Presser Annuler puis Rétablir une fois. | Annuler restaure exactement l’ancien sticker transformé ; Rétablir remet exactement le remplacement, toujours sans changer le nombre. |
| 6 | Sauvegarder, fermer puis rouvrir l’album. | Le remplacement final et toutes ses transformations persistent ; aucune copie supplémentaire n’apparaît après relance. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — identifiants visuels choisis, nombre avant/après et
  résultat des transformations/historique.
- Environnement : reprendre celui de `IPAD-L2-072`, sans différence déclarée.

### `IPAD-L2-074` — Alignement des cadres décoratifs

- Candidat : `9bc11e7423178b66c48446c59abc5a912de5c26f`.
- Spécification : 3.0 incluse dans le candidat exact.
- Préconditions : page 2 avec deux cadres photo remplis, l’un large et l’autre
  haut, dont les limites sont faciles à voir ; relever leur cadrage avant test.
- Exigences : `3:SHR-004`, `3:SHR-005`, `3:SHR-009`, `3:SHR-011`,
  `3:SHR-013`, `3:SHR-014`, `3:CAN-008`.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Appliquer Bord blanc au cadre large puis au cadre haut et examiner leurs quatre côtés. | Le décor visible atteint les limites du cadre sur les deux rapports ; aucune bande régulière de photo ne reste visible entre le décor et le bord. |
| 2 | Répéter avec Bord noir puis Photo instantanée. | Coins et épaisseurs restent nets, les bords suivent chaque rapport et aucun décalage systématique ne révèle la photo derrière. |
| 3 | Parcourir Ruban kraft, Tampon voyage et Feuillage sur les deux cadres. | Chaque décor garde ses transparences et irrégularités voulues, mais son étendue visible est alignée aux limites sans marge extérieure artificielle. |
| 4 | Ajouter un contour intérieur coloré puis comparer l’empilement. | L’ordre reste photo masquée, contour entièrement intérieur, puis décor au-dessus ; aucun calque ne change la géométrie du cadre. |
| 5 | Comparer la page, la vue globale et Prévisualiser. | Le même alignement, les mêmes coins, alpha et ordre apparaissent dans les trois rendus, y compris aux petites tailles. |
| 6 | Choisir Aucun, vérifier les cadrages puis presser Annuler/Rétablir. | Aucun retire seulement le décor ; point focal, zoom, orientation et masque restent identiques ; Annuler/Rétablir restaure et retire le même décor en une commande. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — résultat pour les deux rapports et, si possible,
  captures rapprochées d’au moins Bord blanc et Photo instantanée.
- Environnement : reprendre celui de `IPAD-L2-071`, sans différence déclarée.


## Qualification différée Apple/macOS/Xcode

Ces contrôles complètent les preuves que Swift Playgrounds ou un seul iPad ne
peut pas fournir. `APPLE-L2-001` conserve la procédure historique du premier
incrément ; `APPLE-L2-002…005` restent attachés au candidat `fce5d92…` rejeté
à la compilation iPad et `APPLE-L2-006…009` au correctif `64f5342…` dont les
quatre régressions fonctionnelles ont échoué. Les nouveaux contrôles
`APPLE-L2-010…013` qualifient le candidat exact `9bc11e7…`. Ils restent tous
⚪ `NON TESTÉ` jusqu’à une campagne séparée visant le candidat explicitement
enregistré.

| ID différé | Contrôle | Exigences | État | Motif du report |
|---|---|---|---|---|
| `APPLE-L1-001` | Ouvrir le package sans état local, compiler Debug et Release avec les SDK iOS/iPadOS 26, exécuter tests Core et Apple | `3:ENV-006` à `3:ENV-009`, `3:TST-014` à `3:TST-016` | ⚪ `NON TESTÉ` | Xcode/macOS absent de WSL et non prouvé sur iPad |
| `APPLE-L1-002` | Matrice iPhone portrait/paysage, iPad portrait/paysage, plus anciens appareils compatibles et dernière version système, limitée aux fonctions Lot 1 | `3:TST-003`, `3:TST-008` | ⚪ `NON TESTÉ` | Un seul iPad ne couvre pas la matrice |
| `APPLE-L1-003` | Tests UI automatisés des commandes, états désactivés, focus, gestes et multi-fenêtre | `3:EDT-010`, `3:ZOM-005`, `3:NAV-005`, `3:APP-010` | ⚪ `NON TESTÉ` | Nécessite XCTest/SDK Apple |
| `APPLE-L1-004` | Injections d’interruption à chaque étape du journal, staging, import, restauration et purge future sûre | `3:LOC-004` à `3:LOC-026`, `3:TST-012` | ⚪ `NON TESTÉ` | Interruption déterministe impossible manuellement ; purge physique non exposée au Lot 1 |
| `APPLE-L1-005` | Manque d’espace contrôlé, protection des fichiers, import RAW volumineux et mémoire | `3:LOC-006`, `3:LOC-019`, `3:LOC-020`, `3:SEC-011`, `3:PERF-004` | ⚪ `NON TESTÉ` | Reproduction sûre et mesures nécessitent environnement instrumenté |
| `APPLE-L1-006` | Instruments : mémoire, CPU, énergie, temps de lancement, 100 pages/5 Go et fluidité des transformations | `3:PERF-001` à `3:PERF-009`, `3:ACPT-114` | ⚪ `NON TESTÉ` | Instruments indisponible dans Swift Playgrounds |
| `APPLE-L1-007` | Accessibility Inspector, VoiceOver sur iPhone/iPad, contrastes, filtres de couleur et cibles 44 × 44 pour les fonctions Lot 1 | `3:ACC-001` à `3:ACC-008`, `3:ACC-011` à `3:ACC-017`, `3:ACC-020`, `3:ACC-021` | ⚪ `NON TESTÉ` | Inspection exhaustive et matrice matérielle différées |
| `APPLE-L0-008` | Prototype CloudKit : entitlements, zone privée et comportement local d’erreur, sans publier une fonction Lot 4 | `3:ENV-003`, `3:ARC-004`, `3:ARC-011` | ⚪ `NON TESTÉ` | Configuration CloudKit/signature requise ; fonction publique différée |
| `APPLE-L1-009` | Archive, validation de l’archive et build TestFlight du candidat viable, puis nouvelle campagne distincte | `3:DONE-005`, `3:TST-014`, `3:TST-015` | ⚪ `NON TESTÉ` | À faire seulement après correction des résultats iPad |
| `APPLE-L1-010` | Ressource de fond absente puis copie de secours invalide | `3:BG-008`, `3:ERR-017` | ⚪ `NON TESTÉ` | Nécessite une build de test avec injection de catalogue et vidage contrôlé des caches |
| `APPLE-L1-011` | Échec durable de sauvegarde, Réessayer et tentative de fermeture | `3:SAV-003`, `3:SAV-004`, `3:ERR-014` | ⚪ `NON TESTÉ` | Nécessite une erreur de dépôt déterministe sans remplir dangereusement le disque |
| `APPLE-L1-012` | Preuve réseau qu’aucune photo ne quitte l’app vers un serveur propriétaire | `3:SEC-001`, `3:SEC-010` | ⚪ `NON TESTÉ` | Nécessite capture réseau attribuée au processus et inspection statique |
| `APPLE-L1-013` | Rendu composite et cache de miniature de couverture | `3:COV-007` | ⚪ `NON TESTÉ` | Hits, misses et invalidations du cache ne sont pas observables dans l’interface publique |
| `APPLE-L2-001` | Barre compacte, Gérer les pages, confirmation d’ajout et menu Plus sur iPhone ou environnement Xcode réellement compact | `3:EDT-003`, `3:EDT-004`, `3:EDT-008`, `3:EDT-016`, `3:EDT-020`, `3:PAG-013`, `3:PAG-017`, `3:ACC-002`, `3:ACC-021` | ⚪ `NON TESTÉ` | Swift Playgrounds sur l’iPad testé ne permet pas d’obtenir cette classe de largeur |
| `APPLE-L2-002` | Interface finale Lot 2 en largeur compacte iPhone | `3:EDT-001` à `3:EDT-004`, `3:EDT-008`, `3:EDT-012`, `3:EDT-014`, `3:EDT-016`, `3:EDT-020`, `3:EDT-021`, `3:TBX-005`, `3:TBX-027`, `3:ACC-002`, `3:ACC-021` | ⚪ `NON TESTÉ` | iPhone réel ou simulateur Xcode réellement compact requis ; remplace la preuve attendue de `APPLE-L2-001` pour le candidat final |
| `APPLE-L2-003` | Compilation Debug/Release et tests Apple du candidat final | `3:ENV-006` à `3:ENV-009`, `3:TST-014` à `3:TST-016`, `3:DONE-005` | ⚪ `NON TESTÉ` | macOS, Xcode et SDK iOS approuvés requis |
| `APPLE-L2-004` | Instruments et enveloppe maximale de composition Lot 2 | `3:STK-021`, `3:PERF-001` à `3:PERF-009`, `3:PERF-015` à `3:PERF-017` | ⚪ `NON TESTÉ` | Instruments et jeu synthétique de 100 pages requis |
| `APPLE-L2-005` | Build TestFlight distincte et parcours de fumée Lot 2 | `3:TST-003`, `3:TST-005`, `3:TST-015`, `3:DONE-001` à `3:DONE-005` | ⚪ `NON TESTÉ` | La build TestFlight doit être qualifiée séparément de Swift Playgrounds |
| `APPLE-L2-006` | Interface corrigée Lot 2 en largeur compacte iPhone | `3:EDT-001` à `3:EDT-004`, `3:EDT-008`, `3:EDT-012`, `3:EDT-014`, `3:EDT-016`, `3:EDT-020`, `3:EDT-021`, `3:TBX-005`, `3:TBX-027`, `3:ACC-002`, `3:ACC-021` | ⚪ `NON TESTÉ` | Remplace `APPLE-L2-002` sur le correctif exact ; iPhone réel ou Xcode compact requis |
| `APPLE-L2-007` | Compilation Debug/Release et tests Apple du correctif | `3:ENV-006` à `3:ENV-009`, `3:TST-014` à `3:TST-016`, `3:DONE-005` | ⚪ `NON TESTÉ` | Remplace `APPLE-L2-003` ; macOS, Xcode et SDK iOS approuvés requis |
| `APPLE-L2-008` | Instruments et enveloppe maximale du correctif Lot 2 | `3:STK-021`, `3:PERF-001` à `3:PERF-009`, `3:PERF-015` à `3:PERF-017` | ⚪ `NON TESTÉ` | Remplace `APPLE-L2-004` ; Instruments et jeu synthétique de 100 pages requis |
| `APPLE-L2-009` | Build TestFlight distincte du correctif et parcours de fumée | `3:TST-003`, `3:TST-005`, `3:TST-015`, `3:DONE-001` à `3:DONE-005` | ⚪ `NON TESTÉ` | Remplace `APPLE-L2-005` ; build distincte de Swift Playgrounds |
| `APPLE-L2-010` | Interface corrigée en largeur compacte et petites commandes | `3:EDT-001` à `3:EDT-004`, `3:EDT-008`, `3:EDT-012`, `3:EDT-014`, `3:EDT-016`, `3:EDT-020`, `3:EDT-021`, `3:TBX-005`, `3:TBX-027`, `3:ACC-002`, `3:ACC-003`, `3:ACC-021` | ⚪ `NON TESTÉ` | Remplace `APPLE-L2-006` sur `9bc11e7…` ; iPhone réel ou Xcode compact requis |
| `APPLE-L2-011` | Debug/Release et tests Apple du candidat corrigé | `3:ENV-006` à `3:ENV-009`, `3:TST-014` à `3:TST-016`, `3:DONE-005` | ⚪ `NON TESTÉ` | Remplace `APPLE-L2-007` ; macOS, Xcode et SDK iOS approuvés requis |
| `APPLE-L2-012` | Instruments et enveloppe maximale du candidat corrigé | `3:STK-021`, `3:PERF-001` à `3:PERF-009`, `3:PERF-015` à `3:PERF-017` | ⚪ `NON TESTÉ` | Remplace `APPLE-L2-008` ; Instruments et jeu synthétique de 100 pages requis |
| `APPLE-L2-013` | Build TestFlight distincte du candidat corrigé | `3:TST-003`, `3:TST-005`, `3:TST-015`, `3:DONE-001` à `3:DONE-005` | ⚪ `NON TESTÉ` | Remplace `APPLE-L2-009` ; build distincte de Swift Playgrounds |

### `APPLE-L2-001` — Barre compacte, confirmation et menu Plus

- Candidat : `57afa71e3eeac8b48f05e0aaa719cf77e8a97834`.
- Spécification : 3.0, incluse dans le candidat exact ci-dessus.
- Type : test manuel sur iPhone réel ou simulateur Xcode produisant réellement
  une largeur compacte ; le plein écran iPad n’est pas un substitut.
- Exigences : `3:EDT-003`, `3:EDT-004`, `3:EDT-008`, `3:EDT-016`,
  `3:EDT-020`, `3:PAG-013`, `3:PAG-017`, `3:ACC-002`, `3:ACC-021`.
- Préconditions : page contenant un élément sélectionné, une commande Annuler
  disponible et un élément copié ; Auto successivement désactivé puis activé.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ouvrir l’éditeur en portrait sur un iPhone réel ou un simulateur Xcode produisant une largeur compacte. | La barre principale et la barre sous le canevas sont entièrement visibles ; aucune commande n’est coupée ou inaccessible. |
| 2 | Examiner la barre sous le canevas, puis presser Ajouter une page une fois. | Ajouter une page reste accessible avec son libellé complet ou son icône annoncée ; l’ancien ajout photo n’est pas dupliqué ; la confirmation, sa case et ses actions tiennent dans la largeur compacte et une confirmation positive ajoute une seule page vide en fin d’album. |
| 3 | Parcourir le sélecteur de mode. | Créer, Gérer les pages et Prévisualiser restent directement accessibles dans cet ordre et ne sont pas enfouis dans Plus. |
| 4 | Repérer Mise en page auto dans la barre, d’abord désactivée puis activée. | Auto reste directement visible hors du menu Plus et son état affiché suit la page. |
| 5 | Ouvrir Plus et parcourir Sauvegarder, Annuler, Rétablir, Couper, Copier, Coller et Supprimer. | Toutes les commandes secondaires sont présentes dans leur ordre relatif, avec leur libellé complet et leur état activé ou désactivé correct. |
| 6 | Tourner l’appareil ou le simulateur en paysage, puis rouvrir Plus. | Les barres, le sélecteur et le menu restent entièrement accessibles ; la sélection et la page active sont conservées. |
| 7 | Activer VoiceOver et parcourir Ajouter une page, les trois modes, la barre compacte puis le menu Plus. | Chaque commande possède un libellé accessible non ambigu et annonce correctement son effet ou son état indisponible. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner avec appareil/simulateur, version système, version
  Xcode ou outil, orientation et capture éventuelle.

### `APPLE-L2-002` — Interface finale Lot 2 en largeur compacte iPhone

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Spécification : 3.0 incluse dans ce commit.
- Type : test manuel sur iPhone réel ou simulateur Xcode produisant réellement
  une largeur compacte ; `APPLE-L2-001` reste historique et ne suffit pas pour
  les panneaux ajoutés depuis.
- Exigences : `3:EDT-001` à `3:EDT-004`, `3:EDT-008`, `3:EDT-012`,
  `3:EDT-014`, `3:EDT-016`, `3:EDT-020`, `3:EDT-021`, `3:TBX-005`,
  `3:TBX-027`, `3:ACC-002`, `3:ACC-021`.
- Préconditions : album contenant photo, texte et sticker ; une action Annuler
  et un contenu copié disponibles ; clavier logiciel activé.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ouvrir l’éditeur en portrait sur une largeur compacte réelle. | Barre principale, canevas, barre locale et commandes inférieures tiennent dans la largeur ; aucune action essentielle n’est coupée. |
| 2 | Parcourir les six panneaux et ouvrir chacun d’eux. | Photos, Texte, Stickers, Mise en page, Fonds et Cadres et formes restent atteignables ; le panneau ouvert peut être fermé sans perdre la sélection. |
| 3 | Modifier un texte avec le clavier visible et parcourir tous les formats. | Le curseur, la sélection, les boutons compacts et Terminer restent accessibles ; le clavier ne masque pas durablement le contenu actif. |
| 4 | Sélectionner successivement photo, texte et sticker. | Seule la barre propre au type apparaît, suivie des commandes communes ; aucun libellé ne rend la barre inutilisable. |
| 5 | Presser Ajouter une page et parcourir Créer, Gérer les pages et Prévisualiser. | Le dialogue interne tient dans l’écran ; les trois modes restent directement accessibles et l’ajout confirmé crée une seule page en fin. |
| 6 | Ouvrir Plus et tester les états de Sauvegarder, Annuler, Rétablir, Couper, Copier, Coller et Supprimer. | Toutes les commandes secondaires sont présentes, lisibles et correctement activées ou désactivées. |
| 7 | Tourner en paysage puis activer VoiceOver sur les barres et panneaux. | La page et la sélection persistent ; chaque action conserve un libellé non ambigu et une cible accessible. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — appareil/simulateur, dimensions, OS, Xcode,
  orientations, clavier et captures de tout rognage.
- Environnement : à renseigner.

### `APPLE-L2-003` — Compilation Debug/Release et tests Apple du candidat final

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Spécification : 3.0 incluse dans ce commit.
- Type : validation reproductible sous macOS/Xcode avec SDK iOS approuvé.
- Exigences : `3:ENV-006` à `3:ENV-009`, `3:TST-014` à `3:TST-016`,
  `3:DONE-005`.
- Préconditions : checkout propre du commit exact, cache et DerivedData
  identifiés, aucune modification locale, destinations iPhone et iPad.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Résoudre le package puis compiler la configuration Debug pour iPhone et iPad. | Les deux destinations compilent sans erreur SwiftUI/UIKit, ressource absente ni avertissement bloquant. |
| 2 | Exécuter l’intégralité des tests Core et des éventuels tests Apple. | Tous les tests réussissent ; le nombre, la durée, le SDK et les destinations sont enregistrés. |
| 3 | Compiler puis archiver la configuration Release. | L’archive réussit avec uniquement les API publiques, les 40 stickers et les 6 cadres embarqués. |
| 4 | Valider l’archive avec les contrôles Xcode. | Aucune erreur de signature, d’asset, d’API privée, de manifeste ou de ressource dupliquée n’est signalée. |
| 5 | Lancer Debug puis Release sur appareil ou simulateur et créer un texte, un sticker et un cadre décoratif. | Les deux configurations exposent le même périmètre Lot 2 et rendent les trois éléments sans divergence fonctionnelle visible. |
| 6 | Copier/coller chaque type, sauvegarder, fermer puis relancer. | Les commandes et la persistance fonctionnent dans les deux configurations sans crash ni perte. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — version Xcode/SDK, destinations, commandes, logs,
  nombre de tests et rapport de validation d’archive.
- Environnement : à renseigner.

### `APPLE-L2-004` — Instruments et enveloppe maximale de composition Lot 2

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Spécification : 3.0 incluse dans ce commit.
- Type : campagne Instruments sur build Release et données synthétiques non
  personnelles ; aucun média utilisateur réel.
- Exigences : `3:STK-021`, `3:PERF-001` à `3:PERF-009`,
  `3:PERF-015` à `3:PERF-017`.
- Préconditions : appareil de référence documenté ; album synthétique de cent
  pages contenant chacune vingt photos, vingt textes et vingt stickers ;
  miniatures générées et volume disque mesuré.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Mesurer un lancement froid puis chaud avec cent albums et les miniatures déjà générées. | La Bibliothèque affiche son premier contenu en moins de deux secondes ; la validation idempotente du catalogue ne bloque pas le thread principal. |
| 2 | Ouvrir l’album synthétique et mesurer l’affichage de sa première page. | La première page locale apparaît en moins de deux secondes. |
| 3 | Parcourir rapidement vingt pages en avant puis en arrière en surveillant allocations et mémoire résidente. | Seules la page courante, ses miniatures et au plus la suivante sont préchauffées ; le pic reste inférieur à 500 Mo. |
| 4 | Déplacer, tourner et redimensionner photo, texte et sticker avec Core Animation/Time Profiler. | Les transformations visent 60 images/s, ne décodent pas de pleine résolution et n’écrivent pas durablement à chaque image. |
| 5 | Ouvrir à répétition Stickers, Cadres et formes, Fonds et Mise en page. | Chaque panneau produit un premier retour visuel en moins de 200 ms hors chargement d’asset ; les miniatures mises en cache ne sont pas retraitées inutilement. |
| 6 | Ajouter un vingt-et-unième sticker, puis lancer une tâche dépassant 500 ms si disponible. | Le dépassement produit seulement l’avertissement prévu ; toute tâche longue affiche une activité sans bloquer l’interface. |
| 7 | Examiner fuites, pics CPU, énergie et blocages du thread principal pendant le parcours complet. | Aucune fuite croissante, suspension durable, crash mémoire ou travail lourd injustifié sur le thread principal n’est observé. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — trace Instruments, modèle d’appareil, état thermique,
  tailles du jeu, temps, FPS et pic mémoire.
- Environnement : à renseigner.

### `APPLE-L2-005` — Build TestFlight distincte et parcours de fumée Lot 2

- Candidat : `fce5d92879a5a654778b02ec17a3707590554cd7`.
- Spécification : 3.0 incluse dans ce commit.
- Type : build TestFlight issue de l’archive Release validée par
  `APPLE-L2-003`, testée séparément du package Swift Playgrounds.
- Exigences : `3:TST-003`, `3:TST-005`, `3:TST-015`, `3:DONE-001` à
  `3:DONE-005`.
- Préconditions : build et numéro exacts enregistrés, notes de test sans donnée
  personnelle, installation propre puis mise à jour depuis la build précédente
  si cette dernière existe.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Installer la build TestFlight sur iPhone et iPad compatibles puis lancer la Bibliothèque. | Installation, lancement et lecture des albums réussissent sans dépendre du package Swift Playgrounds. |
| 2 | Créer ou ouvrir un album et exécuter un parcours court photo, texte, sticker, forme, contour et cadre décoratif. | Toutes les fonctions publiques du Lot 2 sont présentes et chaque type se rend correctement. |
| 3 | Copier/coller un texte et un sticker, annuler/rétablir puis sauvegarder. | Le presse-papiers privé, l’historique et la sauvegarde restent cohérents dans la build distribuée. |
| 4 | Passer en arrière-plan, forcer la fermeture, relancer puis travailler hors ligne. | Les données validées persistent ; les ressources intégrées restent disponibles ; aucun clipboard de session ne ressuscite. |
| 5 | Tester portrait, paysage, grande taille de texte et VoiceOver sur les deux familles d’appareil. | Aucun contrôle essentiel n’est inaccessible et les libellés/états restent compréhensibles. |
| 6 | Examiner les journaux TestFlight et les rapports de crash après le parcours. | Aucun crash, blocage, corruption ou erreur répétée de catalogue n’est enregistré. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — version/build TestFlight, appareils, OS, installation
  propre/mise à jour, retours par étape et rapports de crash.
- Environnement : à renseigner.

### `APPLE-L2-006` — Interface finale Lot 2 en largeur compacte iPhone

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Spécification : 3.0 incluse dans ce commit.
- Type : test manuel sur iPhone réel ou simulateur Xcode produisant réellement
  une largeur compacte ; `APPLE-L2-001` reste historique et ne suffit pas pour
  les panneaux ajoutés depuis.
- Exigences : `3:EDT-001` à `3:EDT-004`, `3:EDT-008`, `3:EDT-012`,
  `3:EDT-014`, `3:EDT-016`, `3:EDT-020`, `3:EDT-021`, `3:TBX-005`,
  `3:TBX-027`, `3:ACC-002`, `3:ACC-021`.
- Préconditions : album contenant photo, texte et sticker ; une action Annuler
  et un contenu copié disponibles ; clavier logiciel activé.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ouvrir l’éditeur en portrait sur une largeur compacte réelle. | Barre principale, canevas, barre locale et commandes inférieures tiennent dans la largeur ; aucune action essentielle n’est coupée. |
| 2 | Parcourir les six panneaux et ouvrir chacun d’eux. | Photos, Texte, Stickers, Mise en page, Fonds et Cadres et formes restent atteignables ; le panneau ouvert peut être fermé sans perdre la sélection. |
| 3 | Modifier un texte avec le clavier visible et parcourir tous les formats. | Le curseur, la sélection, les boutons compacts et Terminer restent accessibles ; le clavier ne masque pas durablement le contenu actif. |
| 4 | Sélectionner successivement photo, texte et sticker. | Seule la barre propre au type apparaît, suivie des commandes communes ; aucun libellé ne rend la barre inutilisable. |
| 5 | Presser Ajouter une page et parcourir Créer, Gérer les pages et Prévisualiser. | Le dialogue interne tient dans l’écran ; les trois modes restent directement accessibles et l’ajout confirmé crée une seule page en fin. |
| 6 | Ouvrir Plus et tester les états de Sauvegarder, Annuler, Rétablir, Couper, Copier, Coller et Supprimer. | Toutes les commandes secondaires sont présentes, lisibles et correctement activées ou désactivées. |
| 7 | Tourner en paysage puis activer VoiceOver sur les barres et panneaux. | La page et la sélection persistent ; chaque action conserve un libellé non ambigu et une cible accessible. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — appareil/simulateur, dimensions, OS, Xcode,
  orientations, clavier et captures de tout rognage.
- Environnement : à renseigner.

### `APPLE-L2-007` — Compilation Debug/Release et tests Apple du correctif final

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Spécification : 3.0 incluse dans ce commit.
- Type : validation reproductible sous macOS/Xcode avec SDK iOS approuvé.
- Exigences : `3:ENV-006` à `3:ENV-009`, `3:TST-014` à `3:TST-016`,
  `3:DONE-005`.
- Préconditions : checkout propre du commit exact, cache et DerivedData
  identifiés, aucune modification locale, destinations iPhone et iPad.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Résoudre le package puis compiler la configuration Debug pour iPhone et iPad. | Les deux destinations compilent sans erreur SwiftUI/UIKit, ressource absente ni avertissement bloquant. |
| 2 | Exécuter l’intégralité des tests Core et des éventuels tests Apple. | Tous les tests réussissent ; le nombre, la durée, le SDK et les destinations sont enregistrés. |
| 3 | Compiler puis archiver la configuration Release. | L’archive réussit avec uniquement les API publiques, les 40 stickers et les 6 cadres embarqués. |
| 4 | Valider l’archive avec les contrôles Xcode. | Aucune erreur de signature, d’asset, d’API privée, de manifeste ou de ressource dupliquée n’est signalée. |
| 5 | Lancer Debug puis Release sur appareil ou simulateur et créer un texte, un sticker et un cadre décoratif. | Les deux configurations exposent le même périmètre Lot 2 et rendent les trois éléments sans divergence fonctionnelle visible. |
| 6 | Copier/coller chaque type, sauvegarder, fermer puis relancer. | Les commandes et la persistance fonctionnent dans les deux configurations sans crash ni perte. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — version Xcode/SDK, destinations, commandes, logs,
  nombre de tests et rapport de validation d’archive.
- Environnement : à renseigner.

### `APPLE-L2-008` — Instruments et enveloppe maximale de composition Lot 2

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Spécification : 3.0 incluse dans ce commit.
- Type : campagne Instruments sur build Release et données synthétiques non
  personnelles ; aucun média utilisateur réel.
- Exigences : `3:STK-021`, `3:PERF-001` à `3:PERF-009`,
  `3:PERF-015` à `3:PERF-017`.
- Préconditions : appareil de référence documenté ; album synthétique de cent
  pages contenant chacune vingt photos, vingt textes et vingt stickers ;
  miniatures générées et volume disque mesuré.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Mesurer un lancement froid puis chaud avec cent albums et les miniatures déjà générées. | La Bibliothèque affiche son premier contenu en moins de deux secondes ; la validation idempotente du catalogue ne bloque pas le thread principal. |
| 2 | Ouvrir l’album synthétique et mesurer l’affichage de sa première page. | La première page locale apparaît en moins de deux secondes. |
| 3 | Parcourir rapidement vingt pages en avant puis en arrière en surveillant allocations et mémoire résidente. | Seules la page courante, ses miniatures et au plus la suivante sont préchauffées ; le pic reste inférieur à 500 Mo. |
| 4 | Déplacer, tourner et redimensionner photo, texte et sticker avec Core Animation/Time Profiler. | Les transformations visent 60 images/s, ne décodent pas de pleine résolution et n’écrivent pas durablement à chaque image. |
| 5 | Ouvrir à répétition Stickers, Cadres et formes, Fonds et Mise en page. | Chaque panneau produit un premier retour visuel en moins de 200 ms hors chargement d’asset ; les miniatures mises en cache ne sont pas retraitées inutilement. |
| 6 | Ajouter un vingt-et-unième sticker, puis lancer une tâche dépassant 500 ms si disponible. | Le dépassement produit seulement l’avertissement prévu ; toute tâche longue affiche une activité sans bloquer l’interface. |
| 7 | Examiner fuites, pics CPU, énergie et blocages du thread principal pendant le parcours complet. | Aucune fuite croissante, suspension durable, crash mémoire ou travail lourd injustifié sur le thread principal n’est observé. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — trace Instruments, modèle d’appareil, état thermique,
  tailles du jeu, temps, FPS et pic mémoire.
- Environnement : à renseigner.

### `APPLE-L2-009` — Build TestFlight distincte et parcours de fumée Lot 2

- Candidat : `64f53424a0fc479c4fdea79c401d0b227d52eebd`.
- Spécification : 3.0 incluse dans ce commit.
- Type : build TestFlight issue de l’archive Release validée par
  `APPLE-L2-007`, testée séparément du package Swift Playgrounds.
- Exigences : `3:TST-003`, `3:TST-005`, `3:TST-015`, `3:DONE-001` à
  `3:DONE-005`.
- Préconditions : build et numéro exacts enregistrés, notes de test sans donnée
  personnelle, installation propre puis mise à jour depuis la build précédente
  si cette dernière existe.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Installer la build TestFlight sur iPhone et iPad compatibles puis lancer la Bibliothèque. | Installation, lancement et lecture des albums réussissent sans dépendre du package Swift Playgrounds. |
| 2 | Créer ou ouvrir un album et exécuter un parcours court photo, texte, sticker, forme, contour et cadre décoratif. | Toutes les fonctions publiques du Lot 2 sont présentes et chaque type se rend correctement. |
| 3 | Copier/coller un texte et un sticker, annuler/rétablir puis sauvegarder. | Le presse-papiers privé, l’historique et la sauvegarde restent cohérents dans la build distribuée. |
| 4 | Passer en arrière-plan, forcer la fermeture, relancer puis travailler hors ligne. | Les données validées persistent ; les ressources intégrées restent disponibles ; aucun clipboard de session ne ressuscite. |
| 5 | Tester portrait, paysage, grande taille de texte et VoiceOver sur les deux familles d’appareil. | Aucun contrôle essentiel n’est inaccessible et les libellés/états restent compréhensibles. |
| 6 | Examiner les journaux TestFlight et les rapports de crash après le parcours. | Aucun crash, blocage, corruption ou erreur répétée de catalogue n’est enregistré. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — version/build TestFlight, appareils, OS, installation
  propre/mise à jour, retours par étape et rapports de crash.
- Environnement : à renseigner.

### `APPLE-L2-010` — Interface corrigée en largeur compacte et petites commandes

- Candidat : `9bc11e7423178b66c48446c59abc5a912de5c26f`.
- Spécification : 3.0 incluse dans ce commit.
- Type : test manuel sur iPhone réel ou simulateur Xcode produisant réellement
  une largeur compacte.
- Exigences : `3:EDT-001` à `3:EDT-004`, `3:EDT-008`, `3:EDT-012`,
  `3:EDT-014`, `3:EDT-016`, `3:EDT-020`, `3:EDT-021`, `3:TBX-005`,
  `3:TBX-027`, `3:ACC-002`, `3:ACC-003`, `3:ACC-021`.
- Préconditions : album contenant une photo, un texte et un sticker ; clavier
  logiciel, VoiceOver, Annuler et presse-papiers disponibles.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Ouvrir l’éditeur en portrait sur une largeur compacte réelle et parcourir les six panneaux. | Barres, canevas, Photos, Texte, Stickers, Mise en page, Fonds et Cadres et formes restent accessibles sans rognage. |
| 2 | Modifier un texte avec le clavier visible puis ouvrir chaque menu de format. | Curseur, sélection, Terminer et valeurs de format restent accessibles ; le clavier ne masque pas durablement le contenu actif. |
| 3 | Réduire un sticker au minimum, le déplacer, le tourner et utiliser deux poignées. | Le dessin des neuf commandes n’occulte pas le sticker ; leurs cibles tactiles restent utilisables et n’empiètent pas sur les commandes voisines. |
| 4 | Ouvrir Plus et tester Sauvegarder, Annuler, Rétablir, Couper, Copier, Coller et Supprimer. | Chaque commande est présente, lisible, correctement activée ou désactivée et annoncée sans ambiguïté. |
| 5 | Tourner en paysage puis parcourir les barres et la petite sélection avec VoiceOver. | Page et sélection persistent ; ordre de focus, libellés et cibles restent cohérents dans la seconde orientation. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — appareil/simulateur, dimensions, OS, Xcode,
  orientations, clavier, VoiceOver et captures de tout rognage.
- Environnement : à renseigner.

### `APPLE-L2-011` — Debug, Release et tests Apple du candidat corrigé

- Candidat : `9bc11e7423178b66c48446c59abc5a912de5c26f`.
- Spécification : 3.0 incluse dans ce commit.
- Type : validation reproductible sous macOS/Xcode avec SDK iOS approuvé.
- Exigences : `3:ENV-006` à `3:ENV-009`, `3:TST-014` à `3:TST-016`,
  `3:DONE-005`.
- Préconditions : checkout propre du commit exact, caches identifiés et
  destinations iPhone/iPad disponibles.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Résoudre le package puis compiler Debug pour iPhone et iPad. | Les deux destinations compilent sans erreur SwiftUI/UIKit, ressource absente ni avertissement bloquant. |
| 2 | Exécuter tous les tests Core et Apple disponibles. | Tous réussissent ; nombre, durée, SDK et destinations sont enregistrés. |
| 3 | Compiler Release, créer l’archive puis lancer sa validation Xcode. | L’archive et sa validation réussissent sans API privée, ressource dupliquée, défaut de signature ou de manifeste. |
| 4 | En Debug puis Release, rejouer les parcours de `IPAD-L2-071…074`. | Collage riche, retour arrière, dépôt/remplacement/miniature sticker et cadres décoratifs ont le même résultat conforme dans les deux configurations. |
| 5 | Sauvegarder, fermer et relancer après chaque configuration. | Le document persiste sans crash, perte, duplication d’élément ni divergence de rendu. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — Xcode/SDK, destinations, commandes, logs, nombre de
  tests et rapport de validation de l’archive.
- Environnement : à renseigner.

### `APPLE-L2-012` — Instruments et enveloppe maximale du candidat corrigé

- Candidat : `9bc11e7423178b66c48446c59abc5a912de5c26f`.
- Spécification : 3.0 incluse dans ce commit.
- Type : campagne Instruments sur build Release et données synthétiques non
  personnelles.
- Exigences : `3:STK-021`, `3:PERF-001` à `3:PERF-009`, `3:PERF-015` à
  `3:PERF-017`.
- Préconditions : appareil documenté ; cent albums et un album de cent pages,
  avec vingt photos, vingt textes et vingt stickers par page ; miniatures
  générées et volume disque mesuré.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Mesurer lancements froid/chaud et ouverture de la première page. | La Bibliothèque puis la première page locale affichent un premier contenu en moins de deux secondes. |
| 2 | Parcourir rapidement vingt pages dans les deux sens en surveillant mémoire et allocations. | Le préchauffage reste borné et le pic mémoire demeure inférieur à 500 Mo sans croissance persistante. |
| 3 | Transformer photo, texte et petit sticker avec Core Animation et Time Profiler. | Les gestes visent 60 images/s, restent réactifs et ne déclenchent ni décodage pleine résolution ni écriture durable par image. |
| 4 | Revenir plusieurs fois à la Bibliothèque après des stickers et cadres différents sur la couverture. | Le préchargement et le cache évitent les retraitements continus ; la miniature composée reste correcte sans pic croissant. |
| 5 | Appliquer les six cadres décoratifs à des rapports variés et surveiller le calcul des limites alpha. | Chaque ressource n’est analysée qu’au besoin puis réutilisée ; aucun blocage durable du thread principal n’apparaît. |
| 6 | Examiner fuites, CPU, énergie, blocages et avertissement au vingt-et-unième sticker. | Aucune fuite croissante, suspension, crash mémoire ou travail lourd répété n’est observé ; seul l’avertissement prévu apparaît. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — trace Instruments, modèle, état thermique, tailles du
  jeu, temps, FPS, pic mémoire et observations du cache.
- Environnement : à renseigner.

### `APPLE-L2-013` — Build TestFlight distincte du candidat corrigé

- Candidat : `9bc11e7423178b66c48446c59abc5a912de5c26f`.
- Spécification : 3.0 incluse dans ce commit.
- Type : build TestFlight issue de l’archive Release validée par
  `APPLE-L2-011`, séparée du package Swift Playgrounds.
- Exigences : `3:TST-003`, `3:TST-005`, `3:TST-015`, `3:DONE-001` à
  `3:DONE-005`.
- Préconditions : build/numéro exacts enregistrés ; installation propre puis
  mise à jour depuis la build précédente si elle existe.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Installer la build sur iPhone et iPad puis lancer la Bibliothèque. | Installation, lancement et lecture réussissent sans dépendre de Swift Playgrounds. |
| 2 | Créer ou ouvrir un album et parcourir photo, texte, sticker, forme, contour et cadre décoratif. | Toutes les fonctions publiques du Lot 2 sont présentes et correctement rendues. |
| 3 | Rejouer les contrôles fonctionnels de `IPAD-L2-071…074`. | Les quatre correctifs restent conformes dans la build distribuée. |
| 4 | Annuler/rétablir, sauvegarder, passer en arrière-plan, forcer la fermeture puis relancer hors ligne. | Données et ressources intégrées persistent ; aucun presse-papiers de session ne ressuscite. |
| 5 | Tester portrait, paysage, grande taille de texte et VoiceOver sur les deux familles d’appareil. | Aucun contrôle essentiel n’est inaccessible et les libellés/états restent compréhensibles. |
| 6 | Examiner journaux TestFlight et rapports de crash. | Aucun crash, blocage, corruption ni erreur répétée de catalogue n’est enregistré. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — version/build, appareils, OS, installation
  propre/mise à jour, résultats par étape et rapports de crash.
- Environnement : à renseigner.

### `APPLE-L1-010` — Fond manquant et repli validé

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Type : test Apple instrumenté avec catalogue et stockage injectables ; aucun
  crochet de test ne doit être compilé dans la version publique.
- Exigences : `3:BG-008`, `3:ERR-017`.
- Préconditions : dans un bac à sable jetable, créer une page utilisant un
  motif intégré non par défaut et vérifier que sa copie de secours a été
  validée et enregistrée. Mémoriser l’identifiant/version d’origine et le hash
  du rendu de référence ; désactiver ou vider le cache de rendu avant chaque
  sous-cas.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Injecter un catalogue courant où la ressource d’origine est absente, conserver sa copie de secours valide, relancer, puis rendre la page dans l’éditeur, Vue globale et Prévisualiser. | Les trois sorties utilisent la copie de secours validée et restent visuellement fidèles. |
| 2 | Comparer les trois sorties au hash de rendu attendu et relire la référence persistée. | Le hash attendu est obtenu et l’identifiant/version d’origine n’est pas remplacé. |
| 3 | Repartir d’une copie neuve du bac à sable initial, rendre également la copie de secours absente ou invalide, puis relancer. | L’application démarre sans réécriture silencieuse de la référence et utilise un fond par défaut uniquement provisoire. |
| 4 | Examiner les trois sorties, le diagnostic et l’état interne autorisant une future sortie documentaire. | Les trois sorties affichent le fond provisoire ; le diagnostic conserve l’identifiant/version d’origine et l’état interne bloque la sortie documentaire future. La commande Exporter reste non publique au Lot 1. |
| 5 | Rétablir le catalogue et la copie de secours, puis relancer. | Le fond d’origine réapparaît dans les trois sorties sans migration destructive du document. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — logs structurés, hashes des rendus, référence
  persistée avant/après et capture des trois vues.
- Environnement : à renseigner — macOS, Xcode, SDK, simulateur/appareil et
  configuration exacte de l’injection.

### `APPLE-L1-011` — Échec de sauvegarde, Réessayer et fermeture

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Type : test Apple avec dépôt/journal injecté en échec déterministe.
- Exigences : `3:SAV-003`, `3:SAV-004`, `3:ERR-014`.
- Préconditions : album possédant un snapshot durable A et un hash canonique
  connu ; le double de test peut faire échouer précisément journal, consolidation
  ou flush puis rétablir les écritures sans simuler un disque réellement plein.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Modifier le document vers B, injecter l’échec au prochain flush, puis toucher Sauvegarder. | L’interface affiche « Échec de sauvegarde » et propose Réessayer ; A reste le dernier snapshot durable. |
| 2 | Inspecter le journal récupérable après l’échec. | La commande produisant B est conservée sans état partiel. |
| 3 | Toucher Réessayer pendant que l’échec persiste. | A n’est ni remplacé ni corrompu ; aucune commande n’est dupliquée et l’erreur reste actionnable. |
| 4 | Tenter de revenir à la bibliothèque, puis choisir de rester dans l’éditeur. | Un avertissement explicite empêche une fermeture silencieuse pendant l’échec et l’éditeur reste ouvert. |
| 5 | Rétablir les écritures, toucher Réessayer, attendre « Enregistré » avec l’heure, puis fermer normalement et relancer. | Le flush réussit, l’état visible devient « Enregistré » et la fermeture ne produit plus d’avertissement d’échec. |
| 6 | Relire le document et calculer son hash canonique après la relance. | B est durable avec le hash attendu ; aucun état partiel n’existe et le dernier snapshot valide n’a jamais disparu avant le succès. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — vidéo UI, chronologie des points d’injection, hashes
  A/B, contenu du journal et assertions du double de dépôt.
- Environnement : à renseigner.

### `APPLE-L1-012` — Preuve réseau de confidentialité des photos

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Type : capture réseau sur appareil/simulateur et inspection statique du
  binaire/configuration du candidat.
- Exigences : `3:SEC-001`, `3:SEC-010`.
- Préconditions : utiliser les fixtures non personnelles, réseau actif, capture
  capable d’attribuer les connexions au processus de l’app ; séparer le trafic
  système éventuel du sélecteur Photos du trafic émis par l’application.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Démarrer la capture avant le lancement, puis importer depuis Fichiers les fixtures petite, moyenne et grande. | La capture attribue séparément les connexions au processus de l’app et ne contient aucun envoi des fichiers importés vers un serveur propriétaire. |
| 2 | Placer, recadrer et dupliquer les photos, générer miniatures et couvertures, sauvegarder, fermer, puis relancer. | Aucune donnée photo, dérivé, miniature ou extrait d’album n’est émis par l’app pendant ces opérations. |
| 3 | Répéter le parcours avec une photo déjà téléchargée choisie via PhotosPicker. | L’activité éventuelle du service système Apple est isolée du trafic du processus et aucune émission photo n’est attribuée à l’app. |
| 4 | Inspecter domaines, adresses, méthodes, tailles et corps attribués au processus ; rechercher les signatures binaires et hashes des fixtures dans les requêtes sortantes. | Aucun endpoint propriétaire ni contenu correspondant aux fixtures n’est trouvé dans le trafic de l’app. |
| 5 | Inspecter le binaire, ses dépendances et sa configuration. | Aucun SDK d’analyse comportementale ni endpoint propriétaire implicite non décidé n’est présent. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — fichier de capture, filtre par processus, inventaire
  des destinations, recherche de signatures et rapport d’inspection statique.
- Environnement : à renseigner — outil/proxy, OS, appareil, build et réseau.

### `APPLE-L1-013` — Rendu composite et cache de couverture

- Candidat : `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a`.
- Spécification : 3.0 (`031d2e46c70128c7e633db1f04663949e4531309`).
- Type : test du moteur de rendu avec compteur injecté de compositions et
  métriques explicites de hit/miss/invalidation du cache.
- Exigences : `3:COV-007`.
- Préconditions : album à quatre pages conforme à `IPAD-L1-074` ; couverture
  manuelle sur une occurrence laissant voir le fond, avec cadrage et rotation
  reconnaissables ; taille de miniature et échelle fixées.

| ID | Description | Résultat attendu |
|---:|---|---|
| 1 | Demander la miniature une première fois et observer les compteurs. | Un miss est suivi d’une seule composition par le moteur commun de page. |
| 2 | Comparer la miniature au rendu de page de référence recadré au centre à la taille demandée. | L’image et le recadrage centré correspondent exactement à la référence. |
| 3 | Redemander plusieurs fois la même clé logique, la même taille et la même échelle. | Chaque demande produit un hit sans nouvelle composition. |
| 4 | Modifier successivement le cadrage de l’occurrence cible, le fond de sa page, puis choisir une autre occurrence ; demander la miniature après chaque mutation. | Chaque mutation invalide uniquement l’entrée concernée, provoque une seule recomposition et produit un nouveau rendu fidèle. |
| 5 | Redemander chaque nouvel état sans autre modification. | Chaque état inchangé produit de nouveaux hits sans recomposition. |
| 6 | Modifier un autre album, puis redemander la couverture test. | L’entrée de couverture test reste valide ; aucune invalidation globale sans rapport n’a lieu. |

- Résultat : ⚪ `NON TESTÉ`.
- Preuve : à renseigner — images de référence, hashes, clés anonymisées et
  compteurs hit/miss/composition/invalidation.
- Environnement : à renseigner.

Les documents `.photoalbum`, la lecture, le diaporama, l’animation finale,
l’export et le PDF ne figurent pas dans cette qualification Lot 1 : ils seront
testés avec de nouveaux identifiants lors du Lot 3. Les modèles, le dé, Auto,
le texte, les stickers, formes et cadres décoratifs recevront leurs propres
identifiants lors du Lot 2.

## Résultats de session

| ID exécuté | Date/heure | Résultat observé | Preuve | Anomalie liée | Appareil / OS / Playgrounds |
|---|---|---|---|---|---|
| `IPAD-L2-055…070` sur `64f5342…` (retour libellé `039…054`) | 21 août 2026 | **12 réussites et 4 échecs** : `058`, `061`, `062` et `065` ; toutes les autres fiches sont déclarées réussies globalement | Retour utilisateur détaillé pour les quatre échecs et phrase explicite « tous les autres tests dans `039…054` sont ok », sans capture ni observation par étape pour les réussites ; correspondance un pour un `+16` | `058` : restauration après collage et formats riches ; `061` : dépôt, poignées à petite taille et miniature ; `062` : remplacement ; `065` : alignement des cadres décoratifs | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; paquet du correctif, mode de transfert et orientations non redéclarés ; sources applicatives `94deaf2…` identiques à `64f5342…` |
| `IPAD-L2-039` sur `fce5d92…` | 21 août 2026 | **Échec de compilation à l’étape 1** ; lancement et étapes 2 à 6 non exécutés | Diagnostic exact transmis par l’utilisateur, sans capture : le compilateur ne peut pas type-checker l’expression d’`AppModel` ligne 256 dans un délai raisonnable | Concaténation trop complexe de cinq `Substring` pour former l’UUID stable du catalogue ; découper en sous-expressions `String`, puis créer de nouveaux IDs pour le candidat corrigé | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; transfert et orientation non redéclarés |
| `IPAD-L2-038` sur `6093058…` | 20 août 2026 | **Réussi globalement** : Arrondie, italique, choix actifs, persistance et VoiceOver déclarés conformes | Retour saisi avec un backtick parasite entre `03` et `8`, interprété comme `IPAD-L2-038`, sans capture ni détail par étape | Aucun défaut supplémentaire signalé ; la compacité distincte des boutons reste suivie sous `TBX-027` | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; paysage puis VoiceOver selon la fiche, non redéclarés séparément |
| `IPAD-L2-037` sur `6093058…` | 20 août 2026 | **Réussi globalement** : les trois motifs sont déclarés strictement bornés dans l’éditeur | Retour explicite « IPAD-L2-037 ok », sans capture ni détail par étape | Aucun défaut fonctionnel signalé sur les quatre étapes | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; portrait selon la fiche, non redéclaré séparément |
| `IPAD-L2-036` sur le package présenté comme `6093058…` | 20 août 2026 | **Échec à l’étape 3** : Commit affiche `Non estampillé` ; reste déclaré conforme globalement | Retour explicite « le num du commit n'est pas indiqué, il y a écrit \"non estampillé\" ; sinon le reste est ok », sans capture ni détail par étape | Écart entre l’archive Git contrôlée et le package exécuté ; sélection/copie des 40 caractères non prouvées ; corriger puis créer un nouvel ID | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; orientations et VoiceOver non redéclarés séparément |
| `IPAD-L2-035` sur `3102cda…` | 20 août 2026 | **Réussi globalement** : Arrondie, italique, choix actifs, persistance et VoiceOver déclarés conformes | Retour explicite « c'est ok pour les 2 tests », sans capture ni détail par étape | Les valeurs courantes allongent trop les boutons de format ; reprise ergonomique future sous `TBX-027`, sans invalider cette fiche | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; paysage puis VoiceOver selon la fiche |
| `IPAD-L2-034` sur `3102cda…` | 20 août 2026 | **Réussi globalement** : les trois motifs sont déclarés strictement bornés dans l'éditeur | Retour explicite « c'est ok pour les 2 tests », sans capture ni détail par étape | Aucun défaut fonctionnel signalé ; preuve limitée au candidat exact `3102cda…` | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; portrait selon la fiche |
| `IPAD-L2-033` sur `cb77862…` | 20 août 2026 | **Échec aux étapes 1 et 2** ; étapes 3 et 4 déclarées conformes | Retour détaillé, sans capture | Système/Arrondie trop proches ; Italique visible avec Système, Sérif et Chasse fixe mais pas Arrondie ; nouvelle demande d'état actif pour tous les formats (`TBX-026`) | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; paysage et VoiceOver selon la fiche |
| `IPAD-L2-032` sur `cb77862…` | 20 août 2026 | **Réussi globalement** : sélection conservée, palette et portées en paysage déclarées conformes | Retour explicite « ok », sans capture ni détail par étape | Aucun défaut supplémentaire signalé ; ne couvre que les quatre étapes de la fiche | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; paysage selon la fiche |
| `IPAD-L2-031` sur `cb77862…` | 20 août 2026 | **Réussi globalement** : ordre et séparation des panneaux déclarés conformes | Retour explicite « ok », sans capture ni détail par étape | Aucun défaut supplémentaire signalé ; largeur compacte `APPLE-L2-001` non couverte | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; portrait puis paysage selon la fiche |
| `IPAD-L2-030` sur `cb77862…` | 20 août 2026 | **Échec à l’étape 4** après étapes 1 à 3 réussies | Retour détaillé par étape, sans capture | Descendantes et hauteur automatique corrigées ; chacun des trois motifs recouvre encore l’éditeur, tandis qu’une couleur unie fonctionne | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; portrait selon la fiche |
| `IPAD-L2-029` sur `f0a0cca…` | 19 août 2026 | **Réussi globalement** : profondeur, persistance et accessibilité déclarées conformes | Retour explicite « `IPAD-L2-029` ok », sans capture ni détail par étape | Aucun défaut supplémentaire signalé ; ne couvre aucun autre candidat ni contrôle Apple différé | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; paysage et VoiceOver selon la fiche, réglages non redéclarés |
| `IPAD-L2-028` sur `f0a0cca…` | 19 août 2026 | **Réussi globalement** : géométrie, débordement et modèle texte déclarés conformes | Retour explicite « `IPAD-L2-028` ok », sans capture ni détail par étape | Aucun défaut supplémentaire signalé ; portée limitée aux quatre étapes de la fiche | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 |
| `IPAD-L2-027` sur `f0a0cca…` | 19 août 2026 | **Échec à l’étape 1** ; étapes 2 à 4 déclarées conformes | Retour détaillé par étape, sans capture | Système et Arrondie ont le même rendu ; Italique n’a aucun effet perceptible sur « Bonjour » sélectionné | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 |
| `IPAD-L2-026` sur `f0a0cca…` | 19 août 2026 | **Échec aux étapes 1 et 2 en paysage** ; étapes 3 et 4 sans verdict | Retour détaillé, sans capture | Le clavier masque les dernières couleurs, la palette ne défile pas et fermer le clavier perd la sélection ; mise en couleur d’un seul mot impossible | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; paysage explicitement signalé |
| `IPAD-L2-025` sur `f0a0cca…` | 19 août 2026 | **Échec déclaré à l’étape 3** ; étapes 1, 2 et 4 déclarées conformes avec réserve ergonomique à l’étape 1 | Retour détaillé, sans capture | Fermer le clavier perd la sélection ; la portée zone entière d’Opacité respecte `TBX-012`, mais les trois portées de formats ne sont pas distinguées dans l’interface | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; gêne particulièrement signalée en paysage |
| `IPAD-L2-024` sur `f0a0cca…` | 19 août 2026 | **Échec d’acceptation à l’étape 1** ; étapes 2 à 4 déclarées conformes | Retour détaillé, sans capture | Le menu `+` est accepté ; l’ordre clarifié devient Photos, Texte, Stickers, séparation simple sans titre, Mise en page, Fonds, Cadres et formes | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; `EDT-001` révisé après le retour, nouveau candidat et nouvelle régression requis |
| `IPAD-L2-023` sur `f0a0cca…` | 19 août 2026 | **Échec à l’étape 4** après compilation et étapes 1 à 3 réussies | Retour détaillé, sans capture | Descendantes rognées sur une seule ligne, corrigées visuellement par l’ajout d’une seconde ; avec un motif intégré, le fond passe parfois devant tout l’éditeur ou devient blanc, sans séquence reproductible | Environnement repris : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; aucun contrôle `APPLE-*` inclus |
| `IPAD-L2-022` sur `7bc495e…` | 18 août 2026 | **Échec à l’étape 4 après compilation et lancement réussis indirectement** ; saisie non lisible, suite de la fiche non exécutée | Retour utilisateur explicite, sans capture | La taille était projetée avec `N × H / 3000` au lieu de `N × H / 720`; correction typographique et remplacement par les fiches courtes `023…029` | Environnement repris de la fiche : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; aucun contrôle `APPLE-*` inclus |
| `IPAD-L2-021` sur `0f4b16c…` | 17 août 2026 | **Échec fonctionnel après compilation et lancement réussis** ; seule l’étape 1 est attribuée comme réussite | Retour utilisateur et `IMG_4191.jpg`, reçue dans le dépôt de travail mais non versionnée | Ajout superposé, éditeur noir sur noir, pastilles blanches, échelle incohérente et opacité sans effet visible ; régression complète préparée sous `IPAD-L2-022` | Environnement repris de la fiche : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; aucun contrôle `APPLE-*` inclus |
| `IPAD-L2-020` sur `d882183…` | 17 août 2026 | **Échec de compilation à l’étape 1** ; étapes 2 à 16 non exécutées | `IMG_4188.HEIC` et `IMG_4189.HEIC`, reçues dans le dépôt de travail mais non versionnées | Les contraintes écrivaient plusieurs attributs via un proxy qui ne rend modifiable que leur `AttributeKey`; séparer police, couleur, alignement et interligne sous `IPAD-L2-021` | Environnement repris de la fiche : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; aucun contrôle fonctionnel ni `APPLE-*` inclus |
| `IPAD-L2-019` sur `3944fae…` | 17 août 2026 | **1 réussite** : dialogue compact et cadrage couvrant | Retour global explicite « tout est ok » après remise de cette seule fiche ; aucune capture ni observation par étape jointe | Aucun défaut du candidat signalé ; la preuve ne s’étend ni au nouvel incrément texte ni aux contrôles `APPLE-*` | Environnement repris de la fiche : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 |
| `IPAD-L2-018` sur `7815396…` | 17 août 2026 | **1 réussite** : Remplir l’album, trois densités et commande unique | Retour global explicite « les tests sont ok » après remise de cette seule fiche ; aucune capture ni observation par étape jointe | Aucun défaut de ce candidat signalé ; l’interface compacte et le cadrage demandés avec le retour ont été qualifiés séparément sous `019` | Environnement repris de la fiche : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 |
| `IPAD-L2-017` sur `57afa71…` | 17 août 2026 | **1 réussite** : dialogue interne sans gel, lisible et modal | Retour global explicite « c’est ok » après remise de cette seule fiche ; aucune capture ni observation par étape jointe | Aucun défaut du candidat signalé ; la preuve reste limitée à la fiche et à l’environnement déclarés | Environnement repris de la fiche : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; aucun contrôle `APPLE-*` inclus |
| `IPAD-L2-016` sur `7d8772c…` | 17 août 2026 | **Échec immédiat** : le bouton fige l’app et aucune confirmation ne s’affiche | Retour utilisateur explicite ; aucune capture ; seule l’étape 2 est attribuable au retour | La feuille système à cadre explicite ne s’ouvre pas ; la retirer au profit d’un dialogue interne et créer `IPAD-L2-017` | Environnement repris de la fiche : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; aucun contrôle `APPLE-*` inclus |
| `IPAD-L2-015` sur `8aa7f56…` | 17 août 2026 | **Échec immédiat** : fenêtre minuscule et illisible | Retour utilisateur explicite « ko » ; aucune capture ; seule l’étape 2 est attribuable au retour | Le dimensionnement fitted comprime le `NavigationStack` ; utiliser un cadre iPad explicite et la présentation native en largeur compacte, puis créer un nouvel ID | Environnement repris de la fiche : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; aucun contrôle `APPLE-*` inclus |
| `IPAD-L2-014` sur `02430b1…` | 17 août 2026 | **1 échec ciblé** : ajout en fin, confirmation et réglage déclarés corrects, mais adaptation de la fenêtre non conforme | Retour « tout est ok sauf la taille de la popup » : trop large, trop basse et défilement nécessaire pour lire la fin du pied de texte ; aucune capture ni détail par étape | Étape 11 en échec ; remplacer le formulaire et la hauteur fixe par une présentation ajustée au contenu, puis créer une régression dédiée | Environnement repris de la fiche : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; aucun contrôle `APPLE-*` inclus |
| `IPAD-L2-013` sur `b86c4b3…` | 17 août 2026 | **1 réussite** : action rapide Ajouter une page et libellé Gérer les pages | Retour global explicite « tests ok » après remise de cette seule fiche ; aucune capture ni observation par étape jointe | Aucun défaut du candidat signalé ; la nouvelle règle d’ajout en fin avec confirmation est une évolution ultérieure et recevra un nouvel ID | Environnement repris de la fiche : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; aucun contrôle `APPLE-*` inclus |
| `IPAD-L2-009…012` sur `024a60b…` | 17 août 2026 | **4 réussites** : compilation/compatibilité, adaptation des panneaux, confirmation Appliquer, sélection à nom long et commande aléatoire | Retour global explicite « tous les tests sont ok » après remise des quatre fiches ; aucune capture ni observation par étape jointe ; portée limitée à ces quatre contrôles | Aucune nouvelle anomalie signalée ; les échecs historiques `002` et `004` sont couverts par `010` et `011`, les retours d’ergonomie par `010` et `012` | Environnement repris de l’en-tête : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; détails non redéclarés ; aucun contrôle `APPLE-*` inclus |
| `IPAD-L2-001…008` sur `d427d4e…` | 17 août 2026 | 5 réussites (`001`, `003`, `005`, `006`, `007`), 2 échecs (`002`, `004`) et 1 blocage (`008`) | Retours par identifiant et observations globales ; aucune capture jointe. `002` reste en échec malgré « ok », car le rognage portrait contredit son attente | Panneaux portrait, action Appliquer, ergonomie des panneaux, libellés de sélection et emplacement du dé à reprendre ; menu Plus compact différé | Environnement déclaré en tête de campagne : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; détails non redéclarés dans ce retour |
| `IPAD-L1-063…093` | 16 août 2026 | 31 fiches retranscrites individuellement ci-dessus : 18 réussies, 8 échouées, 4 bloquées et 1 non applicable | Réponses et observations consignées dans chaque fiche ; aucune réussite extrapolée | Correctif regroupé et régressions `109…131` | iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; copie `aeae5c439c461e7994117067d81a416591d348bd` |
| Candidat `06c30b9…` | 16 août 2026 | Compilation impossible : `maximumPixelSize` manquant dans `AlbumCoverView` et paramètre générique non inféré dans `AppModel` | Retour utilisateur avec diagnostics du compilateur | Correctif minimal et contrôle `IPAD-L1-132` | Environnement de campagne déclaré : iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 |
| `IPAD-L1-132` sur `84ec71e…` | 16 août 2026 | 🔴 Échec de compilation : appel `catalogImage(for:)` sans `maximumPixelSize` à la ligne 128 d’`AlbumCoverView` | Diagnostic exact transmis par l’utilisateur | Deux appels corrigés ; nouveau contrôle `IPAD-L1-133` | iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 |
| `IPAD-L1-102`, `109…131`, `133` sur `638c659…` | 16 août 2026 | 25 fiches : 19 réussies, 4 échouées (`113`, `123`, `126`, `128`) et 2 bloquées (`112`, `124`) | Retours par identifiant et captures `IMG_4184.jpg` portrait / `IMG_4185.jpg` paysage conservées hors Git | Corrections et procédures de remplacement `IPAD-L1-134…140` | iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; Paris, France ; français (France) |
| `IPAD-L1-134…140` sur `7a0f2a4…` | 16 août 2026 | 7 fiches : 6 réussies ; `135` échoue encore sur la grille et le bouton local | Retour explicite « tout est ok sauf `135` » ; `IMG_4186.jpg` portrait et `IMG_4187.jpg` paysage conservées hors Git | Grille et action locale reprises par `IPAD-L1-141…142` | iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; Paris, France ; français (France) |
| `IPAD-L1-141…142` sur `48e9fef…` | 16 août 2026 | 2 fiches : `141` réussi par preuve indirecte de lancement ; `142` échoué en portrait | Retour : troisième colonne presque hors écran, bouton d’ajout coupé à gauche et accès Photos/Fonds absent ; aucun résultat paysage distinct extrapolé | Largeur minimale de tout le groupe du canevas reprise par `IPAD-L1-143…144` | iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; Paris, France ; français (France) |
| `IPAD-L1-143…144` sur `101e294…` | 16 août 2026 | 2 fiches réussies ; compilation prouvée indirectement et adaptation portrait/paysage confirmée | Retour explicite « tout est ok maintenant » sur le seul correctif restant ; aucune capture supplémentaire jointe | Passage autorisé à un incrément interne du Lot 2 ; qualifications Apple différées inchangées | iPad 8e génération / iPadOS 26.5.2 / Swift Playgrounds 4.7 ; Paris, France ; français (France) |

## Règle de clôture

La campagne ne permet de déclarer une fiche réussie que si toutes ses étapes
ont été exécutées sur le commit et l’environnement inscrits. Une compilation
WSL du Core ne valide pas SwiftUI/iOS ; un test iPad ne valide pas iPhone,
Xcode, Release, TestFlight, Instruments ni une sortie de Lot 2/3. Toute
anomalie corrigée impose un nouveau commit et, lorsque la preuve antérieure ne
s’applique plus, un nouvel identifiant de régression.
