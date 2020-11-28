#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "ast.h"
#include "funcoes.h"


symbol_node* root_s = NULL;
int param_without_id = 0;
int void_param_error;

lista_palavras* lista = NULL;
lista_palavras* var_locais = NULL;
lista_palavras* nome_funcoes = NULL;

int funcoes[100];
int n_funcoes = 0;
int n_funcoes1 = 0;
int n_funcoes_zero = 0;

int variaveis[100];


symbol_node* ast_to_sym_table(node_type* ast, symbol_node* table){

	if(ast != NULL){

		if(strcmp(ast->type, "Program") == 0){
			table = create_symb(Global, ast->children->token, NULL, 1);

			root_s= table;

			ast_to_sym_table(ast->children, table);

			return table;

		}
		else if(strcmp(ast->type, "MethodDecl") == 0){
			n_funcoes ++;
			if(ast->children != NULL){
				create_func_table(ast->children->children, table, 1);
				ast_to_sym_table(ast->children, table);	
			}else{
				return table;
			}
		}

		else if(strcmp(ast->type, "FieldDecl") == 0){
			//create_func_table(ast->children, table, 0);
			funcao_aux(ast);
			if(ast->siblings){
				ast_to_sym_table(ast->siblings, table);
			}
			return table;
			
			//criar funcao
		}
		else if(strcmp(ast->type, "MethodHeader") == 0){
			
			//================================================
			//=== Adiciona a nome_funcoes
			lista_palavras *no, *aux;
			no = (lista_palavras*) malloc(sizeof(struct lista_palavras));

			sprintf(no->pal, "%s", ast->children->type);
			sprintf(no->id, "%s", ast->children->siblings->token);
			
			if(strcmp(no->pal, "Bool") == 0)
				strcpy(no->pal, "Boolean");
			no->pal[0] += 32;

			if(ast->children->siblings->siblings->children == NULL)
				funcoes[n_funcoes -1] = -1;

			if(nome_funcoes == NULL){
				nome_funcoes = no;
			}
			else{
				aux = nome_funcoes;
				while(aux->next){
					aux = aux->next;
				}
				aux->next = no;
			}


			//================================================
			ast_to_sym_table(ast->children, table);
			ast_to_sym_table(ast->siblings, table);

			return table;
			//criar funcao
		}
		else if(strcmp(ast->type, "MethodParams") == 0){
			//criar funcao
			if(ast->children != NULL)
				ast_to_sym_table(ast->children, table);
			
			
		}
		else if(strcmp(ast->type, "ParamDecl") == 0){
			//criar funcao
			funcoes[n_funcoes - 1] += 1;
			funcao_param(ast);
			if(ast->siblings != NULL ){
				ast_to_sym_table(ast->siblings, table);
			}
			return table;
		}
		else if(strcmp(ast->type, "MethodBody") == 0){
			if(ast->children != NULL)
				ast_to_sym_table(ast->children, table);
			else
				return table;
		}
		else if(strcmp(ast->type, "VarDecl") == 0){
			//criar funcao
			//Ver parametros da funcao
			funcao_vardecl(ast);
			if(ast->siblings != NULL ){
				ast_to_sym_table(ast->siblings, table);
			}
			return table;

		}
		else if(strcmp(ast->type, "ParseArgs") == 0){
			//criar funcao
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Bool") == 0){
			//ast->annotation = strdup("boolean");
		}
		else if(strcmp(ast->type, "Int") == 0){
			//ast->annotation = strdup("");
		}
		else if(strcmp(ast->type, "StrLit") == 0){
		}
		else if(strcmp(ast->type, "Double") == 0){
			//ast->annotation = strdup("double");
		}
		else if(strcmp(ast->type, "If") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Block") == 0){
			//criar funcao
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "While") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Return") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Print") == 0){

			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Id") == 0){
			
		}
		else if(strcmp(ast->type, "Call") == 0){
			
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Add") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Sub") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Mul") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Div") == 0){

			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Mod") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "And") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Or") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Xor") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Lshift") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Rshift") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Eq") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Ge") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Gt") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Le") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Lt") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Ne") == 0){
			ast_to_sym_table(ast->children, table);
		}
		else if(strcmp(ast->type, "Minus") == 0){
		}
		else if(strcmp(ast->type, "Not") == 0){
		}
		else if(strcmp(ast->type, "Plus") == 0){
		}
		else if(strcmp(ast->type, "DecLit") == 0){
		}
		else if(strcmp(ast->type, "RealLit") == 0){
		}
		else if(strcmp(ast->type, "BoolLit") == 0){

		}
		else if(strcmp(ast->type, "Assign") == 0){
			ast_to_sym_table(ast->children, table);
		}

		ast_to_sym_table(ast->siblings, table);

	}

	return NULL;

}



