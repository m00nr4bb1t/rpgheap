private enum Tokens {
    LEFT_PAREN; RIGHT_PAREN;
    MINUS; PLUS; DIVIDE; MULTIPLY;
    MODULO; COLON; DOT;
    INDENT; NEWLINE; EOF;

    EQUAL; EQUAL_EQUAL;
    GREATER; GREATER_EQUAL;
    LESS; LESS_EQUAL;

    LABEL; EXEC; IF; ELSE; ELIF;
    WHILE; NOT; AND; OR; TRUE; FALSE;
    IDENTIFIER; STRING; NUMBER;
}

private class Token {
    public var type: Tokens;
    public var value: Dynamic;

    public function new(type: Tokens, ?value: Dynamic) {
        this.type = type;
        this.value = value;
    }

    public function toString(): String {
        return 'Type: $type, Value: $value';
    }
}

private class BinaryExpression {
    public var a: Dynamic;
    public var b: Dynamic;
    public var op: Tokens;

    public function new(a: Dynamic, b: Dynamic, op: Tokens) {
        this.a = a;
        this.b = b;
        this.op = op;
    }

    public static function evaluate(a: Dynamic, b: Dynamic, op: Tokens): Dynamic {
        switch (op) {
            case Tokens.MINUS: return a - b;
            case Tokens.PLUS: return a + b;
            case Tokens.DIVIDE: return a / b;
            case Tokens.MULTIPLY: return a * b;
            case Tokens.MODULO: return a % b;
            case Tokens.EQUAL_EQUAL: return a == b;
            case Tokens.GREATER: return a > b;
            case Tokens.GREATER_EQUAL: return a >= b;
            case Tokens.LESS: return a < b;
            case Tokens.LESS_EQUAL: return a <= b;
            case Tokens.AND: return a && b;
            case Tokens.OR: return a || b;
            default: return null;
        }
    }
}

private class UnaryExpression {
    public var value: Dynamic;
    public var op: Tokens;

    public function new(value: Dynamic, op: Tokens) {
        this.value = value;
        this.op = op;
    }

    public static function evaluate(value: Dynamic, op: Tokens): Dynamic {
        switch (op) {
            case Tokens.NOT: return !value;
            default: return null;
        }
    }
}

class Scanner {
    var i: Int;
    var str: String;
    
    public function new() {
        //
    }

