# Spécification fonctionnelle et technique — Application iOS d’albums photo

> **Version :** 3.0<br>
> **Date :** 6 août 2026<br>
> **Statut :** projet consolidé — une convention technique de zoom à confirmer avant développement<br>
> **Plateformes :** iPhone et iPad  
> **Version minimale :** iOS 26 et iPadOS 26  
> **Technologies principales :** Swift et SwiftUI

---

## 0. Règles de lecture du document

Les termes suivants ont une valeur normative :

- **DOIT** : exigence obligatoire pour la version ou le lot indiqué.
- **NE DOIT PAS** : comportement interdit.
- **DEVRAIT** : recommandation forte qui peut être écartée uniquement pour une raison technique documentée.
- **PEUT** : comportement facultatif.

Chaque exigence fonctionnelle, technique, de sécurité, de performance ou
d’accessibilité possède un identifiant stable dans l’espace de noms de sa
version majeure. Sa clé complète est `<version majeure de spec>:<ID>`, par
exemple `3:PHO-004`. Les tests, procédures de validation et pull requests
doivent citer les identifiants concernés ainsi que la version exacte de la
spécification ou son commit. Une exigence sans identifiant n’est pas normative.

Les règles de développement suivantes sont normatives :

1. `DEV-001` — Ne pas remplacer une exigence par un comportement supposé plus simple sans le documenter.
2. `DEV-002` — Ne pas utiliser d’API privée Apple.
3. `DEV-003` — Utiliser en priorité les API publiques d’iOS 26. Une garde de disponibilité n’est requise que pour une API introduite après iOS 26.
4. `DEV-004` — Conserver les données de l’utilisateur avant toute considération esthétique.
5. `DEV-005` — Implémenter l’application selon une architecture locale d’abord avec synchronisation différée.
6. `DEV-006` — Écrire les tests du domaine avant ou en même temps que les fonctionnalités correspondantes.
7. `DEV-007` — Une exigence impossible à vérifier dans l’environnement disponible DOIT conserver l’état `BLOQUÉ` ou `NON TESTÉ` ; elle NE DOIT PAS être considérée comme réussie, abandonnée ou implicitement hors périmètre.
8. `DEV-008` — Chaque campagne manuelle sur iPad DOIT enregistrer la version exacte de la spécification, le commit, la build ou copie testée, l’appareil, les versions d’iPadOS et de Swift Playgrounds, les scénarios exécutés, les résultats, les preuves, les anomalies et les contrôles non exécutés.
9. `DEV-009` — La phase temporaire sans macOS/Xcode PEUT produire des prototypes et builds internes, mais elle NE DOIT PAS autoriser une publication publique.

`SPEC-001` — Les résultats antérieurs restent interprétés avec la version de
spécification et le commit qu’ils citent. Une même forme courte, par exemple
`CRP-001`, désigne deux clés normatives différentes dans les espaces 2 et 3.
Aucun résultat 2.1 ne prouve donc l’exigence 3 correspondante, et aucun
identifiant de test manuel historique NE DOIT être réutilisé.

`SPEC-002` — L’espace normatif 2.1 est gelé pour l’historique. La version 3.0
retire entièrement les familles `DSP`, `LAY`, `MED`, `COM`, `CHK`, `TBL`,
`OVF`, `TXT`, `VID`, `CST` et `INS`, ainsi que `APL-009`, `COV-008`,
`CRP-008` à `CRP-010`, `FMT-009` à `FMT-014`, `GPH-012` à `GPH-017` et
`STK-017` à `STK-020` de l’espace 2. Le nouveau périmètre est défini sans
correspondance un-à-un par les exigences de l’espace 3.

`SPEC-003` — Les scénarios `ACPT-101`, `ACPT-105` à `ACPT-110` et
`ACPT-116` de la version 2.1 sont retirés. Ils restent réservés et leurs preuves
historiques ne couvrent pas les scénarios `ACPT-123` à `ACPT-131`.

---

# 1. Objectif du produit

L’application permet à un utilisateur de créer des albums personnalisés dans
un éditeur de composition inspiré du fonctionnement de l’éditeur de livres
photo Photoweb observé en 2026. Chaque page est un canevas libre pouvant
contenir :

- zéro, une ou plusieurs zones photo indépendantes
- zéro, une ou plusieurs zones de texte indépendantes
- des stickers statiques placés librement
- un fond graphique choisi par page

Les modèles de mise en page, le dé de composition aléatoire et la mise en page
automatique facilitent la composition sans empêcher le déplacement, le
redimensionnement, la rotation ni la superposition manuelle des éléments.

À partir de la version 1.1, un album créé sur un iPhone peut être ouvert et modifié sur un autre iPhone ou sur un iPad par CloudKit. Dès la version 1.0, il peut être transféré manuellement par package, consulté en lecture seule, présenté en diaporama et exporté en PDF.

L’application suit quatre principes principaux :

- **locale d’abord** : l’édition reste possible sans connexion
- **non destructive** : le cadrage et les transformations ne modifient pas la photo originale importée
- **portable** : un package exporté contient toutes les ressources nécessaires
- **résiliente** : les opérations suivent les garanties transactionnelles de la section 18

---

# 2. Périmètre et stratégie de livraison

## 2.1 Positionnement

L’application vise en priorité les albums de voyage et les journaux illustrés. La promesse de la première version publique est la suivante :

> Créer localement un album photo avec la souplesse de composition de
> Photoweb, le personnaliser avec des zones de texte et des stickers, le
> consulter et l’exporter sous une forme portable.

Les parcours prioritaires sont, dans cet ordre :

1. créer un album et gérer ses pages
2. importer des photos et les placer dans un ou plusieurs cadres
3. composer la page avec des modèles, des zones de texte et des stickers
4. placer et transformer des stickers
5. choisir une couverture
6. consulter l’album en lecture seule
7. lancer un diaporama
8. exporter un PDF ou un package modifiable

## 2.2 Versions publiques et lots internes

Les lots sont des incréments internes ou TestFlight. Chaque lot laisse le projet compilable, testable et démontrable. Une version publique n’est produite qu’après passage du lot Qualité applicable.

| Version | Lots inclus | Périmètre public |
|---|---|---|
| `1.0` | Lots 0 à 3 et qualité associée | Création locale, canevas multiélément, photos, modèles, fonds, textes, stickers statiques, lecture, diaporama, animation de page, PDF et package modifiable |
| `1.1` | Lot 4 et qualité associée | Historique persistant, synchronisation CloudKit et résolution de conflits |
| `1.2` | Lot 5 et qualité associée | Import de photos depuis Google Photos |

Le format de données local est conçu dès le lot 0 pour accueillir les fonctions des versions 1.1 et 1.2 sans migration destructive.

## 2.3 Fonctionnalités de la version publique 1.0

- bibliothèque de plusieurs albums
- création, renommage, corbeille et restauration d’un album
- couverture automatique ou manuelle
- ajout, suppression, restauration pendant la session et réorganisation des pages
- une page minimum par album
- zéro à plusieurs cadres photo et zones de texte par page
- modèles de mise en page filtrés par nombre de photos
- dé de mise en page aléatoire et mise en page automatique
- déplacement, redimensionnement, rotation, superposition et ordre des éléments
- cadrage photo non destructif avec zoom et déplacement dans chaque cadre
- formes de découpe, contours et cadres décoratifs de photo
- texte avec police, taille, couleur et alignement
- stickers statiques intégrés
- fond sélectionnable par page, avec application facultative à tout l’album
- affichage d’une seule page active et vue globale de toutes les pages
- navigation par boutons et balayage avec animation de page tournée
- lecture seule et diaporama
- annulation et rétablissement pendant la session courante
- stockage local transactionnel
- import depuis la photothèque Apple
- export et import d’un package modifiable
- export en PDF
- fonctionnement en portrait et en paysage
- accessibilité, clavier, pointeur et trackpad sur iPad

## 2.4 Fonctionnalités ajoutées en version 1.1

- historique persistant de cinquante révisions par album
- synchronisation CloudKit locale d’abord
- téléchargement à la demande des photos
- fusion automatique des modifications portant sur des pages différentes
- conservation et résolution explicite des versions concurrentes d’une même page
- corbeille synchronisée pendant trente jours

## 2.5 Fonctionnalités ajoutées en version 1.2

- connexion Google
- import d’une ou plusieurs photos avec Google Photos Picker API
- reprise des téléchargements Google interrompus

## 2.6 Fonctionnalités hors périmètre

`SCP-001` — Les fonctionnalités suivantes sont explicitement hors périmètre des versions 1.0 à 1.2 :

- collaboration simultanée entre plusieurs personnes
- partage public d’un album sur un site Web
- réseau social, commentaires externes ou réactions
- commande d’impression
- application Android ou Web
- montage vidéo
- import, lecture ou export de vidéo
- images ou stickers animés, notamment GIF
- filtres photo avancés
- musique de fond du diaporama
- duplication d’une page
- duplication d’un album
- capture directe depuis l’appareil photo
- lecture de la bibliothèque privée de stickers de Messages
- création, détourage ou import de stickers personnalisés
- tableaux, listes de contrôle, pièces jointes ou dessins dans les zones de texte
- serveur applicatif propriétaire
- texte ou commentaire audio
- affichage simultané de deux pages ou composition en double page
- marge de sécurité d’impression
- commande, prix ou parcours commercial Photoweb
- chiffrement ou protection par mot de passe d’un package exporté
- fusion avec un album existant lors de l’import d’un package
- migration des albums enregistrés par les prototypes de développement fondés sur la spécification 2.1

## 2.7 Applicabilité des exigences

| ID | Exigence |
|---|---|
| `REL-001` | Une exigence sans mention de version DOIT s’appliquer dès la version 1.0 et rester applicable aux versions suivantes. |
| `REL-002` | Une mention de version dans un titre de section DOIT s’appliquer à toutes les exigences de cette section, sauf indication plus précise. |
| `REL-003` | La version 1.1 DOIT hériter de toutes les exigences 1.0 et la version 1.2 de toutes les exigences 1.0 et 1.1. |
| `REL-004` | Les préfixes `HIS`, `SYN`, `ICL` et `CNF` DOIVENT entrer en vigueur en version 1.1. |
| `REL-005` | Le préfixe `GPH` DOIT entrer en vigueur en version 1.2. |

## 2.8 Stratégie temporaire de validation sans Mac

Le projet suit deux phases d’environnement distinctes. Cette organisation
modifie le moment où certaines preuves sont obtenues, mais elle ne réduit pas
le périmètre fonctionnel ni les critères de qualité.

### Phase A — développement progressif et validation manuelle sur iPad

Cette phase est retenue tant que le travail est effectué de manière
occasionnelle sans accès rentable à un Mac :

1. le code est écrit et versionné depuis Windows, VS Code et WSL ;
2. GitHub reste l’unique source de vérité ;
3. l’App Playground est compilé et exécuté sur l’iPad ;
4. les premières versions sont des prototypes ou builds internes ;
5. chaque session disponible exécute la campagne manuelle de la section 30.5 ;
6. les contrôles indisponibles sont inscrits dans le registre de validation
   différée, sans être marqués comme réussis.

| ID | Exigence |
|---|---|
| `ENV-001` | Le rythme intermittent de la phase A NE DOIT PAS imposer la location continue d’un Mac ; les validations macOS/Xcode DOIVENT être regroupées dans une campagne ultérieure. |
| `ENV-002` | Chaque contrôle d’un commit candidat testé sur iPad DOIT avoir un résultat reproductible dans le suivi : `RÉUSSI`, `ÉCHOUÉ`, `BLOQUÉ`, `NON TESTÉ` ou `NON APPLICABLE`. |
| `ENV-003` | Une fonction dépendant d’une capacité absente de Swift Playgrounds, notamment une configuration CloudKit, un type de document exporté ou un retour OAuth, DOIT rester bloquée jusqu’à une preuve sur un environnement compatible. |
| `ENV-004` | Un parcours réussi sur iPad NE DOIT PAS être extrapolé à l’iPhone, aux simulateurs, à la signature de distribution, aux tests automatisés Apple, à Instruments ou à l’accessibilité du PDF. |
| `ENV-005` | Les sources, ressources et configurations générées par Swift Playgrounds DOIVENT rester versionnées et préparées pour une ouverture ou migration déterministe dans Xcode. |

Une **version viable sur iPad** est un jalon interne, et non une version
publique. Elle doit permettre, sur un même commit, de créer un album, placer
plusieurs photos dans plusieurs cadres, modifier une zone de texte et un
sticker, appliquer un modèle, fermer et relancer l’application sans perte,
lire l’album, lancer le diaporama et effectuer les exports réellement
disponibles. Toute étape non encore
implémentée ou bloquée est explicitement listée.

### Phase B — qualification ponctuelle avec macOS et Xcode

Dès qu’une version viable sur iPad existe, ou plus tôt si un blocage empêche
de progresser, une session ponctuelle sur un Mac local, prêté, distant ou
hébergé doit être organisée. Elle n’a pas besoin d’être permanente ni
quotidienne.

| ID | Exigence |
|---|---|
| `ENV-006` | Avant toute publication publique, le commit candidat DOIT être ouvert et compilé avec la version de Xcode compatible avec les SDK ciblés. |
| `ENV-007` | La campagne macOS/Xcode DOIT exécuter la qualification différée de la section 30.6 et enregistrer ses preuves dans le suivi. |
| `ENV-008` | Toute correction réalisée pendant la campagne macOS/Xcode DOIT revenir dans GitHub et la campagne DOIT être relancée sur le nouveau commit candidat. |
| `ENV-009` | Si une capacité obligatoire reste impossible à signer, compiler ou tester, la version concernée NE DOIT PAS être publiée tant que le blocage n’est pas résolu ou que la spécification n’est pas explicitement révisée. |

---

# 3. Décisions produit validées

| ID | Décision retenue |
|---|---|
| `DEC-00` | Toute mention de « changement de pas » signifie « changement de page ». |
| `DEC-01` | L’application est développée en Swift et SwiftUI avec iOS 26 et iPadOS 26 minimum. |
| `DEC-02` | Les pages peuvent être ajoutées, supprimées et réorganisées. Elles ne peuvent pas être dupliquées. Un album contient toujours au moins une page. Il n’existe pas de limite fonctionnelle fixe au nombre de pages. |
| `DEC-03` | Le nom de l’album est obligatoire. La couverture utilise automatiquement la première occurrence photo de l’album selon l’ordre des pages et des éléments. L’utilisateur peut choisir une autre occurrence déjà placée. |
| `DEC-04` | Chaque page possède son propre fond. Une commande explicite permet d’appliquer le fond choisi à toutes les pages. |
| `DEC-05` | L’éditeur et le mode lecture affichent toujours une seule page active. La vue globale affiche uniquement des miniatures destinées à l’organisation et n’est pas un mode de lecture à deux pages. |
| `DEC-06` | La navigation fonctionne avec des boutons et avec un balayage horizontal. |
| `DEC-07` | À `1×`, une photo conserve sa taille native de référence, sans agrandissement ou réduction automatique, et est centrée dans son cadre. Le fond de page reste visible dans toute partie du masque non couverte. Si la photo est plus grande que le cadre, l’utilisateur peut descendre sous `1×`, par exemple à `0,5×`, sans modifier l’original. Seules la conversion technique des pixels source vers cette taille native et la borne basse du zoom restent provisoires en section 3.1. |
| `DEC-08` | Le texte suit le modèle Photoweb : plusieurs zones indépendantes, police, taille, couleur et alignement. Les fonctions de traitement de texte avancé sont exclues. |
| `DEC-09` | Le catalogue contient uniquement des stickers statiques intégrés et licenciés pour le projet. Leur manipulation suit celle des autres éléments du canevas. |
| `DEC-10` | Google Photos utilise le sélecteur officiel et accepte une sélection multiple de photos à partir de la version 1.2. |
| `DEC-11` | La durée du diaporama est globale par page. La boucle est désactivée par défaut et chaque page reste affichée pendant cette durée. |
| `DEC-12` | L’export propose un package modifiable et un PDF. L’historique n’est pas inclus dans le package exporté. |
| `DEC-13` | À partir de la version 1.1, les pages et métadonnées indépendantes sont fusionnées automatiquement. Toute modification concurrente du même élément conserve toutes les branches et demande une résolution explicite. |
| `DEC-14` | À partir de la version 1.1, une révision est créée à la fin d’une session modifiée, après un renommage ou changement de couverture depuis la bibliothèque, et avant toute restauration. Les cinquante dernières révisions sont conservées. |
| `DEC-15` | Annuler et Rétablir couvrent uniquement la session d’édition courante. L’historique persistant couvre les sessions précédentes. |
| `DEC-16` | La suppression d’un album ou d’une page demande confirmation. La suppression d’un élément du canevas ne demande pas confirmation mais reste annulable. |
| `DEC-17` | L’application fonctionne en portrait et en paysage. L’ordre de lecture est de gauche à droite dans les versions 1.0 à 1.2. |
| `DEC-18` | Les vidéos, GIF, Live Photos animées et stickers animés ne sont pas des contenus éditables. Une Live Photo importée utilise uniquement sa composante photo fixe. |
| `DEC-19` | Les cadres photo, zones de texte et stickers sont des éléments indépendants partageant une géométrie et un ordre de profondeur communs. |
| `DEC-20` | Le catalogue propose plusieurs modèles de page ; chaque emplacement produit par un modèle reste ensuite modifiable manuellement. |
| `DEC-21` | Les lots sont des incréments internes ou TestFlight. La première version publique est la version 1.0 définie en section 2. |
| `DEC-22` | La synchronisation CloudKit, les conflits et l’historique persistant sont livrés en version 1.1. |
| `DEC-23` | Google Photos est livré en version 1.2. |
| `DEC-24` | Toute commande métier validée est persistée. Une interruption brutale peut perdre uniquement un geste ou les caractères pas encore journalisés ; le dernier brouillon journalisé est conservé. |
| `DEC-25` | La suppression d’un album le place dans une corbeille pendant trente jours avant suppression définitive. |
| `DEC-26` | Les réglages du diaporama sont globaux à l’application et non enregistrés dans chaque album. |
| `DEC-27` | Les modèles, le dé aléatoire, le remplissage et la mise en page automatique font partie de la version 1.0. |
| `DEC-28` | L’enveloppe garantie est de cent pages, cinq gigaoctets, vingt photos, vingt zones de texte et vingt stickers statiques par page. Une zone de texte est limitée à mille caractères. |
| `DEC-29` | Une seule fenêtre peut modifier un album donné à la fois. Une seconde fenêtre peut l’ouvrir en lecture seule. |
| `DEC-30` | Les documents `.photoalbum` sont des packages natifs Apple, documentés pour permettre leur lecture et leur création par des logiciels tiers. |
| `DEC-31` | La référence fonctionnelle est l’éditeur Web Photoweb documenté et observé en 2026 ; l’interface finale utilise des composants iOS natifs et adaptatifs, sans reprendre la marque, les assets, les couleurs commerciales ni le parcours de commande Photoweb. |
| `DEC-32` | Les panneaux sont ordonnés `Photos`, `Mise en page`, `Fonds`, `Stickers`, `Cadres et formes`. La marge de sécurité n’est jamais proposée. |
| `DEC-33` | Le développement redémarre sur le modèle 3.0. Les données produites par les prototypes 2.1 ne sont pas migrées et leurs tests constituent uniquement un historique ; le premier schéma publiable adopte directement le canevas multiélément. |
| `DEC-34` | Le panneau Photos permet de supprimer un original de l’album courant uniquement lorsque son nombre d’occurrences dans cet album est nul. La suppression demande confirmation et reste annulable pendant la session. |
| `DEC-35` | Appliquer un modèle plus petit qu’un ensemble de cadres remplis demande confirmation avant de retirer les occurrences excédentaires ; leurs originaux restent disponibles dans Photos. |
| `DEC-36` | Les zones de texte participent librement à la même pile de profondeur que les photos et stickers ; elles peuvent être placées devant ou derrière eux. |
| `DEC-37` | Ajouter des photos propose une source native Depuis vos autres albums afin de réutiliser, sans duplication binaire inutile, des originaux déjà présents dans l’application. |

## 3.1 Convention technique de zoom à confirmer avant implémentation

Les cinq comportements demandés ont été arbitrés par l’utilisateur. Une seule
convention d’implémentation reste à confirmer : un fichier numérique n’a pas de
« taille d’origine » indépendante d’un repère de sortie. Pour garantir le même
rendu sur iPhone, iPad, miniature et PDF, `CRP-001` et `DAT-006` proposent
provisoirement une page photo canonique de **2 400 × 3 000 unités** pour le
canevas 4:5 et une plage continue de zoom photo de **`0,1×` à `8×`**. À
`1×`, un pixel source après orientation EXIF correspond à une unité de ce
repère ; une photo de 4 800 × 6 000 pixels occupe donc deux fois la largeur et
la hauteur de la page et l’échelle `0,5×` la ramène à 2 400 × 3 000.
La borne `0,1×` est une borne d’interface fixe proposée, et non un ajustement
automatique au cadre : une image extrêmement grande ou panoramique PEUT donc
rester partiellement rognée à `0,1×`. L’alternative à arbitrer serait une
borne basse calculée pour permettre de contenir entièrement chaque photo dans
son cadre.

Cette convention ignore les métadonnées DPI, `UIImage.scale`, le facteur Retina
et la taille de la fenêtre. Elle ne fixe ni la résolution du PDF ni celle de
l’écran : elle définit uniquement la taille native persistante de la photo dans
le canevas.
Elle DOIT être confirmée avant d’implémenter `CRP-001` à `CRP-007` et
`DAT-006` à `DAT-008`. Toutes les autres décisions de composition sont figées.

---

# 4. Terminologie

| Terme | Définition |
|---|---|
| **Album** | Document contenant un nom, une couverture, une liste ordonnée de pages et, à partir de la version 1.1, un historique. |
| **Page** | Canevas de composition contenant un fond et une liste ordonnée d’éléments. |
| **Élément** | Cadre photo, zone de texte ou sticker possédant un identifiant, une géométrie et un ordre de profondeur. |
| **Cadre photo** | Élément géométrique pouvant être vide ou contenir une occurrence de photo, une forme de découpe, un contour et un cadre décoratif. |
| **Placement photo** | Paramètres non destructifs de zoom et de déplacement d’une photo à l’intérieur de son cadre. |
| **Zone de texte** | Élément contenant du texte et ses attributs Photoweb de police, taille, couleur et alignement. |
| **Sticker** | Élément graphique statique issu du catalogue intégré et placé librement. |
| **Fond** | Texture ou couleur appartenant à une page ; elle peut être appliquée à une page ou à tout l’album. |
| **Modèle de mise en page** | Définition versionnée d’emplacements photo et texte normalisés appliquée à une page. |
| **Mise en page automatique** | Mode qui choisit et réapplique un modèle compatible après ajout ou retrait d’une photo afin d’éviter les cadres vides. |
| **Vue globale** | Grille de miniatures utilisée pour sélectionner, ajouter, supprimer et réorganiser les pages sans les afficher à taille d’édition. |
| **Mode édition** | Mode permettant de modifier l’album. |
| **Mode lecture** | Mode épuré et non modifiable. |
| **Diaporama** | Navigation automatique entre les écrans de l’album. |
| **Révision** | Instantané persistant de l’état complet d’un album. |
| **Package d’album** | Document autonome et versionné qui peut être importé sur un autre appareil. |

---

# 5. Structure générale de l’application

## 5.1 Écrans obligatoires

1. Bibliothèque des albums
2. Création ou renommage d’un album
3. Éditeur d’album à une seule page
4. Vue globale des pages
5. Panneau Photos et sélecteur de source
6. Panneau Mise en page
7. Panneau Fonds
8. Sélecteur de stickers
9. Panneau Cadres et formes
10. Éditeur de cadrage photo
11. Éditeur de zone de texte
12. Prévisualisation
13. Mode lecture
14. Paramètres du diaporama
15. Diaporama
16. Historique des révisions — version 1.1
17. Export
18. Import
19. Résolution de conflit CloudKit — version 1.1
20. Réglages de synchronisation — version 1.1
21. Réglages du compte Google — version 1.2

## 5.2 Navigation principale

| ID | Exigence |
|---|---|
| `APP-001` | La bibliothèque DOIT être l’écran racine. |
| `APP-002` | Une pression sur une carte DOIT ouvrir l’album en mode édition, sauf si cet album est déjà modifié dans une autre fenêtre ; la seconde fenêtre DOIT alors l’ouvrir en lecture seule. |
| `APP-003` | Le mode lecture DOIT être accessible depuis l’éditeur. |
| `APP-004` | Le diaporama DOIT être accessible depuis le mode lecture et depuis le menu de l’éditeur. |
| `APP-005` | Chaque commande métier validée DOIT être persistée sans attendre la fermeture de l’éditeur. |
| `APP-006` | Le retour vers la bibliothèque, le changement d’album et le passage en arrière-plan DOIVENT clore la session d’édition après enregistrement des commandes déjà validées. |
| `APP-007` | À partir de la version 1.1, la clôture d’une session modifiée DOIT créer une révision après réussite de la sauvegarde. |
| `APP-008` | Le passage en arrière-plan DOIT déclencher immédiatement la validation du journal local ; il NE DOIT PAS être considéré comme l’unique mécanisme de sauvegarde. |
| `APP-009` | Une terminaison brutale PEUT perdre le geste continu ou la saisie non validée en cours, mais NE DOIT PAS perdre une commande déjà validée. |
| `APP-010` | Une ouverture en lecture seule causée par une autre fenêtre d’édition DOIT afficher la raison et proposer Réessayer lorsque le verrou d’édition est libéré. |
| `APP-011` | Le verrou d’édition DOIT être propre au processus et à l’album, être libéré à la fermeture de la scène et ne pas survivre à une relance de l’application. |

---

# 6. Bibliothèque et gestion des albums

## 6.1 Bibliothèque

| ID | Exigence |
|---|---|
| `ALB-001` | La bibliothèque DOIT afficher les albums sous forme de grille adaptative. |
| `ALB-002` | Chaque carte DOIT afficher la couverture, le nom et la date de dernière modification. |
| `ALB-003` | Les albums DOIVENT être triés par date de dernière modification décroissante par défaut. |
| `ALB-004` | Un bouton principal DOIT permettre de créer un album. |
| `ALB-005` | Une commande DOIT permettre d’importer un package d’album. |
| `ALB-006` | Une pression sur une carte DOIT ouvrir l’éditeur. |
| `ALB-007` | Un menu contextuel DOIT proposer Renommer, Choisir la couverture, Exporter et Supprimer. |
| `ALB-008` | La suppression d’un album DOIT afficher une confirmation explicite. |
| `ALB-009` | La bibliothèque DOIT posséder un état vide avec une action Créer un album et une action Importer. |
| `ALB-010` | Une miniature manquante ou en cours de génération NE DOIT PAS empêcher l’ouverture de l’album. |
| `ALB-017` | La suppression confirmée d’un album DOIT le déplacer dans une corbeille locale pendant trente jours. |
| `ALB-018` | La bibliothèque DOIT permettre d’ouvrir la corbeille, de restaurer un album et de le supprimer définitivement après confirmation. |
| `ALB-019` | Un album dans la corbeille NE DOIT PAS apparaître dans la bibliothèque principale et NE DOIT PAS être modifiable. |
| `ALB-020` | À l’expiration des trente jours, l’album DOIT être supprimé définitivement uniquement après validation durable du tombstone. Cette suppression retire ses appartenances et identifiants d’assets logiques ; un fichier binaire dont le `contentHash` est encore référencé par un autre album ou un état récupérable reste conservé selon `LOC-008`. |
| `ALB-021` | Renommer un album et changer sa couverture depuis la bibliothèque DOIVENT être annulables tant que l’utilisateur reste dans la bibliothèque. |
| `ALB-022` | À partir de la version 1.1, renommer un album ou changer sa couverture DOIT créer une révision persistante après validation. |
| `ALB-023` | L’expiration de la corbeille DOIT être évaluée au lancement et au moins une fois par jour lorsque l’application reste active. |
| `ALB-024` | La durée de rétention DOIT être calculée comme trente périodes de vingt-quatre heures à partir de `trashedAt` en UTC. |

## 6.2 Création

| ID | Exigence |
|---|---|
| `ALB-011` | La création DOIT demander un nom non vide après suppression des espaces en début et en fin. |
| `ALB-012` | Deux albums PEUVENT porter le même nom. |
| `ALB-013` | Un album nouvellement créé DOIT contenir une page vide. |
| `ALB-014` | Le fond initial DOIT être le thème Album classique à spirales. |
| `ALB-015` | L’album nouvellement créé DOIT ouvrir sa première et unique page active dans l’éditeur. |
| `ALB-016` | L’album DOIT être créé localement avant l’ouverture de l’éditeur. |

## 6.3 Couverture

