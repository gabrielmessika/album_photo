# Album Photo

Application iPhone et iPad de création d’albums photo et vidéo, développée en
Swift et SwiftUI.

Le produit permet de composer des albums contenant des médias, des commentaires
enrichis, des stickers et un fond commun, puis de les lire, de les présenter en
diaporama et de les exporter en PDF ou sous la forme d’un document
`.photoalbum`.

La spécification normative complète se trouve dans [`spec.md`](spec.md).
L’avancement, les risques, les validations et les prochaines actions sont tenus
à jour dans [`SUIVI_PROJET.md`](SUIVI_PROJET.md). Les campagnes manuelles à
effectuer et leurs résultats détaillés sont enregistrés dans
[`suivi_tests.md`](suivi_tests.md).

## État du projet

- Spécification : version 2.1, prête pour le développement avec validation iPad temporaire.
- Implémentation : lot 1 en cours, création locale et ajout de pages persistants.
- Cible minimale : iOS 26 et iPadOS 26.
- Projet d’application prévu : App Playground Swift au format `.swiftpm`.
- Dépôt GitHub :
  [`gabrielmessika/album_photo`](https://github.com/gabrielmessika/album_photo).

Les identifiants d’exigences de `spec.md` sont normatifs. Les branches, pull
requests, tests et comptes rendus de validation doivent citer les identifiants
concernés, par exemple `APP-001`, `LOC-004` ou `ACPT-100`.

## Versions prévues

| Version | Contenu |
|---|---|
| `1.0` | Création locale, médias, commentaires enrichis de base, stickers, lecture, diaporama, PDF et package modifiable |
| `1.1` | Listes de contrôle, tableaux, historique persistant et synchronisation CloudKit |
| `1.2` | Import depuis Google Photos |

Chaque lot doit rester compilable, testable et démontrable. L’ordre de
réalisation détaillé est défini dans la section 31 de `spec.md`.

## Le principe du développement hybride

Le dépôt GitHub est l’unique source de vérité. Le PC sert à écrire et
versionner le code. Pendant la première phase, l’iPad sert à compiler
l’App Playground, à tester manuellement les versions intermédiaires et, si
utile, à envoyer une build interne à App Store Connect. La qualification
complète avec macOS et Xcode est regroupée plus tard, lorsque l’application est
devenue viable sur iPad.

```text
Phase A — pendant les vacances, sans location de Mac

PC Windows + VS Code + WSL
        |
        | commit / push
        v
      GitHub
        |
        | pull ou téléchargement
        v
iPad + Swift Playgrounds
        |
        | build et campagne manuelle
        v
Prototype / build interne validé sur iPad

Phase B — session ponctuelle, après obtention d'une version viable

Commit candidat figé sur GitHub
        |
        v
macOS + Xcode -> tests différés -> archive
        |
        v
TestFlight iPad + iPhone -> App Review
```

### Responsabilité de chaque environnement

| Environnement | Ce qu’il permet | Ce qu’il ne permet pas |
|---|---|---|
| Windows + WSL | Édition, Git, revues, scripts, formatage et tests des modules Swift réellement multiplateformes | Compiler SwiftUI pour iOS, lancer un simulateur Apple, signer une app ou reproduire les SDK Apple |
| GitHub | Source de vérité, branches, pull requests, historique, sauvegarde et CI | Remplacer les tests sur appareil réel |
| Swift Playgrounds sur iPad | Compiler l’App Playground, afficher les previews, exécuter l’app sur iPad et envoyer une build à App Store Connect | Fournir Xcode, ses simulateurs, Instruments ou toute sa chaîne de tests automatisés |
| TestFlight | Installer la build distribuée sur iPhone et iPad | Remplacer les tests locaux rapides pendant le développement |
| macOS + Xcode ponctuel | Reprendre les tests différés, tester les simulateurs, les configurations Release, la signature, les entitlements, Instruments et l’archive | Remplacer les validations manuelles faites au fil du développement |

### Scénario retenu pendant les vacances

Il n’est pas prévu de louer un Mac en continu ni de travailler sur le code tous
les jours. Le développement avance par sessions indépendantes :

1. choisir un groupe cohérent de fonctionnalités et leurs scénarios
   d’acceptation ;
2. les développer et les tester sur le PC, puis pousser un commit identifiable
   sur GitHub ;
3. récupérer exactement ce commit sur l’iPad ;
4. exécuter les contrôles identifiés dans `suivi_tests.md` et communiquer
   chaque résultat avec son identifiant ;
5. corriger lors d’une session ultérieure si nécessaire ;
6. inscrire tout contrôle impossible dans le registre des validations
   différées de `SUIVI_PROJET.md`.

Le premier objectif n’est donc pas une release App Store, mais une **version
viable sur iPad**. Sur un même commit, elle doit au minimum permettre :

- de créer un album et une page ;
- d’ajouter une photo et une vidéo de test ;
- de modifier un commentaire et un sticker ;
- de fermer puis relancer l’app sans perdre les données ;
- de lire l’album et lancer le diaporama ;
- d’exporter puis réimporter les formats déjà implémentés ;
- de lister honnêtement les fonctions absentes ou bloquées.

Une fois ce jalon atteint, une seule session Mac plus dense peut être réservée
pour ouvrir le commit dans Xcode, exécuter la campagne différée, corriger les
écarts et produire une build TestFlight candidate. Il peut s’agir d’un Mac
distant loué à la demande, d’un Mac prêté ou de l’aide ponctuelle d’une
personne équipée. La location devient alors un coût de qualification limité,
pas un abonnement de développement.

Les résultats emploient toujours l’un des cinq états suivants :

| État | Signification |
|---|---|
| `RÉUSSI` | Le résultat attendu a été observé sur l’environnement enregistré |
| `ÉCHOUÉ` | Le test a été exécuté et une anomalie a été observée |
| `BLOQUÉ` | L’environnement ou une dépendance empêche le test |
| `NON TESTÉ` | Le contrôle n’a pas été exécuté pendant cette session |
| `NON APPLICABLE` | Le contrôle ne concerne pas encore le périmètre testé |

`BLOQUÉ` ne signifie jamais `RÉUSSI`. Un résultat iPad ne vaut pas validation
iPhone ou Xcode.

Une erreur telle que `no such module 'SwiftUI'` sous WSL est donc normale :
SwiftUI, PhotosUI, CloudKit et les autres frameworks Apple ne font pas partie du
SDK Linux.

## Limites à connaître avant de commencer

Ce projet est sensiblement plus ambitieux qu’un App Playground classique.
Trois validations du lot 0 sont des conditions de poursuite.

1. **CloudKit en version 1.1.** La liste officielle des capacités actuellement
   prises en charge par Swift Playgrounds ne contient pas iCloud/CloudKit.
   CloudKit exige en outre des entitlements, un conteneur iCloud et les
   notifications push. Il faut vérifier cette capacité sur la version exacte de
   Swift Playgrounds utilisée. Si elle reste absente, la version 1.1 ne pourra
   pas être signée correctement uniquement depuis l’iPad.
2. **Document `.photoalbum` en version 1.0.** Le lot 0 doit prouver que l’App
   Playground peut déclarer le type de document package, son UTType exporté et
   son rôle `Editor`, puis ouvrir le document depuis Fichiers et la feuille de
   partage.
3. **OAuth Google en version 1.2.** Le lot 0 ou le début du lot 5 doit vérifier
   la configuration du schéma d’URL de retour et des paramètres de build sans
   secret.

Si l’un de ces réglages n’est pas exposé par Swift Playgrounds, il ne faut pas
le contourner avec une API privée ni interrompre tout le développement. Le
contrôle reçoit l’état `BLOQUÉ`, la couche concernée reste isolée par protocole
et le travail compatible iPad continue. Le blocage rejoint la campagne
macOS/Xcode ponctuelle organisée après la première version viable. Si la
capacité demeure impossible à valider pendant cette campagne, la version
publique concernée reste bloquée.

L’iPad ne simule pas un iPhone. Avant toute version publique, il faut au minimum
un testeur possédant un iPhone compatible avec iOS 26 et installé via
TestFlight. Sans iPhone ni environnement Xcode distant, les exigences iPhone de
`TST-003`, `TST-004` et `TST-008` ne peuvent pas être déclarées validées.

## Prérequis

### Sur le PC

- Windows 11 à jour ;
- WSL 2 avec Ubuntu ;
- Visual Studio Code installé côté Windows ;
- extensions VS Code **WSL** et **Swift** ;
- Git ;
- Swift pour Linux, utile uniquement pour le code multiplateforme ;
- un compte GitHub ayant accès au dépôt.

### Sur l’iPad

- un iPad compatible avec iPadOS 26 ;
- la dernière version stable de Swift Playgrounds ;
- l’app Fichiers ;
- l’app TestFlight pour tester les builds distribuées ;
- suffisamment d’espace libre pour les médias, les dépendances et les builds ;
- facultatif mais pratique : un clavier, un pointeur ou un trackpad ;
- facultatif : Working Copy pour faire du Git directement sur iPad.

### Pour TestFlight et l’App Store

- un Apple Account avec authentification à deux facteurs ;
- une adhésion active à l’Apple Developer Program ;
- l’accès à
  [App Store Connect](https://appstoreconnect.apple.com/) ;
- un identifiant de bundle définitif, par exemple
  `com.votredomaine.AlbumPhoto` ;
- une icône personnalisée, et non l’une des icônes temporaires de Swift
  Playgrounds ;
- une politique de confidentialité publiée à une URL stable ;
- au moins un iPhone physique de test pour valider la cible iPhone.

Ne jamais utiliser l’exemple `com.votredomaine.AlbumPhoto` pour une build de
distribution. L’identifiant choisi doit être unique, stable et identique dans
Swift Playgrounds, le portail Developer et App Store Connect.

## Installation du poste Windows/WSL

### 1. Installer WSL 2

Ouvrir PowerShell en administrateur :

```powershell
wsl --install -d Ubuntu
```

Redémarrer Windows si demandé, lancer Ubuntu, puis créer l’utilisateur Linux.
Vérifier ensuite dans PowerShell :

```powershell
wsl --status
wsl --list --verbose
```

La distribution Ubuntu doit utiliser la version `2`.

### 2. Installer VS Code

Installer Visual Studio Code sous Windows, avec l’option d’ajout de `code` au
`PATH`. Installer ensuite :

- [WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) ;
- [Swift](https://marketplace.visualstudio.com/items?itemName=swiftlang.swift-vscode).

L’extension Swift doit apparaître comme installée dans l’environnement
**WSL: Ubuntu**, car c’est là que se trouvera la toolchain.

### 3. Installer les outils Linux

Dans le terminal Ubuntu :

```bash
sudo apt update
sudo apt install -y ca-certificates curl git unzip
```

Installer Swift avec `swiftly` en suivant la commande courante publiée sur la
page officielle [Installer Swift sous
Linux](https://www.swift.org/install/linux/). L’installateur signale les
paquets Ubuntu supplémentaires éventuellement requis.

Ouvrir un nouveau terminal, puis vérifier :

```bash
git --version
swift --version
```

Il n’est pas nécessaire de faire correspondre artificiellement le numéro de la
toolchain Linux à celui du SDK Apple. La version réellement décisive pour
l’application est celle embarquée par Swift Playgrounds.

### 4. Configurer Git

```bash
git config --global user.name "Votre Nom"
git config --global user.email "adresse-associee-a-github@example.com"
git config --global core.autocrlf input
git config --global init.defaultBranch main
```

`core.autocrlf input` conserve les fins de ligne LF attendues dans le dépôt
tout en travaillant depuis Windows.

Configurer ensuite une authentification GitHub par clé SSH ou gestionnaire
d’identifiants. Ne jamais mettre de token GitHub dans l’URL du remote, un
script, un fichier de configuration versionné ou le README.

### 5. Cloner le dépôt dans le système de fichiers WSL

Stocker le dépôt dans le système de fichiers Linux, et non dans `/mnt/c`, donne
de meilleures performances à Git, aux extensions et aux observateurs de
fichiers.

```bash
mkdir -p ~/src
cd ~/src
git clone https://github.com/gabrielmessika/album_photo.git
cd album_photo
code album_photo.code-workspace
```

Dans VS Code, l’indicateur en bas à gauche doit afficher `WSL: Ubuntu`.

## Structure cible du dépôt

Le lot 0 doit créer et stabiliser la structure réelle. La direction attendue
est la suivante :

```text
album_photo/
├── Package.swift                # package multiplateforme AlbumPhotoCore
├── AlbumPhoto.swiftpm/          # App Playground compilé sur l’iPad
│   ├── Package.swift            # généré/maintenu par Swift Playgrounds
│   ├── Sources/
│   └── Resources/
├── Sources/
│   └── AlbumPhotoCore/          # domaine Swift sans SwiftUI si extrait
├── Tests/
│   └── AlbumPhotoCoreTests/     # tests exécutables sous WSL
├── docs/
│   ├── architecture/
│   ├── decisions/
│   ├── test-runs/
│   └── traceability/
├── spec.md
└── README.md
```

La séparation d’un paquet `AlbumPhotoCore` multiplateforme est recommandée pour
tester sous WSL :

- modèles du domaine ;
- invariants et validation ;
- commandes pures ;
- sérialisation canonique ;
- calculs de géométrie indépendants de SwiftUI ;
- règles de fusion et d’idempotence.

Les adaptateurs Apple restent dans l’App Playground :

- SwiftUI et UIKit ;
- PhotosUI ;
- AVFoundation et AVKit ;
- CloudKit ;
- PDFKit ;
- UniformTypeIdentifiers ;
- Keychain et autres services Apple.

Le mode exact d’intégration de `AlbumPhotoCore` dans l’App Playground doit être
figé pendant le lot 0. Swift Playgrounds sait ajouter un package Swift public
par URL. Si le package est fourni par ce même dépôt, utiliser une branche
explicitement choisie pendant le développement et verrouiller la révision
résolue pour une build de publication. Une éventuelle version Git du noyau doit
être créée avant la build qui la consomme. Ne pas dupliquer les sources entre
le paquet et l’app.

## Création initiale de l’App Playground

Cette opération n’est faite qu’une fois, au lot 0.

### 1. Créer le document sur l’iPad

Dans Swift Playgrounds :

1. toucher **Nouveau playground** ;
2. choisir **App** ;
3. nommer le projet `AlbumPhoto` ;
4. ouvrir les **Réglages de l’app** ;
5. activer les familles iPhone et iPad si ce choix est proposé ;
6. choisir iOS/iPadOS 26 comme version minimale ;
7. conserver un numéro de version `0.1.0` et un build `1` pour le prototype ;
8. saisir l’identifiant de bundle définitif ;
9. ajouter uniquement les capacités réellement utilisées et une justification
   en français compréhensible par l’utilisateur ;
10. exécuter l’app vide en plein écran.

L’import de médias de la version 1.0 passe par le sélecteur système. Ne pas
ajouter la capacité Caméra : la capture directe est hors périmètre
(`SCP-001`). Une autorisation Photothèque ne doit être ajoutée que si l’API
réellement utilisée l’exige.

### 2. Copier le document vers le PC

Le document créé est un package nommé `AlbumPhoto.swiftpm`.

Sans client Git sur iPad :

1. fermer le projet dans Swift Playgrounds ;
2. depuis l’écran d’accueil, sélectionner le projet et le partager vers
   **Fichiers** ;
3. l’enregistrer dans iCloud Drive ;
4. si Windows ne voit pas le package comme un seul document, effectuer un appui
   long dans Fichiers puis choisir **Compresser** ;
5. télécharger le document ou son ZIP depuis iCloud Drive sur le PC ;
6. le placer dans la racine du dépôt WSL sous le nom
   `AlbumPhoto.swiftpm` ;
7. vérifier que `Package.swift` se trouve directement dans ce dossier, et non
   dans un second dossier imbriqué de même nom.

Exemple si un ZIP a été téléchargé dans le dossier Windows `Downloads` :

```bash
cd ~/src/album_photo
unzip /mnt/c/Users/VOTRE_COMPTE/Downloads/AlbumPhoto.swiftpm.zip
find AlbumPhoto.swiftpm -maxdepth 2 -type f | sort
```

Adapter le chemin Windows. Contrôler le résultat avant tout déplacement ou
suppression.

Avec Working Copy :

1. connecter Working Copy à GitHub ;
2. cloner `gabrielmessika/album_photo` ;
3. partager le document `AlbumPhoto.swiftpm` depuis Swift Playgrounds vers la
   racine de ce clone ;
4. vérifier les fichiers détectés ;
5. créer un commit `chore: bootstrap Swift Playground app` ;
6. pousser ce commit sur une branche et l’intégrer par pull request.

L’édition en place d’un document externe et le lien d’un document package sont
des fonctions avancées de Working Copy. Fermer Swift Playgrounds avant un
pull, un remplacement ou un changement massif de fichiers : deux apps ne
doivent jamais modifier simultanément le même package.

### 3. Versionner le squelette

Sur le PC :

```bash
cd ~/src/album_photo
git switch -c chore/bootstrap-app-playground
git status
git add AlbumPhoto.swiftpm
git diff --cached
git commit -m "chore: bootstrap Swift Playground app"
git push -u origin chore/bootstrap-app-playground
```

Créer une pull request, contrôler que le package ne contient ni secret, ni
cache, ni média personnel, puis fusionner.

Le `Package.swift` de l’App Playground est généré par Swift Playgrounds.
Modifier les réglages de l’app depuis Swift Playgrounds puis versionner le
résultat est préférable à une modification manuelle susceptible d’être
écrasée.

## Cycle de travail d’une session disponible

### Étape A — commencer une tâche sur le PC

```bash
cd ~/src/album_photo
git switch main
git pull --ff-only
git switch -c feat/ACPT-100-creation-album
```

Utiliser une branche courte contenant l’identifiant principal de l’exigence :

- `feat/ACPT-100-creation-album` ;
- `fix/LOC-004-atomic-write` ;
- `test/PKG-002-document-package` ;
- `docs/ARC-003-domain-boundary`.

### Étape B — développer dans VS Code

Les vues ne doivent pas écrire directement dans la base. Le domaine ne doit pas
dépendre de SwiftUI. Les services Apple doivent être injectés par protocole,
conformément à `ARC-001` à `ARC-008`.

Pour un package Swift multiplateforme présent à la racine :

```bash
swift package resolve
swift build
swift test
```

Si le package de domaine possède son propre manifeste :

```bash
swift test --package-path CHEMIN_DU_PACKAGE
```

Ces commandes ne valident que les cibles compatibles Linux. Elles ne doivent
pas être utilisées comme preuve que l’app iOS compile.

Avant le commit :

```bash
git status
git diff --check
git diff
swift test
```

Ne lancer `swift test` que lorsqu’un package multiplateforme testable existe.

### Étape C — pousser et faire relire

```bash
git add CHEMINS_MODIFIES
git commit -m "feat: implement album creation (ACPT-100)"
git push -u origin feat/ACPT-100-creation-album
```

La pull request doit contenir :

- les exigences et scénarios concernés ;
- le comportement implémenté ;
- les tests automatiques exécutés sous WSL ;
- les vérifications restant à faire sur iPad ou iPhone ;
- les migrations ou risques de perte de données ;
- les captures ou preuves manuelles lorsqu’elles existent.

Fusionner dans `main` uniquement après les contrôles disponibles. Utiliser
`--ff-only` lors des pulls ordinaires pour éviter un commit de fusion local
accidentel.

### Étape D — récupérer la version sur l’iPad

Deux méthodes sont prévues.

#### Méthode recommandée : Working Copy

1. fermer `AlbumPhoto` dans Swift Playgrounds ;
2. ouvrir Working Copy et sélectionner le dépôt ;
3. vérifier qu’aucun fichier iPad non sauvegardé n’est présent ;
4. faire **Fetch**, puis **Pull** sur `main` ;
5. vérifier le hash du commit reçu ;
6. copier ou partager `AlbumPhoto.swiftpm` vers l’emplacement utilisé par
   Swift Playgrounds ;
7. remplacer l’ancienne copie de test seulement après avoir confirmé que les
   réglages ou changements utiles de celle-ci sont déjà dans Git ;
8. ouvrir la nouvelle copie dans Swift Playgrounds.

Si le document est lié en tant que dépôt externe avec Working Copy Pro, le pull
peut écrire directement dans le package. Swift Playgrounds doit être fermé
pendant l’opération. La documentation Working Copy avertit que certaines apps
peuvent être perturbées si leurs documents changent pendant qu’elles sont
ouvertes.

#### Méthode gratuite : ZIP GitHub

Cette méthode convient très bien si le code est toujours modifié sur le PC.

1. sur l’iPad, ouvrir le dépôt GitHub dans Safari ;
2. vérifier que la branche affichée est `main` ;
3. toucher **Code**, puis **Download ZIP** ;
4. ouvrir le téléchargement dans Fichiers ;
5. toucher le ZIP pour le décompresser ;
6. ouvrir le dossier extrait puis toucher `AlbumPhoto.swiftpm` ;
7. laisser Swift Playgrounds importer ou ouvrir le projet ;
8. renommer la copie de test avec le hash court si nécessaire, par exemple
   `AlbumPhoto-a1b2c3d`, afin d’éviter toute confusion ;
9. supprimer les anciennes copies uniquement après validation de la nouvelle.

Le ZIP GitHub est un transport, pas une nouvelle source de vérité. Ne jamais
réinjecter l’ensemble du ZIP dans le dépôt.

### Étape E — compiler et tester sur l’iPad

Dans Swift Playgrounds :

1. attendre la résolution complète des packages ;
2. ouvrir la liste des problèmes et corriger toute erreur de compilation ;
3. contrôler la preview ;
4. toucher **Exécuter l’app** pour un test en plein écran ;
5. exécuter le parcours principal touché par le commit ;
6. passer l’app en arrière-plan, la terminer, la relancer et vérifier la
   persistance ;
7. tester portrait, paysage et une fenêtre étroite ou Split View ;
8. tester mode clair et sombre ;
9. tester une grande taille Dynamic Type, VoiceOver et Réduire les animations ;
10. tester avec puis sans réseau ;
11. vérifier l’annulation et au moins un cas d’erreur ou d’annulation
    utilisateur ;
12. pour les médias, utiliser au moins une photo et une vidéo non sensibles ;
13. tester lecture, diaporama et les imports/exports déjà implémentés ;
14. relever le hash Git, la copie ou le numéro de build, le modèle d’iPad, la
    version d’iPadOS et la version de Swift Playgrounds.

Pour un lot donné, suivre les scénarios d’acceptation de la section 29 de
`spec.md` et la campagne de la section 30.5, pas seulement un parcours de
démonstration heureux. Lorsqu’une fonctionnalité touche les médias, les
documents, le stockage, la vidéo ou l’accessibilité, exécuter aussi la
sous-checklist correspondante de `TST-011` à `TST-013`.

Un compte rendu manuel doit être ajouté sous une forme similaire à :

```text
Commit : a1b2c3d
Copie/build : AlbumPhoto-a1b2c3d / build interne 12
Appareil : iPad ...
Système : iPadOS 26.x
Swift Playgrounds : x.y
Scénario : ACPT-100
Résultat attendu : ...
Résultat observé : ...
État : RÉUSSI / ÉCHOUÉ / BLOQUÉ / NON TESTÉ / NON APPLICABLE
Preuve : lien vers capture ou vidéo
Anomalie : lien vers issue GitHub, si applicable
Validations différées : iPhone, Xcode, Instruments, PDF, entitlements...
```

Ajouter cette fiche à l’historique des validations dans `SUIVI_PROJET.md` ou
dans un document de campagne lié depuis celui-ci. Une longue interruption entre
deux sessions ne change pas la procédure : repartir de `main`, noter le commit
et ne pas se fier au nom d’une ancienne copie iPad.

### Étape F — signaler un échec

Créer une issue GitHub contenant :

- le commit exact ;
- le résultat attendu et le résultat obtenu ;
- les étapes minimales de reproduction ;
- le modèle d’appareil et les versions logicielles ;
- la présence ou non du réseau et d’iCloud ;
- une capture, une vidéo ou le backtrace affiché par Swift Playgrounds ;
- l’identifiant de l’exigence touchée.

Corriger ensuite sur une nouvelle branche depuis le PC. Éviter les corrections
durables directement sur l’iPad.

### En cas de correction urgente sur l’iPad

1. partir de la dernière version de `main` ;
2. modifier uniquement les fichiers nécessaires ;
3. fermer Swift Playgrounds ;
4. partager ou synchroniser le package vers Working Copy ;
5. vérifier le diff ;
6. créer une branche `fix/...`, puis commit et push ;
7. ouvrir une pull request ;
8. sur le PC, faire un pull avant toute nouvelle modification.

Ne jamais modifier en parallèle la copie PC et la copie iPad. GitHub tranche :
une modification absente d’un commit poussé est considérée comme temporaire.

## Stratégie de tests sans Mac

Pendant la phase temporaire, les tests sont répartis en trois registres :

- **exécutables maintenant** : tests de domaine sous WSL et contrôles manuels
  sur l’iPad ;
- **échoués** : anomalies à corriger, avec un commit et une reproduction ;
- **différés** : contrôles impossibles sans iPhone, Xcode, simulateur,
  Instruments, entitlements ou inspecteur adapté.

Ce classement évite qu’un contrôle soit oublié pendant une période sans
activité. Chaque nouvelle validation différée doit être ajoutée à
`SUIVI_PROJET.md`, puis cochée lors de la campagne macOS/Xcode.

### Tests possibles sous WSL

Les tests unitaires du domaine doivent être écrits avant ou en même temps que
la fonctionnalité (`DEV-006`, `TST-002`). Pour les exécuter sous Linux, le code
testé ne doit pas importer de framework Apple.

Exemples :

- validation du nom d’album ;
- ordre, ajout et suppression des pages ;
- interdiction de supprimer la dernière page ;
- sérialisation canonique ;
- normalisation du cadrage ;
- contraintes géométriques des stickers ;
- validation de manifeste et de chemins ;
- calcul d’empreintes avec une abstraction multiplateforme ;
- migrations de données pures ;
- règles de fusion.

### Tests à faire sur l’iPad

- compilation de l’app complète ;
- navigation et gestes ;
- import PhotosUI ;
- rendu SwiftUI ;
- vidéo et mode silencieux ;
- stockage dans le sandbox ;
- orientation, fenêtres et accessibilité ;
- export, partage et réimport de documents ;
- fonctionnement hors ligne.

### Tests à faire sur iPhone avec TestFlight

- lancement et navigation sur écran étroit ;
- portrait et paysage ;
- sélection de médias ;
- lecture vidéo ;
- Dynamic Type et VoiceOver ;
- import/export avec Fichiers ;
- performance sur le plus ancien appareil du parc de test.

### Ce que l’iPad seul ne couvre pas

La définition de terminé de `spec.md` demande aussi des tests unitaires,
d’intégration et d’interface automatisés, plusieurs tailles d’iPhone et
d’iPad, des tests d’interruption, des inspections d’accessibilité PDF et des
tests de performance. Swift Playgrounds sur un seul iPad ne suffit pas à
fournir toutes ces preuves.

Il n’est pas nécessaire de louer un Mac pendant les premières itérations. Le
scénario retenu consiste à attendre une version viable sur iPad, puis à
réserver une qualification ponctuelle avec Xcode. Cette campagne doit reprendre
la liste différée et couvrir au minimum :

- ouverture du package ou projet et builds Debug/Release ;
- tests unitaires, d’intégration et d’interface Apple ;
- simulateurs iPhone et iPad, puis au moins un iPhone physique via TestFlight ;
- signature, entitlements, CloudKit, `.photoalbum` et OAuth applicables ;
- interruptions, migrations et packages hostiles ;
- mesures Instruments et inspection de l’accessibilité PDF ;
- archive Release et validation de la build distribuée.

Une CI macOS compatible, un Mac prêté ou l’intervention ponctuelle d’un
développeur équipé peuvent compléter ou remplacer le Mac distant, à condition
de produire les mêmes preuves. Une procédure manuelle ne remplace un test
automatisé que si `spec.md` l’autorise.

Une GitHub Action Linux peut exécuter les tests de domaine. Elle ne transforme
pas Linux en environnement iOS. Une GitHub Action macOS doit être traitée comme
un environnement Xcode à part entière, avec versions épinglées et sans secrets
imprimés dans les logs.

## Préparer une build TestFlight

Une build TestFlight précoce peut servir à des essais internes. Elle reste une
build de phase A et ses limites doivent être inscrites dans les notes de test.
Une build candidate à une publication publique ne peut être retenue qu’après la
campagne macOS/Xcode de `TST-014` à `TST-016`.

### 1. Créer l’app dans App Store Connect

Avant le premier upload :

1. se connecter à App Store Connect depuis Safari ;
2. ouvrir **Apps** puis **Nouvelle app** ;
3. choisir la plateforme iOS ;
4. saisir le nom, la langue principale et un SKU interne ;
5. sélectionner le bundle ID définitif ;
6. vérifier que les contrats Apple en attente sont acceptés.

Le bundle ID doit être strictement identique à celui de l’App Playground.

### 2. Geler un commit de build

Sur le PC :

```bash
git switch main
git pull --ff-only
git status
git rev-parse HEAD
```

Le statut doit être propre. Noter le hash complet dans les notes de build et
transférer précisément ce commit vers l’iPad.

### 3. Régler la build sur l’iPad

Dans **Réglages de l’app** de Swift Playgrounds :

1. choisir une icône personnalisée ;
2. vérifier le nom public ;
3. vérifier la version minimale ;
4. vérifier les familles iPhone et iPad ;
5. vérifier le bundle ID et l’équipe ;
6. saisir la version marketing, par exemple `1.0.0` ;
7. saisir un numéro de build entier strictement supérieur au précédent ;
8. vérifier chaque capacité et sa phrase d’explication ;
9. compiler et exécuter une dernière fois.

Après une modification des Réglages de l’app, renvoyer le package vers GitHub
et versionner le `Package.swift` généré avant l’upload final. Cela garantit que
la build distribuée reste reproductible.

### 4. Envoyer à App Store Connect

Toujours depuis **Réglages de l’app** :

1. se connecter avec l’Apple Account membre de l’équipe ;
2. vérifier équipe, bundle ID, version, build et catégorie ;
3. choisir **Télécharger vers App Store Connect** ;
4. attendre la fin de l’envoi ;
5. ouvrir App Store Connect et attendre le traitement de la build.

Ne pas relancer un upload avec le même numéro de build. En cas de correction,
incrémenter le build.

### 5. Distribuer avec TestFlight

Dans App Store Connect :

1. ouvrir l’onglet **TestFlight** ;
2. sélectionner la build traitée ;
3. renseigner les informations de conformité demandées ;
4. ajouter la build à un groupe de test ;
5. pour un test interne, inviter les utilisateurs App Store Connect autorisés ;
6. pour un test externe, créer un groupe, ajouter les testeurs et soumettre la
   première build à la Beta App Review ;
7. installer la build depuis l’app TestFlight sur l’iPad et au moins un
   iPhone ;
8. exécuter les scénarios applicables et archiver les preuves.

Une build lancée dans Swift Playgrounds n’est pas la build distribuée. Il faut
également tester la variante installée depuis TestFlight.

## Publier sur l’App Store

La première version publique ne doit être soumise qu’après les lots 0 à 3 et le
lot Qualité correspondant. Elle doit aussi avoir passé la qualification
macOS/Xcode, tous les contrôles différés applicables et un test TestFlight sur
iPad et sur au moins un iPhone. Une version « viable sur iPad » n’est pas
encore une version publiable.

Dans App Store Connect :

1. compléter le nom, le sous-titre, la description, les mots-clés et la
   catégorie ;
2. fournir les captures demandées pour les appareils pris en charge ;
3. ajouter l’URL d’assistance et l’URL de politique de confidentialité, cette
   dernière devant aussi être facilement accessible dans l’app ;
4. remplir honnêtement les informations de confidentialité, y compris pour les
   SDK tiers ;
5. répondre aux questions de classification d’âge et de conformité ;
6. renseigner un contact App Review ;
7. fournir des instructions de test pour les fonctions difficiles à trouver ;
8. sélectionner la build TestFlight validée ;
9. vérifier les limitations connues ;
10. choisir **Ajouter pour vérification**, puis **Soumettre pour vérification**.

Pour la version 1.1, expliquer à App Review le comportement local d’abord,
l’usage de la base privée CloudKit et la conduite de l’app sans compte iCloud.
Pour la version 1.2, fournir si nécessaire un compte ou un parcours de test
Google conforme aux règles d’App Review.

Après confirmation de la build réellement envoyée, créer un tag depuis le PC :

```bash
git switch main
git pull --ff-only
git tag -a v1.0.0-build.42 -m "Album Photo 1.0.0 build 42"
git push origin v1.0.0-build.42
```

Adapter les numéros. Le tag doit pointer vers le commit exact correspondant à
la build, pas vers un commit de documentation ultérieur.

## Règles de versionnement

- `main` doit toujours représenter la dernière version intégrée.
- Une fonctionnalité ou correction correspond à une branche et une pull
  request.
- Le numéro de version public suit `MAJEUR.MINEUR.CORRECTIF`.
- Le numéro de build App Store Connect est un entier croissant.
- Chaque build TestFlight doit référencer un hash Git.
- Les releases publiques reçoivent un tag annoté.
- `Package.resolved` doit être versionné pour les builds reproductibles.
- Les caches `.build`, archives `.ipa`, symboles et données personnelles ne
  doivent pas être commités.

## Secrets et configuration

Ne jamais versionner :

- mot de passe Apple ou GitHub ;
- token d’accès personnel GitHub ;
- clé privée SSH ;
- clé privée App Store Connect ;
- secret OAuth Google ;
- token Google d’un utilisateur ;
- certificat ou profil de signature exporté ;
- média personnel utilisé pendant les tests ;
- export CloudKit contenant des données réelles.

Les identifiants publics peuvent être versionnés uniquement lorsque les
recommandations du fournisseur l’autorisent. Aucun secret serveur ne doit être
embarqué dans l’app (`CFG-003`).

Les configurations développement et production doivent être distinctes. Une
build de distribution doit échouer si le bundle ID reste un placeholder ou si
une configuration obligatoire est absente (`CFG-005`, `CFG-006`).

## Diagnostic rapide

### `no such module 'SwiftUI'` sous WSL

C’est attendu. Compiler l’App Playground sur l’iPad. Extraire le code pur dans
un package multiplateforme si ce code doit être testé sous WSL.

### Le projet ne s’ouvre pas sur l’iPad

Vérifier :

- que le dossier porte bien l’extension `.swiftpm` ;
- que `Package.swift` est à la racine du package ;
- que le ZIP GitHub a été décompressé ;
- qu’il reste assez d’espace ;
- que la version de Swift Playgrounds est à jour ;
- qu’aucun package n’est encore en cours de téléchargement.

Fermer puis rouvrir Swift Playgrounds, et redémarrer l’iPad seulement après ces
contrôles.

### La version iPad ne correspond pas au dernier commit

Comparer :

```bash
git rev-parse --short HEAD
```

avec le hash noté lors du transfert. Supprimer la copie de test obsolète et
réimporter le package du bon commit.

### Un pull Working Copy crée un conflit

Ne pas choisir arbitrairement une version :

1. conserver les deux états ;
2. pousser la modification iPad sur une branche distincte si possible ;
3. résoudre et tester le conflit sur le PC ;
4. pousser le commit résolu ;
5. fermer Swift Playgrounds puis récupérer cette version propre sur l’iPad.

### L’upload App Store Connect échoue

Contrôler en priorité :

- adhésion Developer active et contrats acceptés ;
- App Store Connect record créé ;
- bundle ID identique partout ;
- icône personnalisée ;
- numéro de build inédit ;
- phrases d’usage présentes pour les capacités protégées ;
- configuration et entitlements pris en charge par Swift Playgrounds.

### Une fonction requiert une capacité absente

Ne pas forcer la signature et ne pas utiliser d’API privée. Ouvrir une issue
`toolchain-blocker`, citer l’exigence, enregistrer la version des outils et
marquer le test `BLOQUÉ`. Isoler la fonction, poursuivre le périmètre
compatible, puis ajouter ce contrôle à la campagne Xcode ponctuelle. Une
révision de la spécification n’est envisagée qu’après avoir reproduit le
blocage dans un environnement approprié.

## Références officielles

- [Swift Playgrounds — Apple Developer](https://developer.apple.com/swift-playground/)
- [Créer une app dans Swift Playgrounds sur iPad](https://support.apple.com/guide/playgrounds-ipad/create-an-app-playground-itc2207c0870/ipados)
- [Exécuter une app dans Swift Playgrounds](https://support.apple.com/guide/playgrounds-ipad/run-your-app-itc650868b1f/ipados)
- [Ajouter des fichiers, images et packages Swift](https://support.apple.com/guide/playgrounds-ipad/add-swift-files-images-and-swift-packages-itc18b7bce9d/ipados)
- [Capacités prises en charge par les App Playgrounds](https://developer.apple.com/documentation/swift-playgrounds/project-capabilities)
- [Envoyer une app à App Store Connect depuis Swift Playgrounds](https://support.apple.com/guide/playgrounds-ipad/share-a-playground-itc65b2d9a15/ipados)
- [Installer Swift sous Linux](https://www.swift.org/install/linux/)
- [Développer dans WSL avec VS Code](https://code.visualstudio.com/docs/remote/wsl)
- [Ajouter une app dans App Store Connect](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app/)
- [Tester avec TestFlight](https://developer.apple.com/testflight/)
- [Soumettre une app à App Review](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app/)
- [Informations de confidentialité App Store](https://developer.apple.com/app-store/app-privacy-details/)
- [Guide Working Copy — dépôts externes et Swift Playgrounds](https://workingcopyapp.com/manual/cloning-repos/)

## Licence

Aucune licence de redistribution n’est encore définie. Sauf indication
contraire dans un futur fichier `LICENSE`, tous les droits restent réservés.
