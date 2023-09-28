%{
#include <iostream>
#include <algorithm>
#include <string>
#include <fstream>
char abs_sql[10240];
%}
%option noyywrap c++
DIGIT       [0-9]
ALPHA       [a-zA-Z_]
ALPHANUM    {ALPHA}|{DIGIT}
IDENTIFIER  {ALPHA}{ALPHANUM}*
NUMBER      {DIGIT}+(\.{DIGIT}+)?([eE][+-]?{DIGIT}+)?
COMMENT_SINGLE_LINE                         (--\ .*\n)|(#\ .*\n)
COMMENT_MULTI_LINE_BEGIN                    "/*"
COMMENT_MULTI_LINE_END                      "*/"
ANY                                         .|\n
SPACE                                       [[:space:]]+
REPLACE_KEY                                 (?i:select)|(?i:set)|(?i:update)|(?i:delete)|(?i:insert)
REPLACE_VALUE                               {NUMBER}|(\"([^"\\]|\\.)*\")|(\'([^'\\]|\\.)*\')|(?i:NULL)|(?i:true)|(?i:false)
IN_MULTI_VALUE                              (?i:in){SPACE}?"("({REPLACE_VALUE}|,|{SPACE})+")"
INSERT_MULTI_VALUE                          (,{SPACE}?"("({REPLACE_VALUE}|,|{SPACE})+")")+{SPACE}?;
END                                         ;
%x COMMENT REPLACE NO_REPLACE S_IN_MULTI_VALUE S_INSERT_MULTI_VALUE
%%
<INITIAL>{SPACE}    {}
<INITIAL>{COMMENT_MULTI_LINE_BEGIN} {
    BEGIN(COMMENT);
    strcat(abs_sql,yytext);
    }

<COMMENT>{COMMENT_MULTI_LINE_END} {
    BEGIN(INITIAL);
    strcat(abs_sql,yytext);
    }
<COMMENT>{ANY} { strcat(abs_sql,yytext); }
<INITIAL,REPLACE,NO_REPLACE>{SPACE} { strcat(abs_sql," "); }
<INITIAL>{REPLACE_KEY} {
    BEGIN(REPLACE);
    std::transform(yytext, yytext + strlen(yytext), yytext, ::toupper);
    strcat(abs_sql,yytext);
    }
<REPLACE>{IN_MULTI_VALUE} { strcat(abs_sql,"in ( ? )"); }
<REPLACE>{INSERT_MULTI_VALUE} {
    printf("%s;\n",abs_sql);
    memset(abs_sql, 0, sizeof(abs_sql));
    BEGIN(INITIAL);
    }
<INITIAL>[^REPLACE_KEY] {
    BEGIN(NO_REPLACE);
    std::transform(yytext, yytext + strlen(yytext), yytext, ::toupper);
    strcat(abs_sql,yytext);
    }
<REPLACE,NO_REPLACE>{IDENTIFIER} {
    std::transform(yytext, yytext + strlen(yytext), yytext, ::toupper);
    strcat(abs_sql,yytext);
}
<REPLACE>{REPLACE_VALUE} { strcat(abs_sql,"?"); }
<REPLACE,NO_REPLACE,INITIAL>^{COMMENT_SINGLE_LINE} { }
<INITIAL,REPLACE,NO_REPLACE>{END} {
    printf("%s;\n",abs_sql);
    memset(abs_sql, 0, sizeof(abs_sql));
    BEGIN(INITIAL);
}
<NO_REPLACE>{REPLACE_VALUE} { strcat(abs_sql,yytext); }
<REPLACE,NO_REPLACE>. {
    std::transform(yytext, yytext + strlen(yytext), yytext, ::toupper);
    strcat(abs_sql,yytext);
    }
%%
int main(int argc, char **argv) {
    if (argc < 2) {
        std::cerr << "Please input a file name.\n";
        return -1;
    }
    std::ifstream inFile(argv[1]);
    if (!inFile) {
        std::cerr << "Can't open file " << argv[1] << "\n";
        return -1;
    }
    yyFlexLexer lexer(&inFile, &std::cout);
    while(lexer.yylex() != 0);
    inFile.close();
    return 0;
}