```
◇ Test run started.
↳ Testing Library Version: 94 (arm64-apple-ios13.0-simulator)
◇ Suite UserTests started.
◇ Suite TaskTests started.
◇ Suite SwiftDataUserRepositoryTests started.
◇ Suite UserCreationTests started.
◇ Suite UserListTests started.
◇ Suite TaskPaginationTests started.
◇ Suite TaskItemReadTests started.
◇ Suite TaskItemCreationTests started.
◇ Suite TaskDueDateTests started.
◇ Suite TaskSortTests started.
◇ Suite TaskItemEditStatusTests started.
◇ Suite TaskDeleteTests started.
◇ Suite SwiftDataRepositoryIntegrationTests started.
◇ Suite TaskSearchTests started.
◇ Suite TaskItemEditTests started.
◇ Test "Saving a user with an existing ID updates it" started.
◇ Suite TaskFilterTests started.
◇ Test "List users with no users returns empty result" started.
◇ Test "Save a new user and retrieve it successfully by email" started.
◇ Test "Finding a non-existent user returns nil" started.
◇ Test "Tenter de créer un utilisateur avec un email invalide" started.
◇ Test "Créer un utilisateur avec des données valides" started.
◇ Test "Tenter de créer un utilisateur avec un email existant" started.
◇ Test "List users returns paginated and sorted results" started.
◇ Test "Demander la liste avec une taille de page invalide lève une erreur" started.
◇ Test "Tenter de créer un utilisateur avec un nom vide" started.
◇ Test "Demander une page d'utilisateurs au-delà des limites retourne une liste vide" started.
◇ Test "Tenter de créer un utilisateur avec un nom trop long" started.
◇ Test "Demander la liste des utilisateurs avec des paramètres de page invalides lève une erreur" started.
◇ Test "Obtenir la deuxième page d'une liste" started.
◇ Test "Trier les utilisateurs par nom descendant" started.
◇ Test "Demander la liste complexe avec des paramètres de page invalides lève une erreur" started.
◇ Test "La pagination des utilisateurs fonctionne correctement" started.
◇ Test "Lister les utilisateurs les trie par nom par défaut" started.
◇ Test "Demander la liste avec les paramètres par défaut" started.
◇ Test "Consulter une tâche avec un ID inexistant" started.
◇ Test "Demander une page au-delà des limites (complex list) retourne une liste vide" started.
◇ Test "Demander une page au-delà des limites (simple list) retourne une liste vide" started.
◇ Test "Lister les utilisateurs quand il n'y en a aucun" started.
◇ Test "Tenter de définir une échéance avec un ID mal formaté" started.
◇ Test "Consulter une tâche existante avec un ID valide" started.
◇ Test "Demander la liste quand il n'y a aucune tâche" started.
◇ Test "Consulter une tâche avec un ID au mauvais format" started.
◇ Test "Obtenir la première page d'une liste de 25 tâches" started.
◇ Test "Supprimer une date d'échéance" started.
◇ Test "Définir une date d'échéance dans le passé" started.
◇ Test "Tenter de supprimer une tâche avec un ID mal formaté" started.
◇ Test "Définir une date d'échéance future valide" started.
◇ Test "Modifier une date d'échéance existante" started.
◇ Test "Supprimer une tâche existante avec succès" started.
◇ Test "Trier les tâches par titre" started.
◇ Test "Tenter plusieurs opérations sur une tâche supprimée" started.
◇ Test "Trier les tâches par statut" started.
◇ Test "Tenter de définir une échéance sur une tâche inexistante" started.
◇ Test "Vérification de la précision de la date de création" started.
◇ Test "Trier les tâches par date de création" started.
◇ Test "Le tri par défaut et la combinaison avec les filtres fonctionnent" started.
◇ Test "Tentative de création avec un titre vide ou blanc" started.
◇ Test "Création avec un titre contenant des espaces en trop" started.
◇ Test "Tentative de création avec un titre trop long" started.
◇ Test "Tentative de création avec une description trop longue" started.
◇ Test "Attempting to retrieve a non-existent task throws an error" started.
◇ Test "Création avec un titre et une description valides" started.
◇ Test "Save a new task and retrieve it successfully" started.
◇ Test "Création avec un titre valide" started.
◇ Test "Saving a task with an existing ID updates the task" started.
◇ Test "List tasks with complex sorting, filtering, and searching" started.
◇ Test "La recherche sur un terme inexistant retourne une liste vide" started.
◇ Test "La recherche est insensible à la casse" started.
◇ Test "Attempting to delete a non-existent task throws an error" started.
◇ Test "List tasks with simple pagination works correctly" started.
◇ Test "Les résultats de recherche sont bien paginés" started.
◇ Test "Rechercher un terme dans le titre ou la description" started.
◇ Test "Modifier le titre d'une tâche existante" started.
◇ Test "La recherche avec une chaîne vide retourne toutes les tâches" started.
◇ Test "Delete an existing task removes it from the context" started.
◇ Test "Modifier la description d'une tâche existante" started.
◇ Test "Tenter de modifier une tâche avec un titre vide" started.
◇ Test "Tenter de modifier une tâche inexistante" started.
◇ Test "Tenter de modifier une tâche avec un ID mal formaté" started.
◇ Test "Modifier le titre et la description d'une tâche" started.
◇ Test "Tenter de changer le statut d'une tâche avec un ID mal formaté" started.
◇ Test "Changer le statut d'une tâche existante" started.
◇ Test "Tenter de créer un statut avec une valeur invalide" started.
◇ Test "Tenter de changer le statut d'une tâche inexistante" started.
◇ Test "Tenter de modifier une tâche avec des valeurs trop longues" started.
◇ Test "Filtrer par un statut existant retourne les bonnes tâches" started.
◇ Test "Les résultats filtrés sont paginés" started.
✔ Test "Saving a user with an existing ID updates it" passed after 0.055 seconds.
✔ Test "List users with no users returns empty result" passed after 0.059 seconds.
✔ Test "Save a new user and retrieve it successfully by email" passed after 0.059 seconds.
✔ Test "Tenter de créer un utilisateur avec un email invalide" passed after 0.059 seconds.
✔ Test "Finding a non-existent user returns nil" passed after 0.070 seconds.
✔ Test "Tenter de créer un utilisateur avec un email existant" passed after 0.070 seconds.
✔ Test "Demander une page d'utilisateurs au-delà des limites retourne une liste vide" passed after 0.070 seconds.
✔ Test "Demander la liste des utilisateurs avec des paramètres de page invalides lève une erreur" passed after 0.070 seconds.
✔ Test "Tenter de créer un utilisateur avec un nom trop long" passed after 0.070 seconds.
✔ Test "Le tri par défaut et la combinaison avec les filtres fonctionnent" passed after 0.065 seconds.
✔ Test "Créer un utilisateur avec des données valides" passed after 0.070 seconds.
✔ Test "Demander la liste avec une taille de page invalide lève une erreur" passed after 0.070 seconds.
✔ Test "Lister les utilisateurs les trie par nom par défaut" passed after 0.070 seconds.
✔ Test "List users returns paginated and sorted results" passed after 0.070 seconds.
✔ Test "Trier les utilisateurs par nom descendant" passed after 0.070 seconds.
✔ Test "Demander la liste complexe avec des paramètres de page invalides lève une erreur" passed after 0.070 seconds.
✔ Test "La pagination des utilisateurs fonctionne correctement" passed after 0.070 seconds.
✔ Test "Trier les tâches par date de création" passed after 0.068 seconds.
✔ Test "Consulter une tâche avec un ID inexistant" passed after 0.068 seconds.
✔ Suite SwiftDataUserRepositoryTests passed after 0.070 seconds.
✔ Test "Obtenir la deuxième page d'une liste" passed after 0.070 seconds.
✔ Test "Demander une page au-delà des limites (simple list) retourne une liste vide" passed after 0.070 seconds.
✔ Test "Lister les utilisateurs quand il n'y en a aucun" passed after 0.070 seconds.
✔ Test "Demander la liste avec les paramètres par défaut" passed after 0.070 seconds.
✔ Test "Tenter de créer un utilisateur avec un nom vide" passed after 0.070 seconds.
✔ Suite UserListTests passed after 0.070 seconds.
✔ Suite UserCreationTests passed after 0.070 seconds.
✔ Suite UserTests passed after 0.071 seconds.
✔ Test "Tenter de définir une échéance avec un ID mal formaté" passed after 0.070 seconds.
✔ Test "Consulter une tâche avec un ID au mauvais format" passed after 0.071 seconds.
✔ Test "Demander la liste quand il n'y a aucune tâche" passed after 0.073 seconds.
✔ Test "Obtenir la première page d'une liste de 25 tâches" passed after 0.072 seconds.
✔ Test "Tenter de supprimer une tâche avec un ID mal formaté" passed after 0.068 seconds.
✔ Test "Demander une page au-delà des limites (complex list) retourne une liste vide" passed after 0.073 seconds.
✔ Test "Définir une date d'échéance dans le passé" passed after 0.072 seconds.
✔ Suite TaskPaginationTests passed after 0.073 seconds.
✔ Test "Modifier une date d'échéance existante" passed after 0.072 seconds.
✔ Test "Tenter plusieurs opérations sur une tâche supprimée" passed after 0.075 seconds.
✔ Test "Trier les tâches par statut" passed after 0.079 seconds.
✔ Test "Trier les tâches par titre" passed after 0.076 seconds.
✔ Test "Consulter une tâche existante avec un ID valide" passed after 0.079 seconds.
✔ Suite TaskSortTests passed after 0.081 seconds.
✔ Suite TaskItemReadTests passed after 0.081 seconds.
✔ Test "Supprimer une tâche existante avec succès" passed after 0.080 seconds.
✔ Test "Supprimer une date d'échéance" passed after 0.084 seconds.
✔ Test "Tentative de création avec un titre trop long" passed after 0.079 seconds.
✔ Test "Tenter de définir une échéance sur une tâche inexistante" passed after 0.084 seconds.
✔ Test "Vérification de la précision de la date de création" passed after 0.080 seconds.
✔ Test "Création avec un titre et une description valides" passed after 0.080 seconds.
✔ Test "La recherche sur un terme inexistant retourne une liste vide" passed after 0.079 seconds.
✔ Test "Tentative de création avec un titre vide ou blanc" passed after 0.080 seconds.
✔ Test "Définir une date d'échéance future valide" passed after 0.084 seconds.
✔ Test "Création avec un titre valide" passed after 0.080 seconds.
✔ Test "Tentative de création avec une description trop longue" passed after 0.080 seconds.
✔ Test "Saving a task with an existing ID updates the task" passed after 0.079 seconds.
✔ Test "Attempting to delete a non-existent task throws an error" passed after 0.079 seconds.
✔ Test "Les résultats de recherche sont bien paginés" passed after 0.079 seconds.
✔ Suite TaskDeleteTests passed after 0.086 seconds.
✔ Test "List tasks with complex sorting, filtering, and searching" passed after 0.082 seconds.
✔ Test "Création avec un titre contenant des espaces en trop" passed after 0.080 seconds.
✔ Test "La recherche avec une chaîne vide retourne toutes les tâches" passed after 0.082 seconds.
✔ Test "Delete an existing task removes it from the context" passed after 0.082 seconds.
✔ Test "Modifier la description d'une tâche existante" passed after 0.082 seconds.
✔ Test "Tenter de modifier une tâche inexistante" passed after 0.081 seconds.
✔ Test "Tenter de modifier une tâche avec des valeurs trop longues" passed after 0.081 seconds.
✔ Test "Changer le statut d'une tâche existante" passed after 0.081 seconds.
✔ Test "Modifier le titre et la description d'une tâche" passed after 0.081 seconds.
✔ Test "Tenter de changer le statut d'une tâche inexistante" passed after 0.081 seconds.
✔ Test "Modifier le titre d'une tâche existante" passed after 0.081 seconds.
✔ Test "Les résultats filtrés sont paginés" passed after 0.079 seconds.
✔ Test "Save a new task and retrieve it successfully" passed after 0.082 seconds.
✔ Test "Attempting to retrieve a non-existent task throws an error" passed after 0.082 seconds.
✔ Test "Tenter de modifier une tâche avec un ID mal formaté" passed after 0.081 seconds.
✔ Test "Tenter de créer un statut avec une valeur invalide" passed after 0.081 seconds.
✔ Test "La recherche est insensible à la casse" passed after 0.082 seconds.
✔ Test "Rechercher un terme dans le titre ou la description" passed after 0.082 seconds.
✔ Test "List tasks with simple pagination works correctly" passed after 0.083 seconds.
✔ Test "Tenter de changer le statut d'une tâche avec un ID mal formaté" passed after 0.081 seconds.
✔ Test "Filtrer par un statut existant retourne les bonnes tâches" passed after 0.080 seconds.
✔ Suite TaskDueDateTests passed after 0.090 seconds.
✔ Test "Tenter de modifier une tâche avec un titre vide" passed after 0.081 seconds.
✔ Suite TaskItemEditStatusTests passed after 0.090 seconds.
✔ Suite SwiftDataRepositoryIntegrationTests passed after 0.090 seconds.
✔ Suite TaskFilterTests passed after 0.090 seconds.
✔ Suite TaskItemEditTests passed after 0.090 seconds.
✔ Suite TaskSearchTests passed after 0.090 seconds.
✔ Suite TaskItemCreationTests passed after 0.090 seconds.
✔ Suite TaskTests passed after 0.091 seconds.
✔ Test run with 72 tests passed after 0.091 seconds.
```
