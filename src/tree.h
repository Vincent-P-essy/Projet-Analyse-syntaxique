/* tree.h */
#ifndef TREE_H
#define TREE_H

typedef enum
{
  /* Programme et déclarations */
  Prog,
  DeclVars,
  DeclFoncts,
  DeclFonct,

  /* Structures */
  StructDecl,
  ChampStructs,
  StructType,

  /* Déclarations */
  Declarateurs,
  EnTeteFonct,
  Parametres,
  ListTypVar,

  /* Corps et instructions */
  Corps,
  SuiteInstr,
  Instr,
  InstrAssign,
  InstrIf,
  InstrIfElse,
  InstrWhile,
  InstrCall,
  InstrReturn,
  InstrReturnVoid,
  InstrBlock,
  InstrEmpty,

  /* Expressions */
  Exp,
  TB,
  FB,
  M,
  E,
  T,
  F,

  /* Opérateurs */
  OpOr,
  OpAnd,
  OpEq,
  OpOrder,
  OpAddsub,
  OpDivstar,
  OpUnaryMinus,
  OpNot,

  /* Terminaux */
  Type,
  Ident,
  Num,
  Character,

  /* Arguments et listes */
  Arguments,
  ListExp

  /* list all other node labels, if any */
  /* The list must coincide with the string array in tree.c */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
} label_t;

typedef struct Node
{
  label_t label;
  struct Node *firstChild, *nextSibling;
  int lineno;
  char *ident; /* Pour stocker le nom des identificateurs */
  int num;     /* Pour stocker les valeurs numériques */
  char *type;  /* Pour stocker les types */
} Node;

Node *makeNode(label_t label);
Node *makeNodeIdent(label_t label, const char *ident);
Node *makeNodeNum(label_t label, int num);
Node *makeNodeType(label_t label, const char *type);
void addSibling(Node *node, Node *sibling);
void addChild(Node *parent, Node *child);
void deleteTree(Node *node);
void printTree(Node *node);

#define FIRSTCHILD(node) node->firstChild
#define SECONDCHILD(node) node->firstChild->nextSibling
#define THIRDCHILD(node) node->firstChild->nextSibling->nextSibling

#endif /* TREE_H */
