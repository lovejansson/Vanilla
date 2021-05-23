require './rdparse.rb'
require './nodes.rb'

class VanillaParser
  def initialize()
    @parser = Parser.new("Vanilla language") do

      # comments (only single line)
      token(/#.*/)
      
      token(/[\n\r]/) { | separators | separators } 
      token(/\s/)
      token(/"[^"]*"/) { | string | VString.new(string[1...-1]) }
      token(/'[^']*'/) { | string | VString.new(string[1...-1]) }
  
      token(/\d+\.\d+/) { | float | float.to_f() }
      token(/\d+/) { | integer | integer.to_i() }
      
      token(/or/) { | b_operator | b_operator }
      token(/and/) { | b_operator | b_operator }

      token(/\+=/) { | short_op | short_op }
      token(/-=/) { | short_op | short_op}
      token(/\*=/) { | short_op | short_op}
      token(/\/=/) { | short_op | short_op}
      token(/\^=/) { | short_op | short_op}
      token(/%=/) { | short_op | short_op}

      token(/==/) { | c_operator | c_operator }
      token(/>=/) { | c_operator | c_operator }
      token(/<=/) { | c_operator | c_operator }
      token(/</) { | c_operator | c_operator }
      token(/>/) { | c_operator | c_operator }
      token(/!=/) { | c_operator | c_operator }
      token(/!/) {| b_operator | b_operator }

      token(/[\+\-\*\/\^%=]/) { | a_operator | a_operator }

      token(/endfor/) { | block_end | block_end }
      token(/endif/) { | block_end | block_end }
      token(/endwhile/) { | block_end | block_end }
      token(/end/) { | block_end | block_end }

      token(/[\w!\?]+/) { | identifier | identifier }
  
      token(/[\{\}\[\]:\(\),\.]/) { | special_char | special_char }


      start :program do 
        match(:separator, :function, :separator, :program, :separator) do | _, function, _, program, _ |
          program << function 
        end

        match(:function, :separator, :program, :separator) do | function, _, program, _ | 
          program << function 
        end

        match(:separator, :function, :separator, :program) do | _, function, _, program |
          program << function 
        end

        match(:function, :separator, :program) do | function, _, program | 
          program << function 
        end

        match(:separator, :function, :separator) { | _, f, _ | [f] } 
 
        match(:function, :separator) { | f, _ | [f] } 

        match(:separator, :function) { | _, f | [f] }  

        match(:function)  { | f | [f] }   
  
        match(:separator) 
      end 
  
      rule :function do
        match(:types, :name, :parameters, ":", :block, "end") do | types, name, parameters, _, block, _ |
          Function.new(types, name, parameters.reverse(), Block.new(block.reverse()))
         end
      end

      rule :parameters do
        match("(", ")") { | _, _ | [] }
        match("(", :parameter_list, ")") { |_, parameters, _ | parameters }
      end

      rule :parameter_list do
        match(:declaration, ',', :parameter_list) { | param, _, list | list << param }
        match(:declaration) { | param | [param] }
      end

      rule :block do
        match(:separator, :valid, :block) { | _, s, list |  list << s } 
        match(:separator, :valid, :separator) { | _, s, _ | [s] }
        # This is so that empty if_statements and iterations can be written
        match(:separator) { | _ | [] }
      end

      rule :separator do
        match( /[\n\r]/, :separator) 
        match(/[\n\r]/) 
      end

      rule :valid do
        match(:statement)
        match(:lambda_expression)
      end  

      rule :statement do
        match(:declaration)
        match(:assignment)
        match(:return)
        match("break") {  IterationInterrupt.new(:break) }
        match("next") {   IterationInterrupt.new(:next) }
        match(:print)
        match(:if)
        match(:iteration)
      end

      rule :declaration do
        match(:types, :name, "=", :lambda_expression) do | types, name, _, expr | 
          VariableDeclarationDef.new(types, name, expr) 
        end

        match(:types, :name) do | types, name | 
          VariableDeclarationDef.new(types, name) 
        end 
     end

      rule :assignment do
        match(:name, :assign_op, :lambda_expression) do | name, op, expr | 
          VariableAssignment.new(name, op, expr) 
        end
      end

      rule :assign_op do
        match("=")
        match("+=")
        match("-=")
        match("*=")
        match("/=")
        match("^=")
        match("%=")
      end 

      rule :return do
        match("return", :lambda_expression) do | _, expr |
          Return.new(expr)
        end
      end

      rule :print do 
        match("print", "(", :lambda_expression, ")") do | _, _, expr, _ | 
          Print.new(expr) 
        end

        match("printn", "(", :lambda_expression, ")") do | _, _, expr, _ | 
          Print.new(expr, true) 
        end 
      end

      rule :if do 
        match(:simple_if)
        match(:compounded_if) 
      end

      rule :simple_if do 
        match("if", :lambda_expression, ":", :block, "endif") do | _, expr, _, block, _ | 
          If.new({ expr => Block.new(block.reverse()) })
        end 
      end 

      rule :compounded_if do 
        match("if", :lambda_expression, ":", :block, :branches, "endif") do | _, expr, _, block, branches, _ |
          If.new({ expr => Block.new(block.reverse()) }.merge(branches))
        end
      end 

      rule :branches do 
        match(:elseif_branch, :branches) do | elseif, branches | 
          elseif.merge(branches) 
        end

        match(:elseif_branch)
        match(:else_branch) 
      end 

      rule :elseif_branch do
        match("elseif", :lambda_expression, ":", :block) do | _, expr, _, block |
          {expr => Block.new(block.reverse())} 
        end
      end

      rule :else_branch do
        match("else", ":", :block) do | _, _, block | 
           {Bool.new(true) => Block.new(block.reverse())} 
        end
      end 

      rule :iteration do 
        match(:for_loop)
        match(:for_each)
        match(:while_loop)
      end 

      rule :for_loop do 
         match("for", :declaration, ",", :lambda_expression, ",", :assignment,
         ":", :block, "endfor") do | _, declaration, _, expr, _, step, _, block, _ |
          ForLoopDef.new(declaration, expr, Block.new(block.reverse()), step) 
         end
      end

      rule :for_each do
        match("for", :declaration, "in", :lambda_expression,
        ":", :block, "endfor") do | _, iter, _, expr, _, block, _ |
        ForEachDef.new(iter, expr, Block.new(block.reverse())) 
        end
        
        match("for", :declaration, ",", :declaration, "in", :lambda_expression,
        ":", :block, "endfor") do | _, key_iter, _, value_iter, _, expr, _, block, _ |
        ForEachDef.new([key_iter, value_iter], expr, Block.new(block.reverse())) 
        end 

        match("for", :auto, "in", :lambda_expression,
        ":", :block, "endfor") do | _, iter, _, expr, _, block, _ |
        ForEachDef.new(iter, expr, Block.new(block.reverse())) 
        end
        
        match("for", :auto, ",", :auto, "in", :lambda_expression,
        ":", :block, "endfor") do | _, key_iter, _, value_iter, _, expr, _, block, _ |
        ForEachDef.new([key_iter, value_iter], expr, Block.new(block.reverse())) 
        end
      end

      rule :auto do
        match("auto", :name) { | _, name |  VariableDeclarationDef.new(:auto, name) }
      end 

      rule :while_loop do 
        match("while", :lambda_expression, ":", :block, "endwhile" ) do | _, expr, _, block, _ |
          WhileLoop.new(expr, Block.new(block.reverse()))
        end 
      end

      rule :lambda_expression do
        # empty

        match("[", "]", :parameters, ":", "end") do | _, _, parameters, _, _ | 
          Lambda.new(parameters.reverse(), nil)
        end

        match("[", :captures, "]", :parameters, ":", "end") do | _, captures, _, parameters, _, _ | 
          Lambda.new(parameters.reverse(), nil, captures)
        end

        # with expression 

        match("[", "]", :parameters, ":", :lambda_expression, "end") do | _, _, parameters, _, expr, _ | 
          Lambda.new(parameters.reverse(), expr)
        end

        match("[", :captures, "]", :parameters, ":", :lambda_expression, "end") do | _, captures, _, parameters, _, expr, _ |
          Lambda.new(parameters.reverse(), expr, captures)
        end

        match(:bool_expression)
      end 

      rule :captures do
        match(:name, ",", :captures) { | name, _, list | list << name }
        match(:name) { | name | [name] }
      end 

      rule :bool_expression do
        match(:bool_expression, "or", :bool_term) { | lhs, op, rhs | BoolExpression.new(lhs, op, rhs) }
        match(:bool_term)
      end

      rule :bool_term do
        match(:bool_term, "and", :bool_factor) { | lhs, op, rhs | BoolExpression.new(lhs, op, rhs) }
        match(:bool_factor)
      end
      
      rule :bool_factor do
        match("not", :bool_factor) { | _, factor | NotBoolExpression.new(factor) }
        match("!", :bool_factor) { | _, factor |   NotBoolExpression.new(factor) }
        match(:comp_expression)
      end 

      rule :comp_expression do 
        match(:comp_expression, :comp_operator, :arithmetic_expression) do | a, op, b | 
          ComparisonExpression.new(a, op, b)
        end

        match(:arithmetic_expression)
      end
      
      rule :comp_operator do
        match(">")
        match("<") 
        match(">=") 
        match("<=") 
        match("==")
        match("!=")   
      end

      rule :arithmetic_expression do
          match(:arithmetic_expression, '+', :arithmetic_term) do | lhs, _ , rhs | 
            Addition.new(lhs, rhs) 
          end

          match(:arithmetic_expression, '-', :arithmetic_term) do | lhs, _ , rhs | 
            Subtraction.new(lhs, rhs) 
          end

          match(:arithmetic_term)
      end

      rule :arithmetic_term do
        match(:arithmetic_term, '*', :arithmetic_factor) do | lhs, _ , rhs | 
          Multiplication.new(lhs, rhs) 
        end

        match(:arithmetic_term, '/', :arithmetic_factor) do | lhs, _ , rhs | 
          Division.new(lhs, rhs) 
        end

        match(:arithmetic_term, '%', :arithmetic_factor) do| lhs, _ , rhs | 
          Mod.new(lhs, rhs) 
        end

        match(:arithmetic_factor)
      end

      rule :arithmetic_factor do
        match(:method, '^', :arithmetic_factor) do | lhs, _ , rhs |
          Power.new(lhs, rhs) 
        end

        match(:method)
      end

      rule :method do
        match(:method, ".", :name , :args) do | object, _,  name, args | 
          MethodCall.new(object, name, args) 
        end

        match(:method, "[", :lambda_expression , "]", "=", :lambda_expression) do | object, _, arg, _, _, arg2 | 
          MethodCall.new(object, "[]=", [arg, arg2]) 
        end

        match(:method, "[", :lambda_expression , "]") do | object, _, arg, _ | 
          MethodCall.new(object, "[]", [arg]) 
        end

        match(:atom)
      end
    
      rule :atom do
        match(:input)
        match(:function_call)
        match("-", Float) { | _, f | VFloat.new(-f) }
        match("-", Integer) { | _, i | Int.new(-i) }
        match(Float) { | f | VFloat.new(f) }
        match(Integer) { | i | Int.new(i) }
        match(VString) 
        match(:list)
        match(:map)
        match("true") { Bool.new(true) }
        match("false") { Bool.new(false) }
        match(:name) { | var | VariableAccess.new(var) }
        match('(', :lambda_expression, ')') { | _, expr, _ | expr}
      end

      rule :function_call do
        match(:name, :args) { | name, args | FunctionCall.new(name, args) }
      end

      rule :input do
        match("input", "(", :lambda_expression, ")") { | _, _, msg, _ | Input.new(msg) }
        match("input", "(", ")") { Input.new() }
      end 

      rule :list do
         match("[", :arg_list ,"]") { | _, elems, _ | List.new(elems.reverse()) }
         match("[", "]") { List.new() }
      end

      rule :map do
        match("{", :pairs ,"}") { | _, mappings, _ | Map.new(mappings.to_a().reverse().to_h) }
        match("{", "}") {  Map.new() }  
      end 

      rule :pairs do 
        match(:key_value, ",", :pairs) { | pair, _, tot | tot.merge(pair) }
        match(:key_value)
      end

      rule :key_value do
        match(:lambda_expression, ":", :lambda_expression) { | key, _, value | { key => value} }
      end 

      rule :args do
        match("(", ")") {[]}
        match("(", :arg_list , ")") { | _, list, _ | list.reverse() } 
      end
     
      rule :arg_list do
        match(:lambda_expression, ",", :arg_list) { | a, _, list | list << a }
        match(:lambda_expression) { | arg | [arg] }
      end

      rule :types do
        match("map", "<", :types, ",", :types, ">") do | type, _, key, _, value, _ |
          [key , value]
        end
  
        match("list", "<", :types, ">") do | type, _, subtypes, _ | 
          {:subtype => subtypes} 
        end

        match(:type)
      end

      rule :type do
        match("int") { Int }
        match("string") { String }
        match("float") { Float }
        match("nothing") { :nothing }
        match("bool") { Bool }
        match("lambda") { Lambda }
      end

      rule :name do
        match(/^(?!\[$)(?!\]$)(?!printn$)(?!print$)(?!input$)(?!end$)(?!endwhile$)(?!endfor$)(?!endif$)(?!do$)[a-z_][0-9a-zA-Z=_]*[!?]?$/)
      end
    end
  end

  def log(state = true)
    if state
      @parser.logger.level = Logger::DEBUG
    else
      @parser.logger.level = Logger::WARN
    end
  end

  def test_run(str)
    res = @parser.parse str
    if res.class == Array and res != [] 
      return Program.new(res.reverse).evaluate()
    end
  end 

  def run(filename)
    str = File.read(filename)
    res = @parser.parse(str) 
  
    if res.class == Array and res != []
      return Program.new(res.reverse()).evaluate()
    end
  end

end

if __FILE__ == $0
  parser = VanillaParser.new()

  parser.log(false)

  if ARGV[0].include?("/") 
    file_path = ARGV[0]
  else 
    file_path = "./" + ARGV[0]
  end

  parser.run(file_path)
end

