%{
#include <stdio.h>
#include "ast.h"
#include <string.h>


int yylex (void);
void yyerror(char* s);

extern int yyleng;
extern char* yytext;
extern int flag_erro;
extern int contadorLinhas;
extern int contadorColunas;
extern int eof;

char* type_aux;
int aux1 = 0;
int aux2 = 0;
int block_aux = 0;
node_type* root = NULL;
node_type* aux_node = NULL;
node_type* aux_node2 = NULL;


%}

%union{
    struct _token_struct* token;
    struct node_type* node;
}

%token <token> AND ASSIGN STAR COMMA DIV EQ GE GT LBRACE LE LPAR LSQ LT MINUS MOD NE NOT 
%token <token> OR PLUS RBRACE RPAR RSQ SEMICOLON ARROW LSHIFT RSHIFT XOR BOOL CLASS 
%token <token> DOTLENGTH DOUBLE ELSE IF INT PRINT PARSEINT PUBLIC RETURN STATIC STRING VOID WHILE
%token <token> STRLIT RESERVED INTLIT REALLIT ID BOOLLIT


%type<node> List Start Program MethodDecl FieldDecl MethodHeader MethodBody Type CommaIDList CommaIDList2 CommaTypeIdList
FormalParams StateVarList VarDecl StatementList Statement CommaExprList Assignment ParseArgs Expr Expr_extra
MethodInvocation

%left COMMA
%right ASSIGN
%left OR
%left XOR
%left AND
%left EQ NE
%left LT GT LE GE
%left LSHIFT RSHIFT
%left PLUS MINUS
%left STAR DIV MOD
%right NOT
%right preced
%left LBRACE LPAR LSQ RSQ RPAR RBRACE
%nonassoc ELSE

%%
Start: 
        Program        						{$$ = create_node("Program", NULL, -1, -1); root = $$; add_child($$, $1);}
        ;
Program:
        CLASS ID LBRACE List RBRACE       	{$$ = create_node("Id", $2->value, $2->line, $2->col); add_sibling($$, $4);}
        ;

List: /*epsilon*/  							{$$ = create_node("Null", NULL, -1, -1);}
		| List MethodDecl                   {if(is_null_node($1)==0) {$$ = $1; if(is_null_node($2)==0) {add_sibling($$, $2);} } else if(is_null_node($2) == 0) {$$ = $2;}}

		| List FieldDecl                    {if(is_null_node($1)==0) {$$ = $1; if(is_null_node($2)==0) {add_sibling($$, $2);} } else if(is_null_node($2) == 0) {$$ = $2;}}

        | List SEMICOLON                    {$$ = $1;}       
        ;



MethodDecl: 
        PUBLIC STATIC MethodHeader MethodBody   {$$ = create_node("MethodDecl", NULL, -1, -1); add_sibling($3, $4); 
                                                    add_child($$, $3);}                                                                      
        ;

FieldDecl: 
        PUBLIC STATIC Type ID CommaIDList SEMICOLON     {$$ = create_node("FieldDecl", NULL, -1, -1); add_sibling($3, create_node("Id", $4->value, $4->line, $4->col)); 
                                                            if(is_null_node($5) == 0) {add_sibling($$, $5);} add_child($$, $3);}

        | error SEMICOLON 							{$$ = create_node("Error", NULL, -1, -1);}
        ;


CommaIDList: /*epsilon*/  				{$$ = create_node("Null", NULL, -1, -1);}

        | CommaIDList COMMA ID      	{if(is_null_node($1) == 0) { $$ = $1; aux_node = create_node("FieldDecl", NULL, -1, -1); add_sibling($$, aux_node);
                                            aux_node2 = create_node(type_aux, NULL, -1, -1); add_child(aux_node, aux_node2); add_sibling(aux_node2, create_node("Id", $3->value, $3->line, $3->col));}
                                        else{$$ = create_node("FieldDecl", NULL, -1, -1); aux_node2 = create_node(type_aux, NULL, -1, -1); add_child($$, aux_node2);
                                            aux_node = create_node("Id", $3->value, $3->line, $3->col); add_sibling(aux_node2, aux_node);}}
        ;


