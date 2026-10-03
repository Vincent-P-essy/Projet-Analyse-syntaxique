# Projet d'Analyse Syntaxique - Langage TPC

## Licence Informatique 2025-2026

### Auteur
- Vincent PLESSY

---

## Description

Analyseur syntaxique complet pour le langage TPC (Tiny Pascal-like C), un sous-ensemble simplifié du langage C, développé avec Flex et Bison.

Le projet implémente :
- **Analyse lexicale** avec Flex - reconnaissance des tokens et gestion des commentaires
- **Analyse syntaxique** avec Bison - vérification de la conformité syntaxique
- **Construction d'arbres syntaxiques abstraits (AST)** - représentation hiérarchique du code
- **Support des structures** - déclarations et utilisation de types composés
- **Gestion robuste des erreurs** - messages d'erreur clairs avec numéro de ligne et colonne
- **Tests automatisés** - suite complète de tests pour validation

---

## Structure du projet

```
ProjetASL3_PLESSY/
├── src/                 # Fichiers sources
│   ├── tpcas.lex       # Analyseur lexical (Flex)
│   ├── tpcas.y         # Analyseur syntaxique (Bison)
│   ├── tree.c          # Implémentation de l'AST
│   └── tree.h          # Interface de l'AST
├── bin/                # Exécutable généré
│   └── tpcas           # Analyseur compilé
├── obj/                # Fichiers objets (.o)
├── test/               # Jeux de tests
│   ├── good/           # Programmes syntaxiquement corrects (8 tests)
│   └── syn-err/        # Programmes avec erreurs syntaxiques (8 tests)
├── rep/                # Documentation et rapport
│   └── RAPPORT.md      # Rapport technique du projet
├── makefile            # Compilation automatique
├── test.sh             # Script de tests automatiques avec rapport coloré
└── README.md           # Ce fichier
```

---

## Prérequis

### Linux (Ubuntu/Debian)
```bash
sudo apt install flex bison gcc make
```

### macOS
```bash
# Installer les outils de développement Xcode
xcode-select --install

# Installer Homebrew (si nécessaire)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Installer Flex et Bison
brew install flex bison
```

---

## Compilation

```bash
# Compilation complète
make

# Nettoyage des fichiers objets
make clean

# Nettoyage complet (y compris l'exécutable)
make mrproper
```

---

## Utilisation

### Syntaxe de base
```bash
# Analyser un fichier avec redirection
./bin/tpcas < fichier.tpc

# Analyser un fichier directement
./bin/tpcas fichier.tpc

# Afficher l'arbre syntaxique abstrait
./bin/tpcas -t < fichier.tpc
./bin/tpcas --tree fichier.tpc

# Afficher l'aide
./bin/tpcas -h
./bin/tpcas --help
```

