# Tableau de bord 3.0 — Album Photo

Ce fichier est le suivi opérationnel de la reconstruction 3.0. La source
normative reste [`spec.md`](spec.md), le fonctionnement du dépôt est décrit
dans [`README.md`](README.md) et chaque preuve manuelle est enregistrée dans
[`suivi_tests.md`](suivi_tests.md).

Le tableau de bord précédent reste consultable dans l’historique Git à la base
`06aaa59`. Il n’est pas repris comme preuve du nouveau code : conformément à
`DEC-33`, la reconstruction ne migre ni les sources, ni le store, ni les
résultats du prototype 2.1.

## Fiche du candidat

| Information | Valeur |
|---|---|
| Produit | Album Photo 3.0 |
| Date du suivi | 2026-08-17 |
| Phase courante | Lot 2 — `IPAD-L2-021` échoué ; correctif panneau/rendu texte figé pour `IPAD-L2-022` |
| Base avant reconstruction | `06aaa59` |
| Candidat de première campagne | implémentation `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a` ; copie iPad `aeae5c439c461e7994117067d81a416591d348bd`, déclarée identique |
| Candidat correctif rejeté | `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` — deux erreurs de compilation Apple signalées |
| Second candidat correctif rejeté | `84ec71e1a66df4676e3c388e9d4f87a5a7e06e4e` — appel catalogue incomplet dans `AlbumCoverView` |
| Candidat de deuxième campagne compilé et testé | `638c659925e1b036570484a98c0fc016602687c9`, basé sur `7b13cbd697bbde77c20b85245515874760991d3c` |
| Candidat de troisième campagne compilé et testé | `7a0f2a442f5f13a98663c5c02a97b8110bd943d6` — `134` et `136…140` réussis, `135` échoué |
| Candidat de quatrième campagne ciblée | `48e9fef9c317835f605df430c4112320d8cb66c3` — `141` réussi indirectement, `142` échoué en portrait |
| Candidat d’adaptation validé sur iPad | `101e2948252f51991933b8d61f767f52aa6b629d` ; `IPAD-L1-143…144` réussis |
| Premier incrément Lot 2 | Candidat `d427d4e747dd2de56235341bd661d537a9a31c8e` sur `feature/lot2-composition` ; campagne `IPAD-L2-001…008` exécutée : 5 réussites, 2 échecs, 1 blocage |
| Correctif des retours Lot 2 | Candidat `024a60bcd7b7a837497a5d6a00e8e42cacfd9366` : `IPAD-L2-009…012` réussis ; confirmation capturée par page, marges et panneau droit repliable par section, sélection à nom borné et dé déplacé validés sur iPad |
| Ajustement de navigation Lot 2 testé | Candidat `b86c4b323e0b8d2cfe2fc2e0394ff9d5f3e4e0b4` : Ajouter une page remplace Ajouter une photo sous le canevas ; Organiser devient Gérer les pages ; `IPAD-L2-013` réussi |
| Évolution de l’ajout de page Lot 2 testée | Candidat `02430b16f2853c01dbcafc88d48cd40c48373c4c` : parcours fonctionnel déclaré correct, mais `IPAD-L2-014` échoue car la fenêtre est trop large, trop basse et impose un défilement pour son pied de texte |
| Premier correctif de fenêtre testé | Candidat `8aa7f566de775c15ddf5a9e702a01ed5e9fdb640` : `IPAD-L2-015` échoué immédiatement, la présentation fitted ayant comprimé la fenêtre jusqu’à la rendre minuscule et illisible |
| Seconde correction de fenêtre Lot 2 testée | Candidat `7d8772c6d87a769a239b4f9eafabe74c8c126681` : `IPAD-L2-016` échoue, car le bouton fige l’app sans afficher la confirmation (`PAG-017`) |
| Correctif de gel Lot 2 validé | Candidat `57afa71e3eeac8b48f05e0aaa719cf77e8a97834` : la feuille système et sa négociation de taille sont retirées ; le dialogue interne centré est validé par `IPAD-L2-017`, d’après le retour global « c’est ok » sans capture ni détail par étape (`PAG-017`) |
| Candidat Remplir l’album Lot 2 testé | `781539603d6b98523fe48326ee49e24288dfa09b` : choix des trois densités, plan déterministe, confirmation chiffrée, réutilisation/création de pages et commande unique Annuler/Rétablir ; `IPAD-L2-018` réussi selon le retour global « les tests sont ok » |
| Candidat compact et cadrage Lot 2 testé | `3944fae199b2eb37c7b1f0a1aae5558197455b87` : bouton compact, dialogue interne Densité/compteur/Annuler/Valider et cadrage initial couvrant après géométrie finale ; `IPAD-L2-019` réussi selon le retour global « tout est ok » |
| Candidat zones de texte Lot 2 rejeté | `d882183d31de7ed6078c70f9e79a80d6ba994dd6` : `IPAD-L2-020` échoue dès la compilation d’`AlbumTextEditorView`; captures `IMG_4188.HEIC`/`IMG_4189.HEIC`, aucune étape fonctionnelle exécutée |
| Correctif de compilation texte Lot 2 testé | `0f4b16c6c6435c29ca44da4e2726fac210add520` : compilation et lancement Apple réussis indirectement, mais `IPAD-L2-021` échoue sur l’ajout superposé, le fond noir de l’éditeur, les pastilles blanches, l’échelle et l’opacité ; `IMG_4191.jpg` conservée hors Git |
| Correctif panneau et rendu texte Lot 2 | `7bc495ec623e5b12301569d0108fbccadb978630` : panneau Texte entre Mise en page et Fonds, formats dans l’inspecteur, ajout hors canevas, fond réel, palette colorée, aperçu à l’échelle et opacité immédiate ; 146 tests, contrats, empreintes et parse AppModule réussis ; `IPAD-L2-022` à exécuter |
| Spécification de première campagne | `031d2e46c70128c7e633db1f04663949e4531309` |
| Spécification de troisième campagne | `spec.md` inclus dans `7a0f2a442f5f13a98663c5c02a97b8110bd943d6` |
| Spécification du correctif Lot 2 | `spec.md` dans `024a60bcd7b7a837497a5d6a00e8e42cacfd9366` précise `EDT-002`, `ELM-014` et `RND-001` conformément aux retours utilisateur du 17 août 2026 |
| Enveloppe iPad conservée | `Albumzh.swiftpm` ; son `Package.swift` généré n’a pas été recréé |
| Sources | Anciennes sources 2.1 supprimées, nouvelles sources 3.0 écrites from scratch |
| Stockage 3.0 | Nouvelle génération `AlbumPhotoCanvasV1` ; aucun parcours de migration 2.1 |
| Plateformes cibles | iPhone/iPad, iOS/iPadOS 26 minimum, portrait et paysage |
| Validation disponible | Noyau Swift multiplateforme sous WSL |
| Validation indispensable restante | Transférer puis exécuter `IPAD-L2-022` sur `7bc495ec623e5b12301569d0108fbccadb978630` ; couvrir `EDT-004` et la navigation compacte avec `APPLE-L2-001` sur iPhone/Xcode ; compléter justifié, frappe groupée, stickers, cadres et presse-papiers commun |
| État global | 🟡 **Lot 1 viable sur l’iPad 8 ; l’action compacte et le cadrage couvrant sont validés par `IPAD-L2-019` ; `IPAD-L2-021` compile mais échoue sur cinq défauts de texte, corrigés sous WSL et à requalifier sur Apple avec `IPAD-L2-022`** |

## Légende

| Repère | État | Règle d’emploi |
|---|---|---|
| ⬜ | Non commencé | Aucun travail vérifiable n’a débuté |
| 🟡 | En cours / à valider | Code ou contrat présent, mais preuve de sortie incomplète |
| 🟠 | Bloqué / à risque | Dépendance, ambiguïté normative ou environnement manquant |
| 🟢 | Terminé | Implémentation et toutes les preuves applicables sont acquises |
| ⏸️ | Différé | Travail appartenant explicitement à un lot ultérieur |

Aucun lot ni parcours d’interface de ce candidat n’est marqué 🟢 avant une
preuve Apple/iPad reproductible. Les tests Core réussis prouvent le noyau
portable ; ils ne prouvent ni la compilation SwiftUI avec le SDK Apple, ni les
gestes tactiles, ni l’accessibilité, conformément à `ENV-004` et
`DONE-001` à `DONE-005`.

## Décisions appliquées

| Décision | Application dans le candidat |
|---|---|
| Reconstruction sans migration | `DEC-33` : la racine 3.0 est initialisée indépendamment ; aucun ancien store n’est lu ou converti. |
| Enveloppe Swift conservée | `Albumzh.swiftpm` reste le document créé depuis l’iPad ; seules ses anciennes sources sont remplacées. |
| Une seule page active | `DEC-05`, `GLO-001` : aucun mode ni réglage à deux pages ; la vue globale ne sert qu’à organiser les miniatures. |
| Zoom photo dynamique et cadrage initial | `DEC-07`, section 3.1, `FRM-004`, `FRM-009`, `CRP-001` à `CRP-007` : `1×` reste la taille native ; une nouvelle affectation et Réinitialiser utilisent désormais le facteur centré minimal couvrant le cadre, tandis que la borne basse dynamique autorise toujours le fond visible ; `8×` reste la borne haute. |
| Zoom du canevas séparé | `ZOM-001` à `ZOM-008` : état de fenêtre de session, non sérialisé et distinct du cadrage photo. |
| Frontière stricte des lots | `ARC-014`, `DEC-38` : le jalon Lot 1 reste figé ; la branche Lot 2 expose modèles/dé/Auto puis le premier incrément texte. Stickers, cadres décoratifs, lecture, PDF et export restent masqués. |
| Données locales d’abord | `ARC-002`, section 18 : commandes métier via le service d’application, assets adressés par contenu et transactions journalisées ; les vues SwiftUI n’écrivent pas directement dans la base. |
| Commandes ordonnées | Toutes les opérations publiques du service d’application empruntent une file FIFO commune ; l’éditeur possède en plus une barrière FIFO d’interface afin qu’une fin de tâche ancienne ne puisse pas écraser un état plus récent (`APP-002`, `APP-005`, `LOC-011` à `LOC-014`). |
| RAW non destructif | L’original importé et son dérivé PNG statique immuable sont indexés et validés atomiquement. Le dérivé local est régénérable et reste hors du package logique v1, qui transporte l’original conformément à `PKG-008` et `PKG-021`. |
| Publication transactionnelle | Une erreur avant remplacement du snapshot échoue sans publier ; après remplacement durable, un défaut de nettoyage du journal reste un succès métier et le rejeu/nettoyage est idempotent (`LOC-011` à `LOC-026`). |
| Empreintes en flux | La finalisation, la déduplication, la vérification physique et la réutilisation interalbum calculent SHA-256 par blocs, avec comptage exact, sans charger l’original complet pour le seul hachage. |
| Ressources versionnées | Contrats figés pour 3 fonds, 6 formes natives et leurs 6 masques golden 64 × 48, ainsi que 32 modèles de prototype ; seuls les fonds relèvent de l’interface du lot 1. |
| Ergonomie du correctif Lot 2 | Retour utilisateur du 17 août 2026 : le dé quitte la barre locale et reçoit un libellé visible dans Mise en page (`RND-001`) ; les deux contenus droits choisissent l’option de replis indépendants jusqu’au titre (`EDT-002`) ; le nom visible est tronqué avant position et plan sans tronquer VoiceOver (`ELM-014`). |
| Navigation locale et gestion des pages | Retours utilisateur du 17 août 2026 : la barre sous le canevas privilégie Ajouter une page, l’ajout photo reste dans Photos ou les cadres, et le mode Organiser est renommé Gérer les pages. Les deux commandes ajoutent à la fin de l’album après confirmation ; « Ne plus demander » est un réglage de session modifiable dans Gérer les pages et réinitialisé à la fermeture (`EDT-003`, `EDT-008`, `EDT-016`, `EDT-020`, `PAG-002`, `PAG-013`, `PAG-014`, `PAG-017`). |
| Présentation de la confirmation d’ajout | Retours `IPAD-L2-014…016` : le formulaire défilant est trop large/bas, fitted comprime le contenu et la feuille à cadre explicite fige l’app. La confirmation devient donc un dialogue interne centré, sans feuille système, large de 400 points maximum avec 16 points de marge par côté ; l’éditeur assombri est non interactif et tout le texte reste déployé (`PAG-017`). |
| Remplissage déterministe de l’album | `AUT-009…011` : le panneau Photos ne conserve qu’un bouton compact sous Ajouter des photos ; sa fenêtre porte les trois densités, le nombre de photos inutilisées, l’impact et Annuler/Valider. Les photos sont ordonnées par date, index d’album puis UUID, réparties par capacités 2/4/8, sur les premières pages sans photo puis sur de nouvelles pages en fin d’album, en une commande sans supprimer d’asset. |
| Éditeur de texte SwiftUI | `TXA-001…004`, `TBX-001…025` : le domaine conserve paragraphes et runs sans SwiftUI ; l’adaptateur iOS 26 emploie `TextEditor`, `AttributedTextSelection` et une définition d’attributs bornée. L’ADR-003 maintient l’alignement justifié hors interface tant qu’aucune solution SwiftUI publique n’est disponible ; `TBX-011` reste partiel. |
| Panneau et aperçu du texte | Retour `IPAD-L2-021` : Ajouter un texte quitte le canevas pour un panneau Texte placé entre Mise en page et Fonds, tandis que le menu `+` conserve Ajouter un cadre photo et Ajouter du texte. L’inspecteur expose le contenu et les formats de toute la zone ; la fenêtre reprend le fond réel et la hauteur affichée de la page, affiche ses propres pastilles colorées et prévisualise l’opacité (`EDT-001`, `EDT-008`, `EDT-012`, `EDT-014`, `EDT-021`, `TBX-002`, `TBX-009`, `TBX-012`, `TBX-014`, `TBX-016`, `TBX-025`). |

## Synthèse

| Périmètre | État | Preuve actuelle | Condition de sortie restante |
|---|---|---|---|
| Spécification et architecture 3.0 | 🟡 | Zoom dynamique confirmé ; frontière des lots 1 à 3 arbitrée par `DEC-38` et spécification figée dans la campagne ; ADR, schémas, contrats et traçabilité présents | Qualifier le candidat sur Apple |
| Lot 0 — Prototypes et contrats | 🟡 | Modèle, géométrie, texte, modèles/Auto, navigation, sérialisation, transaction, catalogue, schéma package et plan Cloud couverts par le Core ; intégration App Playground compilée | Prouver les capacités Apple encore bloquées et corriger les écarts fonctionnels du premier incrément Lot 2 |
| Lot 1 — Création locale | 🟡 | Parcours métier validés et adaptation finale confirmée par `143…144` sur `101e294…` | Conserver le jalon iPad ; qualifications iPhone/Xcode et Apple différées empêchent encore l’état 🟢 |
| Lot 2 — Parité de composition | 🟡 | Le dialogue interne, Remplir l’album, l’action compacte et le cadrage couvrant sont validés jusqu’à `IPAD-L2-019`. `0f4b16c…` compile mais échoue sous `IPAD-L2-021`; `7bc495e…` passe 146 tests, les contrats et le parse SwiftUI | Exécuter `IPAD-L2-022`, couvrir la largeur compacte, puis compléter texte, stickers, cadres et presse-papiers commun avant `ACPT-123`, `125`, `126`, `128`, `130` |
| Lot 3 — Consultation/documents | ⏸️ | Schéma `.photoalbum` préparatoire seulement | Démarrer après le lot 2 |
| Lots 4 à 6 | ⏸️ | Plan CloudKit pur uniquement ; aucune capacité publique | Versions ultérieures et qualification dédiée |