    public function tokenize(str: String): Array<Array<Token>> {
        i = 0;
        this.str = str;
        var char: String, start: Int;
        var tokens: Array<Array<Token>> = [[]];

        while (i < str.length) {
            start = i;
            char = str.charAt(i);
            switch (char) {
                case "#": while (!peakNext("\n")) i++; i++; continue;

                case "(": tokens[tokens.length - 1].push(new Token(Tokens.LEFT_PAREN)); i++; continue;
                case ")": tokens[tokens.length - 1].push(new Token(Tokens.RIGHT_PAREN)); i++; continue;
                case "-": tokens[tokens.length - 1].push(new Token(Tokens.MINUS)); i++; continue;
                case "+": tokens[tokens.length - 1].push(new Token(Tokens.PLUS)); i++; continue;
                case "/": tokens[tokens.length - 1].push(new Token(Tokens.DIVIDE)); i++; continue;
                case "*": tokens[tokens.length - 1].push(new Token(Tokens.MULTIPLY)); i++; continue;
                case "%": tokens[tokens.length - 1].push(new Token(Tokens.MODULO)); i++; continue;
                case ":": tokens[tokens.length - 1].push(new Token(Tokens.COLON)); i++; continue;
                case ".": tokens[tokens.length - 1].push(new Token(Tokens.DOT)); i++; continue;
                case "\t": tokens[tokens.length - 1].push(new Token(Tokens.INDENT)); i++; continue;
                case " ": if (eatNext(" ") && eatNext(" ") && eatNext(" ")) tokens[tokens.length - 1].push(new Token(Tokens.INDENT)); i++; continue;
                case "\n": if (tokens[tokens.length - 1].length > 0) tokens.push(new Array<Token>()); i++; continue;

                case "=": if (eatNext("=")) tokens[tokens.length - 1].push(new Token(EQUAL_EQUAL)); else tokens[tokens.length - 1].push(new Token(EQUAL)); i++; continue;
                case ">": if (eatNext("=")) tokens[tokens.length - 1].push(new Token(GREATER_EQUAL)); else tokens[tokens.length - 1].push(new Token(GREATER)); i++; continue;
                case "<": if (eatNext("=")) tokens[tokens.length - 1].push(new Token(LESS_EQUAL)); else tokens[tokens.length - 1].push(new Token(LESS)); i++; continue;

                case "i": if (eatNext("f")) {tokens[tokens.length - 1].push(new Token(Tokens.IF)); i++; continue;}
                case "o": if (eatNext("r")) {tokens[tokens.length - 1].push(new Token(Tokens.OR)); i++; continue;}
                case "n": if (eatNext("o") && eatNext("t")) {tokens[tokens.length - 1].push(new Token(Tokens.NOT)); i++; continue;} else i = start;
                case "a": if (eatNext("n") && eatNext("d")) {tokens[tokens.length - 1].push(new Token(Tokens.AND)); i++; continue;} else i = start;

                case "t":
                    if (eatNext("r") && eatNext("u") && eatNext("e")) {
                        tokens[tokens.length - 1].push(new Token(Tokens.TRUE));
                        i++;
                        continue;
                    } else {
                        i = start;
                    }
                case "f":
                    if (eatNext("a") && eatNext("l") && eatNext("s") && eatNext("e")) {
                        tokens[tokens.length - 1].push(new Token(Tokens.FALSE));
                        i++;
                        continue;
                    } else {
                        i = start;
                    }
                case "w":
                    if (eatNext("h") && eatNext("i") && eatNext("l") && eatNext("e")) {
                        tokens[tokens.length - 1].push(new Token(Tokens.WHILE));
                        i++;
                        continue;
                    } else {
                        i = start;
                    }
                case "l":
                    if (eatNext("a") && eatNext("b") && eatNext("e") && eatNext("l")) {
                        tokens[tokens.length - 1].push(new Token(Tokens.LABEL));
                        i++;
                        continue;
                    } else {
                        i = start;
                    }
                case "e":
                    if (eatNext("l")) {
                        if (eatNext("s") && eatNext("e")) {
                            tokens[tokens.length - 1].push(new Token(Tokens.ELSE));
                            i++;
                            continue;
                        } else {
                            i = start;
                            if (eatNext("i") && eatNext("f")) {
                                tokens[tokens.length - 1].push(new Token(Tokens.ELIF));
                                i++;
                                continue;
                            } else {
                                i = start;
                            }
                        }
                    } else if (eatNext("x")) {
                        if (eatNext("e") && eatNext("c")) {
                            tokens[tokens.length - 1].push(new Token(Tokens.EXEC));
                            i++;
                            continue;
                        }
                    }
                
                case "\"":
                    var value = "";
                    while (i < str.length) {
                        i++;
                        char = str.charAt(i);
                        if (char == "\"") break;
                        if (char == "\\") {
                            if (eatNext("\n")) continue;
                            else if (eatNext("\\")) value += "\\";
                            else if (eatNext("\"")) value += "\"";
                            else if (eatNext("\"")) value += "\"";
                            else if (eatNext("\n")) value += "\n";
                            else if (eatNext("\r")) value += "\r";
                            else if (eatNext("\t")) value += "\t";
                            else value += str.charAt(i++);
                        } else {
                            value += char;
                        }
                    }
                    tokens[tokens.length - 1].push(new Token(Tokens.STRING, value));
                    i++;
                    continue;
            }

            var value = "";

            if (isSafe(0, false) && !isNumber(0)) {
                while (isSafe(0)) {
                    value += str.charAt(i);
                    i++;
                }
                tokens[tokens.length - 1].push(new Token(Tokens.IDENTIFIER, value));
                continue;
            }
            
            if (isNumber(0) || char == "." || char == "-") {
                var mult: Int = 1;
                var seenDot = false;
                if (char == "-") {
                    i++;
                    mult = -1;
                }
                while (isNumber(0) || (!seenDot && (seenDot = str.charAt(i) == '.'))) {
                    value += str.charAt(i);
                    i++;
                }
                tokens[tokens.length - 1].push(new Token(Tokens.NUMBER, Std.parseFloat(value) * mult));
                continue;
            }

            trace('ERROR: Unknown token $char at position $i');
            i++;
        }

        tokens[tokens.length - 1].push(new Token(Tokens.EOF));
        return tokens;
    }

    private function eatNext(char: String): Bool {
        if (peakNext(char)) {
            i++;
            return true;
        }
        return false;
    }

    private function peakNext(char: String): Bool {
        if (i + 1 >= str.length) return false;
        else return (str.charAt(i + 1) == char);
    }

    private function isSafe(n:Int = 1, includeDot:Bool = true) {
        if (i + n >= str.length) return false;
        var charCode: Int = str.charCodeAt(i + n);
        if (charCode >= 65 && charCode <= 90) return true;
        if (charCode >= 97 && charCode <= 122) return true;
        if (charCode >= 48 && charCode <= 57) return true;
        if (charCode == 95) return true;
        return charCode == 46 && includeDot;
    }

    private function isNumber(n:Int = 1) {
        if (i + n >= str.length) return false;
        var charCode: Int = str.charCodeAt(i + n);
        return charCode >= 48 && charCode <= 57;
    }
}

class Parser {
    var variables = new Map<String, Dynamic>();
    
    public function new() {
        //
    }

    public function parse(tokens: Array<Array<Token>>) {
        var _lines = new Array<Array<String>>();
        for (line in tokens) {
            var _line = new Array<String>();
            for (token in line) {
                _line.push(token.toString());
            }
            _lines.push(_line);
        }
        trace(_lines);
    }

