# https://www.cs.rochester.edu/~brown/173/readings/05_grammars.txt
#
#  "TINY" Grammar
#
# PGM        -->   STMT+
# STMT       -->   ASSIGN   |   "print"  EXP
# ASSIGN     -->   ID  "="  EXP
# EXP        -->   TERM   ETAIL
# ETAIL      -->   "+" TERM   ETAIL  | "-" TERM   ETAIL | EPSILON
# TERM       -->   FACTOR  TTAIL
# TTAIL      -->   "*" FACTOR TTAIL  | "/" FACTOR TTAIL | EPSILON
# FACTOR     -->   "(" EXP ")" | INT | ID
# EPSILON    -->   ""
# ID         -->   ALPHA+
# ALPHA      -->   a  |  b  | … | z  or
#                  A  |  B  | … | Z
# INT        -->   DIGIT+
# DIGIT      -->   0  |  1  | …  |  9
# WHITESPACE -->   Ruby Whitespace

#
#  Parser Class
#
load "Lexer.rb"
class Parser < Scanner

    def initialize(filename)
        super(filename)
        consume()
    end

    def consume()
        @lookahead = nextToken()
        while(@lookahead.type == Token::WS)
            @lookahead = nextToken()
        end
    end

    def match(dtype)
        if (@lookahead.type != dtype)
            puts "Expected #{dtype} found #{@lookahead.text}"
			@errors_found+=1
        end
        consume()
    end

    def program()
    	@errors_found = 0
		
		p = AST.new(Token.new("program","program"))
		
	    while( @lookahead.type != Token::EOF)
            p.addChild(statement())
        end
        
        puts "There were #{@errors_found} parse errors found."
      
		return p
    end

    def statement()
		stmt = AST.new(Token.new("statement","statement"))
        if (@lookahead.type == Token::PRINT)
			stmt = AST.new(@lookahead)
            match(Token::PRINT)
            stmt.addChild(exp())
        else
            stmt = assign()
        end
		return stmt
    end

    def exp()
        exp = AST.new(Token.new("exp","exp"))
        termTree = term() #
        exp = etail()
        if(exp != nil)
            exp.addChild(termTree)
            return exp
        else
            return termTree
        end
    end

    def term()
        term = AST.new(Token.new("term","term"))
        factor = factor()
        term = ttail()
        if(term != nil)
            term.addChild(factor)
            return term
        else
            return factor
        end
    end

    def factor()
        fct = AST.new(Token.new("factor", "factor"))
        if (@lookahead.type == Token::LPAREN)
            match(Token::LPAREN)
            fct = exp()
            if (@lookahead.type == Token::RPAREN)
                match(Token::RPAREN)
            else
				match(Token::RPAREN)
            end
        elsif (@lookahead.type == Token::INT)
            fct = AST.new(@lookahead)
            match(Token::INT)
        elsif (@lookahead.type == Token::ID)
            fct = AST.new(@lookahead)
            match(Token::ID)
        else
            puts "Expected ( or INT or ID found #{@lookahead.text}"
            @errors_found+=1
            consume()
        end
		return fct
    end

    def ttail()
        ttail = AST.new(Token.new("ttail", "ttail"))
        if (@lookahead.type == Token::MULTOP)
            ttail = AST.new(@lookahead)
            match(Token::MULTOP)
            factor = factor()
            child = ttail()
            if(child != nil)
                child.addChild(factor)
                ttail.addChild(child)
            else
                ttail.addChild(factor)
            end
        elsif (@lookahead.type == Token::DIVOP)
            ttail = AST.new(@lookahead)
            match(Token::DIVOP)
            factor = factor()
            child = ttail()
            if(child != nil)
                child.addChild(factor)
                ttail.addChild(child)
            else
                ttail.addChild(factor)
            end
		else
			return nil
        end
        return ttail
    end

    def etail()
        #todo
        etail = AST.new(Token.new("etail", "etail"))
        if (@lookahead.type == Token::ADDOP)
            etail = AST.new(@lookahead)
            match(Token::ADDOP)
            #add term as a child of etail
            #add etail to etail
            term = term()
            child = etail()
            if(child != nil)
                child.addChild(term)
                etial.addChild(child)
            else
                etail.addChild(term)
            end
        elsif (@lookahead.type == Token::SUBOP)
            etail = AST.new(@lookahead)
            match(Token::SUBOP)
            term = term()
            child = etail().addChild(term)
            etail.addChild(child)
		else
			return nil
        end
        return etail
    end

    def assign()
        assgn = AST.new(Token.new("assignment","assignment"))
		if (@lookahead.type == Token::ID)
			idtok = AST.new(@lookahead)
			match(Token::ID)
			if (@lookahead.type == Token::ASSGN)
				assgn = AST.new(@lookahead)
				assgn.addChild(idtok)
            	match(Token::ASSGN)
				assgn.addChild(exp())
        	else
				match(Token::ASSGN)
			end
		else
			match(Token::ID)
        end
		return assgn
	end
end