**Résultat d’acceptation actuel :** la première campagne `063…093` conserve ses
18 réussites, 8 échecs, 4 blocages et 1 fiche non applicable sur `aeae5c…`. La
deuxième campagne sur `638c659…` ajoute 19 réussites, dont la compilation Apple,
4 échecs (`113`, `123`, `126`, `128`) et 2 blocages de procédure (`112`, `124`).
La troisième campagne sur `7a0f2a4…` ajoute 6 réussites et un échec : `135`
reste en défaut sur les miniatures et le bouton local. La quatrième campagne
ciblée sur `48e9fef…` prouve indirectement sa compilation, mais `142` échoue
encore en portrait : troisième colonne presque hors écran, bouton local coupé
à gauche et accès Photos/Fonds absent dans l’état signalé. Les autres
corrections restent confirmées ; l’adaptation reste 🟡 jusqu’à
`IPAD-L1-143…144`. La cinquième campagne ciblée confirme ensuite ces deux
fiches sur `101e294…`. Le jalon Lot 1 est viable sur l’iPad 8 ; il reste 🟡 au
sens strict de `DONE-001` à `DONE-005` parce que les qualifications iPhone,
Xcode et Apple différées n’ont pas été exécutées. `LOT-003` autorise néanmoins
le passage à l’incrément interne du Lot 2 demandé par l’utilisateur. La
première campagne Lot 2 sur `d427d4e…` ajoute ensuite cinq réussites (`001`,
`003`, `005`, `006`, `007`), deux échecs (`002`, `004`) et un blocage (`008`).
Le rognage portrait empêche de retenir le « ok » synthétique de `002` ; le
bouton Appliquer de `004` ne publie aucun changement et le menu Plus compact de
`008` ne peut pas être atteint dans Swift Playgrounds sur cet iPad. Le candidat
correctif `024a60b…` traite les deux échecs ainsi que le repli, les noms longs
et l’emplacement du dé. Le retour global « tous les tests sont ok » valide les
quatre régressions `IPAD-L2-009…012` sur iPad : les échecs historiques `002`
et `004` sont couverts par `010` et `011`, et les retours d’ergonomie par `010`
et `012`. Cette preuve ne couvre ni `APPLE-L2-001`, ni une autre qualification
Apple différée. Le retour suivant « tests ok » valide séparément
`IPAD-L2-013` sur `b86c4b3…`, sans capture ni détail par étape. La demande
produit reçue avec ce résultat remplace ensuite l’insertion après la page active
par un ajout en fin d’album et introduit une confirmation désactivable pour la
session. `IPAD-L2-014` confirme ce parcours mais échoue sur la seule adaptation
de la fenêtre, trop large et trop basse, avec un pied de texte nécessitant un
défilement. Le premier correctif `8aa7f56…` échoue ensuite sous
`IPAD-L2-015`, car la fenêtre devient minuscule et illisible. La seconde
correction échoue sous `IPAD-L2-016` en figeant l’app, puis le dialogue interne
de `57afa71…` réussit `IPAD-L2-017` selon le retour global « c’est ok ». Cette
preuve reste limitée à l’iPad déclaré et ne couvre aucune qualification
`APPLE-*`. `IPAD-L2-018` valide ensuite globalement Remplir l’album sur
`7815396…`. Enfin, le retour « tout est ok » valide `IPAD-L2-019` sur
`3944fae…`, donc le bouton compact, son dialogue et le cadrage couvrant des
nouvelles affectations, sans capture ni détail par étape. Le nouvel incrément
texte ne réutilise pas cette preuve : `IPAD-L2-020` échoue dès la compilation
de `d882183…`. `0f4b16c…` corrige les proxies, compile et lance l’app, mais
`IPAD-L2-021` relève cinq défauts fonctionnels avec `IMG_4191.jpg` comme preuve
partielle. Le nouveau panneau Texte et le rendu corrigé doivent reprendre toute
la qualification sous `IPAD-L2-022`.

## Première campagne iPad du 16 août 2026

| Groupe | Résultat confirmé | Suite |
|---|---|---|
| Bibliothèque, pages, fonds, couverture et cadrage principal | Parcours métier largement fonctionnels | Corriger lancement, retour post-création, dates de corbeille, insertion de page et page active après Rétablir |
| Photos | Imports et placements de base fonctionnels | Corriger grilles carrées, déduplication intra-album, compteurs, annonce d’usage et modes Ajouter/Remplir/Remplacer |
| Sélection et interface | Transformations réussies | Installer l’inspecteur droit, rendre les choix non ambigus, séparer qualité/commandes, ajouter poignées hybrides et aperçu de rotation |
| Gestes et sauvegarde | Pincement et persistance de base observés | Corriger panoramique à deux doigts, réinitialisation du balayage et fin de geste après Sauvegarder |
| Environnement | iPad 8e génération, iPadOS 26.5.2, Swift Playgrounds 4.7, français (France), Paris | Multi-fenêtre et haptique restent bloqués ; RAW différé jusqu’à une fixture décodable |

## Deuxième campagne iPad du 16 août 2026

| Groupe | Résultat confirmé sur `638c659…` | Suite |
|---|---|---|
| Compilation et stockage | `IPAD-L1-102` et `133` réussis | `134` a ensuite validé `7a0f2a4…` lors de la troisième campagne |
| Persistance, fonds, charge et commandes | `109`, `110`, `114…122`, `125`, `127`, `129…131` réussis | Conserver ces preuves ; rejouer seulement les surfaces modifiées |
| Photos et inspecteur | `111` fonctionnellement réussi ; `113` échoué ; `124` incomplet | Bandeau renforcé, grille plus large et barre locale stabilisée ; `135` et `140` |
| Corbeille et pages | `123` et `126` échoués sur la présentation uniquement | Dates françaises, page active et insertion corrigées ; `136` et `137` |
| Gestes canevas | `128` échoué sur vide et cadres non sélectionnés | Pont UIKit fixé à la fenêtre et arbitrage clarifié ; `138` |
| Procédure qualité | `112` bloqué car « format régional » non expliqué | Nouvelle procédure explicite France/États-Unis sous `139` |

## Troisième campagne iPad du 16 août 2026

| Groupe | Résultat confirmé sur `7a0f2a4…` | Suite |
|---|---|---|
| Compilation | `IPAD-L1-134` réussi | `48e9fef…` a ensuite été exécuté lors de la quatrième campagne ciblée |
| Dates, pages, gestes, qualité et interalbum | `IPAD-L1-136…140` réussis | Conserver les preuves métier ; seule la présentation de grille partagée avec `140` est rejouée |
| Photos et barre du canevas | `IPAD-L1-135` échoué malgré une hauteur de barre corrigée | `142` a confirmé que l’adaptation restait insuffisante |

## Quatrième campagne iPad ciblée du 16 août 2026

| Groupe | Résultat confirmé sur `48e9fef…` | Suite |
|---|---|---|
| Compilation | `IPAD-L1-141` réussi par preuve indirecte : l’éditeur a été lancé et observé | Recompiler le prochain candidat par `143` |
| Portrait, panneau et barre du canevas | `IPAD-L1-142` échoué : troisième colonne presque hors écran, bouton d’ajout coupé à gauche et accès Photos/Fonds absent dans l’état signalé | Rendre adaptatif tout le groupe ajout/zoom/navigation et rejouer `144` en portrait puis paysage |

## Cinquième campagne iPad ciblée du 16 août 2026

| Groupe | Résultat confirmé sur `101e294…` | Suite |
|---|---|---|
| Compilation | `IPAD-L1-143` réussi par preuve indirecte : la régression fonctionnelle a été exécutée | Conserver la qualification Apple différée séparée |
| Portrait, paysage, panneaux et barre du canevas | `IPAD-L1-144` réussi ; le retour « tout est ok maintenant » confirme le seul correctif restant | Passage à l’incrément interne Lot 2 autorisé selon `LOT-003` |

## Première campagne iPad Lot 2 du 17 août 2026

| Groupe | Résultat confirmé sur `d427d4e…` | Suite |
|---|---|---|
| Compilation et compatibilité Lot 1 | `IPAD-L2-001` réussi | La compilation Apple du premier incrément est acquise pour ce candidat uniquement |
| Catalogue et modèles | `IPAD-L2-003` réussi ; `IPAD-L2-004` échoué car Appliquer ne produit aucun changement | Correctif `024a60b…` validé par `IPAD-L2-011` |
| Dé et Auto | `IPAD-L2-005…007` réussis | Dé déplacé dans Mise en page avec libellé visible et `die.face.5.fill` dans `024a60b…`, validé par `IPAD-L2-012` |
| Adaptation de l’éditeur | `IPAD-L2-002` échoué : rail gauche et inspecteur droit encore légèrement rognés en portrait | Marges, largeur et replis indépendants du correctif `024a60b…` validés par `IPAD-L2-010` |
| Largeur compacte et frontière du lot | Parties accessibles de `IPAD-L2-008` déclarées bonnes, mais fiche bloquée faute d’accès au menu Plus compact | Reprendre `EDT-004` sur iPhone, simulateur Xcode ou autre environnement produisant réellement une largeur compacte |
| Ergonomie transversale | Le bouton Replier du panneau gauche agit sur le panneau droit ; les deux contenus droits ne sont pas redimensionnables ; un nom long masque position et profondeur dans Sélectionner un élément | Correctif `024a60b…` validé par `IPAD-L2-010` et `012` : masquage déplacé à droite, deux titres repliables, libellé visible limité à 45 caractères en tronquant seulement le détail et libellé VoiceOver complet |

## Campagne corrective iPad Lot 2 du 17 août 2026

| Groupe | Résultat confirmé sur `024a60b…` | Limite de preuve / suite |
|---|---|---|
| Compilation et compatibilité | `IPAD-L2-009` réussi | Retour global sans capture ; qualification limitée à Swift Playgrounds sur l’iPad déclaré |
| Marges, panneau droit et replis | `IPAD-L2-010` réussi | Couvre le correctif des retours de `002`, pas la matrice iPhone/Xcode |
| Confirmation Appliquer | `IPAD-L2-011` réussi | Couvre l’échec historique `004`, y compris Annuler/Rétablir et relance selon la fiche |
| Sélection à nom long et commande aléatoire | `IPAD-L2-012` réussi | Couvre les retours d’ergonomie ; `APPLE-L2-001` reste nécessaire en largeur compacte |

La preuve est le retour global explicite « tous les tests sont ok », reçu après
remise de ces quatre fiches. Aucun détail par étape ni capture n’a été joint ;
aucun contrôle `APPLE-*` n’est donc extrapolé.

## Campagne de navigation iPad Lot 2 du 17 août 2026

| Groupe | Résultat confirmé | Limite de preuve / suite |
|---|---|---|
| Ajouter une page et Gérer les pages | `IPAD-L2-013` réussi | Retour « tests ok » sans capture ni détail par étape ; le nouveau parcours d’ajout en fin avec confirmation, demandé dans le même retour, doit être validé sous un nouvel ID |
| Ajout en fin et confirmation sur `02430b1…` | `IPAD-L2-014` échoué sur l’adaptation de la fenêtre ; les autres comportements sont déclarés corrects | Retour sans capture ni détail par étape : fenêtre trop large et trop basse, défilement nécessaire pour lire le pied de texte ; correction dédiée à requalifier |
| Premier correctif de fenêtre sur `8aa7f56…` | `IPAD-L2-015` échoué dès l’étape 2 | Retour « ko » sans capture : fenêtre minuscule et illisible ; utiliser un cadre régulier explicite et réserver la présentation page native au compact |
| Second correctif de fenêtre sur `7d8772c…` | `IPAD-L2-016` échoué dès l’étape 2 | Retour sans capture : le bouton fige l’app et aucune confirmation ne s’affiche ; retirer le chemin de feuille système |
| Dialogue interne sur `57afa71…` | `IPAD-L2-017` réussi | Retour global « c’est ok » après remise de cette seule fiche ; aucune capture ni observation par étape, aucune qualification `APPLE-*` extrapolée |

Le parcours demandé ensuite est figé dans
`02430b16f2853c01dbcafc88d48cd40c48373c4c`. `IPAD-L2-014` déclare tous ses
comportements corrects sauf la taille de la fenêtre : trop large, trop basse et
nécessitant un défilement pour lire la fin du pied de texte. Le correctif exact
`8aa7f566de775c15ddf5a9e702a01ed5e9fdb640` est isolé dans `IPAD-L2-015`,
qui échoue à son tour sur une fenêtre minuscule et illisible. Le cadre
explicite de `7d8772c6d87a769a239b4f9eafabe74c8c126681` échoue ensuite sous
`IPAD-L2-016` : le bouton fige l’app sans afficher la confirmation. Le
correctif suivant remplace cette feuille par un dialogue interne. Il est figé
dans `57afa71e3eeac8b48f05e0aaa719cf77e8a97834` et `IPAD-L2-017` réussit son
absence de gel, sa lisibilité et son comportement selon le retour global
« c’est ok », sans capture ni détail par étape.

Le RAW synthétique `raw.dng` reste volontairement hors de ce correctif : son
refus ne permet pas de distinguer une anomalie applicative d’une fixture non
décodable par ImageIO. `IPAD-L1-076` demeure bloqué et aucun résultat RAW n’est
extrapolé.

## Lot 0 — Prototypes et contrats

| Chantier | État | Réalisation et preuve | Reste à faire |
|---|---|---|---|
| Domaine indépendant de SwiftUI | 🟡 | Nouveau `AlbumPhotoCore` : albums, pages, éléments, assets, index, validation et service d’application ; tests WSL inclus et intégration compilée dans l’App Playground (`ARC-001` à `ARC-005`, `DAT-001` à `DAT-043`) | Qualifications Apple différées et sorties de lots complètes |
| Canevas multiélément | 🟡 | Moteurs purs de géométrie, profondeur, hit-testing, poignées, magnétisme, rotation et cadrage dynamique testés (`CAN-001` à `CAN-009`, `ELM-001` à `ELM-014`, `CRP-001` à `CRP-007`) | Valider les gestes, cibles tactiles et retours haptiques sur iPad |
| Zoom de fenêtre et navigation | 🟡 | États purs de zoom ancré, centre normalisé et navigation testés (`ZOM-001` à `ZOM-008`, `NAV-001` à `NAV-007`) | Valider la priorité réelle des reconnaisseurs SwiftUI |
| Texte Photoweb | 🟡 | Domaine pur et adaptateur SwiftUI iOS 26 : styles, limite, hauteur, débordement, rendu commun, commandes et modèles texte. Après le type-check corrigé, le panneau Texte, le fond réel, la palette, l’échelle et l’opacité répondent au retour `021` (`TXA-001…005`, `TBX-001…025`, `TPL-012`, `TPL-013`, `TPL-017`) | Qualifier `IPAD-L2-022` ; justifié `TBX-011`, frappe groupée `TBX-022` et export `TBX-021` restent ouverts |
| Modèles, dé et automatisme | 🟡 | Les 32 modèles canoniques sont embarqués byte à byte ; résolution active/inactive, bijection photo de `DAT-042`, ordre UUID/lecture, commandes atomiques, dé de session et recomposition Auto sont testés puis exposés. Remplir l’album ajoute son plan pur et sa commande transactionnelle (`AUT-009…011`) ; les variantes texte sont maintenant actives | Qualifier les variantes texte avec `IPAD-L2-022` |
| Animation de page | 🟡 | Machine d’état interactive prototypée et testée (`ANI-001` à `ANI-009`) | Animation SwiftUI finale et Réduire les animations au Lot 3 |
| Sérialisation canonique | 🟡 | JSON canonique, empreinte logique SHA-256, exclusion explicite des dérivés locaux régénérables et golden tests du noyau (`DAT-020` à `DAT-028`, `PKG-008`, `PKG-021`) | Reconfirmer les fixtures avec le commit candidat |
| Transactions et reprise | 🟡 | Store adressé par contenu, file FIFO globale, journal, snapshot atomique et injections d’interruption testés, y compris commandes concurrentes ; après publication durable, un échec de nettoyage n’est plus présenté comme un échec métier (`LOC-011` à `LOC-026`) | Tester sur le système de fichiers Apple réel, notamment `afterAssetStaging`, `afterAssetValidation` et `afterGenerationRootPublish` encore sans injection automatisée directe |
| Génération de stockage isolée | 🟡 | Initialisation hors site puis renommage de `AlbumPhotoCanvasV1`, marqueur prêt et snapshot vide valide ; l’ancien store est ignoré (`DEC-33`) | Valider création, relance et manque d’espace sur iPad |
| Contrats de catalogue | 🟡 | Schéma extensible aux stickers/cadres futurs mais registre runtime limité à 3 fonds et 6 formes ; rendu Swift pur des formes, 6 masques golden 64 × 48, 32 modèles et 10 empreintes validés (`CAT-001` à `CAT-009`, `TPL-019`) | Reconfirmer chargement depuis le bundle Apple et repli hors ligne ; figer les payloads Lot 2 avant de les publier |
| Package `.photoalbum` | 🟡 | Schéma v1, documentation, exemple minimal et exemples invalides présents (`PKG-001` à `PKG-022`, `IMP-001` à `IMP-025`) | 🟠 Déclaration UTType, ouverture Fichiers et partage non testées dans Swift Playgrounds |
| CloudKit page par page | 🟠 | Planificateur pur et note de prototype présents (`SYN-001` à `SYN-003`) | Entitlements, zone et opérations CloudKit exigent un environnement Apple compatible |
| Traçabilité | 🟡 | Matrices Lot 0/1 et Lot 2, méthodes automatisées, 104 contrôles iPad, 13 validations Apple différées et 24 scénarios `ACPT` ; `020…021` sont 🔴 et la régression `022` est préparée à ⚪ | Exécuter `IPAD-L2-022` et conserver `008` bloqué jusqu’à une largeur compacte réelle |