| ID | Exigence |
|---|---|
| `COV-001` | La couverture par défaut DOIT utiliser la première occurrence photo non vide, selon l’ordre des pages puis l’ordre de profondeur des éléments, du fond vers le premier plan. |
| `COV-002` | La couverture DOIT rendre le cadrage, la forme, le contour et le cadre décoratif de l’occurrence choisie ; toute partie de son masque non couverte par la photo DOIT conserver la transparence et révéler le rendu de page situé dessous selon `CRP-001`. |
| `COV-003` | L’utilisateur DOIT pouvoir sélectionner une occurrence photo déjà placée dans l’album ; le choix DOIT identifier la page et l’élément. |
| `COV-004` | L’utilisateur NE DOIT PAS pouvoir importer une photo uniquement pour la couverture dans les versions 1.0 à 1.2. |
| `COV-005` | Si la page, le cadre ou le contenu choisi est supprimé, la couverture DOIT revenir à la première occurrence disponible, même si le même asset existe ailleurs. |
| `COV-006` | Si l’album ne contient aucune occurrence photo, la couverture DOIT afficher le nom de l’album sur le fond de la première page. |
| `COV-007` | La miniature de couverture DOIT utiliser le même moteur de rendu que la page, être recadrée au centre puis mise en cache. |

---

# 7. Canevas de composition et éditeur

## 7.1 Repère logique et éléments

Le format logique initial reste un portrait **4:5**. Toutes les géométries
persistantes utilisent la page orientée après rendu comme repère : origine en
haut à gauche, largeur et hauteur normalisées de `0` à `1`.

| ID | Exigence |
|---|---|
| `CAN-001` | Une page DOIT accepter simultanément zéro à plusieurs cadres photo, zones de texte et stickers. Aucun séparateur ni rapport fixe entre photo et texte NE DOIT exister. |
| `CAN-002` | Chaque élément DOIT posséder un identifiant stable, un centre, une largeur, une hauteur, une rotation et une clé d’ordre de profondeur. |
| `CAN-003` | Le fond DOIT être rendu sous tous les éléments ; les autres éléments DOIVENT partager une seule pile de profondeur et pouvoir se chevaucher. |
| `CAN-004` | Les poignées, contours de sélection, guides, boutons locaux, cadres photo vides et emplacements texte vides de modèle DOIVENT être des aides d’édition exclues de la lecture, des miniatures finales et des exports. |
| `CAN-005` | Une géométrie validée DOIT laisser au moins le centre de l’élément dans la page afin qu’il reste sélectionnable ; un élément PEUT dépasser les bords et son rendu DOIT alors être rogné par la page. |
| `CAN-006` | La largeur et la hauteur validées d’un élément NE DOIVENT PAS être inférieures à `0,05` de la dimension de page correspondante. |
| `CAN-007` | Toute taille, marge ou géométrie de modèle DOIT provenir d’une définition centralisée et non d’une constante dispersée dans les vues. |
| `CAN-008` | Le même moteur de composition DOIT rendre l’éditeur, la prévisualisation, la lecture, les miniatures, le diaporama et le PDF. |
| `CAN-009` | Sous réserve de confirmation de la convention 3.1, chaque sortie DOIT transformer uniformément la page canonique `2 400 × 3 000` vers sa destination, sans faire dépendre la composition de la densité d’écran, de la taille de fenêtre, du zoom du canevas ou de la résolution du PDF. |

## 7.2 Organisation des commandes

| ID | Exigence |
|---|---|
| `EDT-001` | Les cinq panneaux de création DOIVENT apparaître dans cet ordre stable : Photos, Mise en page, Fonds, Stickers, Cadres et formes. |
| `EDT-002` | Sur iPad, ces panneaux DOIVENT utiliser un rail latéral et un inspecteur repliable ; sur iPhone, ils DOIVENT utiliser une barre inférieure et une feuille adaptative. Leur contenu et leur ordre fonctionnel restent identiques. |
| `EDT-003` | Dans l’ordre fonctionnel, la barre principale DOIT proposer Retour, Aide, nom de l’album avec Renommer, état de sauvegarde, Sauvegarder, Annuler, Rétablir, Couper, Copier, Coller, Mise en page auto, Créer — Vue page, Organiser — Vue globale, Prévisualiser puis Exporter. |
| `EDT-004` | Une commande trop large pour l’iPhone DOIT rester disponible dans un menu Plus sans changer son libellé, son effet ni son ordre relatif. |
| `EDT-005` | La marge de sécurité, un prix, Commander et toute commande commerciale NE DOIVENT PAS apparaître. |
| `EDT-006` | Changer ou fermer un panneau NE DOIT PAS modifier ni désélectionner l’élément courant. |
| `EDT-007` | L’état de sauvegarde DOIT afficher Enregistré, Enregistrement… ou Échec de sauvegarde selon le dernier résultat durable. |
| `EDT-008` | La page DOIT proposer les actions locales Ajouter une photo et Ajouter du texte ; elles restent accessibles quand aucun élément n’est sélectionné. |

### 7.2.1 Libellés et icônes fonctionnelles

Les noms de SF Symbols ci-dessous fixent l’intention visuelle. Si un symbole
n’existe plus sur la version minimale, l’application utilise le symbole natif
le plus proche sans modifier le libellé accessible ni la position de la
commande.

| Emplacement | Commande | Symbole de référence | État désactivé |
|---|---|---|---|
| Barre principale | Retour aux albums | `chevron.left` | jamais |
| Barre principale | Aide | `questionmark.circle` | jamais |
| Barre principale | Renommer l’album | `pencil` | album ouvert en lecture seule |
| Barre principale | Sauvegarder | `externaldrive.badge.checkmark` | aucun changement à consolider |
| Barre principale | Annuler | `arrow.uturn.backward` | pile Annuler vide |
| Barre principale | Rétablir | `arrow.uturn.forward` | pile Rétablir vide |
| Barre principale | Couper | `scissors` | aucun élément sélectionné |
| Barre principale | Copier | `doc.on.doc` | aucun élément sélectionné |
| Barre principale | Coller | `doc.on.clipboard` | presse-papiers incompatible |
| Barre principale | Mise en page auto | `wand.and.stars` avec interrupteur | jamais, sauf tâche atomique en cours |
| Barre principale | Créer — Vue page | `rectangle.portrait` | déjà active |
| Barre principale | Organiser — Vue globale | `square.grid.2x2` | déjà active |
| Barre principale | Prévisualiser | `eye` | alerte bloquante, notamment texte débordant |
| Barre principale | Exporter | `square.and.arrow.up` | texte débordant selon `TBX-021` ou tâche atomique incompatible en cours |
| Rail ou barre de panneaux | Photos | `photo.on.rectangle` | jamais |
| Panneau Photos | Ajouter des photos | `photo.badge.plus` | import ou réutilisation atomique en cours |
| Source d’ajout | Photothèque | `photo.on.rectangle` | sélecteur système indisponible |
| Source d’ajout | Fichiers | `folder` | sélecteur système indisponible |
| Source d’ajout | Depuis vos autres albums | `rectangle.stack` | aucun autre album actif contenant une photo disponible |
| Miniature photo | Supprimer de cet album | `trash` | photo utilisée dans l’album ou tâche atomique en cours |
| Panneau Photos | Masquer / Afficher les photos utilisées | `eye.slash` / `eye` | jamais |
| Panneau Photos | Trier | `arrow.up.arrow.down` | moins de deux photos |
| Panneau Photos | Remplir l’album | `wand.and.stars` | aucune photo inutilisée ou tâche atomique en cours |
| Rail ou barre de panneaux | Mise en page | `rectangle.3.group` | jamais |
| Rail ou barre de panneaux | Fonds | `paintpalette` | jamais |
| Rail ou barre de panneaux | Stickers | `face.smiling` | jamais |
| Rail ou barre de panneaux | Cadres et formes | `square.on.circle` | aucun cadre photo sélectionné |
| Page | Ajouter une photo | `photo.badge.plus` | jamais |
| Page | Ajouter du texte | `textformat` avec badge `+` | jamais |
| Page | Changer aléatoirement la mise en page | `dice` | moins de deux modèles compatibles |
| Canevas | Zoom arrière | `minus.magnifyingglass` | zoom à `50 %` ou mode cadrage |
| Canevas | Ajuster | `arrow.up.left.and.arrow.down.right` | zoom à `100 %` et page centrée, ou mode cadrage |
| Canevas | Zoom avant | `plus.magnifyingglass` | zoom à `400 %` ou mode cadrage |
| Navigation de page | Précédent | `chevron.left` | première page |
| Navigation de page | Suivant | `chevron.right` | dernière page |
| Vue globale | Ajouter une page | `rectangle.stack.badge.plus` | tâche atomique incompatible en cours |
| Miniature de page | Réorganiser | `line.3.horizontal` | album d’une seule page |
| Miniature de page | Supprimer la page | `trash` | album d’une seule page |

### 7.2.2 Icônes des barres contextuelles

| Type | Commande | Symbole de référence | État désactivé |
|---|---|---|---|
| Cadre vide | Ajouter une photo | `photo.badge.plus` | jamais |
| Cadre vide | Cadres et formes | `square.on.circle` | jamais |
| Cadre photo ou sticker | Remplacer | `arrow.triangle.2.circlepath` | import atomique en cours pour une photo ; jamais pour un sticker |
| Cadre photo | Retirer la photo | `photo.badge.minus` | cadre vide |
| Cadre photo | Recadrer | `crop` | cadre vide |
| Cadre photo | Pivoter à gauche / à droite | `rotate.left` / `rotate.right` | cadre vide |
| Cadre photo ou sticker | Retourner horizontalement | `arrow.left.and.right` | cadre vide pour une photo |
| Texte | Police | `textformat` | aucune zone de texte sélectionnée |
| Texte | Taille | `textformat.size` | aucune zone de texte sélectionnée |
| Texte | Gras / Italique | `bold` / `italic` | aucune zone de texte sélectionnée |
| Texte | Couleur | `paintpalette` | aucune zone de texte sélectionnée |
| Texte | Alignement | `text.alignleft`, `text.aligncenter`, `text.alignright` ou `text.justify` | aucune zone de texte sélectionnée |
| Texte | Interligne | `line.3.horizontal` | aucune zone de texte sélectionnée |
| Texte ou sticker | Opacité | `circle.lefthalf.filled` | type non compatible |
| Tout élément | Rotation… | `rotate.right` | aucune sélection |
| Tout élément | Dupliquer | `plus.square.on.square` | aucune sélection |
| Tout élément | Premier plan / Avancer | `arrow.up.to.line` / `arrow.up` | élément déjà au premier plan |
| Tout élément | Reculer / Arrière-plan | `arrow.down` / `arrow.down.to.line` | élément déjà à l’arrière-plan |
| Tout élément | Supprimer | `trash` | aucune sélection |
| Mode cadrage | Zoom photo | `magnifyingglass` | cadre vide ou opération atomique en cours |
| Mode cadrage | Annuler / Réinitialiser / Terminé | `xmark` / `arrow.counterclockwise` / `checkmark` | opération atomique en cours |

| ID | Exigence |
|---|---|
| `EDT-010` | Chaque commande des tableaux 7.2.1 et 7.2.2 DOIT conserver son ordre relatif, son libellé accessible et son état activé/désactivé sur iPhone et iPad. |
| `EDT-011` | L’état actif d’un panneau ou d’une vue DOIT combiner forme, libellé ou indicateur avec la couleur ; la couleur seule est interdite. |
| `EDT-012` | Sans sélection, Couper et Copier sont désactivés ; Photos, Mise en page, Fonds et Stickers, les deux ajouts locaux, le dé compatible, Auto, Vue globale et Prévisualiser restent accessibles. Cadres et formes est désactivé tant qu’aucun cadre photo n’est sélectionné. |
| `EDT-013` | Avec un cadre vide sélectionné, la barre contextuelle DOIT proposer Ajouter une photo, Cadres et formes, Dupliquer, ordre de profondeur et Supprimer. Recadrer et les transformations du contenu sont désactivés. |
| `EDT-014` | Avec une photo, un texte ou un sticker sélectionné, seule la barre propre au type définie par `FRM-005`, `TBX-009` ou `STK-016` DOIT apparaître, suivie des commandes communes dans le même ordre. |
| `EDT-015` | En mode cadrage, les panneaux, navigation de page et transformations du cadre DOIVENT être temporairement désactivés ; la barre DOIT proposer Zoom photo avec sa valeur en `×`, Annuler, Réinitialiser et Terminé. Zoom photo expose toute la plage de `CRP-004`, y compris les valeurs inférieures à `1×`, avec un ajustement accessible sans pincement. Les commandes de zoom du canevas restent visuellement distinctes et désactivées jusqu’à la sortie du cadrage. |
| `EDT-016` | Sur iPad, Créer, Organiser et Prévisualiser DOIVENT former un sélecteur de mode visible dans cet ordre. Sur iPhone, la présentation PEUT changer mais ces trois commandes NE DOIVENT PAS être enfouies dans Plus. Le libellé accessible de Créer DOIT inclure Vue page et celui d’Organiser Vue globale. |
| `EDT-017` | Les barres contextuelles DOIVENT respecter le tableau 7.2.2. Une commande de profondeur désactivée à une extrémité NE DOIT PAS désactiver l’autre direction disponible ; Supprimer utilise le rôle destructif sans dépendre de la couleur seule. |
| `EDT-018` | Exporter DOIT ouvrir le choix défini par `EXP-001`. Sur iPad, cette commande reste la dernière action visible de la barre ; sur iPhone, elle PEUT être placée dans Plus après Prévisualiser. |
| `EDT-019` | Aide DOIT ouvrir une aide native consultable hors ligne et contextualisée sur la vue ou le panneau actif. Elle explique au minimum sélection, ajout photo, cadre vide, modèle, dé, Auto, texte, stickers, vue globale et alertes de qualité, sans reprendre les textes ni la marque Photoweb. |
| `EDT-020` | En largeur régulière, Ajouter une photo et Ajouter du texte DOIVENT rester deux boutons visibles près du canevas, dans cet ordre. En largeur compacte, ils PEUVENT être regroupés sous un bouton Ajouter avec le symbole `plus`, dont le menu conserve Photos puis Texte ; l’action reste accessible en deux activations au plus. |

## 7.3 Sélection, gestes et barre contextuelle

| ID | Exigence |
|---|---|
| `ELM-001` | Un seul élément PEUT être sélectionné. Une pression choisit l’élément de premier plan sous le point ; pour un cadre photo, toute sa forme de masque participe au hit-testing, y compris une partie non couverte par les pixels de la photo. Une pression sur une zone vide désélectionne. |
| `ELM-002` | La sélection DOIT afficher un contour non exporté, quatre poignées d’angle, quatre poignées latérales et une poignée de rotation extérieure. |
| `ELM-003` | Glisser l’intérieur déplace l’élément ; les poignées le redimensionnent ; la poignée de rotation le fait tourner. Un pincement et une rotation à deux doigts DOIVENT offrir les mêmes transformations. |
| `ELM-004` | Les cadres photo et zones de texte PEUVENT changer de rapport ; les stickers DOIVENT conserver leurs proportions. |
| `ELM-005` | Des guides magnétiques DOIVENT signaler l’alignement avec les bords et centres de la page ainsi qu’avec les bords et centres des autres éléments. Aucun guide de marge de sécurité NE DOIT exister. |
| `ELM-006` | Un accrochage DOIT intervenir à six points écran ou moins du guide, produire un retour haptique léger une seule fois et cesser dès que cette distance est dépassée. |
| `ELM-007` | Chaque transformation continue DOIT produire une seule commande annulable lors de sa validation. |
| `ELM-008` | La barre contextuelle commune DOIT proposer Dupliquer, Premier plan, Avancer, Reculer, Arrière-plan et Supprimer, avec les commandes propres au type insérées avant ces commandes. |
| `ELM-009` | Couper, Copier et Coller DOIVENT agir sur l’élément sélectionné. Coller crée un nouvel identifiant et tente un décalage de 12 points vers le bas et la droite, réduit sur chaque axe autant que nécessaire pour respecter `CAN-005`. Sur la même page, la copie est placée juste au-dessus de l’original ; sur une autre page, elle est placée au premier plan. Elle devient sélectionnée. |
| `ELM-010` | Supprimer un élément NE DOIT PAS demander confirmation et DOIT rester annulable. |
| `ELM-011` | Les touches fléchées DOIVENT déplacer la sélection de `0,01` de la dimension correspondante ; avec la touche Option, le pas DOIT être `0,0025`. |
| `ELM-012` | Le déplacement et le redimensionnement DOIVENT avoir des alternatives accessibles par menu ; aucune opération obligatoire NE DOIT dépendre uniquement d’un geste multipoint. |
| `ELM-013` | Rotation… DOIT ouvrir un contrôle accessible exprimé en degrés, borné dans `[-180, 180)`, avec pas de `1°`, actions `−90°`, `+90°` et Réinitialiser à `0°`. Valider constitue une seule commande annulable sur la géométrie de l’élément ; pour une photo, cette rotation du cadre reste distincte des rotations de contenu de `FRM-005`. |
| `ELM-014` | Une pression longue sur un point couvert par plusieurs éléments DOIT proposer Sélectionner un élément, lister les candidats du premier plan vers l’arrière-plan avec un type, un extrait ou une description accessible non ambiguë, puis sélectionner le choix sans changer sa profondeur. Une action VoiceOver équivalente DOIT permettre de retrouver notamment un texte entièrement masqué par une photo. |

### 7.3.1 Zoom du canevas

| ID | Exigence |
|---|---|
| `ZOM-001` | Le zoom du canevas DOIT être un état de fenêtre d’édition distinct de la composition. La valeur `100 %` correspond à la page entière ajustée par aspect-fit dans l’espace disponible et centrée ; la plage autorisée va de `50 %` à `400 %` de cette échelle. |
| `ZOM-002` | Les commandes Zoom arrière, Ajuster et Zoom avant DOIVENT utiliser les symboles, libellés accessibles et états du tableau 7.2.1. Zoom arrière et Zoom avant parcourent respectivement les paliers `50`, `75`, `100`, `125`, `150`, `200`, `300` et `400 %`; à partir d’une valeur intermédiaire, elles choisissent le palier strictement inférieur ou supérieur. Ajuster fixe `100 %` et recentre la page. |
| `ZOM-003` | Un pincement sur une zone vide du canevas DOIT modifier le zoom continûment autour de son point médian, avec limitation à la plage de `ZOM-001`. Le relâchement NE DOIT PAS arrondir à un palier. |
| `ZOM-004` | Lorsque les limites visuelles de la page dépassent la fenêtre, un déplacement à deux doigts sur une zone vide DOIT déplacer le centre visible sans permettre de perdre entièrement la page. Sur un axe où la page tient dans la fenêtre, elle reste centrée. |
| `ZOM-005` | La priorité des gestes DOIT être déterministe : en mode cadrage, les gestes commencés dans le cadre sélectionné modifient le contenu selon `CRP-002` et `CRP-003`; hors cadrage, un geste à un doigt ou à deux doigts commencé dans l’élément sélectionné transforme cet élément selon `ELM-003`; un pincement ou déplacement à deux doigts commencé sur une zone vide agit sur la fenêtre selon `ZOM-003` et `ZOM-004`. La navigation de page ne commence que si `NAV-005` l’autorise. |
| `ZOM-006` | Chaque scène d’édition DOIT conserver en mémoire de session, pour chaque `pageID`, le zoom continu et le centre visible normalisé. Passer en Vue globale ou en prévisualisation puis revenir restaure cet état ; supprimer la page le supprime. Une relance initialise toute page à `100 %` centrée. |
| `ZOM-007` | Le zoom et le centre visible NE DOIVENT PAS être sérialisés dans l’album, modifier `updatedAt`, créer une commande Annuler/Rétablir, ni affecter éditeur logique, miniature, lecture, diaporama ou export. |
| `ZOM-008` | Contours, poignées, boutons locaux et guides DOIVENT conserver une épaisseur et une cible tactile constantes en points écran pendant le zoom ; seule leur position suit la transformation du canevas. |

## 7.4 Gestion des pages

| ID | Exigence |
|---|---|
| `PAG-001` | Un album DOIT toujours contenir au moins une page. |
| `PAG-002` | Un bouton Ajouter une page DOIT créer une page vide immédiatement après la page active. |
| `PAG-003` | Le gestionnaire des pages DOIT afficher des miniatures numérotées. |
| `PAG-004` | Une pression longue suivie d’un glissement DOIT permettre de réorganiser les pages. |
| `PAG-005` | La réorganisation DOIT être enregistrée comme une seule action annulable. |
| `PAG-006` | La suppression d’une page DOIT demander confirmation. |
| `PAG-007` | Le bouton de suppression DOIT être désactivé lorsque l’album ne contient qu’une page. |
| `PAG-008` | Une suppression confirmée DOIT rester annulable pendant la session courante. |
| `PAG-009` | La suppression d’une page DOIT supprimer tous ses `PageElement`, notamment cadres remplis ou vides, zones de texte et stickers. Elle NE DOIT PAS retirer les originaux de `photoAssetIDs` ni supprimer une ressource encore référencée par l’album. |
| `PAG-010` | Après suppression la page active DOIT devenir la page suivante si elle existe ou la page précédente. |
| `PAG-011` | Les numéros affichés DOIVENT être recalculés après une réorganisation. |
| `PAG-012` | L’application DOIT garantir son fonctionnement jusqu’à cent pages par album et DOIT avertir l’utilisateur au-delà sans imposer de limite arbitraire si les ressources de l’appareil restent suffisantes. |
| `PAG-013` | Vue page DOIT afficher sous le canevas une barre ordonnée Précédent, `Page N sur M`, Suivant. Les états suivent `NAV-001` à `NAV-003` et les icônes le tableau 7.2.1 ; le compteur est accessible mais non interactif. |
| `PAG-014` | Vue globale DOIT placer Ajouter une page dans sa barre d’outils. Chaque miniature DOIT offrir Réorganiser par poignée ou geste et Supprimer la page par menu contextuel ; les alternatives VoiceOver appliquent les mêmes règles et icônes que le tableau 7.2.1. |
| `PAG-015` | Une page créée par Ajouter une page DOIT utiliser le fond par défaut de `BG-002`, l’état de mise en page de `AUT-015`, une liste d’éléments et un ordre d’accessibilité vides. Elle NE DOIT PAS copier implicitement le fond ou les éléments de la page active. |

## 7.5 Raccourcis clavier

`EDT-009` — Sur iPad avec clavier, l’éditeur DOIT prendre en charge `⌘Z`,
`⇧⌘Z`, `⌘X`, `⌘C`, `⌘V`, Supprimer et les déplacements par flèches. Les
raccourcis NE DOIVENT PAS s’exécuter lorsqu’un champ de texte les consomme.

## 7.6 Modèles de mise en page

| ID | Exigence |
|---|---|
| `TPL-001` | Le panneau Mise en page DOIT regrouper les modèles par nombre de cadres photo (`1`, `2`, …, `7+`) et permettre de filtrer les modèles avec ou sans zone de texte. |
| `TPL-002` | Chaque modèle DOIT posséder un identifiant et une version stables, un nom localisé, des emplacements photo et texte normalisés et un ordre de lecture explicite. Sa miniature fidèle DOIT être un rendu dérivé régénérable de ces slots et styles par le moteur commun, et non un asset indépendant. |
| `TPL-003` | Pour chacun des nombres de une à huit photos, la version 1.0 DOIT fournir au moins deux variantes sans emplacement texte et deux variantes avec exactement un emplacement texte. Des variantes ayant plusieurs textes PEUVENT s’ajouter ; en leur absence, le dé est normalement indisponible sur une page qui possède plusieurs zones de texte. |
| `TPL-004` | Appliquer un modèle DOIT reconstruire les géométries photo et texte concernées, sans modifier le fond ni les stickers. La géométrie produite DOIT être persistée indépendamment du catalogue. |
| `TPL-005` | L'ordre de base d'un type est l'ordre de ses identifiants dans `accessibilityOrder`; un identifiant absent est ajouté après eux par `order` puis comparaison lexicographique des seize octets UUID. Pour l'affectation, les cadres remplis précèdent les cadres vides et les textes contenant au moins un `Character` précèdent les textes vides, chaque sous-groupe conservant l'ordre de base. Ils sont affectés aux slots du même type triés par `readingOrder` puis octets ASCII croissants de l'identifiant de slot, et chaque élément affecté reçoit exactement le `sourceTemplateSlotID` de son slot. L'ordre de profondeur NE DOIT donc pas, à lui seul, changer leur futur emplacement. |
| `TPL-006` | Si le modèle possède plus d’emplacements photo que la page ne contient de cadres, il DOIT créer les cadres vides manquants. S’il possède moins d’emplacements que de cadres mais au moins autant que de cadres remplis, les seuls cadres vides excédentaires sont retirés sans confirmation dans l’ordre inverse défini par `TPL-005`. |
| `TPL-007` | Si un modèle possède moins d’emplacements photo que de cadres remplis, une confirmation DOIT annoncer le nombre exact d’occurrences qui seraient retirées et proposer Annuler ou Appliquer. Annuler ne modifie rien. Après confirmation, les cadres remplis excédentaires puis tous les cadres vides sans slot sont retirés selon l’ordre inverse de `TPL-005`; leurs assets restent dans Photos et l’opération complète reste annulable selon `TPL-010`. |
| `TPL-008` | Un modèle ayant moins d’emplacements texte que de zones non vides DOIT être désactivé et expliquer que du texte devrait être retiré. Aucun texte NE DOIT disparaître lors d’un changement de modèle. |
| `TPL-009` | Appliquer un modèle DOIT conserver exactement le `nativeScale`, le point focal, les quarts de tour et le retournement de chaque photo. La nouvelle géométrie du cadre NE DOIT PAS déclencher un zoom automatique de couverture ; les parties non couvertes suivent `CRP-001`. |
| `TPL-010` | L’application d’un modèle, y compris la réaffectation de tous ses contenus, DOIT constituer une seule commande annulable. |
| `TPL-011` | Modifier manuellement la géométrie d’un cadre photo DOIT passer `photoMode` à `free`, effacer ses identifiants de modèle et appliquer `AUT-006` si nécessaire. Modifier une zone de texte liée à un slot DOIT seulement effacer son `sourceTemplateSlotID`; sa géométrie devient libre sans modifier `photoMode` ni `isAutoLayoutEnabled`. |
| `TPL-012` | Un emplacement texte sans texte existant DOIT créer une zone vide persistante liée par `sourceTemplateSlotID`, afficher Ajouter du texte uniquement en édition et rester absente de toutes les sorties finales. La toucher commence la saisie définie par `TBX-004`. |
| `TPL-013` | Lors d'un changement de modèle, les zones de texte suivent obligatoirement `TPL-005` : les zones non vides sont affectées d'abord, puis les zones vides existantes. Toute zone vide restante sans slot est retirée sans confirmation et tout slot texte restant crée une nouvelle zone vide selon `TPL-012`. Une zone contenant au moins un `Character` n'est jamais retirée par un modèle. |
| `TPL-014` | Un modèle NE DOIT PAS imposer l’ordre de profondeur. Les éléments existants conservent leur `order` et donc leurs relations avec les stickers ; seules leur position, taille et rotation sont remplacées. |
| `TPL-015` | Les cadres ou zones vides créés parce qu’un modèle possède des emplacements supplémentaires DOIVENT être ajoutés au-dessus de tous les éléments existants, dans l’ordre croissant de `readingOrder`, puis la pile DOIT être renumérotée selon `DAT-012`. |
| `TPL-016` | Appliquer explicitement un modèle, directement ou par le dé, DOIT désactiver Auto dans la même commande, fixer `photoMode = template`, `templateID` et `templateVersion` au modèle choisi et afficher Mise en page auto désactivée si elle était active. Aucun état intermédiaire avec Auto actif et cadres vides NE DOIT être publié. |
| `TPL-017` | Un cadre ou texte existant réaffecté conserve tous ses styles. Un élément vide nouvellement créé utilise le style du slot s’il existe, après validation de ses références de catalogue, sinon les valeurs de `FRM-009` ou `TBX-025`; le style effectivement choisi est persisté et ne dépend plus du modèle. |
| `TPL-018` | Le dé DOIT appliquer exactement la même transition et la même commande atomique que `TPL-010` et `TPL-016`. Son résultat fixe le modèle choisi ; il NE DOIT PAS laisser une provenance aléatoire ou un état Auto implicite. |
| `TPL-019` | Le catalogue créable DOIT provenir d'un manifeste canonique `docs/layout-templates-v1.json`, validé par un schéma public. Il énumère exactement chaque identifiant, version, état actif, clé de nom, slots, géométries, ordre de lecture et styles par défaut. Son fichier et son SHA-256 DOIVENT être figés dans le dépôt avant toute implémentation de `TPL-001`, `RND-001` ou `AUT-012`; les minima de `TPL-003` y sont validés automatiquement. |
| `TPL-020` | Le couple (`id`, `version`) DOIT être unique dans le manifeste et une seule version active PEUT être créable pour un même `id`. Tout ID de modèle ou de slot respecte l'expression ASCII `^[a-z0-9][a-z0-9._-]{0,63}$`; les tris portent donc sur ses octets ASCII. Panneau, dé et Auto n'énumèrent que les versions actives. Une version inactive reste résolvable pour les diagnostics et les pages existantes, dont la géométrie persistée reste autoritaire selon `DAT-035`. |
| `TPL-021` | Lorsque Auto est désactivé, toute commande structurelle directe Ajouter, Dupliquer, Coller, Couper ou Supprimer portant sur un cadre photo ou une zone de texte DOIT fixer `photoMode = free`, effacer `templateID` et `templateVersion`, et donner `sourceTemplateSlotID = nil` à tout nouvel élément, dans la même commande annulable. Cette règle ne s'applique pas à l'application atomique d'un modèle ou du dé, qui suit `TPL-016`, ni à Auto. Remplir, remplacer ou retirer seulement le contenu d'un cadre existant ne change pas cette provenance. Ajouter, retirer ou transformer un sticker ne la change jamais. |
| `TPL-022` | Toute transition de `photoMode = template` vers `free` ou `automatic` DOIT mettre à `nil` le `sourceTemplateSlotID` de tous les cadres et textes dans la même commande, sans modifier pour cette seule raison leur géométrie ou leur contenu. L'application d'un modèle renseigne les slots selon `TPL-005`; modifier ensuite la seule géométrie d'un texte peut laisser ce texte à `nil` tout en conservant la provenance photo de la page selon `TPL-011`. |
| `TPL-023` | Seule l'application explicite d'un modèle par `TPL-005` PEUT attribuer un `sourceTemplateSlotID`. Toute création, duplication ou copie d'un cadre ou texte hors de cette opération initialise cet identifiant à `nil`, même si la source copiée en possède un et quel que soit l'état Auto. |

