%{
/* Analyseur syntaxique pour le langage TPC avec construction d'AST */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

/* Variables externes */
extern int lineno;
extern int colno;
extern FILE *yyin;
int yylex(void);
void yyerror(const char *s);

/* Options de ligne de commande */
int print_tree = 0;

/* Arbre syntaxique abstrait */
Node *syntax_tree = NULL;
%}

/* Union pour les valeurs sémantiques */
%union {
    char *str;
    int num;
    struct Node *node;
}

/* Définition des tokens */
%token IF ELSE WHILE RETURN
%token VOID STRUCT
%token <str> TYPE IDENT
%token <num> NUM
%token <str> CHARACTER
%token <str> EQ ORDER ADDSUB DIVSTAR
%token OR AND

/* Types des non-terminaux */
%type <node> Prog DeclVars DeclFoncts DeclFonct
%type <node> StructDecl ChampStructs
%type <node> Declarateurs EnTeteFonct Parametres ListTypVar
%type <node> Corps SuiteInstr Instr
%type <node> Exp TB FB M E T F
%type <node> Arguments ListExp

/* Associativité et priorité des opérateurs */
%left OR
%left AND
%left EQ
%left ORDER
%left ADDSUB
%left DIVSTAR
%right '!' UMINUS

/* Attendre 1 conflit shift/reduce (dangling else) */
%expect 1

%%

/* Grammaire du langage TPC avec actions sémantiques */

Prog:  DeclVars DeclFoncts
    {
        $$ = makeNode(Prog);
        if ($1) addChild($$, $1);
        if ($2) addChild($$, $2);
        syntax_tree = $$;
    }
    ;

DeclVars:
       DeclVars TYPE Declarateurs ';'
    {
        $$ = $1 ? $1 : makeNode(DeclVars);
        Node *typeNode = makeNodeType(Type, $2);
        addChild($$, typeNode);
        addChild($$, $3);
        free($2);
    }
    |  DeclVars STRUCT IDENT Declarateurs ';'
    {
        $$ = $1 ? $1 : makeNode(DeclVars);
        Node *structType = makeNode(StructType);
        Node *structName = makeNodeIdent(Ident, $3);
        addChild(structType, structName);
        addChild($$, structType);
        addChild($$, $4);
        free($3);
    }
    |  DeclVars StructDecl
    {
        $$ = $1 ? $1 : makeNode(DeclVars);
        addChild($$, $2);
    }
    |  /* epsilon */
    {
        $$ = NULL;
    }
    ;

/* Déclaration de structures */
StructDecl:
       STRUCT IDENT '{' ChampStructs '}' ';'
    {
        $$ = makeNode(StructDecl);
        Node *structName = makeNodeIdent(Ident, $2);
        addChild($$, structName);
        addChild($$, $4);
        free($2);
    }
    ;

ChampStructs:
       ChampStructs TYPE Declarateurs ';'
    {
        $$ = $1 ? $1 : makeNode(ChampStructs);
        Node *typeNode = makeNodeType(Type, $2);
        addChild($$, typeNode);
        addChild($$, $3);
        free($2);
    }
    |  ChampStructs STRUCT IDENT Declarateurs ';'
    {
        $$ = $1 ? $1 : makeNode(ChampStructs);
        Node *structType = makeNode(StructType);
        Node *structName = makeNodeIdent(Ident, $3);
        addChild(structType, structName);
        addChild($$, structType);
        addChild($$, $4);
        free($3);
    }
    |  TYPE Declarateurs ';'
    {
        $$ = makeNode(ChampStructs);
        Node *typeNode = makeNodeType(Type, $1);
        addChild($$, typeNode);
        addChild($$, $2);
        free($1);
    }
    |  STRUCT IDENT Declarateurs ';'
    {
        $$ = makeNode(ChampStructs);
        Node *structType = makeNode(StructType);
        Node *structName = makeNodeIdent(Ident, $2);
        addChild(structType, structName);
        addChild($$, structType);
        addChild($$, $3);
        free($2);
    }
    ;

Declarateurs:
       Declarateurs ',' IDENT
    {
        $$ = $1;
        Node *id = makeNodeIdent(Ident, $3);
        addChild($$, id);
        free($3);
    }
    |  IDENT
    {
        $$ = makeNode(Declarateurs);
        Node *id = makeNodeIdent(Ident, $1);
        addChild($$, id);
        free($1);
    }
    ;

DeclFoncts:
       DeclFoncts DeclFonct
    {
        $$ = $1 ? $1 : makeNode(DeclFoncts);
        addChild($$, $2);
    }
    |  DeclFonct
    {
        $$ = makeNode(DeclFoncts);
        addChild($$, $1);
    }
    ;

DeclFonct:
       EnTeteFonct Corps
    {
        $$ = makeNode(DeclFonct);
        addChild($$, $1);
        addChild($$, $2);
    }
    ;