### Sortie du lot 0

Le lot 0 n’est pas terminé au sens de `DONE-002`. Les prototypes portables et
les contrats existent et le projet compile désormais dans Swift Playgrounds,
mais le type de document n’est pas validé et CloudKit reste bloqué sur la
chaîne Apple.

## Lot 1 — Création locale

| Fonction | État | Réalisation candidate | Validation restante |
|---|---|---|---|
| Bibliothèque | 🟡 | Création, retour immédiat post-création, tri et cartes adaptatives validés sur `638c659…` (`ALB-006`, `ACPT-100`) | Qualifications iPhone/Xcode et sortie de lot |
| Renommage, corbeille et restauration | 🟡 | Cibles typées, confirmation, restauration, suppression définitive et dates françaises validées par `136` (`ALB-017` à `ALB-025`, `ACPT-102`) | Qualifications iPhone/Xcode et sortie de lot |
| Bail d’édition | 🟡 | Un éditeur modifiable par album, seconde scène en lecture seule (`DEC-29`) | Test multi-fenêtre iPad |
| Éditeur à une page | 🟡 | Une page active sur toutes les tailles ; ancien `AlbumSpreadView` supprimé (`DEC-05`, `GLO-001`, `GLO-002`) | Portrait, paysage, Split View et iPhone réel |
| Pages et vue globale | 🟡 | Ordre, activation après Rétablir, contour/badge actif et insertion intercartes validés par `137` ; après les échecs `IPAD-L2-014…016`, le dialogue interne de `57afa71…` est validé par `IPAD-L2-017` (`PAG-001` à `PAG-017`, `EDT-016`) | Qualifications iPhone/Xcode |
| Fonds par page | 🟡 | Trois fonds, application ciblée/globale, miniatures asynchrones et caches mémoire/disque ; relance et réouvertures hors ligne validées (`IPAD-L1-110`, `116`, `122`) | Instruments et injections de ressource absente |
| Couverture | 🟡 | Choix automatique de la première occurrence ou choix manuel par `pageID + elementID`, empreinte logique et cache de rendu préchargé (`ACPT-103`, `COV-001` à `COV-007`) | Transparence, cadrage, invalidation/suppression de l’occurrence et instrumentation du cache |
| Assets et transactions | 🟡 | Copie locale adressée par SHA-256 en flux borné, index global, dérivé RAW immuable, reprise de journal, commandes atomiques sérialisées et contrôle d’espace (`LOC-001` à `LOC-031`, section 22.8) | Interruption forcée et volume réel sur iPad |
| Import Apple multiple | 🟡 | PhotosPicker ordonné, import Fichiers multiple, progression/annulation/nettoyage, erreurs partielles et déduplication intra-album par `contentHash` sans commande vide (`PHO-001` à `PHO-019`, `APL-001` à `APL-008`, `SEC-008`) | Rejouer imports répétés/lot/annulation ; RAW explicitement différé (`IPAD-L1-121`) |
| Réutilisation interalbum | 🟡 | Parcours autonome `×0→×1→×0`, suppression de la source et compteurs validés par `140` ; présentation de grille confirmée par `144` (`DEC-37`, `PHO-002`, `PHO-015` à `PHO-019`) | Qualifications iPhone/Xcode différées |
| Cadres multiples | 🟡 | Les trois modes, VoiceOver, grille et action locale sont confirmés, la dernière adaptation étant validée par `144` (`FRM-001` à `FRM-009`, `PHO-011` à `PHO-013`, `ELM-014`) | Qualifications iPhone/Xcode différées |
| Cadrage photo | 🟡 | `1×` reste le repère natif ; le cadrage initial couvrant centré et Réinitialiser sont raccordés pour ajout libre, remplissage/remplacement, Auto et remplissage d’album, avec conservation des cadrages existants (`FRM-004`, `FRM-009`, `CRP-001` à `CRP-007`) | Qualifier sur iPad les cas 600×400 et 4 800×6 000, le dézoom révélant le fond, les masques, la persistance et la priorité des gestes |
| Manipulation des éléments | 🟡 | Contour, poignées hybrides, sélection non ambiguë et rotation validés par `115` et `127` ; `024a60b…` borne à 45 caractères le libellé visible en tronquant seulement le nom, tout en conservant position, plan et libellé accessible complet, validé par `IPAD-L2-012` (`ELM-001` à `ELM-014`, `EDT-021`) | Haptique indisponible et qualification iPhone/Xcode différée |
| Zoom du canevas | 🟡 | Pont fixé à la fenêtre et règle vide/élément non sélectionné testée dans le Core puis validée tactilement par `138` (`ZOM-001` à `ZOM-008`) | Qualification XCTest différée |
| Qualité photo | 🟡 | Trois états, libellé informatif et séparateurs France/États-Unis validés par `139` (`QLT-001` à `QLT-006`, `EDT-021`) | Export Lot 3 et qualification Apple différée |
| Sauvegarde et annulation | 🟡 | Interruption, sauvegarde pendant geste, commande unique et transitions rapides validées par `109`, `129`, `131` (`SAV-001` à `SAV-004`, `UND-001` à `UND-012`) | Injection d’échec durable Apple (`APPLE-L1-011`) |
| Presse-papiers | 🟡 | Portée session/album et invalidation après fermeture ou arrière-plan validées par `IPAD-L1-130` (`CLP-001` à `CLP-006`) | Étendre et requalifier avec les types du Lot 2 |
| Navigation | 🟡 | Boutons, balayages et arbitrage avec le pont gestuel validés par `138` ; la barre locale proposant Ajouter une page est validée par `IPAD-L2-013` et sa confirmation corrigée par `IPAD-L2-017` (`NAV-001` à `NAV-007`, `EDT-020`, `PAG-013`, `PAG-017`) | Qualification XCTest/iPhone différée |
| Prévisualisation et aide | 🟡 | Rendu sans aides d’édition, alerte de cadre vide et aide hors ligne contextuelle pour les panneaux exposés | Comparer rendu éditeur/global/prévisualisation et accessibilité |
| Adaptation/accessibilité | 🟡 | Commandes, VoiceOver, Dynamic Type, pointeur et Réduire les animations validés ; la barre à deux rangées, le rail et les trois colonnes étaient confirmés par `144`, avant le remplacement de son action locale (`EDT-002`, `EDT-020`, `ACC-001` à `ACC-021`) | Requalifier la barre modifiée sur iPad ; matrice iPhone/Xcode et Accessibility Inspector différés |

### Sortie du lot 1

Le lot reste 🟡. Le candidat `7a0f2a442f5f13a98663c5c02a97b8110bd943d6`
compile dans Swift Playgrounds et confirme six des sept régressions ciblées.
Dates, pages, gestes, qualité et réutilisation interalbum sont validés. Le
candidat `48e9fef9c317835f605df430c4112320d8cb66c3` compile lui aussi, mais
`IPAD-L1-142` confirme que l’adaptation Photos reste en échec en portrait. Le
candidat `101e2948252f51991933b8d61f767f52aa6b629d` corrige finalement cette
régression et réussit `IPAD-L1-143…144`. Le jalon est viable sur l’iPad 8 et
permet le passage au Lot 2 selon `LOT-003`, sans déclarer le Lot 1 🟢 avant les
qualifications différées exigées par `DONE-001` à `DONE-005`.

## Lot 2 — Parité de composition

| Fonction | État | Réalisation candidate | Validation ou suite restante |
|---|---|---|---|
| Catalogue de modèles | 🟡 | `docs/layout-templates-v1.json` est généré dans le Core sans divergence ; les 32 définitions sont compilées et parcourues sur iPad, puis l’interface corrigée est requalifiée par `IPAD-L2-010` (`TPL-002`, `TPL-003`, `TPL-019`, `TPL-020`, `DAT-042`) | Variantes texte activées dans le correctif et à qualifier sous `IPAD-L2-022` |
| Panneaux de création | 🟡 | Les marges, la largeur droite à 324 points et les replis de `024a60b…` sont validés par `IPAD-L2-010`. Le candidat ajoute Texte entre Mise en page et Fonds et conserve la sélection (`EDT-001`, `EDT-002`, `EDT-006`, `TPL-001`, `TPL-002`) | Qualifier le nouvel ordre et le panneau Texte sous `IPAD-L2-022`; largeur compacte iPhone/Xcode différée |
| Application des modèles | 🟡 | Modèle plus grand validé sous `IPAD-L2-003` ; requête capturée et `pageID` du modèle plus petit validés par `IPAD-L2-011`, Annuler/Rétablir et relance inclus. Les slots texte créent maintenant une zone vide éditable et absente des sorties finales (`TPL-004…023`) | Qualifier les modèles Avec texte sous `IPAD-L2-022` |
| Dé | 🟡 | Compatibilité, sac sans répétition, Annuler/Rétablir et persistance réussis sous `IPAD-L2-005` ; nouvel emplacement, libellé visible, icône `die.face.5.fill` et absence dans la barre locale validés par `IPAD-L2-012` (`RND-001…006`) | Qualification compacte iPhone/Xcode encore différée |
| Mise en page auto | 🟡 | Interrupteur, densités et recomposition réussis sous `IPAD-L2-006…007` ; `IPAD-L2-018` valide les capacités 2/4/8, le tri stable, les groupes, les pages et la commande unique. `IPAD-L2-019` valide le dialogue compact et le cadrage couvrant de `3944fae…` (`AUT-001…019`, `PHO-014`, `FRM-009`, `TPL-005`, `UND-001`) | Sortie complète du Lot 2 et largeur compacte encore restantes |
| Navigation locale et pages | 🟡 | Après les échecs de présentation `IPAD-L2-014…016`, le dialogue interne de `57afa71…` bloque l’éditeur sous-jacent et réussit `IPAD-L2-017` (`EDT-003`, `EDT-008`, `EDT-016`, `EDT-020`, `PAG-002`, `PAG-013` à `PAG-017`) | Retour global sans capture ni détail ; largeur compacte iPhone/Xcode restante |
| Zones de texte | 🟡 | Éditeur riche, styles, limite 1 000, hauteur, débordement, persistance et rendu commun. `0f4b16c…` compile mais `021` relève cinq défauts ; `7bc495e…` déplace l’ajout dans Texte, reprend fond/échelle, colore la palette et rend l’opacité immédiate (`TBX-001…025`, `TXA-001…005`) | Exécuter `IPAD-L2-022` ; justifié, délai 750 ms, export et finition du collage pris en charge restent ouverts |
| Stickers et cadres décoratifs | ⬜ | Aucun sticker ni cadre décoratif Lot 2 persisté | Figer assets/licences `CAT-009` avant implémentation |

Ce premier incrément reste 🟡 : le candidat initial compte cinq réussites, deux
échecs et un blocage, puis le correctif `024a60b…` réussit les quatre
régressions `IPAD-L2-009…012`. Les échecs historiques restent enregistrés mais
sont couverts par les nouveaux IDs. Le candidat `b86c4b3…` ajuste ensuite la
barre locale et le nom du mode pages ; `IPAD-L2-013` le valide sur iPad. La
demande suivante ajoute la confirmation et déplace la création à la fin de
l’album dans `02430b1…` ; `IPAD-L2-014` confirme ces comportements mais échoue
sur la taille et le défilement de la fenêtre. `IPAD-L2-015` échoue ensuite sur
la fenêtre minuscule de `8aa7f56…`, puis `IPAD-L2-016` sur le gel sans fenêtre
de `7d8772c…`. Le dialogue interne de `57afa71…` réussit ensuite
`IPAD-L2-017` selon le retour global « c’est ok ».
`IPAD-L2-008` reste
bloqué uniquement pour la largeur compacte, reprise par `APPLE-L2-001`.
Remplir l’album couvre maintenant `AUT-009…011` sur l’iPad déclaré grâce à
`IPAD-L2-018`, selon un retour global sans capture ni détail par étape. La
nouvelle demande produit remplace toutefois son grand groupe permanent par un
bouton et une fenêtre, et change le cadrage initial. Ces changements sont figés
dans `3944fae…` ; le retour global « tout est ok » qualifie maintenant
`IPAD-L2-019`, sans capture ni détail par étape. Le développement enchaîne avec les
zones de texte dans `d882183…`, mais `IPAD-L2-020` échoue dès la compilation.
Le correctif `0f4b16c…` structure la portée comme le modèle Apple, compile et
lance l’app ; `IPAD-L2-021` relève toutefois cinq défauts fonctionnels. Le
correctif suivant ajoute le panneau Texte, retire l’action superposée et reprend
le fond, la palette, l’échelle et l’opacité avant la régression `IPAD-L2-022`.
L’incrément ne prétend satisfaire aucune autre sortie finale du Lot 2.

## Arbitrage normatif appliqué

L’utilisateur a validé le 10 août 2026 la frontière stricte formalisée par
`DEC-38` :

- le Lot 1 reste la création photo locale avec les panneaux Photos et Fonds ;
- `ACPT-123` et `ACPT-130` deviennent des sorties du Lot 2, avec les cinq
  panneaux et le presse-papiers commun photo/texte/sticker ;
- `ACPT-127` devient une sortie du Lot 3, lorsque lecture et PDF sont livrés.

Les candidats Lot 1 jusqu’à `101e2948252f51991933b8d61f767f52aa6b629d`
conservent cette frontière. La branche `feature/lot2-composition` ouvre
désormais explicitement le premier incrément Lot 2 ; aucun comportement du
Lot 3 n’est rendu public.

## Garde-fous contre les erreurs du prototype 2.1

