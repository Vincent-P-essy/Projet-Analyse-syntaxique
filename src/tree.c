/* tree.c */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"
extern int lineno;       /* from lexer */

/* Implémentation portable de strdup pour compatibilité C99 strict */
static char *my_strdup(const char *s) {
  size_t len;
  char *copy;

  if (s == NULL) return NULL;

  len = strlen(s) + 1;
  copy = malloc(len);
  if (copy == NULL) return NULL;

  memcpy(copy, s, len);
  return copy;
}

static const char *StringFromLabel[] = {
  /* Programme et déclarations */
  "Prog",
  "DeclVars",
  "DeclFoncts",
  "DeclFonct",

  /* Structures */
  "StructDecl",
  "ChampStructs",
  "StructType",

  /* Déclarations */
  "Declarateurs",
  "EnTeteFonct",
  "Parametres",
  "ListTypVar",

  /* Corps et instructions */
  "Corps",
  "SuiteInstr",
  "Instr",
  "InstrAssign",
  "InstrIf",
  "InstrIfElse",
  "InstrWhile",
  "InstrCall",
  "InstrReturn",
  "InstrReturnVoid",
  "InstrBlock",
  "InstrEmpty",

  /* Expressions */
  "Exp",
  "TB",
  "FB",
  "M",
  "E",
  "T",
  "F",

  /* Opérateurs */
  "OpOr",
  "OpAnd",
  "OpEq",
  "OpOrder",
  "OpAddsub",
  "OpDivstar",
  "OpUnaryMinus",
  "OpNot",

  /* Terminaux */
  "Type",
  "Ident",
  "Num",
  "Character",

  /* Arguments et listes */
  "Arguments",
  "ListExp"

  /* list all other node labels, if any */
  /* The list must coincide with the label_t enum in tree.h */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
};

Node *makeNode(label_t label) {
  Node *node = malloc(sizeof(Node));
  if (!node) {
    printf("Run out of memory\n");
    exit(1);
  }
  node->label = label;
  node->firstChild = node->nextSibling = NULL;
  node->lineno = lineno;
  node->ident = NULL;
  node->num = 0;
  node->type = NULL;
  return node;
}

Node *makeNodeIdent(label_t label, const char *ident) {
  Node *node = makeNode(label);
  if (ident) {
    node->ident = my_strdup(ident);
  }
  return node;
}

Node *makeNodeNum(label_t label, int num) {
  Node *node = makeNode(label);
  node->num = num;
  return node;
}

Node *makeNodeType(label_t label, const char *type) {
  Node *node = makeNode(label);
  if (type) {
    node->type = my_strdup(type);
  }
  return node;
}

void addSibling(Node *node, Node *sibling) {
  if (!node || !sibling) return;
  Node *curr = node;
  while (curr->nextSibling != NULL) {
    curr = curr->nextSibling;
  }
  curr->nextSibling = sibling;
}

void addChild(Node *parent, Node *child) {
  if (!parent || !child) return;
  if (parent->firstChild == NULL) {
    parent->firstChild = child;
  }
  else {
    addSibling(parent->firstChild, child);
  }
}

void deleteTree(Node *node) {
  if (!node) return;
  if (node->firstChild) {
    deleteTree(node->firstChild);
  }
  if (node->nextSibling) {
    deleteTree(node->nextSibling);
  }
  if (node->ident) {
    free(node->ident);
  }
  if (node->type) {
    free(node->type);
  }
  free(node);
}

void printTree(Node *node) {
  if (!node) return;
  static int rightmost[128]; // tells if node is rightmost sibling
  static int depth = 0;      // depth of current node
  int i;
  Node *child;

  for (i = 1; i < depth; i++) { // 2502 = vertical line
    printf(rightmost[i] ? "    " : "\u2502   ");
  }
  if (depth > 0) { // 2514 = L form; 2500 = horizontal line; 251c = vertical line and right horiz
    printf(rightmost[depth] ? "\u2514\u2500\u2500 " : "\u251c\u2500\u2500 ");
  }
  printf("%s", StringFromLabel[node->label]);

  /* Afficher les informations supplémentaires si présentes */
  if (node->ident) {
    printf(" (%s)", node->ident);
  }
  if (node->type) {
    printf(" <%s>", node->type);
  }
  if (node->label == Num) {
    printf(" [%d]", node->num);
  }

  printf("\n");
  depth++;
  for (child = node->firstChild; child != NULL; child = child->nextSibling) {
    rightmost[depth] = (child->nextSibling) ? 0 : 1;
    printTree(child);
  }
  depth--;
}
