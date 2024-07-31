grammar MXDR;

/* ======= */
/* Grammar */
/* ======= */

// The productions below are from the XDR standard (RFC-4506), augmented with
// facilities supporting the definition of types with range constraints.

specification:
    definition*;

// Definition Syntax
// -----------------
definition:
    type_def | constant_def | encoder_def | decoder_def | line;

type_def:
      TYPEDEF declaration RANGE range_constraint SEMI
    | TYPEDEF declaration subtype_spec RANGE range_constraint SEMI
    | TYPEDEF declaration SEMI
    | ENUM IDENTIFIER enum_body SEMI
    | STRUCT IDENTIFIER struct_body SEMI
    | UNION IDENTIFIER union_body SEMI
    | MESSAGE STRUCT (LARROW | RARROW) IDENTIFIER struct_body (WITH aspect_list)? SEMI;

range_constraint:
      CONSTANT DOTDOT CONSTANT
    | CONSTANT DOTDOT IDENTIFIER;

subtype_spec:
      IS IDENTIFIER
    | IS NATURAL;

aspect_list
    :   (aspect_deffinition COMMA)* aspect_deffinition;

aspect_deffinition
    :   ASPECT_TYPE RPOINT LPARENS expression RPARENS;

constant_def:
      CONST IDENTIFIER EQUALS CONSTANT SEMI
    | CONST IDENTIFIER IS IDENTIFIER EQUALS CONSTANT SEMI;

encoder_def:
    ENCODER IDENTIFIER LPARENS declaration (COMMA declaration)* RPARENS SEMI;

decoder_def:
    DECODER IDENTIFIER LPARENS declaration (COMMA declaration)* RPARENS SEMI;

line:
     declaration SEMI;

// Declaration Syntax
// ------------------
declaration:
      type_specifier IDENTIFIER
    | type_specifier IDENTIFIER EQUALS CONSTANT
    | type_specifier IDENTIFIER LBRACKET value RBRACKET
    | type_specifier IDENTIFIER LANGLE value? RANGLE
    | OPAQUE IDENTIFIER LBRACKET value RBRACKET
    | OPAQUE IDENTIFIER LANGLE value? RANGLE
    | STRING IDENTIFIER LANGLE value? RANGLE
    | IDENTIFIER LANGLE value? RANGLE
    | type_specifier STAR IDENTIFIER
    | VOID;

type_specifier:
      UNSIGNED? INT
    | UNSIGNED? HYPER
    | FLOAT
    | DOUBLE
    | QUADRUPLE
    | BOOL
    | STRING
    | IDENTIFIER
    | TIME
    | TIME_SPAN
    | DATA
    | enum_type_spec
    | struct_type_spec
    | union_type_spec;

value:
    CONSTANT | IDENTIFIER;

enum_type_spec:
    ENUM enum_body;

enum_body:
    LBRACE IDENTIFIER EQUALS value (COMMA IDENTIFIER EQUALS value)* RBRACE
    | LBRACE IDENTIFIER (COMMA IDENTIFIER)* RBRACE;

struct_type_spec:
    STRUCT struct_body;

struct_body:
    LBRACE (declaration SEMI)+ RBRACE;

union_type_spec:
    UNION union_body;

union_body:
    SWITCH LPARENS declaration RPARENS LBRACE
      case_spec+
      (DEFAULT COLON declaration SEMI)?
    RBRACE;

case_spec:
    (CASE value COLON)+ declaration SEMI;

// Expression Syntax
// -----------------
expression
    : add_expression
    | expression (EQUALS | NEQUALS | LANGLE | LOE | RANGLE | GOE) add_expression;

add_expression
    : multiply_expression
    | add_expression (PLUS | MINUS) multiply_expression;

multiply_expression
    : primary_expression
    | multiply_expression (STAR | DIVIDE) primary_expression;

primary_expression
    : IDENTIFIER
    | TRUE
    | FALSE
    | INTEGER_LITERAL
    | LPARENS expression RPARENS;

/* =========== */
/* Lexer rules */
/* =========== */

// --------------
// Reserved Words
// --------------
BOOL      : 'bool';
CASE      : 'case';
CONST     : 'const';
DATA      : 'CubedOS.Lib.Octet_Array';
DECODER   : 'decoder';
DEFAULT   : 'default';
DOUBLE    : 'double';
ENCODER   : 'encoder';
ENUM      : 'enum';
FLOAT     : 'float';
HYPER     : 'hyper';
INT       : 'int';
IS        : 'is';
MESSAGE   : 'message';
NATURAL   : 'Natural';
OPAQUE    : 'opaque';
QUADRUPLE : 'quadruple';
RANGE     : 'range';
STRING    : 'string';
STRUCT    : 'struct';
SWITCH    : 'switch';
TIME      : 'Ada.Real_Time.Time';
TIME_SPAN : 'Ada.Real_Time.Time_Span';
TYPEDEF   : 'typedef';
UNION     : 'union';
UNSIGNED  : 'unsigned';
VOID      : 'void';
WITH      : 'with';
TRUE      : 'true';
FALSE     : 'false';

// -------
// Symbols
// -------
AND      : '&&';
OR       : '||';
NOT      : '!';
COLON    : ':';
COMMA    : ',';
DOTDOT   : '..';
GOE      : '>=';
LANGLE   : '<';
LARROW   : '<-';
LBRACE   : '{';
LBRACKET : '[';
LOE      : '<=';
LPARENS  : '(';
EQUALS   : '=';
NEQUALS  : '/=';
RANGLE   : '>';
RARROW   : '->';
RBRACE   : '}';
RBRACKET : ']';
RPARENS  : ')';
RPOINT   : '=>';
SEMI     : ';';
STAR     : '*';
PLUS     : '+';
MINUS    : '-';
DIVIDE   : '/';

ASPECT_TYPE
    : 'message_invariant';

IDENTIFIER
    :   [a-zA-Z][a-zA-Z0-9_']*;

INTEGER_LITERAL
    :   [0-9][0-9]*;

WHITESPACE
    :   [ \t\f\r\n]+  -> skip;

COMMENT1
    :    '/*' .*? '*/' -> skip;

COMMENT2
    :   '//' .*? [\r\n] -> skip;

CONSTANT
    :   ('-' | '+')? (DECIMAL | BASED) ( ('.') DIGIT+ )? ( ('E' | 'e') DIGIT+ )?;

fragment DECIMAL
    :   DIGIT ('_'? DIGIT)*;

fragment BASED
    :   DIGIT+ '#' HDIGIT ('_'? HDIGIT)* '#';

fragment DIGIT
    :   [0-9];

fragment HDIGIT
    :   [0-9a-fA-F];