| Risque historique | Garde-fou 3.0 | Preuve encore nécessaire |
|---|---|---|
| Mauvaise portée d’un modificateur SwiftUI et imports Apple manquants | Vues réécrites en sous-vues plus petites, imports explicites, analyse syntaxique de toutes les sources AppModule | Type-check et compilation avec le SDK Apple |
| Expression SwiftUI trop complexe à compiler | Éditeur, canevas, panneaux, vue globale et composants de bibliothèque séparés | Compilation réelle dans Swift Playgrounds |
| Dialogue agissant sur la mauvaise cible ou perdant la cible avant confirmation | États de commandes et cibles typés ; la cible vit jusqu’à la résolution | Renommage, corbeille et suppression définitive manuels |
| Aperçu non rafraîchi, doubles sources de vérité ou réponses asynchrones réordonnées | `EditorViewModel` et service d’application centralisent les mutations ; les vues ne persistent rien directement ; files FIFO Core et interface | Changement rapide, fermeture, relance et multi-fenêtre (`IPAD-L1-131`) |
| Commande annoncée en échec après publication durable | La frontière de publication est explicite : les défauts de nettoyage post-snapshot sont récupérés de manière idempotente et ne provoquent pas une seconde action utilisateur | Injection équivalente sur le système de fichiers Apple |
| Import annulé laissant des temporaires ou terminant hors ordre | La barrière commence avant le transfert PhotosPicker ; la tâche est annulable et nettoie ses temporaires au `defer` et au lancement | Import long, fermeture de l’éditeur et relance (`IPAD-L1-107`) |
| Photo débordant de son cadre | Rendu masqué et geometry engine commun ; cadrage non destructif persistant | Cas réels rectangulaires, transparence et couverture |
| Reconnaisseurs de cadrage actifs hors mode | Sous-arbre et commandes de cadrage conditionnels ; navigation et transformation désactivées pendant le cadrage | Gestes tactiles imbriqués sur iPad |
| Navigation cassée par les gestes de cadrage | Priorités explicites, reconnaisseur deux doigts unifié qui annule les touches de navigation concurrentes, identité de page et drapeaux de balayage réinitialisés | Balayages et gestes combinés de `IPAD-L1-128` |
| Pincement qui saute ou empêche le panoramique | Zoom et translation composés depuis une origine commune autour du point médian ; calcul pur couvert par `testCanvasTwoFingerTransformComposesScaleAndTranslation` | Vérifier tactilement l’ancrage continu à 50–400 % |
| Rotation difficile ou décalée du doigt | Poignée dédiée, alternative Rotation… et calcul géométrique indépendant du rendu | Toucher, Apple Pencil, pointeur et VoiceOver |
| Poignées trompeuses sur un cadre débordant | La poignée visuelle reste sur la bordure réelle ; une cible de secours distincte, pointillée et accessible est recalée uniquement si nécessaire | Vérifier cadre débordant et tourné (`IPAD-L1-115`, `IPAD-L1-127`) |
| Complexité du mode deux pages | Anciennes vues de double page supprimées ; une seule page logique et visuelle partout | Portrait, paysage et Split View |

## Validations exécutées

