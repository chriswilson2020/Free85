; Home soft-menu pages, five entries per page.
home_menu_page0: DB "MATH GRF VAR MEM SYS", 0
home_menu_page1: DB "LIST MAT VEC STAT PGM", 0

soft_action_table:
    DW action_math, action_graph, action_variables, action_memory, action_system
    DW action_lists, action_matrix, action_vector, action_statistics, action_programs

; Normal editor insertion strings indexed by physical key code.
normal_insert_table:
    DW 0,0,0,0,0,0,0,0,0,0
    DW 0, insert_x, 0,0,0,0,0,0,0,0
    DW insert_log,insert_sin,insert_cos,insert_tan,insert_power
    DW insert_ln,insert_ee,insert_lparen,insert_rparen,insert_divide
    DW insert_square,insert_7,insert_8,insert_9,insert_multiply
    DW insert_comma,insert_4,insert_5,insert_6,insert_minus
    DW insert_store,insert_1,insert_2,insert_3,insert_plus
    DW 0,insert_0,insert_decimal,insert_negate,0

; Shifted operations that can already be represented in the Phase 2 editor.
second_insert_table:
    DW 0,0,0,0,0,0,0,0,0,0
    DW 0,0,0,0,0,0,0,0,0,0
    DW insert_pow10,insert_asin,insert_acos,insert_atan,insert_pi
    DW insert_exp,insert_reciprocal,insert_lbracket,insert_rbracket,0
    DW insert_sqrt,0,0,0,0
    DW insert_angle,0,0,0,0
    DW 0,0,0,0,0
    DW 0,0,insert_colon,insert_ans,0

; Zero means that ALPHA falls through to the key's normal navigation/action.
alpha_character_table:
    DB 0,0,0,0,0,0,0,0,0,0
    DB 0,'x',0,0,0,0,0,0,0,0
    DB 'A','B','C','D','E','F','G','H','I','J'
    DB 'K','L','M','N','O','P','Q','R','S','T'
    DB 0,'U','V','W','X',0,'Y','Z',0,0

; Printed shifted labels, used by the generic planned-feature dialog.
second_name_table:
    DW second_m1,second_m2,second_m3,second_m4,second_m5
    DW 0,second_quit,second_mode,0,0
    DW second_lower,second_link,second_insert,0,0
    DW second_solver,second_simult,second_poly,second_catalog,second_toler
    DW second_pow10,second_asin,second_acos,second_atan,second_pi
    DW second_exp,second_recip,second_lbracket,second_rbracket,second_calc
    DW second_sqrt,second_matrix,second_vector,second_complex,second_math
    DW second_angle,second_constants,second_convert,second_string,second_list
    DW second_recall,second_base,second_test,second_vars,second_memory
    DW second_off,second_char,second_colon,second_ans,second_entry

insert_x:          DB "X",0
insert_log:        DB "LOG(",0
insert_sin:        DB "SIN(",0
insert_cos:        DB "COS(",0
insert_tan:        DB "TAN(",0
insert_power:      DB "^",0
insert_ln:         DB "LN(",0
insert_ee:         DB "E",0
insert_lparen:     DB "(",0
insert_rparen:     DB ")",0
insert_divide:     DB "/",0
insert_square:     DB "^2",0
insert_7:          DB "7",0
insert_8:          DB "8",0
insert_9:          DB "9",0
insert_multiply:   DB "*",0
insert_comma:      DB ",",0
insert_4:          DB "4",0
insert_5:          DB "5",0
insert_6:          DB "6",0
insert_minus:      DB "-",0
insert_store:      DB "->",0
insert_1:          DB "1",0
insert_2:          DB "2",0
insert_3:          DB "3",0
insert_plus:       DB "+",0
insert_0:          DB "0",0
insert_decimal:    DB ".",0
insert_negate:     DB "-",0
insert_pow10:      DB "TEN(",0
insert_asin:       DB "ASIN(",0
insert_acos:       DB "ACOS(",0
insert_atan:       DB "ATAN(",0
insert_pi:         DB "PI",0
insert_exp:        DB "EXP(",0
insert_reciprocal: DB "1/(",0
insert_lbracket:   DB "[",0
insert_rbracket:   DB "]",0
insert_sqrt:       DB "SQRT(",0
insert_angle:      DB "ANGLE(",0
insert_colon:      DB ":",0
insert_ans:        DB "ANS",0

action_math:       DB "MATH MENU",0
action_graph:      DB "GRAPH MENU",0
action_variables:  DB "VARIABLES",0
action_memory:     DB "MEMORY",0
action_system:     DB "SYSTEM",0
action_lists:      DB "LISTS",0
action_matrix:     DB "MATRIX",0
action_vector:     DB "VECTOR",0
action_statistics: DB "STATISTICS",0
action_programs:   DB "PROGRAMS",0

second_m1:       DB "M1",0
second_m2:       DB "M2",0
second_m3:       DB "M3",0
second_m4:       DB "M4",0
second_m5:       DB "M5",0
second_quit:     DB "QUIT",0
second_mode:     DB "MODE",0
second_lower:    DB "LOWER ALPHA",0
second_link:     DB "LINK",0
second_insert:   DB "INSERT MODE",0
second_solver:   DB "SOLVER",0
second_simult:   DB "SIMULTANEOUS",0
second_poly:     DB "POLYNOMIAL",0
second_catalog:  DB "CATALOG",0
second_toler:    DB "TOLERANCE",0
second_pow10:    DB "10 POWER X",0
second_asin:     DB "INVERSE SIN",0
second_acos:     DB "INVERSE COS",0
second_atan:     DB "INVERSE TAN",0
second_pi:       DB "PI",0
second_exp:      DB "EXPONENTIAL",0
second_recip:    DB "RECIPROCAL",0
second_lbracket: DB "OPEN BRACKET",0
second_rbracket: DB "CLOSE BRACKET",0
second_calc:     DB "CALCULUS",0
second_sqrt:     DB "SQUARE ROOT",0
second_matrix:   DB "MATRIX",0
second_vector:   DB "VECTOR",0
second_complex:  DB "COMPLEX",0
second_math:     DB "MATH MENU",0
second_angle:    DB "POLAR ANGLE",0
second_constants: DB "CONSTANTS",0
second_convert:  DB "CONVERSIONS",0
second_string:   DB "STRINGS",0
second_list:     DB "LISTS",0
second_recall:   DB "RECALL",0
second_base:     DB "NUMBER BASE",0
second_test:     DB "LOGIC TESTS",0
second_vars:     DB "VARIABLES",0
second_memory:   DB "MEMORY",0
second_off:      DB "POWER OFF",0
second_char:     DB "CHARACTERS",0
second_colon:    DB "COLON",0
second_ans:      DB "PREVIOUS ANSWER",0
second_entry:    DB "PREVIOUS ENTRY",0

notice_entry_full:   DB "ENTRY FULL",0
notice_entry_empty:  DB "ENTRY EMPTY",0
notice_entry_start:  DB "START OF ENTRY",0
notice_entry_end:    DB "END OF ENTRY",0
notice_history:      DB "NO MORE HISTORY",0
notice_evaluator:    DB "EVALUATOR NEXT",0
notice_syntax:       DB "SYNTAX ERROR",0
notice_div_zero:     DB "DIVIDE BY ZERO",0
notice_numeric_overflow: DB "NUMERIC OVERFLOW",0
notice_domain:       DB "DOMAIN ERROR",0
notice_awake:        DB "ALREADY AWAKE",0
notice_home:         DB "ALREADY AT HOME",0
notice_no_alpha:     DB "NO ALPHA MAP",0
