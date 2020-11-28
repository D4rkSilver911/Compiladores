/* Grupo: 

Carlos Miguel da Luz Lima - 2017266922
Gabriel Nunes Saraiva - 2017256436

*/

%{

	#include "y.tab.h"
	#include "ast.h"
	#include "funcoes.h"
	int contadorLinhas = 1; /* Contador linhas */
	int contadorColunas = 1; /* Contador colunas */
	int contadorAspas = 0;
	int string_valida = 0;
	int comment_linha = 0;
	int comment_coluna = 0;
	int contadorLinhasAux = 0;
	char frase[100];
	int eof = 0;

	int flag = 0;
	int flagt = 0;
	int flage1 = 0;
	int flage2 = 0;
	int flag_lex = 0;
	int flag_erro = 0;
	int flag_s = 0;

	extern node_type* root;
	symbol_node *symtab=NULL;

	#define CREATE_TOKEN() {token_struct* temp_token = (token_struct*) malloc(sizeof(struct _token_struct)); temp_token->value = strdup(yytext); temp_token->line = contadorLinhas; temp_token->col = contadorColunas; yylval.token = temp_token;}
%}

%X COMENTARIO1 COMENTARIO2 STRING2
%%
"/*"	{BEGIN COMENTARIO2; comment_linha = contadorLinhas; comment_coluna = contadorColunas; contadorColunas+=yyleng;}
\"		{BEGIN STRING2; 	contadorAspas = contadorColunas;
						contadorColunas += yyleng;}
"//"	{BEGIN COMENTARIO1; contadorColunas+=yyleng;}

<COMENTARIO1>(\n)|(\r)|(\r\n)     	{BEGIN (0);contadorLinhas++; contadorColunas = 1;}
<COMENTARIO1>.						{contadorColunas+=yyleng;}

<COMENTARIO2>"*/"					{BEGIN (0); contadorLinhasAux = 0; contadorColunas+=yyleng;}
<COMENTARIO2>(\n)|(\r)|(\r\n) 		{contadorLinhas++; contadorColunas = 1;}
<COMENTARIO2>.						{contadorColunas+=yyleng;}
<COMENTARIO2><<EOF>> 				{printf("Line %d, col %d: unterminated comment\n", comment_linha, comment_coluna); eof = 1; yyterminate();}



<STRING2>\"							{BEGIN (0);	contadorColunas+=yyleng;}
								
<STRING2>(\n)|(\r)|(\r\n)			{BEGIN (0);printf("Line %d, col %d: unterminated string literal\n", contadorLinhas, contadorAspas);contadorLinhas++; contadorColunas = 1;}

<STRING2>\\f|\\n|\\r|\\t|\\\\|\\\"	{contadorColunas+=yyleng;}

<STRING2>(\\.|\\)		{printf("Line %d, col %d: invalid escape sequence (%s)\n", contadorLinhas, contadorColunas, yytext);
						contadorColunas += yyleng;}
<STRING2><<EOF>>			{BEGIN (0);printf("Line %d, col %d: unterminated string literal\n", contadorLinhas, contadorAspas); eof = 1; yyterminate();}

<STRING2>.				{contadorColunas += yyleng;}


\"([^\\\n""\"""\r"]|\\(n|r|t|\\|\"|f))*\"															{ CREATE_TOKEN();
																									if(flage1)printf("STRLIT(%s)\n", yytext); 
																									contadorColunas+=yyleng;
																									if(!flag_lex) return STRLIT;}