| Environnement | Commande ou contrôle | Résultat connu | Portée et limite |
|---|---|---|---|
| Dépôt, registre du panneau Texte, 2026-08-17 | Contrôle de `IPAD-L2-021`, des IDs synthétiques/détaillés et du tableau de `IPAD-L2-022` | **OK** : 22/22 IDs Lot 2 ; `021` enregistré 🔴 avec étape 1 réussie indirectement ; 16 étapes pour `022`, initialisé à ⚪ | `IMG_4191.jpg` prouve le bouton superposé et l’écart de taille ; les constats de fond, couleur et opacité restent des observations utilisateur sans capture correspondante |
| WSL, Swift 6.3.3 et frontend Swift, 2026-08-17 | `swift test --parallel`, test ciblé `ManifestContractTests.testTextEditorUsesNativeAttributedSelectionAndActivatesTextTemplates` et parse de tout AppModule après panneau/rendu texte | **146 tests, 0 échec** ; contrat ciblé **1 test, 0 échec** ; parse **OK** | Vérifie le Core et, structurellement, le panneau Texte, l’inspecteur, l’unique raccourci supérieur, le fond réel, l’échelle, la palette et l’opacité ; sans type-check ni rendu Apple |
| WSL, contrats, 2026-08-17 | `perl tools/validate_contracts.pl` et `sha256sum -c catalog-checksums-v1.sha256` après panneau/rendu texte | **OK** : contrats et **10/10 empreintes** | 32 modèles, 3 fonds, 6 formes, schémas et fixture package inchangés ; pas une preuve Apple du texte |
| iPad 8 déclaré, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-17 | `IPAD-L2-021` sur `0f4b16c6c6435c29ca44da4e2726fac210add520` | **ÉCHEC fonctionnel après compilation réussie** | Ajout superposé, éditeur noir sur noir, pastilles blanches, taille incohérente et opacité sans effet visible ; étapes non commentées non attribuées, capture `IMG_4191.jpg` hors Git |
| Dépôt, registre du correctif texte, 2026-08-17 | Contrôle des IDs synthétiques/détaillés et des tableaux `IPAD-L2-020…021` | **OK** : 21/21 IDs Lot 2 ; `020` enregistré 🔴 à l’étape 1 ; 16 étapes pour `021`, initialisé à ⚪ | Les captures `IMG_4188.HEIC` et `IMG_4189.HEIC` étayent le diagnostic mais restent volontairement non versionnées |
| WSL, Swift 6.3.3, 2026-08-17 | `swift test --parallel` et test ciblé du contrat après séparation des contraintes de texte | **146 tests, 0 échec** ; contrat ciblé **1 test, 0 échec** | Le contrat vérifie la portée imbriquée et une seule sortie modifiable par `AttributeKey` ; ne type-checke pas les API Apple |
| WSL, frontend Swift, 2026-08-17 | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` après correction d’`AlbumTextEditorView` | **OK** | Syntaxe de la portée imbriquée et des quatre contraintes ; sans SDK Apple ni type-check SwiftUI |
| iPad 8 déclaré, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-17 | `IPAD-L2-020` sur `d882183d31de7ed6078c70f9e79a80d6ba994dd6` | **ÉCHEC de compilation à l’étape 1** | `FontAttribute`, `ForegroundColorAttribute` et `TextAlignmentAttribute` étaient écrits via un proxy dont l’`AttributeKey` déclaré était différent ; étapes 2 à 16 non exécutées |
| Dépôt, registre texte, 2026-08-17 | Contrôle de `IPAD-L2-019`, des IDs synthétiques/détaillés et du tableau de `IPAD-L2-020` | **OK** : 20/20 IDs Lot 2 ; `019` enregistré 🟢 ; 16 étapes pour `020`, initialisé à ⚪ | Contrôle documentaire ; le retour `019` reste global et aucune preuve Apple du texte n’est extrapolée |
| WSL, Swift 6.3.3, 2026-08-17 | `swift test --parallel` après intégration des zones de texte | **146 tests, 0 échec** | Couvre manifeste de polices, contraste initial, hauteur/débordement, commandes atomiques, redimensionnement manuel, modèles texte et contrats source ; ne valide pas SwiftUI/iOS |
| WSL, frontend Swift, 2026-08-17 | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` après intégration de l’éditeur riche | **OK** | Syntaxe de l’adaptateur `AttributedString`, de l’éditeur, du rendu et des raccords ; sans type-check SwiftUI ni disponibilité réelle des API Apple |
| WSL, contrats, 2026-08-17 | `perl tools/validate_contracts.pl` depuis la racine et `sha256sum -c catalog-checksums-v1.sha256` depuis `docs/` | **OK** : contrats et **10/10 empreintes** | 32 modèles, 3 fonds, 6 formes, schémas et fixture package inchangés ; pas une preuve Apple du texte |
| iPad 8 déclaré, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-17 | `IPAD-L2-019` sur `3944fae199b2eb37c7b1f0a1aae5558197455b87` | **RÉUSSI** | Retour global « tout est ok » après remise de la seule fiche ; aucune capture ni observation par étape ; aucune qualification `APPLE-*` extrapolée |
| Dépôt, registre compact/cadrage, 2026-08-17 | Contrôle du candidat exact, des IDs synthétiques/détaillés et du tableau de `IPAD-L2-019` | **OK** : 19/19 IDs Lot 2 ; 12 étapes pour `019` ; nouveau contrôle initialisé à ⚪ | Contrôle documentaire uniquement ; aucune preuve Apple du bouton, du dialogue ou du cadrage couvrant |
| WSL, Swift 6.3.3, 2026-08-17 | `swift test --parallel` après action compacte et cadrage initial couvrant | **139 tests, 0 échec** | Couvre petite/grande photo, ajout libre, remplissage de cadre, géométrie finale Auto et remplissage d’album, conservation du cadrage existant et contrat UI ; ne valide pas SwiftUI/iOS |
| WSL, frontend Swift, 2026-08-17 | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` après dialogue de densité | **OK** | Syntaxe du bouton compact, du dialogue interne, du sélecteur et du raccord ViewModel ; sans type-check SwiftUI ni rendu Apple |
| WSL, contrats, 2026-08-17 | `perl tools/validate_contracts.pl` et `sha256sum -c catalog-checksums-v1.sha256` depuis `docs/` | **OK** : contrats et **10/10 empreintes** | Ressources inchangées ; pas une preuve du rendu ou du toucher Apple |
| iPad 8 déclaré, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-17 | `IPAD-L2-018` sur `781539603d6b98523fe48326ee49e24288dfa09b` | **RÉUSSI** | Retour global « les tests sont ok » après remise de la seule fiche ; aucune capture ni observation par étape ; ne couvre pas les changements demandés avec le retour |
| WSL, passe intermédiaire, 2026-08-17 | Premiers `swift test` après changement de règle | **Échecs attendus des anciennes assertions `1×` et du contrat de l’ancien groupe, puis un attendu géométrique de fixture corrigés** | Les tests ont été réécrits pour vérifier la couverture effective ; la passe finale de 139 tests est la preuve retenue |
| Dépôt, registre Remplir l’album, 2026-08-17 | Contrôle du candidat, des IDs synthétiques/détaillés et du tableau de `IPAD-L2-018` | **OK** : 18/18 IDs Lot 2 ; 10 étapes pour `018` ; nouveau contrôle initialisé à ⚪ | Contrôle documentaire uniquement ; aucune preuve Apple de Remplir l’album |
| WSL, Swift 6.3.3, 2026-08-17 | `swift test --parallel` après implémentation de Remplir l’album | **137 tests, 0 échec** | Ajoute les preuves du tri/groupement déterministe, de la réutilisation/création de pages, de la conservation des assets et de la commande unique Annuler/Rétablir ; ne valide pas SwiftUI/iOS |
| WSL, frontend Swift, 2026-08-17 | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` après ajout de Remplir l’album | **OK** | Syntaxe du panneau Photos, de la confirmation et du raccord ViewModel ; sans type-check SwiftUI ni rendu Apple |
| WSL, contrats, 2026-08-17 | `perl tools/validate_contracts.pl` puis `sha256sum -c catalog-checksums-v1.sha256` depuis `docs/` après Remplir l’album | **OK** : contrats et **10/10 empreintes** | Ressources inchangées ; pas une preuve du rendu ou du toucher Apple |
| iPad 8 déclaré, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-17 | `IPAD-L2-017` sur `57afa71e3eeac8b48f05e0aaa719cf77e8a97834` | **RÉUSSI** | Retour global « c’est ok » après remise de la seule fiche ; aucune capture ni observation par étape ; aucune qualification `APPLE-*` extrapolée |
| Dépôt, registre du correctif de gel, 2026-08-17 | Contrôle du candidat, des IDs synthétiques/détaillés, du résultat `016` et du tableau de `IPAD-L2-017` | **OK** : 17/17 IDs Lot 2 ; 6 étapes pour `017` ; les 6 fiches détaillées encore à ⚪ utilisent `ID`/`Description`/`Résultat attendu` | Contrôle documentaire uniquement ; aucune preuve Apple du dialogue interne |
| WSL, Swift 6.3.3, 2026-08-17 | `swift test --parallel` après remplacement de la feuille par le dialogue interne | **134 tests, 0 échec** | Contrat source sur l’absence de la feuille fautive, le fond bloquant, la largeur maximale et les marges ; aucun rendu Apple |
| WSL, frontend Swift, 2026-08-17 | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` après correction du gel | **OK** | Syntaxe du dialogue interne et de sa surcouche ; sans type-check SwiftUI ni rendu Apple |
| WSL, contrats, 2026-08-17 | `perl tools/validate_contracts.pl` puis `sha256sum -c catalog-checksums-v1.sha256` depuis `docs/` après correction du gel | **OK** : contrats et **10/10 empreintes** | Ressources inchangées ; pas une preuve du rendu ou du toucher Apple |
| iPad 8 déclaré, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-17 | `IPAD-L2-016` sur `7d8772c6d87a769a239b4f9eafabe74c8c126681` | **ÉCHEC immédiat** | Presser le bouton fige l’app sans afficher la confirmation ; étapes 3 à 6 non attribuées, aucune capture ni qualification `APPLE-*` |
| Dépôt, registre du second correctif de fenêtre, 2026-08-17 | Contrôle du candidat, des IDs synthétiques/détaillés et du tableau de `IPAD-L2-016` | **OK** : 16/16 IDs Lot 2 ; 6 étapes pour `016` ; les 6 fiches détaillées encore à ⚪ utilisent `ID`/`Description`/`Résultat attendu` | Contrôle documentaire uniquement ; aucune preuve Apple du second correctif |
| WSL, Swift 6.3.3, 2026-08-17 | `swift test --parallel` après seconde correction de fenêtre | **134 tests, 0 échec** | Contrat source sur cadre régulier 400 × 340 et présentation compacte `.page` ; aucun rendu Apple |
| WSL, frontend Swift, 2026-08-17 | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` après seconde correction | **OK** | Syntaxe de la branche par classe de largeur ; sans type-check SwiftUI ni rendu Apple |
| WSL, contrats, 2026-08-17 | `perl tools/validate_contracts.pl` et `sha256sum -c catalog-checksums-v1.sha256` après seconde correction | **OK** : contrats et **10/10 empreintes** | Ressources inchangées ; pas une preuve visuelle |
| iPad 8 déclaré, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-17 | `IPAD-L2-015` sur `8aa7f566de775c15ddf5a9e702a01ed5e9fdb640` | **ÉCHEC immédiat** | Fenêtre minuscule et illisible dès l’étape 2 ; étapes suivantes non attribuées, aucune capture ni qualification `APPLE-*` |
| Dépôt, registre du correctif de fenêtre Lot 2, 2026-08-17 | Contrôle du candidat, des IDs synthétiques/détaillés et du tableau de `IPAD-L2-015` | **OK** : 15/15 IDs Lot 2 ; 6 étapes pour `015` ; les 6 fiches détaillées encore à ⚪ utilisent `ID`/`Description`/`Résultat attendu` | Contrôle documentaire uniquement ; aucune preuve Apple du correctif |
| WSL, Swift 6.3.3, 2026-08-17 | `swift test --parallel` après adaptation de la fenêtre | **134 tests, 0 échec** | Le contrat source vérifie largeur idéale 400, plafond 420, dimensionnement ajusté et retrait de l’ancien detent 280 ; aucun rendu Apple |
| WSL, frontend Swift, 2026-08-17 | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` après adaptation de la fenêtre | **OK** | Syntaxe de la pile non défilante et de `presentationSizing(.fitted)` ; sans type-check SwiftUI ni rendu Apple |
| WSL, contrats, 2026-08-17 | `perl tools/validate_contracts.pl` et `sha256sum -c catalog-checksums-v1.sha256` après adaptation de la fenêtre | **OK** : contrats et **10/10 empreintes** | Ressources inchangées ; pas une preuve visuelle |
| iPad 8 déclaré, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-17 | `IPAD-L2-014` sur `02430b16f2853c01dbcafc88d48cd40c48373c4c` | **ÉCHEC ciblé** | Tout déclaré correct sauf fenêtre trop large, trop basse et pied de texte après défilement ; aucune capture ni qualification `APPLE-*` |
| Dépôt, registre de l’ajout de page Lot 2, 2026-08-17 | Contrôle du candidat, des IDs synthétiques/détaillés et du tableau de `IPAD-L2-014` | **OK** : 14/14 IDs Lot 2 ; 12 étapes pour `014` ; les 6 fiches détaillées encore à ⚪ utilisent `ID`/`Description`/`Résultat attendu` | Contrôle documentaire uniquement ; aucune preuve Apple du nouveau candidat |
| WSL, Swift 6.3.3, 2026-08-17 | `swift test --parallel` après ajout en fin d’album et confirmation de session | **134 tests, 0 échec** | Prouve l’ajout Core en fin et vérifie statiquement les deux raccords à la confirmation ainsi que le réglage temporaire ; ne valide pas SwiftUI/iOS |
| WSL, frontend Swift, 2026-08-17 | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` après confirmation de l’ajout | **OK** | Syntaxe de la fenêtre, de sa case, du réglage Gérer les pages et des deux commandes ; sans type-check SwiftUI ni disponibilité réelle des symboles |
| WSL, contrats, 2026-08-17 | `perl tools/validate_contracts.pl` et `sha256sum -c catalog-checksums-v1.sha256` après évolution des pages | **OK** : contrats et **10/10 empreintes** | Ressources inchangées ; ne valide pas le rendu Apple de la confirmation |
| iPad 8 déclaré, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-17 | `IPAD-L2-013` sur `b86c4b323e0b8d2cfe2fc2e0394ff9d5f3e4e0b4` | **1 réussite** | Retour « tests ok » sans capture ni détail par étape ; ne couvre pas l’évolution ultérieure d’ajout en fin avec confirmation ni `APPLE-*` |
| Dépôt, registre de navigation Lot 2, 2026-08-17 | Contrôle de `IPAD-L2-013`, du hash candidat et du tableau des étapes | **OK** : 13/13 IDs Lot 2 synthétiques et détaillés ; 9 étapes numérotées ; les 5 fiches encore à ⚪ utilisent le tableau requis | Contrôle documentaire ; résultat Apple de `013` enregistré séparément |
| WSL, Swift 6.3.3, 2026-08-17 | `swift test --parallel` après remplacement de l’action locale et renommage du mode pages | **134 tests, 0 échec** | Ajoute un contrat statique sur Ajouter une page, l’absence de l’ancien raccord photo et Gérer les pages ; ne valide pas SwiftUI/iOS |
| WSL, frontend Swift, 2026-08-17 | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` après ajustement de navigation | **OK** | Syntaxe de la nouvelle action, du libellé et du retrait du mode photo redondant ; sans type-check SwiftUI ni disponibilité réelle du symbole |
| WSL, Swift 6.3.3, 2026-08-17 | `swift test --parallel` après correction des retours Lot 2 | **133 tests, 0 échec** | Ajoute 2 tests `ELM-014`/`ACC-002` sur la troncature ciblée et le libellé accessible complet ; ne valide pas SwiftUI/iOS |
| WSL, frontend Swift, 2026-08-17 | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` | **OK** | Syntaxe de la confirmation capturée, du panneau droit repliable et du dé déplacé ; sans type-check SwiftUI ni disponibilité réelle des symboles |
| WSL, contrats, 2026-08-17 | `perl tools/validate_contracts.pl` et `sha256sum -c catalog-checksums-v1.sha256` | **OK** : contrats et **10/10 empreintes** | Vérifie les catalogues et ressources inchangés ; pas le rendu Apple du correctif |
| iPad 8 déclaré, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-17 | `IPAD-L2-009…012` sur `024a60bcd7b7a837497a5d6a00e8e42cacfd9366` | **4 réussites** | Retour global « tous les tests sont ok » sans capture ni détail par étape ; environnement repris de l’en-tête et non redéclaré ; aucune qualification `APPLE-*` extrapolée |
| Dépôt, registre du correctif Lot 2, 2026-08-17 | Comptage des IDs synthétiques/détaillés, champs obligatoires, hash candidat, traçabilité et format des étapes | **OK** : 12 IDs `IPAD-L2` synthétiques et 12 fiches détaillées ; `009…012` sont 🟢 et les 5 fiches Apple détaillées restant à ⚪ conservent leurs tableaux `ID`/`Description`/`Résultat attendu` | Contrôle documentaire ; aucune preuve Apple extrapolée |
| iPad 8 déclaré, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-17 | `IPAD-L2-001…008` sur `d427d4e747dd2de56235341bd661d537a9a31c8e` | **5 réussites, 2 échecs, 1 blocage** ; compilation réussie | Retours par ID sans capture ; environnement repris de la fiche de campagne et non redéclaré. `002` échoue sur le rognage portrait, `004` sur Appliquer sans effet, `008` est bloqué faute de largeur compacte |
| WSL, Swift 6.3.3, 2026-08-16 | `swift test --parallel` après le premier incrément modèles/dé/Auto | **131 tests, 0 échec** | Cœur portable, catalogue runtime et transactions ; ne valide ni SwiftUI ni le SDK Apple |
| WSL, frontend Swift, 2026-08-16 | `swiftc -frontend -parse Albumzh.swiftpm/Sources/AppModule/*.swift` | **OK** sur le panneau Mise en page et tout AppModule | Syntaxe seulement ; type-check et compilation Swift Playgrounds non exécutés |
| WSL, contrats, 2026-08-16 | `perl tools/validate_contracts.pl` puis `sha256sum -c catalog-checksums-v1.sha256` dans `docs/` | **OK** : 32 modèles et **10/10 empreintes** | Le test manifeste confirme en plus l’identité byte à byte de la copie runtime ; bundle Apple non testé |
| iPad 8, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-16 | `IPAD-L1-143…144` sur `101e2948252f51991933b8d61f767f52aa6b629d` | **2 réussites** | Retour « tout est ok maintenant » ; compilation prouvée indirectement par l’exécution fonctionnelle, aucune capture supplémentaire ; ne qualifie ni iPhone ni Xcode |
| iPad 8, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-16 | `IPAD-L1-141…142` sur `48e9fef9c317835f605df430c4112320d8cb66c3` | **1 réussite indirecte, 1 échec** | L’exécution fonctionnelle prouve la compilation de `141` sans capture de build séparée ; `142` échoue en portrait sur le débordement global, aucun résultat paysage distinct n’est extrapolé |
| iPad 8, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-16 | `IPAD-L1-134…140` sur `7a0f2a442f5f13a98663c5c02a97b8110bd943d6` | **6 réussites, 1 échec** ; compilation réussie | `135` échoue encore ; captures `IMG_4186.jpg` portrait et `IMG_4187.jpg` paysage non versionnées ; autres réussites issues du retour exclusif « tout est ok sauf 135 » |
| WSL, Swift 6.3.3, 2026-08-16 | `swift test --parallel` après le correctif de largeur globale | **124 tests, 0 échec** | Noyau portable inchangé ; ne valide ni la mise en page SwiftUI ni le rendu Apple |
| iPad 8, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-16 | `IPAD-L1-102`, `109…131`, `133` sur `638c659925e1b036570484a98c0fc016602687c9` | **19 réussites, 4 échecs, 2 blocages** ; compilation réussie | Retours par ID ; captures `IMG_4184.jpg` portrait et `IMG_4185.jpg` paysage non versionnées ; anomalies relayées par la campagne suivante |
| WSL, Swift 6.3.3, 2026-08-16 | `swift test --quiet` après correction des appels de couverture | **123 tests, 0 échec**, 7,938 s | Noyau portable ; la correction ne change pas le domaine et ne valide pas SwiftUI/iOS |
| WSL, frontend Swift, 2026-08-16 | `find Albumzh.swiftpm/Sources/AppModule -name '*.swift' -print0 \| xargs -0 swiftc -frontend -parse` | **OK** sur toutes les sources AppModule corrigées | Syntaxe seulement ; ni type-check SwiftUI, ni disponibilité SDK Apple |
| iPad 8, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-16 | Compilation des sources applicatives de `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` | **ÉCHEC** : argument `maximumPixelSize` manquant dans `AlbumCoverView` ; paramètre générique non inféré dans `AppModel` | Retour utilisateur ; aucun test fonctionnel du correctif n’est validé |
| iPad 8, iPadOS 26.5.2, Swift Playgrounds 4.7, 2026-08-16 | `IPAD-L1-132` sur `84ec71e1a66df4676e3c388e9d4f87a5a7e06e4e` | **ÉCHEC** : ligne 128 d’`AlbumCoverView`, appel `catalogImage(for:)` sans `maximumPixelSize` | Retour utilisateur ; remplacé par `IPAD-L1-133` |
| WSL, contrats, 2026-08-16 | `perl tools/validate_contracts.pl` puis `sha256sum -c catalog-checksums-v1.sha256` dans `docs/` | **OK** : 32 modèles, 3 fonds, 6 formes, schémas/package ; **10/10 empreintes OK** | Contrats et intégrité du dépôt, pas chargement/cache sur iPad |
| Dépôt, registre et diff, 2026-08-16 | Comptage des IDs synthétiques/détaillés, continuité, espaces invisibles et `git diff --check` | **OK** : 82 IDs synthétiques, 82 fiches détaillées, continuité `063…144`, aucun espace U+200B ; diff propre | Contrôle structurel ; ne transforme aucune régression iPad en réussite |
| Dépôt, registre Lot 2, 2026-08-16 | Comptage des entrées `IPAD-L2`, hash candidat et champs obligatoires | **OK** : 8 IDs synthétiques, 8 fiches détaillées `001…008`, toutes ⚪ `NON TESTÉ` et liées à `d427d4e…` | Contrôle documentaire ; aucune compilation Apple ni réussite fonctionnelle |
| WSL, Swift 6.3.3, 2026-08-10 | `timeout 240 /home/gmessika/.local/share/swiftly/toolchains/6.3.3/usr/bin/swift test` | **121 tests, 0 échec**, 6,696 s | Noyau `AlbumPhotoCore` uniquement ; ne valide pas SwiftUI/iOS |
| WSL | `perl tools/validate_contracts.pl` | **OK** : 32 modèles, 3 fonds, 6 formes, schémas et package exemple | Contrats statiques uniquement |
| WSL | `(cd docs && sha256sum -c catalog-checksums-v1.sha256)` | **10/10 OK** : modèles, catalogue, schéma, contrat du renderer et 6 masques | Intégrité des fichiers du dépôt, pas leur chargement Apple |
| WSL, Swift 6.3.3 | Compilation puis exécution de `tools/generate_shape_goldens.swift` dans un répertoire temporaire | **OK** : les 6 PBM régénérés sont identiques byte à byte | Reproductibilité du renderer pur, pas le rendu SwiftUI |
| WSL, frontend Swift, 2026-08-10 | `find Albumzh.swiftpm/Sources/AppModule -name '*.swift' -print0 \| xargs -0 /home/gmessika/.local/share/swiftly/toolchains/6.3.3/usr/bin/swiftc -frontend -parse` | **OK** sur toutes les sources AppModule | Analyse syntaxique seulement, sans SDK ni type-check SwiftUI |
| WSL, C | `cc -Wall -Wextra -pedantic -fsyntax-only tools/generate_photo_fixture.c tools/normalize_png_4x5.c` | **OK** | Syntaxe des générateurs seulement |
| Dépôt, registre manuel, 2026-08-10 | Contrôle de continuité, champs obligatoires, états et références normatives | **OK historique** : 46 fiches détaillées `063…108`, alors toutes ⚪, 13 validations Apple, 276 références résolues | État du registre avant la première campagne ; remplacé par le contrôle du 16 août ci-dessus |
| Dépôt, traçabilité, 2026-08-16 | Contrôle des identifiants et liens de `docs/traceability/lot0-lot1.md` | **OK structurel** : 82 contrôles iPad jusqu’à `IPAD-L1-144`, 13 Apple et 24 `ACPT` | Ne transforme aucune couverture structurelle en réussite fonctionnelle |
| Dépôt, traçabilité Lot 2, 2026-08-16 | Revue de `docs/traceability/lot2.md` contre les tests Core et `suivi_tests.md` | **OK structurel** : 5 repères automatisés et 8 contrôles iPad reliés | `AUT-009…011` et les incréments texte/stickers/cadres restent explicitement incomplets |
| Dépôt, arbitrage des lots, 2026-08-10 | Vérification de `DEC-38`, des trois lots de validation, des sorties de la section 31 et du registre manuel | **OK** : Lot 1 = six sorties photo locales ; `ACPT-123`/`130` au Lot 2 ; `ACPT-127` au Lot 3 ; 276 références manuelles résolues | Documentation uniquement ; tests Core non relancés car aucune source ni ressource n’a changé |
| Dépôt | `git diff --exit-code -- Albumzh.swiftpm/Package.swift Package.swift` | **OK** : les deux manifestes sont inchangés | Confirme la conservation de l’enveloppe, pas sa compilation Apple |
| Dépôt | `git diff --check` | **OK** après écriture du code, des contrats et du registre manuel ; à rejouer après fixation des hashes | Contrôle des espaces et marqueurs de conflit, pas une preuve fonctionnelle |

## Validations non exécutées

| Validation | État | Motif |
|---|---|---|
| `IPAD-L2-018`, Remplir l’album sur `7815396…` | 🟢 Réussi sur l’iPad déclaré | Retour global « les tests sont ok » sans capture ni détail par étape ; ne couvre pas la nouvelle interface compacte ni le cadrage couvrant demandés avec ce retour |
| `IPAD-L2-019`, action compacte et cadrage sur `3944fae…` | 🟢 Réussi sur l’iPad déclaré | Retour global « tout est ok » sans capture ni détail par étape ; limité à cette fiche et à ce candidat |
| `IPAD-L2-020`, zones de texte sur `d882183…` | 🔴 Échec de compilation Apple | Étape 1 échouée ; aucune étape fonctionnelle exécutée, preuve limitée aux diagnostics visibles dans les deux captures reçues |
| `IPAD-L2-021`, correctif texte `0f4b16c…` | 🔴 Échec fonctionnel sur Apple | Compilation et lancement réussis, puis cinq défauts signalés ; aucune réussite extrapolée aux étapes non commentées |
| `IPAD-L2-022`, panneau et rendu texte `7bc495e…` | ⚪ Non testé sur Apple | Compiler puis vérifier panneau, deux raccourcis `+`, fond, palette, échelle, opacité et reprendre la qualification fonctionnelle complète du texte |
| `APPLE-L2-001`, largeur compacte de `57afa71…` | 🟠 Bloqué sur cet iPad | Swift Playgrounds ne permet pas de réduire suffisamment la fenêtre ; reprendre le dialogue, la barre, Gérer les pages et le menu Plus sur iPhone ou environnement Xcode réellement compact |
| iPhone réel | ⚪ Non testé | Aucun appareil ni build TestFlight qualifié dans cette remise |
| Xcode/macOS et simulateurs | ⚪ Non testés | SDK Apple absent de WSL ; campagne différée selon `ENV-006` à `ENV-009` |
| Accessibilité et adaptation exhaustives iPhone/Xcode | ⚪ Non testées | `114`, `115`, `118…120` réussis sur l’iPad 8 ; matrice iPhone et Accessibility Inspector toujours absents |
| Performance instrumentée, enveloppe 5 Go et mémoire | ⚪ Non testée | `116`, `117`, `122` réussis manuellement ; Instruments et charge 5 Go restent nécessaires |
| Import RAW réel | 🟠 Différé | La fixture synthétique fournie n’est pas décodable par ImageIO ; l’utilisateur refera ultérieurement un test avec un autre RAW |
| UTType/package `.photoalbum`, partage, PDF | ⚪ Non testés | Déclarations et fonctions Lot 3 non exposées dans le candidat Lot 1 |
| CloudKit | 🟠 Bloqué | Entitlements et conteneur non disponibles sous WSL |

