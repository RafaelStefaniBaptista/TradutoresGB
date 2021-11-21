grammar TradutoresGB;

options {
	language = Java;
}

@header {
    import java.util.HashMap;
}

@members {

	void logError(String message, org.antlr.runtime.Token token){
		var text = token.getText();
		var line = token.getLine();
		var column = token.getCharPositionInLine();
		System.out.println(message + " token:" + text + " line:" + line + " column:" + column);
	}

	HashMap<String, Double> memory = new HashMap<>();
}

prog: commands END_OF_FILE?;

commands: (command WS?)+;

command: assignment | iteration | conditional;

iteration: WHILE WS? relation WS? DO WS? commands ENDWHILE;

assignment:
	VARIABLE WS? ':=' WS? expr WS? ';' { memory.put($VARIABLE.text, new Double($expr.value)); System.out.println("variable " + $VARIABLE.text + " = " + $expr.value + " insert in memory"); };

conditional:
	IF WS? relation WS? THEN WS? commands WS? alternativa? WS? ENDIF;

alternativa: ELSE WS? commands;

expr returns[ double value ]: e = expr_add {$value = $e.value;};

expr_add returns[ double value ]:
	e = expr_mult {$value = $e.value;} (
		WS? '+' WS? d = expr_add {$value += $d.value;} {System.out.println("Result of " + $e.value + " + " + $d.value + ": " + $value);}
		| WS? '-' WS? d = expr_add {$value -= $d.value;} {System.out.println("Result of " + $e.value + " - " + $d.value + ": " + $value);}
	)?;

expr_mult returns[ double value ]:
	e = term {$value = $e.value;} (
		WS? '*' WS? d = expr_mult {$value *= $d.value;} {System.out.println("Result of " + $e.value + " * " + $d.value + ": " + $value);}
		| WS? '/' WS? d = expr_mult {$value /= $d.value;} {System.out.println("Result of " + $e.value + " / " + $d.value + ": " + $value);}
	)?;

term returns[ double value ]:
	'(' WS? e = expr {$value = $e.value;} WS? ')'
	| (
		CONSTANT { $value = Double.parseDouble($CONSTANT.text); } {System.out.println("read value constant: " + $value);}
		| v = VARIABLE { 
			var memo = memory.get($v.text);
			if(memo == null) {
				$value = 0.0;
				logError("[ERRO SEMÂNTICO: variável não declarada]", $v);
			} else {
				$value = memo;
				System.out.println("read " + $v.text + " from memory: " + $value);
			}
		}
	);

relation returns[ boolean r ]:
	(e = expr) WS? (
		'=' WS? d = 	expr {$r = $e.value == $d.value;} {System.out.println("Result expr relashion " + $e.value + " = "  + $d.value + " : " + $r);}
		| '<>' WS? d = 	expr {$r = $e.value != $d.value;} {System.out.println("Result expr relashion " + $e.value + " <> " + $d.value + " : " + $r);}
		| '<' WS? d = 	expr {$r = $e.value <  $d.value;} {System.out.println("Result expr relashion " + $e.value + " < "  + $d.value + " : " + $r);}
		| '>' WS? d = 	expr {$r = $e.value >  $d.value;} {System.out.println("Result expr relashion " + $e.value + " > "  + $d.value + " : " + $r);}
		| '<=' WS? d = 	expr {$r = $e.value <= $d.value;} {System.out.println("Result expr relashion " + $e.value + " <= " + $d.value + " : " + $r);}
		| '>=' WS? d = 	expr {$r = $e.value >= $d.value;} {System.out.println("Result expr relashion " + $e.value + " >= " + $d.value + " : " + $r);}
	);

IF: 'if';
THEN: 'then';
ELSE: 'else';
ENDIF: 'endif';

WHILE: 'while';
DO: 'do';
ENDWHILE: 'endwhile';

CONSTANT: '0' | (('1' ..'9') ('0' ..'9')*);
VARIABLE: ('A' ..'Z' | 'a' ..'z')+ (
		'A' ..'Z'
		| 'a' ..'z'
		| '0' ..'9'
	)*;

WS: (' ' | '\n' | '\r' | '\t')+;

END_OF_FILE: EOF {skip();};