Type:
        BOOL                  {$$ = create_node("Bool", NULL, $1->line, $1->col); type_aux = "Bool";}                              
        | INT                 {$$ = create_node("Int", NULL, $1->line, $1->col); type_aux = "Int";}                              
        | DOUBLE              {$$ = create_node("Double", NULL, $1->line, $1->col); type_aux = "Double";}                              
        ;

MethodHeader:
        Type ID LPAR FormalParams RPAR      {$$ = create_node("MethodHeader", NULL, -1, -1);  aux_node = create_node("Id", $2->value, $2->line, $2->col); add_sibling($1, aux_node); add_sibling($1, $4);
                                                 add_child($$, $1);}

        | VOID ID LPAR FormalParams RPAR    {$$ = create_node("MethodHeader", NULL, -1, -1); aux_node = create_node("Void", NULL, $1->line, $1->col); add_sibling(aux_node, create_node("Id", $2->value, $2->line, $2->col)); 
                                                add_sibling(aux_node, $4); add_child($$, aux_node);}				
        ;

FormalParams:/*epsilon*/            {$$ = create_node("MethodParams", NULL, -1, -1);}

        | Type ID CommaTypeIdList	{$$ = create_node("MethodParams", NULL, -1, -1); aux_node2 = create_node("ParamDecl", NULL, -1, -1); add_child($$, aux_node2); 
                                        aux_node = create_node("Id", $2->value, $2->line, $2->col); add_sibling($1, aux_node); if(is_null_node($3)==0){add_sibling(aux_node2, $3);} 
                                            add_child(aux_node2, $1);}

        | STRING LSQ RSQ ID     	{$$ = create_node("MethodParams", NULL, -1, -1); aux_node2 = create_node("ParamDecl", NULL, -1, -1); add_child($$, aux_node2); 
                                        aux_node = create_node("StringArray", NULL, -1, -1); add_sibling(aux_node, create_node("Id", $4->value, $4->line, $4->col)); add_child($$, aux_node2); add_child(aux_node2, aux_node); }				
        ;

CommaTypeIdList:/*Epsilon*/				{$$ = create_node("Null", NULL, -1, -1);}

        | CommaTypeIdList COMMA Type ID   {if(is_null_node($1) == 0) { $$ = $1; aux_node = create_node("ParamDecl", NULL, -1, -1); add_sibling($$, aux_node);
                                            aux_node2 = $3; add_child(aux_node, aux_node2); add_sibling(aux_node2, create_node("Id", $4->value, $4->line, $4->col));}
                                        else{$$ = create_node("ParamDecl", NULL, -1, -1); aux_node2 = $3; add_child($$, aux_node2);
                                            aux_node = create_node("Id", $4->value, $4->line, $4->col); add_sibling(aux_node2, aux_node);}}

        ;

MethodBody:
        LBRACE StateVarList RBRACE      {$$ = create_node("MethodBody",NULL, -1, -1); if(is_null_node($2) == 0){ add_child($$, $2);}}                                        
        ;

StateVarList: /*epsilon*/  {$$ = create_node("Null", NULL, -1, -1);}

        | StateVarList Statement   {if(is_null_node($1) == 0) {$$ = $1; add_sibling($$, $2); } else {$$ = $2;}}

        | StateVarList VarDecl     {if(is_null_node($1) == 0) {$$ = $1; add_sibling($$, $2); } else {$$ = $2;}}
        ;

VarDecl:
        Type ID CommaIDList2 SEMICOLON  {$$ = create_node("VarDecl", NULL, -1, -1); add_sibling($1, create_node("Id", $2->value, $2->line, $2->col)); 
                                            if(is_null_node($3) == 0) {add_sibling($$, $3);} add_child($$, $1);}
        ;

