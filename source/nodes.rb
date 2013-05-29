#!/usr/bin/env ruby
# -*- coding: utf-8 -*-


class Node
	def initialize()
	end
	
	def eval()
	end
end

class LogicNode < Node
	def initialize(lhs, operator, rhs)
		@vars = [lhs, rhs]
		@op = operator
	end
	
	def eval()
		evVars = []
		@vars.each {|var|
			begin
				evVars.push(var.eval())
			rescue NoMethodError
				evVars.push(var)
			end}
		return evVars[0].send(@op, evVars[1])
	end
end

class MathNode < Node
	def initialize(lhs, operator, rhs)
		@vars = [lhs, rhs]
		@op = operator
	end
	
	def eval()
		evVars = []
		@vars.each {|var|
			begin
				evVars.push(var.eval())
			rescue NoMethodError
				evVars.push(var)
			end}
		 evVars.each {|var|
		 	if not var.is_a?(Numeric)
		 		puts "Matematik fungerar enbart med tal!"
		 		exit()
		 	end}
		if @op == :/ and evVars[1] == 0
			puts "Dela inte med noll. Gör det helt enkelt inte. Man sprängs."
			exit()
		end
		return evVars[0].send(@op, evVars[1])
	end
end

class UnaryNode < Node
	def initialize(operator, rhs)
		@op = operator
		@rhs = rhs
	end
	def eval()
		begin
			evRhs = rhs.eval
		rescue NoMethodError
			evRrhs = @rhs
		end
		return eval("#{@op} #{evRhs}")
	end
end

class ComparisonNode < Node
	def initialize(lhs, operator, rhs)
		@vars = [lhs, rhs]
		@op = operator
	end
	
	def eval()
		evVars = []
		@vars.each {|var|
			begin
				evVars.push(var.eval())
			rescue NoMethodError
				evVars.push(var)
			end}
		return evVars[0].send(@op, evVars[1])
	end
end

class ExpressionNode < Node
	def initialize(child)
		@childNode = child
	end

	def eval()
		begin
			evChildNode = @childNode.eval()
		rescue NoMethodError
			evChildNode = @childNode
		end
		return evChildNode
	end
end

class IdNode < Node

	attr_reader :name
	@@scope = 0
	@@vars = [{}]

	def self.increaseScope
		@@scope += 1
		@@vars.push({})
	end
	
	def self.decreaseScope
		@@scope -= 1
		@@vars.pop
	end

	def initialize(name)
		@name = name
	end

	def setVar(var)
		@@vars[@@scope][@name] = [:var, var]
	end

	def bindFunc(funcnode)
		@@vars[@@scope][@name] = [:func, funcnode]
	end

	def call(argslist)
		if @name == "indata"
			data = $stdin.gets.chomp
			if data.match(/^\d+\.\d+$/)
				return data.to_f
			elsif data.match(/^([1-9](\d)*)$/)
				return data.to_i
			else
				return data.to_s
			end
		elsif not @@vars[@@scope][@name].nil?
			if @@vars[@@scope][@name][0] == :func
				ret = @@vars[@@scope][@name][1].eval(argslist)
			else
				ret = @@vars[@@scope][@name][1]
			end
		else
			puts "Variabeln eller funktionen finns inte. Deklarera den innan du anropar den!"
			exit()
		end
		return ret
	end
end

class FuncDefNode < Node
	def initialize(id, block, idlist)
		@id = id
		@block = block
		@idlist = idlist
	end
	
	def eval()
		@id.bindFunc(FuncNode.new(@id.name, @block, @idlist))
	end
end

class FuncNode < Node
	def initialize(name, block, idlist)
		@name = name
		@block = block
		@idlist = idlist
	end
	
	def eval(argslist)
		evArgslist = argslist.map {|arg|
		begin
			arg.eval()
		rescue NoMethodError
			arg
		end}
		IdNode.increaseScope
		if evArgslist.size() ==  @idlist.size()
			@idlist.each_with_index {|id, i|
			begin
				id.setVar(evArgslist[i].eval())
			rescue NoMethodError
				id.setVar(evArgslist[i])
			end}
		else
			puts "\nFel antal argument till funktion: " + @name
			exit()
		end
		ret = @block.eval()
		if ret.is_a?(ReturnNode)
			ret = ret.getValue
			IdNode.decreaseScope
			return ret
		elsif ret.is_a?(AbortNode)
			puts "\nOtillåten användning av 'avbryt' i funktion: " + @name
			puts "Använd 'skicka tillbaka' för att avbryta funktioner."
			exit()
		end
		IdNode.decreaseScope
		return ret
	end
end

class BlockNode < Node
	def initialize(stmt_list)
		@statements = stmt_list
	end
	
	def eval()
		@statements.each {|stmt|
		if stmt != "\n"
			evStmt = stmt.eval()
			if evStmt.is_a?(ReturnNode)
				return evStmt
			elsif evStmt.is_a?(AbortNode)
				return evStmt
			end
		end}
	end
end

class CallNode < Node
	def initialize(id, argslist=[])
		@id = id
		@argslist = argslist
	end
	
	def eval()
		return @id.call(@argslist)
	end
end

class AssignmentNode < Node
	def initialize(id, expr)
		@id = id
		@expr = expr
	end
	
	def eval()
		begin
			@id.setVar(@expr.eval())
		rescue NoMethodError
			@id.setVar(@expr)
		end
	end
end

class PrintNode < Node
	def initialize(string)
		@str = string
	end
	
	def eval()
		begin
			evStr = @str.eval()
		rescue NoMethodError
			evStr = @str
		end
		print evStr
		$stdout.flush
	end
end

class ReturnNode < Node
	def initialize(expr)
		@expr = expr
	end
	
	def getValue()
		begin
			ret = @expr.eval()
		rescue NoMethodError
			ret = @expr
		end

		return ret
	end
	
	def eval()
		return self
	end
end

class AbortNode < Node
	def eval()
		return self
	end
end

class IfNode < Node
	def initialize(expr, mainBlock, elifNode=nil)
		@expr = expr
		@mainBlock = mainBlock
		@elifNode = elifNode
	end
	
	def eval()
		begin
			evExpr = @expr.eval
		rescue NoMethodError
			evExpr = @expr
		end
		if evExpr
			@mainBlock.eval()
		elsif @elifNode != nil
			@elifNode.eval()
		end
	end
end

class WhileNode < Node
	def initialize(expr, block)
		@expr = expr
		@block = block
	end
	
	def eval()
		loop do
			begin
				evExpr = @expr.eval()
			rescue NoMethodError
				evExpr = @expr
			end
			if not evExpr
				break
			else
				@block.eval
			end
		end
	end
end