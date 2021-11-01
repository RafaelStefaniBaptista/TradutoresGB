grammar TradutoresGB;

options {
	language=Java;
}

prog returns [ double v ]:

	(e = expr {$v = $e.v;} {System.out.println("Resultado: " + $v);}  WHITE_SPACE*)+ 
	;
	
expr returns [ double v ]:
	VARIABLE {$v = Double.parseDouble( $INT.text);} ('+' e = expr {$v += $e.v;} | '-' e = expr {$v -= $e.v;} | '*' e = expr {$v *= $e.v;} | '/' e = expr {$v /= $e.v;})	
    |	VARIABLE {$v = Double.parseDouble( $INT.text);}
    

    |	'(' e = expr {$v = $e.v;} ')'
    ;
	
CONSTANT:	('0'..'9');
VARIABLE:	('A'..'Z' | 'a'..'z');

LINE_TERMINATOR: ('\r' | '\n');
WHITE_SPACE:	 (' ' | '\t' | '\f');
SEPARATOR:	 (LINE_TERMINATOR | WHITE_SPACE);
