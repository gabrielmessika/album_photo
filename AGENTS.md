# Instructions pour Codex

Ces instructions s’appliquent à tout le dépôt `album_photo`.

## Documents de référence

- [`spec.md`](spec.md) est la source normative des exigences produit et
  techniques.
- [`README.md`](README.md) décrit l’installation et le fonctionnement hybride
  Windows/WSL, GitHub et iPad.
- [`SUIVI_PROJET.md`](SUIVI_PROJET.md) est le tableau de bord opérationnel.
- [`suivi_tests.md`](suivi_tests.md) est le registre détaillé des campagnes
  manuelles et de leurs résultats par commit et environnement.

Lire les sections pertinentes de ces quatre documents avant toute modification.
Ne pas simplifier, remplacer ou supprimer une exigence normative sans demande
explicite de l’utilisateur et sans documenter la décision.

## Mise à jour obligatoire du suivi

Toute modification du dépôt doit inclure une mise à jour cohérente de
`SUIVI_PROJET.md` dans le même changement. Cette règle s’applique au code, aux
tests, à la documentation, aux configurations, aux assets, aux scripts et aux
correctifs mineurs.

Avant de terminer une tâche :

1. actualiser la date et la phase courante si elles ont changé ;
2. mettre à jour l’état des tâches affectées ;
3. consigner les tests et validations réellement exécutés ;
4. indiquer explicitement les tests non exécutés et pourquoi ;
5. enregistrer les nouveaux risques, blocages, anomalies et décisions ;
6. mettre à jour les prochaines actions si leur ordre a changé ;
7. ajouter une ligne concise en haut du journal des mises à jour avec les
   fichiers et exigences concernés.

Si une modification ne change pas l’avancement fonctionnel, laisser les états
inchangés mais journaliser tout de même la nature du changement et sa
validation.

Ne jamais marquer une tâche 🟢 sur la seule base d’un code écrit :

- une implémentation partielle ou non testée reste 🟡 ;
- une dépendance manquante ou une impossibilité reproductible passe à 🟠 ;
- une tâche terminée doit avoir une preuve vérifiable ;
- un lot ne peut être terminé que si sa sortie et `DONE-001` à `DONE-005` sont
  satisfaites.

## Règles de développement

- Citer les identifiants de `spec.md` dans les tests, pull requests, décisions
  et comptes rendus applicables.
- Préserver l’architecture locale d’abord et l’intégrité des données.
- Ne jamais utiliser d’API Apple privée.
- Ne pas faire écrire les vues SwiftUI directement dans la base.
- Garder le domaine indépendant de SwiftUI et testable lorsque possible.
- Isoler les accès fichiers, CloudKit et services externes.
- Ajouter ou modifier les tests en même temps que les fonctionnalités.
- Ne pas exposer une fonction d’un lot ultérieur dans une version publique.
- Ne jamais versionner de secret, token, clé privée, média personnel ou donnée
  utilisateur réelle.
- Ne pas modifier `spec.md` pour faire correspondre la spécification à une
  implémentation plus simple sans instruction explicite.
- S'il y a une ambiguïté dans la spécification, demander une clarification avant de coder.

## Environnements de validation

- Sous WSL, n’exécuter que les builds et tests des cibles réellement
  multiplateformes.
- Ne pas considérer un build Linux comme une validation de l’application iOS.
- Compiler et tester les frameworks Apple dans Swift Playgrounds sur iPad ou
  dans un environnement Xcode macOS approuvé.
- Enregistrer pour chaque validation Apple le commit, l’appareil, la version du
  système et la version de l’outil.
- Tester la build TestFlight séparément de la build lancée dans Swift
  Playgrounds.

## Méthode de travail

1. Inspecter l’état Git avant toute édition et préserver les changements de
   l’utilisateur.
2. Identifier les exigences et la phase concernées.
3. Effectuer le changement minimal cohérent.
4. Exécuter les validations proportionnées au risque.
5. Mettre à jour la documentation affectée.
6. Mettre obligatoirement à jour `SUIVI_PROJET.md`.
7. Vérifier `git diff --check` et relire le diff avant de rendre la tâche.

## Campagnes manuelles regroupées

Afin de limiter les transferts et manipulations dans Swift Playgrounds,
préparer par défaut plusieurs fonctionnalités cohérentes d’un même lot avant
de demander une nouvelle campagne iPad. Le regroupement ne doit pas mélanger
des lots incompatibles, masquer un risque d’intégrité ni retarder un contrôle
nécessaire après une modification dangereuse de la persistance.

Pour chaque remise nécessitant une validation manuelle :

1. ajouter dans `suivi_tests.md` tous les tests à exécuter ;
2. attribuer à chacun un identifiant unique, stable et jamais réutilisé ;
3. indiquer le commit exact, les préconditions, les étapes, le résultat
   attendu et les exigences de `spec.md` couvertes ;
4. afficher le repère coloré défini dans `suivi_tests.md` devant chaque état et
   initialiser les nouveaux contrôles à ⚪ `NON TESTÉ` ;
5. permettre à l’utilisateur de répondre avec l’identifiant suivi de `OK`,
   `BLOQUÉ` ou de la description du bug ;
6. après chaque retour, mettre à jour le résultat, la preuve et
   l’environnement dans `suivi_tests.md` ;
7. reporter les anomalies, blocages et effets sur l’avancement dans
   `SUIVI_PROJET.md` ;
8. créer un nouvel identifiant de test de régression lorsqu’un changement rend
   une preuve antérieure insuffisante.

Ne jamais transformer un retour global ou ambigu en réussite détaillée sans
consigner explicitement la limite de preuve. Un test automatisé Linux ne
remplace pas un test manuel Apple et réciproquement.

Le compte rendu final doit mentionner :

- les fichiers modifiés ;
- l’état d’avancement résultant ;
- les validations exécutées ;
- les validations restant à faire ;
- tout blocage ou risque découvert.
