grammar gramatic;

options {
	language=Java;
}

@header {
    import java.util.HashMap;
}

@members {
    HashMap<String, Double> memory = new HashMap<>();
}

prog
    :
    stat+ EOF
    ;

stat
    :
    comands
    ; 

comands
    :
    (comand ';')+
    ;

comand
    : 
    assignment
    | iteration
    | conditional 
    ;

iteration
    :
	WHILE relashion DO comands
    ;

assignment
    :
    VARIABLE ':=' expr 
    { memory.put($VARIABLE.text, new Double($expr.value)); } 
    { System.out.println("variable " + $VARIABLE.text + " = " + $expr.value + " insert in memory"); }
    ;

conditional
    :
	(IF relashion THEN comands) alternativa 
	;
	
alternativa
    :	
	(ELSE comands)
	;

expr returns [ double value ]
    :
    ( CONSTANT { $value = Double.parseDouble($INT.text); } {System.out.println("read value constant: " + $value);}
    | VARIABLE { $value = memory.getOrDefault($VARIABLE.text, 0.0); } {System.out.println("read memory variable: " + $value);} )
    ( '+' {System.out.println("read: + ");} e = expr {$value += $e.value;} {System.out.println("Result of sum: " + $value);}
    | '-' {System.out.println("read: - ");} e = expr {$value -= $e.value;} {System.out.println("Result of subtract: " + $value);}
    | '*' {System.out.println("read: * ");} e = expr {$value *= $e.value;} {System.out.println("Result of multiply: " + $value);}
    | '/' {System.out.println("read: / ");} e = expr {$value /= $e.value;} {System.out.println("Result of division: " + $value);}
    |
    )
    | '(' e = expr {$value = $e.value;} ')'
    ;

relashion returns [ boolean r ]
    : 
    ( e = expr ) 
    ( '='  {System.out.println("read expr relashion: = " );} d = expr {$r = $e.value == $d.value;} {System.out.println("Result expr relashion " + $e.value + " = "  + $d.value + " : " + $r);} 
    | '<>' {System.out.println("read expr relashion: <> ");} d = expr {$r = $e.value != $d.value;} {System.out.println("Result expr relashion " + $e.value + " <> " + $d.value + " : " + $r);} 
    | '<'  {System.out.println("read expr relashion: < " );} d = expr {$r = $e.value <  $d.value;} {System.out.println("Result expr relashion " + $e.value + " < "  + $d.value + " : " + $r);}
    | '>'  {System.out.println("read expr relashion: > " );} d = expr {$r = $e.value >  $d.value;} {System.out.println("Result expr relashion " + $e.value + " > "  + $d.value + " : " + $r);} 
    | '<=' {System.out.println("read expr relashion: <= ");} d = expr {$r = $e.value <= $d.value;} {System.out.println("Result expr relashion " + $e.value + " <= " + $d.value + " : " + $r);}
    | '>=' {System.out.println("read expr relashion: >= ");} d = expr {$r = $e.value >= $d.value;} {System.out.println("Result expr relashion " + $e.value + " >= " + $d.value + " : " + $r);}
    )   
    ;

DO   : 'do';
ELSE : 'else';
IF   : 'if';
WHILE: 'while';
THEN : 'then';
END  : 'end';

CONSTANT:	('0'..'9')+;
VARIABLE:	('A'..'Z' | 'a'..'z')+;

WS   : (' '|'\n'|'\r'|'\t')+;