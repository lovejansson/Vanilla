
# Contains function definitions on format { name => object }
$functions = Hash.new()

# Contains variables on format { name => value }, one hash per function. 
$variables = []

# Used for recursion, stores scopes ({}) from function calls.
$stack = []


def look_up(name, scope)
  """
  Searches after variable in scope. 

  Args:
      name: String, name of variable.
      scope: Hash on format { name => value }, scope to search in. 
  Returns: 
      * VariableDeclarationEval, value of variable 
      or 
      * false, if not found
  """

    if scope.has_key?(name)
      return scope[name]
    elsif scope.has_key?(:parent)
      look_up(name, scope[:parent])
    else 
      return false 
    end 
  
end


def assign(name, value, scope, scope_index, path: "$variables[scope_index]")
  """
  Changes value of variable in scope. 

  Args:
      name: String, name of variable
      value: new value of same type as variable
      scope: Hash with mappings of name and value ({ name => value })
      scope_index: integer, represents wich scope(index) in $variables
      path: String, path needed to access correct scope level in $variables
  Returns: 
      * no intended return..
  """
  
    if scope.has_key?(name) == true
    
        path = path + "['#{name}']"

        eval(path).value = value 
    else 
        new_path = path + "[:parent]"
        assign(name, value, scope[:parent], scope_index, path: new_path)
    end 

end
  
  
def add_parent_scope(scope_index)
    $variables[scope_index] = {:parent => $variables[scope_index]}
end     


def pop_parent_scope(scope_index)
    $variables[scope_index] =  $variables[scope_index][:parent]
end


def adjust_iter_scope(scope_index, iters = {})
    $variables[scope_index]  = {:parent => $variables[scope_index][:parent]}

    iters.each() do | name, value | 
      $variables[scope_index][name] = value 
    end 
end 

