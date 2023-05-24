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
# ID         -->   ALPHA+
# ALPHA      -->   a  |  b  | … | z  or
#                  A  |  B  | … | Z
# INT        -->   DIGIT+
# DIGIT      -->   0  |  1  | …  |  9
# WHITESPACE -->   Ruby Whitespace

#
#  Parser Class
#
load "Token.rb"
load "Lexer.rb"
class Parser < Scanner
	
	def initialize(filename)
    	super(filename)
		 @errors = 0;
    	consume()
   end
   	
	def consume()
		@lookahead = nextToken()
		while(@lookahead.type == Token::WS)
		@lookahead = nextToken()
		end
   end
  	
	#dtype == the token name
	#compares the expected token type with the current lookahead
	def match(dtype, tokenVarName)
		if (@lookahead.type != dtype)
			puts "Expected #{dtype} found #{@lookahead.text}"
			@errors += 1;
		else
			puts "Found #{tokenVarName} Token: #{@lookahead.text}"
		end
		consume()
   end
   	
	def program()
		while( @lookahead.type != Token::EOF)
			puts "Entering STMT Rule"
			statement()
		end
		puts "There were #{@errors} parse errors found."
   end

	def statement()
		if (@lookahead.type == Token::PRINT)
			match(Token::PRINT, "PRINT")
			puts "Entering EXP Rule"
			exp()
		else
			puts "Entering ASSGN Rule"
			assign()
		end
		
		puts "Exiting STMT Rule"
	end

	def assign()
		match(Token::ID, "ID")
		match(Token::ASSGN, "ASSGN")
		puts "Entering EXP Rule"
		exp()
		puts "Exiting ASSGN Rule"
	end

	def exp()
		puts "Entering TERM Rule"
		term()
		puts "Entering ETAIL Rule"
		etail()
		puts "Exiting EXP Rule"
	end

	
	def etail()
		if(@lookahead.type == Token::ADDOP)
			match(Token::ADDOP, "ADDOP")
			puts "Entering TERM Rule"
			term()
			puts "Entering ETAIL Rule"
			etail()
		elsif (@lookahead.type == Token::SUBOP)
			match(Token::SUBOP, "SUBOP")
			puts "Entering TERM Rule"
			term()
			puts "Entering ETAIL Rule"
			etail()
		else
			puts "Did not find ADDOP or SUBOP Token, choosing EPSILON production"
		end

		puts "Exiting ETAIL Rule"
	end	

	def term()
		puts "Entering FACTOR Rule"
		factor()
		puts "Entering TTAIL Rule"
		ttail()
		puts "Exiting TERM Rule"
	end

	def ttail()
		if(@lookahead.type == Token::MULTOP)
			match(Token::MULTOP, "MULTOP")
			puts "Entering FACTOR Rule"
			factor()
			puts "Entering TTAIL Rule"
			ttail()
		elsif (@lookahead.type == Token::DIVOP)
			match(Token::DIVOP, "DIVOP")
			puts "Entering FACTOR Rule"
			factor()
			puts "Entering TTAIL Rule"
			ttail()
		else
			puts "Did not find MULTOP or DIVOP Token, choosing EPSILON production"
		end

		puts "Exiting TTAIL Rule"
	end

	def factor()
		if (@lookahead.type == Token::LPAREN)
			match(Token::LPAREN, "LPAREN")
			puts "Entering EXP Rule"
			exp()
			match(Token::RPAREN, "RPAREN")
		elsif (@lookahead.type == Token::INT)
			match(Token::INT, "INT")
		elsif (@lookahead.type == Token::ID)
			match(Token::ID, "ID")
		else
			puts "Expected ( or INT or ID found #{@lookahead.text}"
			consume()
			@errors += 1
		end

		puts "Exiting FACTOR Rule"
	end

	def test()
		puts @lookahead.text
	end
end