## 7.7 Dé aléatoire

| ID | Exigence |
|---|---|
| `RND-001` | Un bouton portant une icône de dé et le libellé accessible Changer aléatoirement la mise en page DOIT être visible dans Vue page. |
| `RND-002` | Pour le dé, un modèle est compatible si et seulement s’il possède exactement autant d’emplacements photo que la page contient de cadres photo, remplis ou vides, et exactement autant d’emplacements texte que la page contient de zones de texte, vides ou non. Le dé NE DOIT donc ajouter ni retirer aucun élément. |
| `RND-003` | Le dé NE DOIT changer ni le nombre, ni l’ordre des contenus, ni le fond, ni les stickers ; il change seulement les géométries définies par le modèle. |
| `RND-004` | Tant qu'un autre modèle compatible n'existe pas, le bouton DOIT être désactivé. Dans chaque cycle défini par `RND-006`, le modèle courant ne peut pas être choisi deux fois de suite et tous les autres modèles compatibles du sac DOIVENT être parcourus avant répétition. |
| `RND-005` | Le résultat choisi et toutes ses géométries DOIVENT être persistés et annulables comme une seule commande ; le caractère aléatoire NE DOIT PAS être rejoué à la relance. |
| `RND-006` | Le dé maintient en mémoire de session un sac des couples compatibles non encore parcourus dans le cycle. À la première utilisation, après relance, après changement de l’ensemble compatible ou après tout changement du modèle courant extérieur au dé — application manuelle, Annuler/Rétablir, passage en mode libre ou Auto — il reconstruit un nouveau cycle dans l’ordre ASCII ID/version puis retire le modèle courant s’il existe. Si le sac devient vide après le tirage précédent, un nouveau cycle est reconstruit de la même manière. Chaque pression choisit uniformément un indice du sac avec une source aléatoire injectée et un tirage entier sans biais, retire le couple choisi, puis applique `RND-005`. Les tests remplacent cette source sans modifier l’algorithme. |

## 7.8 Mise en page et remplissage automatiques

| ID | Exigence |
|---|---|
| `AUT-001` | Mise en page auto DOIT être un interrupteur visible dans la barre principale et persistant séparément pour chaque page dans `isAutoLayoutEnabled`. |
| `AUT-002` | Lorsque `isAutoLayoutEnabled` est vrai, l’ajout d’une occurrence photo DOIT produire exactement un cadre rempli par occurrence et aucun cadre vide. Toute occurrence nouvelle utilise le `PhotoPlacement` initial de `FRM-009`; les occurrences survivantes conservent le leur selon `AUT-004`. Retirer une occurrence DOIT aussi retirer son cadre, puis recalculer la géométrie des cadres remplis restants ; retirer la dernière occurrence laisse la page sans cadre photo. Chaque résultat fixe `photoMode = automatic` et efface les identifiants de modèle. |
| `AUT-003` | Le choix automatique DOIT être déterministe pour un même état et prendre en compte le nombre de photos, leur orientation, le rapport de page et la densité courante. |
| `AUT-004` | L’automatisme DOIT conserver l’ordre des photos et NE DOIT modifier ni les zones de texte, ni les stickers, ni le fond, ni le `nativeScale`, ni le point focal, ni l’orientation interne des photos. La nouvelle géométrie des cadres NE DOIT PAS déclencher un zoom automatique de couverture. |
| `AUT-005` | L’ajout ou le retrait déclencheur et la réorganisation résultante DOIVENT constituer une seule commande annulable. |
| `AUT-006` | Déplacer, redimensionner ou tourner manuellement un cadre photo DOIT fixer `isAutoLayoutEnabled = false`, `photoMode = free` et les identifiants de modèle à `nil` avant la transformation, puis afficher Mise en page auto désactivée pour cette page avec une action Annuler. La désactivation et la transformation forment une seule commande. |
| `AUT-007` | Recadrer une photo, déplacer un texte ou sticker, ou modifier une forme, un contour ou un cadre décoratif NE DOIT PAS désactiver l’automatisme photo. |
| `AUT-008` | Activer Auto sur une page qui contient au moins un cadre photo DOIT avertir que les cadres vides seront retirés et les géométries photo remplacées. Après confirmation, l’application fixe `isAutoLayoutEnabled = true`, recompose immédiatement les seules occurrences remplies selon `AUT-012`, fixe `photoMode = automatic` et efface les identifiants de modèle dans une commande annulable. Une page sans cadre suit directement cette transition sans confirmation. |
| `AUT-009` | Le panneau Photos DOIT proposer Remplir l'album lorsque des photos inutilisées existent. L'utilisateur choisit Aérée (`1–2`), Équilibrée (`3–4`) ou Dense (`5–8` photos par page). La capacité cible `c` vaut respectivement `2`, `4` ou `8`; seule la dernière page produite PEUT contenir moins que le minimum affiché lorsque le reliquat l'impose. |
| `AUT-010` | Soit `M > 0` photos inutilisées et la capacité `c` de `AUT-009`, Remplir l'album DOIT produire `p = ceil(M / c)` groupes : les `p - 1` premiers contiennent exactement `c` photos et le dernier `M - c × (p - 1)`. Les photos sont triées par `(capturedAt ?? importedAt)` UTC croissant, puis indice dans `photoAssetIDs`, puis octets UUID croissants. Les groupes sont affectés aux `p` premières pages sans occurrence photo dans l'ordre de l'album, puis aux pages manquantes créées après la dernière page; les autres pages restent inchangées. Sur chaque cible existante, tous les cadres photo vides sont retirés selon l'ordre inverse de `TPL-005` avant de créer exactement un cadre rempli par photo avec un `PhotoPlacement` initialisé selon `FRM-009`; fond, textes et stickers sont conservés. Chaque cible reçoit la densité choisie, `isAutoLayoutEnabled = true`, `photoMode = automatic`, des identifiants de modèle et de slot nuls et la géométrie finale de `AUT-012`. |
| `AUT-011` | Le remplissage complet DOIT présenter le nombre de photos, de cadres vides retirés, de pages existantes réutilisées et de pages créées, demander confirmation et constituer une seule commande annulable sans jamais supprimer un asset importé. |
| `AUT-012` | Pour zéro à vingt occurrences, le moteur DOIT toujours produire une géométrie valide : il utilise la projection des emplacements photo d’un modèle intégré ayant le compte exact lorsqu’elle existe, sinon un pavage généré de manière pure et déterministe respectant `CAN-005` à `CAN-007`, le rapport de page, l’orientation des photos et la densité. Pour zéro occurrence, ce pavage ne contient aucun cadre. |
| `AUT-013` | Au-delà de vingt occurrences, le moteur PEUT prolonger le pavage déterministe si les invariants de géométrie et de performance restent satisfaits. Sinon il DOIT conserver la composition, désactiver Auto pour la page et expliquer qu’une mise en page manuelle est nécessaire, sans retirer de contenu. |
| `AUT-014` | Lorsqu’un modèle intégré alimente Auto, seules ses géométries et son ordre d’emplacements photo sont utilisés. Ses emplacements texte et ses styles NE DOIVENT ni créer, ni déplacer, ni modifier une zone de texte ; `AUT-004` reste prioritaire. |
| `AUT-015` | Une nouvelle page DOIT commencer avec `isAutoLayoutEnabled = false`, `photoMode = free`, `density = balanced`, `templateID = nil`, `templateVersion = nil` et aucun cadre photo. Activer Auto sur cette page vide applique `AUT-008`; le premier ajout de photo déclenche alors `AUT-002`. |
| `AUT-016` | Parmi plusieurs modèles actifs ayant le compte photo exact, Auto affecte les photos dans l'ordre de `TPL-005` aux slots photo triés par `readingOrder` puis identifiant. Pour une occurrence, `ratioPhoto` vaut `pixelWidth / pixelHeight` selon `DAT-043`, avec permutation des axes si `quarterTurns` est impair; `ratioSlot = (slot.width × 4) / (slot.height × 5)` dans la page logique 4:5. La pénalité d'orientation vaut `Σ abs(log2(ratioPhoto / ratioSlot))` et la surface photo totale `Σ(slot.width × slot.height)`. Toute valeur de score non négative `x` est quantifiée par `q(x) = floor(x × 1 000 000 + 0,5) / 1 000 000`. Les candidats sont classés par le tuple `(q(pénalité), q(abs(surface - cible)), octets ASCII de id croissants, version croissante)`, avec cible `0,55`, `0,70` ou `0,85` selon la densité. Le premier candidat est obligatoire. |
| `AUT-017` | Pour le repli généré avec `N > 0`, soit `s = 0,04`, `0,025` ou `0,015` selon la densité; `s` est à la fois le retrait sur chacun des quatre bords, exprimé dans l'axe normalisé correspondant, et la gouttière horizontale ou verticale. Le moteur énumère `rows = 1...N`, fixe `columns = ceil(N / rows)` et rejette le couple si `(rows - 1) × columns >= N`. Il calcule `cellWidth = (1 - 2s - (columns - 1)s) / columns` et `cellHeight = (1 - 2s - (rows - 1)s) / rows`; chaque cadre a cette taille et une rotation nulle. Pour la rangée d'indice `i` et la cellule `j`, `centerY = s + (i + 0,5) × cellHeight + i × s`. Une rangée pleine utilise `left = s`; la dernière contient `last = N - (rows - 1) × columns` cadres et utilise `left = s + (columns - last) × (cellWidth + s) / 2`; dans les deux cas `centerX = left + (j + 0,5) × cellWidth + j × s`. Les photos sont affectées de gauche à droite puis de haut en bas. Après rejet selon `CAN-005` à `CAN-007`, le candidat obligatoire minimise lexicographiquement `(q(pénalité d'orientation de AUT-016), q(abs(N × cellWidth × cellHeight - cible)), rows × columns - N, rows, columns)`. Pour `N = 0`, `AUT-012` produit directement zéro cadre. |
| `AUT-018` | Désactiver manuellement l'interrupteur DOIT conserver exactement les géométries et la provenance `photoMode` courantes, fixer seulement `isAutoLayoutEnabled = false` et constituer une commande annulable. Une modification ultérieure d'un cadre suit `TPL-011`. |
| `AUT-019` | Tant qu'Auto est actif, une commande directe qui créerait un cadre photo vide, notamment Dupliquer ou Coller, DOIT être désactivée comme incompatible. Ajouter, dupliquer ou coller un cadre rempli ajoute son occurrence puis applique `AUT-002` dans la même commande; Couper ou Supprimer un cadre rempli retire son occurrence puis applique aussi `AUT-002`. Les créations de texte et sticker restent permises, utilisent `sourceTemplateSlotID = nil` selon `TPL-023` et ne recomposent pas les photos. |

---

# 8. Fonds de page

## 8.1 Catalogue

| ID | Exigence |
|---|---|
| `BG-001` | La version 1.0 DOIT fournir les trois fonds intégrés définis en section 8.2. |
| `BG-002` | Le fond par défaut DOIT être `album.classicSpiral` version `1`, représentant un album photo classique avec reliure à spirales. |
| `BG-003` | Chaque motif ou fond intégré au catalogue DOIT posséder un identifiant et une version stables indépendants de son libellé. Aucun et les couleurs unies sont identifiés par leur cas de `BackgroundSelection` et leur valeur RGBA, sans `catalogID`. |
| `BG-004` | Le catalogue DOIT afficher une miniature et un nom pour chaque fond. |
| `BG-005` | Une pression sur un fond DOIT l’appliquer immédiatement à la page active uniquement. Une commande Appliquer à toutes les pages DOIT être proposée séparément. |
| `BG-006` | Le changement de fond DOIT être annulable. |
| `BG-007` | Le fond DOIT être rendu en édition, en lecture, en diaporama et dans le PDF. |
| `BG-008` | Si un fond enregistré n’existe plus dans le bundle après une mise à jour, la page DOIT rendre sa copie de secours validée. Si cette copie est elle-même absente ou invalide, l’éditeur utilise provisoirement le fond par défaut, conserve l’identifiant d’origine en diagnostic et l’export reste bloqué selon `PDF-008`. |
| `BG-011` | `textContrastHint` DOIT valoir `darkText` ou `lightText` et déterminer la couleur initiale d’une nouvelle zone de texte, sans modifier les zones existantes. |
| `BG-012` | Le panneau DOIT proposer Aucun, des couleurs unies et les motifs intégrés, chacun avec une miniature fidèle. |
| `BG-013` | Appliquer un fond à toutes les pages DOIT annoncer le nombre de pages concernées et constituer une seule commande annulable. |
| `BG-014` | Un changement de fond NE DOIT déplacer, supprimer ni recolorer aucun élément. |
| `BG-015` | Aucun DOIT produire une page blanche opaque en édition et dans toutes les sorties. Une couleur unie DOIT être un `SRGBAColor` opaque persistant et rendre exactement cette couleur, indépendamment du mode clair ou sombre. |
| `BG-016` | Pour Aucun, la couleur initiale de texte est noire. Pour une couleur unie, l’application DOIT choisir initialement entre noir et blanc selon la meilleure valeur de contraste WCAG ; pour un motif, elle utilise `textContrastHint`. Ce choix initial NE DOIT jamais recolorer un texte existant. |

## 8.2 Définition d’un thème

`BG-009` — Chaque thème DOIT au minimum fournir :

```text
BackgroundTheme
- catalogID
- catalogVersion
- localizedNameKey
- textContrastHint
```

L'entrée de registre d'un thème utilise un unique payload `asset` : la
surface complète et opaque de la page, reliure ou décoration de bord comprise,
encodée en PNG sRGB au rapport 4:5. Elle est ajustée exactement aux limites de
la page logique 4:5, sans recadrage ni mosaïque. La miniature de catalogue et la
surface de couverture sont des rendus dérivés de ce même payload par le moteur
commun, et non des fichiers persistants ou des payloads supplémentaires.

Le catalogue initial est :

| Identifiant stable | Version | Nom français | Indication de contraste |
|---|---:|---|---|
| `album.classicSpiral` | `1` | Album classique | `darkText` |
| `album.travelKraft` | `1` | Carnet de voyage | `darkText` |
| `album.minimalDark` | `1` | Nuit minimaliste | `lightText` |

`BG-010` — Le rendu de la spirale DOIT rester sur le bord gauche de chaque
page. Il ne modifie pas le repère logique et aucune gouttière de double page
n’est rendue.

---

# 9. Vue page, vue globale et prévisualisation

| ID | Exigence |
|---|---|
| `GLO-001` | Vue page DOIT afficher exactement une page active sur iPhone comme sur iPad et dans toutes les orientations. À l’ouverture initiale et après Ajuster, cette page est centrée et rendue par aspect-fit aussi grande que l’espace disponible le permet ; tout zoom ou déplacement ultérieur suit `ZOM-001` à `ZOM-008`. |
| `GLO-002` | L’application NE DOIT proposer aucun réglage Une page/Deux pages et NE DOIT afficher deux pages côte à côte ni dans l’éditeur, ni en lecture, ni dans le diaporama. |
| `GLO-003` | Vue globale DOIT afficher toutes les pages comme une grille adaptative de miniatures numérotées, sans permettre la transformation de leurs éléments. |
| `GLO-004` | Toucher une miniature en vue globale DOIT la rendre active et revenir à Vue page ; revenir par le bouton Vue page sans sélection DOIT rouvrir la dernière page active. |
| `GLO-005` | Vue globale DOIT permettre l’ajout, la suppression et la réorganisation des pages selon `PAG-001` à `PAG-015`. |
| `GLO-006` | Une miniature DOIT signaler de manière accessible un cadre photo vide, un texte débordant ou une photo dont l’état dérivé selon `QLT-001` est `Acceptable` ou `Insuffisante`. |
| `GLO-007` | Prévisualiser DOIT afficher une seule page à la fois et masquer panneaux, sélection, poignées, guides, cadres vides et commandes d’édition. |
| `GLO-008` | Quitter la prévisualisation DOIT restaurer la page, la sélection et le zoom de canevas antérieurs sans modifier le document. |
| `GLO-009` | L’ajout ou la suppression d’une page depuis la vue globale DOIT conserver une seule page active déterminée par `PAG-002` et `PAG-010`. |

---

# 10. Navigation et animation de page

## 10.1 Commandes

| ID | Exigence |
|---|---|
| `NAV-001` | Des boutons Précédent et Suivant DOIVENT être disponibles. |
| `NAV-002` | Le bouton Précédent DOIT être désactivé au début de l’album. |
| `NAV-003` | Le bouton Suivant DOIT être désactivé à la fin de l’album. |
| `NAV-004` | Un balayage horizontal à un doigt commencé sur une zone vide de la page DOIT produire la même navigation que les boutons. |
| `NAV-005` | Le balayage ne DOIT PAS commencer pendant le déplacement ou la transformation d’un élément, le cadrage d’une photo, l’édition de texte ou l’interaction avec un panneau. Tout geste à deux doigts commencé sur une zone vide est consommé exclusivement par le zoom ou déplacement de fenêtre `ZOM-003`/`ZOM-004` et NE DOIT JAMAIS déclencher la navigation. |
| `NAV-006` | Un geste DOIT être horizontal si son déplacement horizontal absolu dépasse 1,25 fois son déplacement vertical absolu ; il DOIT être vertical dans le cas inverse. Tant que ce seuil n’est pas atteint, aucune navigation ne DOIT commencer. |
| `NAV-007` | Une fois le geste horizontal reconnu, un balayage vers la gauche demande Suivant et un balayage vers la droite demande Précédent. À une borne, le geste ne change pas de page et produit le même état désactivé que le bouton correspondant. |

## 10.2 Animation

| ID | Exigence |
|---|---|
| `ANI-001` | Chaque changement vers la page précédente ou suivante déclenché par `NAV-001` à `NAV-007` DOIT simuler une page tournée manuellement. L’ouverture d’un panneau, d’un menu ou d’un autre écran NE DOIT PAS utiliser cet effet. |
| `ANI-002` | L’animation DOIT suivre progressivement le doigt pendant un balayage interactif. |
| `ANI-003` | Le geste DOIT être validé lorsque le déplacement dépasse 25 % de la largeur ou lorsque sa vitesse dépasse 600 points par seconde dans la bonne direction. |
| `ANI-004` | Un geste non validé DOIT revenir à la page actuelle. |
| `ANI-005` | L’animation déclenchée par un bouton DOIT durer 350 ms avec une tolérance de 50 ms. |
| `ANI-006` | L’animation DOIT utiliser une perspective, une rotation autour du bord et une ombre évolutive. |
| `ANI-007` | L’application NE DOIT PAS utiliser d’API privée pour reproduire l’effet. |
| `ANI-008` | Une seule transition PEUT être active à la fois. Les commandes supplémentaires reçues avant sa fin DOIVENT être ignorées. |
| `ANI-009` | Lorsque Réduire les animations est activé l’application DOIT remplacer l’effet par un fondu court. |

---

# 11. Photos, cadres et cadrage

## 11.1 Panneau Photos

| ID | Exigence |
|---|---|
| `PHO-001` | Le panneau Photos DOIT proposer Ajouter des photos, une grille de miniatures, Masquer les photos utilisées et un tri par date de prise de vue, nom ou date d’import. Ajouter des photos ouvre, dans cet ordre, Photothèque, Fichiers et Depuis vos autres albums, puis Google Photos lorsque la version 1.2 est disponible. |
| `PHO-002` | Chaque miniature DOIT indiquer son nombre d’occurrences dans l’album ; Masquer les photos utilisées masque celles dont ce nombre est supérieur à zéro. |
| `PHO-003` | Chaque photo ajoutée appartient logiquement à la photothèque interne de l’album courant indépendamment de son placement et reste disponible après retrait d’une occurrence, jusqu’à une suppression explicite conforme à `PHO-009` et `PHO-010`. |
| `PHO-004` | Sur iPad, une photo DOIT pouvoir être glissée sur un cadre vide, un cadre rempli ou une zone vide de la page. Sur iPhone et iPad, une pression sur sa miniature remplit le cadre photo sélectionné, vide ou rempli, ou crée un cadre au centre si aucun cadre photo n’est sélectionné. |
| `PHO-005` | Déposer sur un cadre vide le remplit ; déposer sur un cadre rempli remplace uniquement sa photo ; déposer sur la page crée un nouveau cadre centré sur le dépôt. Tout contenu nouvellement affecté commence centré à `1×`, sans rotation ni retournement, selon `FRM-004` et `FRM-009`. |
| `PHO-006` | Lorsque Auto est désactivé, un cadre libre nouvellement créé DOIT utiliser la plus grande taille conservant le rapport de la photo dans une boîte de `0,45 × 0,45` de la page, respecter le minimum de `CAN-006`, être centré sur le dépôt ou sur la page et être placé au premier plan. La taille choisie pour le cadre NE DOIT PAS redimensionner automatiquement son contenu photo à l’intérieur. |
| `PHO-007` | Un import multiple DOIT conserver l’ordre de sélection. Un échec partiel NE DOIT PAS retirer les photos déjà importées et DOIT proposer Réessayer pour les seules erreurs. |
| `PHO-008` | Les états d’un import DOIVENT être En attente, Import en cours avec progression, Disponible, Interrompu, Format non pris en charge ou Fichier inaccessible. |
| `PHO-009` | Chaque miniature DOIT proposer Supprimer de cet album avec le symbole `trash`. La commande est activée si et seulement si le nombre d’occurrences de cet `assetID` dans les pages de l’album courant vaut zéro au moment de l’affichage ; sinon elle est désactivée et annonce « Utilisée N fois ». Retirer une occurrence ou supprimer son cadre ne supprime jamais automatiquement l’asset. |
| `PHO-010` | Activer Supprimer de cet album DOIT revalider atomiquement que le nombre d’occurrences dans l’album courant vaut zéro, puis demander confirmation en identifiant la photo et en proposant Annuler ou Supprimer. Si le compte est devenu positif, aucune confirmation destructive n’est validée, la miniature est actualisée et l’interface annonce que la photo est maintenant utilisée. Annuler ne modifie rien. Confirmer retire l’`assetID` et ses métadonnées logiques de la photothèque de cet album dans une seule commande annulable ; Annuler/Rétablir restaure ou retire l’entrée à son indice d’origine. L’action NE DOIT modifier ni Apple Photos, ni Fichiers, ni Google Photos, ni un autre album. La purge physique distincte suit `LOC-008` et `LOC-022` à `LOC-025`. |
| `PHO-011` | Ajouter une photo depuis la page DOIT ouvrir le panneau Photos en mode de choix pour un nouveau cadre. La prochaine miniature pressée crée ce cadre selon `PHO-006`; Annuler, changer de page ou fermer le mode de choix ne crée rien. |
| `PHO-012` | Ajouter une photo dans un cadre vide DOIT ouvrir le même panneau en ciblant cet `elementID`. La prochaine miniature pressée remplit uniquement ce cadre avec les valeurs initiales de `FRM-009` ; Annuler le choix conserve le cadre vide. |
| `PHO-013` | Si aucune photo n’est disponible, les modes de choix de `PHO-011` et `PHO-012` DOIVENT proposer le sélecteur système. Un import multiple ajoute toutes les photos au panneau puis revient au mode de choix sans en placer arbitrairement une ; l’utilisateur presse ensuite la miniature voulue. Ce parcours constitue l’alternative accessible au glisser-déposer. |
| `PHO-014` | Lorsque Auto est actif, toute création d'occurrence demandée par `PHO-004`, `PHO-005`, `PHO-011` ou par le remplissage d'un cadre vide dans `PHO-012` ajoute d'abord le `PhotoPlacement` logique initialisé selon `FRM-009`, puis laisse `AUT-002` déterminer, dans la même commande, la géométrie de tous les cadres. Le placement libre de `PHO-006` et l'ancienne géométrie d'un éventuel cadre vide NE DOIVENT PAS être publiés comme état intermédiaire. `PHO-012` ne crée jamais un deuxième cadre avant cette recomposition. |
| `PHO-015` | Depuis vos autres albums DOIT lister les albums actifs autres que l’album courant, en excluant la corbeille. Ils sont triés par `updatedAt` décroissant, puis nom localisé croissant, puis octets UUID croissants. Ouvrir un album source affiche toutes les photos de son `photoAssetIDs` dans leur ordre, y compris celles qui n’y sont pas placées. |
| `PHO-016` | Dans un album source, une photo dont le `contentHash` appartient déjà à la photothèque cible DOIT porter l’état Déjà ajoutée et être désactivée. Une photo dont le binaire n’est pas localement disponible DOIT proposer son téléchargement ou Réessayer et ne peut être ajoutée avant vérification de l’empreinte. La source accepte une sélection multiple et annonce le nombre choisi. |
| `PHO-017` | Valider Ajouter N photos depuis un autre album DOIT, dans l’ordre de sélection, créer pour chacune un nouvel `assetID` logique propre à l’album cible, l’ajouter à la fin de `photoAssetIDs` et copier ses métadonnées immuables. Le nouvel asset conserve `contentHash`, dimensions, type, nom d’origine, date de prise de vue et propriétés colorimétriques ; il fixe `source = .reusedAlbum` et `importedAt` à la date de validation. Aucun identifiant de l’album ou de l’asset source ne persiste dans le modèle cible. Le lot vérifie le quota logique `LOC-017`, journalise et valide métadonnées, index et appartenance dans la transaction de `LOC-016`, forme une seule commande annulable et ne modifie pas l’album source. |
| `PHO-018` | La réutilisation interalbum DOIT référencer le même fichier immuable global par `contentHash` sans nouvelle copie binaire. L’asset cible reste néanmoins autonome : supprimer la photo ou l’album source ne l’affecte pas, supprimer l’asset cible n’affecte pas la source, et un export de l’album cible embarque ses propres octets selon `PKG-008`. Après l’ajout, les photos apparaissent dans le panneau cible sans être placées arbitrairement sur une page. |

## 11.2 Import Apple

| ID | Exigence |
|---|---|
| `APL-001` | L’application DOIT utiliser `PhotosPicker` pour la photothèque et le sélecteur système public pour Fichiers. |
| `APL-002` | Le sélecteur DOIT autoriser plusieurs images statiques par opération et filtrer les vidéos. |
| `APL-003` | Une annulation NE DOIT modifier aucune donnée. |
| `APL-004` | Chaque photo sélectionnée DOIT être copiée dans le stockage contrôlé par l’application avant d’être marquée Disponible. |
| `APL-005` | Un album NE DOIT PAS dépendre uniquement d’un identifiant de la photothèque ou d’une URL de sécurité temporaire. |
| `APL-006` | Une copie dépassant 500 ms DOIT afficher une progression par fichier et globale. |
| `APL-007` | Une miniature orientée et gérée en couleur DOIT être générée après import. |
| `APL-008` | Une erreur sur un fichier NE DOIT remplacer aucune photo déjà présente dans un cadre. |

## 11.3 Google Photos — version 1.2

| ID | Exigence |
|---|---|
| `GPH-001` | La connexion DOIT utiliser Google Sign-In officiel et OAuth 2.0. |
| `GPH-002` | La sélection DOIT utiliser Google Photos Picker API sans recréer une interface de navigation Google Photos. |
| `GPH-003` | La session DOIT autoriser une sélection multiple de photos dans la limite maximale prise en charge par l’API et l’enveloppe locale. |
| `GPH-004` | Les ressources sélectionnées DOIVENT être téléchargées localement dans l’ordre retourné avant d’être marquées Disponibles. |
| `GPH-005` | Les photos importées DOIVENT rester disponibles après déconnexion du compte Google et hors ligne. |
| `GPH-006` | Les jetons DOIVENT être stockés dans le trousseau et NE DOIVENT apparaître ni dans les journaux, ni dans CloudKit, ni dans les packages. |
| `GPH-007` | Une session expirée DOIT proposer une nouvelle authentification sans modifier la page active. |
| `GPH-008` | La session Picker DOIT être abandonnée proprement après import ou annulation. |
| `GPH-009` | Le polling DOIT respecter `pollingConfig.pollInterval` et `pollingConfig.timeoutIn` retournés par le service. |
| `GPH-010` | Si une URL expire, l’application DOIT tenter d’en obtenir une nouvelle tant que la session le permet, puis proposer une nouvelle sélection. |
| `GPH-011` | Seules les ressources photo DOIVENT être importées ; une ressource vidéo retournée par le service DOIT être ignorée avec une explication non bloquante. |

## 11.4 Formats statiques et normalisation

