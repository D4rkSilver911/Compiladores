#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

node_type* create_node(char* type, char* token, int line, int col) {
	node_type* new_node = (node_type*) malloc(sizeof(node_type));

	new_node->type = strdup(type);
	new_node->token = token;

	new_node->token_line = line;
	new_node->token_col = col;
	new_node->annotation = NULL;

	new_node->children = NULL;
	new_node->siblings = NULL;

	return new_node;
}

void add_child(node_type* parent, node_type* child) {
	parent->children = child;
}

void add_sibling(node_type* first, node_type* last) {
	if(first != NULL) {
		while(first->siblings != NULL)
			first = first->siblings;
		first->siblings = last;
	}
}

int have_sibling(node_type* node) {
	if(node != NULL && node->siblings != NULL)
		return 1;
	else
		return 0;
}

int is_null_node(node_type* node) {
	if(node != NULL && node->type != NULL && strcmp(node->type,"Null") == 0) {
		free(node->type);
		node->type = NULL;

		free(node);
		node = NULL;

		return 1;
	} else {
		return 0;
	}
}

node_type* add_typespec_to_declarations(node_type* typespec, node_type* declarations_list) {
	node_type* aux = declarations_list;
	node_type* new_node_typespec = NULL;

	while(aux != NULL) {
		new_node_typespec = create_node(typespec->type, NULL, -1, -1);

		new_node_typespec->siblings = aux->children;

		aux->children = new_node_typespec;

		aux = aux->siblings;
	}

	return declarations_list;
}

void print_ast(node_type* current_node, int nb_points) {
	int i;

	if(current_node == NULL)
		return;
	if(strcmp(current_node->type, "Null") != 0 && strcmp(current_node->type, "Null1") != 0 && strcmp(current_node->type, "Null2") != 0) 
		for(i=0; i<nb_points; i++)
			printf(".");

	if(current_node->token != NULL)
		printf("%s(%s)\n", current_node->type, current_node->token);
	else
		if(strcmp(current_node->type, "Null") != 0 && strcmp(current_node->type, "Null1") != 0 && strcmp(current_node->type, "Null2") != 0) 
			printf("%s\n", current_node->type);

	print_ast(current_node->children, nb_points+2);
	print_ast(current_node->siblings, nb_points);
}

void clear_ast(node_type* current_node) {
	
	if(current_node == NULL)
		return;

	if(current_node->token != NULL) {
		free(current_node->token);
		current_node->token = NULL;
	}

	if(current_node->type != NULL) {
		free(current_node->type);
		current_node->type = NULL;
	}

	clear_ast(current_node->children);
	current_node->children = NULL;
	clear_ast(current_node->siblings);
	current_node->siblings = NULL;

	free(current_node);
	current_node = NULL;
}
int number_siblings( node_type* no){

	int num = 0;
	if(is_null_node(no) == 0){
		while(no->siblings != NULL){

			if(is_null_node(no) == 0){
				num++;
			}
			no = no->siblings;
		}
	}
	return num;
}

int verifica_no( node_type* no){

	if(strcmp(no->type, "Null1") == 0){
		return 1;
	}
	else
		return 0;
}

int verifica_no2( node_type* no){

	if(strcmp(no->type, "Null2") == 0){
		return 1;
	}
	else
		return 0;
}
