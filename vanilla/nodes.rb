require './scope_helpers.rb'
require './type_controll_helpers.rb'
require './errors.rb'


class Numeric
  def initialize(value)
    @value = value
  end

  def absolute()
    return @value.abs() 
  end 

  def evaluate(scope_index)
    return eval("#{@value}")
  end
  
  def string()
    return @value.to_s()
  end

end


class Int < Numeric
  def initialize(value)
    super(value)
  end

  def type()
    return self.class().to_s() 
  end 

  def float()
    return @value.to_f() 
  end

end

""" classes Float and String has a 'V' in class name just so it wouldn't extend 
on Ruby's classes. But in the language it is just called String and Float. 
error messages are adjusted so that it prints out Float instead of VFloat. 
"""
class VFloat < Numeric
  def initialize(value)
    super(value)
  end

  def type()
    return "Float"
  end 

  def round(digits = 0)
    if digits.class() != Integer 
      raise(ArgumentError, "Numeric.round: 'digits' must be of type Int")
    end 

    return @value.round(digits)
  end 

  def int()
    return @value.to_i() 
  end

end


""" classes Float and String has a 'V' in class name just so it wouldn't extend 
on Ruby's classes. But in the language it is just called String and Float. 
error messages are adjusted so that it prints out Float instead of VFloat. 
"""
class VString 
  def initialize(value)
    @value = value
  end

  def type()
    return "String"
  end

  def [](index)
    if index.class() != Integer 
      raise(ArgumentError, "String.[]: 'index' must be of type Int")
    end

    if index > @value.length() - 1
      raise(RangeError, "String.[]: index ranges from 0"\
      " to #{@value.length() - 1}")
    end 
 
    return @value[index]
  end 

  def []=(index, new_value)
    if index.class() != Integer 
      raise(ArgumentError, "String.[]=: 'index' must be of type Int")
    end

    if index > @value.length() - 1 and @value.length() != 0 
      raise(RangeError, "String.[]=: index ranges from 0"\
      " to #{@value.length() - 1}")  
    end 

    if index > @value.length() and @value.length() == 0 
      raise(RangeError, "String.[]=: index ranges from 0 to #{@value.length()}")  
    end 

    if new_value.class() != String 
      raise(ArgumentError, "String.[]=: 'new_value' must be String") 
    end 

    @value[index] = new_value

    return @value
  end

  def length()
    return @value.length()
  end
 
  def split(chr="")
    if chr.class() != String 
      raise(ArgumentError, "String.split: 'chr' must be of type String") 
    end

    array = @value.split(chr)

    return array 
  end 

  def int()
    res = @value.to_i()
 
    if res == 0 and @value != "0"
      raise(RuntimeError, "String.int: can't convert #{@value} to Int") 
    else
      return res
    end 
  end

  def float()
    res = @value.to_f()
    if res == 0.0 and @value != "0.0"
      raise(RuntimeError, "String.float: can't convert #{@value} to Float") 
    else
      return res
    end 
  end

  def upper()
    return @value.upcase()
  end 

  def lower()
    return @value.downcase()
  end

  def sub(original, new_chars, all = false)
    if original.class() != String 
      raise(ArgumentError, "String.sub: 'original' must be of type String")
    end

    if new_chars.class() != String 
      raise(ArgumentError, "String.sub: 'new_chars' must be of type String") 
    end 

    if all.class() != FalseClass and all.class() != TrueClass
      raise(ArgumentError, "String.sub: 'all' must be of type Bool") 
    end 

    if !@value.include?(original) 
      raise(ArgumentError, "String.sub: '#{original}' not included"\
      " in '#{@value}'")
    end 
    
    if all 
      return @value.gsub(/#{original}/, new_chars)
    else
      return @value.sub(/#{original}/, new_chars)
    end 
  end
  
  def is_alpha(all = false)
    if all.class() != FalseClass and all.class() != TrueClass
      raise(ArgumentError, "String.is_alpha: 'all' must be of type Bool") 
    end 

    if all
      @value.each_char() do | chr |
        if !(chr =~ /[[:alpha:]]/) 
          return false
        end  
      end
      return true
    else 
      @value =~ /[[:alpha:]]/ ? true : false
    end
  end
  
  def has_chr(chr)
    if chr.class() != String 
      raise(ArgumentError, "String.has_chr: 'chr' must be of type String")
    end

    return @value.include?(chr)
  end
    
  def evaluate(scope_index)
    return @value
  end

end


class Bool
  def initialize(value)
    @value = value 
  end 

  def evaluate(scope_index)
    return @value 
  end

  def type()
    return self.class().to_s()
  end 

end 


class CompositeDataStructure
  def initialize(value)
    @value = value 
  end

  def type()
    return self.class().to_s() 
  end 

  def length()
    return @value.length()
  end 

  def to_ruby_hash(scope_index)
    """
    Converts @value to a hash with ruby's datatypes instead of vanilla's  

    Args:
        scope_index: Integer, wich scope should be used during evaluations
    Returns: 
        * Hash
    """

    res = @value.transform_keys() do | key |

        if key.class() == List 
            key = key.to_ruby_array(scope_index)
        elsif key.class() == Map 
            key = key.to_ruby_hash(scope_index)
        else 
            key = key.evaluate(scope_index)
        end 

        key 
    end

    res = res.transform_values() do | value |
      
        if value.class() == List
            value = value.to_ruby_array(scope_index)
        elsif value.class() == Map 
            value = value.to_ruby_hash(scope_index)
        else 
            value = value.evaluate(scope_index)
        end
        
        value    
    end

    return res
  end

  def to_ruby_array(scope_index)
    """
    Converts @value to an array with ruby's datatypes instead of vanilla's. 

    Args:
        scope_index: Integer, wich scope should be used during evaluations
    Returns: 
      * Array 
    """
    
    res = @value.collect() do | element |
        if element.class() == List
            element = element.to_ruby_array(scope_index)
        elsif element.class() == Map
            element = element.to_ruby_hash(scope_index) 
        else 
            element = element.evaluate(scope_index)
        end
        
        element 
    end

    return res
  end

end 


class List < CompositeDataStructure
  attr_reader :value

  def initialize(value=[])
    super(value)
  end

  def [](index)
    if index.class() != Integer  
      raise(ArgumentError, "List.[]: 'index' must be of type Int") 
    end 

    if index > @value.length() - 1 and @value.length() != 0
      raise(RangeError, "List.[]: index ranges from 0"\
      " to #{@value.length() - 1}")
    end
    
    if index > @value.length() and @value.length() == 0
      raise(RangeError, "List.[]: index ranges from 0 to #{@value.length()}")
    end 

    return @value[index]
  end 

  def []=(index, new_value)
    if index.class() != Integer  
      raise(ArgumentError, "List.[]=: 'index' must be of type Int")
    end 

    if index > @value.length() - 1 and @value.length() != 0
      raise(RangeError, "List.[]=: index ranges from 0"\
      " to #{@value.length() - 1}")
    end
    
    if index > @value.length() and @value.length() == 0
      raise(RangeError, "List.[]=: index ranges from 0 to #{@value.length()}") 
    end 

    @value[index] = new_value

    # MethodCall.evaluate need new_value for type control
    return @value, new_value   
  end  

  def sorted()
    return @value.sort() 
  end

  def add_to_back(new_value)
    @value.push(new_value)

    # MethodCall.evaluate need new_value for type control
    return @value, new_value  
  end

  def add_to_front(new_value)
    @value.insert(0, new_value)

    # MethodCall.evaluate need new_value for type control
    return @value, new_value 
  end

  def pop_at(index)
    if index.class() != Integer  
      raise(ArgumentError, "List.pop_at: 'index' must be of type Int")
    end 

    if @value.length() == 0 
      raise(RuntimeError, "List.pop_at: List is empty") 
    end

    if index > @value.length() - 1  
      raise(RangeError, "List.pop_at: index ranges from 0"\
      " to #{@value.length() - 1}") 
    end
    
    return @value.delete_at(index)
  end

  def get_index(element) 
    if !@value.include?(element)
      raise(ArgumentError, "List.get_index: element #{element} not in List") 
    end 

    return @value.index(element)
  end

  def evaluate(scope_index)
    # if the List has already been evaluated it will already contain ruby's
    # datatypes and no conversion is needed.
    if !@value.empty? and !is_ruby(@value[0])
      @value = to_ruby_array(scope_index)

    end 

    return @value
  end

end


class Map < CompositeDataStructure
  attr_reader :value

  def initialize(value={})
    super(value)
  end

  def [](key)
    if @value == {}
      raise(KeyError, "Map.[]: Map is empty") 
      
    else
      correct_type = make_type_structure(@value.keys()[0])

      type_control(correct_type, key, "Map.[]", ArgumentError)

      res = @value[key]

      if res
        return res
      else 
        raise(KeyError, "Map.[]: key #{key} doesn't exist") 
      end
    end  

  end
  
  def []=(key, value)
    @value[key] = value

    # MethodCall.evaluate need {key => value} for type control
    return @value, {key => value}
  end 

  def get_keys()
    return @value.keys()
  end 

  def get_values()
    return @value.values() 
  end

  def evaluate(scope_index)
    # if the Map has already been evaluated it will already contain ruby's
    # datatypes and no conversion is needed.
    if !@value.empty? and !is_ruby(@value.keys()[0]) 
      @value = to_ruby_hash(scope_index)

    end

    return @value   
  end

end 


class Program
  def initialize(functions)
    @functions = functions
  end

  def evaluate()
    count_chief = @functions.count() { | f | f.name() == "chief" }

    if count_chief < 1
      raise(RuntimeError, "function 'chief' required but not found") 
    elsif count_chief > 1
      raise(RuntimeError, "only one function named 'chief' is allowed") 
    end

    scope_index = 0 

    @functions.each() do | f |
        f.evaluate(scope_index)
        scope_index += 1
    end

    chief = FunctionCall.new("chief")
    res = chief.evaluate(0)

    return res 
  end

end


class Function
  attr_reader :return_type, :name, :parameters, :body, :scope_index

  def initialize(return_type, name, parameters, body)
    @return_type = return_type
    @name = name
    @parameters = parameters
    @body = body
    @scope_index = nil 
  end

  def evaluate(scope_index)
    $variables.append({})

    @scope_index = scope_index 

    $functions[@name] = self
  end

end


class Lambda
  attr_reader :parameters, :body, :captures

  def initialize(parameters, body, captures = nil)
    @parameters = parameters
    @body = body 
    @captures = captures 
  end 

  def evaluate(scope_index)
    if @captures
     @captures.collect!() do | c | 

        """ captures is a list of variable names whose values ​​the program may 
        need later when the user calls the lambda function. Therefore the 
        element is replaced by a VariableDeclarationDef node with the value of 
        the variable. Later in FunctionCall.evaluate, this node can be evaluated 
        so that it exists in the scope of the lambda body.""" 
        
        value = VariableAccess.new(c).evaluate(scope_index)
        type = look_up(c, $variables[scope_index]).type() 
        variable = VariableDeclarationDef.new(type, c, vanilla_object(value))
        variable
      end
    end

    return self 
  end

  def to_s()
    return "<Lambda:#{object_id}>"
  end

  def inspect()
    return "<Lambda:#{object_id}>"
  end

end


class Block
  def initialize(content)
    @content = content # an Array of statements and/or expressions 
  end

  def evaluate(scope_index)
    """
    evaluates statement(s) and/or expression(s) in @content. 
    This method is called from evaluate-functions im iteration-nodes, 
    functionCall and If.

    Args:
        scope_index: Integer, wich scope should be used during evaluations
    Returns: 
        * Hash {Return => evaluated return value}
        or
        * Symbol of IterationInterrupt: :next or :break 
        or
        * nil 

      obs!!

      The Array of statement(s) and/or expression(s) in @content is dumped and 
      later restored.
      This is because when Lists or Maps are created within different for loops
      with iteration variable(s) as element(s)/key-value-pairs, the Array needs 
      to include the original version of the List/Map the next iteration. 
      Otherwise it will be evaluated and contain the values of the 
      iterationvariable(s) as of first iteration. 
    """

    org_content = Marshal.dump(@content)
    res = nil

    @content.each() do |s| 
      if s.class() == Return
        res = {s.class() => s.evaluate(scope_index)}
        break

      elsif s.class() == IterationInterrupt
        res = s.type_of()
        break    
      end 

      return_value = s.evaluate(scope_index)
      

      if return_value.class() == Hash and return_value.has_key?(Return)
        res = return_value
        break 

      elsif return_value == :next or return_value == :break
        res = return_value
        break
      end

    end

    @content = Marshal.load(org_content)

    return res 
  end 

end 


class FunctionCall
  def initialize(name, arguments = [])
    @name = name
    @arguments = arguments
    @parameters = nil 
    @captures = nil
    @body = nil 
    @recursion = false
    @is_lambda = false 
  end

  def evaluate(scope_index)
    # regular functions has highest priority, i.e. if a lambda- and regular 
    # function has the same name, the regular function will be called. 

    if !$functions[@name]
      variable = look_up(@name, $variables[scope_index])

      if variable
        if variable.value().class() == Lambda
          @is_lambda = true 
          update_instance_variables(variable.value(), scope_index)
        else
          raise "function #{@name} does not exist!"
        end

      else
        raise "function #{@name} does not exist!"
      end
    else
      update_instance_variables($functions[@name], scope_index)
    end

    update_scope()

    evaluate_parameters()

    assert_number_of_arguments()

    assign_arguments(scope_index)

    res = evaluate_function_body() 

    restore_scope()

    return res
  end

  private

  # depending on wether it is lambda or regular function call, different 
  # instance variables are updated before evaluation of body. 
  def update_instance_variables(function, scope_index)
    @parameters = function.parameters()
    @body = function.body()

    if @is_lambda
      @captures = function.captures() 
      @scope_index = scope_index 
    else
      @return_type = function.return_type() 
      @scope_index = function.scope_index() 

      if @scope_index == scope_index
        @recursion = true 
      end
    end 
  end

  def update_scope()
    $stack.append($variables[@scope_index])

    $variables[@scope_index] = {}

    # captures stores VariableDeclarationDef nodes that needs to be added
    # to the scope that the lambda-body has access to.
    if @is_lambda
      if @captures
        @captures.each() do | c |
          c.evaluate(@scope_index)
        end 
      end
    end
  end

  def restore_scope()
    $variables[@scope_index] = $stack.pop()
  end 

  def evaluate_parameters()
    @parameters.each() { | param | param.evaluate(@scope_index) }
  end

  def assert_number_of_arguments()
    required = @parameters.count() { | param | param.value() == nil }

    if @arguments.length() < required
      raise(ArgumentError, "function #{@name}: wrong number of arguments "\
      "#{@arguments.length()} given, expected #{required} to"\
      " #{@parameters.length()}")
    end
  end

  def assign_arguments(scope_index)
    if @parameters.length() != 0
      @parameters.zip(@arguments) do | parameter, argument |
        if argument != nil 
          arg = VariableAssignment.new(parameter.name(), "=", argument)

          """ 
          1. When function is called from another function it needs that scope 
          to search for variables during assignment of the arguments. 

          2. Scope from previous recursion level is needed if the function is
           called from same function. The same is true when it is
           a lambda-call. 
          """ 
          if @scope_index != scope_index
            arg.evaluate(@scope_index, error_msg: "#{@name}", 
            error: ArgumentError, argument_scope: scope_index)

          elsif @recursion or @is_lambda
            arg.evaluate(@scope_index, error_msg: "#{@name}", 
            error: ArgumentError, argument_scope: -1)
          end
        end
      end
    end

  end

  def evaluate_function_body()
    # empty lambda
    if @body == nil
      return_value = nil
    else
      return_value = @body.evaluate(@scope_index)
    end
    
    if !@is_lambda
      if return_value != nil 
        return_value = return_value[Return]
      end

      type_control(@return_type, return_value, @name)
    end 

    return return_value
  end
 
end


class MethodCall
  def initialize(object, method_name, arguments)
    @object = object 
    @method_name = method_name
    @arguments = arguments 
  end 

  def evaluate(scope_index)
    """
    Calls methods via objects and returns the result.

    Args:
        object: vanilla basic datatype or expression
        method_name: String, name of method
        arguments: Array, containing vanilla objects
    Returns: 
        * return values from methods
    """
  
    evaluated_object = @object.evaluate(scope_index)

    changing_object = ["[]=", "add_to_back", "add_to_front"]

    """ If values are added to a composite object (List, Map) via the method 
    call, it's needed to check for correct data type of the added value. """
    if changing_object.include?(@method_name) and get_type(evaluated_object) != String
      org_object = Marshal.dump(evaluated_object)
      type_control_needed = true
    else
      type_control_needed = false  
    end

    call_object = vanilla_object(evaluated_object)

    begin
      if @arguments.length() != 0 
        args = ""
        @arguments.each() do | arg |
          arg = arg.evaluate(scope_index)
          
          if arg.class() == String
            arg = "'" + arg + "'"
          end

          args += arg.to_s() + ","
        end

        args.chop!()
        
        res = eval("call_object.#{@method_name}(#{args})")

        if type_control_needed 
          """
          The methods returns the returnvalue for the user and the added value.
          -added value is for type control!
          """

          added_value = res[1]
          res = res[0]
          
          """
          if the object is stored in a variable, correct type is accessed 
          through the variable.
          """
          if @object.class() == VariableAccess
            variable = look_up(@object.name(), $variables[scope_index])
            type = variable.type()  
          
          """
          if the object is just freely written, types are checked via making a 
          type structure based on the original List/Map.
          """
          else
            org_object = Marshal.load(org_object)
            if org_object == [] or org_object == {}
                return res
            else
              type = make_type_structure(org_object)
            end 
          end

          """
          element type is the value of key :subtype. when it comes to maps 
          [key_type, value_type] is already what variable 'type' contains. 
          """
          if call_object.class() == List
            type = type[:subtype]
          end 

          error_msg = get_type(res).to_s() + "." + @method_name
          type_control(type, added_value, error_msg, ArgumentError)

        end

        return res
      else
        return eval("call_object.#{@method_name}()")
      end

    rescue NoMethodError => error  
      raise error
    end
  end

end


class VariableDeclarationDef
  attr_reader :name
  attr_accessor :type, :value 

  def initialize(type, name, value = nil)
    @type = type
    @name = name
    @value = value
  end

  def evaluate(scope_index)
    evaluate_node = VariableDeclarationEval.new(@type, @name, @value)
    return evaluate_node.evaluate(scope_index)
  end

end 


class VariableDeclarationEval
  attr_accessor :type, :value, :name

  def initialize(type, name, value)
    @type = type
    @name = name
    @value = value
    @default_values = {Hash => [], Array => {}, Int => 0, Float => 0.0, 
    String => "", Bool => false, Lambda => nil }
  end

  def evaluate(scope_index)
    if $variables[scope_index].has_key?(@name)
      raise(DeclarationError, "variable #{@name} already declared") 
    end

    if @value 
      value = @value.evaluate(scope_index)
      
      type_control(@type, value, "VARIABLE DECLARATION")
      
      @value = value

    else
      if @type.class() == Hash or @type.class() == Array 
        @value = @default_values[@type.class()]

      else
        @value = @default_values[@type]
      end
  
    end 
    
    add_variable_to_scope(@name, self, scope_index)

    return self 
  end

  private 

  def add_variable_to_scope(name, value, scope_index)
    $variables[scope_index][name] = value
  end

end


class VariableAssignment
  attr_reader :name

  def initialize(name, op, value)
    @name = name
    @op = op 
    @value = value
  end

  def evaluate(scope_index, argument_scope: false, 
    error_msg: "VARIABLE ASSIGNMENT", error: DatatypeError)

    variable = look_up(@name, $variables[scope_index])

    if !variable
      raise(DeclarationError, "variable #{@name} not declared") 
    end 

    case @op
    
    when "+="
      v = Addition.new(VariableAccess.new(@name), @value) 
    when "-="
      v = Subtraction.new(VariableAccess.new(@name), @value)
      
    when "/="
      v = Division.new(VariableAccess.new(@name), @value)

    when "*="
      v = Multiplication.new(VariableAccess.new(@name), @value)
    
    when "^="
      v = Power.new(VariableAccess.new(@name), @value)

    when "%="
      v = Mod.new(VariableAccess.new(@name), @value)
  
    when "="
        v = @value 
    end 

    if argument_scope
      new_value = v.evaluate(argument_scope)
    else
      new_value = v.evaluate(scope_index)
    end

    type_control(variable.type(), new_value, error_msg, error)

    assign(@name, new_value, $variables[scope_index], scope_index)
  end

end


class VariableAccess
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def evaluate(scope_index)
    if scope_index == -1
      variable = look_up(@name, $stack[-1])
    else
     variable = look_up(@name, $variables[scope_index])
    end

    if !variable
      raise(DeclarationError, "variable #{@name} not declared") 
    end 

     return variable.value()
  end

end


class If
  def initialize(branches)
    @branches = branches # is hash { condition => Block }
  end

  def evaluate(scope_index)
    @branches.each() do |condition, block|
      condition = condition.evaluate(scope_index)

      if condition
        add_parent_scope(scope_index)
    
        res = block.evaluate(scope_index)

        pop_parent_scope(scope_index)

        return res 
      end
    end
  end 

end


class ForEachDef
  def initialize(iter, container, block)
    # Map has two iters: [key, value]
    if iter.class() == Array 
      @is_map = true 
      @iter_type_key = iter[0].type()  
      @iter_type_value = iter[1].type() 
      @iter_name_key = iter[0].name()
      @iter_name_value = iter[1].name()

      if iter[0].value() != nil or iter[1].value() != nil
        warn("value of iteration variable is not allowed and will be"\
        " overwritten")
      end
    else
      @is_map = false 
      @iter_type = iter.type() 
      @iter_name = iter.name()

      if iter.value() != nil
        warn("value of iteration variable is not allowed and will be"\
        " overwritten")
      end
    end 

    @container = container 
    @block = block 
  end

  def evaluate(scope_index)
    add_parent_scope(scope_index)
    
    if @is_map 
      key_iter = VariableDeclarationDef.new(@iter_type_key, @iter_name_key)
      value_iter = VariableDeclarationDef.new(@iter_type_value, @iter_name_value)
      iter = [key_iter, value_iter]
    else
      iter = VariableDeclarationDef.new(@iter_type, @iter_name)
    end 

    eval_node = ForEachEval.new(iter, @container, @block, @is_map)

    res = eval_node.evaluate(scope_index)
   
    pop_parent_scope(scope_index)

    return res
  end

end


class ForEachEval
  def initialize(iter, container, block, is_map)
    @iter = iter 
    @container = container 
    @block = block 
    @is_map = is_map 
  end 

  def evaluate(scope_index) 
    container = setup_container(scope_index)

    iter_setup(container, scope_index, 0)
 
    if container.class() == String
      container = container.split("")
    end 

    container.each_with_index() do | element, index |

      update_iter_value(scope_index, index, container)
      
      res = @block.evaluate(scope_index)
      
      # any newly declared variables should not exist next iteration
      if @is_map
        adjust_iter_scope(scope_index, {@iter[0].name() => @iter[0],
        @iter[1].name() => @iter[1]})
      else
        adjust_iter_scope(scope_index, {@iter.name() => @iter})
      end 
      
      """ 
      checking if 'res' is a Return or break 
      (in case of keyword next, evaluation of block content has already been 
      interrupted in Block.evaluate)
      """
      if res != nil 
        if res == :break 
          break 
        elsif res.class() == Hash 
          return res 
        end 
      end
    end
  end

  private

  def setup_container(scope_index)
    container = @container.evaluate(scope_index)

    if !is_valid_container(container)
      raise(RuntimeError, "container must be of type String, List or Map")
    end

    # if @container is written freely for example: [1, 2, 3], type control is 
    # needed.
    if get_type(container) == @container.class()

      type = make_type_structure(container)

      type_control(type, container, "FOR EACH")
    end 

    return container
  end 

  def is_valid_container(container)
    return [Array, Hash, String].include?(container.class())
  end 

  def iter_setup(container, scope_index, index)
    # if type is :auto itertype is set, otherwise we check 
    # for correct type of iter. 
    if !@is_map and @iter.type() == :auto
      set_iter_type(container)

    elsif @is_map and @iter[0].type() == :auto
      set_iter_type(container)

    else
      check_iter_type(container) 
    end

    # after type control, iter is evaluated so that it exists in scope. 
    if @is_map
      @iter[0] = @iter[0].evaluate(scope_index)
      @iter[1] = @iter[1].evaluate(scope_index)

    else 
      @iter = @iter.evaluate(scope_index)
    end 

  end 

  def check_iter_type(container)
    if container.class() == String 
      type_control(@iter.type(), container, "FOR EACH")

    elsif container.class() == Hash
      key_type = @iter[0].type()
      value_type = @iter[1].type()

      type_control(key_type, container.keys()[0], "FOR EACH")
      type_control(value_type, container.values()[0], "FOR EACH")

    else
      element_type = container[0]
      type_control(@iter.type(), element_type, "FOR EACH")
    end 
   
  end

  def set_iter_type(container)
    if @is_map
      types = make_type_structure(container)
      @iter[0].type = types[0]
      @iter[1].type = types[1]

    else
      @iter.type = make_type_structure(container[0])
    end 
  end

  def update_iter_value(scope_index, index, container)
    """
    The iterationvariable(s) are set to the value(s) of the current 
    letter/element/key-value and updated in scope. 
    They are separate from the actual objects in the container so
    by changing the iter(s) you don't change anything in the container.
    """ 

    if @is_map
      new_key = container.keys()[index]
      new_value = container.values()[index]

      assign(@iter[0].name(), new_key, $variables[scope_index], scope_index)
      assign(@iter[1].name(), new_value, $variables[scope_index], scope_index)

    else
      new_iter_value = container[index]
      assign(@iter.name(), new_iter_value, $variables[scope_index], scope_index)
    end
  end

end


class ForLoopDef
  def initialize(iter, expr, block, step)
    @iter_type = iter.type 
    @iter_name = iter.name 
    @iter_value = iter.value
    @expr = expr 
    @block = block  
    @step = step 
  end 

  def evaluate(scope_index) 
    add_parent_scope(scope_index)
  
    iter = VariableDeclarationDef.new(@iter_type, @iter_name, @iter_value)

    eval_node = ForLoopEval.new(iter, @expr, @block, @step)

    res = eval_node.evaluate(scope_index)
 
    pop_parent_scope(scope_index)
 
    return res 
  end

end


class ForLoopEval
  def initialize(iter, expr, block, step)
    @iter = iter 
    @expr = expr
    @block = block
    @step = step  
  end 

  def evaluate(scope_index) 
    iter_setup(scope_index)
    
    while @expr.evaluate(scope_index)
      res = @block.evaluate(scope_index)
      
      # any newly declared variables should not exist next iteration
      adjust_iter_scope(scope_index, {@iter.name() => @iter})

      @step.evaluate(scope_index)
      
      """ 
      checking if 'res' is a Return or break 
      (in case of keyword next, evaluation of block content has already been 
      interrupted in Block.evaluate)
      """
      if res != nil 
        if res == :break 
          break
        elsif res.class() == Hash 
          return res
        end
      end 
    end

  end

  private
  
  def iter_setup(scope_index)
    @iter = @iter.evaluate(scope_index)
    type_control(Int, @iter.value(), "FOR LOOP") 
  end

end


class WhileLoop
  def initialize(expr, block)
    @expr = expr 
    @block = block 
  end 

  def evaluate(scope_index)
    add_parent_scope(scope_index)

    while @expr.evaluate(scope_index)
      res = @block.evaluate(scope_index)

      # any newly declared variables should not exist next iteration
      adjust_iter_scope(scope_index)
  
      """ 
      checking if 'res' is a Return or break 
      (in case of next evaluation of block content has already beem interrupted 
      in Block.evaluate)
      """
      if res != nil 
        if res == :break 
          break 
        elsif res.class() == Hash
          return res
        end
      end 

    end

    pop_parent_scope(scope_index)
  end

end 


class Print
  def initialize(value, newline = false)
    @value = value 
    @newline = newline
  end

  def evaluate(scope_index)
    to_be_printed = @value.evaluate(scope_index)

    """
    If 'to_be_printed' is a composite datatype that is written freely we need to
    control for correct types. 
    """
    
    if get_type(to_be_printed) == @value.class()

      type = make_type_structure(to_be_printed)

      type_control(type, to_be_printed, "PRINT")
    end 

    if @newline
      if to_be_printed.class() == Array 
        puts(to_be_printed.inspect)
      else
        puts(to_be_printed)
      end 
    else
      print(to_be_printed)
    end   
  end

end
  

class IterationInterrupt 
  attr_reader :type_of

  def initialize(type_of)
    @type_of = type_of 
  end

  def evaluate(scope_index)
    return @type_of
  end

end


class Return
  def initialize(value)
    @value = value
  end

  def evaluate(scope_index)
    return @value.evaluate(scope_index)
  end

end


class Input
  def initialize(message = nil)
    @message = message
  end

  def evaluate(scope_index)
    if @message
      puts @message.evaluate(scope_index)
    end

    @input_value = VString.new(STDIN.gets().chomp!)

    return @input_value.evaluate(scope_index)
  end

end


class BoolExpression
  def initialize(lhs, operator, rhs)
    @lhs = lhs 
    @operator = operator 
    @rhs = rhs 
  end

  def evaluate(scope_index)
    lhs = @lhs.evaluate(scope_index)
    rhs = @rhs.evaluate(scope_index)

    if lhs.class() == Lambda
      lhs = true
    elsif rhs.class() == Lambda
      rhs = true 
    end

    if lhs.class() == String 
      lhs = "'" + lhs + "'"
    end

    if rhs.class() == String
      rhs = "'" + rhs + "'" 
    end

    return eval("#{lhs} #{@operator} #{rhs}")
  end

end 


class NotBoolExpression
  def initialize(expr)
    @value = expr
  end

  def evaluate(scope_index)
    res = @value.evaluate(scope_index)

    return !eval("#{res}")
  end

end


class ComparisonExpression
  attr_reader :lhs, :rhs

  def initialize(lhs, operator, rhs)
    @lhs = lhs 
    @operator = operator 
    @rhs = rhs 
  end
  
  def evaluate(scope_index)
    rhs = @rhs.evaluate(scope_index)
    lhs = @lhs.evaluate(scope_index)

    if lhs.class() == String 
      lhs = "'" + lhs + "'"
    end

    if rhs.class() == String
      rhs = "'" + rhs + "'"
    end 
    
    #The first operators works for all datatypes
    if @operator == "==" 
        return rhs == lhs
    elsif @operator == "!="
      return rhs != lhs 

    # The rest of the operators doesn't work for:
    elsif [List, Map, Bool, Lambda].include?(get_type(lhs)) 
        raise(OperatorError, "#{get_type(lhs)} has no operator '#{@operator}'")
    elsif [List, Map, Bool, Lambda].include?(get_type(rhs)) 
      raise(OperatorError, "#{get_type(rhs)} has no operator '#{@operator}'")
    
    # Strings and Numeric can't be compared with eachother
    elsif lhs.class() == String and (rhs.class() == Integer or rhs.class() == Float)
        raise(RuntimeError, "String can't be compared with #{get_type(rhs)}")
    elsif rhs.class() == String and (lhs.class() == Integer or lhs.class() == Float)
        raise(RuntimeError, "#{get_type(lhs)} can't be compared with String")
    else
      return eval("#{lhs}#{@operator}#{rhs}")
    end
  end

end


class ArithmeticExpression
  def initialize(lhs, rhs)
    @lhs = lhs
    @rhs = rhs
  end

  def evaluate(scope_index)
    lhs =  @lhs.evaluate(scope_index)

    rhs = @rhs.evaluate(scope_index)

    invalid_type = [Bool, List, Map, Lambda]
 
    if invalid_type.include?(get_type(lhs)) 
      raise(RuntimeError, "#{get_type(lhs)} can't be"\
      " included in arithmetic expression") 
    end

    if invalid_type.include?(get_type(rhs))
      raise(RuntimeError, "#{get_type(rhs)} can't be"\
      " included in arithmetic expression") 
    end 

    return lhs, rhs 
  end

end


class Addition < ArithmeticExpression

  def initialize(lhs, rhs)
    super(lhs, rhs)
  end

  def evaluate(scope_index)
    lhs, rhs = super(scope_index)

    if lhs.class() == String
      if rhs.class() == String 
        return lhs + rhs
      else
        raise(RuntimeError, "String #{lhs} can't be concatenated with"\
        "#{get_type(rhs)} #{rhs}") 
      end
    elsif rhs.class() == String
      raise(RuntimeError, "#{get_type(lhs)} #{lhs} can't be concatenated with"\
      "String #{rhs}")
    else
      return eval("#{lhs} + #{rhs}")
    end
  end 

end


class Subtraction < ArithmeticExpression

  def initialize(lhs, rhs)
    super(lhs, rhs)
  end

  def evaluate(scope_index)
    lhs, rhs = super(scope_index)

    if lhs.class() == String or rhs.class() == String 
      raise(OperatorError, "String has no operator '-'")
    end 

    return eval("#{lhs} - #{rhs}")
  end

end


class Division < ArithmeticExpression

  def initialize(lhs, rhs)
    super(lhs, rhs)
  end

  def evaluate(scope_index)
    lhs, rhs = super(scope_index)

    if lhs.class() == String or rhs.class() == String 
      raise(OperatorError, "String has no operator '/'") 
    elsif rhs == 0
      raise(ZeroDivisionError, "can't divide #{lhs} by #{rhs}") 
    end

    return eval("#{lhs} / #{rhs}")
  end
   
end


class Multiplication < ArithmeticExpression

  def initialize(lhs, rhs)
    super(lhs, rhs)
  end

  def evaluate(scope_index)
    lhs, rhs = super(scope_index)

    if lhs.class() == String
      if rhs.class() == String 
        raise(RuntimeError, "String #{lhs} can't be multiplied with "\
        "String #{rhs}")
      else
        return lhs * rhs 
      end 
    elsif rhs.class() == String
      return rhs * lhs 
    end 

    return eval("#{lhs} * #{rhs}")
  end
   
end 


class Mod < ArithmeticExpression
  
  def initialize(lhs, rhs)
    super(lhs, rhs)
  end

  def evaluate(scope_index)
    lhs, rhs = super(scope_index)

    if lhs.class() == String or rhs.class() == String 
      raise(OperatorError, "String has no operator '%'") 
    end

    return eval("#{lhs}.remainder(#{rhs})")  

  end
   
end


class Power < ArithmeticExpression
  
  def initialize(lhs, rhs)
    super(lhs, rhs)
  end

  def evaluate(scope_index)
    lhs, rhs = super(scope_index)

    if lhs.class() == String or rhs.class() == String 
      raise(OperatorError, "String has no operator '^'")
    end

    return pow(eval("#{lhs}"), eval("#{rhs}"))

  end

  private 

  # Used becuase we want -1 ^ 2 to return a positive result, not negative as 
  # in ruby 
  def pow(base, exponent)
    res = 1
    exponent.abs().times() do 
      res *= base 
    end 

    if exponent < 0
      return 1.0 / res 
    else
      return res
    end
  end
   
end 