| ID | Exigence |
|---|---|
| `FMT-001` | L’application DOIT accepter HEIF/HEIC, JPEG et PNG lorsqu’ils sont décodables par les frameworks publics du système. |
| `FMT-002` | Une image RAW décodable DOIT conserver son original et produire un dérivé statique non destructif pour l’affichage. |
| `FMT-003` | Une Live Photo DOIT utiliser uniquement sa composante photo fixe ; sa composante vidéo NE DOIT PAS être copiée. |
| `FMT-004` | GIF, APNG, vidéo et tout autre contenu animé NE DOIVENT PAS être importés. Le refus DOIT expliquer que seuls les contenus photo statiques sont pris en charge. |
| `FMT-005` | Les métadonnées d’orientation et le profil colorimétrique DOIVENT être appliqués au rendu sans réécrire l’original. |
| `FMT-006` | Une image déclarant plus de deux cents mégapixels après orientation DOIT être refusée avant décodage intégral. |
| `FMT-007` | Aucun plafond arbitraire inférieur aux limites de sécurité et d’espace local NE DOIT être appliqué à un fichier décodable. |
| `FMT-008` | Le PDF DOIT convertir avec gestion des couleurs les contenus non sRGB vers un espace compatible en préservant autant que possible leur apparence. |

## 11.5 Indicateur de qualité photo

| ID | Exigence |
|---|---|
| `QLT-001` | Chaque occurrence remplie DOIT exposer un indicateur dérivé de sa définition effective à la taille imprimée : `OK` à partir de `300 ppp`, `Acceptable` de `150 ppp` inclus à `300 ppp` exclus, et `Insuffisante` sous `150 ppp`. |
| `QLT-002` | Pour une page canonique dont le canevas 4:5 — et non la feuille PDF entière — est rendu sur `W` pouces par `H` pouces, la définition effective d’une photo DOIT valoir `min(2 400 / (nativeScale × W), 3 000 / (nativeScale × H))` ppp. Le calcul porte uniquement sur les pixels photo effectivement rendus ; une partie transparente du masque et le fond visible ne sont pas une photo de mauvaise qualité. Le point focal, le masque, la rotation, y compris un quart de tour, et la taille du cadre changent les pixels visibles mais pas cette densité locale isotrope tant que `nativeScale` et la taille de sortie restent identiques. |
| `QLT-003` | Avant qu’un format PDF soit choisi, le calcul DOIT utiliser le format régional par défaut de `PDF-016`, l’orientation automatique et la zone imprimable de `PDF-017`. Le dialogue d’export DOIT recalculer l’état pour le format effectivement choisi. |
| `QLT-004` | L’état DOIT être recalculé après remplacement, changement de `nativeScale`, rotation, redimensionnement, changement de masque ou toute reconfiguration géométrique d’un cadre par un modèle, le dé, Auto ou le format d’export. Il est dérivé et NE DOIT PAS être persisté ; une reconfiguration qui conserve `nativeScale` et la taille de sortie DOIT conserver le même état. |
| `QLT-005` | L’éditeur DOIT afficher l’état près de la barre d’un cadre sélectionné et la vue globale DOIT signaler les états `Acceptable` et `Insuffisante`. Forme, icône et libellé accessible DOIVENT accompagner la couleur. |
| `QLT-006` | Un état `Insuffisante` DOIT produire un avertissement avant export mais NE DOIT bloquer ni l’édition, ni la sauvegarde, ni l’export. |

## 11.6 Cadre vide, contenu et suppression

| ID | Exigence |
|---|---|
| `FRM-001` | Un cadre vide DOIT afficher une trame neutre, l’icône photo avec `+` et le libellé Ajouter une photo, tous exclus du rendu final. |
| `FRM-002` | La géométrie, le masque, le contour, le cadre décoratif et l’ordre appartiennent au cadre ; la référence d’asset et le cadrage appartiennent à son contenu photo. |
| `FRM-003` | Hors mise en page auto, Retirer la photo DOIT conserver le cadre vide et ses styles. Supprimer le cadre DOIT retirer le cadre et son contenu. Ces commandes DOIVENT être distinctes et annulables. En mode automatique, l’exception explicite de `AUT-002` s’applique. |
| `FRM-004` | Remplacer DOIT conserver la géométrie et les styles du cadre, affecter la nouvelle photo et initialiser son contenu centré à `1×`, sans rotation ni retournement. La nouvelle photo NE DOIT PAS être agrandie ou réduite automatiquement pour remplir le masque. |
| `FRM-005` | La barre photo DOIT présenter, dans cet ordre, Remplacer, Retirer la photo, Recadrer, Pivoter à gauche, Pivoter à droite, Retourner horizontalement, puis les commandes communes de `ELM-008`. |
| `FRM-006` | Les commandes DOIVENT utiliser des SF Symbols ou icônes natives équivalentes, avec les libellés accessibles exacts de `FRM-005`; l’icône ne remplace jamais le libellé VoiceOver. |
| `FRM-007` | Dupliquer un cadre rempli DOIT créer une nouvelle occurrence du même asset avec une copie indépendante du cadrage et des styles. |
| `FRM-008` | Les cadres photo sans `PhotoPlacement` produisent un avertissement non bloquant en prévisualisation et NE DOIVENT PAS être rendus dans les exports. Un cadre possédant un `PhotoPlacement` reste rempli au sens métier même si son contenu à taille native ne couvre pas tout le masque ; cette transparence normale ne produit pas l’avertissement Cadre vide. |
| `FRM-009` | Un nouveau cadre libre DOIT commencer avec le masque `shape.rectangle` version `1`, un contour d’épaisseur `0`, aucun cadre décoratif et, lorsqu’il est rempli, un cadrage centré à `1×`, sans rotation ni retournement du contenu. |

## 11.7 Cadrage non destructif

| ID | Exigence |
|---|---|
| `CRP-001` | Sous réserve de confirmation de la convention 3.1, le canevas photo DOIT utiliser un repère canonique de `2 400 × 3 000` unités. À `1×`, un pixel source après orientation EXIF mesure exactement une unité canonique et la photo est centrée sans ajustement automatique au cadre. Toute partie du masque sans pixel photo reste transparente et révèle les éléments de profondeur inférieure puis le fond de page. |
| `CRP-002` | Un double toucher sur la photo ou la commande Recadrer DOIT ouvrir le mode de cadrage en laissant le cadre fixe et en assombrissant ce qui se trouve hors du masque. |
| `CRP-003` | Dans ce mode, glisser déplace la photo en modifiant le point focal dans les bornes de `DAT-007`, pincer la zoome et les commandes de rotation ou retournement transforment son contenu sans transformer le cadre. Le point focal transformé reste au centre du cadre afin que le contenu ne puisse pas devenir entièrement introuvable. |
| `CRP-004` | Le zoom photo `nativeScale` DOIT varier continûment de `0,1` à `8`, bornes incluses. Le pincement et le contrôle accessible Zoom photo PEUVENT donc descendre sous `1×`, notamment à `0,5×`; ils NE DOIVENT PAS confondre cette valeur avec le zoom de fenêtre `ZOM-001`. Révéler le fond autour de la photo est autorisé et NE DOIT PAS provoquer de zoom correctif. |
| `CRP-005` | Réinitialiser DOIT restaurer l’orientation d’origine et le cadrage centré à `1×`; Annuler restaure l’état d’entrée et Terminé valide une seule commande annulable. |
| `CRP-006` | Le fichier original NE DOIT JAMAIS être modifié. Le cadrage DOIT persister le `nativeScale` absolu par rapport à `1×` et un point focal normalisé ; il NE DOIT persister ni facteur d’écran, ni échelle relative à un remplissage du masque. |
| `CRP-007` | Après changement du rapport, de la taille ou de la forme du cadre, application d’un modèle ou recomposition Auto, le moteur DOIT conserver exactement `nativeScale`, point focal, quarts de tour et retournement. Il NE DOIT ni recentrer ni ajuster la photo pour couvrir le nouveau masque. |

## 11.8 Cadres et formes

| ID | Exigence |
|---|---|
| `SHR-001` | Le panneau Cadres et formes DOIT être actif pour un cadre photo sélectionné et distinguer trois groupes : Forme, Contour et Cadre décoratif. |
| `SHR-002` | Une forme définit le masque de découpe. Le catalogue initial DOIT au minimum proposer Rectangle, Rectangle arrondi, Cercle, Ovale, Cœur et Étoile. |
| `SHR-003` | Un seul masque et un seul cadre décoratif PEUVENT être actifs par cadre. Dans Forme, Aucun signifie le masque procédural Rectangle et se sérialise par sa référence enregistrée ; dans Cadre décoratif, Aucun signifie `nil`. |
| `SHR-004` | Le contour DOIT proposer Aucun, une couleur sRGB avec alpha `1` et une épaisseur de `0` à `0,03` de la plus petite dimension de page. Aucun se sérialise canoniquement avec `width = 0` et la couleur noire opaque `(0, 0, 0, 1)`. |
| `SHR-005` | La version 1.0 DOIT fournir au moins six cadres décoratifs provenant du registre versionné et d’assets dont les droits autorisent la distribution ; aucun asset Photoweb ne doit être copié sans licence. |
| `SHR-006` | Changer de forme DOIT conserver exactement le `nativeScale`, le point focal et l’orientation du contenu. Il NE DOIT PAS augmenter le zoom pour couvrir le nouveau masque ; les parties non couvertes restent transparentes selon `CRP-001`. |
| `SHR-007` | Les portées Sélection, Toutes les photos de la page et Toutes les photos de l’album DOIVENT être proposées pour une forme, un contour ou un cadre décoratif. |
| `SHR-008` | Une application multiple DOIT annoncer le nombre de cadres affectés, ne modifier ni géométrie, ni asset photo, ni `nativeScale`, ni point focal, ni orientation du contenu, et constituer une seule commande annulable. |
| `SHR-009` | Le rendu d’un masque, contour ou cadre décoratif DOIT être identique dans toutes les sorties définies par `CAN-008`. |
| `SHR-010` | Les six formes initiales DOIVENT être des entrées `nativeVector` de version `1` portant respectivement les identifiants `shape.rectangle`, `shape.roundedRectangle`, `shape.circle`, `shape.oval`, `shape.heart` et `shape.star`. Rectangle est la valeur de Aucun définie par `SHR-003`. |
| `SHR-011` | Les six cadres décoratifs minimaux DOIVENT être des entrées `asset` de version `1` portant respectivement les identifiants `frame.whiteBorder`, `frame.blackBorder`, `frame.kraftTape`, `frame.travelStamp`, `frame.botanical` et `frame.instantPhoto`, avec les noms français Bord blanc, Bord noir, Ruban kraft, Tampon voyage, Feuillage et Photo instantanée. Leur preuve de licence DOIT être enregistrée dans le manifeste avant toute build de lot 2. |

`SHR-012` — Pour les six formes de `SHR-010`, `rendererID` DOIT être égal à
`catalogID` et la version `1` DOIT suivre le contrat public suivant. Les chemins
sont fermés, utilisent la règle de remplissage non nulle, n'ont pas de contour
intrinsèque et sont ensuite découpés aux limites de l'élément :

- `shape.rectangle` : rectangle couvrant exactement les limites de l'élément ;
- `shape.roundedRectangle` : même rectangle, avec un rayon de coin égal à
  `0,12 × min(largeur, hauteur)` ;
- `shape.circle` : cercle centré, de rayon `0,5 × min(largeur, hauteur)` ;
- `shape.oval` : ellipse centrée tangente aux quatre limites ;
- `shape.heart` : dans le carré normalisé puis mis à l'échelle de chaque axe,
  le chemin `M .50 .95 C .44 .88 .08 .65 .08 .34 C .08 .15 .21 .05 .36 .05 C .44 .05 .49 .10 .50 .17 C .51 .10 .56 .05 .64 .05 C .79 .05 .92 .15 .92 .34 C .92 .65 .56 .88 .50 .95 Z` ;
- `shape.star` : dans le carré normalisé puis mis à l'échelle de chaque axe,
  le polygone de dix sommets centré en `(0,5 ; 0,5)`, d'angle
  `-π/2 + kπ/5` pour `k = 0...9`, avec rayon `0,5` lorsque `k` est pair et
  `0,22` sinon.

Toute modification d'une de ces géométries exige une nouvelle
`catalogVersion`; elle NE DOIT PAS altérer le rendu de la version `1`.

`SHR-013` — Chaque entrée de cadre décoratif DOIT publier dans le registre ses
`sourceCapInsetsPixels` entiers et ses `destinationCapInsets` flottants
(`top`, `left`, `bottom`, `right`), puis utiliser le rendu neuf zones suivant.
Les insets source sont positifs ou nuls, leurs sommes horizontale et verticale
sont strictement inférieures à la largeur et à la hauteur orientées du payload.
Les insets destination sont finis, compris entre `0` et `0,5` exclus, et leurs
sommes sur chaque axe sont strictement inférieures à `1`; ils expriment la
fraction des limites non tournées de l'élément occupée par chaque bord. Les
quatre coins source sont mis à l'échelle de leurs rectangles destination, les
bords sont étirés seulement sur leur axe longitudinal et le centre sur les
deux axes, avec interpolation bilinéaire. Le cadre remplit les limites de
l'élément, conserve son alpha, est composé au-dessus de la photo masquée et du
contour, puis suit la rotation et le rognage de l'élément. Les deux jeux
d'insets font partie du contrat versionné de `CAT-009` et garantissent le même
rendu relatif à toute résolution.

`SHR-014` — Un contour d'épaisseur non nulle DOIT être tracé entièrement à
l'intérieur du chemin du masque, avec jointures et extrémités arrondies, en
source-over au-dessus de la photo masquée et sous le cadre décoratif. Son bord
extérieur coïncide avec le chemin du masque; il NE DOIT donc ni agrandir
l'élément ni modifier le cadrage.

---

# 12. Zones de texte

## 12.1 Création et édition

| ID | Exigence |
|---|---|
| `TBX-001` | Une page DOIT accepter plusieurs zones de texte indépendantes, superposables aux photos et stickers et ordonnées librement dans la pile commune. Toutes les commandes Premier plan, Avancer, Reculer et Arrière-plan leur sont applicables ; un texte PEUT donc se trouver derrière une photo ou un sticker. |
| `TBX-002` | Ajouter du texte DOIT être disponible dans la page et dans le menu d’ajout. La nouvelle zone DOIT être centrée, mesurer `0,60` de la largeur et `0,12` de la hauteur de page, et être placée au premier plan. |
| `TBX-003` | Une nouvelle zone DOIT afficher Votre texte comme texte indicatif sélectionné, ouvrir le clavier et supprimer la zone si l’utilisateur quitte sans remplacer l’indication. |
| `TBX-004` | Une pression sélectionne la zone ; une seconde pression ou un double toucher place le curseur. Terminer valide la saisie et Annuler restaure le contenu et le style à l’ouverture. |
| `TBX-005` | Le clavier et sa barre d’outils NE DOIVENT PAS masquer durablement le curseur ni la sélection sur iPhone ou iPad. |
| `TBX-006` | Une zone DOIT être limitée à mille `Character` Swift, espaces et sauts de ligne compris. La limite atteinte DOIT être annoncée et empêcher seulement les caractères supplémentaires. |
| `TBX-007` | Le collage DOIT conserver le texte et les seuls attributs pris en charge ; images, pièces jointes, listes, tableaux, liens actifs et métadonnées DOIVENT être retirés. Une URL reste du texte non cliquable. |
| `TBX-008` | Le correcteur et la dictée iOS PEUVENT être utilisés ; aucune correction NE DOIT être appliquée sans action ou réglage système de l’utilisateur. |

## 12.2 Mise en forme Photoweb

| ID | Exigence |
|---|---|
| `TBX-009` | La barre texte DOIT proposer dans cet ordre Police, Taille, Gras, Italique, Couleur, Alignement, Interligne, Opacité, puis les commandes communes de `ELM-008`. |
| `TBX-010` | Police, taille, graisse, italique et couleur DOIVENT s’appliquer aux caractères sélectionnés ; sans sélection, ils deviennent le style de frappe. |
| `TBX-011` | L’alignement gauche, centré, droit ou justifié et l’interligne de `0,8` à `2,0` DOIVENT s’appliquer aux paragraphes touchés. |
| `TBX-012` | L’opacité, comprise entre `0,1` et `1`, la rotation et l’ordre de profondeur DOIVENT s’appliquer à toute la zone. |
| `TBX-013` | Les polices proposées DOIVENT être décrites dans un manifeste, embarquées ou garanties par iOS et autorisées pour la distribution afin que le rendu soit stable hors ligne et à l’export. |
| `TBX-014` | Les tailles DOIVENT être persistées relativement à la hauteur logique de page, avec une plage équivalente à 8–96 points sur la page de référence ; l’interface PEUT afficher l’équivalent en points. |
| `TBX-015` | Une couleur DOIT être stockée en RGBA sRGB, avec quatre composantes finies bornées entre `0` et `1`. |
| `TBX-016` | Les boutons DOIVENT utiliser des icônes natives équivalentes à `textformat`, `textformat.size`, `bold`, `italic`, `paintpalette`, `text.alignleft` et `line.3.horizontal`, avec un libellé VoiceOver explicite. |
| `TBX-017` | Listes, cases à cocher, tableaux, retraits, surlignage, pièces jointes, dessin, audio et styles Notes NE DOIVENT PAS être proposés. |

## 12.3 Géométrie, débordement et persistance

| ID | Exigence |
|---|---|
| `TBX-018` | Redimensionner la zone DOIT modifier la boîte de composition sans changer la taille de police. Tourner la zone NE DOIT pas transformer les glyphes autrement que par la rotation globale. |
| `TBX-019` | Avant tout redimensionnement manuel, la hauteur DEVRAIT s’ajuster au contenu dans les limites de la page. Après redimensionnement, la géométrie choisie devient fixe. |
| `TBX-020` | Un texte débordant DOIT afficher un contour rouge, une icône d’alerte et une explication accessible ; aucun caractère NE DOIT être tronqué silencieusement. |
| `TBX-021` | Prévisualiser et Exporter DOIVENT être bloqués tant qu’une zone déborde et proposer d’ouvrir directement la page et la zone concernées. |
| `TBX-022` | Une séquence de frappe DOIT être regroupée après 750 ms d’inactivité ou à la perte de focus, persistée comme une commande et rester annulable. |
| `TBX-023` | Le modèle persistant DOIT stocker une suite ordonnée de paragraphes et de runs dont la concaténation correspond exactement au texte, sans RTF opaque ni structure de tableau ou de liste. |
| `TBX-024` | Le texte complet, ses attributs pris en charge et sa géométrie DOIVENT produire le même rendu dans toutes les sorties de `CAN-008`. |
| `TBX-025` | Une nouvelle zone DOIT utiliser la police système régulière, une taille relative équivalente à 18 points sur la page de référence, ni gras ni italique, la couleur initiale déterminée par `BG-011` ou `BG-016`, l’alignement centré, un interligne de `1`, une opacité de `1`, une rotation nulle et l’ajustement automatique de hauteur activé. |

---

# 13. Stickers statiques

## 13.1 Catalogue

| ID | Exigence |
|---|---|
| `STK-001` | Le panneau Stickers DOIT afficher Récents puis les catégories intégrées dans une bande horizontale et une grille adaptative. |
| `STK-002` | Une recherche DOIT interroger le nom et les tags localisés des stickers intégrés. |
| `STK-003` | Récents DOIT conserver les cinquante derniers identifiants distincts utilisés, du plus récent au plus ancien. |
| `STK-004` | Une pression DOIT ajouter le sticker au centre ; sur iPad, un glisser-déposer DOIT permettre de choisir directement sa position. |
| `STK-005` | La plus grande dimension initiale DOIT valoir `0,20` de la plus petite dimension de page et le sticker DOIT être ajouté au premier plan. |
| `STK-006` | Le panneau NE DOIT proposer ni Mes stickers, ni import, ni détourage, ni création personnalisée, ni contenu animé. |
| `STK-007` | Remplacer sur un sticker sélectionné DOIT ouvrir le catalogue et conserver son centre, sa rotation, son opacité, son retournement et son ordre. Si le nouveau rapport intrinsèque diffère, sa largeur et sa hauteur deviennent d'abord le plus grand rectangle de ce rapport entièrement contenu dans les anciennes limites non tournées. Si une dimension est alors inférieure au minimum de `STK-015`, le rectangle est agrandi uniformément autour de son centre jusqu'à satisfaire les deux minima, même s'il dépasse les anciennes limites; aucun sticker n'est déformé ni recadré. |
| `STK-008` | Changer de catégorie, rechercher ou fermer le panneau NE DOIT modifier aucun sticker déjà placé. |

## 13.2 Assets intégrés

| ID | Exigence |
|---|---|
| `STK-009` | Les stickers DOIVENT être statiques et décrits par le registre versionné : le couple `catalogID`/`catalogVersion`, le nom, les tags, la catégorie et le rapport intrinsèque DOIVENT correspondre à l'unique payload `asset` de l'entrée. La miniature est un rendu dérivé régénérable de ce payload et non une seconde ressource persistante. |
| `STK-010` | Les ressources DOIVENT être fournies avec des droits compatibles avec la distribution de l’application. |
| `STK-011` | Aucun personnage, logo, asset ni imitation d’asset Photoweb protégé NE DOIT être inclus sans licence explicite. |
| `STK-012` | La version 1.0 DOIT fournir au moins quarante stickers répartis entre Voyage, Transport, Nature, Météo et Symboles, avec au moins six stickers et trois tags français distinctifs par catégorie. |
| `STK-013` | Une ressource connue du registre `CAT-001` mais absente de la version installée DOIT utiliser la copie de secours de l’album validée selon `CAT-002` et signaler le diagnostic sans remplacer silencieusement le visuel. |

`CAT-001` — L’application DOIT embarquer un registre versionné unique pour
les fonds, stickers, formes et cadres décoratifs intégrés. Chaque entrée DOIT
contenir au minimum `catalogID`, `catalogVersion`, type de ressource, preuve de
licence ou de source et un discriminant de payload : `asset` avec type MIME,
longueur et empreinte SHA-256 attendus, ou `nativeVector` avec un `rendererID`
intégré, stable et sans octets externes.

`CAT-002` — Le couple (`catalogID`, `catalogVersion`) DOIT être unique. Toute
copie de secours d’une entrée `asset` utilisée hors du bundle DOIT avoir le
type réel, la longueur et l’empreinte exactement enregistrés pour ce couple ;
sinon elle est invalide. Une entrée `nativeVector` NE DOIT accepter aucun
fichier de secours fourni par un package.

`CAT-003` — Seules les références présentes dans ce registre PEUVENT être
persistées, synchronisées ou importées comme ressources de catalogue. Une
ressource visuelle arbitraire fournie par un package tiers constitue un contenu
personnalisé interdit par `SCP-001` et NE DOIT PAS devenir un sticker, un fond,
une forme ou un cadre modifiable.

`CAT-004` — Tout couple publié DOIT rester résolvable par le lecteur ou par une
migration publique de la même génération afin de respecter `PKG-012`. Il PEUT
être masqué du catalogue de création. Pour `asset`, ses métadonnées de
validation et la capacité à rendre sa copie de secours NE DOIVENT PAS être
retirées ; pour `nativeVector`, son contrat public et l'implémentation de son
`rendererID` NE DOIVENT PAS être retirés tant qu'un format public qui le
référence reste importable.

`CAT-005` — Avant de valider la commande d'application ou d'insertion d'une ressource
`asset`, l'application DOIT copier ses octets de référence dans le dépôt
immuable adressé par contenu et vérifier type, longueur et empreinte. Cette
opération et la création de la référence métier constituent une transaction
atomique selon la section 18.3. Une entrée `nativeVector` vérifie seulement que
son `rendererID` est pris en charge par la build.

`CAT-006` — Toute `CatalogResourceReference` vers une entrée `asset` DOIT
contenir un `fallbackContentHash` non nul qui résout exactement la copie créée
par `CAT-005`. Pour une entrée `nativeVector`, ce champ DOIT être nul. Une
couleur unie ou la sélection Aucun ne crée aucune référence de catalogue.

`CAT-007` — La copie de secours DOIT être conservée tant qu’un album, une
révision, une branche de conflit, une exportation en cours ou un staging validé
la référence. Sa purge suit `LOC-008`, `LOC-024` et `LOC-025`.

`CAT-008` — Pour `asset`, export et synchronisation DOIVENT partir de la copie
validée, et non relire implicitement le bundle courant. Pour `nativeVector`, ils
DOIVENT sérialiser uniquement le couple enregistré et vérifier le `rendererID`,
sans créer ni accepter de fichier. Un échec de copie ou de résolution lors de
la première utilisation annule la commande sans créer de référence incomplète.

`CAT-009` — Avant la sortie du lot 0, le dépôt DOIT publier le schéma du
registre et le contrat de chaque `rendererID` dans un format documenté,
indépendant du code Swift et exploitable par un lecteur tiers. Les trois
entrées de fond de `BG-009` et les six formes de `SHR-010`, avec leurs payloads,
empreintes et licences applicables, DOIVENT être figées avant la première build
du lot 1 qui les persiste. Le registre complet de la version 1, incluant
stickers, cadres, insets et toutes les preuves de licence, DOIT l'être avant la
première build du lot 2 qui persiste ces ressources et avant tout package
public. Il reprend exactement les primitives, paramètres et chemins de
`SHR-012` ainsi que le contrat de `SHR-013`; un nom de symbole SwiftUI ou une
implémentation opaque n'est pas un contrat de rendu suffisant.

## 13.3 Manipulation

| ID | Exigence |
|---|---|
| `STK-014` | Les règles communes de sélection, déplacement, rotation, ordre, duplication, suppression et annulation de `ELM-001` à `ELM-014` DOIVENT s’appliquer. |
| `STK-015` | Le redimensionnement DOIT conserver les proportions et aucune dimension NE DOIT descendre sous `0,05` de la plus petite dimension de page. |
| `STK-016` | La barre sticker DOIT proposer Remplacer, Opacité, Retourner horizontalement, puis les commandes communes de `ELM-008`. L'opacité est comprise entre `0,1` et `1`. |
| `STK-021` | L'application DOIT garantir la fluidité jusqu'à vingt stickers par page et produire un avertissement non bloquant au-delà. |
| `STK-022` | Les icônes de la barre DOIVENT utiliser des symboles natifs avec les libellés accessibles exacts de `STK-016`. |
| `STK-023` | Un nouveau sticker DOIT utiliser une rotation nulle, une opacité de `1` et `flippedHorizontally = false`; sa largeur et sa hauteur respectent exactement le rapport intrinsèque validé et la taille de `STK-005`. |
| `STK-024` | Le payload décodé, orienté et converti en sRGB DOIT être ajusté sans recadrage ni déformation aux limites non tournées du sticker, puis retourné, tourné et composé en source-over. Pour chaque pixel, `alphaSortie = alphaPayload × StickerElement.opacity`; les composantes sRGB sont prémultipliées par cet alpha pour la composition. Tout pixel hors de la page est rogné par `CAN-005`. |

---

# 14. Mode lecture

| ID | Exigence |
|---|---|
| `RED-001` | Le mode lecture DOIT être strictement non modifiable. |
| `RED-002` | Il DOIT masquer les cadres vides, boutons d’ajout, poubelles, poignées, guides et contours de sélection. |
| `RED-003` | Il DOIT conserver les boutons de navigation. |
| `RED-004` | Une pression simple sur une zone neutre DOIT afficher ou masquer les contrôles. |
| `RED-005` | Une action explicite DOIT permettre de revenir à l’éditeur. |
| `RED-006` | La page courante DOIT être conservée lors du passage entre édition et lecture. |
| `RED-007` | Il DOIT rendre les photos, textes, stickers, formes, contours et cadres décoratifs avec le moteur partagé de `CAN-008`. |
| `RED-008` | Aucun élément NE DOIT être sélectionnable, déplaçable ou modifiable en lecture. |
| `RED-009` | Le balayage horizontal de navigation DOIT rester prioritaire lorsque le geste est principalement horizontal. |
| `RED-010` | Une seule page DOIT être visible, y compris sur un iPad en plein écran. |

---

# 15. Diaporama

## 15.1 Paramètres

| ID | Exigence |
|---|---|
| `SLD-001` | Le lancement DOIT ouvrir une feuille de paramètres. |
| `SLD-002` | L’utilisateur DOIT pouvoir choisir une durée comprise entre 1 et 60 secondes par écran. |
| `SLD-003` | La valeur par défaut DOIT être de 5 secondes. |
| `SLD-004` | L’utilisateur DOIT pouvoir activer ou désactiver la boucle. |
| `SLD-005` | La boucle DOIT être désactivée par défaut. |
| `SLD-006` | Le diaporama DOIT toujours afficher une seule page par écran. |
| `SLD-020` | La durée et la préférence de boucle DOIVENT être des réglages globaux à l’application et DOIVENT être proposées comme valeurs initiales à chaque lancement. |

## 15.2 Exécution