CommaIDList2: /*epsilon*/  				{$$ = create_node("Null", NULL, -1, -1);}

        | CommaIDList2 COMMA ID      	{if(is_null_node($1) == 0) { $$ = $1; aux_node = create_node("VarDecl", NULL, -1, -1); add_sibling($$, aux_node);
                                            aux_node2 = create_node(type_aux, NULL, -1, -1); add_child(aux_node, aux_node2); add_sibling(aux_node2, create_node("Id", $3->value, $3->line, $3->col));}
                                        else{$$ = create_node("VarDecl", NULL, -1, -1); aux_node2 = create_node(type_aux, NULL, -1, -1); add_child($$, aux_node2);
                                            aux_node = create_node("Id", $3->value, $3->line, $3->col); add_sibling(aux_node2, aux_node);}}
        ;

StatementList:/*epsilon*/ 			{$$ = create_node("Null", NULL, -1, -1);}

        | StatementList Statement  {if(is_null_node($1) == 0) {
                                        $$ = $1; 
                                        if( verifica_no2($2) == 0){ 
                                            add_sibling($1, $2);
                                        }
                                    }else if( verifica_no2($2) == 0){
                                        $$ = $2;
                                    }else{ 
                                        $$ = create_node("Null", NULL, -1, -1);} 
                                    }
        ;

