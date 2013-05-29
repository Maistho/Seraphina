#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rdparse.rb'
require 'nodes.rb'

class Seraphina

	def initialize
		@@nodes = []
		@parser = Parser.new('Seraphina') do

			token(/\n/) {|m| m}
			token(/\s+/)
			token(/\"[^\n]*\"/) {|m| m}
			token(/\d+\.\d+/) {|m| m.to_f}
			token(/([1-9](\d)*)/) {|m| m.to_i}
			token(/0/) {|m| m.to_i}
			token(/inte är/) {|m| m}
			token(/är större än/) {|m| m}
			token(/är mindre än/) {|m| m}
			token(/delat med/) {|m| m}
			token(/annars om/) {|m| m}
			token(/skicka tillbaka/) {|m| m}
			token(/[a-zåäö_\d]+/i) {|m| m}
			token(/\(/) {|m| m}
			token(/\)/) {|m| m}
			token(/[^\s]+/) {|m| m}


			start :start do
				match(:stmt_list) {|a| 
				@@nodes = a}
				match(:stmt_list, /\z/) { |a, _|
				@@nodes = a}
			end

			rule :stmt_list do
				match(:stmt_list, :statement) {|a, b| a.push(b)}
				match(:statement) {|a| [a]}
			end
			
			rule :statement do
				match(:simple_stmt) {|a| a}
				match(:compound_stmt) {|a| a}
				match("\n")
			end

			rule :simple_stmt do
				match(:assignment_stmt) {|a| a}
				match(:expression_stmt) {|a| a}
				match(:print_stmt) {|a| a}
				match(:return_stmt) {|a| a}
				match(:break_stmt) {|a| a}
			end

			rule :expression_stmt do
				match(:expression) {|a| ExpressionNode.new(a)}
			end

			rule :expression do
				match(:or_test) {|a| a}
			end

			rule :or_test do
				match(:and_test) {|a| a}
				match(:or_test, "eller", :and_test) {|a, _, b|
					LogicNode.new(a, :or, b)}
			end

			rule :and_test do
				match(:not_test) {|a| a}
				match(:and_test, "och", :not_test) {|a, _, b|
					LogicNode.new(a, :and, b)}
			end

			rule :not_test do
				match(:comparison) {|a| a}
				match("inte", :not_test) {|_, a| 
					UnaryNode.new(:not, a)}
			end

			rule :comparison do
				match(:a_expr, :comp_operator, :a_expr) {|a, b, c|
					ComparisonNode.new(a, b, c)}
				match(:a_expr){|a| a}
			end

			rule :comp_operator do
				match(/är mindre än/) {|_| :<}
				match(/är större än/) {|_| :>}
				match(/är/) {|_| :==}
				match(/inte är/) {|_| :!=}
			end

			rule :a_expr do
				match(:m_expr) {|a| a}
				match(:a_expr, /(\+)|(plus)/, :m_expr) {|a, _, b|
					MathNode.new(a, :+, b)}
				match(:a_expr, /(\-)|(minus)/, :m_expr) {|a, _, b|
					MathNode.new(a, :-, b)}
			end

			rule :m_expr do
				match(:u_expr) {|a| a}
				match(:m_expr, /\*|(gånger)/, :u_expr) {|a, _, b|
					MathNode.new(a, :*, b)}
				match(:m_expr, /\/|(delat med)/, :u_expr) {|a, _, b|
					MathNode.new(a, :/, b)}
			end

			rule :u_expr do
				match(:primary) {|a| a}
				match('-', :u_expr) {|_, a|
					UnaryNode.new(:-, a)}
				match('+', :u_expr) {|_, a| a}
			end

			rule :primary do
				match(:call) {|a| a}
				match(:atom) {|a| a}
			end

			rule :atom do
				match(:identifier) {|a| a}
				match(:literal) {|a| a}
				match('(', :expression, ')') {|_, a, _| ExpressionNode.new(a)}
			end

			rule :literal do
				match(:string) {|a| a}
				match(:integer) {|a| a}
				match(:floatnumber) {|a| a}
			end

			rule :string do
				match(/\"[^\n]*\"/) {|a| eval("#{a}")}
			end

			rule :integer do
				match(Integer) {|a| a}
			end

			rule :floatnumber do
				match(Float) {|a| a}
			end

			rule :identifier do
				match(/^(?!eller$|och$|inte$|är$|inte är$|är större än$|är mindre än$|plus$|minus$|gånger$|delat med$|med$|och$|blir$|skriv$|avbryt$|om$|annars om$|annars$|medan$|funktion$|använder$|och$|kör$|slut$|skicka tillbaka$)([a-zåäö]([a-zåäö]|\d|_)*)/i) {|a| IdNode.new(a)}
			end

			rule :call do
				match(:identifier, "med", :argslist) {|a, _, b|
					CallNode.new(a,b)}
				match(:identifier) {|a| 
					CallNode.new(a)}
			end

			rule :argslist do
				match(:argslist, "och", :a_expr) {|a, _, b| a.insert(-1, b)}
				match(:a_expr) {|a| [a]}
			end

			rule :assignment_stmt do
				match(:identifier, "blir", :expression) {|a, _, b|
					AssignmentNode.new(a,b)}
			end

			rule :print_stmt do
				match("skriv", :expression) {|_, a|
					PrintNode.new(a)}
			end

			rule :return_stmt do
				match("skicka tillbaka", :expression) {|_, a|
					ReturnNode.new(a)}
			end

			rule :break_stmt do
				match("avbryt") {
					AbortNode.new}
			end

			rule :compound_stmt do
				match(:if_stmt)
				match(:while_stmt)
				match(:funcdef)
			end

			rule :if_stmt do
				match("om", :expression, :block, "\n", :elif_stmt) {|_, a, b, _, c|
					IfNode.new(a, b, c)}
				match("om", :expression, :block) {|_, a, b|
					IfNode.new(a, b)}
			end

			rule :elif_stmt do
				match("annars om", :expression, :block, "\n", :elif_stmt) {|_, a, b, _, c|
					IfNode.new(a, b, c)}
				match("annars om", :expression, :block) {|_, a, b|
					IfNode.new(a, b)}
				match("annars", :block) {|_, a|
					IfNode.new(true, a)}
			end

			rule :while_stmt do
				match("medan", :expression, :block) {|_, a, b|
					WhileNode.new(a, b)}
			end
			
			rule :funcdef do
				match("funktion", :identifier, "använder", :idlist, :block) {|_, a, _, b, c|
					FuncDefNode.new(a, c, b)}
				match("funktion", :identifier, :block) {|_, a, b|
					FuncDefNode.new(a, b)}
			end

			rule :idlist do
				match(:identifier, "och", :idlist) {|a, _, b| b.insert(0, a)}
				match(:identifier) {|a| [a]}
			end

			rule :block do
				match("kör", :stmt_list, "slut") {|_, a, _|
					BlockNode.new(a)}
			end
		end
	end

	def parse(file)
		@parser.logger.level = Logger::WARN
		@parser.parse(STD_LIB+file)
	end
	
	def run()
		#puts @@nodes
		@@nodes.each {|node|
			if node != "\n"
				node.eval()
			end}
	end
end