| ID | Exigence |
|---|---|
| `SLD-007` | Chaque page DOIT rester visible pendant la durée globale, qu’elle contienne ou non des éléments. |
| `SLD-008` | Le diaporama NE DOIT lancer aucun contenu audio ou animé. |
| `SLD-009` | L’ordre DOIT suivre strictement l’ordre des pages de l’album, une page après l’autre. |
| `SLD-010` | La page courante DOIT être rendue avec le moteur partagé de `CAN-008`. |
| `SLD-011` | La transition DOIT utiliser l’animation de changement de page. |
| `SLD-012` | Une pression DOIT afficher les contrôles. |
| `SLD-013` | Les contrôles DOIVENT proposer Pause, Reprendre, Précédent, Suivant et Quitter. |
| `SLD-014` | Une navigation manuelle DOIT réinitialiser le minuteur de l’écran. |
| `SLD-015` | Le passage en arrière-plan DOIT mettre le diaporama en pause. |
| `SLD-016` | Une interruption système qui masque l’application DOIT mettre le diaporama en pause. |
| `SLD-017` | L’écran DOIT rester allumé pendant un diaporama actif. |
| `SLD-018` | À la fin de l’album le diaporama DOIT s’arrêter sauf si la boucle est activée. |
| `SLD-019` | Lorsque Réduire les animations est actif les transitions DOIVENT utiliser un fondu. |
| `SLD-021` | Une navigation manuelle DOIT afficher immédiatement la page cible puis redémarrer son minuteur complet. |
| `SLD-022` | Une ressource photo ou décorative manquante DOIT afficher son emplacement de secours avec une indication accessible, attendre la durée globale puis continuer. |

---

# 16. Annulation et rétablissement

## 16.1 Portée

La pile Annuler et Rétablir de l’éditeur existe uniquement pendant une session. Une session commence à l’ouverture d’un album en édition et se termine à la fermeture de l’éditeur, au changement d’album ou au passage de l’application en arrière-plan. Elle n’est pas restaurée après sa clôture.

La bibliothèque possède une pile distincte, limitée à la présence de l’utilisateur dans la bibliothèque, pour le renommage et le changement de couverture. La suppression d’un album est récupérable par la corbeille et n’est pas ajoutée à cette pile.

## 16.2 Actions couvertes

| ID | Exigence |
|---|---|
| `UND-001` | L’éditeur DOIT afficher Annuler et Rétablir. |
| `UND-002` | Les boutons DOIVENT être désactivés lorsqu’aucune action correspondante n’existe. |
| `UND-003` | Une nouvelle modification après une annulation DOIT supprimer la branche de rétablissement. |
| `UND-004` | Dans l’éditeur, les actions sur le nom, les pages, fonds, couverture, photos, cadres, textes, stickers, modèles, dé et automatisme DOIVENT être prises en charge, notamment l’import, la réutilisation interalbum et Supprimer de cet album. |
| `UND-005` | Une navigation de page NE DOIT PAS être ajoutée à la pile. |
| `UND-006` | Un changement entre Vue page, Vue globale, prévisualisation et lecture NE DOIT PAS être ajouté à la pile. |
| `UND-007` | Un geste continu DOIT être regroupé en une action. |
| `UND-008` | Une séquence de saisie regroupée selon `TBX-022` DOIT être une action unique au niveau de l’album. |
| `UND-009` | Pendant la saisie, les commandes d’annulation standard du champ DOIVENT rester disponibles sans dupliquer une action dans la pile de l’album. |
| `UND-010` | La pile DOIT utiliser des commandes métier réversibles et non des références directes vers des vues. La commande Supprimer de cet album DOIT conserver de façon autonome l’indice dans `photoAssetIDs`, les `PhotoAssetMetadata` et le `contentHash` nécessaires à sa restauration, sans dépendre d’un album source. |
| `UND-011` | Le renommage et le changement de couverture depuis la bibliothèque DOIVENT être pris en charge par sa pile distincte. |
| `UND-012` | La clôture d’une session DOIT vider ses piles Annuler et Rétablir après réussite de la persistance. Les références de rétention portées par leurs commandes ne sont libérées qu’après ce vidage durable ; une purge ultérieure suit `LOC-008` et `LOC-025`. |

## 16.3 Sauvegarde explicite

| ID | Exigence |
|---|---|
| `SAV-001` | Le bouton Sauvegarder DOIT valider la valeur courante d’un geste continu comme une commande unique, valider la saisie active, consolider le journal et demander un flush durable. Il NE DOIT PAS annuler silencieusement une modification en cours. |
| `SAV-002` | Sauvegarder NE DOIT PAS être l’unique mécanisme de persistance et NE réduit pas l’exigence `APP-005`. |
| `SAV-003` | Une réussite DOIT afficher Enregistré avec l’heure ; une erreur DOIT afficher Échec de sauvegarde, conserver le journal récupérable et proposer Réessayer. |
| `SAV-004` | Fermer l’éditeur pendant un échec durable DOIT avertir l’utilisateur sans supprimer ni remplacer le dernier snapshot valide. |

## 16.4 Presse-papiers

| ID | Exigence |
|---|---|
| `CLP-001` | Copier DOIT sérialiser le type, le style, la géométrie et la référence d’asset de l’élément sélectionné dans un format privé versionné. Pour une photo, le payload DOIT aussi retenir ses métadonnées logiques et son `contentHash` afin de protéger le binaire tant que le presse-papiers reste valide. |
| `CLP-002` | Couper DOIT effectuer Copier puis Supprimer comme une seule commande atomique annulable. |
| `CLP-003` | Coller DOIT créer un nouvel identifiant sur la page active et appliquer le placement inter- ou intrapage de `ELM-009` ; une photo copiée référence le même asset immuable mais possède son propre cadrage. Si cet `assetID` a entre-temps été retiré de la photothèque de l’album courant par `PHO-010`, Coller DOIT d’abord restaurer atomiquement ce même asset et ses métadonnées à la fin de `photoAssetIDs`, puis créer l’occurrence dans la même commande. |
| `CLP-004` | Coller DOIT être désactivé sans contenu compatible et NE DOIT interpréter aucune donnée externe comme élément de page sans validation. |
| `CLP-005` | Le collage de texte externe dans une zone de texte suit uniquement `TBX-007` et NE crée pas un nouvel élément automatiquement. |

---

# 17. Historique persistant — version 1.1

| ID | Exigence |
|---|---|
| `HIS-001` | Chaque album DOIT posséder un historique persistant. |
| `HIS-002` | Une révision DOIT être créée à la clôture d’une session d’édition lorsque le contenu a changé. |
| `HIS-003` | Une révision DOIT être créée avant toute restauration. |
| `HIS-004` | Aucune révision ne doit être créée si l’état est identique à la dernière révision. |
| `HIS-005` | Les cinquante révisions les plus récentes DOIVENT être conservées. |
| `HIS-006` | Lors de la création d’une cinquante-et-unième révision la plus ancienne DOIT être supprimée après validation de la nouvelle. |
| `HIS-007` | Les photos et ressources intégrées identiques NE DOIVENT PAS être recopiées dans chaque révision. |
| `HIS-008` | L’historique DOIT afficher la date, l’heure, le motif et une miniature. |
| `HIS-009` | L’utilisateur DOIT pouvoir prévisualiser une révision sans modifier l’album. |
| `HIS-010` | Restaurer DOIT demander confirmation. |
| `HIS-011` | La restauration DOIT créer une révision de l’état courant avant de charger l’état choisi. |
| `HIS-012` | Une restauration NE DOIT PAS supprimer les révisions existantes. |
| `HIS-013` | Les révisions DOIVENT être synchronisées par CloudKit. |
| `HIS-014` | Les révisions NE DOIVENT PAS être incluses dans les packages exportés par les versions 1.0 à 1.2. |
| `HIS-015` | Une révision initiale DOIT être créée lors de la création de l’album. |
| `HIS-016` | Une révision DOIT être créée après un renommage ou un changement de couverture validé depuis la bibliothèque. |
| `HIS-017` | La limite de cinquante révisions DOIT s’appliquer séparément à chaque album. |
| `HIS-018` | Les révisions NE DOIVENT PAS pouvoir être épinglées ou exclues de la purge dans les versions 1.1 et 1.2. |
| `HIS-019` | L’ordre de purge DOIT être déterministe entre appareils à partir d’un ordre de révision synchronisé ; la date locale NE DOIT PAS être l’unique clé de tri. |
| `HIS-020` | Une révision distante validée DOIT être reçue avant qu’une purge locale ne décide quelles cinquante révisions conserver. |
| `HIS-022` | Lors de la migration vers la version 1.1, un album sans historique DOIT recevoir une révision initiale correspondant à son état migré. |

`HIS-021` — Une révision DOIT correspondre à un instantané logique. Elle
DOIT conserver, pour chaque `assetID` historique, son appartenance ordonnée et
les `PhotoAssetMetadata` nécessaires à une restauration autonome. Les fichiers
binaires DOIVENT être référencés par leur `contentHash` afin de permettre la
déduplication et restent protégés par `LOC-008` tant que la révision existe.

---

# 18. Stockage local

## 18.1 Principes

| ID | Exigence |
|---|---|
| `LOC-001` | L’application DOIT fonctionner hors ligne pour tous les albums déjà téléchargés. |
| `LOC-002` | Les métadonnées DOIVENT être stockées dans une base locale versionnée. |
| `LOC-003` | Les fichiers binaires DOIVENT être stockés dans Application Support et non dans le dossier temporaire. |
| `LOC-004` | Les écritures DOIVENT être atomiques. |
| `LOC-005` | Une version valide ne doit être remplacée qu’après validation complète de la nouvelle version. |
| `LOC-006` | Un manque d’espace DOIT être détecté et signalé sans corrompre l’album. |
| `LOC-007` | Les photos et ressources binaires DOIVENT être identifiées par une empreinte SHA-256 afin d’éviter les copies inutiles. |
| `LOC-008` | Un fichier immuable identifié par `contentHash` NE DOIT être purgé tant qu’une métadonnée logique active ou récupérable, un album actif ou en corbeille, une révision, une branche de conflit, une commande validée du journal, une pile Annuler/Rétablir, un presse-papiers valide, une opération de synchronisation en attente, une exportation en cours ou un staging validé le réfère. La vérification transactionnelle DOIT porter sur toutes les références réelles à l’empreinte, et non sur un seul `assetID` ou compteur. |
| `LOC-009` | Les miniatures et images d’aperçu peuvent être régénérées et ne font pas partie des données critiques. |
| `LOC-010` | À partir de la première évolution d’un format publié sous la génération 3.0, toute migration de schéma DOIT être testée avec les données de chaque version publique antérieure concernée de cette même génération. Les stores et snapshots du prototype 2.1 sont exclus et NE DOIVENT PAS être présentés à ce mécanisme. |
| `LOC-011` | Une commande métier validée DOIT être ajoutée durablement au journal local avant d’être considérée comme réussie par l’interface. |
| `LOC-012` | La validation atomique d’un nouveau fichier d’asset DOIT suivre le protocole de staging décrit en section 18.3. La création d’un nouvel asset logique réutilisant un binaire global déjà présent et revérifié suit la transaction sans copie définie dans cette même section. |
| `LOC-013` | Au lancement, l’application DOIT rejouer les commandes validées non consolidées et nettoyer ou reprendre les opérations de staging selon leur état. |
| `LOC-014` | Une interruption à chaque étape d’une importation, restauration, exportation ou purge NE DOIT PAS rendre la dernière version validée illisible. |
| `LOC-015` | Le dépôt d’assets DOIT être global à l’application et adressé par contenu ; plusieurs identifiants métier PEUVENT référencer la même empreinte. |
| `LOC-016` | Une modification d’appartenance, de métadonnées, de références, d’index et de compteurs associés DOIT être journalisée et validée dans une seule transaction de base. Cette règle s’applique notamment à la réutilisation et à Supprimer de cet album. |
| `LOC-017` | L’application DOIT garantir l’enveloppe de cinq gigaoctets par album et avertir au-delà, sans bloquer si l’opération reste sûre et que l’espace est suffisant. Pour ce quota, chaque `contentHash` distinct référencé par l’état courant, ses révisions ou branches conservées et ses ressources de secours est compté une fois dans chaque album concerné, même si le dépôt global ne stocke physiquement ses octets qu’une fois. |
| `LOC-018` | L’application DOIT garantir par page vingt occurrences photo, vingt zones de texte et vingt stickers, puis avertir sans bloquer au-delà si l’opération reste sûre. |
| `LOC-019` | Avant une importation ou un transcodage, l’espace disponible pour les données importantes DOIT être supérieur à deux fois la taille source connue, augmentée de 512 Mo de réserve. |
| `LOC-020` | Si la taille source n’est pas connue, l’opération DOIT surveiller l’espace pendant la copie et s’interrompre proprement avant épuisement. |

## 18.2 Arborescence recommandée

```text
Application Support/
└── AlbumPhotoCanvasV1/
    ├── Database/
    │   └── App.sqlite
    ├── Assets/
    │   ├── sha256-abcd...
    │   └── sha256-efgh...
    ├── Thumbnails/
    ├── Journal/
    ├── Staging/
    ├── Revisions/
    │   └── <album-id>/
    ├── Trash/
    ├── Exports/
    └── TemporaryImports/
```

`LOC-021` — Les dossiers d’export temporaire DOIVENT être nettoyés après partage, après annulation, et au prochain lancement s’ils datent de plus de vingt-quatre heures.

## 18.3 Protocole transactionnel

Pour toute commande ne créant pas d’asset :

1. valider les invariants du domaine
2. écrire la commande et son identifiant idempotent dans le journal local
3. valider la transaction
4. publier le nouvel état dans l’interface
5. consolider les commandes rapprochées dans l’instantané au plus tard après 500 ms d’inactivité

Pour toute opération créant un asset :

1. copier ou télécharger la ressource dans `Staging/`
2. vérifier la décodabilité statique, le type réel, les dimensions et la taille
3. calculer l’empreinte SHA-256
4. produire et valider les dérivés nécessaires
5. déplacer atomiquement les fichiers immuables vers `Assets/` sur le même volume
6. créer les métadonnées et références dans une transaction de base unique
7. marquer l’opération de staging comme validée
8. nettoyer le staging

Pour une réutilisation interalbum dont le fichier immuable est déjà présent,
l’application DOIT revérifier empreinte, type et longueur, puis créer le nouvel
`assetID`, ses métadonnées et son appartenance cible dans une seule transaction
journalisée, sans staging ni copie binaire. Si les octets ne sont pas
disponibles ou ne passent pas ces contrôles, aucune appartenance n’est créée et
l’interface propose Télécharger ou Réessayer.

| ID | Exigence |
|---|---|
| `LOC-022` | Une opération destructive DOIT être journalisée et validée immédiatement. Supprimer de cet album valide uniquement le retrait logique ; elle rend le binaire éligible à un futur nettoyage et NE DOIT PAS le purger dans la même transaction. |
| `LOC-023` | L’interface NE DOIT PAS afficher comme définitive une importation dont la transaction de références n’est pas validée. |
| `LOC-024` | Un asset déplacé mais non référencé après interruption DOIT être conservé comme orphelin récupérable jusqu’au prochain cycle de nettoyage. |
| `LOC-025` | Le nettoyage d’un orphelin ou d’un binaire devenu éligible DOIT revérifier dans une transaction toutes les références de `LOC-008` à son `contentHash` immédiatement avant suppression. Toute nouvelle référence annule la purge. |
| `LOC-026` | Le passage en arrière-plan DOIT demander la consolidation immédiate du journal sans supposer qu’un temps d’exécution supplémentaire sera accordé. |
| `LOC-027` | Les caches, miniatures et aperçus régénérables PEUVENT être supprimés automatiquement sous pression disque, du plus ancien au plus récent. |
| `LOC-028` | Les originaux, textes, révisions et assets utilisés NE DOIVENT JAMAIS être supprimés automatiquement pour libérer de l’espace. |
| `LOC-029` | Toute donnée locale de la génération 3.0 DOIT être créée exclusivement sous `Application Support/AlbumPhotoCanvasV1/`. Aucun chemin du prototype 2.1 NE DOIT être réutilisé comme racine, base, journal, dépôt d’assets ou staging. |
| `LOC-030` | Si des fichiers du prototype 2.1 existent encore, l’application 3.0 DOIT les laisser intacts et les ignorer : elle NE DOIT ni les ouvrir ou décoder, ni les déplacer, copier, renommer, importer ou supprimer. |
| `LOC-031` | Au premier lancement 3.0, la nouvelle racine et sa base vide DOIVENT être créées atomiquement sans inspecter le contenu de l’ancienne racine. Un échec conserve l’ancien contenu intact et n’autorise aucune initialisation partielle présentée comme valide. |

---

# 19. Synchronisation CloudKit — version 1.1

## 19.1 Architecture

La synchronisation utilise la base privée CloudKit du compte iCloud de l’utilisateur.

`SYN-001` — L’implémentation DOIT être locale d’abord :

1. la modification est enregistrée localement
2. elle est placée dans une file de synchronisation
3. l’interface reste utilisable
4. la synchronisation s’exécute lorsque le réseau et le compte iCloud sont disponibles

`SYN-002` — L’application NE DOIT PAS utiliser la synchronisation automatique SwiftData comme unique mécanisme.

`SYN-003` — La base privée DOIT utiliser une zone personnalisée `AlbumZone` afin de récupérer les changements par jeton et de gérer les suppressions.

### 19.1.1 Granularité des records

| Record | Rôle |
|---|---|
| `AlbumRecord` | Nom, couverture, dates, ordre des pages, `photoAssetIDs` ordonnés et état de corbeille |
| `PageRecord` | Contenu complet d’une page et empreinte de sa base commune |
| `AssetRecord` | Appartenance et `PhotoAssetMetadata` d’un asset logique, identifié par `assetID`, rattaché à un album et référençant un `contentHash` |
| `BlobRecord` | `CKAsset` binaire immuable unique dans le compte privé, identifié par `contentHash` et partageable par plusieurs `AssetRecord` |
| `RevisionRecord` | Métadonnées d’une révision et instantané logique stocké comme `CKAsset` au-delà du seuil `SYN-005` |
| `ConflictHeadRecord` | Branche concurrente non résolue d’une page ou des métadonnées d’un album |
| `DeletionTombstoneRecord` | Suppression logique et date d’expiration |

| ID | Exigence |
|---|---|
| `SYN-004` | Une page DOIT être synchronisée indépendamment des autres pages. |
| `SYN-005` | Un enregistrement CloudKit hors `CKAsset` NE DOIT PAS approcher 1 Mo ; à partir de 750 Ko sérialisés, le contenu DOIT être placé dans un `CKAsset` ou découpé. |
| `SYN-006` | Une opération de modification DOIT contenir au plus deux cents records et au plus 1 Mo de champs hors `CKAsset`. |
| `SYN-007` | Une erreur de limite DOIT provoquer un découpage déterministe de l’opération et une nouvelle tentative idempotente. |
| `SYN-008` | Les change tags, identifiants de records, jetons de zone et bases communes DOIVENT être conservés dans la base locale. |
| `SYN-009` | Chaque commande envoyée DOIT posséder un identifiant idempotent pour éviter une double application après reprise. |
| `SYN-010` | Une suppression DOIT être synchronisée par tombstone et NE DOIT PAS dépendre uniquement de la disparition d’un record. Supprimer de cet album produit un tombstone visant le couple album/`assetID`, jamais le `contentHash` ni le `BlobRecord`, et le conserve invisiblement pendant quatre-vingt-dix jours après acceptation serveur. Annuler cette suppression retire le tombstone encore en attente ou publie une restauration explicite plus récente du même `AssetRecord`. Avant application ou publication, le moteur recompte les occurrences dans l’état courant et les branches reçues ; une occurrence concurrente conserve ou restaure l’`AssetRecord`, empêche toute purge et crée un conflit récupérable plutôt qu’une référence pendante. Un `BlobRecord` n’est supprimable qu’après absence de tout `AssetRecord`, révision, branche, tombstone de rétention ou référence de `LOC-008`. |
| `SYN-021` | Le payload canonique de la base commune DOIT être conservé localement tant qu’une modification ou branche qui en descend n’est pas résolue. Une empreinte seule NE SUFFIT PAS pour effectuer une fusion à trois voies. |
| `SYN-022` | Les métadonnées d’album DOIVENT être fusionnées champ par champ à trois voies ; deux champs différents PEUVENT fusionner automatiquement, tandis que deux valeurs différentes du même champ créent un conflit. |
| `SYN-023` | Deux `PageRecord` distincts modifiés depuis la même base DOIVENT fusionner automatiquement. Deux contenus différents du même `PageRecord` DOIVENT créer des branches. |
| `SYN-024` | Un changement de compte DOIT être détecté à partir de l’identifiant utilisateur opaque fourni par CloudKit. Cet identifiant NE DOIT PAS être synchronisé, exporté ni journalisé. |
| `SYN-025` | Les métadonnées Cloud de l’ancien compte DOIVENT rester associées à ce compte localement et NE DOIVENT PAS être réutilisées avec le nouveau compte. Une réutilisation interalbum copie uniquement les métadonnées métier et résout les octets par empreinte ; elle NE DOIT copier ni nom de record, ni change tag, ni base de synchronisation et DOIT résoudre ou téléverser le `BlobRecord` dans le compte courant. |

## 19.2 Données synchronisées

| ID | Exigence |
|---|---|
| `ICL-001` | Les albums, leur `photoAssetIDs` ordonné, pages, éléments, textes, assets photo logiques, blobs photo, fonds, styles de cadres et révisions DOIVENT être synchronisés. Les réglages globaux du diaporama NE DOIVENT PAS l’être dans les versions 1.1 et 1.2. |
| `ICL-002` | Les catalogues intégrés NE DOIVENT PAS créer de bibliothèque utilisateur synchronisée ; les identifiants et copies de secours utilisés restent dans les pages et packages. |
| `ICL-003` | Les jetons Google et les caches temporaires NE DOIVENT PAS être synchronisés. |
| `ICL-004` | Tous les originaux et dérivés binaires de photos ainsi que les copies de secours nécessaires DOIVENT utiliser `CKAsset`. Un seul `BlobRecord` et un seul `CKAsset` sont créés par `contentHash` dans le compte ; plusieurs assets logiques, notamment issus de `PHO-017`, le référencent sans second téléversement. |
| `ICL-005` | Les appareils DOIVENT télécharger `AlbumRecord` et `AssetRecord` avant les `BlobRecord` afin d’afficher rapidement la bibliothèque et ses appartenances ordonnées. |
| `ICL-006` | Une photo non encore téléchargée DOIT afficher un état clair et une progression. |
| `ICL-007` | Une erreur CloudKit NE DOIT PAS bloquer l’édition locale. |
| `ICL-008` | Un nouvel appareil DOIT télécharger automatiquement les métadonnées logiques et couvertures, puis chaque `BlobRecord` distinct à la demande. |
| `ICL-009` | Une commande Télécharger l’album DOIT télécharger et vérifier tous les `BlobRecord` distincts nécessaires à un usage hors ligne, y compris ceux d’assets réutilisés. |
| `ICL-010` | Un album NE DOIT être marqué Disponible hors ligne qu’après vérification de tous ses assets logiques et blobs distincts. |

## 19.3 Réglage

| ID | Exigence |
|---|---|
| `SYN-011` | Un réglage global Synchronisation iCloud DOIT être proposé et activé par défaut lorsqu’un compte iCloud est disponible. |
| `SYN-012` | Une désactivation DOIT arrêter les nouveaux échanges sans supprimer les données locales ou distantes. |
| `SYN-013` | Une réactivation DOIT comparer les bases communes et fusionner automatiquement uniquement les changements non concurrents. |
| `SYN-014` | Lors d’un changement de compte iCloud, les albums locaux DOIVENT être conservés localement et NE DOIVENT PAS être publiés automatiquement dans le nouveau compte. |
| `SYN-015` | L’utilisateur DOIT choisir explicitement quels albums locaux publier vers un nouveau compte. |
| `SYN-016` | Une action distincte Télécharger l’album DOIT être disponible depuis les détails de synchronisation. |
| `SYN-017` | La suppression synchronisée d’un album DOIT le placer dans la corbeille de tous les appareils pendant trente jours. |
| `SYN-018` | Après les trente jours de récupération utilisateur, le tombstone Cloud DOIT rester invisible mais être conservé pendant soixante jours supplémentaires afin d’empêcher la résurrection par un appareil longtemps hors ligne. |

## 19.4 Conflits

Un conflit existe lorsque plusieurs branches modifient la même page ou le même champ de métadonnées depuis une base commune. Des modifications portant sur des pages ou champs distincts sont fusionnées automatiquement.

| ID | Exigence |
|---|---|
| `CNF-001` | Un conflit NE DOIT PAS être résolu par un écrasement silencieux. |
| `CNF-002` | L’application DOIT conserver toutes les branches concurrentes, quel que soit le nombre d’appareils concernés. |
| `CNF-003` | Une bannière DOIT signaler le conflit. |
| `CNF-004` | L’écran de résolution DOIT afficher pour chaque branche sa date, son appareil, sa page concernée et un aperçu. |
| `CNF-005` | L’utilisateur DOIT pouvoir choisir une branche pour chaque page ou métadonnée en conflit, ou choisir Conserver les albums complets. |
| `CNF-006` | La branche retenue DOIT être publiée et toutes les branches écartées DOIVENT être archivées dans l’historique. |
| `CNF-007` | Si une branche distante est retenue, l’ancien état local DOIT être archivé avant remplacement. |
| `CNF-008` | Conserver les albums complets DOIT créer un album par branche retenue avec de nouveaux identifiants d’album, de pages, d’éléments et d’assets logiques, et des noms suffixés par la date et l’appareil. Les `contentHash` et `BlobRecord` immuables restent dédupliqués. |
| `CNF-009` | Une fermeture de l’écran sans choix DOIT conserver toutes les branches et maintenir le conflit ouvert. |
| `CNF-010` | Les fichiers identiques entre les versions DOIVENT être dédupliqués. |
| `CNF-011` | Pendant un conflit, l’utilisateur DOIT pouvoir continuer à modifier la branche locale. |
| `CNF-012` | Les publications Cloud de la page ou métadonnée en conflit DOIVENT être suspendues jusqu’à résolution ; les autres pages PEUVENT continuer à se synchroniser. |
| `CNF-013` | La résolution DOIT être une commande idempotente et atomique du point de vue du modèle local. |

## 19.5 État de synchronisation

`SYN-019` — Chaque album DOIT exposer un état parmi :

- Local uniquement
- En attente
- Synchronisation en cours
- À jour
- Téléchargement partiel
- Conflit
- Erreur récupérable

`SYN-020` — L’interface DOIT permettre d’ouvrir les détails et de relancer une erreur récupérable.

---

# 20. Export et import d’un album modifiable

## 20.1 Format

La version 1.0 utilise un document package natif Apple avec l’extension stable `.photoalbum` et un `UTType` propre à l’application. Le package est manipulé avec `FileWrapper` et `ReferenceFileDocument` ou une API publique équivalente.

`PKG-001` — Le nom du type DOIT être construit à partir de `PRODUCT_BUNDLE_IDENTIFIER` sous la forme :

```text
<bundle-identifier>.photoalbum-document
```

`PKG-002` — Le type exporté DOIT être déclaré comme document package et le rôle de l’application DOIT être `Editor`.

`PKG-003` — Le format DOIT être publiquement documenté dans le dépôt, indépendamment du code Swift, avec son schéma JSON, ses invariants, des exemples, le manifeste de modèles de `TPL-019`, le registre et les contrats de rendu de `CAT-001` à `CAT-009`, ainsi que la règle selon laquelle seules les références de ces manifestes sont acceptées.

`PKG-004` — Un package NE DOIT PAS être présenté comme authentifié : ses empreintes garantissent la détection d’une modification ou corruption, pas l’identité de son auteur.

## 20.2 Contenu du package

```text
MonAlbum.photoalbum/
├── manifest.json
├── photos/
├── catalog-resources/
├── previews/
│   └── cover.jpg
└── checksums.json
```

### 20.2.1 Manifeste

`PKG-005` — `manifest.json` DOIT être un objet JSON UTF-8 contenant au minimum :

```text
formatVersion
minimumReaderVersion
formatGeneration
generator { bundleIdentifier, appVersion, build }
exportedAt
album
assets[]
catalogResources[]
coverPreviewPath
```

`PKG-021` — Chaque descripteur de photo DOIT contenir son identifiant logique
local au package, son empreinte SHA-256, son type MIME déclaré, sa longueur en
octets, son chemin relatif, `pixelWidth`, `pixelHeight`, `originalFilename`,
`colorSpaceName`, `isHDR`, `source`, `capturedAt` et `importedAt`. Les clés
`originalFilename`, `colorSpaceName` et `capturedAt` sont obligatoires mais
PEUVENT contenir `null`; `source` et `importedAt` sont obligatoires. Aucun
identifiant d’album ou d’asset source extérieur au package n’est autorisé. Les
dimensions et dates suivent `DAT-021` et `DAT-043` et restent présentes même
si le fichier manque dans un import dégradé. Pour un fichier présent, le
décodage DOIT confirmer les dimensions orientées avant l'import.

`PKG-006` — `checksums.json` DOIT contenir pour chaque fichier, à l’exception de lui-même, le chemin relatif normalisé, la longueur en octets et l’empreinte SHA-256 calculée sur les octets exacts.

`PKG-007` — Dans un package complet, chaque fichier physique présent, hormis
`checksums.json`, DOIT être déclaré exactement une fois dans ce dernier et
chaque entrée déclarée DOIT exister exactement une fois. Plusieurs
descripteurs logiques de photo PEUVENT référencer le même chemin dans
`photos/` si et seulement si empreinte, longueur et type concordent ; les
octets d’un même `contentHash` ne sont alors embarqués qu’une fois.