void funcao_teste(){
	int i;
	lista_palavras *lista_aux;
	printf("=========================================\n");
	printf("=========================================\n");
	printf("\n\nNumero de funcoes: %d\n", n_funcoes);

	for(i = 0;  i < n_funcoes; i++){
		printf("\tFuncao %d: %d\n", i, funcoes[i]);
	}

	printf("\n\tImprime Lista\n");

	lista_aux = lista;
	while(lista_aux != NULL){

		printf("PAL: %s  ID: %s\n", lista_aux->pal, lista_aux->id );
		lista_aux = lista_aux->next;
	}


	printf("\n\tImprime Var Locais\n");
	lista_aux = var_locais;
	while(lista_aux != NULL){
		printf("PAL: %s  ID: %s\n", lista_aux->pal, lista_aux->id );
		lista_aux = lista_aux->next;
	}

	printf("\n\tImprime funcoes tipo\n");
	lista_aux = nome_funcoes;
	while(lista_aux != NULL){
		printf("PAL: %s  ID: %s\n", lista_aux->pal, lista_aux->id );
		lista_aux = lista_aux->next;
	}

	printf("=========================================\n");
	printf("=========================================\n");
}


void arvore_contas(node_type* node){
	lista_palavras *aux;
	char funcao[100];

	//uma conta tem sempre como fiho um id
	if(strcmp(node->children->type, "Id") == 0)
		strcpy(funcao, node->children->token);
	else
		strcpy(funcao, node->children->siblings->token);

	//printf("Funcao %d: %s\n",n_funcoes, funcao);

	//==========================================================================
	//procurar o id como na arvore_id
	aux = nome_funcoes;
	if(aux != NULL){
		while(aux->next != NULL && strcmp(aux->id, funcao) != 0){
			
			if(aux->next == NULL)
				break;
			aux = aux->next;
		}
		if(aux != NULL && strcmp(aux->id, funcao) == 0){

			//printf("\tAUX: %s\n", aux->id);
			node->annotation = strdup(aux->pal);
		}
	}

	aux = lista;
	if( aux != NULL){
		while(aux->next != NULL && strcmp(aux->id, funcao) != 0){
			if(aux->next == NULL)
				break;
			aux = aux->next;
		}
		if(aux != NULL && strcmp(aux->id, funcao) == 0){

			//printf("\tAUX: %s\n", aux->id);
			node->annotation = strdup(aux->pal);
		}

	}

	aux = var_locais;
	if( aux != NULL){
		while(aux->next != NULL && strcmp(aux->id, funcao) != 0){
			if(aux->next == NULL)
				break;
			aux = aux->next;
		}
		if(aux != NULL && strcmp(aux->id, funcao) == 0){

			node->annotation = strdup(aux->pal);
		}
	}
	//==========================================================================
}