EnTeteFonct:
       TYPE IDENT '(' Parametres ')'
    {
        $$ = makeNode(EnTeteFonct);
        Node *typeNode = makeNodeType(Type, $1);
        Node *nameNode = makeNodeIdent(Ident, $2);
        addChild($$, typeNode);
        addChild($$, nameNode);
        if ($4) addChild($$, $4);
        free($1);
        free($2);
    }
    |  VOID IDENT '(' Parametres ')'
    {
        $$ = makeNode(EnTeteFonct);
        Node *typeNode = makeNodeType(Type, "void");
        Node *nameNode = makeNodeIdent(Ident, $2);
        addChild($$, typeNode);
        addChild($$, nameNode);
        if ($4) addChild($$, $4);
        free($2);
    }
    |  STRUCT IDENT IDENT '(' Parametres ')'
    {
        $$ = makeNode(EnTeteFonct);
        Node *structType = makeNode(StructType);
        Node *structName = makeNodeIdent(Ident, $2);
        addChild(structType, structName);
        Node *funcName = makeNodeIdent(Ident, $3);
        addChild($$, structType);
        addChild($$, funcName);
        if ($5) addChild($$, $5);
        free($2);
        free($3);
    }
    ;

Parametres:
       VOID
    {
        $$ = NULL;
    }
    |  ListTypVar
    {
        $$ = makeNode(Parametres);
        addChild($$, $1);
    }
    ;

ListTypVar:
       ListTypVar ',' TYPE IDENT
    {
        $$ = $1;
        Node *typeNode = makeNodeType(Type, $3);
        Node *nameNode = makeNodeIdent(Ident, $4);
        addChild($$, typeNode);
        addChild($$, nameNode);
        free($3);
        free($4);
    }
    |  ListTypVar ',' STRUCT IDENT IDENT
    {
        $$ = $1;
        Node *structType = makeNode(StructType);
        Node *structName = makeNodeIdent(Ident, $4);
        addChild(structType, structName);
        Node *varName = makeNodeIdent(Ident, $5);
        addChild($$, structType);
        addChild($$, varName);
        free($4);
        free($5);
    }
    |  TYPE IDENT
    {
        $$ = makeNode(ListTypVar);
        Node *typeNode = makeNodeType(Type, $1);
        Node *nameNode = makeNodeIdent(Ident, $2);
        addChild($$, typeNode);
        addChild($$, nameNode);
        free($1);
        free($2);
    }
    |  STRUCT IDENT IDENT
    {
        $$ = makeNode(ListTypVar);
        Node *structType = makeNode(StructType);
        Node *structName = makeNodeIdent(Ident, $2);
        addChild(structType, structName);
        Node *varName = makeNodeIdent(Ident, $3);
        addChild($$, structType);
        addChild($$, varName);
        free($2);
        free($3);
    }
    ;

Corps: '{' DeclVars SuiteInstr '}'
    {
        $$ = makeNode(Corps);
        if ($2) addChild($$, $2);
        if ($3) addChild($$, $3);
    }
    ;

SuiteInstr:
       SuiteInstr Instr
    {
        $$ = $1 ? $1 : makeNode(SuiteInstr);
        if ($2) addChild($$, $2);
    }
    |  /* epsilon */
    {
        $$ = NULL;
    }
    ;

Instr:
       IDENT '=' Exp ';'
    {
        $$ = makeNode(InstrAssign);
        Node *id = makeNodeIdent(Ident, $1);
        addChild($$, id);
        addChild($$, $3);
        free($1);
    }
    |  IF '(' Exp ')' Instr
    {
        $$ = makeNode(InstrIf);
        addChild($$, $3);
        addChild($$, $5);
    }
    |  IF '(' Exp ')' Instr ELSE Instr
    {
        $$ = makeNode(InstrIfElse);
        addChild($$, $3);
        addChild($$, $5);
        addChild($$, $7);
    }
    |  WHILE '(' Exp ')' Instr
    {
        $$ = makeNode(InstrWhile);
        addChild($$, $3);
        addChild($$, $5);
    }
    |  IDENT '(' Arguments  ')' ';'
    {
        $$ = makeNode(InstrCall);
        Node *id = makeNodeIdent(Ident, $1);
        addChild($$, id);
        if ($3) addChild($$, $3);
        free($1);
    }
    |  RETURN Exp ';'
    {
        $$ = makeNode(InstrReturn);
        addChild($$, $2);
    }
    |  RETURN ';'
    {
        $$ = makeNode(InstrReturnVoid);
    }
    |  '{' SuiteInstr '}'
    {
        $$ = makeNode(InstrBlock);
        if ($2) addChild($$, $2);
    }
    |  ';'
    {
        $$ = makeNode(InstrEmpty);
    }
    ;

