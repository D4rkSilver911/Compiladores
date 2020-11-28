#ifndef SIMBTAB_H_INCLUDED
#define SIMBTAB_H_INCLUDED

typedef enum {Global, Func, Var} Symbol_Type;

typedef struct symbol_node {
	Symbol_Type tipo;
	
	char* id;
	char* type;
	
	union {
		int flag_print;
		int flag_param;
	} flag;
	
	struct symbol_node* next;
	struct symbol_node* children;

} symbol_node;

typedef struct lista_palavras {
	char id[1024];
	char pal[1024];
	
	struct lista_palavras* next;

} lista_palavras;

symbol_node* ast_to_sym_table(node_type* ast, symbol_node* table);
symbol_node* create_symb(Symbol_Type t, char* id, char* type, int flag);
void add_symbol_to_table(symbol_node* tab, symbol_node* new_simb);
void print_symbol_table(symbol_node* tab_symb);
int strlit_length(char *str);
int num_length(int num);
void clear_symbol_table(symbol_node* current_node);
void clear_func_table(symbol_node* current_node);
void create_func_table(node_type* node, symbol_node* table, int flag_print);
int check_func_errors(symbol_node* old, symbol_node* new, int line, int col);
void funcao_vardecl(node_type* node);
void funcao_param(node_type* node);
void funcao_teste();
void funcao_aux(node_type* node);
void arvore_call(node_type* node);
void arvore_id(node_type* node);
void arvore_contas(node_type* node);
#endif // SIMBTAB_H_INCLUDED