void arvore_id(node_type* node){
	lista_palavras *aux;
	char funcao[100];
	char buffer[100];
	int n_fun = 0;
	
	strcpy(funcao, node->token);
	//printf("Funcao %d: |%s|\n",n_funcoes, funcao);

	//Variaveis nome funcoes
	aux = nome_funcoes;
	if(aux != NULL){
		while(aux->next != NULL && strcmp(aux->id, funcao) != 0){
			
			if(aux->next == NULL)
				break;
			aux = aux->next;
			n_fun++;
		}
		if(aux != NULL && strcmp(aux->id, funcao) == 0){

			if(funcoes[n_fun] == 0){
				strcpy(buffer, aux->pal);
			}else{
				strcpy(buffer, "(");
				strcat(buffer, aux->pal);
				strcat(buffer, ")");
			}

			//printf("\tAUX: %s\n", aux->id);
			//node->annotation = strdup(aux->pal);
			node->annotation = strdup(buffer);
		}
	}

	aux = lista;
	if( aux != NULL){
		while(aux->next != NULL && strcmp(aux->id, funcao) != 0){
			if(aux->next == NULL)
				break;
			aux = aux->next;
		}
		if(aux != NULL && strcmp(aux->id, funcao) == 0){

			//printf("\tAUX: %s\n", aux->id);
			node->annotation = strdup(aux->pal);
		}

	}

	aux = var_locais;
	if( aux != NULL){
		while(aux->next != NULL && strcmp(aux->id, funcao) != 0){
			if(aux->next == NULL)
				break;
			aux = aux->next;
		}
		if(aux != NULL && strcmp(aux->id, funcao) == 0){

			//printf("\tAUX: %s\n", aux->id);
			node->annotation = strdup(aux->pal);
		}

	}
}

void arvore_call(node_type* node){

	lista_palavras *aux;
	char funcao[100];

	strcpy(funcao, node->children->token);
	//printf("Funcao %d: %s\n",n_funcoes, funcao);

	//vou procurar o tipo de funcao
	aux = nome_funcoes;
	while(strcmp(aux->id, funcao) != 0)
		aux = aux->next;

	//printf("AUX: %s, %s\n",aux->pal, aux->id );

	node->annotation = strdup(aux->pal);
}

void funcao_aux(node_type* node){

	lista_palavras *no, *aux;
	no = (lista_palavras*) malloc(sizeof(struct lista_palavras));

	funcoes[n_funcoes] = 0;
	n_funcoes++;

	if(strcmp(no->pal, "StringArray") != 0){
		sprintf(no->pal, "%s", node->children->type);
		sprintf(no->id, "%s", node->children->siblings->token);
		no->pal[0] = no->pal[0] + 32;
	}else{
		sprintf(no->pal, "%s", node->children->type);
		sprintf(no->id, "%s", node->children->siblings->token);
	}

	if(strcmp(no->pal, "stringArray") == 0){
		strcpy(no->pal, "String[]");
	}
	else if(strcmp(no->pal, "bool") == 0){
		strcpy(no->pal, "boolean");
	}

	if(nome_funcoes == NULL){
		nome_funcoes = no;
	}
	else{
		aux = nome_funcoes;
		while(aux->next){
			aux = aux->next;
		}
		aux->next = no;
	}
}

void funcao_param(node_type* node){
	lista_palavras *no, *aux;
	no = (lista_palavras*) malloc(sizeof(struct lista_palavras));


	if(strcmp(no->pal, "StringArray") != 0){
		sprintf(no->pal, "%s", node->children->type);
		sprintf(no->id, "%s", node->children->siblings->token);
		no->pal[0] = no->pal[0] + 32;
	}else{
		sprintf(no->pal, "%s", node->children->type);
		sprintf(no->id, "%s", node->children->siblings->token);
	}

	if(strcmp(no->pal, "stringArray") == 0){
		strcpy(no->pal, "String[]");
	}
	else if(strcmp(no->pal, "bool") == 0){
		strcpy(no->pal, "boolean");
	}

	if(lista == NULL){
		lista = no;
	}
	else{
		aux = lista;
		while(aux->next){
			aux = aux->next;
		}
		aux->next = no;
	}
}