`PKG-017` — Le premier format publié DOIT utiliser `formatGeneration = "album-photo-canvas-v1"`, `formatVersion = 1` et `minimumReaderVersion = 1`. Une autre génération désigne un autre format et NE DOIT PAS être passée aux décodeurs de cette spécification.

`PKG-018` — Le champ `album` DOIT utiliser la représentation sérialisée de
`AlbumSnapshot` avec des identifiants locaux au package et sans métadonnées de
synchronisation. Toutes les références de `photoAssetIDs` et
`PhotoPlacement.assetID` DOIVENT résoudre un descripteur du package, sans lien
vivant vers une bibliothèque ou un album externe.

`PKG-019` — Le schéma JSON normatif DOIT être livré dans `docs/photoalbum-format-v1.schema.json` avant la sortie du lot 0.

`PKG-020` — Les fichiers du package natif NE DOIVENT PAS appliquer de compression applicative supplémentaire dans la version de format 1.

### 20.2.2 Contenu autonome

`PKG-008` — Le package DOIT inclure :

- le nom et les métadonnées de l’album
- l’ordre et le contenu des pages
- le fond propre à chaque page
- les cadres photo, zones de texte et stickers avec leur géométrie et ordre
- les cadrages, formes, contours et cadres décoratifs
- l’état de modèle et de mise en page automatique de chaque page
- tous les originaux appartenant à `photoAssetIDs`, y compris ceux qui ne sont placés dans aucun cadre
- les copies de secours de toutes les ressources `asset` intégrées utilisées et les références sans fichier des ressources `nativeVector`
- la couverture
- la version du schéma
- les empreintes de contrôle

Un original ajouté depuis un autre album est inclus sous son identité logique
cible et avec ses octets, même si le dépôt local global les partage avec
l’album source. Le package DOIT rester autonome après suppression de cet album
source.

`PKG-016` — Chaque fond, sticker ou cadre décoratif `asset` utilisé DOIT posséder une copie de secours dans `catalog-resources/`, même s'il existe dans le catalogue installé. Son descripteur DOIT citer le couple enregistré et ses octets, type réel, longueur et empreinte DOIVENT correspondre à `CAT-001` et `CAT-002`. Une forme `nativeVector` cite son couple et son contrat public selon `CAT-009`, mais NE DOIT PAS embarquer de fichier de secours.

`PKG-009` — Le package NE DOIT PAS inclure :

- l’historique
- les jetons Google
- les identifiants de session Google
- les états de synchronisation CloudKit
- les fichiers temporaires

`PKG-010` — Le package NE DOIT PAS être chiffré ni protégé par mot de passe dans les versions 1.0 à 1.2.

`PKG-011` — L’interface d’export DOIT avertir que le document contient une copie des photos originales nécessaires.

## 20.3 Compatibilité

| ID | Exigence |
|---|---|
| `PKG-012` | Toute version de format publiée DOIT rester importable par migration ascendante dans les versions ultérieures de l’application. |
| `PKG-013` | L’application NE DOIT PAS produire un package dans un ancien format. |
| `PKG-014` | `minimumReaderVersion` DOIT empêcher l’import si l’application ne comprend pas les données obligatoires. |
| `PKG-015` | Une version future incompatible DOIT être refusée avec une demande de mise à jour, sans écriture durable. |
| `PKG-022` | L'exporteur DOIT fixer `minimumReaderVersion` à une version qui connaît chaque couple (`catalogID`, `catalogVersion`) et (`templateID`, `templateVersion`) référencé. Il NE DOIT PAS produire un package qu'un lecteur déclaré compatible interpréterait avec une ressource, un modèle ou un slot différent ou inconnu. |

## 20.4 Export

| ID | Exigence |
|---|---|
| `EXP-001` | Une commande Exporter DOIT proposer Album modifiable et PDF. |
| `EXP-002` | La préparation du package DOIT afficher une progression. |
| `EXP-003` | L’utilisateur DOIT pouvoir annuler avant l’ouverture de la feuille de partage. |
| `EXP-004` | Le résultat DOIT être partageable avec la feuille de partage iOS. |
| `EXP-005` | Le package DOIT être autonome et ouvrable hors ligne. |
| `EXP-006` | L’export NE DOIT PAS modifier l’album source. |
| `EXP-007` | Une erreur DOIT supprimer les fichiers temporaires incomplets. |
| `EXP-008` | Les empreintes DOIVENT être calculées avant partage. |

## 20.5 Import

| ID | Exigence |
|---|---|
| `IMP-001` | L’application DOIT accepter le type de document depuis Fichiers, AirDrop et la feuille de partage. |
| `IMP-002` | Le manifeste, la structure et les empreintes DOIVENT être validés avant création d’un album local. |
| `IMP-003` | Les chemins DOIVENT utiliser `/`, être relatifs, normalisés Unicode NFC et limités à l’intérieur du package. Les composantes vides, `.` et `..` sont interdites. |
| `IMP-004` | Un manifeste invalide, une empreinte incorrecte sur un fichier présent, un fichier présent non décodable ou un type réel interdit DOIT faire rejeter le package sans créer d’album. L’absence isolée d’une photo référencée suit `IMP-014`. |
| `IMP-005` | Toutes les versions publiques antérieures de la même `formatGeneration` DOIVENT être migrées. Cette règle exclut les stores, snapshots et éventuels artefacts du prototype 2.1, qui ne constituent pas un format public importable. |
| `IMP-006` | Une version future inconnue DOIT produire un message indiquant qu’une mise à jour de l’application est nécessaire. |
| `IMP-007` | Tout import DOIT créer une copie avec un nouvel identifiant d’album et de nouveaux identifiants de pages, d’éléments et d’assets logiques, puis remapper toutes les références. Chaque photo importée conserve son `contentHash`, fixe `source = .importedPackage` et référence le blob global dédupliqué par empreinte ; aucun lien vers l’album exportateur ou un album local homonyme n’est créé. |
| `IMP-008` | L’album importé DOIT être entièrement modifiable. |
| `IMP-009` | L’album importé DOIT rester lisible sans connexion et sans compte Google. |
| `IMP-010` | Une ressource `asset` enregistrée mais absente de la version installée DOIT utiliser sa copie de secours uniquement si `CAT-002` et tous les contrôles du package réussissent. Une ressource `nativeVector` exige toujours que le lecteur connaisse son couple et son `rendererID`; l'absence de ce moteur fait rejeter le package et aucun fichier ne peut le remplacer. |
| `IMP-011` | Les liens symboliques, liens matériels, alias, fichiers spéciaux et wrappers imbriqués non déclarés DOIVENT être rejetés. |
| `IMP-012` | Un package DOIT contenir au plus dix mille entrées, une profondeur de huit composants et des fichiers JSON de dix mégaoctets maximum chacun. |
| `IMP-013` | Aucune limite arbitraire de taille totale du package NE DOIT être imposée ; l’import DOIT toutefois satisfaire les contrôles d’espace de `LOC-019` et `LOC-020`. |
| `IMP-014` | Si tous les contrôles applicables aux fichiers présents réussissent et que la seule anomalie est l’absence d’une ou plusieurs photos référencées, l’application DOIT présenter une prévisualisation dégradée et demander si l’utilisateur souhaite importer malgré ces photos manquantes. |
| `IMP-015` | Un import dégradé accepté DOIT conserver les cadres concernés avec un contenu explicite Photo manquante et les métadonnées de diagnostic. Les dimensions orientées et dates validées du descripteur restent disponibles pour `AUT-010` et `AUT-016`; la photo reste non rendable, porte l'alerte distincte Photo manquante et n'expose aucun des trois états `QLT-001` jusqu'à restauration du fichier. |
| `IMP-016` | Un import dégradé NE DOIT PAS être qualifié de package valide complet dans les journaux ou l’interface. |
| `IMP-017` | L’import NE DOIT PAS proposer de remplacer ou fusionner un album existant dans les versions 1.0 à 1.2. |
| `IMP-018` | Le type MIME déclaré DOIT être comparé au type détecté à partir du contenu ; le type détecté DOIT déterminer le décodeur autorisé. |
| `IMP-019` | L’inspection structurelle et des chemins DOIT être effectuée en lecture seule avant toute copie dans le staging de l’application. |
| `IMP-020` | Deux chemins égaux après normalisation NFC et comparaison Unicode insensible à la casse DOIVENT être considérés comme un doublon interdit. |
| `IMP-021` | Un composant de chemin DOIT être limité à 255 octets UTF-8 et un chemin relatif complet à 1024 octets. |
| `IMP-022` | La profondeur d’imbrication d’un document JSON DOIT être limitée à 64 pendant la validation. |
| `IMP-023` | Avant toute écriture durable, chaque référence et descripteur de fond, sticker, forme ou cadre décoratif DOIT être résolu dans le registre `CAT-001`. Pour `asset`, la copie de secours est obligatoire et vérifiée selon `CAT-002`; pour `nativeVector`, aucun fichier n'est autorisé et le couple ainsi que son `rendererID` doivent être pris en charge localement. |
| `IMP-024` | Un identifiant ou une version de catalogue inconnus, une catégorie différente, une empreinte enregistrée différente, une copie de secours non conforme, un couple de modèle inconnu ou un slot absent ou de mauvais type DOIT faire rejeter tout le package. Ce cas NE DOIT PAS être proposé comme import dégradé. |
| `IMP-025` | Un manifeste sans `formatGeneration`, avec une génération différente de `album-photo-canvas-v1`, ou ressemblant à une donnée du prototype 2.1 DOIT être rejeté avant décodage de `album`. Aucun parcours utilisateur NE DOIT proposer de le convertir ou de le migrer. |

---

# 21. Export PDF

## 21.1 Options

`PDF-011` — Le dialogue d’export PDF DOIT proposer :

- une page d’album par feuille
- format A4 ou US Letter
- orientation automatique
- inclure ou non les numéros de page

`PDF-012` — Une feuille DOIT toujours contenir exactement une page d’album.

## 21.2 Rendu

| ID | Exigence |
|---|---|
| `PDF-001` | Le PDF DOIT inclure le fond et tous les éléments visibles de chaque page dans leur ordre de profondeur. |
| `PDF-002` | Une photo DOIT respecter son `nativeScale`, son point focal, son orientation, son masque, son contour, son cadre décoratif et la géométrie de son cadre. Les parties non couvertes du masque restent transparentes et laissent apparaître les éléments inférieurs puis le fond exactement comme dans l’éditeur. |
| `PDF-003` | Une zone de texte DOIT respecter ses runs, paragraphes, alignement, interligne, opacité et rotation sans troncature. |
| `PDF-004` | Un sticker DOIT respecter son asset, ses proportions, son opacité, sa rotation et son ordre. |
| `PDF-005` | Les éléments qui dépassent de la page DOIVENT être rognés exactement comme dans la prévisualisation. |
| `PDF-006` | L’export DOIT refuser une zone de texte débordante selon `TBX-021`. |
| `PDF-007` | Les cadres photo vides NE DOIVENT PAS être rendus et DOIVENT produire un avertissement non bloquant avant export. |
| `PDF-008` | Une ressource intégrée manquante sans copie de secours DOIT bloquer l’export et identifier la page et l’élément. |
| `PDF-009` | La génération DOIT être effectuée hors du thread principal. |
| `PDF-010` | L’utilisateur DOIT pouvoir annuler une génération longue. |
| `PDF-013` | Le PDF DOIT être balisé par page avec un ordre de lecture explicite pour les photos, paragraphes et stickers décoratifs ou informatifs. |
| `PDF-014` | Chaque occurrence photo DOIT posséder un texte alternatif ; en l’absence de description utilisateur, l’application DOIT générer « Photo, page N ». |
| `PDF-015` | Le texte du canevas NE DOIT PAS être réduit automatiquement ; une taille inférieure à l’équivalent de 9 points DOIT produire un avertissement avant export. |
| `PDF-016` | Le format par défaut DOIT être A4 pour les régions utilisant ce standard et US Letter dans les autres régions. |
| `PDF-017` | Le contenu DOIT être centré avec une marge de placement minimale de 12 mm sur la feuille ; l’orientation automatique DOIT choisir celle qui maximise la surface du canevas. Cette marge de feuille n’est pas une marge de sécurité du canevas et NE DOIT PAS être affichée dans l’éditeur. |
| `PDF-018` | Les photos DOIVENT utiliser les originaux et PEUVENT être sous-échantillonnées jusqu’à 300 ppp à leur taille imprimée, sans descendre sous la définition nécessaire. |
| `PDF-019` | Le rendu PDF DOIT utiliser sRGB pour les contenus standards et une conversion avec gestion des couleurs pour les contenus HDR. |
| `PDF-020` | Avant génération, l’export DOIT présenter les occurrences `Acceptable` ou `Insuffisante` selon `QLT-001` à `QLT-006`, avec leur page, sans bloquer la poursuite. |

---

# 22. Modèle de données du domaine

`DAT-001` — Le modèle ci-dessous est normatif sur le sens des données. Les noms exacts PEUVENT être adaptés au code sans modifier leur sémantique.

## 22.1 Album

```swift
struct AlbumSnapshot: Codable, Sendable {
    let modelGeneration: String
    let schemaVersion: Int
    let id: UUID
    var name: String
    var coverSelection: CoverSelection
    var photoAssetIDs: [UUID]
    var pages: [PageSnapshot]
    var createdAt: Date
    var updatedAt: Date
    var trashedAt: Date?
}
```

`DAT-002` — `updatedAt` DOIT changer uniquement lorsqu’un contenu ou réglage propre à l’album change. La lecture, la navigation, un téléchargement, une génération de miniature et une synchronisation sans modification de contenu NE DOIVENT PAS la modifier.

`DAT-003` — L’ordre des pages DOIT être défini par leur ordre dans `AlbumSnapshot.pages`.

`DAT-004` — `trashedAt` DOIT être nul pour un album actif et contenir la date d’entrée en corbeille pour un album supprimé logiquement.

## 22.2 Couverture

```swift
enum CoverSelection: Codable, Sendable {
    case automatic
    case pagePhoto(pageID: UUID, elementID: UUID)
}
```

`DAT-005` — Une couverture manuelle DOIT identifier un cadre photo rempli sur
une page et non uniquement l’asset partagé. La cible est invalide si
`elementID` ne désigne plus un `PhotoFrameElement` rempli de cette page.

## 22.3 Page

```swift
struct PageSnapshot: Codable, Sendable {
    let id: UUID
    var background: BackgroundSelection
    var layout: PageLayoutState
    var elements: [PageElement]
    var accessibilityOrder: [UUID]
}

enum BackgroundSelection: Codable, Sendable {
    case none
    case solid(SRGBAColor)
    case catalog(CatalogResourceReference)
}

struct PageLayoutState: Codable, Sendable {
    var isAutoLayoutEnabled: Bool
    var photoMode: PagePhotoLayoutMode
    var templateID: String?
    var templateVersion: Int?
    var density: AutoLayoutDensity
}

enum PagePhotoLayoutMode: String, Codable {
    case free
    case template
    case automatic
}

enum AutoLayoutDensity: String, Codable {
    case airy
    case balanced
    case dense
}

struct LayoutTemplateDefinition: Codable, Sendable {
    let id: String
    let version: Int
    let isActive: Bool
    let localizedNameKey: String
    let slots: [LayoutSlotDefinition]
}

struct LayoutSlotDefinition: Codable, Sendable, Identifiable {
    let id: String
    let kind: LayoutSlotKind
    let geometry: LayoutSlotGeometry
    let readingOrder: Int
    let defaultPhotoStyle: PhotoFrameStyleDefaults?
    let defaultTextStyle: TextStyleDefaults?
}

struct LayoutSlotGeometry: Codable, Sendable {
    var centerX: Double
    var centerY: Double
    var width: Double
    var height: Double
    var rotationRadians: Double
}

enum LayoutSlotKind: String, Codable {
    case photo
    case text
}

enum PageElement: Codable, Sendable {
    case photo(PhotoFrameElement)
    case text(TextBoxElement)
    case sticker(StickerElement)
}

struct ElementGeometry: Codable, Sendable {
    var centerX: Double
    var centerY: Double
    var width: Double
    var height: Double
    var rotationRadians: Double
    var order: Int64
}
```

`DAT-030` — `elements` DOIT contenir des identifiants uniques. Chaque
identifiant DOIT apparaître exactement une fois dans `accessibilityOrder`.
L'ajout place l'élément à la fin de cet ordre. L'application d'un modèle DOIT
conserver l'ordre relatif de tous les éléments survivants, retirer les seuls
identifiants supprimés et ajouter les nouveaux identifiants à la fin dans
l'ordre de `readingOrder` puis d'identifiant de slot. Elle NE DOIT PAS
recalculer l'ordre d'accessibilité à partir de la position visuelle.

`DAT-034` — Un modèle DOIT contenir au moins un emplacement et des identifiants
de slot uniques. `readingOrder` DOIT être une permutation contiguë commençant
à zéro. Les deux styles par défaut sont mutuellement exclusifs selon `kind`.

`DAT-035` — La géométrie persistée dans `elements` est toujours autoritaire.
L’identifiant et la version du modèle servent à l’interface et à une nouvelle
application explicite ; une mise à jour du catalogue NE DOIT PAS déplacer une
page enregistrée.

`DAT-036` — `photoAssetIDs` DOIT contenir chaque asset logique appartenant à
l’album exactement une fois, dans l’ordre de son admission par import,
réutilisation interalbum ou import de package. Dans l’état courant, un
`assetID` logique appartient à un seul album ; copier ou réutiliser une photo
dans un autre album crée un nouvel `assetID`, même lorsque `contentHash` est
identique. Un asset PEUT n’être référencé par aucun cadre et reste alors
disponible dans le panneau Photos jusqu’à sa suppression explicite.

## 22.4 Photo et cadre

```swift
struct PhotoAssetMetadata: Codable, Sendable {
    let id: UUID
    let contentHash: String
    let mimeType: String
    let originalFilename: String?
    let pixelWidth: Int
    let pixelHeight: Int
    let byteCount: Int64
    let colorSpaceName: String?
    let isHDR: Bool
    let source: PhotoSource
    let importedAt: Date
    let capturedAt: Date?
}

enum PhotoSource: String, Codable {
    case applePhotos
    case files
    case reusedAlbum
    case googlePhotos
    case importedPackage
}

struct PhotoFrameElement: Codable, Sendable, Identifiable {
    let id: UUID
    var geometry: ElementGeometry
    var sourceTemplateSlotID: String?
    var content: PhotoPlacement?
    var mask: PhotoMask
    var border: PhotoBorder
    var decorativeFrame: CatalogResourceReference?
}

struct PhotoPlacement: Codable, Sendable {
    let assetID: UUID
    var nativeScale: Double
    var focalX: Double
    var focalY: Double
    var quarterTurns: Int
    var flippedHorizontally: Bool
    var accessibilityDescription: String?
}

struct PhotoMask: Codable, Sendable {
    var shape: CatalogResourceReference
}

struct PhotoBorder: Codable, Sendable {
    var width: Double
    var color: SRGBAColor
}

struct PhotoFrameStyleDefaults: Codable, Sendable {
    var mask: CatalogResourceReference
    var border: PhotoBorder
    var decorativeFrame: CatalogResourceReference?
}
```

`DAT-006` — Sous réserve de confirmation de la convention 3.1,
`nativeScale` DOIT être fini et compris entre `0,1` et `8`. Soit une photo de
`Iw × Ih` pixels après orientation EXIF : avant rotation utilisateur, son rendu
mesure exactement `nativeScale × Iw` par `nativeScale × Ih` unités dans la
page canonique `2 400 × 3 000`. Les axes sont permutés lorsque `quarterTurns`
est impair. La géométrie du cadre, son masque, les DPI du fichier, le facteur
Retina et la destination de rendu NE DOIVENT PAS entrer dans cette échelle.

`DAT-007` — `focalX` et `focalY` DOIVENT être finis et compris entre `0` et
`1` dans les coordonnées de la photo après orientation EXIF mais avant les
transformations utilisateur. Le point source ainsi désigné, après rotation et
retournement, DOIT coïncider avec le centre local du cadre. La valeur initiale
`(0,5, 0,5)` centre donc la photo ; le déplacement modifie ce point sans imposer
de couverture minimale du masque.

`DAT-008` — `quarterTurns` DOIT être normalisé dans `0...3`. L’ordre de rendu
DOIT être orientation EXIF, rotation par quarts de tour, retournement horizontal
dans les axes ainsi tournés, `nativeScale`, positionnement du point focal,
masque, rotation du cadre puis composition. Une modification du rapport, de la
taille ou du masque du cadre conserve les cinq paramètres géométriques
`nativeScale`, `focalX`, `focalY`, `quarterTurns` et
`flippedHorizontally`, conformément à `CRP-007`.

`DAT-009` — `accessibilityDescription` PEUT être vide et DOIT être limité à cinq cents caractères utilisateur.

`DAT-010` — `contentHash` DOIT identifier les octets exacts de l’original
conservé. Un dérivé DOIT posséder sa propre entrée d’asset et sa propre
empreinte.

## 22.5 Texte, sticker et ressources de catalogue

```swift
struct TextBoxElement: Codable, Sendable, Identifiable {
    let id: UUID
    var geometry: ElementGeometry
    var sourceTemplateSlotID: String?
    var content: TextBoxContent
    var typingDefaults: TextStyleDefaults
    var opacity: Double
    var usesAutomaticHeight: Bool
}

struct TextBoxContent: Codable, Sendable {
    var paragraphs: [TextParagraph]
}

struct TextParagraph: Codable, Sendable {
    var alignment: TextAlignmentValue
    var lineSpacing: Double
    var runs: [TextRun]
}

struct TextRun: Codable, Sendable {
    var text: String
    var fontID: String
    var relativeFontSize: Double
    var weight: TextWeightValue
    var isItalic: Bool
    var color: SRGBAColor
}

struct TextStyleDefaults: Codable, Sendable {
    var fontID: String
    var relativeFontSize: Double
    var weight: TextWeightValue
    var isItalic: Bool
    var color: SRGBAColor
    var alignment: TextAlignmentValue
    var lineSpacing: Double
}

enum TextAlignmentValue: String, Codable {
    case leading
    case center
    case trailing
    case justified
}

enum TextWeightValue: String, Codable {
    case regular
    case bold
}

struct StickerElement: Codable, Sendable, Identifiable {
    let id: UUID
    var geometry: ElementGeometry
    var resource: CatalogResourceReference
    var opacity: Double
    var flippedHorizontally: Bool
}

struct CatalogResourceReference: Codable, Sendable {
    let catalogID: String
    let catalogVersion: Int
    let fallbackContentHash: String?
}

struct SRGBAColor: Codable, Sendable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
}
```

`DAT-011` — `centerX` et `width` DOIVENT être normalisés par la largeur de
page ; `centerY` et `height` par la hauteur de page. `rotationRadians` est
mesurée dans le sens horaire et normalisée dans `[-π, π)`.

`DAT-012` — L’ordre visuel DOIT être croissant selon `order`. Après import,
fusion ou réordonnancement, les valeurs DOIVENT être uniques et renumérotées
avec un pas constant de `1024`.

`DAT-013` — En présence temporaire de deux valeurs `order` identiques, le tri
DOIT utiliser l’UUID de l’élément comme second critère avant renumérotation.

`DAT-031` — Les composantes `SRGBAColor`, opacités, interlignes, tailles
relatives, coordonnées et `nativeScale` DOIVENT être finies et bornées par les
exigences de leur fonction avant persistance.

`DAT-032` — Le premier schéma publiable DOIT utiliser directement ce modèle.
Aucun lecteur ni migrateur des snapshots de développement antérieurs à la
spécification 3.0 NE DOIT être développé.

`DAT-038` — `typingDefaults` DOIT persister le style de frappe complet utilisé
lorsque le curseur n’hérite d’aucun run et le style d’une zone vide, notamment
celle créée par `TPL-012`. Une évolution du catalogue de modèles NE DOIT PAS
modifier ce style après création.

`DAT-039` — Les trois cas de `BackgroundSelection` DOIVENT rester distincts à
la sérialisation. `none` ne contient aucune ressource, `solid` contient une
couleur sRGB opaque validée et `catalog` contient la référence complète dont le
hash de secours respecte le discriminant défini par `CAT-006`.

`DAT-041` — Chaque champ `CatalogResourceReference` DOIT résoudre le type
attendu dans le registre : `BackgroundSelection.catalog` vers un fond `asset`,
`StickerElement.resource` vers un sticker `asset`, `PhotoMask.shape` et le
masque d'un `PhotoFrameStyleDefaults` vers une forme `nativeVector`, et chaque
`decorativeFrame` vers un cadre décoratif `asset`. Une catégorie, une version,
un payload ou un hash incompatible DOIT faire refuser l'état avant
persistance, synchronisation ou import.

`DAT-042` — Si `photoMode` n'est pas `template`, chaque
`sourceTemplateSlotID` DOIT être nul. Si `photoMode = template`, toute valeur
non nulle DOIT désigner un slot de même type dans le couple
`templateID`/`templateVersion` de la page, lequel DOIT résoudre une version
active ou inactive du manifeste `TPL-019`, et deux éléments NE DOIVENT PAS
désigner le même slot. Les cadres photo et les slots photo forment une
bijection : chaque cadre a un identifiant non nul et chaque slot est utilisé
exactement une fois. Un texte PEUT seul avoir une valeur nulle après avoir été
libéré par `TPL-011`; les autres identifiants texte restent uniques, de bon
type, et un slot libéré n'est pas réattribué implicitement. Tout autre état est
refusé avant persistance, synchronisation ou import.

`DAT-043` — `PhotoAssetMetadata.pixelWidth` et `pixelHeight` DOIVENT être des
entiers strictement positifs décrivant les axes après application de
l'orientation EXIF, sans réécriture de l'original. Ils sont immuables pour un
`assetID`, synchronisés avec ses autres métadonnées et utilisables même lorsque
les octets sont temporairement ou durablement indisponibles.

## 22.6 Révision

```swift
struct AlbumRevisionMetadata: Codable, Sendable {
    let id: UUID
    let albumID: UUID
    let createdAt: Date
    let reason: RevisionReason
    let snapshotHash: String
    let deviceIdentifier: String
    var serverAcceptedAt: Date?
}

enum RevisionReason: String, Codable {
    case albumCreated
    case editorClosed
    case libraryRename
    case coverChanged
    case beforeRestore
    case conflictResolution
    case migration
}
```

`DAT-014` — L’ordre déterministe des révisions DOIT utiliser successivement `serverAcceptedAt ?? createdAt`, `deviceIdentifier` et `id`.

`DAT-015` — `deviceIdentifier` DOIT être un UUID aléatoire propre à l’installation, stocké localement. Il NE DOIT PAS utiliser un identifiant matériel, publicitaire ou de compte.

## 22.7 Métadonnées de synchronisation

```swift
struct SyncMetadata: Codable, Sendable {
    var cloudRecordName: String?
    var cloudChangeTag: String?
    var baseContentHash: String?
    var baseSnapshotReference: UUID?
    var localContentHash: String
    var conflictHeadRecordNames: [String]
    var lastSyncedAt: Date?
    var state: SyncState
}
```

`DAT-016` — Les métadonnées de synchronisation DOIVENT être associées
séparément à l’album, à chaque page, à chaque asset logique, à chaque
blob identifié par `contentHash` et à chaque révision. Les métadonnées Cloud
d’un `AssetRecord` NE DOIVENT PAS être copiées vers le nouvel `assetID` créé
par une réutilisation interalbum.

```swift
struct SyncBaseSnapshot: Codable, Sendable {
    let id: UUID
    let entityID: UUID
    let contentHash: String
    let canonicalPayload: Data
    let createdAt: Date
}
```

`DAT-029` — `baseSnapshotReference` DOIT résoudre un `SyncBaseSnapshot` dont l’empreinte correspond à `baseContentHash`.

## 22.8 Index global des assets

```swift
struct AssetBlobIndexEntry: Codable, Sendable {
    let contentHash: String
    let relativePath: String
    let byteCount: Int64
    let detectedContentType: String
    var referenceCount: Int
    var state: AssetState
}
```

`DAT-017` — L’index binaire DOIT contenir au plus une entrée par
`contentHash`. `referenceCount` agrège tous les identifiants logiques et états
récupérables qui partagent cette empreinte ; il reste une optimisation et NE
DOIT PAS être l’unique preuve autorisant une suppression. La purge DOIT
vérifier les références réelles selon `LOC-008`.

`DAT-018` — Un album et une révision DOIVENT référencer les assets logiques
par `assetID`. La résolution s’effectue obligatoirement en deux étapes :
`assetID` vers ses `PhotoAssetMetadata`, puis leur `contentHash` vers l’unique
`AssetBlobIndexEntry` et son fichier immuable. Plusieurs `assetID` de plusieurs
albums PEUVENT ainsi résoudre les mêmes octets sans partager leur identité
métier.

## 22.9 Réglages globaux

```swift
struct AppSettings: Codable, Sendable {
    var slideshow: SlideshowSettings
}

struct SlideshowSettings: Codable, Sendable {
    var screenDurationSeconds: Double
    var loops: Bool
}
```

`DAT-019` — `screenDurationSeconds` DOIT être comprise entre `1` et `60`. Les valeurs initiales DOIVENT être `5` et `false`.

## 22.10 Sérialisation et empreintes logiques