Statement:
        LBRACE StatementList RBRACE                         {   if(is_null_node($2) == 0){
                                                                    if(verifica_no($2) == 1){
                                                                        $$ = $2;
                                                                    }
                                                                    else if( number_siblings($2) >= 1){ 
                                                                        aux_node = create_node("Block", NULL, -1, -1); $$ = aux_node; add_child($$, $2);   
                                                                    }else{
                                                                        $$ = $2;
                                                                    }
                                                                }else{
                                                                    $$ = create_node("Null1", NULL, -1, -1);
                                                                }
                                                            }                                                    

        | IF LPAR Expr_extra RPAR Statement ELSE Statement 	{ $$ = create_node("If", NULL, $1->line, $1->col); add_child($$, $3);
                                                                aux1 = number_siblings($5); aux2 = number_siblings($7); block_aux = aux1 + aux2;


                                                                if( block_aux == 0){
                                                                    if(is_null_node($5) == 0 && is_null_node($7) == 0){
                                                                        if(verifica_no($5) == 1 && verifica_no($7) == 1){
                                                                            aux_node = create_node("Block", NULL, $1->line, $1->col); add_sibling($3, aux_node); 
                                                                            add_sibling($3, create_node("Block", NULL, $1->line, $1->col));

                                                                        }else if(verifica_no($5) == 1){
                                                                            add_sibling($3, create_node("Block", NULL, $1->line, $1->col)); add_sibling($3, $7); 

                                                                        }else if(verifica_no($7) == 1){
                                                                            add_sibling($3, create_node("Block", NULL,$1->line, $1->col));add_sibling($3, $5); 

                                                                        }else if(verifica_no2($5) == 1 && verifica_no2($7) == 1){
                                                                            aux_node = create_node("Block", NULL,$1->line, $1->col); add_sibling($3, aux_node); 
                                                                            add_sibling($3, create_node("Block", NULL,$1->line, $1->col));

                                                                        }else if(verifica_no2($5) == 1){
                                                                            add_sibling($3, create_node("Block", NULL,$1->line, $1->col)); add_sibling($3, $7);
                                                                        
                                                                        }else if(verifica_no2($7) == 1){
                                                                            add_sibling($3, create_node("Block", NULL,$1->line, $1->col));add_sibling($3, $5);

                                                                        }else{
                                                                            add_sibling($3, $5); add_sibling($3, $7);
                                                                        }
                                                                    }
                                                                    else{
                                                                        aux_node = create_node("Block", NULL,$1->line, $1->col); add_sibling($3, aux_node); 
                                                                        add_sibling($3, create_node("Block", NULL,$1->line, $1->col));
                                                                    }
                                                                }
                                                                else{
                                                                    aux_node = create_node("Block", NULL,$1->line, $1->col); add_sibling($3, aux_node); add_child(aux_node, $5);
                                                                    add_sibling($5, $7); add_sibling($3, create_node("Block", NULL,$1->line, $1->col));
                                                                }
                                                            }
                                                                
        | IF LPAR Expr_extra RPAR Statement                 { $$ = create_node("If", NULL,$1->line, $1->col); add_child($$, $3);  block_aux = number_siblings($5);

                                                                if(is_null_node($5) != 0){
                                                                    aux_node = create_node("Block", NULL,$1->line, $1->col); add_sibling($3, aux_node);
                                                                }
                                                                else if(verifica_no($5) == 1){
                                                                    aux_node = create_node("Block", NULL,$1->line, $1->col); add_sibling($3, aux_node); 
                                                                    add_sibling($3, create_node("Block", NULL,$1->line, $1->col));
                                                                }
                                                                else if(verifica_no2($5) == 1){
                                                                    aux_node = create_node("Block", NULL,$1->line, $1->col); add_sibling($3, aux_node); 
                                                                    add_sibling($3, create_node("Block", NULL,$1->line, $1->col));
                                                                }
                                                                else if(block_aux >= 1){
                                                                    aux_node = create_node("Block", NULL,$1->line, $1->col); add_sibling($3, aux_node);
                                                                    add_child(aux_node, $5); add_sibling($3, create_node("Block", NULL,$1->line, $1->col)); 
                                                                }
                                                                else{
                                                                    add_sibling($3, $5); aux_node = create_node("Block", NULL,$1->line, $1->col);
                                                                    add_sibling($3, aux_node);
                                                                }
                                                            }

        | WHILE LPAR Expr_extra RPAR Statement             	{  $$ = create_node("While", NULL,$1->line, $1->col); add_child($$, $3); block_aux = number_siblings($5);

                                                                if(is_null_node($5) != 0){
                                                                    aux_node = create_node("Block", NULL,$1->line, $1->col); add_sibling($3, aux_node);
                                                                }
                                                                else if( block_aux == 0){
                                                                    if(verifica_no2($5) == 1){
                                                                        aux_node = create_node("Block", NULL,$1->line, $1->col); add_sibling($3, aux_node);
                                                                    }else if(verifica_no($5) == 1){
                                                                        aux_node = create_node("Block", NULL,$1->line, $1->col); add_sibling($3, aux_node);
                                                                    }
                                                                    else{
                                                                        add_sibling($3, $5);
                                                                    }
                                                                }
                                                                else{
                                                                    add_sibling($3, $5);
                                                                }


                                                            }      

        | RETURN Expr_extra SEMICOLON                       {$$ = create_node("Return", NULL,$1->line, $1->col); add_child($$, $2);}   

        | RETURN SEMICOLON 									{$$ = create_node("Return", NULL,$1->line, $1->col); }

        | MethodInvocation SEMICOLON                        {$$ = $1;}      

        | Assignment SEMICOLON                              {$$ = $1;}

        | ParseArgs SEMICOLON                               { $$ = $1;} 

        | SEMICOLON 										{$$ = create_node("Null2", NULL,-1, -1);}
        
        | PRINT LPAR Expr_extra RPAR SEMICOLON              {$$ = create_node("Print", NULL,$1->line, $1->col);add_child($$, $3);}

        | PRINT LPAR STRLIT RPAR SEMICOLON    			    {$$ = create_node("Print", NULL,$1->line, $1->col);add_child($$, create_node("StrLit", $3->value, $3->line, $3->col)); }

        | error SEMICOLON     								{$$ = create_node("Error", NULL, -1, -1);}    
        ;

MethodInvocation:
        ID LPAR Expr_extra CommaExprList RPAR  {$$ = create_node("Call", NULL,$1->line, $1->col); aux_node=create_node("Id", $1->value, $1->line, $1->col); add_sibling(aux_node, $3);
                                                    if(is_null_node($4) == 0) {add_sibling(aux_node, $4);} add_child($$, aux_node);} 

        |ID LPAR RPAR   						{$$ = create_node("Call", NULL,$1->line, $1->col); aux_node=create_node("Id", $1->value, $1->line, $1->col); add_child($$, aux_node);} 

        |ID LPAR error RPAR  					{$$ = create_node("Error", NULL, -1, -1);} 
        ;

