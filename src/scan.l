%{
/* Lexical analyser for RetroBASIC
   Copyright (C) 2020 Maury Markowitz

   Based on gnbasic
   Copyright (C) 1998 James Bowman
 
This file is part of RetroBASIC.

RetroBASIC is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

RetroBASIC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with RetroBASIC; see the file COPYING.  If not, write to
the Free Software Foundation, 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.  */

#include "retrobasic.h"
#include "strng.h"
#include "parse.h"

%}

%option noyywrap
%option caseless
%option yylineno
 //%option nodefault

%%

 /* end of file */
"\032"  {
          yyterminate();
        }
<<EOF>> {
          yyterminate();
        }

 /* statements */
 /* REM statements are odd because they consist of a token and a line of text, but
    the rest of the line is part of the statement. If you want to keep the REM part as
    a separate token, this is the simplest solution. See:
    https://stackoverflow.com/questions/59117309/rest-of-line-in-bison/59122569#59122569
  */
REM.*   { yylval.s = str_new(str_copy(yytext + 3, yyleng - 3)); return REM; }
'.*     { yylval.s = str_new(str_copy(yytext + 1, yyleng - 1)); return QUOTEREM; } // short form in MS
!.*     { yylval.s = str_new(str_copy(yytext + 1, yyleng - 1)); return BANGREM; }  // later MS allow bang as well
BYE     { return BYE; } // also SYSTEM and GOODBYE
CLEAR   { return CLEAR; }
CLR     { return CLEAR; } /* synonyms */
DEF     { return DEF; }
DATA    { return DATA; }
DIM     { return DIM; }
END     { return END; }
FOR     { return FOR; }
GOSUB		{ return GOSUB; }
GOTO		{ return GOTO; }
IF      { return IF; }
INPUT   { return INPUT; }
LET	    { return LET; }
NEXT	  { return NEXT; }
NEW			{ return NEW; } // also CLEAR (sometimes with options), ERASE and SCRATCH
OF      { return OF; }
ON      { return ON; }
POKE    { return POKE; }
PRINT   { return PRINT; }
READ		{ return READ; }
RESTORE	{ return RESTORE; }
RETURN	{ return RETURN; }
RUN			{ return RUN; }
STEP		{ return STEP; }
STOP    { return STOP; }
THEN		{ return THEN; }
TO			{ return TO; }

 /* extended statements found in some versions*/
CALL      { return CALL; }    // used to call system functions in TI-99 and some other BASICs
CLEAR     { return CLEAR; }
CLR       { return CLEAR; }
CLS       { return CLS; }     // clear screen, do not confuse with CLR or CLEAR
CMD       { return CMD; }     // redirects output of PRINT to another device
GET       { return GET; }
PUT       { return PUT; }
INPUT#    { return INPUT_FILE; }
PRINT#    { return PRINT_FILE; }
OPTION    { return OPTION; }
BASE      { return BASE; }
RANDOMIZE { return RANDOMIZE; }
SYS       { return SYS; }     // same as CALL
USING     { return USING; }
VARLIST   { return VARLIST; }
PAUSE     { return PAUSE; }
POP       { return POP; }
EXIT      { return EXIT; }    // same as POP

 /* math functions */
ABS			  { return ABS; }
ACS       { return ACS; }
ASN       { return ASN; }
ATN       { return ATN; }
COS       { return COS; }
COSH      { return COSH; }
CLOG		  { return CLOG; } // CLG on Honeywell Series 60
CSH       { return COSH; }
EXP       { return EXP; }
FIX       { return FIX; }
FRAC      { return FRAC; }
INT			  { return INT; }
LOG			  { return LOG; }
PI        { return PI; }
SIN			  { return SIN; }
SINH      { return SINH; }
SGN			  { return SGN; }
SQR			  { return SQR; }
SNH       { return SINH; }
ROUND     { return ROUND; }
RND       { return RND; }
TAN       { return TAN; }
TANH      { return TANH; }
TNH       { return TANH; }
VAL			  { return VAL; }

 /* string-related functions */
ASC       { return ASC; } // CODE on Sinclair due to being non-ASCII, CH on Atom (no parens), ASCII on DEC?
CHR\$     { return CHR; } // CHR (SOL and SWTP), CHAR (MAX-BASIC), CHAR$ (Micropolis)
LEFT\$		{ return LEFT; }
RIGHT\$		{ return RIGHT; }
MID\$     { return MID; }
LEN       { return LEN; }
STR\$     { return STR; } // also NUM$ in some dialects
INSTR     { return INSTR; } // also INDEX and POS
INDEX     { return INSTR; } // also FIND and other variations
 /* aliases for MID found in some versions */
