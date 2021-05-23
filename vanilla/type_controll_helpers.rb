# get_type and has_type are used all over the place and are self explanatory

def get_type(object)
    table = {Integer => Int, Float => Float, String => String,
    FalseClass => Bool, TrueClass => Bool, Array => List, Hash => Map, 
    NilClass => :nothing}

    if table.include?(object.class()) 
        return table[object.class()]
    else
        return object.class()
    end 
end

def has_type(object, type) 
    return get_type(object) == type 
end

# used in Map.evaluate and List.evaluate so that the function doesn't try to make
# a ruby hash/array out of a ruby hash/array
def is_ruby(value)
    ruby_types = [Array, Hash, TrueClass, FalseClass, Integer, Float, String]
    return ruby_types.include?(value.class())
end 

# used in Lambda.evaluate to make the list of captures for later calls and
# in MethodCall.evaluate to be able to call methods. 
def vanilla_object(object)
    type = get_type(object)

    # I wanted to call the datatypes String and Float, but VString and VFloat
    # is needed to be able to make a vanilla object. 
    if type == String
        type = VString
    elsif type == Float
        type = VFloat
    end

    vanilla_object = type.new(object)

    return vanilla_object
  end 


def make_type_structure(object)
    """
    Creates a datastructure that describes the type(s) of the object. 
    This is used to controll for correct types of all values (or keys and values) 
    when type controll is neccessary (except for in VariableDeclaration where a 
    type structure is provided from the parser.). 

    If the object is a composite data structure, first element or first 
    key and value pair will determine the type structure(s). 

    Args:
        object: is a ruby datatype: Integer, String, Float, Array, Hash or 
        TrueClass/FalseClass
    Returns: 
        * if the object is a primitive datatype: vanilla class name

        or

        * if the object is an Array: nested Hash: {:subtype => {:subtype => Int}} 
        (list<list<int>>)

        or

        * if the object is a hash: Array with type structures of key and value 
        e.g. [{:subtype => VFloat}, Int] (map<list<float>, int>)

        or

        * a mix of the above
    """
   
    if object.class() == Array 
        if object[0].class() == Array
            return {:subtype => make_type_structure(object[0])}

        elsif object[0].class() == Hash 
            key = object[0].keys()[0]

            value = object[0][key]

            map_structure = [make_type_structure(key),  make_type_structure(value)]  

            return {:subtype => map_structure}
        else
            return {:subtype => get_type(object[0])}
        end

    elsif object.class() == Hash
        key = object.keys()[0]
      
        value = object[key]
    
        return [make_type_structure(key), make_type_structure(value)]  

    else
        return get_type(object)
    end    
end


def assert_types_map(type, map, msg, error = DatatypeError)
    """
    Going through a map to controll for correct types of key and value. 

    Args:
        type: type structure of key an value e.g. [{:subtype => VFloat}, Int] 
        (map<list<float>, int>)
        map: Hash 
        msg: String, part of message to raise in case of error.
        error: DatatypeError or ArgumentError
    Returns: 
        * no intended return values..
    """

    # determining correct type of key
    if type[0].class() == Hash
        correct_key_type = List 
    elsif type[0].class() == Array 
        correct_key_type = Map 
    else
        correct_key_type = type[0]
    end

    # determining correct type of value
    if type[1].class() == Hash
        correct_value_type = List 
    elsif type[1].class() == Array
        correct_value_type = Map 
    else
        correct_value_type = type[1]
    end

    # going through each value and checking type vs. correct type. 
    map.each_value() do | value | 
        if !has_type(value, correct_value_type)
            raise(error, "#{msg}: is #{get_type(value)}"\
            " expected #{correct_value_type}") 
        end
    end
    
    # checking for correct type of element/key and value
    if correct_value_type == List or correct_value_type == Map 
        map.each_value() do | value | 
            if correct_value_type == List 
                assert_type_list(type[1], value, msg, error)
            else
                assert_types_map(type[1], value, msg, error)
            end

        end 
    end

    # going through each key and checking type vs. correct type. 
    map.each_key() do | key | 
        if !has_type(key, correct_key_type)
            raise(error, "#{msg}: is #{get_type(key)}"\
            " expected #{correct_key_type}") 
        end
    end

    # checking for correct type of element/key and value
    if correct_key_type == List or correct_key_type == Map 
        map.each_key() do | key | 
            if correct_key_type == List 
                assert_type_list(type[0], key, msg, error)
            else
                assert_types_map(type[0], key, msg, error)
            end 
        end 
    end
end 


def assert_type_list(type, list, msg, error = DatatypeError)
    """
    Going through an array to controll for correct types of elements. 

    Args:
        type: e.g. {:subtype => {:subtype => Int}} (list<list<int>>)
        list: Array
        msg: String, part of message to raise in case of error. 
        error: DatatypeError or ArgumentError
    Returns: 
        * no intended return values...
    """
 
    # determining the correct type. 
    if type[:subtype].class() == Hash
        correct_type = List
    elsif type[:subtype].class() == Array
        correct_type = Map 
    else
        correct_type = type[:subtype]
    end

    # going through each element and checking type vs. correct type. 
    list.each() do | element |
        if !has_type(element, correct_type)
            raise(error, "#{msg}: is #{get_type(element)}"\
            " expected #{correct_type}") 
        end
    end
    
    # checking for correct type of element/key and value
    if correct_type == List or correct_type == Map 
        list.each() do | element |
            if correct_type == List 
                assert_type_list(type[:subtype], element, msg, error)
            else
                assert_types_map(type[:subtype] , element, msg, error)
            end 
            
        end 
    end
end


def type_control(type, value, msg, error = DatatypeError)

    """
    Main type control function!

    Args:
        type: a datastructure as described in function make_type_structure.
        value: Integer, String, Float, Array, Hash or TrueClass or FalseClass 
        or Lambda
        msg: String, part of message to raise in case of error.
        error: DatatypeError or ArgumentError
    Returns: 
        * no intended return values..
    """

    # the datastructure describing types in List is a hash:
    # {:subtype => {:subtype => Int}} (list<list<int>>)
    if type.class() == Hash 
        if !has_type(value, List)
            raise(error, "#{msg}: is #{get_type(value)}"\
            " expected List") 
        end

        assert_type_list(type, value, msg, error)

    # the datastructure describing types in Map is an array:
    # [{:subtype => VFloat}, Int] (map<list<float>, int>)
    elsif type.class() == Array 
        if !has_type(value, Map)
            raise(error, "#{msg}: is #{get_type(value)}"\
            " expected Map") 
        end

        assert_types_map(type, value, msg, error)
    
    elsif value == nil and type != :nothing
        raise(ReturnError, "End of non-nothing function '#{msg}':"\
        " Return Statement not reached")

    elsif value != nil and type == :nothing
        raise(ReturnError, "return statement found in nothing function: '#{msg}'")

    # if type is only a class name of one of the primitive types, we can compare
    # the type of the value against the correct type directly. 
    else
        if !has_type(value, type)
            raise(error, "#{msg}: is #{get_type(value)}"\
            " expected #{type}") 
        end
    end
end 


