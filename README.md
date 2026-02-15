# Compte-rendu – Loïc Durand
**Qualité de développement**

---

## Partie 1 : Git

### exercice 1 — Récupération et installation de PrivateBin + utilisation de Make

**Manipulations effectuées :**
- Récupération du code du projet :
  ```bash
  git clone git@github.com:PrivateBin/PrivateBin.git
  ```
- Installation des dépendances :
  ```bash
  make install
  ```
- Lancement du serveur :
  ```bash
  make start
  ```
- Création de plusieurs secrets, puis arrêt du serveur.
- Vérification du dépôt :
  ```bash
  git status
  ```
- Aucun secret n’apparaît, car ignorés par le `.gitignore`.

---

### Exercice 2 — Création de branches et commits distincts

**Manipulations :**
- Création d’une nouvelle branche et modification de `lib/Configuration.php` :
  - Langue par défaut changée en français.
  - Ajout d’une option d’expiration à 30 minutes (1800 secondes).
- Réalisation de deux commits distincts :
  ```bash
  git switch -c modification
  git add -p lib/Configuration.php
  git commit -m "langue francais"
  git add -p lib/Configuration.php
  git commit -m "30min expiration"
  git checkout main
  git status
  ```
- Les modifications ne sont pas visibles sur `main`.

---

###  Fusion de branches

**Manipulations :**
```bash
git checkout main
git merge modification
git log
git branch -d modification
```

---

### Exercice 3 — Gestion des conflits

**Conflit volontaire sur la durée d’expiration par défaut :**
```bash
git switch -c expiration
# modification : 1 mois
git add . (juste ceci de modifié)
git commit -m "Expiration 1 mois"

git checkout main
# modification : 1 jour
git add . (juste ceci de modifié)
git commit -m "Expiration 1 jour"

git merge expiration
# conflit détecté
```
Résolution manuelle du conflit dans le fichier concerné, puis commit.

---

### Exercice 4 — Git bisect

**Recherche du commit fautif (renommage PrivateBin → CharleBin) :**
```bash
git checkout rename-vers-charlebin
git bisect start
git bisect bad
git bisect good <commit_sain>
git bisect bad / good
git bisect reset
```

---

### Git bisect automatisé

**Utilisation automatisée :**
```bash
git bisect run make test
```
Recherche plus rapide et plus fiable.

---

## Partie 2 : Pull Request et Review

### Création du repository CharleBin
**Création du repository en ligne :**

https://github.com/loicdurand7/CharleBin

**Commandes principales :**
```bash
git clone git@github.com:loicdurand7/CharleBin.git
git status
<copie de PrivateBin>
git add .
git commit -m "copie de PrivateBin"
git push
git status
```

---

### Pull Request

- Création d’une branche dédiée, suppression du footer.
- Commit + push, puis création de la Pull Request.

---

### Documentation

Création de :
- `README.md`
- `CONTRIBUTING.md`

Contenant :
- Description du projet
- Instructions d’installation
- Règles de contribution

---

## Partie Linters

### Installation

```bash
composer require --dev squizlabs/php_codesniffer
composer require --dev phpmd/phpmd
composer require --dev friendsofphp/php-cs-fixer
```

### Ajout dans le Makefile

```makefile
lint:
  php -l cfg/conf.sample.php
  ./vendor/bin/phpcs --extensions=php ./lib/
  ./vendor/bin/phpmd ./lib ansi codesize,unusedcode,naming
```

### Corrections effectuées
- Variables inutilisées
- Mauvais nommage
- Méthodes trop longues
- Espaces et indentations incorrectes

---

### Pre-commit Hook

Création d’un script `.git/hooks/pre-commit` :

```bash
./vendor/bin/php-cs-fixer fix lib
git add .
./vendor/bin/phpmd ./lib ansi codesize,unusedcode,naming
```

- Le commit est bloqué si une erreur est détectée.
- Contournement possible :
  ```bash
  git commit --no-verify
  ```

---

### GitHub Actions + Protection de main

**Workflow GitHub :**

```yaml
name: Lint

on:
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: composer install
      - run: make lint
```

**Protection GitHub :**
- Interdiction de push direct sur `main`.
- Merge uniquement si le lint passe avec succès.

---

## DevTools — Analyse sécurité

### Vérification du mot de passe
- Visible dans la boite tant que la page reste ouverte.
- inspecter :
- selectionner un élément de la page (choisir la boite de texte avec le mdp écrit)
- aller dans élément puis proriété
- descendre en bas sur value

### Vérification du chiffrement
- Dans “Network” → le message n’apparaît pas en clair → chiffrement côté client confirmé.

### Vérification du stockage local
- Aucune donnée persistée dans :
  - Cookies
  - LocalStorage
  - SessionStorage
  - IndexedDB

→ Comportement conforme attendu.

---

## Partie Tests – Cypress (E2E)

### Installation

```bash
node -v
npx cypress install
npx cypress open
```

---

### Test E2E CharleBin

**Objectif :**
- Créer un texte avec message et mot de passe
- Récupérer l’URL générée
- Recharger la page, entrer le mot de passe, et vérifier le message déchiffré

**Test Cypress :**
```javascript
describe("CharleBin - Create and retrieve paste", () => {

  const message = "Test Cypress CharleBin";
  const password = "monMotDePasse123";

  it("should create a paste, open it and decrypt it", () => {

    cy.visit("http://localhost:8080");

    cy.contains("New").click();

    cy.get("#message").type(message);
    cy.get("#passwordinput").type(password);
    cy.get("#sendbutton").click();

    cy.location("href").then((url) => {

      cy.visit(url);

      cy.get("#passworddecrypt").type(password, { force: true });

      cy.contains("Decrypt").click({ force: true });

      cy.contains(message).should("be.visible");

    });

  });

});

```