[1-9][0-9_]*[0-9]|0|[1-9][0-9]*																			{ CREATE_TOKEN();
																										if(flage1)printf("INTLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return INTLIT;}



0{0,1}"."[0-9]+																							{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}"."[0-9][0-9_]*[1-9]																				{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0"."[0-9]*[eE][+-]{0,1}[0-9]+																			{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}"."[0-9]+[eE][+-]{0,1}[0-9]+																		{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}"."[0-9]+[eE][+-]{0,1}[0-9][0-9_]*[0-9]															{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}"."[0-9][0-9_]*[0-9][eE][+-]{0,1}[0-9][0-9_]*[0-9]												{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}"."[0-9][0-9_]*[0-9][eE][+-]{0,1}[0-9]+															{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}[1-9]"."[Ee]*[+-]*[0-9][0-9_]*[0-9]																{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}[1-9]+"."[0-9]*[eE][+-]{0,1}[0-9]+ 																{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}[1-9]+"."[0-9]*[eE][+-]{0,1}[0-9][0-9_]*[0-9]														{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}[1-9]+"."[0-9][0-9_]*[0-9][eE][+-]{0,1}[0-9][0-9_]*[0-9]											{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}[1-9]+"."[0-9][0-9_]*[0-9][eE][+-]{0,1}[0-9]+														{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}[1-9]*"."[0-9]+																					{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}[1-9]+[eE][+-]{0,1}[0-9]+																			{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}[1-9]+[eE][+-]{0,1}[0-9][0-9_]*[0-9]																{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}[1-9]*"."[0-9][0-9_]*[0-9]																		{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

[0-9][0-9_]*[0-9]"."[0-9][0-9_]*[0-9]																	{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

[0-9][0-9_]*[0-9]"."[0-9]+																				{ CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

[0-9][0-9_]*[0-9]"."[0-9]*[eE][+-]{0,1}[0-9]+															{CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

[0-9][0-9_]*[0-9]"."[0-9]*[eE][+-]{0,1}[0-9][0-9_]*[0-9]												{CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

[0-9][0-9_]*[0-9]"."[0-9][0-9_]*[0-9][eE][+-]{0,1}[0-9]+												{CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

[0-9][0-9_]*[0-9]"."[0-9][0-9_]*[0-9][eE][+-]{0,1}[0-9][0-9_]*[0-9]										{CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

[0-9][0-9_]*[0-9][eE][+-]{0,1}[0-9]+																	{CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

[0-9][0-9_]*[0-9][eE][+-]{0,1}[0-9][0-9_]*[0-9]															{CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0{0,1}[0-9]"." 																							{CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

[0-9][0-9_]*[0-9]"." 																					{CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}



0[eE][+-]{0,1}[0-9] 																					{CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}

0[eE][+-]{0,1}[0-9][0-9_]*[0-9] 																		{CREATE_TOKEN();
																										if(flage1)printf("REALLIT(%s)\n", yytext);
																										contadorColunas += yyleng;
																										if(!flag_lex) return REALLIT;}


" "|"\t"|"\f"			{contadorColunas += yyleng;}

"true"					{CREATE_TOKEN();
						if(flage1)printf("BOOLLIT(true)\n");
						contadorColunas += yyleng;
						if(!flag_lex) return BOOLLIT;}

"false"					{CREATE_TOKEN();
						if(flage1)printf("BOOLLIT(false)\n");
						contadorColunas += yyleng;
						if(!flag_lex) return BOOLLIT;}

"&&"					{CREATE_TOKEN();if(flage1)printf("AND\n");
						contadorColunas += yyleng;
						if(!flag_lex) return AND;}

"="						{CREATE_TOKEN();if(flage1)printf("ASSIGN\n");
						contadorColunas += yyleng;
						if(!flag_lex) return ASSIGN;}

"*"						{CREATE_TOKEN();if(flage1)printf("STAR\n");
						contadorColunas += yyleng;
						if(!flag_lex) return STAR;}

","						{CREATE_TOKEN();if(flage1)printf("COMMA\n");
						contadorColunas += yyleng;
						if(!flag_lex) return COMMA;}

"/"						{CREATE_TOKEN();if(flage1)printf("DIV\n");
						contadorColunas += yyleng;
						if(!flag_lex) return DIV;}

"=="					{CREATE_TOKEN();if(flage1)printf("EQ\n");
						contadorColunas += yyleng;
						if(!flag_lex) return EQ;}

">="					{CREATE_TOKEN();if(flage1)printf("GE\n");
						contadorColunas += yyleng;
						if(!flag_lex) return GE;}

">"						{CREATE_TOKEN();if(flage1)printf("GT\n");
						contadorColunas += yyleng;
						if(!flag_lex) return GT;}

"{"						{CREATE_TOKEN();if(flage1)printf("LBRACE\n");
						contadorColunas += yyleng;
						if(!flag_lex) return LBRACE;}

"<="					{CREATE_TOKEN();if(flage1)printf("LE\n");
						contadorColunas += yyleng;
						if(!flag_lex) return LE;}

"("						{CREATE_TOKEN();if(flage1)printf("LPAR\n");
						contadorColunas += yyleng;
						if(!flag_lex) return LPAR;}

"["						{CREATE_TOKEN();if(flage1)printf("LSQ\n");
						contadorColunas += yyleng;
						if(!flag_lex) return LSQ;}

"<"						{CREATE_TOKEN();if(flage1)printf("LT\n");
						contadorColunas += yyleng;
						if(!flag_lex) return LT;}

"-"						{CREATE_TOKEN();if(flage1)printf("MINUS\n");
						contadorColunas += yyleng;
						if(!flag_lex) return MINUS;}

"%"						{CREATE_TOKEN();if(flage1)printf("MOD\n");
						contadorColunas += yyleng;
						if(!flag_lex) return MOD;}

"!="					{CREATE_TOKEN();if(flage1)printf("NE\n");
						contadorColunas += yyleng;
						if(!flag_lex) return NE;}

"!"						{CREATE_TOKEN();if(flage1)printf("NOT\n");
						contadorColunas += yyleng;
						if(!flag_lex) return NOT;}

"||"					{CREATE_TOKEN();if(flage1)printf("OR\n");
						contadorColunas += yyleng;
						if(!flag_lex) return OR;}

"+"						{CREATE_TOKEN();if(flage1)printf("PLUS\n");
						contadorColunas += yyleng;
						if(!flag_lex) return PLUS;}

"}"						{CREATE_TOKEN();if(flage1)printf("RBRACE\n");
						contadorColunas += yyleng;
						if(!flag_lex) return RBRACE;}

")"						{CREATE_TOKEN();if(flage1)printf("RPAR\n");
						contadorColunas += yyleng;
						if(!flag_lex) return RPAR;}

"]"						{CREATE_TOKEN();if(flage1)printf("RSQ\n");
						contadorColunas += yyleng;
						if(!flag_lex) return RSQ;}

";"						{CREATE_TOKEN();if(flage1)printf("SEMICOLON\n");
						contadorColunas += yyleng;
						if(!flag_lex) return SEMICOLON;}

"->"					{CREATE_TOKEN();if(flage1)printf("ARROW\n");
						contadorColunas += yyleng;
						if(!flag_lex) return ARROW;}

"<<"					{CREATE_TOKEN();if(flage1)printf("LSHIFT\n");
						contadorColunas += yyleng;
						if(!flag_lex) return LSHIFT;}

">>"					{CREATE_TOKEN();if(flage1)printf("RSHIFT\n");
						contadorColunas += yyleng;
						if(!flag_lex) return RSHIFT;}

"^"						{CREATE_TOKEN();if(flage1)printf("XOR\n");
						contadorColunas += yyleng;
						if(!flag_lex) return XOR;}

"boolean"				{CREATE_TOKEN();if(flage1)printf("BOOL\n");
						contadorColunas += yyleng;
						if(!flag_lex) return BOOL;}

"class"					{CREATE_TOKEN();if(flage1)printf("CLASS\n");
						contadorColunas += yyleng;
						if(!flag_lex) return CLASS;}

".length"				{CREATE_TOKEN();if(flage1)printf("DOTLENGTH\n");
						contadorColunas += yyleng;
						if(!flag_lex) return DOTLENGTH;}

"double"				{CREATE_TOKEN();if(flage1)printf("DOUBLE\n");
						contadorColunas += yyleng;
						if(!flag_lex) return DOUBLE;}

"else"					{CREATE_TOKEN();if(flage1)printf("ELSE\n");
						contadorColunas += yyleng;
						if(!flag_lex) return ELSE;}

"if"					{CREATE_TOKEN();if(flage1)printf("IF\n");
						contadorColunas += yyleng;
						if(!flag_lex) return IF;}

"int"					{CREATE_TOKEN();if(flage1)printf("INT\n");
						contadorColunas += yyleng;
						if(!flag_lex) return INT;}

"System.out.print"		{CREATE_TOKEN();if(flage1)printf("PRINT\n");
						contadorColunas += yyleng;
						if(!flag_lex) return PRINT;}

"Integer.parseInt"		{CREATE_TOKEN();if(flage1)printf("PARSEINT\n");
						contadorColunas += yyleng;
						if(!flag_lex) return PARSEINT;}

"public"				{CREATE_TOKEN();if(flage1)printf("PUBLIC\n");
						contadorColunas += yyleng;
						if(!flag_lex) return PUBLIC;}

"return"				{CREATE_TOKEN();if(flage1)printf("RETURN\n");
						contadorColunas += yyleng;
						if(!flag_lex) return RETURN;}

"static"				{CREATE_TOKEN();if(flage1)printf("STATIC\n");
						contadorColunas += yyleng;
						if(!flag_lex) return STATIC;}

"String"				{CREATE_TOKEN();if(flage1)printf("STRING\n");
						contadorColunas += yyleng;
						if(!flag_lex) return STRING;}

"void"					{CREATE_TOKEN();if(flage1)printf("VOID\n");
						contadorColunas += yyleng;
						if(!flag_lex) return VOID;}

"while"					{CREATE_TOKEN();if(flage1)printf("WHILE\n");
						contadorColunas += yyleng;
						if(!flag_lex) return WHILE;}

"++"|"--"|"null"|"Integer"|"System"|"break"|"byte"|"case"|"catch"|"char"|"const"|"enum"|"extends"|"final"|"finally"|"float"|"for"|"implements" 	{CREATE_TOKEN();if(flage1)printf("RESERVED(%s)\n", yytext); contadorColunas+=yyleng; if(!flag_lex) return RESERVED;}
"import"|"instanceof"|"interface"|"long"|"native"|"new"|"protected"|"short"|"strictfp"|"super"|"this"|"throw"|"throws"|"transient"|"try"		{CREATE_TOKEN();if(flage1)printf("RESERVED(%s)\n", yytext);contadorColunas+=yyleng;if(!flag_lex) return RESERVED;}
"volatile"|"abstract"|"continue"|"volatile"|"switch"|"assert"|"default"|"package"|"synchronized"|"synchronized"|"do"|"goto"|"private"			{CREATE_TOKEN();if(flage1)printf("RESERVED(%s)\n", yytext);contadorColunas+=yyleng;if(!flag_lex) return RESERVED;}


			


[a-zA-Z$_][0-9a-zA-Z$_]*																					{CREATE_TOKEN();if(flage1)printf("ID(%s)\n", yytext);
																											contadorColunas += yyleng;
																											if(!flag_lex) return ID;};
																							
<<EOF>>								{contadorColunas+=yyleng; return yytext[0];}
\n|\r|\r\n 																									{contadorLinhas++;
																											contadorColunas = 1;};
. {printf("Line %d, col %d: illegal character (%s)\n", contadorLinhas, contadorColunas, yytext);
											contadorColunas += yyleng;};


%%
int main(int argc, char* argv[] ){
	
	if(argc > 1 && strcmp(argv[1], "-l") == 0){
		flage1 = 1; /*Flag -l, contudo como li mal pensei que era a -e1, não me apeteceu mudar o nome again*/
		flag_lex = 1;
	}
	else if(argc > 1 && strcmp(argv[1], "-t") == 0){
		flagt = 1;
	}
	else if(argc > 1 && strcmp(argv[1], "-e1") == 0){
		flag_lex = 1;
	}
	else if(argc > 1 && strcmp(argv[1], "-s") == 0){
		flag_s = 1;
	}
	

	if(flag_lex){
		yylex();
			
	}
	else{
		yyparse();
		if(flagt && !flag_erro){
			print_ast(root, 0);
		}
		if(!flag_erro){ 
			symtab = ast_to_sym_table(root, NULL);
			if(flag_s){
				//Imprimir a tabela.
				print_symbol_table(symtab);
				print_ast(root, 0);
			}
			clear_symbol_table(symtab);

		}
		clear_ast(root);
	}
	return 0;	

	
}

int yywrap(){
	return 1;
}