CommaExprList:/*Epsilon*/ {$$ = create_node("Null", NULL, -1, -1);}

        | CommaExprList COMMA Expr_extra  { if(is_null_node($1) == 0) {$$ = $1; add_sibling($$, $3);} else {$$ = $3;} }
        ;

Assignment:
        ID ASSIGN Expr_extra  {$$ = create_node("Assign", NULL, $2->line, $2->col); aux_node = create_node("Id", $1->value, $1->line, $1->col); add_sibling(aux_node, $3); add_child($$, aux_node); }                         
        ;

ParseArgs:
        PARSEINT LPAR ID LSQ Expr_extra RSQ RPAR {$$ = create_node("ParseArgs", NULL ,$1->line, $1->col); aux_node = create_node("Id", $3->value, $3->line, $3->col); add_sibling(aux_node, $5); add_child($$, aux_node);}

        |PARSEINT LPAR error RPAR  				{$$ = create_node("Error", NULL, -1, -1);} 
        ;


Expr:
        Expr PLUS Expr    		{$$ = create_node("Add", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                              
        | Expr MINUS Expr   	{$$ = create_node("Sub", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                             
        | Expr STAR Expr    	{$$ = create_node("Mul", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                                  
        | Expr DIV Expr      	{$$ = create_node("Div", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                                 
        | Expr MOD Expr       	{$$ = create_node("Mod", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                               

        | Expr AND Expr         {$$ = create_node("And", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                              
        | Expr OR Expr          {$$ = create_node("Or", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                       
        | Expr XOR Expr        	{$$ = create_node("Xor", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                               
        | Expr LSHIFT Expr      {$$ = create_node("Lshift", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                             
        | Expr RSHIFT Expr      {$$ = create_node("Rshift", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                              

        | Expr EQ Expr          {$$ = create_node("Eq", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                              
        | Expr GE Expr          {$$ = create_node("Ge", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                              
        | Expr GT Expr          {$$ = create_node("Gt", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                              
        | Expr LE Expr          {$$ = create_node("Le", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                              
        | Expr LT Expr          {$$ = create_node("Lt", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                              
        | Expr NE Expr          {$$ = create_node("Ne", NULL, $2->line, $2->col); add_sibling($1, $3); add_child($$, $1);}                            

        | MINUS Expr %prec preced {$$ = create_node("Minus", NULL, $1->line, $1->col); add_child($$, $2);}               
        | NOT Expr %prec preced   {$$ = create_node("Not", NULL, $1->line, $1->col); add_child($$, $2);}                            
        | PLUS Expr %prec preced  {$$ = create_node("Plus", NULL, $1->line, $1->col); add_child($$, $2);}             

        | LPAR Expr_extra RPAR    {$$ = $2;}                               

        | MethodInvocation         {$$ = $1;}                                                      
        | ParseArgs                {$$ = $1;}                         

        | ID DOTLENGTH             {aux_node = create_node("Id", $1->value, $1->line, $1->col); $$ = create_node("Length", NULL, $2->line, $2->col); add_child($$, aux_node);}                         
        | ID                       {$$ = create_node("Id", $1->value, $1->line, $1->col);}                            

        | INTLIT                  {$$ = create_node("DecLit", $1->value, $1->line, $1->col);}                          
        | REALLIT                  {$$ = create_node("RealLit", $1->value, $1->line, $1->col);}                         
        | BOOLLIT                  {$$ = create_node("BoolLit", $1->value, $1->line, $1->col);}                        
        | LPAR error RPAR 		{$$ = create_node("Error", NULL, -1, -1);} 
        ;

Expr_extra: 
    Assignment {$$ = $1;}
    | Expr    {$$ = $1;}

    ;

  

%%

void yyerror(char *s) {
    int size = contadorColunas-yyleng;
    if(size == 0){
        size = 1;
    }
    if(eof == 1){
        size = contadorColunas;
    }
	flag_erro = 1;
    printf("Line %d, col %d: %s: %s\n", contadorLinhas, size, s, yytext);
}