**Le test fonctionne :**
- Le bon fonctionnement de la création des messages et MDP
- Le déchiffrement correct et l’affichage du message final
- Les { force: true } ont été utilisés pour forcer l'utilisation du CSS car sinon les tests ne pouvais pas cliquer sur les boutons

**Résultat :** Test réussi et push sur GitHub.

---


**Conclusion :**
Les tests E2E simulent un utilisateur réel et garantissent la fiabilité des fonctionnalités web.

---

### Extension : Application sur NetVOD

# Tests unitaires -- SAE NetVOD

Après avoir réalisé des tests sur CharleBin, j'ai effectué des **tests
unitaires sur la SAE NetVOD** pour mieux comprendre comment tester un
projet Web en PHP avec **PHPUnit**.

------------------------------------------------------------------------

## Structure des tests

J'ai créé un dossier `test/` dans le projet et implémenté **deux
fichiers de test** :

### 1. TestDispatcher.php (4 tests)

Tests d'intégration du **routage Dispatcher** et génération HTML :

-   `testCatalogueAction()` : routage vers `CatalogueAction`
-   `testRegisterAction()` : affichage formulaire inscription
-   `testDefaultAction()` : fallback vers `HomeAction`
-   `testLogoutAction()` : génération HTML déconnexion

------------------------------------------------------------------------

### 2. TestRepository.php (4 tests)

Tests unitaires **Repository** avec BDD SQLite temporaire :

-   `testInsertAndGetHashUser()` : insertion + récupération hash
    utilisateur
-   `testGetHashUserReturnsNull()` : utilisateur inexistant → `null`
-   `testAddSeriesToFavorites()` : ajout série aux favoris
-   `testRemoveSeriesFromFavorites()` : suppression favoris

------------------------------------------------------------------------

## Modifications apportées à NetVOD

### TestDispatcher

-   `Action::__construct()` : `$_SERVER['REQUEST_METHOD'] ?? 'GET'`
-   `TestDispatcher::setUp()` : `$_SERVER['REQUEST_METHOD'] = 'GET'`
-   Neutralisation `session_start()` dans Dispatcher / Actions
-   Mock `Repository::$instance` via `ReflectionProperty` (propriété
    private)
-   Output buffering : `ob_start()` / `ob_get_contents()` /
    `ob_end_clean()`

------------------------------------------------------------------------

### TestRepository

-   BDD SQLite temporaire : `test.db` (créée / supprimée
    automatiquement)
-   Schéma minimal : tables `user` + `favoris`
-   Configuration : `dbtest.config.ini` pour SQLite
-   Nettoyage : `tearDown()` + Reflection pour reset
    `Repository::$instance`

------------------------------------------------------------------------

## Problèmes rencontrés

  ---------------------------------------------------------------------------------------------------------------
  Composant -->                 Problème -->                                  Solution
  ------------------------- ----------------------------------------- -------------------------------------------
  **Dispatcher**   -->         `Undefined array key "REQUEST_METHOD"`  -->  `$_SERVER ?? 'GET'` + `setUp()`

  **Dispatcher**    -->        `session_start(): headers already sent`  --> Suppression `session_start()` +
                                                                      `ob_start()`

  **Dispatcher**      -->      `Cannot modify header information`    -->    Neutralisation `header()` dans `catch`

  **Dispatcher**      -->      `Repository::$instance private`      -->     `ReflectionProperty::setAccessible(true)`

  **Repository**            BDD non initialisée                       SQLite + schéma `CREATE TABLE`
  ---------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------

## Commandes d'exécution

``` bash
# Windows
php vendor/bin/phpunit test/TestDispatcher.php
php vendor/bin/phpunit test/TestRepository.php

# Linux / Mac
./vendor/bin/phpunit test/TestDispatcher.php
./vendor/bin/phpunit test/TestRepository.php
```

------------------------------------------------------------------------

## Résultats

    TestDispatcher : OK (4 tests, 4 assertions) 
    TestRepository : OK (4 tests, 4 assertions) 

    TOTAL : 8 tests, 8 assertions réussis

------------------------------------------------------------------------

## Fichiers fournis

    test/
    ├── TestDispatcher.php     # Tests routage + mock Reflection
    ├── TestRepository.php     # Tests BDD SQLite
    ├── dbtest.config.ini      # Config SQLite Repository
    └── test.db                # BDD temporaire (auto-générée)

------------------------------------------------------------------------

## Couverture validée

  Couche       Fonctionnalités testées
  ------------ -------------------------------------------------
  Dispatcher   Routage 4 actions, génération HTML, gestion CLI
  Repository   CRUD users, gestion favoris, singleton pattern
  Actions      Exécution sans crash (mock dependencies)

------------------------------------------------------------------------


## Conclusion générale

À travers ces TP, j’ai :
- Approfondi Git (branches, conflits, bisect)
- Mis en place des Pull Requests
- Rédigé une documentation claire
- Intégré des linters et hooks automatiques
- Sécurisé la branche main
- Automatisé la vérification via GitHub Actions
- Réalisé un test E2E complet avec Cypress

J’ai ainsi compris l’importance de :
- La qualité et la lisibilité du code
- L’automatisation des vérifications
- Les tests robustes