void funcao_vardecl(node_type* node){
	lista_palavras *no, *aux;
	no = (lista_palavras*) malloc(sizeof(struct lista_palavras));

	
	sprintf(no->pal, "%s",node->children->type);
	sprintf(no->id, "%s",node->children->siblings->token);
	

	if(strcmp(no->pal, "Bool") == 0){
		strcpy(no->pal, "Boolean");
	}
	no->pal[0] += 32;


	variaveis[n_funcoes -1] ++;
	if(var_locais == NULL){
		var_locais = no;
	}
	else{
		aux = var_locais;
		while(aux->next){
			aux = aux->next;
		}
		aux->next = no;
	}
}

void create_func_table(node_type* node, symbol_node* table, int flag_print) {
	char *id;
	char buffer[1024];
	int line, col, line_decl, col_decl;

	while (strcmp(node->type,"MethodParams") != 0) {
		if(strcmp(node->type,"Id") == 0) {
			id = node->token;
			line = node->token_line;
			col = node->token_col;

		} else {
			if (strcmp(node->type,"Int") == 0) {
				sprintf(buffer, "int");
				line_decl = node->token_line;
				col_decl = node->token_col;
			} else if (strcmp(node->type,"Bool") == 0) {
				sprintf(buffer, "boolean");
				line_decl = node->token_line;
				col_decl = node->token_col;
			} else if (strcmp(node->type,"Double") == 0) {
				sprintf(buffer, "double");
				line_decl = node->token_line;
				col_decl = node->token_col;
			} else if (strcmp(node->type,"Void") == 0) {
				sprintf(buffer, "void");
				line_decl = node->token_line;
				col_decl = node->token_col;
			}
		}

		node = node->siblings;
	}
	ast_to_sym_table(node, table);	
}

symbol_node* create_symb(Symbol_Type t, char* id, char* type, int flag) {
	symbol_node* new_symbol = (symbol_node*) malloc(sizeof(symbol_node));
	char null_name [100];

	new_symbol->tipo = t;
	if (id != NULL) {
		new_symbol->id = strdup(id);
	} else {
		sprintf(null_name, "%d", param_without_id);
		new_symbol->id = strdup(null_name);
		param_without_id++;
	}

	if(new_symbol->tipo == Func) {
		new_symbol->flag.flag_print = flag;
		new_symbol->children = create_symb(Var, "return", type, 0);

	} else if (new_symbol->tipo == Var) {
		new_symbol->flag.flag_param = flag;
		new_symbol->type = strdup(type);
		new_symbol->children = NULL;

	} else if (new_symbol->tipo == Global){
		new_symbol->type = NULL;
		new_symbol->children = NULL;

	} else {
		free(new_symbol->id);
		free(new_symbol);
		printf("ERROR: TIPO DE SIMBOLO INVÁLIDO!\n");
		new_symbol = NULL;
	}

	return new_symbol;
}

void add_symbol_to_table(symbol_node* tab, symbol_node* new_simb) {
	if(tab != NULL) {
		if(tab->tipo == Global) {
			while(tab->next != NULL)
				tab = tab->next;
			tab->next = new_simb;
		} else if (tab->tipo == Func) {
			while(tab->children != NULL)
				tab = tab->children;
			tab->children = new_simb;
		}
	}
}