Exp :  Exp OR TB
    {
        $$ = makeNode(OpOr);
        addChild($$, $1);
        addChild($$, $3);
    }
    |  TB
    {
        $$ = $1;
    }
    ;

TB  :  TB AND FB
    {
        $$ = makeNode(OpAnd);
        addChild($$, $1);
        addChild($$, $3);
    }
    |  FB
    {
        $$ = $1;
    }
    ;

FB  :  FB EQ M
    {
        $$ = makeNodeType(OpEq, $2);
        addChild($$, $1);
        addChild($$, $3);
        free($2);
    }
    |  M
    {
        $$ = $1;
    }
    ;

M   :  M ORDER E
    {
        $$ = makeNodeType(OpOrder, $2);
        addChild($$, $1);
        addChild($$, $3);
        free($2);
    }
    |  E
    {
        $$ = $1;
    }
    ;

E   :  E ADDSUB T
    {
        $$ = makeNodeType(OpAddsub, $2);
        addChild($$, $1);
        addChild($$, $3);
        free($2);
    }
    |  T
    {
        $$ = $1;
    }
    ;

T   :  T DIVSTAR F
    {
        $$ = makeNodeType(OpDivstar, $2);
        addChild($$, $1);
        addChild($$, $3);
        free($2);
    }
    |  F
    {
        $$ = $1;
    }
    ;

F   :  ADDSUB F %prec UMINUS
    {
        $$ = makeNodeType(OpUnaryMinus, $1);
        addChild($$, $2);
        free($1);
    }
    |  '!' F
    {
        $$ = makeNode(OpNot);
        addChild($$, $2);
    }
    |  '(' Exp ')'
    {
        $$ = $2;
    }
    |  NUM
    {
        $$ = makeNodeNum(Num, $1);
    }
    |  CHARACTER
    {
        $$ = makeNodeIdent(Character, $1);
        free($1);
    }
    |  IDENT
    {
        $$ = makeNodeIdent(Ident, $1);
        free($1);
    }
    |  IDENT '(' Arguments  ')'
    {
        $$ = makeNode(F);
        Node *id = makeNodeIdent(Ident, $1);
        addChild($$, id);
        if ($3) addChild($$, $3);
        free($1);
    }
    ;

Arguments:
       ListExp
    {
        $$ = makeNode(Arguments);
        if ($1) addChild($$, $1);
    }
    |  /* epsilon */
    {
        $$ = NULL;
    }
    ;

ListExp:
       ListExp ',' Exp
    {
        $$ = $1 ? $1 : makeNode(ListExp);
        addChild($$, $3);
    }
    |  Exp
    {
        $$ = makeNode(ListExp);
        addChild($$, $1);
    }
    ;

%%

/* Gestion des erreurs syntaxiques */
void yyerror(const char *s) {
    fprintf(stderr, "Erreur syntaxique ligne %d, colonne %d: %s\n", lineno, colno, s);
}

/* Affichage de l'aide */
void print_help(const char *prog_name) {
    printf("Usage: %s [OPTIONS] [FILE]\n", prog_name);
    printf("Analyseur syntaxique pour le langage TPC\n\n");
    printf("Options:\n");
    printf("  -t, --tree    Affiche l'arbre abstrait\n");
    printf("  -h, --help    Affiche cette aide\n");
    printf("\nExemples:\n");
    printf("  %s -t < fichier.tpc\n", prog_name);
    printf("  %s --tree fichier.tpc\n", prog_name);
}

/* Fonction principale */
int main(int argc, char **argv) {
    char *input_file = NULL;
    int i;

    /* Analyse simple des arguments */
    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-t") == 0 || strcmp(argv[i], "--tree") == 0) {
            print_tree = 1;
        } else if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            print_help(argv[0]);
            return 0;
        } else if (argv[i][0] != '-') {
            /* C'est un fichier d'entrée */
            input_file = argv[i];
        }
    }

    /* Ouvrir le fichier d'entrée si spécifié */
    if (input_file != NULL) {
        yyin = fopen(input_file, "r");
        if (!yyin) {
            fprintf(stderr, "Erreur: Impossible d'ouvrir le fichier %s\n", input_file);
            return 2;
        }
    }

    /* Analyse syntaxique */
    int result = yyparse();

    /* Fermer le fichier si ouvert */
    if (input_file != NULL && yyin != NULL) {
        fclose(yyin);
    }

    /* Afficher l'arbre si demandé et si pas d'erreur */
    if (result == 0 && print_tree && syntax_tree) {
        printTree(syntax_tree);
    }

    /* Libérer la mémoire de l'arbre */
    if (syntax_tree) {
        deleteTree(syntax_tree);
    }

    /* Code de retour */
    if (result != 0) {
        return 1;  /* Erreur lexicale ou syntaxique */
    }

    return 0;  /* Succès */
}