## Risques et blocages

| ID | Niveau | Risque | Mesure actuelle / condition de levée |
|---|---|---|---|
| `RSK-3.0-001` | Élevé | Le ledger ne recense pas encore toutes les références récupérables futures (révisions, conflits, certains états différés). Une purge physique naïve pourrait supprimer trop tôt. | La purge physique reste désactivée au Lot 1 ; accepter une fuite disque temporaire plutôt qu’une perte. Compléter le ledger avant toute purge. |
| `RSK-3.0-002` | Levé dans le Core | `DAT-042` était incomplet : une page modèle pouvait référencer un couple ou un slot non résolu. | Le manifeste runtime résout aussi les versions inactives ; la bijection photo, les types et l’unicité sont refusés avant persistance. La preuve Apple reste distincte. |
| `RSK-3.0-003` | Élevé | Le hachage, la déduplication et la réutilisation sont désormais en flux borné, mais ImageIO, la création du dérivé et certains chemins d’affichage chargent encore le média complet ; un RAW volumineux peut donc créer un pic mémoire. | Mesurer sur iPad et instrumenter les chemins de décodage avant de revendiquer l’enveloppe 5 Go. |
| `RSK-3.0-004` | Moyen | Risque matérialisé sur `06c30b9…`, `84ec71e…`, puis `d882183…` : l’analyse syntaxique Linux ne détecte pas toutes les erreurs de type SwiftUI. `0f4b16c…` compile, mais chaque nouvel incrément peut réintroduire cet écart. | Garder un contrôle de compilation Swift Playgrounds séparé avant chaque campagne fonctionnelle Lot 2 ; `IPAD-L2-022` commence par ce contrôle. |
| `RSK-3.0-005` | Levé | Les anciennes sorties de Lot 1 pour `ACPT-123`, `ACPT-127` et `ACPT-130` contredisaient la frontière des lots. | Arbitrage utilisateur enregistré par `DEC-38` : scénarios déplacés respectivement aux Lots 2, 3 et 2. |
| `RSK-3.0-006` | Moyen | Le risque tactile s’était matérialisé : le pont attaché à une sous-vue SwiftUI ne recevait aucun geste de canevas hors sélection. Le pont fenêtre est désormais validé par `IPAD-L1-138`. | Conserver la preuve iPad et compléter par la qualification XCTest différée. |
| `RSK-3.0-007` | Moyen | Lancement, Fonds, cent pages et déplacement continu ont été déclarés OK sur l’iPad 8, sans joindre les durées ni instrumentation. | Conserver la preuve manuelle limitée et mesurer ensuite avec Instruments avant toute revendication de marge. |
| `RSK-3.0-008` | Levé sur l’iPad déclaré | Le débordement global de `142` avait été corrigé sous `144`, puis l’ajout du panneau Mise en page avait fait réapparaître un léger rognage sous `IPAD-L2-002`. | `IPAD-L2-010` valide les marges et la largeur de `024a60b…` ; Split View, iPhone réel et matrice Xcode restent distincts. |
| `RSK-3.0-009` | Élevé | CloudKit et le type de document package dépendent de capacités ou réglages Swift Playgrounds non prouvés. | Prototype Apple ciblé ; escalade vers Xcode/macOS si indisponible. |
| `RSK-3.0-010` | Moyen | `L10N-002` n’est pas encore satisfait : les libellés français sont présents dans les vues mais aucun catalogue `.xcstrings` n’est livré. | Conserver le candidat interne ; créer et valider le catalogue au lot Qualité avant de déclarer une fonctionnalité terminée. |
| `RSK-3.0-011` | Moyen | Le cache de couverture SwiftUI n’a pas encore de preuve instrumentée d’invalidation ni de budget mémoire sur appareil. | Exécuter le parcours couverture, puis instrumenter le cache avant de déclarer `COV-007` satisfait. |
| `RSK-3.0-012` | Moyen | Une tâche déjà en attente dans la file durable n’est pas retirée par l’annulation Swift et exécutera son tour ; c’est souhaité pour une commande durable soumise, mais ce contrat ne convient pas à une future commande explicitement annulable. | Les imports vérifient leur annulation entre fichiers et conservent les copies déjà publiées ; rendre les waiters sensibles à l’annulation avant d’étendre ce mécanisme à d’autres opérations annulables. |
| `RSK-3.0-013` | Faible | La fermeture d’une session vide l’historique sans republier immédiatement certains `referenceCount`, qui peuvent rester temporairement surévalués. | La purge physique est désactivée et la surévaluation ne peut pas perdre de données ; recomputer et persister le ledger avant toute purge future. |
| `RSK-3.0-014` | Moyen | L’URL physique d’un blob peut être obtenue sans verrou de fichier OS ; l’immuabilité dépend actuellement de tous les écrivains du dépôt respectant les acteurs. | Les chemins internes vérifient taille et empreinte avant réutilisation ; réduire l’exposition de l’URL et ajouter protection/verrouillage avant toute écriture externe ou purge. |
| `RSK-3.0-015` | Moyen | La fixture `raw.dng` synthétique (1 600 × 1 200, 16 bits RGGB) est refusée par ImageIO ; son échec ne prouve pas un défaut du pipeline RAW de l’app. | Ne modifier ni assouplir le pipeline sur cette seule preuve ; conserver `IPAD-L1-076` bloqué et refaire plus tard le test avec un RAW publiquement décodable et son hash. |
| `RSK-3.0-016` | Levé sur l’iPad déclaré | L’ajout d’un panneau, du dé et d’Auto avait modifié les barres validées par `144` et `IPAD-L2-002` constatait un rognage portrait. | `IPAD-L2-010` et `012` réussissent sur `024a60b…` ; la matrice compacte reste différée. |
| `RSK-3.0-017` | Levé dans le correctif, à confirmer sur iPad | Les variantes de modèles avec texte étaient visibles mais désactivées afin de ne pas créer une zone vide impossible à saisir. | L’éditeur et `TPL-012` sont intégrés dans le même incrément ; vérifier création, saisie et absence en prévisualisation sous `IPAD-L2-022`. |
| `RSK-3.0-018` | Levé sur l’iPad déclaré | `IPAD-L2-004` échouait parce que l’action relisait une requête d’alerte que SwiftUI pouvait déjà avoir remise à `nil`. `024a60b…` utilise la requête capturée et son `pageID`. | `IPAD-L2-011` valide Appliquer, Annuler/Rétablir et relance sur iPad. |
| `RSK-3.0-019` | Levé sur l’iPad déclaré | Le bouton Replier du rail agissait sur le panneau opposé et les contenus droits partageaient mal la hauteur. Dans `024a60b…`, le masquage est dans le panneau droit et ses deux sections se replient indépendamment. | `IPAD-L2-010` valide les quatre combinaisons, Réduire les animations et la conservation de la sélection. |
| `RSK-3.0-020` | Levé sur l’iPad déclaré | Un nom long masquait position et plan dans Sélectionner un élément. `024a60b…` borne le libellé visible à 45 caractères en tronquant le seul détail et conserve le libellé accessible complet. | 2 tests Core et `IPAD-L2-012` avec VoiceOver réussissent ; compléter sur iPhone reste différé. |
| `RSK-3.0-021` | Levé sur l’iPad déclaré | Le dé était fonctionnel mais peu explicite. `024a60b…` applique `RND-001` : bouton `die.face.5.fill` à libellé visible dans Mise en page, absent de la barre du canevas. | `IPAD-L2-012` valide l’icône, le libellé et la séquence fonctionnelle. |
| `RSK-3.0-022` | Levé sur l’iPad déclaré | Le remplacement d’une commande dans la barre sous le canevas rendait la preuve d’adaptation `IPAD-L1-144` insuffisante, et le nouveau libellé du sélecteur pouvait se comprimer. | `IPAD-L2-013` réussit sur `b86c4b3…` en suivant la fiche portrait, paysage et VoiceOver ; la preuve reste sans capture ni détail par étape. |
| `RSK-3.0-023` | Levé sur l’iPad déclaré | `IPAD-L2-014` montre une fenêtre trop large/basse, `015` que fitted la comprime jusqu’à devenir illisible et `016` que la feuille explicite fige l’app sans s’afficher. | `57afa71…` retire la feuille système au profit d’un dialogue interne borné ; `IPAD-L2-017` réussit selon le retour global « c’est ok ». |
| `RSK-3.0-024` | Levé sur l’iPad déclaré pour `7815396…` | Remplir l’album modifie potentiellement de nombreuses pages en une commande et ajoute une nouvelle surface SwiftUI. | `IPAD-L2-018` réussit les trois densités, pages et Annuler/Rétablir selon un retour global ; la nouvelle présentation est suivie séparément. |
| `RSK-3.0-025` | Levé sur l’iPad déclaré | Le déplacement du choix de densité dans un dialogue interne et le nouveau cadrage couvrant touchaient le rendu SwiftUI, le calcul après recomposition Auto et la compatibilité des placements persistés. | `3944fae…` conserve les placements existants sans migration ; `IPAD-L2-019` réussit selon le retour global « tout est ok ». |
| `RSK-3.0-026` | Moyen, matérialisé puis corrigé sur `0f4b16c…` | Les API SwiftUI iOS 26 de texte riche ne peuvent être que parsées sous WSL ; `d882183…` a échoué car deux contraintes écrivaient plusieurs clés à travers un proxy borné à leur seule `AttributeKey`. | Les quatre contraintes séparées compilent sur Apple sous `IPAD-L2-021`; le nouveau raccord panneau/fond doit repasser le contrôle de compilation sous `IPAD-L2-022`. |
| `RSK-3.0-027` | Moyen | L’API publique `AttributedString.TextAlignment` d’iOS 26 n’expose pas l’alignement justifié exigé par `TBX-011`. | ADR-003 : conserver la valeur métier, rendre à gauche et ne pas proposer un faux bouton ; prototyper séparément une intégration ponctuelle conforme à `TXA-003` avant de fermer l’exigence. |
| `RSK-3.0-028` | Moyen | Le premier incrément valide une session d’édition comme une commande, mais ne publie pas encore chaque séquence après 750 ms ; la conservation fine des styles provenant d’un collage externe reste aussi à compléter. | Garder `TBX-007` et `TBX-022` partiels, ne pas les déclarer terminés sous `IPAD-L2-022`, puis ajouter des tests Apple ciblés dans l’incrément suivant. |
| `RSK-3.0-029` | Élevé, matérialisé | `IPAD-L2-021` montre qu’un éditeur riche qui compile peut rester incohérent avec la page : surface système opaque, tailles évaluées sur 3 000 points au lieu du canevas, palette de menu monochrome et opacité sans aperçu. | Le correctif utilise `AlbumPageBackground`, la hauteur rendue de la page, une palette SwiftUI propre et un aperçu d’opacité ; vérifier chaque point sous `IPAD-L2-022` avant de reprendre la suite du texte. |

## Prochaines actions

1. Transférer `7bc495ec623e5b12301569d0108fbccadb978630` et exécuter
   `IPAD-L2-022` sur l’iPad déclaré, en commençant par sa compilation Apple.
2. Vérifier en priorité le fond clair/sombre, les six pastilles, 18/96 points et
   25/50/100 % d’opacité avant de reprendre le reste des étapes texte.
3. Compléter ensuite `TBX-007`, `TBX-011`, `TBX-021` et `TBX-022` sans moteur
   parallèle ni faux contrôle d’interface.
4. Reprendre séparément `APPLE-L2-001` sur un iPhone ou un environnement Xcode
   réellement compact ; ne pas demander le menu Plus au plein écran iPad.
5. Enchaîner ensuite catalogue de stickers/cadres et
   presse-papiers multi-types ; figer les assets et licences avant de les persister.
6. Le RAW reste hors de cette campagne immédiate.
7. Organiser en parallèle différé les campagnes iPhone, Xcode/macOS,
   accessibilité, performance et interruption transactionnelle.

## Journal des mises à jour

Le journal 3.0 repart de zéro ; l’historique détaillé du prototype 2.1 reste
dans Git à `06aaa59`. Les entrées les plus récentes doivent rester en haut.