### Codes de retour
- **0** : Programme correct (pas d'erreur)
- **1** : Erreur lexicale ou syntaxique détectée
- **2+** : Autre erreur (ligne de commande, fichier introuvable, etc.)

---

## Tests

### Script de test automatique (recommandé)
```bash
# Rendre le script exécutable (une seule fois)
chmod +x test.sh

# Lancer tous les tests
./test.sh

# Lancer avec sortie détaillée en cas d'erreur
VERBOSE=1 ./test.sh
```

Le script de test :
- ✅ Teste 8 programmes corrects
- ✅ Teste 8 programmes avec erreurs syntaxiques
- ✅ Affiche un rapport coloré avec statistiques
- ✅ Vérifie les codes de retour appropriés

### Résultat attendu
```
======================================
   Tests du compilateur TPC
======================================

=== Tests sur programmes corrects ===
Test: test01_hello.tpc                   ✓ PASS
Test: test02_variables.tpc               ✓ PASS
...

=== Tests sur programmes avec erreurs ===
Test: err01_missing_semicolon.tpc        ✓ PASS (erreur détectée)
...

======================================
   Résultats des tests
======================================
Total:   16 tests
Réussis: 16
Échoués: 0
Score:   100%

✓ Tous les tests sont passés avec succès!
```

---

## Exemples de programmes TPC

### Programme correct
```c
/* exemple.tpc */
int x, y;

int addition(int a, int b) {
    int result;
    result = a + b;
    return result;
}

int main(void) {
    x = addition(5, 10);
    return x;
}
```

### Programme avec structure
```c
/* structure.tpc */
struct point {
    int x, y;
};

struct rectangle {
    struct point coin1, coin2;
};

int main(void) {
    struct point p;
    return 0;
}
```

---

## Développement et personnalisation

### Ajouter un nouveau token
1. Modifier `src/tpcas.lex` (ajouter le pattern de reconnaissance)
2. Modifier `src/tpcas.y` (déclarer le token avec `%token`)
3. Recompiler avec `make clean && make`

### Ajouter une règle de grammaire
1. Modifier `src/tpcas.y` (section des règles après `%%`)
2. Ajouter les actions sémantiques (construction de l'AST)
3. Recompiler avec `make clean && make`
4. Tester avec un fichier d'exemple

### Modifier l'arbre syntaxique abstrait
1. Modifier `src/tree.h` (ajouter de nouveaux labels dans l'enum)
2. Modifier `src/tree.c` (ajouter les noms correspondants)
3. Modifier `src/tpcas.y` (utiliser les nouveaux labels dans les actions)
4. Recompiler et tester

---

## Grammaire du langage TPC

Le langage TPC supporte :
- Types de base : `int`, `char`, `void`
- Structures : `struct`
- Instructions : `if`, `else`, `while`, `return`
- Opérateurs arithmétiques : `+`, `-`, `*`, `/`, `%`
- Opérateurs de comparaison : `==`, `!=`, `<`, `>`, `<=`, `>=`
- Opérateurs booléens : `&&`, `||`, `!`
- Appels de fonctions
- Déclarations de variables globales et locales

---

## Problèmes courants

### Erreur "command not found: bison"
**Solution** : Installer Bison (voir section Prérequis)

### Erreur "library 'fl' not found" (macOS)
**Solution** : Le projet a été configuré pour ne pas nécessiter libfl. Si l'erreur persiste :
```bash
make clean
make
```

### Erreur "YYSTYPE has no member named..."
**Solution** : Ce problème a été corrigé. Assurez-vous d'utiliser la dernière version des fichiers sources.

### Tests qui échouent
**Solution** :
1. Vérifier que le fichier test est bien formé (pas d'initialisation inline comme `int a = 1;`)
2. Tester manuellement : `./bin/tpcas -t < test/good/test01_hello.tpc`
3. Lire les messages d'erreur détaillés avec `VERBOSE=1 ./test.sh`

### Le compilateur n'accepte pas `int a = 1;`
**C'est normal** : La grammaire TPC ne supporte pas l'initialisation lors de la déclaration. Utilisez :
```c
int a;
a = 1;
```

---

## Checklist avant le rendu

- [ ] Tous les fichiers sources sont dans `src/`
- [ ] Le makefile compile sans erreur
- [ ] L'exécutable s'appelle `bin/tpcas`
- [ ] Les options `-t` et `-h` fonctionnent
- [ ] Les codes de retour sont corrects (0, 1, 2+)
- [ ] Au moins 10 tests dans `test/good/`
- [ ] Au moins 10 tests dans `test/syn-err/`
- [ ] Le rapport est dans `rep/`
- [ ] L'archive est nommée correctement

# Créer le fichier de rendu

mkdir ProjetASL3_PLESSY && cp -r bin obj rep src test test.sh makefile README.md ProjetASL3_PLESSY/ && tar -czf ProjetASL3_PLESSY.tar.gz ProjetASL3_PLESSY/ && rm -rf ProjetASL3_PLESSY