grammar TradutoresGB;

options {
	language=Java;
}

@header {
    import java.util.HashMap;
}

@members {

	void testMethod(org.antlr.runtime.Token token){
		var text = token.getText();
		var line = token.getLine();
		var column = token.getCharPositionInLine();
		System.out.println(text + " line:" + line + " column:" + column);
	}

	HashMap<String, Double> memory = new HashMap<>();
}

prog: commands END_OF_FILE?;

commands: (command WS?)+;

command: assignment | iteration | conditional;

iteration: WHILE WS? relation WS? DO WS? commands ENDWHILE;

assignment:
    VARIABLE WS? ':=' WS? expr WS? ';'
    { memory.put($VARIABLE.text, new Double($expr.value)); System.out.println("variable " + $VARIABLE.text + " = " + $expr.value + " insert in memory"); }
    ;

conditional
    :
	IF WS? relation WS? THEN WS? commands WS? alternativa? WS? ENDIF
	;
	
alternativa
    :	
	ELSE WS? commands
	;
    
expr returns [ double value ]
    :
    expr_add
    ;
    
expr_add returns [ double value ]
    :
    expr_mult
    ( WS? '+' WS? e = expr_add {$value += $e.value;} {System.out.println("Result of sum: " + $value);}
    | WS? '-' WS? e = expr_add {$value -= $e.value;} {System.out.println("Result of subtract: " + $value);}
    )?
    ;

expr_mult returns [ double value ]
    :
    term
    ( WS? '*' WS? e = expr_mult {$value *= $e.value;} {System.out.println("Result of multiply: " + $value);}
    | WS? '/' WS? e = expr_mult {$value /= $e.value;} {System.out.println("Result of division: " + $value);}
    )?
    ;

term  returns [ double value ]
    : '(' WS? e = expr {$value = $e.value;} WS? ')'
    |( CONSTANT { $value = Double.parseDouble($CONSTANT.text); testMethod($CONSTANT); } {System.out.println("read value constant: " + $value);}
    | VARIABLE { $value = memory.getOrDefault($VARIABLE.text, 0.0); } {System.out.println("read memory variable: " + $value);} )
    ;


relation returns [ boolean r ]
    : 
    ( e = expr ) 
    ( '='  d = expr {$r = $e.value == $d.value;} {System.out.println("Result expr relashion " + $e.value + " = "  + $d.value + " : " + $r);} 
    | '<>' d = expr {$r = $e.value != $d.value;} {System.out.println("Result expr relashion " + $e.value + " <> " + $d.value + " : " + $r);} 
    | '<'  d = expr {$r = $e.value <  $d.value;} {System.out.println("Result expr relashion " + $e.value + " < "  + $d.value + " : " + $r);}
    | '>'  d = expr {$r = $e.value >  $d.value;} {System.out.println("Result expr relashion " + $e.value + " > "  + $d.value + " : " + $r);} 
    | '<=' d = expr {$r = $e.value <= $d.value;} {System.out.println("Result expr relashion " + $e.value + " <= " + $d.value + " : " + $r);}
    | '>=' d = expr {$r = $e.value >= $d.value;} {System.out.println("Result expr relashion " + $e.value + " >= " + $d.value + " : " + $r);}
    )   
    ;

IF   : 'if';
THEN : 'then';
ELSE : 'else';
ENDIF 	: 'endif';

WHILE: 'while';
DO   : 'do';
ENDWHILE  : 'endwhile';

CONSTANT: '0' | (('1'..'9') ('0'..'9')*);
VARIABLE: ('A'..'Z' | 'a'..'z')+ ('A'..'Z' | 'a'..'z' | '0'..'9')*;

WS   : (' '|'\n'|'\r'|'\t')+;

END_OF_FILE   : EOF {skip();};