void print_symbol_table(symbol_node* tab_symb) {
	//funcao_teste();
	symbol_node* tab;
	lista_palavras *lista_aux, *lista_aux1;
	lista_aux = lista; 
	char args[1000] = "" ;
	int j = 0;
	int k, m;

	tab = tab_symb;
		
	printf("===== Class %s Symbol Table =====\n", tab->id);

	lista_aux1 = nome_funcoes;
	lista_aux = lista;
	while(lista_aux1 != NULL){
		lista_aux = lista;
		strcpy(args, "");
		//============================================================
		//ir para o no certo de lista_aux
		for(k = 0; k < j; k++){
			for(m = 0; m < funcoes[k]; m++){
				lista_aux = lista_aux->next;
			}
		}
		//============================================================

		//ir buscar args da funcao
		for(k = 0; k < funcoes[j] / 2; k++){
			if(k >= 1)
				strcat(args, ",");
			strcat(args, lista_aux->pal);
			
			lista_aux = lista_aux->next;
		}

		if(funcoes[j] == 0)
			printf("%s\t\t%s\n", lista_aux1->id, lista_aux1->pal );
		else if( funcoes[j] == -1)
			printf("%s\t()\t%s\n", lista_aux1->id, lista_aux1->pal );
		else
			printf("%s\t(%s)\t%s\n", lista_aux1->id, args, lista_aux1->pal );
		lista_aux1 = lista_aux1->next;
		j++;
	}
	printf("\n");


	lista_aux1 = nome_funcoes;
	for(j = 0; j < n_funcoes; j++){
		if(funcoes[j] != 0){
			//============================================================
			//ir para o no certo de lista_aux
			lista_aux = lista;
			for(k = 0; k < j; k++){
				for(m = 0; m < funcoes[k]; m++){
					lista_aux = lista_aux->next;
				}
			}
			//============================================================
			//ir buscar args da funcao
			strcpy(args, "");
			for(k = 0; k < funcoes[j] / 2; k++){
				if(k >= 1)
					strcat(args, ",");
				strcat(args, lista_aux->pal);
				
				lista_aux = lista_aux->next;
			}
			//============================================================
			printf("===== Method %s(%s) Symbol Table =====\n", lista_aux1->id, args);

			// Parametros de entrada
			printf("return\t\t%s\n", lista_aux1->pal);
			for(k = 0; k < funcoes[j] / 2; k++){
				printf("%s\t\t%s\tparam\n", lista_aux->id, lista_aux->pal);
				
				lista_aux = lista_aux->next;
			}

			// variaveis na funcao
			if(variaveis[j] != 0){

				for( k = 0; k < variaveis[j]; k++){
					printf("%s\t\t%s\n", var_locais->id, var_locais->pal);
					var_locais = var_locais->next;
				}

			}

			printf("\n");
			
		}
		lista_aux1 = lista_aux1->next;
	}
}


int num_length(int num) {
	char buffer[1024];
	
	sprintf(buffer, "%d", num);

	return strlen(buffer);
}
int strlit_length(char *str) {
	int i, j, length = 0;
	for (i = 1; i < strlen(str)-1; i++) {
		if(str[i] == '\\') {
			if(str[i+1] == 't' || str[i+1] == 'n' || str[i+1] == '\\' || str[i+1] == '\'' || str[i+1] == '\"') {
				i = i + 1;
				length++;
			} else {
				j = 1;
				while (j < 4 && isdigit(str[i+j]) && (str[i+j] - '0') > -1 && (str[i+j] - '0') < 8) {
					j = j + 1;
				}
				
				i = i + (j - 1);

				length++;
			}
		} else {
			length++;
		}
	}

	return length + 1;
}

void clear_symbol_table(symbol_node* current_node) {
	if(current_node == NULL)
		return;

	if(current_node->id != NULL) {
		free(current_node->id);
		current_node->id = NULL;
	}

	if(current_node->type != NULL) {
		free(current_node->type);
		current_node->type = NULL;
	}

	clear_symbol_table(current_node->children);
	current_node->children = NULL;
	clear_symbol_table(current_node->next);
	current_node->next = NULL;

	free(current_node);
	current_node = NULL;
}

void clear_func_table(symbol_node* current_node) {
	if(current_node == NULL)
		return;

	if(current_node->id != NULL) {
		free(current_node->id);
		current_node->id = NULL;
	}

	if(current_node->type != NULL) {
		free(current_node->type);
		current_node->type = NULL;
	}

	clear_func_table(current_node->children);
	current_node->children = NULL;

	current_node->next = NULL;
	
	free(current_node);
	current_node = NULL;
}
int check_func_errors(symbol_node* old, symbol_node* new, int line, int col) {
	
	if(strcmp(old->type, new->type) != 0) {
		/* NOT EQUAL PARAMETERS OR TYPE */
		printf("Line %d, col %d: Conflicting types (got %s, expected %s)\n", line, col, new->type, old->type);
	} else if (new->flag.flag_param == 1) {
		return 1;
	}

	return 0;
}