| ID | Exigence |
|---|---|
| `DAT-020` | Les UUID DOIVENT être sérialisés en minuscules avec tirets. |
| `DAT-021` | Les dates DOIVENT être sérialisées en UTC au format RFC 3339 avec millisecondes. |
| `DAT-022` | Les nombres flottants DOIVENT être finis ; `NaN` et les infinis sont interdits. |
| `DAT-023` | Les valeurs normalisées DOIVENT être bornées et validées avant persistance. |
| `DAT-024` | Une empreinte logique DOIT être calculée sur un JSON canonique UTF-8 conforme à RFC 8785 après application des règles précédentes. |
| `DAT-025` | Chaque type persistant publiable DOIT porter ou hériter d’une version de schéma permettant les migrations des futures versions publiées. |
| `DAT-026` | Une future migration d’un format publié DOIT conserver l’original jusqu’à validation et empreinte du résultat migré ; cette règle ne crée aucune compatibilité avec les prototypes 2.1 exclus par `DEC-33`. |
| `DAT-027` | L'empreinte logique d'un album DOIT inclure sa génération de modèle, son schéma, son nom, sa couverture, sa photothèque ordonnée, les dimensions, `capturedAt` et `importedAt` des photos, ses pages, fonds, états de mise en page, éléments et références d'assets ; elle DOIT exclure `createdAt`, `updatedAt`, `trashedAt`, les dates et métadonnées de synchronisation, caches, miniatures et diagnostics. |
| `DAT-028` | Toute commande modifiant le contenu DOIT affecter à `updatedAt` l’instant UTC de sa validation, y compris une commande Annuler ou Rétablir. |
| `DAT-033` | Le premier schéma local publiable de la spécification 3.0 DOIT utiliser `modelGeneration = "album-photo-canvas-v1"` et `schemaVersion = 1`. Le décodeur DOIT vérifier la génération avant le schéma et refuser toute autre valeur. |
| `DAT-037` | Une géométrie produite par le générateur `AUT-012` DOIT persister `photoMode = automatic`, `isAutoLayoutEnabled`, la densité utilisée et les géométries finales, avec `templateID = nil` et `templateVersion = nil` ; sa relance NE DOIT pas dépendre d’une nouvelle exécution du générateur. |
| `DAT-040` | `photoMode = template` exige `templateID` et `templateVersion` tous deux non nuls ; `free` ou `automatic` exigent les deux valeurs nulles. `isAutoLayoutEnabled = true` exige `photoMode = automatic`, tandis que la valeur `false` est valide avec chaque provenance. Tout état ne respectant pas ces invariants DOIT être refusé avant persistance ou import. |
---

# 23. Architecture technique

## 23.1 Organisation recommandée

```text
App/
├── Application/
├── Domain/
│   ├── Models/
│   ├── Commands/
│   └── Validation/
├── Persistence/
│   ├── Local/
│   ├── Assets/
│   └── Schema/
├── Sync/
│   ├── CloudKit/
│   └── ConflictResolution/
├── Photos/
│   ├── ApplePhotos/
│   ├── GooglePhotos/
│   ├── Files/
│   └── Thumbnails/
├── Documents/
│   ├── AlbumPackage/
│   └── PDF/
├── Features/
│   ├── Library/
│   ├── AlbumEditor/
│   ├── PageOverview/
│   ├── LayoutPicker/
│   ├── TextEditor/
│   ├── StickerPicker/
│   ├── FrameAndShapePicker/
│   ├── Reader/
│   ├── Slideshow/
│   ├── History/
│   └── Settings/
├── DesignSystem/
└── Resources/
```

## 23.2 Séparation des responsabilités

| ID | Exigence |
|---|---|
| `ARC-001` | Les vues SwiftUI NE DOIVENT PAS écrire directement dans la base. |
| `ARC-002` | Les opérations métier DOIVENT passer par des commandes ou services testables. |
| `ARC-003` | Les modèles du domaine NE DOIVENT PAS dépendre de SwiftUI. |
| `ARC-004` | Les accès aux fichiers et à CloudKit DOIVENT être isolés dans des `actor`. |
| `ARC-005` | Les ViewModels qui modifient l’interface DOIVENT être `@MainActor`. |
| `ARC-006` | Les services externes DOIVENT être injectés par protocole. |
| `ARC-007` | Une commande métier DOIT être idempotente ou porter explicitement une clé d’idempotence. |
| `ARC-008` | Le rendu de page utilisé par l’éditeur, la lecture, le diaporama et le PDF DOIT partager les mêmes fonctions géométriques pures. |
| `ARC-014` | Une version publique NE DOIT PAS exposer les écrans ou commandes d’un lot ultérieur ; les capacités de schéma inutilisées PEUVENT déjà être présentes. |
| `ARC-015` | Les fonctionnalités différées DOIVENT être activées par version de produit ou configuration de build testée, et non par une condition dispersée dans les vues. |
| `ARC-016` | Le domaine et les services externes DOIVENT rester séparés afin que les tests Linux, les doubles de test et les implémentations Apple utilisent les mêmes contrats. |
| `ARC-017` | Le package produit avec Swift Playgrounds NE DOIT PAS dépendre d’un état local non versionné nécessaire à son ouverture ultérieure dans Xcode. |

## 23.3 Protocoles principaux

```swift
protocol AlbumRepository
protocol AssetRepository
protocol RevisionRepository
protocol CloudSyncService
protocol GooglePhotosService
protocol AlbumPackageService
protocol PDFExportService
protocol ThumbnailService
protocol PhotoImportService
protocol LayoutCatalogService
protocol CatalogResourceService
protocol PageRenderingService
protocol TransactionJournal
protocol PackageValidator
protocol AlbumEditLeaseService
```

## 23.4 Stockage local recommandé

| ID | Exigence |
|---|---|
| `ARC-009` | SwiftData PEUT être utilisé pour les métadonnées locales sous iOS 26 si le protocole transactionnel de la section 18 reste respecté. |
| `ARC-010` | Les photos et copies de secours binaires des ressources de catalogue DOIVENT rester dans le système de fichiers. |
| `ARC-011` | La synchronisation CloudKit DOIT être pilotée par un service explicite. |
| `ARC-012` | Les instantanés de révision PEUVENT être stockés en JSON canonique ou en binaire Codable versionné. |

## 23.5 Éditeur de texte Photoweb sous iOS 26

| ID | Exigence |
|---|---|
| `TXA-001` | L’éditeur DOIT utiliser prioritairement les API SwiftUI publiques d’iOS 26 pour `AttributedString`, la sélection et les attributs de saisie. |
| `TXA-002` | Aucun fallback pour un système antérieur à iOS 26 ni moteur TextKit parallèle NE DOIT être développé. |
| `TXA-003` | Une intégration UIKit ponctuelle PEUT être utilisée uniquement après une décision d’architecture documentant l’impossibilité avec les API SwiftUI. |
| `TXA-004` | `TextBoxContent` DOIT rester indépendant de SwiftUI et d’`AttributedString` et être testable sous Linux. |
| `TXA-005` | Le lot 0 DOIT prototyper sélection partielle, styles Photoweb, collage filtré, redimensionnement de boîte, détection de débordement, annulation et sérialisation. |

## 23.6 Frameworks publics

- SwiftUI
- UIKit lorsque nécessaire
- PhotosUI
- CloudKit
- UniformTypeIdentifiers
- PDFKit ou Core Graphics
- Core Image et ImageIO pour les images fixes
- CryptoKit pour les empreintes
- Security pour le trousseau
- Google Sign-In via Swift Package Manager
- Google Photos Picker API via HTTPS et OAuth

`ARC-013` — Aucune dépendance externe supplémentaire NE DOIT être ajoutée sans décision d’architecture et justification dans le README technique.

## 23.7 Configuration sensible

| ID | Exigence |
|---|---|
| `CFG-001` | Les identifiants OAuth Google DOIVENT être fournis par configuration de build. |
| `CFG-002` | Les fichiers contenant uniquement des identifiants publics PEUVENT être intégrés selon les recommandations Google. |
| `CFG-003` | Aucun secret serveur NE DOIT être embarqué. |
| `CFG-004` | Le nom du conteneur CloudKit DOIT être défini dans un fichier de configuration par environnement. |
| `CFG-005` | Les environnements développement et production DOIVENT être distincts. |
| `CFG-006` | Une archive de distribution DOIT échouer si le bundle identifier est un placeholder ou si la configuration obligatoire de sa version publique est absente. |

---

# 24. Gestion des erreurs

| ID | Situation | Comportement obligatoire |
|---|---|---|
| `ERR-001` | Photothèque annulée | Fermer le sélecteur sans modification. |
| `ERR-002` | Photo non décodable | Afficher une erreur et conserver l’ancienne photo ou le cadre vide. |
| `ERR-003` | Vidéo, GIF ou contenu animé sélectionné | Refuser l’import et rappeler que seules les photos statiques sont acceptées. |
| `ERR-004` | Stockage insuffisant | Refuser la validation et conserver la dernière version valide. |
| `ERR-005` | Téléchargement Google interrompu | Conserver la page puis proposer Réessayer. |
| `ERR-006` | Session Google expirée | Proposer une nouvelle connexion et sélection. |
| `ERR-007` | Compte Google déconnecté | Conserver toutes les photos déjà importées. |
| `ERR-008` | iCloud indisponible | Continuer localement et afficher Local uniquement ou En attente. |
| `ERR-009` | Quota iCloud atteint | Conserver les changements localement et afficher Gérer le stockage. |
| `ERR-010` | Conflit CloudKit | Conserver toutes les branches et ouvrir le processus de résolution. |
| `ERR-011` | Package corrompu | Refuser l’import sans créer d’album. |
| `ERR-012` | Package complet sauf photos absentes | Prévisualiser en mode dégradé et demander confirmation avant import. |
| `ERR-013` | Version de package trop récente | Demander une mise à jour de l’application. |
| `ERR-014` | Erreur de sauvegarde | Ne pas remplacer l’état valide précédent et conserver la commande dans le journal si possible. |
| `ERR-015` | Erreur de restauration | Conserver l’état courant et la révision créée avant la tentative. |
| `ERR-016` | Erreur de génération PDF | Supprimer le fichier temporaire puis permettre une nouvelle tentative. |
| `ERR-017` | Ressource de fond absente du bundle courant | Utiliser la copie de secours validée ; à défaut, afficher provisoirement le fond par défaut, conserver l’identifiant d’origine et bloquer l’export concerné. |
| `ERR-018` | Ressource de sticker, forme ou cadre indisponible | Pour un `asset`, utiliser la copie de secours validée ; à défaut, signaler l'élément et bloquer l'export concerné. Pour un `nativeVector`, ne jamais chercher de fichier : un `rendererID` inconnu ou indisponible signale l'élément et bloque l'export concerné. |
| `ERR-019` | Texte débordant | Identifier la page et la zone, bloquer Prévisualiser et Exporter, puis proposer d’ouvrir la zone. |
| `ERR-020` | Limite de zone de texte atteinte | Empêcher la saisie supplémentaire et annoncer la limite de manière accessible. |
| `ERR-022` | Aucun autre modèle compatible avec le dé, ou Auto impossible au-delà de l’enveloppe garantie | Désactiver uniquement la commande concernée ou Auto, conserver la composition et expliquer comment poursuivre manuellement, sans créer ni retirer de contenu. Le générateur obligatoire `AUT-012` interdit cette erreur entre zéro et vingt occurrences pour Auto. |
| `ERR-023` | Référence ou copie de ressource de catalogue inconnue ou non conforme | Rejeter le package sans créer d’album et expliquer qu’il contient une ressource visuelle non prise en charge. |
| `ERR-024` | Génération de modèle local ou de package absente ou différente | Ne pas décoder le contenu comme un album 3.0, ne modifier aucune donnée et expliquer que le document n’est pas compatible. |

`ERR-021` — Les messages DOIVENT expliquer l’action possible. Une erreur technique brute NE DOIT PAS être affichée seule.

---

# 25. Confidentialité et sécurité

| ID | Exigence |
|---|---|
| `SEC-001` | Aucune photo ne doit être envoyée vers un serveur propriétaire. |
| `SEC-002` | Les données CloudKit doivent utiliser la base privée de l’utilisateur. |
| `SEC-003` | Les jetons Google doivent être stockés dans le trousseau. |
| `SEC-004` | Les journaux ne doivent contenir ni jeton ni contenu intégral d’album. |
| `SEC-005` | Les packages importés doivent être validés avant toute écriture durable. |
| `SEC-006` | Les chemins contenus dans un package ne doivent pas pouvoir sortir de sa racine. |
| `SEC-007` | Les empreintes de fichiers doivent être vérifiées. |
| `SEC-008` | Les fichiers temporaires doivent être supprimés après utilisation. |
| `SEC-009` | L’application doit fournir les déclarations de confidentialité exigées pour Google Sign-In et l’accès aux photos. |
| `SEC-010` | Aucun outil d’analyse comportementale ne doit être ajouté sans décision produit distincte. |
| `SEC-011` | Les fichiers persistants DOIVENT utiliser la protection de données du système au moins équivalente à `completeUntilFirstUserAuthentication`. |
| `SEC-012` | Les journaux et jetons DOIVENT utiliser la protection la plus stricte compatible avec leur usage. |
| `SEC-013` | Les packages non fiables DOIVENT être analysés sans exécuter ni interpréter de contenu actif. |
| `SEC-014` | Les noms de fichiers provenant d’un import NE DOIVENT PAS être utilisés directement comme chemins locaux. |

---

# 26. Accessibilité et adaptation

| ID | Exigence |
|---|---|
| `ACC-001` | Tous les boutons doivent posséder un libellé VoiceOver. |
| `ACC-002` | Les commandes uniquement graphiques doivent posséder une indication et une aide accessibles. |
| `ACC-003` | Les zones tactiles doivent mesurer au moins 44 × 44 points. |
| `ACC-004` | Les états ne doivent pas être signalés uniquement par une couleur. |
| `ACC-005` | Les actions de déplacement, rotation, redimensionnement et ordre de chaque type d’élément doivent être accessibles par menu en plus des gestes. |
| `ACC-006` | Réduire les animations doit être respecté. |
| `ACC-007` | VoiceOver doit lire le numéro de page, le nombre de cadres photo dont les cadres vides, le nombre de zones de texte, le nombre de stickers et les alertes. |
| `ACC-008` | Les éléments d’interface hors canevas doivent respecter Dynamic Type. |
| `ACC-009` | L’éditeur de zone de texte doit être pleinement utilisable avec Dynamic Type sans modifier la géométrie persistée du canevas. |
| `ACC-010` | Le canevas conserve sa mise en page, mais le texte complet de chaque zone reste lisible et éditable par VoiceOver. |
| `ACC-011` | L’utilisateur DOIT pouvoir saisir une description accessible pour chaque occurrence photo. |
| `ACC-012` | Chaque élément DOIT être parcourable individuellement avec VoiceOver avec son type, son nom ou texte, sa position approximative et son ordre. |
| `ACC-013` | Déplacer, tourner, redimensionner et réordonner tout élément DOIVENT être réalisables sans geste multipoint. |
| `ACC-014` | Les parcours principaux DOIVENT être utilisables au clavier, au pointeur et au trackpad sur iPad. |
| `ACC-015` | Les commandes fréquentes DOIVENT proposer des raccourcis clavier documentés lorsqu’un clavier est présent. |
| `ACC-016` | Le mode contraste élevé, les filtres de couleur et Différencier sans couleur DOIVENT conserver la compréhension de tous les contrôles. |
| `ACC-017` | Les photos sans description utilisateur DOIVENT recevoir le libellé neutre « Photo, page N ». |
| `ACC-018` | Les PDF DOIVENT respecter les exigences de balisage et de texte alternatif de `PDF-013` et `PDF-014`. |
| `ACC-019` | La palette de texte DOIT signaler une combinaison qui ne respecte pas le contraste WCAG AA avec le fond visible au centre de la zone, sans empêcher un choix explicite. |
| `ACC-020` | Le glisser-déposer d’une photo, la réorganisation d’une page et chaque commande du dé ou de l’automatisme DOIVENT posséder une alternative activable par VoiceOver. |
| `ACC-021` | Le changement iPad/iPhone entre rail latéral, barre inférieure et feuille NE DOIT perdre ni le focus, ni la sélection, ni l’accès aux cinq panneaux. |

---

# 27. Performance et robustesse

L’appareil de référence est le plus ancien iPhone ou iPad officiellement compatible avec iOS 26 et disponible dans la matrice de test.

| ID | Exigence |
|---|---|
| `PERF-001` | Les pages non visibles NE DOIVENT PAS conserver de photo pleine résolution décodée en mémoire. |
| `PERF-002` | La bibliothèque DOIT utiliser des miniatures et les listes des conteneurs paresseux. |
| `PERF-003` | Au plus la page courante, ses miniatures nécessaires et la page suivante PEUVENT être préchauffées à une définition adaptée à l’écran. |
| `PERF-004` | Les imports, exports, empreintes, conversions d’images et synchronisations DOIVENT s’exécuter hors du thread principal. |
| `PERF-005` | Les transformations d’éléments, guides et animations de page DOIVENT viser 60 images/s sur l’appareil de référence dans l’enveloppe garantie. |
| `PERF-006` | Avec cent pages contenant chacune vingt photos, vingt textes et vingt stickers et cinq gigaoctets sur disque, le pic de mémoire résidente DOIT rester inférieur à 500 Mo. |
| `PERF-007` | L’ouverture locale de la bibliothèque puis l’affichage de son premier contenu DOIT prendre moins de deux secondes avec cent albums et des miniatures déjà générées. |
| `PERF-008` | L’ouverture d’un album de cent pages puis l’affichage de la première page DOIT prendre moins de deux secondes lorsque ses premiers assets sont locaux. |
| `PERF-009` | Une tâche dépassant 500 ms DOIT afficher un état de progression ou d’activité et, lorsqu’elle modifie des fichiers, une annulation sûre. |
| `PERF-010` | Une génération PDF ou un export PEUT durer plusieurs minutes si la progression continue, l’annulation et la cohérence sont assurées. |
| `PERF-011` | Une annulation de tâche longue DOIT laisser les données dans un état cohérent et nettoyer son staging. |
| `PERF-012` | Les révisions DOIVENT référencer des ressources immuables dédupliquées. |
| `PERF-013` | Les nouvelles tentatives réseau DOIVENT respecter `Retry-After` lorsqu’il existe, sinon utiliser une attente exponentielle avec jitter de 1 seconde à 5 minutes. |
| `PERF-014` | Une erreur non récupérable ou une action utilisateur DOIT interrompre la stratégie de nouvelle tentative. |
| `PERF-015` | Les dépassements de cent pages, cinq gigaoctets ou vingt éléments d’un même type par page DOIVENT produire un avertissement non bloquant ; seul un risque de cohérence, de stockage ou de décodage PEUT bloquer. |
| `PERF-016` | L’ouverture d’un panneau, l’application d’un modèle et le calcul du dé DOIVENT produire leur premier retour visuel en moins de 200 ms hors chargement d’asset. |
| `PERF-017` | Le déplacement d’un élément NE DOIT déclencher aucun décodage pleine résolution ni écriture durable à chaque image ; la commande finale reste persistée selon `APP-005`. |

---

# 28. Localisation

| ID | Exigence |
|---|---|
| `L10N-001` | La première langue fournie DOIT être le français. |
| `L10N-002` | Toutes les chaînes visibles DOIVENT être stockées dans un catalogue de chaînes localisables. |
| `L10N-003` | Aucun texte utilisateur NE DOIT être utilisé comme identifiant technique. |
| `L10N-004` | Le sens de lecture des versions 1.0 à 1.2 DOIT rester gauche vers droite, même si une langue droite vers gauche est ajoutée. |
| `L10N-005` | Les dates, nombres et durées DOIVENT utiliser les formateurs du système. |

---

# 29. Scénarios d’acceptation

`TST-005` — Chaque scénario DOIT posséder un identifiant, une version cible et les groupes d’exigences principalement couverts. La matrice de traçabilité détaillée DOIT relier chaque identifiant individuel à au moins un scénario, test automatisé ou contrôle manuel.

## 29.1 `ACPT-100` — Création et durabilité — version 1.0

**Couvre :** `ALB-011` à `ALB-016`, `APP-005`, `LOC-011` à `LOC-016`<br>
**Étant donné** une bibliothèque vide<br>
**Quand** l’utilisateur crée un album nommé « Guatemala », ajoute une page, puis le processus est interrompu après validation<br>
**Alors** l’album, ses deux pages et le fond à spirales réapparaissent après relance sans corruption.

## 29.2 `ACPT-102` — Corbeille — version 1.0

**Couvre :** `ALB-008`, `ALB-017` à `ALB-020`<br>
**Étant donné** un album existant<br>
**Quand** l’utilisateur confirme sa suppression puis le restaure depuis la corbeille avant trente jours<br>
**Alors** l’album et ses ressources réapparaissent sans perte.

## 29.3 `ACPT-103` — Couverture automatique et manuelle — version 1.0

**Couvre :** `COV-001` à `COV-007`, `DAT-005`<br>
**Étant donné** quatre pages dont les pages 1, 3 et 4 possèdent plusieurs occurrences photo<br>
**Quand** l’utilisateur choisit l’occurrence de la page 4, réorganise les pages puis supprime cette occurrence<br>
**Alors** la couverture manuelle suit son `elementID` puis revient à la première occurrence selon l’ordre des pages et des éléments.

## 29.4 `ACPT-104` — Pages et annulation — version 1.0

**Couvre :** `PAG-001` à `PAG-015`, `UND-001` à `UND-010`<br>
**Étant donné** cinq pages contenant chacune un marqueur distinct<br>
**Quand** la cinquième est déplacée en deuxième position puis supprimée<br>
**Alors** deux actions Annuler restaurent successivement la page puis l’ordre initial, et la dernière page restante ne peut jamais être supprimée.

## 29.5 `ACPT-111` — Package interappareils — version 1.0

**Couvre :** `PKG-001` à `PKG-022`, `EXP-001` à `EXP-008`, `IMP-001` à `IMP-025`<br>
**Étant donné** un album complet créé sur iPhone, contenant une photo réutilisée depuis un autre album, des zones transparentes autour d’une photo à `1×` et un cadrage sous `1×`<br>
**Quand** son package est partagé, que l’album source est supprimé, puis que le package est importé deux fois sur iPad<br>
**Alors** deux copies autonomes possèdent de nouveaux identifiants logiques, résolvent leurs propres octets hors ligne, conservent les `contentHash` dédupliqués et rendent exactement les mêmes rectangles canoniques, transparences, pages et ressources.

## 29.6 `ACPT-112` — Package non fiable — version 1.0

**Couvre :** `IMP-002` à `IMP-025`, `SEC-005` à `SEC-014`, `CAT-001` à `CAT-008`<br>
**Étant donné** des packages avec traversée de chemin, checksum incorrect, ressource de catalogue arbitraire, catégorie incohérente, copie `asset` manquante, fichier ou hash de secours interdit sur un `nativeVector`, `rendererID` inconnu ou génération du prototype, puis un package 3.0 autrement valide avec une photo absente<br>
**Quand** ils sont inspectés<br>
**Alors** la génération du prototype est rejetée avant de décoder `album`, tous les packages hostiles sont rejetés avant toute écriture durable, et le dernier peut être prévisualisé puis importé en mode dégradé uniquement après confirmation.

## 29.7 `ACPT-113` — PDF accessible — version 1.0

**Couvre :** `PDF-001` à `PDF-020`<br>
**Étant donné** un album avec photos à des `nativeScale` inférieurs, égaux et supérieurs à `1`, masques partiellement transparents, au moins une occurrence `Acceptable` et une autre `Insuffisante`, textes stylés, stickers et descriptions accessibles<br>
**Quand** l’utilisateur choisit le format, consulte le récapitulatif par page puis poursuit la génération du PDF<br>
**Alors** les états suivent la formule canonique de `QLT-002`, l’avertissement reste non bloquant, les zones non couvertes laissent voir la composition inférieure comme dans la prévisualisation et le document expose l’ordre de lecture et les textes alternatifs attendus.

## 29.8 `ACPT-114` — Enveloppe de performance — version 1.0

**Couvre :** `PERF-001` à `PERF-017`<br>
**Étant donné** l'appareil de référence et un album de cent pages, vingt éléments de chaque type par page et cinq gigaoctets<br>
**Quand** l'album est ouvert, qu'un panneau est affiché, qu'un modèle et le dé sont appliqués, qu'un élément est déplacé pendant instrumentation, puis que l'album est parcouru et exporté<br>
**Alors** les seuils de temps, mémoire, fluidité, progression et annulation de la section 27 sont respectés, le premier retour panneau/modèle/dé arrive en moins de 200 ms hors asset et aucune image du déplacement ne décode l'original ni n'écrit durablement.

## 29.9 `ACPT-115` — Accessibilité iPhone et iPad — version 1.0

**Couvre :** `ACC-001` à `ACC-021`<br>
**Étant donné** VoiceOver, Dynamic Type, contraste élevé et un clavier avec pointeur<br>
**Quand** l’utilisateur exécute les parcours prioritaires<br>
**Alors** il peut créer, lire, décrire et manipuler les éléments sans geste multipoint ni information transmise uniquement par la couleur.

## 29.10 `ACPT-117` — Historique — version 1.1

**Couvre :** `HIS-001` à `HIS-022`<br>
**Étant donné** plus de cinquante révisions provenant de plusieurs appareils<br>
**Quand** une ancienne révision conservée est restaurée<br>
**Alors** l’état précédent devient courant, l’ancien état courant est archivé et la purge conserve déterministement les cinquante dernières.

## 29.11 `ACPT-118` — Fusion de pages distinctes — version 1.1

**Couvre :** `SYN-001` à `SYN-025`, `ICL-001` à `ICL-010`<br>
**Étant donné** deux appareils modifiant hors ligne deux pages différentes depuis la même base<br>
**Quand** ils se reconnectent<br>
**Alors** les deux changements fusionnent automatiquement sans perdre ni dupliquer un asset.

## 29.12 `ACPT-119` — Conflit multi-appareil — version 1.1

**Couvre :** `CNF-001` à `CNF-013`<br>
**Étant donné** trois appareils modifiant hors ligne la même page<br>
**Quand** ils se reconnectent<br>
**Alors** les trois branches sont conservées, les autres pages continuent à se synchroniser et l’utilisateur peut choisir une branche ou conserver plusieurs albums.

## 29.13 `ACPT-120` — Compte iCloud et hors ligne — version 1.1

**Couvre :** `SYN-011` à `SYN-020`, `SYN-024`, `SYN-025`, `ICL-008` à `ICL-010`<br>
**Étant donné** un changement de compte iCloud<br>
**Quand** le nouveau compte devient actif<br>
**Alors** les albums locaux ne sont pas publiés sans choix ; après Télécharger l’album, toutes ses ressources restent disponibles hors ligne.

## 29.14 `ACPT-121` — Corbeille synchronisée — version 1.1

**Couvre :** `SYN-017`, `SYN-018`, `ALB-017` à `ALB-020`<br>
**Étant donné** un album synchronisé supprimé sur un appareil<br>
**Quand** un autre appareil se synchronise dans les trente jours<br>
**Alors** l’album apparaît dans sa corbeille et peut être restauré sur tous les appareils.

## 29.15 `ACPT-122` — Google Photos — version 1.2

**Couvre :** `GPH-001` à `GPH-011`<br>
**Étant donné** une connexion Google valide<br>
**Quand** plusieurs photos sont sélectionnées puis téléchargées<br>
**Et** le compte Google est déconnecté et l’appareil passe hors ligne<br>
**Alors** toutes les photos restent disponibles localement ; une éventuelle ressource vidéo est ignorée avec une explication.

## 29.16 `ACPT-123` — Éditeur Photoweb natif, une page — version 1.0

**Couvre :** `EDT-001` à `EDT-020`, `ZOM-001` à `ZOM-008`, `GLO-001`, `GLO-002`, `NAV-001` à `NAV-007`<br>
**Étant donné** le même album de plusieurs pages sur iPhone étroit et iPad large<br>
**Quand** l'utilisateur parcourt Photos, Mise en page, Fonds, Stickers et Cadres et formes, ouvre l'aide hors ligne depuis deux panneaux, zoome par commandes et pincement, revient de Vue globale et de la prévisualisation, puis atteint les bornes de l'album avec les boutons et les balayages<br>
**Alors** l'ordre, les commandes, les symboles fonctionnels, leurs libellés accessibles et leurs états activés ou désactivés respectent les matrices 7.2.1 et 7.2.2 dans les présentations natives adaptées, l'aide explique le contexte actif sans réseau, le zoom de session est restauré sans modifier l'album, Précédent et Suivant ciblent les mêmes pages, et une seule page est toujours affichée.

## 29.17 `ACPT-124` — Photos et cadres multiples — version 1.0