| Date | Auteur | Changement | Fichiers et exigences | Validation |
|---|---|---|---|---|
| 2026-08-17 | Codex | Gel du correctif panneau/rendu texte `7bc495ec623e5b12301569d0108fbccadb978630` et injection du candidat exact dans `IPAD-L2-022` | `README.md`, `suivi_tests.md`, `docs/traceability/lot2.md`, `SUIVI_PROJET.md` ; `TST-001…005`, `TST-013`, `EDT-001`, `EDT-008`, `EDT-021`, `TBX-002`, `TBX-009`, `TBX-012`, `TBX-014`, `TBX-016`, `TBX-025` | WSL : 146 tests Core, contrat ciblé, parse AppModule, contrats et 10/10 empreintes réussis ; 22/22 IDs Lot 2 ; `IPAD-L2-022` reste ⚪ sur Apple |
| 2026-08-17 | Codex | Enregistrement de l’échec fonctionnel `IPAD-L2-021`, ajout du panneau Texte, retrait du bouton superposé, formats de zone dans l’inspecteur, fond réel, palette colorée, aperçu à l’échelle du canevas et opacité immédiate ; préparation de `IPAD-L2-022` | `spec.md`, `AlbumTextEditorView.swift`, `TextPanelView.swift`, `EditorViewModel.swift`, `AlbumEditorView.swift`, `HelpView.swift`, `ManifestContractTests.swift`, `README.md`, `suivi_tests.md`, `docs/traceability/lot2.md`, `SUIVI_PROJET.md` ; `EDT-001`, `EDT-002`, `EDT-006`, `EDT-008`, `EDT-012`, `EDT-014`, `EDT-021`, `TBX-002`, `TBX-009`, `TBX-012`, `TBX-014`, `TBX-016`, `TBX-025`, `ACC-002`, `ACC-006`, `ACC-021` | Retour iPad et `IMG_4191.jpg` hors Git ; WSL : 146 tests Core, contrat ciblé, parse AppModule, contrats et 10/10 empreintes réussis ; 22/22 IDs Lot 2 ; compilation/rendu Apple du correctif NON TESTÉS |
| 2026-08-17 | Codex | Enregistrement de l’échec de compilation `IPAD-L2-020`, correction d’`AlbumTextEditorView` et gel de `0f4b16c6c6435c29ca44da4e2726fac210add520` : portée métier imbriquée et une contrainte par clé native modifiable ; préparation de `IPAD-L2-021` | `AlbumTextEditorView.swift`, `ManifestContractTests.swift`, `README.md`, `suivi_tests.md`, `docs/traceability/lot2.md`, `SUIVI_PROJET.md` ; `TBX-001…020`, `TBX-023…025`, `TPL-012`, `TPL-013`, `TPL-017`, `TXA-001`, `TXA-002`, `TXA-004`, `ACC-002`, `ACC-006`, `ACC-021` | WSL : 146 tests Core, contrat ciblé et parse AppModule réussis ; 21/21 IDs Lot 2 ; captures `IMG_4188.HEIC`/`IMG_4189.HEIC` conservées hors Git ; compilation Apple du correctif NON TESTÉE |
| 2026-08-17 | Codex | Gel du candidat zones de texte `d882183d31de7ed6078c70f9e79a80d6ba994dd6` et injection de son empreinte dans `IPAD-L2-020` | `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot2.md` ; `TST-001…005`, `TST-013`, `TBX-001…025`, `TXA-001…005`, `TPL-012`, `TPL-013`, `TPL-017` | Registre : 20/20 IDs Lot 2 synthétiques et détaillés ; `IPAD-L2-020` à ⚪ ; 16 étapes au format `ID`/`Description`/`Résultat attendu` ; aucune preuve Apple du texte extrapolée |
| 2026-08-17 | Codex | Enregistrement de la réussite globale `IPAD-L2-019`, puis premier incrément public des zones de texte : éditeur riche SwiftUI iOS 26, ajout dans la page et le menu, polices système, styles, limite, hauteur/débordement, modèles texte, rendu et commandes atomiques ; ADR de la limite justifiée et fiche `IPAD-L2-020` | `DomainModels.swift`, `PrototypeEngines.swift`, `AlbumApplicationService.swift`, `AlbumTextEditorView.swift`, `EditorViewModel.swift`, `PageCanvasView.swift`, `AlbumEditorView.swift`, `LayoutPanelView.swift`, `HelpView.swift`, tests, `docs/architecture/ADR-003-swiftui-rich-text-alignment.md`, `README.md`, `suivi_tests.md`, `docs/traceability/lot2.md`, `SUIVI_PROJET.md` ; `TBX-001…025`, `TXA-001…005`, `TPL-012`, `TPL-013`, `TPL-017`, `ACC-002`, `ACC-006`, `ACC-021` | Retour `019` global sans capture ; candidat applicatif `d882183…` ; WSL : 146 tests Core, parse AppModule, contrats et 10/10 empreintes OK ; compilation/rendu/toucher Apple du texte NON TESTÉS ; `TBX-007`, `TBX-011`, `TBX-021` et `TBX-022` restent partiels |
| 2026-08-17 | Codex | Gel du candidat compact/cadrage `3944fae199b2eb37c7b1f0a1aae5558197455b87` et préparation de `IPAD-L2-019` en 12 étapes tabulaires | `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot2.md` ; `TST-001…005`, `TST-011`, `TST-013`, `DEC-07`, section 3.1, `AUT-002`, `AUT-004`, `AUT-009…011`, `PHO-005`, `PHO-006`, `PHO-014`, `FRM-004`, `FRM-009`, `CRP-001`, `CRP-004…007`, `ACC-002`, `ACC-006`, `ACC-021` | Registre : 19/19 IDs Lot 2 synthétiques et détaillés ; `IPAD-L2-019` à ⚪ ; 12 étapes au format `ID`/`Description`/`Résultat attendu` ; aucune preuve Apple extrapolée |
| 2026-08-17 | Codex | Enregistrement de la réussite `IPAD-L2-018`, compaction de Remplir l’album en un bouton ouvrant un dialogue Densité/compteur/Annuler/Valider, et nouvelle règle de cadrage initial couvrant après géométrie finale | `GeometryEngines.swift`, `PrototypeEngines.swift`, `AlbumApplicationService.swift`, `PhotosPanelView.swift`, `AlbumEditorView.swift`, `EditorViewModel.swift`, `HelpView.swift`, tests, `spec.md`, `README.md`, `suivi_tests.md`, `docs/traceability/lot2.md`, `SUIVI_PROJET.md` ; `DEC-07`, section 3.1, `AUT-002`, `AUT-004`, `AUT-009…011`, `PHO-005`, `PHO-006`, `PHO-014`, `FRM-004`, `FRM-009`, `CRP-001`, `CRP-005`, `CRP-007` | Retour `018` global sans capture ; WSL : 139 tests Core, parse AppModule, contrats et 10/10 empreintes OK ; compilation/rendu/toucher Apple des deux changements NON TESTÉS, candidat et nouvel ID à figer |
| 2026-08-17 | Codex | Gel du candidat Remplir l’album `781539603d6b98523fe48326ee49e24288dfa09b` et préparation de `IPAD-L2-018` en 10 étapes tabulaires | `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot2.md` ; `TST-001…005`, `TST-013`, `AUT-009…012`, `FRM-009`, `TPL-005`, `UND-001`, `ACC-002`, `ACC-006`, `ACC-021` | Registre : 18/18 IDs Lot 2 synthétiques et détaillés ; `IPAD-L2-018` à ⚪ ; aucune preuve Apple extrapolée |
| 2026-08-17 | Codex | Enregistrement de la réussite `IPAD-L2-017`, puis implémentation de Remplir l’album : trois densités, plan déterministe, confirmation chiffrée, pages réutilisées/créées et commande atomique | `PrototypeEngines.swift`, `AlbumApplicationService.swift`, `EditorViewModel.swift`, `PhotosPanelView.swift`, `AlbumEditorView.swift`, `HelpView.swift`, tests, `README.md`, `suivi_tests.md`, `docs/traceability/lot2.md`, `SUIVI_PROJET.md` ; `AUT-009…011`, `FRM-009`, `TPL-005`, `UND-001`, `EDT-001`, `EDT-020` | `IPAD-L2-017` : retour « c’est ok » sans capture ni détail ; nouveau code : 137 tests Core, parse AppModule, contrats et 10/10 empreintes OK ; compilation/rendu/toucher Apple de Remplir l’album NON TESTÉS, candidat à figer |
| 2026-08-17 | Codex | Gel du correctif de gel `57afa71e3eeac8b48f05e0aaa719cf77e8a97834` et préparation de `IPAD-L2-017` en 6 étapes tabulaires | `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot2.md` ; `TST-001…005`, `TST-013`, `PAG-017`, `ACC-002`, `ACC-006`, `ACC-021` | Registre : 17/17 IDs Lot 2 synthétiques et détaillés ; `IPAD-L2-017` à ⚪ ; procédure conforme au tableau `ID`/`Description`/`Résultat attendu` ; aucune preuve Apple extrapolée |
| 2026-08-17 | Codex | Enregistrement de l’échec immédiat `IPAD-L2-016`, puis suppression de la feuille système qui figeait l’app au profit d’un dialogue interne centré, borné et bloquant | `AlbumEditorView.swift`, `ManifestContractTests.swift`, `spec.md`, `README.md`, `suivi_tests.md`, `docs/traceability/lot2.md`, `SUIVI_PROJET.md` ; `PAG-017`, `ACC-002`, `ACC-006`, `ACC-021`, `TST-013` | Retour iPad : app figée sans confirmation ; correction WSL : 134 tests, parse AppModule, contrats et 10/10 empreintes OK ; rendu corrigé Apple NON TESTÉ, candidat et nouvel ID à figer |
| 2026-08-17 | Codex | Gel de la seconde correction de fenêtre `7d8772c6d87a769a239b4f9eafabe74c8c126681` et préparation de `IPAD-L2-016` en 6 étapes tabulaires ; la qualification compacte vise ce candidat | `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot2.md` ; `TST-001…005`, `TST-013`, `PAG-017`, `ACC-002`, `ACC-006`, `ACC-021` | Registre : 16/16 IDs Lot 2 synthétiques et détaillés ; `IPAD-L2-016` à ⚪ ; les 6 fiches détaillées non testées respectent le tableau requis ; aucune preuve Apple extrapolée |
| 2026-08-17 | Codex | Enregistrement de l’échec immédiat `IPAD-L2-015` puis seconde correction : cadre iPad régulier explicite de 400 × 340 points et présentation page native en compact | `AlbumEditorView.swift`, `ManifestContractTests.swift`, `spec.md`, `README.md`, `suivi_tests.md`, `docs/traceability/lot2.md`, `SUIVI_PROJET.md` ; `PAG-017`, `ACC-006`, `ACC-021`, `TST-013` | Retour iPad : fenêtre minuscule et illisible ; correction WSL : 134 tests, parse AppModule, contrats et 10/10 empreintes OK ; rendu corrigé Apple NON TESTÉ, candidat et nouvel ID à figer |
| 2026-08-17 | Codex | Gel du correctif de fenêtre `8aa7f566de775c15ddf5a9e702a01ed5e9fdb640` et préparation de `IPAD-L2-015` en 6 étapes tabulaires ; la qualification compacte vise désormais ce candidat | `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot2.md` ; `TST-001…005`, `TST-013`, `PAG-017`, `ACC-002`, `ACC-006`, `ACC-021` | Registre : 15/15 IDs Lot 2 synthétiques et détaillés ; `IPAD-L2-015` à ⚪ ; les 6 fiches détaillées non testées respectent le tableau requis ; aucune preuve Apple extrapolée |
| 2026-08-17 | Codex | Enregistrement de l’échec ciblé `IPAD-L2-014` puis correction : suppression du formulaire défilant et du detent fixe, pile à hauteur intrinsèque, largeur idéale 400 et plafond 420 points | `AlbumEditorView.swift`, `ManifestContractTests.swift`, `spec.md`, `README.md`, `suivi_tests.md`, `docs/traceability/lot2.md`, `SUIVI_PROJET.md` ; `PAG-017`, `ACC-006`, `ACC-021`, `TST-013` | Retour iPad : parcours correct mais fenêtre trop large/basse et texte après défilement ; correction WSL : 134 tests, parse AppModule, contrats et 10/10 empreintes OK ; rendu corrigé Apple NON TESTÉ, candidat et nouvel ID à figer |
| 2026-08-17 | Codex | Gel du candidat d’ajout de page `02430b16f2853c01dbcafc88d48cd40c48373c4c` et préparation de `IPAD-L2-014` en 12 étapes tabulaires ; `APPLE-L2-001` est réaligné sur le même parcours en largeur compacte | `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot2.md` ; `TST-001…005`, `TST-013`, `EDT-008`, `PAG-002`, `PAG-013` à `PAG-017`, `ACC-002`, `ACC-006`, `ACC-021` | Registre : 14/14 IDs Lot 2 synthétiques et détaillés ; `IPAD-L2-014` à ⚪ ; 12 étapes ; les 6 fiches détaillées non testées respectent le tableau requis ; aucune preuve Apple extrapolée |
| 2026-08-17 | Codex | Enregistrement de la réussite `IPAD-L2-013`, puis évolution demandée : les deux commandes ajoutent en fin d’album après une confirmation commune dont « Ne plus demander » reste modifiable dans Gérer les pages et limité à la session d’édition | `AlbumApplicationService.swift`, `EditorViewModel.swift`, `AlbumEditorView.swift`, `GlobalPagesView.swift`, `HelpView.swift`, tests, `spec.md`, `README.md`, `suivi_tests.md`, `docs/traceability/lot2.md`, `SUIVI_PROJET.md` ; `EDT-008`, `PAG-002`, `PAG-013` à `PAG-017`, `ACC-002` | `IPAD-L2-013` : retour « tests ok » sur `b86c4b3…` ; nouveau code WSL : 134 tests, 0 échec, parse AppModule, contrats et 10/10 empreintes OK ; nouveau parcours Apple NON TESTÉ, candidat et régression à figer |
| 2026-08-17 | Codex | Gel du candidat de navigation `b86c4b323e0b8d2cfe2fc2e0394ff9d5f3e4e0b4` et préparation de `IPAD-L2-013` avec étapes en tableau | `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot2.md` ; `TST-001…005`, `TST-013`, `EDT-003`, `EDT-008`, `EDT-016`, `EDT-020`, `PAG-002`, `PAG-013`, `PHO-011`, `ACC-002`, `ACC-021` | 13e fiche Lot 2 à ⚪ ; rendu, toucher, adaptation, insertion de page et VoiceOver Apple NON TESTÉS |
| 2026-08-17 | Codex | Ajustement demandé de la navigation locale : Ajouter une page remplace l’ajout photo sous le canevas, Organiser devient Gérer les pages et le mode de choix photo devenu mort est retiré | `AlbumEditorView.swift`, `EditorViewModel.swift`, `HelpView.swift`, `ManifestContractTests.swift`, `spec.md`, `README.md`, `docs/traceability/lot2.md`, `SUIVI_PROJET.md` ; `EDT-003`, `EDT-008`, `EDT-012`, `EDT-016`, `EDT-020`, `PAG-002`, `PAG-013`, `PHO-011`, `PHO-013` | WSL : 134 tests, 0 échec ; parse AppModule OK ; rendu, toucher, adaptation et VoiceOver Apple NON TESTÉS ; candidat et régression iPad à figer |
| 2026-08-17 | Codex | Enregistrement du retour global de la campagne corrective Lot 2 ; portée explicitement limitée à `IPAD-L2-009…012`, sans extrapolation aux contrôles Apple différés | `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot2.md` ; `ENV-001…005`, `EDT-002`, `ELM-014`, `TPL-005…010`, `RND-001…005`, `TST-004`, `TST-013` | Retour « tous les tests sont ok » : 4 réussites sur `024a60b…`, aucune capture ni observation par étape ; environnement repris de l’en-tête et non redéclaré ; tests automatisés non relancés car sources inchangées |
| 2026-08-17 | Codex | Mise en tableau des étapes des neuf procédures détaillées encore à exécuter, avec un résultat attendu associé à chaque action ; règle rendue obligatoire pour toute future fiche détaillée | `AGENTS.md`, `suivi_tests.md`, `SUIVI_PROJET.md` ; `TST-004`, `TST-005`, `TST-013` | Format documentaire contrôlé sur 4 fiches iPad et 5 fiches Apple ; états inchangés à ⚪ ; tests automatisés non relancés car aucun code ni contrat produit n’a changé |
| 2026-08-17 | Codex | Gel du candidat correctif `024a60bcd7b7a837497a5d6a00e8e42cacfd9366` et préparation de `IPAD-L2-009…012` ; le menu Plus est sorti de la campagne iPad plein écran et isolé dans `APPLE-L2-001` pour une vraie largeur compacte | `README.md`, `suivi_tests.md`, `SUIVI_PROJET.md`, `docs/traceability/lot2.md` ; `TST-001…005`, `EDT-002…004`, `ELM-014`, `RND-001`, `TPL-005…010` | Registre : 12/12 entrées `IPAD-L2`, 4 nouvelles fiches complètes à ⚪, 14 contrôles Apple ; aucune validation Apple du correctif |
| 2026-08-17 | Codex | Correctif regroupé des retours Lot 2 : requête Appliquer capturée par page, marges latérales, panneau droit plus étroit et sections repliables indépendantes, détail de sélection borné avec VoiceOver complet, dé déplacé dans Mise en page | `AlbumEditorView.swift`, `EditorViewModel.swift`, `LayoutPanelView.swift`, `PageCanvasView.swift`, `ElementSelectionLabelFormatter.swift`, tests, `spec.md` et suivi ; `EDT-002`, `ELM-014`, `RND-001`, `TPL-005…010`, `ACC-002`, `ACC-021` | WSL : 133 tests, 0 échec ; parse AppModule OK ; contrats et 10/10 empreintes OK ; compilation/rendu/toucher Apple NON TESTÉS |
| 2026-08-17 | Codex | Enregistrement de la première campagne Lot 2 : cinq réussites, échecs d’adaptation portrait et d’Appliquer, blocage du menu Plus compact, plus quatre retours d’ergonomie à reprendre | `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot2.md` ; `EDT-002…004`, `EDT-019`, `ELM-014`, `TPL-005…010`, `RND-001…006`, `AUT-001…019`, `ACC-021`, `ERR-022` | Retour utilisateur sur `d427d4e747dd2de56235341bd661d537a9a31c8e` : 5 réussites, 2 échecs, 1 blocage ; aucune capture ; aucun test automatisé relancé car sources inchangées |
| 2026-08-16 | Codex | Gel du premier candidat Lot 2 et préparation de la campagne iPad `IPAD-L2-001…008` avec matrice de traçabilité séparée | `README.md`, `suivi_tests.md`, `SUIVI_PROJET.md`, `docs/traceability/lot2.md` ; `TST-001…005`, `LOT-003`, `TPL`, `RND`, `AUT`, `DAT-042` | Candidat exact `d427d4e747dd2de56235341bd661d537a9a31c8e` ; 8/8 fiches à ⚪ NON TESTÉ ; aucune preuve Apple extrapolée |
| 2026-08-16 | Codex | Complément pré-campagne Auto : avertissement explicite après transformation manuelle ou modèle appliqué avec action Annuler restaurant la commande atomique précédente | `EditorViewModel.swift`, `AlbumEditorView.swift`, `SUIVI_PROJET.md` ; `TPL-016`, `AUT-006`, `UND-001` | Parse AppModule OK ; compilation et comportement Apple NON TESTÉS |
| 2026-08-16 | Codex | Premier incrément Lot 2 : manifeste de modèles embarqué, provenance stricte, application atomique, dé, Auto/densité, panneau Mise en page adaptatif, aide et commandes incompatibles désactivées | `BuiltInLayoutTemplateCatalog.generated.swift`, `PrototypeEngines.swift`, `DomainValidation.swift`, `AlbumApplicationService.swift`, `EditorViewModel.swift`, `LayoutPanelView.swift`, `AlbumEditorView.swift`, `PhotosPanelView.swift`, `HelpView.swift`, tests et générateur ; `TPL-001…023`, `RND-001…006`, `AUT-001…008`, `AUT-012…019`, `DAT-042`, `PHO-014`, `EDT-001…004`, `EDT-019` | WSL : 131 tests Core, 0 échec ; parse AppModule OK ; contrats OK ; 10/10 empreintes ; `git diff --check` OK ; compilation et rendu Apple NON TESTÉS |
| 2026-08-16 | Codex | Enregistrement de la cinquième campagne ciblée : compilation et adaptation finale `143…144` réussies ; jalon Lot 1 viable sur iPad et transition vers le premier incrément du Lot 2 | `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot0-lot1.md` ; `EDT-002`, `EDT-020`, `PHO-002`, `ACC-021`, `LOT-003`, `DONE-001` à `DONE-005` | Retour utilisateur « tout est ok maintenant » sur `101e2948252f51991933b8d61f767f52aa6b629d` ; aucune qualification iPhone/Xcode extrapolée |
| 2026-08-16 | Codex | Gel documentaire du correctif de largeur globale et injection de son empreinte dans `143…144` | `README.md`, `suivi_tests.md`, `SUIVI_PROJET.md`, `docs/traceability/lot0-lot1.md` ; `TST-001` à `TST-005`, `DONE-001` à `DONE-005` | Sources applicatives exactes : `101e2948252f51991933b8d61f767f52aa6b629d` ; `143…144` restent ⚪ NON TESTÉ ; aucune preuve Apple extrapolée |
| 2026-08-16 | Codex | Enregistrement de la quatrième campagne ciblée (`141` réussi indirectement, `142` échoué) et correction de la largeur minimale globale : variantes sur une rangée puis repli sur deux rangées pour conserver rail, inspecteur et commandes en portrait ; tests `143…144` préparés | `AlbumEditorView.swift`, `spec.md`, `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot0-lot1.md` ; `EDT-002`, `EDT-020`, `PHO-002`, `PHO-011`, `PHO-019`, `ACC-021` | Commit `101e2948252f51991933b8d61f767f52aa6b629d` ; WSL : 124 tests, 0 échec ; parse AppModule, contrats, 10/10 empreintes, registre 82/82 et diff OK ; compilation/rendu Apple NON TESTÉS |
| 2026-08-16 | Codex | Gel documentaire du second correctif d’adaptation et injection de son empreinte dans `141…142` | `README.md`, `suivi_tests.md`, `SUIVI_PROJET.md`, `docs/traceability/lot0-lot1.md` ; `TST-001` à `TST-005`, `DONE-001` à `DONE-005` | Sources applicatives exactes : `48e9fef9c317835f605df430c4112320d8cb66c3` ; `141…142` restent ⚪ NON TESTÉ ; aucune preuve Apple extrapolée |
| 2026-08-16 | Codex | Enregistrement de la troisième campagne (`6` réussites, `1` échec), analyse des captures et second correctif d’adaptation : trois colonnes flexibles contraintes, noms de fichiers bornés et action locale à libellé complet/court/icône ; tests `141…142` préparés | `PhotosPanelView.swift`, `AlbumEditorView.swift`, `spec.md`, `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot0-lot1.md` ; `EDT-002`, `EDT-020`, `PHO-002`, `PHO-011`, `PHO-019`, `ACC-021` | WSL : 124 tests, 0 échec ; parse AppModule, contrats, 10/10 empreintes et registre 80/80 OK ; captures `IMG_4186.jpg`/`IMG_4187.jpg` examinées mais non versionnées ; compilation et rendu Apple NON TESTÉS |
| 2026-08-16 | Codex | Gel documentaire du correctif de la deuxième campagne et injection de son empreinte dans les sept fiches `134…140` | `README.md`, `suivi_tests.md`, `SUIVI_PROJET.md`, `docs/traceability/lot0-lot1.md` ; `TST-001` à `TST-005`, `DONE-001` à `DONE-005` | Sources applicatives exactes : `7a0f2a442f5f13a98663c5c02a97b8110bd943d6` ; les sept fiches restent ⚪ NON TESTÉ ; aucune preuve Apple extrapolée |
| 2026-08-16 | Codex | Enregistrement de la deuxième campagne (`19` réussites, `4` échecs, `2` blocages), clarification normative et corrections ciblées : bandeaux orange à icônes propres, grille Photos et bouton local adaptatifs, dates françaises, page active/insertion renforcées, pont gestuel fixé à la fenêtre et arbitrage sur éléments non sélectionnés ; tests `134…140` préparés | `spec.md`, `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot0-lot1.md`, `GeometryEngines.swift`, `EditorViewModel.swift`, `PhotosPanelView.swift`, `AlbumEditorView.swift`, `TrashView.swift`, `PageCanvasView.swift`, `MediaAssetStore.swift`, `GlobalPagesView.swift`, `GeometryEngineTests.swift` ; `ALB-025`, `EDT-002`, `GLO-003`, `PAG-016`, `PHO-011`, `ZOM-003` à `ZOM-005` | Candidat `7a0f2a442f5f13a98663c5c02a97b8110bd943d6` ; WSL : 124 tests, 0 échec ; parse AppModule OK ; captures portrait/paysage examinées mais non versionnées ; compilation et tactile Apple NON TESTÉS |
| 2026-08-16 | Codex | Correction des deux appels de préchargement de couverture restés sur l’ancienne signature de `catalogImage` ; `IPAD-L1-132` enregistré en échec et remplacement `133` créé | `AlbumCoverView.swift`, `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot0-lot1.md` ; `ENV-001` à `ENV-005`, `PERF-016`, `DONE-005` | Commit `638c659925e1b036570484a98c0fc016602687c9` ; WSL : 123 tests, 0 échec ; parse AppModule OK ; 4/4 appels catalogue avec taille explicite ; recompilation Apple requise par `IPAD-L1-133` |
| 2026-08-16 | Codex | Correction des deux diagnostics de compilation Apple : initialiseur explicite de fond avec taille par défaut et ensembles de catalogue typés | `AlbumPageBackground.swift`, `AppModel.swift`, `suivi_tests.md`, `SUIVI_PROJET.md`, `README.md`, `docs/traceability/lot0-lot1.md` ; `ENV-001` à `ENV-005`, `PERF-007`, `PERF-016`, `DONE-005` | Commit `84ec71e1a66df4676e3c388e9d4f87a5a7e06e4e` ; WSL : 123 tests, 0 échec ; parse AppModule OK ; type-check Apple à rejouer par `IPAD-L1-132` |
| 2026-08-16 | Codex | Gel documentaire du correctif et de sa spécification pour la seconde campagne iPad | `README.md`, `suivi_tests.md`, `SUIVI_PROJET.md`, `docs/traceability/lot0-lot1.md` ; `TST-001` à `TST-005`, `DONE-001` à `DONE-005` | Candidat exact `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` injecté dans `IPAD-L1-102` et `109…131` ; aucune preuve Apple extrapolée |
| 2026-08-16 | Codex | Analyse de la première campagne iPad et correctif regroupé : lancement/catalogue asynchrone avec priorité sûre au fond par défaut, retour post-création, dates de corbeille, déduplication, grilles et compteurs photo, modes de choix, inspecteur droit et suppression rapide, insertion de page, sélection/poignées/rotation, gestes canevas/navigation, sauvegarde en cours de geste et registre de régression ; RAW différé | `spec.md`, `suivi_tests.md`, `SUIVI_PROJET.md`, `docs/traceability/lot0-lot1.md`, `AlbumApplicationService.swift`, `GeometryEngines.swift`, `AppModel.swift`, `LibraryView.swift`, `TrashView.swift`, `MediaAssetStore.swift`, `PhotosPanelView.swift`, `AlbumEditorView.swift`, `EditorViewModel.swift`, `PageCanvasView.swift`, `GlobalPagesView.swift`, tests ; `ALB-025`, `EDT-021`, `PAG-016`, `PHO-019`, `CLP-006`, `PERF-007`, `PERF-016` et exigences reliées | Commit `06c30b93ca479a90a4cc4f3d90c0ba130bbb42e7` ; WSL : 123 tests Core, 0 échec ; parse AppModule OK ; contrats OK ; 10/10 empreintes OK ; compilation/gestes/performance Apple NON TESTÉS ; `094…101`, `103…108` obsolètes, `102` NON TESTÉ, régressions `109…131` préparées |
| 2026-08-10 | Codex | Arbitrage des lots appliqué sans modification du candidat : Lot 1 Photos/Fonds, Lot 2 composition Photoweb complète et presse-papiers multi-types, Lot 3 lecture/documents ; empreinte normative injectée dans toute la campagne | `spec.md`, `README.md`, `docs/traceability/lot0-lot1.md`, `suivi_tests.md`, `SUIVI_PROJET.md` ; `DEC-38`, `ARC-014`, `ACPT-123`, `ACPT-127`, `ACPT-130` | Spécification `031d2e46c70128c7e633db1f04663949e4531309` ; contrats OK ; sorties cohérentes ; 46 fiches, 13 Apple, 50 cartes et 276 références manuelles résolues ; tests Core non relancés car code inchangé |
| 2026-08-10 | Codex | Gel du candidat d’implémentation et de spécification, puis injection de son empreinte Git exacte dans les 46 fiches iPad et les validations Apple différées | `suivi_tests.md`, `SUIVI_PROJET.md` ; `TST-001` à `TST-016`, `DONE-001` à `DONE-005` | Candidat `314cf07c1a5b4c87e8abab4e35595ad9031e4b9a` ; toutes les fiches restent ⚪ NON TESTÉ ; aucune preuve Apple extrapolée |
| 2026-08-10 | Codex | Audit final avant gel : correction de la frontière de publication transactionnelle, SHA-256 et vérification en flux, annulation/nettoyage des imports initiaux et repris, suppression de page sûre, poignées pleine page, panneau compact glissable, accessibilité de prévisualisation, risques résiduels documentés et traçabilité exhaustive | `Albumzh.swiftpm/Sources/AlbumPhotoCore/`, `Albumzh.swiftpm/Sources/AppModule/`, `Tests/AlbumPhotoCoreTests/`, `docs/traceability/lot0-lot1.md`, `suivi_tests.md`, `SUIVI_PROJET.md` ; `LOC-011` à `LOC-026`, `APL-006`, `PERF-009`, `PERF-011`, `SEC-008`, `PAG-006`, `ELM-005` à `ELM-009`, `ACC-001` à `ACC-021` | 121 tests Core sans échec (6,696 s) ; contrats, 10 checksums, 6 goldens, parse AppModule, syntaxe C, manifestes, registre, traçabilité et `git diff --check` OK ; Apple/iPad NON TESTÉ ; candidat encore `À figer` |
| 2026-08-10 | Codex | Finalisation avant gel : file FIFO commune du service et barrière FIFO de l’éditeur, baux de bibliothèque/édition, dérivé RAW immuable et indexé, renderer pur des 6 formes avec golden masks, cache de couverture, progression d’import, descriptions accessibles et fiche de régression des commandes rapides | `Albumzh.swiftpm/Sources/AlbumPhotoCore/`, `Albumzh.swiftpm/Sources/AppModule/`, `Tests/AlbumPhotoCoreTests/`, `docs/catalog-*`, `docs/golden/`, `tools/`, `suivi_tests.md`, `SUIVI_PROJET.md` ; `APP-002`, `APP-005`, `LOC-011` à `LOC-014`, `PHO-015` à `PHO-018`, `FMT-002`, `CAT-009`, `COV-007`, `APL-006`, `ACC-001` à `ACC-020` | 118 tests Core sans échec ; contrats OK ; 10/10 checksums ; 6 goldens régénérés à l’identique ; parse AppModule, syntaxe C, manifestes inchangés et `git diff --check` OK ; Apple/iPad NON TESTÉ ; candidat encore `À figer` |
| 2026-08-10 | Codex | Reprise après interruption, gel du Core à 91 tests, finalisation des dérivés RAW persistants, de la qualité régionale, des baux par scène et des arbitrages de gestes ; relance de toutes les validations WSL avant le commit candidat | `Albumzh.swiftpm/Sources/AlbumPhotoCore/`, `Albumzh.swiftpm/Sources/AppModule/`, `Tests/AlbumPhotoCoreTests/`, `README.md`, `SUIVI_PROJET.md` ; `ALB-020`, `PHO-015`, `APL-007`, `FMT-002`, `QLT-001` à `QLT-006`, `APP-002`, `APP-011`, `ELM-009`, `CRP-003`, `ZOM-006` | 91 tests Core sans échec ; contrats, checksums, parse AppModule, syntaxe C, manifestes inchangés et `git diff --check` réussis ; Apple/iPad toujours NON TESTÉ ; candidat encore `À figer` |
| 2026-08-06 | Codex | Reconstruction from scratch des lots 0 et 1 dans l’enveloppe `Albumzh.swiftpm` : nouveau domaine, stockage transactionnel, contrats/catalogues, assets de fonds, AppModule à une page, import et composition photo ; mise à jour normative du zoom dynamique et création d’un tableau de bord 3.0 neuf | `spec.md`, `README.md`, `Albumzh.swiftpm/Sources/AlbumPhotoCore/`, `Albumzh.swiftpm/Sources/AppModule/`, `Tests/AlbumPhotoCoreTests/`, `docs/`, `tools/`, `SUIVI_PROJET.md` ; `DEC-05`, `DEC-07`, `DEC-33` à `DEC-37`, lots 0/1, `ACPT-100`, `102` à `104`, `123`, `124`, `127`, `129`, `130` | WSL : 91 tests Core sans échec, contrats et checksums OK ; parse AppModule intermédiaire réussi mais à reconfirmer ; Apple/iPad, accessibilité et performance NON TESTÉS ; candidat `À figer` |

## Règle de maintien

Toute modification du dépôt doit mettre ce tableau à jour dans le même
changement. Un code écrit ou un test Linux réussi reste 🟡 tant que les preuves
Apple applicables manquent. Les résultats manuels ne valent que pour le commit,
l’appareil et les versions logicielles enregistrés, et aucun retour global ne
doit être transformé en série de réussites détaillées.