SEG\$     { return SEG; }
SUBSTR\$  { return SUBSTR; }
SUBSTRING\$  { return SUBSTR; }
 /* aliases for MID found in some versions */
INKEY\$   { return INKEY; }

 /* system functions */
FRE       { return FRE; }
TAB			  { return TAB; }
SPC			  { return SPC; }
SPA       { return SPC; }   // from HP, same as SPC
PEEK      { return PEEK; }  // also EXAM (North Star) and FETCH (Digital Group Opus)
POS       { return POS; } // COUNT in Atom
USR       { return USR; }
LIN       { return LIN; }

 /* various operators and punctuation */
[:,;()\[\]\^=+\-*/\<\>\&]     { return yytext[0]; }
MOD       { return MOD; }

 /* alternate form for power */
"**"      { return '^'; } // FIXME: we should have a separate token for this?

 /* binary operators */
AND       { return AND; }
OR        { return OR; }
NOT       { return NOT; }
XOR       { return XOR; }

 /* comparison operators */
\<=       { return CMP_LE; }
=\<       { return CMP_LE; }
\>=       { return CMP_GE; }
=\>       { return CMP_GE; }
\<\>      { return CMP_NE; }
\>\<      { return CMP_NE; }
#         { return CMP_HASH; } // use a separate token here to preserve it in LIST

 /* defs added in Extended BASIC */
 /* FIXME: these are actually easy to do, simply run them as DIMs so they get entered into the var list */
DEFSTR    { return DEFSTR; }
DEFINT    { return DEFINT; }
DEFSNG    { return DEFSNG; }
DEFDBL    { return DEFDBL; }

 /* other string commands and functions */
CHANGE    { return CHANGE; }
CONVERT   { return CONVERT; }
UCASE\$   { return UCASE; }
LCASE\$   { return LCASE; }
STRING\$  { return STRNG; } // returns n copies of a given string
SPACE\$   { return SPC; }   // returns n spaces as a value, which is how our SPC works anyway

 /* commodore-style TIME and TIME$ */
TIME\$    { return TIME_STR; }
TIME      { return TIME; }
 /* and their alternate short forms */
TI\$      { return TIME_STR; }
TI        { return TIME; }
CLK\$     { return TIME_STR; } // from BASIC-PLUS, Univac System 9 has CLK(x) where x is numeric

 /* HEX, OCT and BIN conversions */
BIN       { return BIN; }
BIN\$     { return BINSTR; }
HEX       { return HEX; }
HEX\$     { return HEXSTR; }
OCT       { return OCT; }
OCT\$     { return OCTSTR; }

 /* array utilities */
UBOUND    { return UBOUND; }
LBOUND    { return LBOUND; }

 /* line labels, procedures, etc. */
LABEL    { return LABEL; }

 /* hex, oct and bin strings encoding numbers */
\&[0-9a-fA-F]+  {
            yylval.d = (double)strtol(yytext + 1, NULL, 16);
            return NUMBER;
          }
0[x|h|X|H][0-9a-fA-F]+ {
            yylval.d = (double)strtol(yytext + 2, NULL, 16);
            return NUMBER;
          }
0[o|O][0-7]+ {
            yylval.d = (double)strtol(yytext + 2, NULL, 8);
            return NUMBER;
          }
0[b|B][0-1]+ {
            yylval.d = (double)strtol(yytext + 2, NULL, 2);
            return NUMBER;
          }

 /* other numeric constants and line numbers */
[0-9]*[0-9.][0-9]*([Ee][-+]?[0-9]+)? {
            yylval.d = strtod(yytext, NULL);
            return NUMBER;
          }

 /* user defined functions */
"FN"[A-Za-z@][A-Za-z0-9_]?[\$%\!#]? {
            yylval.s = str_new(yytext);
            return FUNCTION_NAME;
          }

 /* variable references */
 /* currently set to allow only one or two chars plus an optional type indicator
    replace the ? with a * for multi-char variables */
[A-Za-z@][A-Za-z0-9_]?[\$%\!#]? {
            yylval.s = str_new(yytext);
            return VARIABLE_NAME;
          }

 /* string constants */
\"[^"^\n]*[\"\n] {
            yytext[strlen(yytext) - 1] = '\0';
            yylval.s = str_new(yytext + 1);
            return STRING;
          }

 /* preserve line ends */
[\n]        { return '\n'; }

 /* eat other whitespace */
[ \t\r\l]   {  }

. printf("Bad input character '%s' at line %d\n", yytext, yylineno);

%%