**Couvre :** `PHO-001` à `PHO-018`, `APL-001` à `APL-008`, `FMT-001` à `FMT-008`, `QLT-001` à `QLT-006`, `FRM-001` à `FRM-009`, `CRP-001` à `CRP-007`, `DAT-006` à `DAT-010`, `DAT-036`, `DAT-043`, `LOC-007`, `LOC-008`, `LOC-015` à `LOC-017`<br>
**Étant donné** une petite photo de `600 × 400` pixels, une grande photo de `4 800 × 6 000`, trois cadres dans l’album cible et une photo distincte dans un autre album actif<br>
**Quand** la petite photo est placée à `1×`, la grande à `0,5×`, qu’une occurrence est remplacée et une autre dupliquée, que la suppression de son original utilisé est tentée puis sa dernière occurrence retirée, que Supprimer de cet album est confirmé puis annulé, et que la photo de l’autre album est ajoutée par Depuis vos autres albums avant relance<br>
**Alors** la petite photo garde sa taille native centrée avec la composition inférieure et le fond visibles autour d’elle, la grande mesure `2 400 × 3 000` unités, les cadrages persistent, la suppression est désactivée tant qu’une occurrence existe puis restaure asset et indice en une action, la réutilisation crée un nouvel `assetID` cible avec le même `contentHash` sans modifier la source, les états de qualité sont cohérents et GIF ou vidéo sont refusés sans altérer la page.

## 29.18 `ACPT-125` — Modèles, dé et automatisme — version 1.0

**Couvre :** `TPL-001` à `TPL-023`, `RND-001` à `RND-006`, `AUT-001` à `AUT-019`, `DAT-037`, `DAT-040`, `DAT-042`, `DAT-043`<br>
**Étant donné** plusieurs modèles compatibles, quatre photos placées et un modèle ne possédant que deux emplacements photo<br>
**Quand** ce modèle plus petit est d’abord annulé depuis sa confirmation puis appliqué, que l’application est annulée par Annuler, que le dé est utilisé, qu’Auto réagit à un retrait puis que Remplir l’album distribue les photos inutilisées<br>
**Alors** l’annulation de la confirmation ne modifie rien, l’application confirmée annonce et retire exactement deux occurrences dans l’ordre déterministe sans supprimer leurs assets, Annuler restaure toute la composition, aucun autre contenu ne disparaît silencieusement, les cadrages internes sont conservés, les résultats sont persistés et chaque opération complète s’annule en une seule action.

## 29.19 `ACPT-126` — Zones de texte multiples — version 1.0

**Couvre :** `TBX-001` à `TBX-025`, `ELM-008`, `ELM-014`, `DAT-038`<br>
**Étant donné** deux zones superposées à une photo<br>
**Quand** l’utilisateur applique police, taille, couleur et alignement à des sélections, envoie une zone entièrement derrière la photo, la resélectionne par Sélectionner un élément, la ramène au premier plan, colle du contenu Web puis provoque un débordement et relance l’app<br>
**Alors** la profondeur libre et la resélection du texte masqué fonctionnent sans réordonner les autres éléments, seuls les attributs Photoweb persistent, l’alerte identifie la zone et Prévisualiser reste bloqué jusqu’à correction.

## 29.20 `ACPT-127` — Fonds par page — version 1.0

**Couvre :** `BG-001` à `BG-016`, `DAT-039`<br>
**Étant donné** trois pages<br>
**Quand** trois fonds distincts sont appliqués puis l’un est appliqué à tout l’album et l’action annulée<br>
**Alors** éditeur, vue globale, lecture, PDF et relance rendent à nouveau les trois fonds initiaux.

## 29.21 `ACPT-128` — Stickers, cadres et formes — version 1.0

**Couvre :** `STK-001` à `STK-016`, `STK-021` à `STK-024`, `SHR-001` à `SHR-014`, `CAT-001` à `CAT-009`, `DAT-041`<br>
**Étant donné** un cadre photo, le catalogue intégré, son registre public et les golden masks des six formes version 1<br>
**Quand** un sticker est ajouté, remplacé par un rapport différent, transformé et réordonné, puis chacune des six formes, un contour et les six cadres décoratifs sont rendus et une propriété est appliquée à plusieurs photos<br>
**Alors** les cardinalités, identités, licences et contrats du registre public correspondent à la build, les valeurs initiales et le redimensionnement du sticker sont exacts, chaque masque et rendu neuf zones correspond à sa fixture dans toutes les sorties, les rendus persistent, l'annulation globale restaure tous les cadres et aucune commande personnalisée ou animée n'existe.

## 29.22 `ACPT-129` — Vue globale — version 1.0

**Couvre :** `GLO-003` à `GLO-009`, `PAG-001` à `PAG-015`<br>
**Étant donné** cinq pages avec fonds et alertes distincts<br>
**Quand** l’utilisateur les réorganise, en supprime une et ouvre une miniature<br>
**Alors** les numéros et miniatures restent fidèles, aucune page interne n’est éditable dans la grille et Vue page ouvre uniquement la page choisie.

## 29.23 `ACPT-130` — Sauvegarde et presse-papiers — version 1.0

**Couvre :** `SAV-001` à `SAV-004`, `CLP-001` à `CLP-005`, `UND-001` à `UND-012`<br>
**Étant donné** une photo, un texte et un sticker<br>
**Quand** ils sont copiés, coupés et collés entre pages puis Sauvegarder est utilisé avant une interruption simulée<br>
**Alors** les copies ont de nouveaux identifiants, chaque commande s’annule correctement et la relance retrouve le dernier état annoncé Enregistré.

## 29.24 `ACPT-131` — Rendu commun, navigation animée et alertes — version 1.0

**Couvre :** `CAN-001` à `CAN-009`, `ELM-001` à `ELM-014`, `ZOM-001` à `ZOM-008`, `QLT-001` à `QLT-006`, `NAV-001` à `NAV-007`, `ANI-001` à `ANI-009`, `RED-001` à `RED-010`, `SLD-001` à `SLD-022`<br>
**Étant donné** plusieurs pages dont une composition d’éléments superposés, un cadre vide et une alerte de qualité photo<br>
**Quand** chaque type est sélectionné puis déplacé, redimensionné, tourné par poignée et par le contrôle accessible, aligné jusqu'au seuil magnétique, réordonné et dupliqué, qu’un élément masqué est retrouvé par le sélecteur de chevauchement, que les zones transparentes d’un cadre rempli et la composition sont comparées dans l'éditeur, la vue globale, la prévisualisation, la lecture, le diaporama et le PDF, puis que l'utilisateur navigue par bouton et balayage, interrompt un geste et recommence avec Réduire les animations<br>
**Alors** hit-testing, poignées, pas, guides, unique retour haptique, sélection des éléments cachés et alternatives accessibles respectent `ELM-001` à `ELM-014`, la composition utile et les transparences sont identiques, les aides d'édition sont absentes, les alertes restent non bloquantes et chaque changement suit `ANI-001` à `ANI-008` ou le fondu de `ANI-009` sans jamais afficher deux pages actives.

---

# 30. Tests obligatoires

`TST-001` — Chaque exigence normative DOIT être reliée dans la matrice de traçabilité à au moins un test automatisé ou une procédure manuelle.

`TST-002` — Les tests du domaine DOIVENT être écrits avant ou en même temps que la fonctionnalité correspondante.

## 30.1 Tests unitaires

`TST-006` — La suite unitaire DOIT couvrir au minimum :

- validation du nom d’album
- ajout, suppression et réorganisation des pages
- interdiction de supprimer la dernière page
- calcul de la couverture automatique
- repère canonique, dimensions à `1×`, échelles sous `1×`, point focal, transparence, ordre des transformations et conservation lors d’un changement de cadre, forme, modèle ou Auto
- fixtures de cadrage : `600 × 400` dans un cadre canonique `1 200 × 900` à `1×` laisse `300` unités à gauche/droite et `250` en haut/bas ; `2 400 × 1 800` à `0,5×` remplit exactement ce cadre ; valeurs non finies ou hors bornes refusées
- géométrie, hit-testing, ordre unifié et sélection d’un élément entièrement masqué
- zoom de fenêtre, centre visible par page, paliers et absence de mutation du document
- validation du manifeste canonique des modèles, de son empreinte, de l'unique version active par ID et des quatre variantes exigées pour chaque compte de une à huit photos
- application de modèles plus grands, égaux et plus petits avec priorité aux contenus non vides, annulation puis validation de la confirmation lorsque des occurrences seraient retirées, gestion déterministe des slots vides et invalidation de provenance après changement structurel
- bijection des cadres et unicité des textes liés aux slots, avec refus des provenances de modèle invalides
- choix aléatoire sans répétition, cycle complet du sac, changement manuel du modèle courant, remises à zéro et tirage entier sans biais avec source d’aléa injectée
- compatibilité exacte du dé sans ajout ni retrait d’élément
- mise en page automatique après ajout et retrait pour chaque compte de zéro à vingt, suppression des cadres vides réutilisés, provenance de slot nulle et repli généré déterministe
- validation des dimensions photo orientées strictement positives, immuables et utilisables sans octets
- éligibilité atomique de Supprimer de cet album, restauration de l’asset et de son indice par Annuler, puis purge interdite tant qu’une référence récupérable existe
- réutilisation interalbum avec nouvel `assetID`, même `contentHash`, métadonnées cibles indépendantes et ordre d’ajout stable
- valeurs initiales d’une page, d’un cadre libre et d’une zone de texte
- remplissage par densité sans perte d’asset
- sérialisation des zones de texte et détection du débordement
- contrat du registre public : trois fonds, au moins quarante stickers avec cardinalités/tags, six formes et six cadres avec IDs, versions, catégories et licences attendus
- octets, MIME, longueur, SHA-256 et copie de secours de chaque payload `asset`
- `rendererID`, hash nul, absence de fichier et golden masks exacts des six formes `nativeVector` de `SHR-012`
- insets et golden images du rendu neuf zones de chaque cadre décoratif selon `SHR-013`
- commandes Annuler et Rétablir
- création et purge des révisions
- déduplication des fichiers
- validation du manifeste et des empreintes
- migrations de futurs schémas publiés, lorsqu’elles existent
- détection et résolution des conflits
- validation des mille caractères par zone et par graphème Swift `Character`
- sérialisation canonique et stabilité des empreintes
- règles de merge page par page et métadonnée par métadonnée
- ordre déterministe des révisions et éléments
- validation et refus déterministes des formats statiques ou animés

## 30.2 Tests d’intégration

`TST-007` — La suite d’intégration DOIT couvrir au minimum :

- stockage local puis relance
- création exclusive de la racine 3.0 en présence d’un store 2.1 laissé intact et jamais décodé
- import multiple de photos
- import HEIC, JPEG, PNG, RAW et composante fixe de Live Photo avec fichiers de référence
- refus de GIF, APNG, vidéo et image dépassant la limite de pixels
- calcul des états photo `OK`, `Acceptable` et `Insuffisante` aux seuils de 300 et 150 ppp
- conservation d’un original dans Photos après retrait de sa dernière occurrence, puis suppression confirmée uniquement à zéro occurrence et restauration complète par Annuler
- réutilisation depuis un album actif avec nouvel `assetID` cible, même `contentHash` et même blob physique, puis suppression de la source et de la cible indépendantes
- import Google avec service simulé
- glisser-déposer ou affectation d’une photo dans plusieurs cadres
- modèles, dé, automatisme et remplissage suivis d’une relance
- fonds distincts par page
- copies de secours enregistrées et validées des fonds, stickers et cadres `asset`
- formes `nativeVector` résolues par leur `rendererID`, sans hash ni fichier de secours
- export puis réimport d’un package autonome contenant une photo interalbum après suppression de son album source
- génération PDF
- synchronisation CloudKit avec doubles de test
- interruption pendant une copie de fichier
- manque d’espace simulé
- reprise du journal après interruption à chaque étape transactionnelle
- import dégradé avec photo absente
- rejet d’un descripteur photo incomplet, de dimensions non positives ou différentes du fichier présent, ainsi que d’un identifiant de modèle ou de slot absent du manifeste
- rejet de liens, chemins malveillants, types MIME trompeurs, générations étrangères, ressources de catalogue arbitraires, catégories ou versions incohérentes, fallback `asset` manquant ou altéré, fichier/hash interdit sur `nativeVector`, `rendererID` inconnu et packages surdimensionnés en nombre d'entrées
- changement de compte iCloud
- conflit impliquant trois appareils
- verrou d’édition entre deux scènes iPad
- comparaison du rendu canonique, notamment fond et éléments inférieurs visibles dans les zones non couvertes, entre éditeur, miniatures, lecture et PDF

## 30.3 Tests d’interface

`TST-008` — La suite d’interface et les procédures manuelles DOIVENT couvrir au minimum :

- iPhone portrait
- iPhone paysage
- iPad portrait
- iPad paysage
- iPad en fenêtre étroite
- mode clair et sombre
- Dynamic Type
- VoiceOver
- Réduire les animations
- ordre des cinq panneaux et adaptation iPhone/iPad
- garantie d’une seule page visible à toute largeur
- vue globale, réorganisation et retour vers la page choisie
- sélection, poignées et barre contextuelle de chaque type d’élément
- texte envoyé entièrement derrière une photo puis resélectionné sans changement de profondeur par le sélecteur de chevauchement et son action VoiceOver
- zoom par commandes et pincement, déplacement de fenêtre, restauration par page et priorité face au cadrage, aux transformations et à la navigation
- Zoom photo sous `1×`, valeur `0,5×`, réinitialisation à `1×` et distinction explicite avec le zoom du canevas
- symboles, libellés accessibles, ordre et états activés/désactivés des deux matrices de commandes
- sources Photothèque, Fichiers et Depuis vos autres albums, commande Supprimer de cet album activée ou désactivée et compteur d’occurrences
- modèles, confirmation Annuler/Appliquer d’un modèle plus petit, dé, mise en page automatique et remplissage
- navigation par boutons et gestes
- conflit entre transformation d’un élément et changement de page
- clavier, pointeur et trackpad
- navigation VoiceOver élément par élément et alternative au glisser-déposer
- PDF balisé vérifié avec un inspecteur d’accessibilité

## 30.4 Tests de compatibilité

`TST-003` — La suite DOIT être exécutée au minimum sur :

- la dernière mise à jour disponible d’iOS 26
- la dernière mise à jour disponible d’iPadOS 26
- la version iOS/iPadOS la plus récente prise en charge par l’environnement de build si elle est postérieure
- le plus ancien iPhone et le plus ancien iPad officiellement compatibles avec iOS/iPadOS 26 dans le parc de test

`TST-004` — Les tests visuels et d’accessibilité qui ne sont pas automatisables DOIVENT utiliser une procédure, un résultat attendu et une preuve enregistrée.

## 30.5 Campagne manuelle temporaire sur iPad

`TST-009` — Chaque commit candidat significatif testé pendant la phase A DOIT
faire l’objet d’une fiche de session conforme à `DEV-008`. Un test interrompu
ou impossible à exécuter est `BLOQUÉ` ou `NON TESTÉ`, jamais `RÉUSSI`.

`TST-010` — La vérification rapide suivante DOIT être rejouée sur chaque build
interne candidate :

- compilation sans erreur et lancement en plein écran
- ouverture de la bibliothèque et du dernier album
- création d’un album et d’au moins une page
- import d’une petite et d’une grande photo, placement de plusieurs occurrences, taille native centrée à `1×`, fond visible et dézoom à `0,5×`
- remplacement, retrait de contenu et suppression de cadre distincts, puis Supprimer de cet album désactivé avec une occurrence et confirmé/annulé à zéro occurrence
- réutilisation d’une photo depuis un autre album sans modifier l’album source
- modification de plusieurs textes, dont un passage derrière une photo suivi d’une resélection, et d’un sticker statique
- application d’un modèle plus petit avec annulation puis confirmation, du dé, de l’automatisme et de fonds par page
- passage par la vue globale en vérifiant qu’une seule page est éditée
- fermeture, passage en arrière-plan, terminaison de l’app puis relance
- vérification de la persistance après chaque relance
- lecture, navigation manuelle et diaporama
- export, partage et réimport des formats déjà implémentés
- portrait, paysage et fenêtre étroite
- modes clair et sombre
- une taille Dynamic Type élevée et un parcours VoiceOver essentiel
- Réduire les animations
- fonctionnement sans réseau pour les données locales
- annulation utilisateur et au moins un cas d’erreur pertinent

`TST-011` — Lorsqu’un chantier touche les photos, la campagne DOIT utiliser un
corpus non personnel avec HEIC, JPEG, PNG, RAW, Live Photo et HDR statique,
ainsi qu’un GIF, une vidéo, un fichier invalide, une image dépassant la limite
de pixels, une petite photo de `600 × 400`, une photo de `2 400 × 1 800` et
une photo de `4 800 × 6 000`. Elle DOIT couvrir import multiple, occurrences
multiples, remplacement, retrait de contenu, `1×` avec fond visible, `0,5×`,
conservation de l’original dans Photos, suppression refusée lorsqu’il est
utilisé puis confirmée et annulée à zéro occurrence, réutilisation entre deux
albums avec identités logiques distinctes et blob commun, suppression de cadre,
calcul de qualité et refus des formats animés. Les éléments indisponibles sont
inscrits dans le registre différé.

`TST-012` — Lorsqu’un chantier touche le stockage ou les documents, la campagne
DOIT vérifier la relance, l’import/export autonome d’une photo réutilisée, un
package valide, un package dégradé, l’annulation d’une suppression d’asset, la
non-purge d’un blob partagé, une photo manquante et un manque d’espace lorsque ce cas
peut être reproduit sans risque. Une interruption impossible à injecter
manuellement reste réservée à la section 30.6.

`TST-013` — La campagne iPad DOIT conserver, pour chaque scénario :

1. le résultat attendu et le résultat observé ;
2. l’un des états `RÉUSSI`, `ÉCHOUÉ`, `BLOQUÉ`, `NON TESTÉ` ou
   `NON APPLICABLE` ;
3. une capture, une vidéo, un journal ou une note expliquant pourquoi aucune
   preuve visuelle n’est pertinente ;
4. le lien de l’anomalie pour chaque échec ;
5. la liste cumulative des validations différées vers macOS/Xcode, iPhone ou
   un autre appareil.

## 30.6 Qualification différée avec macOS et Xcode

`TST-014` — Avant une version publique, et dès la première version viable sur
iPad lorsque l’environnement peut être réservé, la campagne ponctuelle
macOS/Xcode DOIT couvrir au minimum :

- ouverture du package ou projet sans configuration locale implicite
- compilation propre des configurations Debug et Release
- exécution des suites unitaires, d’intégration et d’interface Apple
- exécution de la matrice iPhone et iPad définie par `TST-003`
- reprise des contrôles `BLOQUÉ` et `NON TESTÉ` de la phase A
- validation de la signature, des entitlements, du type `.photoalbum`, de
  CloudKit et du retour OAuth applicables à la version
- tests d’interruption, de futures migrations publiées et de packages hostiles
- mesures Instruments de mémoire, CPU, énergie, stockage et temps de lancement
- inspection du PDF balisé et contrôles d’accessibilité indisponibles sur iPad
- archive Release, validation de l’archive et envoi TestFlight
- test de la build TestFlight sur iPad et sur au moins un iPhone compatible

`TST-015` — La campagne macOS/Xcode DOIT produire le commit exact, la version de
Xcode et des SDK, la destination de chaque test, les rapports de suites, les
mesures, les anomalies et la décision de publication.

`TST-016` — La disponibilité future d’un Mac NE DOIT PAS conduire à reporter
les tests de domaine compatibles Linux ni les vérifications manuelles
réalisables sur iPad au moment de chaque fonctionnalité.

---

# 31. Ordre de réalisation

## Lot 0 — Prototypes et contrats

- projet universel iOS/iPadOS 26
- prototype du canevas multiélément, hit-testing, ordre et guides
- prototype d’édition de texte Photoweb défini par `TXA-005`
- moteur pur de modèles, dé et mise en page automatique
- prototype d’animation de page interactive
- modèle du domaine et sérialisation canonique
- protocole transactionnel et injection de crash
- schéma `.photoalbum` avec fichiers d’exemple
- prototype CloudKit page par page
- matrice de traçabilité initiale
- registre initial des validations iPad et des validations différées

**Sortie :** les prototypes réalisables prouvent les risques principaux, les
formats sont relus et les décisions d’architecture sont enregistrées. Un
prototype impossible dans Swift Playgrounds reste explicitement bloqué et
rejoint la campagne macOS/Xcode ; il n’est pas réputé réussi.

## Lot 1 — Création locale

- bibliothèque, corbeille et albums
- éditeur à une seule page et vue globale
- pages, fonds par page et couverture par occurrence
- dépôt d’assets et journal transactionnel
- import multiple de photos statiques, cadres multiples et cadrage
- sauvegarde, presse-papiers, navigation et annulation

**Sortie :** `ACPT-100`, `ACPT-102` à `ACPT-104`, `ACPT-123`, `ACPT-124`,
`ACPT-127`, `ACPT-129` et `ACPT-130` passent.

## Lot 2 — Parité de composition Photoweb

- panneau Mise en page et catalogue de modèles
- dé, mise en page automatique et remplissage de l’album
- zones de texte multiples et mise en forme Photoweb
- stickers statiques intégrés
- formes, contours et cadres décoratifs
- gestes, clavier, ordre de profondeur et adaptation iPhone/iPad

**Sortie :** `ACPT-125`, `ACPT-126` et `ACPT-128` passent. Le rendu commun
reste vérifié intégralement par `ACPT-131` à la sortie du lot 3.

## Lot 3 — Consultation et documents

- mode lecture
- diaporama
- animation de page finalisée
- package modifiable et import sécurisé
- PDF accessible

**Sortie :** `ACPT-111` à `ACPT-115` et `ACPT-131` passent. Après le lot
Qualité correspondant, ce lot constitue la version publique 1.0.

## Lot 4 — Historique et CloudKit

- révisions et restauration
- zone et records CloudKit
- fusion page par page
- conflits multi-appareil
- corbeille synchronisée et téléchargements hors ligne

**Sortie :** `ACPT-117` à `ACPT-121` passent. Après le lot Qualité
correspondant, ce lot constitue la version publique 1.1.

## Lot 5 — Google Photos

- Google Sign-In
- Google Photos Picker API avec sélection multiple
- import de photos statiques uniquement
- reprise, expiration et déconnexion

**Sortie :** `ACPT-122` passe. Après le lot Qualité correspondant, ce lot constitue la version publique 1.2.

## Lot 6 — Qualité et publication

Ce lot s’exécute avant chaque version publique et comprend :

- accessibilité et PDF balisé
- localisation
- performance et tests de charge
- migrations des seuls formats déjà publiés, lorsqu’elles deviennent applicables
- sécurité des packages
- tests de reprise après interruption
- documentation et matrice de traçabilité
- reprise de toutes les validations différées de la phase iPad
- qualification macOS/Xcode définie par `TST-014` et `TST-015`

`LOT-001` — Chaque lot DOIT laisser le projet compilable, testable et démontrable.

`LOT-002` — Une version publique NE DOIT PAS être produite tant que son lot Qualité ne satisfait pas la définition de terminé.

`LOT-003` — Pendant la phase A, un lot PEUT fournir des incréments internes
partiellement qualifiés sur iPad si les validations manquantes sont identifiées
et si son état n’est pas présenté comme terminé.

`LOT-004` — Le lot Qualité d’une version publique NE DOIT PAS être déclaré
terminé avant la campagne macOS/Xcode et les tests iPhone applicables.

---

# 32. Livrables attendus du développement

`DEL-001` — Chaque version publique DOIT fournir les livrables applicables suivants :

- projet Xcode compilable
- application iPhone et iPad
- code source Swift formaté
- tests unitaires, intégration et interface
- catalogue d’assets de démonstration libres de droits
- schéma CloudKit documenté
- configuration Google documentée sans secret embarqué
- README d’installation
- README d’architecture
- description du format `.photoalbum`
- liste des limitations connues
- données d’exemple pour prévisualisations SwiftUI et tests
- matrice de traçabilité exigences–tests–versions
- corpus de packages valides, dégradés et malveillants, complété par les anciennes versions publiées lorsqu’elles existent
- décisions d’architecture du lot 0

---

# 33. Définition de terminé

`DONE-001` — Une fonctionnalité est terminée lorsque :

1. les exigences associées sont implémentées
2. les tests pertinents passent
3. l’interface fonctionne sur iPhone et iPad
4. le comportement hors ligne est vérifié
5. les erreurs sont traitées sans perte de données
6. les libellés sont localisés
7. toutes ses exigences d’accessibilité sont validées
8. aucune API privée n’est utilisée
9. aucune donnée sensible n’apparaît dans les journaux
10. la documentation est mise à jour

`DONE-002` — Un lot est terminé lorsque ses critères de sortie passent et que chaque exigence de son périmètre est couverte dans la matrice de traçabilité.

`DONE-003` — Une version publique est terminée lorsque tous ses lots, son lot Qualité, ses scénarios d’acceptation et toutes ses exigences associées sont validés.

`DONE-004` — Le passage des seuls scénarios d’acceptation NE SUFFIT PAS si une exigence normative associée reste sans validation.

`DONE-005` — Une version viable sur iPad constitue uniquement un candidat
interne. Elle NE DOIT PAS être confondue avec une fonctionnalité, un lot ou une
version publique terminée tant que les validations différées applicables ne
sont pas passées.

---

# 34. Références fonctionnelles Photoweb

Le relevé public a été effectué le **6 août 2026**. Les sources confirment le
vocabulaire et les fonctions accessibles publiquement ; lorsqu’un détail de
geste n’est pas publié, la règle déterministe des sections 7 à 13 est la
référence normative de l’application.

| Source officielle | Comportements retenus |
|---|---|
| https://www.photoweb.fr/assistance-editeur-de-livre | panneau Photos, photos utilisées, sauvegarde, organisation générale et restriction contradictoire des modèles au nombre de photos courant |
| https://www.photoweb.fr/questions-frequentes/est-ce-que-je-peux-supprimer-une-photo-/ | commande actuelle de suppression d’une photo téléchargée ; contradiction publique tranchée par `DEC-34` au profit d’une suppression confirmée uniquement à zéro occurrence dans l’album courant |
| https://www.photoweb.fr/questions-frequentes/est-ce-que-je-peux-r-utiliser-mes-photos-dans-une-autre-cration-/ | source Depuis vos créations précédentes lors d’un ajout ; contradiction publique tranchée par la source native Depuis vos autres albums de `DEC-37` |
| https://www.photoweb.fr/questions-frequentes/comment-changer-de-mise-en-page-/ | modèles, cadres vides, glisser-déposer, dé et mise en page automatique ; le retrait d’occurrences par un modèle plus petit suit la confirmation de `DEC-35` |
| https://www.photoweb.fr/questions-frequentes/je-souhaite-appliquer-un-liser--toutes-les-photos-comment-faire--/ | panneau Cadres et formes, contour et portées d’application |
| https://www.photoweb.fr/espaces/magazine/indicateur-qualite-photo/ | indicateur `OK`, `Acceptable`, `Insuffisante` et seuils de 300/150 ppp |
| https://www.photoweb.fr/espaces/magazine/livre-photo-avec-texte/ | plusieurs zones de texte libres, déplaçables, redimensionnables et rotatives ; police, taille et couleur |
| https://www.photoweb.fr/espaces/magazine/mise-en-page-album-photo/ | organisation historique de la profondeur et ancienne règle du texte au premier plan ; `DEC-36` retient explicitement une profondeur commune libre dans l’application |
| https://www.photoweb.fr/questions-frequentes/conseils-creation/ | couleur appliquée à tout ou partie d’un texte et avertissement de cadre photo vide |
| https://www.photoweb.fr/outil-creation-photo | organisation 2026, import et fonctions de création |
| https://www.photoweb.fr/les-evolutions-a-venir | fonds, stickers, formes, cadres et évolution 2026 |
| https://www.photoweb.fr/tuto-personnaliser-une-image | recadrage, contour, forme et cadre |
| https://www.photoweb.fr/media/wysiwyg/PW/FR/Pages-supports/Nouveautes/phoenix-mockup-2026-01.jpg | ordre des panneaux, commandes supérieures et bouton Texte observables |

`VIS-001` — Ces pages sont des références d’organisation et de comportement.
Le rendu final DOIT suivre les composants natifs d’iOS 26 plutôt qu’une copie
pixel par pixel.

`VIS-002` — La marque, les textes commerciaux, les prix, le bouton Commander,
les couleurs propres à Photoweb et ses assets de fonds, stickers, formes ou
cadres NE DOIVENT PAS être copiés sans autorisation.

`VIS-003` — La parité recherchée porte sur les comportements, l’organisation
des commandes et les intentions d’icônes. Les volumes commerciaux annoncés par
Photoweb, notamment plus de 250 fonds et 700 stickers en 2026, NE SONT PAS un
critère de parité de la version 1.0 ; les minima propres et licenciés de
`BG-001` et `STK-012` s’appliquent.

---

# 35. Références techniques officielles

- Apple — texte avec SwiftUI et `AttributedString` : https://developer.apple.com/documentation/swiftui/building-rich-swiftui-text-experiences
- Apple — `PhotosPicker` : https://developer.apple.com/documentation/photosui/photospicker
- Apple — glisser-déposer SwiftUI : https://developer.apple.com/documentation/swiftui/adopting-drag-and-drop-using-swiftui
- Apple — SF Symbols : https://developer.apple.com/sf-symbols/
- Apple — CloudKit : https://developer.apple.com/documentation/cloudkit
- Google — démarrage avec Photos Picker API : https://developers.google.com/photos/picker/guides/get-started-picker
- Google — sessions Photos Picker : https://developers.google.com/photos/picker/guides/sessions
- Google — récupération des médias sélectionnés : https://developers.google.com/photos/picker/guides/media-items
- Google — Google Sign-In pour iOS : https://developers.google.com/identity/sign-in/ios/start-integrating