    private function parseExpression(tokens: Array<Token>): Array<Dynamic> {
        var AST: Array<Dynamic> = [];
        var inParentheses = false;

        if (tokens.length > 0 && tokens[0].type == Tokens.LEFT_PAREN && tokens[tokens.length - 1].type == Tokens.RIGHT_PAREN) {
            tokens.shift();
            tokens.pop();
        }

        var j: Int = tokens.length - 1;
        while (j >= 0) {
            if (tokens[j].type == Tokens.RIGHT_PAREN) inParentheses = true;
            if (tokens[j].type == Tokens.LEFT_PAREN) inParentheses = false;
            if (inParentheses) continue;

            if (tokens[j].type == Tokens.OR) {
                AST.push(new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.OR));
                return AST;
            }

            j--;
        }

        j = tokens.length - 1;
        while (j >= 0) {
            if (tokens[j].type == Tokens.RIGHT_PAREN) inParentheses = true;
            if (tokens[j].type == Tokens.LEFT_PAREN) inParentheses = false;
            if (inParentheses) continue;

            if (tokens[j].type == Tokens.AND) {
                AST.push(new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.AND));
                return AST;
            }

            j--;
        }

        j = tokens.length - 1;
        while (j >= 0) {
            if (tokens[j].type == Tokens.RIGHT_PAREN) inParentheses = true;
            if (tokens[j].type == Tokens.LEFT_PAREN) inParentheses = false;
            if (inParentheses) continue;

            if (tokens[j].type == Tokens.NOT) {
                AST.push(new UnaryExpression(parseExpression(tokens.slice(j + 1)), Tokens.NOT));
                return AST;
            }

            j--;
        }

        inParentheses = false;
        j = tokens.length - 1;
        while (j >= 0) {
            if (tokens[j].type == Tokens.RIGHT_PAREN) inParentheses = true;
            if (tokens[j].type == Tokens.LEFT_PAREN) inParentheses = false;
            if (inParentheses) continue;

            if (tokens[j].type == Tokens.EQUAL_EQUAL) {
                AST.push(new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.EQUAL_EQUAL));
                return AST;
            } else if (tokens[j].type == Tokens.LESS) {
                AST.push(new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.LESS));
                return AST;
            } else if (tokens[j].type == Tokens.LESS_EQUAL) {
                AST.push(new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.LESS_EQUAL));
                return AST;
            } else if (tokens[j].type == Tokens.GREATER) {
                AST.push(new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.GREATER));
                return AST;
            } else if (tokens[j].type == Tokens.GREATER_EQUAL) {
                AST.push(new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.GREATER_EQUAL));
                return AST;
            }

            j--;
        }

        inParentheses = false;
        j = tokens.length - 1;
		while (j >= 0) {
            if (tokens[j].type == Tokens.RIGHT_PAREN) inParentheses = true;
            if (tokens[j].type == Tokens.LEFT_PAREN) inParentheses = false;
            if (inParentheses) continue;

            if (tokens[j].type == Tokens.PLUS) {
                AST.push(new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.PLUS));
                return AST;
            } else if (tokens[j].type == Tokens.MINUS) {
                AST.push(new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.MINUS));
                return AST;
            }

            j--;
        }

        inParentheses = false;
        j = tokens.length - 1;
		while (j >= 0) {
            if (tokens[j].type == Tokens.RIGHT_PAREN) inParentheses = true;
            if (tokens[j].type == Tokens.LEFT_PAREN) inParentheses = false;
            if (inParentheses) continue;

            if (tokens[j].type == Tokens.DIVIDE) {
                AST.push(new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.DIVIDE));
                return AST;
            } else if (tokens[j].type == Tokens.MULTIPLY) {
                AST.push(new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.MULTIPLY));
                return AST;
            } else if (tokens[j].type == Tokens.MODULO) {
                AST.push(new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.MODULO));
                return AST;
            }
            
            j--;
        }

        return tokens;
    }

    private function evaluateExpression(subtree: Array<Dynamic>): Dynamic {
        subtree = subtree[0];
        if (Std.is(subtree, BinaryExpression)) {
            var _subtree = cast (subtree, BinaryExpression);
            return BinaryExpression.evaluate(evaluateExpression(_subtree.a), evaluateExpression(_subtree.b), _subtree.op);
        } else if (Std.is(subtree, UnaryExpression)) {
            var _subtree = cast (subtree, UnaryExpression);
            return UnaryExpression.evaluate(evaluateExpression(_subtree.value), _subtree.op);
        } else if (Std.is(subtree, Token)) {
            var _subtree = cast (subtree, Token);
            switch (_subtree.type) {
                case Tokens.NUMBER: return _subtree.value;
                case Tokens.STRING: return _subtree.value;
                case Tokens.IDENTIFIER: return variables.get(_subtree.value);
                case Tokens.TRUE: return true;
                case Tokens.FALSE: return false;
                default: return null;
            }
        }
        return null;
    }
}