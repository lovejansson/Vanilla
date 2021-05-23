
require './vanilla.rb'
require 'test/unit'

class TestVanilla < Test::Unit::TestCase 
    @@parser = VanillaParser.new()
    @@parser.log(false)

    def test_int_float()

        assert_equal(4, @@parser.test_run("
        int chief(): 
            return 4
        end"))

        assert_equal(4.4444, @@parser.test_run("
        float chief():
            return 4.4444
        end"))

        assert_equal(-1000000, @@parser.test_run("
        int chief():
            return -1000000
        end"))

        assert_equal(-4.4, @@parser.test_run("
        float chief():
            return -4.4
        end"))

    end

    def test_int_float_methods()

        assert_equal(44, @@parser.test_run("
        int chief():
            return -44.absolute()
        end"))

        assert_equal(44.4, @@parser.test_run("
        float chief():
            return -44.4.absolute()
        end"))
        
        assert_equal("4", @@parser.test_run("
        string chief():
            return 4.string()
        end"))

        assert_equal("4.0", @@parser.test_run("
        string chief():
            return 4.0.string()
        end"))
        
        assert_equal(36, @@parser.test_run("
        int chief():
            return 35.5.round()
        end"))

        assert_equal(35.55, @@parser.test_run("
        float chief():
            return 35.5456.round(2)
        end"))

        assert_raise(ArgumentError) do 
            @@parser.test_run('int chief():
                return 35.5.round("2")
            end')
        end

        assert_raise_message("Numeric.round: 'digits' must be of type Int") do 
            @@parser.test_run('
            int chief():
                return 35.5.round("2")
            end')
        end

        assert_equal("Float", @@parser.test_run("
        string chief():
            return 3.3.type()
        end"))

        assert_equal(3, @@parser.test_run("
        int chief():
            return 3.0.int()
        end"))
        
        assert_equal("Int", @@parser.test_run("
        string chief():
            return 3.type()
        end"))

        assert_equal(3.0, @@parser.test_run("
        float chief():
            return 3.float()
        end")) 

    end
    
    def test__bool()
        assert_equal(true, @@parser.test_run("
        bool chief():
            return true
        end"))

        assert_equal(false, @@parser.test_run("
        bool chief():
            return false
        end"))  
    end

    def test__string()

        assert_equal("", @@parser.test_run('
        string chief():
            return ""
        end'))

        assert_equal("hejsan", @@parser.test_run('
        string chief():
            return "hejsan"
        end'))

        assert_equal("444", @@parser.test_run('
        string chief():
            return "444"
        end'))

        assert_equal("40u6-*+//()=%&¤#", @@parser.test_run('
        string chief():
            return "40u6-*+//()=%&¤#"
        end'))
    end 

    def test_string_methods()

        # type()
        assert_equal("String", @@parser.test_run('
        string chief():
            return "hehe".type()
        end'))

        #[]

        assert_equal("h", @@parser.test_run('
        string chief():
            string x = "hehe"
            return x[0]
        end'))

        assert_equal("e", @@parser.test_run('
        string chief():
            string x = "hehe"
            return x[-1]
        end'))

        assert_raise(ArgumentError) do 
            @@parser.test_run('
            string chief():
                string x = "hehe"
                return x["-1"]
            end')
        end

        assert_raise_message("String.[]: 'index' must be of type Int") do 
            @@parser.test_run('
            string chief():
                string x = "hehe"
                return x["-1"]
            end')
        end

        assert_raise(RangeError) do 
            @@parser.test_run('
            string chief():
                string x = "hehe"
                return x[4]
            end')
        end

        assert_raise_message("String.[]: index ranges from 0 to 3") do 
            @@parser.test_run('
            string chief():
                string x = "hehe"
                return x[4]
            end')
        end

        #[]=

        assert_equal("ö", @@parser.test_run('
        string chief():
            string x = ""
            x[0] = "ö"
            return x
        end'))

        assert_equal("öehe", @@parser.test_run('
        string chief():
            string x = "hehe"
            x[0] = "ö"
            return x
        end'))

        assert_equal("love", @@parser.test_run('
        string chief():
            return ""[0]= "love"
        end'))

        assert_raise(ArgumentError) do 
            @@parser.test_run('
            nothing chief():
                string x = "hehe"
                x["ö"] = "ö"
            end')
        end

        assert_raise_message("String.[]=: 'index' must be of type Int") do 
            @@parser.test_run('
            nothing chief():
                string x = "hehe"
                x["ö"] = "ö"
            end')
        end

        assert_raise(ArgumentError) do 
            @@parser.test_run('
            nothing chief():
                string x = "hehe"
                x[1] = 2 
            end')
        end

        assert_raise_message("String.[]=: 'new_value' must be String") do 
            @@parser.test_run('
            nothing chief():
                string x = "hehe"
                x[1] = 2 
            end')
        end

        #length()

        assert_equal(3, @@parser.test_run('
        int chief():
            return "444".length()
        end'))

        assert_equal(0, @@parser.test_run('
        int chief():
            return "".length()
        end'))
  
        #split()

        assert_equal(["h", "e", "h", "e"], @@parser.test_run('
        list<string> chief():
            string x = "hehe"
            list<string> y = x.split()

            return y
        end'))

        assert_equal(["1", "3", "5", "7"], @@parser.test_run('
        list<string> chief():
            string x = "12325272"
            list<string> y = x.split("2")
            return y
        end'))

        assert_raise(ArgumentError) do
            @@parser.test_run('
            nothing chief():
                string x = "12325272"
                list<string> y = x.split(2)
  
            end')
        end

        assert_raise_message("String.split: 'chr' must be of type String") do
            @@parser.test_run('
            nothing chief():
                string x = "12325272"
                list<string> y = x.split(2)
            end')
        end

        #int() and float()

        assert_equal(444, @@parser.test_run('
        int chief():
            return "444".int()
        end'))

        assert_equal(444.0, @@parser.test_run('
        float chief():
            return "444".float()
        end'))

        assert_raise(RuntimeError) do 
            @@parser.test_run('
            int chief():
                return "e".int()
            end') 
        end

        assert_raise_message("String.int: can't convert e to Int") do 
            @@parser.test_run('
            int chief():
                return "e".int()
            end') 
        end
        
        assert_raise(RuntimeError) do
            @@parser.test_run('
            float chief():
                return "e".float()
            end')  
        end

        assert_raise_message("String.float: can't convert e to Float") do
            @@parser.test_run('
            float chief():
                return "e".float()
            end')  
        end

        #upper() and lower()

        assert_equal("ABCD", @@parser.test_run('
        string chief():
            return "abcd".upper()
        end'))

        assert_equal("abcd", @@parser.test_run('
        string chief():
            return "aBcD".lower()
        end'))

        #sub()

        assert_equal("h3h3", @@parser.test_run('
        string chief():
            string x = "hehe".sub("e", "3", true)
            return x
        end'))

        assert_equal("h3he", @@parser.test_run('
        string chief():
            string x = "hehe".sub("e", "3")
            return x
        end'))

        assert_raise(ArgumentError) do 
            @@parser.test_run('
            string chief():
                string x = "hehe".sub(2, "3")
                return x
            end')
        end 

        assert_raise_message("String.sub: 'original' must be of type String") do 
            @@parser.test_run('
            string chief():
                string x = "hehe".sub(2, "3")
                return x
            end')
        end
        
        assert_raise(ArgumentError) do
            @@parser.test_run('
            string chief():
                string x = "hehe".sub("e", 2)
                return x
            end')
        end

        assert_raise_message("String.sub: 'new_chars' must be of type String") do
            @@parser.test_run('
            string chief():
                string x = "hehe".sub("e", 2)
                return x
            end')
        end

        assert_raise(ArgumentError) do 
            @@parser.test_run('string chief():
            string x = "hehe".sub("e", "3", "3")
            return x
            end')
        end

        assert_raise_message("String.sub: 'all' must be of type Bool") do 
            @@parser.test_run('
            string chief():
                string x = "hehe".sub("e", "3", "3")
                return x
            end')
        end

        assert_raise(ArgumentError) do 
            @@parser.test_run('
            string chief():
                string x = "hehe".sub("a", "3")
                return x
            end')
        end 

        assert_raise_message("String.sub: 'a' not included in 'hehe'") do 
            @@parser.test_run('
            string chief():
                string x = "hehe".sub("a", "3")
                return x
            end')
        end 

        #is_alpha()

        assert_equal(true, @@parser.test_run('
        bool chief():
            return "s".is_alpha()
        end'))

        assert_equal(true, @@parser.test_run('
        bool chief():
            return "s12".is_alpha()
        end'))

        assert_equal(false, @@parser.test_run('
        bool chief():
            return "s12".is_alpha(true)
        end'))

        assert_equal(false, @@parser.test_run('
        bool chief():
            return "4".is_alpha()
        end'))

        assert_raise(ArgumentError) do 
            @@parser.test_run('
            bool chief():
                return "!".is_alpha("hej")
            end')
        end 

        assert_raise_message("String.is_alpha: 'all' must be of type Bool") do 
            @@parser.test_run('
            bool chief():
                return "!".is_alpha("hej")
            end')
        end 

        #has_chr()

        assert_equal(true, @@parser.test_run('
        bool chief(): 
            return "hehe".has_chr("e")
        end'))

        assert_equal(false, @@parser.test_run('
        bool chief():
            return "s12".has_chr("3")
        end'))

        assert_raise(ArgumentError) do 
            @@parser.test_run('
            bool chief():
                return "s12".has_chr(3)
            end')
        end 

        assert_raise_message("String.has_chr: 'chr' must be of type String") do 
            @@parser.test_run('
            bool chief():
                return "s12".has_chr(3)
            end')
        end 
    
        # * and + for strings

        assert_equal("ööö", @@parser.test_run('
        string chief():
            string x = "ö"
            x = 3 * x 
            return x
        end'))

        assert_equal("ööö", @@parser.test_run('
        string chief():
            string x = "ö"
            x =  x * 3.0  
            return x
        end'))

        assert_equal("ööö", @@parser.test_run('
        string chief():
            string x = "ö"
            x =  x + "ö" + "ö"  
            return x
        end'))

        assert_raise(OperatorError) {@@parser.test_run('
        int chief():
            return "2" ^ 2
        end')}

        assert_raise_message("String has no operator '^'") do 
            @@parser.test_run('
            int chief():
                return "2" ^ 2
            end')
        end 

        assert_raise_message("String has no operator '-'") do 
            @@parser.test_run('
            string chief():
                return "2" - 2
            end')
        end 

        assert_raise_message("String has no operator '%'") do 
            @@parser.test_run('
            int chief():
                return 2 % "2"
            end')
        end 

        assert_raise_message("String has no operator '/'") do 
            @@parser.test_run('
            int chief():
                return 2 / "2"
            end')
        end 
    end 

    def test_lists()
        
        # empty 

        assert_equal([], @@parser.test_run("
        list<int> chief():
            list<int> x = []
        
            return x
        end"))
        
        assert_equal([], @@parser.test_run("
        list<int> chief():
            list<int> x
        
            return x
        end"))
    
        # with basic types 
    
        assert_equal([1, 2, 3, 4, 5], @@parser.test_run("
        list<int> chief():
            list<int> x = [1, 2, 3, 4, 5]
       
            return x
        end"))

        assert_equal(["love", "andreas", "linus", "hanna"], @@parser.test_run('
        list<string> chief():
            list<string> x = ["love", "andreas", "linus", "hanna"]
       
            return x
        end'))
        
        assert_equal([1.1, 2.2, 3.3], @@parser.test_run("
        list<float> chief():
            list<float> x = [1.1, 2.2, 3.3]

            return x
        end"))
        
        assert_equal([false, true, true], @@parser.test_run("
        list<bool> chief():
            list<bool> x = [false, true, true]

            return x
        end"))

        assert_equal([[1, 2, 3], [4, 5, 6]], @@parser.test_run("
        list<list<int>> chief():
            list<list<int>> x = [[1, 2, 3], [4, 5, 6]]
        
            return x
        end"))

        assert_equal([{1 => 1}, {2 => 2}], @@parser.test_run("
        list<map<int, int>> chief():
            list<map<int, int>> x = [{1: 1}, {2: 2}]
        
            return x
        end"))

        # with expressions 

        assert_equal([true, false, false, false], @@parser.test_run('
        list<bool> chief():
            list<bool> x = [2 == 2, "love".length() < 3 , not true , false and false]

            return x
        end'))

        assert_equal([4, 4, 50, 1], @@parser.test_run('
        list<int> chief():
            list<int> x = [2 + 2, "love".length() , 100 / 2 , 2 ^ 0]
        
            return x
        end'))

        assert_equal(6, @@parser.test_run("
        int chief():
            list<lambda> x = [[](int y): y * 3 end]
            lambda l = x[0]
            return l(2)
        end"))

        # with variables

        assert_equal([[1, 2], [3, 4]], @@parser.test_run('
        list<list<int>> chief():
            list<int> a = [1, 2]
            list<int> b = [3, 4]
        
            list<list<int>> x = [a, b]
        
            return x
        end'))

        assert_equal([2, 2, 2], @@parser.test_run('
        list<int> chief():
            list<int> a = [1, 2]
            list<int> b = [1, 2]
            list<list<int>> c = [a, b]

            list<int> y = [a.length(), b.length(), c.length()]
            
            return y
        end'))
    end
        
    def test_list_errors()

        assert_raise(DatatypeError) do
            @@parser.test_run('
            nothing chief():
                list<int> z = [2, 2.2]
            end') 
        end

        assert_raise_message("VARIABLE DECLARATION: is Float expected Int") do
            @@parser.test_run('
            nothing chief():
                list<int> z = [2, 2.2]
            end') 
        end

        assert_raise_message("VARIABLE DECLARATION: is String expected Int") do
            @@parser.test_run('
            nothing chief():
                list<list<list<int>>> z = [[[1, 2, 3], ["a", 5, 6]]]
            end')
        end

    end
 

    def test_list_methods()

        # []

        assert_equal(4, @@parser.test_run("
        int chief():
            list<int> x = [1, 2, 3, 4, 5]

            return x[3]
        end"))

        assert_equal(["d", "e", "f"], @@parser.test_run('
        list<string> chief():
            list<list<list<string>>> x = [[["a", "b", "c"], ["d", "e", "f"]], [["1", "2", "3"], ["4", "5", "6"]]]
            list<list<string>> y = x[0]
            list<string> w = y[-1]

            return w
        end'))

        # []=

        assert_equal([4], @@parser.test_run("
        list<int> chief():
            list<int> x = []
            x[0] = 4

            return x
        end"))
    
        assert_equal(2, @@parser.test_run("
        int chief():
            list<int> x = [1, 2, 3, 4, 5]
            x[3] = 2 
            
            return x[3] 
        end"))

        assert_equal([7, 8, 9], @@parser.test_run("
        list<int> chief():
            list<list<int>> x = [[1, 2, 3], [4, 5, 6]]
            x[-1] = [7, 8, 9] 
        
            return x[1]
        end"))

        assert_equal({2 => 2}, @@parser.test_run("
        map<int, int> chief():
            list<map<int, int>> x = [{1: 1}]
            x[-1] = {2:2}
        
            return x[0]
        end"))

        assert_equal([1, 2, 4], @@parser.test_run("
        list<int> chief():
            return [1, 2, 3][2]=4
        end"))

        # length()

        assert_equal(4, @@parser.test_run("
        int chief():
            list<int> x = [1, 2, 3, 4]
            
            return x.length()
        end"))

        assert_equal(0, @@parser.test_run("
        int chief():
            return [].length()
        end"))

        # sorted()
        
        assert_equal([0, 1, 9], @@parser.test_run("
        list<int> chief():
            list<int> x = [3 ^ 2, 5 % 2, 4 - 4]
            list<int> sorted = x.sorted()
        
            return sorted
        end"))

        assert_equal(["d", "e", "e", "f"], @@parser.test_run('
        list<string> chief():
            list<string> x = [ "e", "d", "e", "f"]
            list<string> sorted = x.sorted()

            return sorted
        end'))

        assert_equal([["a", "b", "c"], ["d", "e", "f"]], @@parser.test_run('
        list<list<string>> chief():
            list<list<string>> x = [["d", "e", "f"], ["a", "b", "c"]]
            list<list<string>> sorted = x.sorted()
        
            return sorted
        end'))

        # add_to_back()

        assert_equal([1, 2, 3, 4, 5, 8], @@parser.test_run("
        list<int> chief():
            list<int> x = [1, 2, 3, 4, 5]
            x.add_to_back(8)

            return x
        end"))

        assert_equal([[1], [2], [3], [4]], @@parser.test_run('
        list<list<int>> chief():
            list<list<int>> x = [[1],[2] ,[3]]
            x.add_to_back([4])

            return x
        end'))

        assert_equal([[1, 2, 3], [4, 5, 6]], @@parser.test_run('
        list<list<int>> chief():
            return [[1, 2, 3]].add_to_back([4, 5, 6])
        end'))
        
        # add_to_front() 

        assert_equal([8, 1, 2, 3, 4, 5], @@parser.test_run("
        list<int> chief():
            list<int> x = [1,2 ,3 ,4,5]
            x.add_to_front(8)

            return x
        end"))

        assert_equal([{2 => 2}, {1 => 1}], @@parser.test_run('
        list<map<int, int>> chief():
            list<map<int, int>> x = [{1: 1}]
            x.add_to_front({2 :2})

            return x
        end'))

        assert_equal([[4, 5, 6], [1, 2, 3]], @@parser.test_run('
        list<list<int>> chief():
            return [[1, 2, 3]].add_to_front([4, 5, 6])
        end'))

        # pop_at()

        assert_equal(3, @@parser.test_run("
        int chief():
            list<int> x = [1, 2, 3, 4, 5]

            return  x.pop_at(2)
        end"))

        assert_equal([3], @@parser.test_run("
        list<int> chief():
            list<list<int>> x = [[1], [2] ,[3]]
    
            return  x.pop_at(2)
        end"))

        # get_index()

        assert_equal(1, @@parser.test_run("
        int chief():
            list<int> x = [1, 2, 3, 4]
            
            return x.get_index(2)
        end"))
    end

    def test_list_methods_errors()

        # errors for []

        assert_raise(ArgumentError) do
            @@parser.test_run('
            nothing chief():
                list<list<int>> z = [[2, 3], [4, 5]]
                list<int> y = z["2"]
            end')
        end

        assert_raise_message("List.[]: 'index' must be of type Int") do
            @@parser.test_run('
            nothing chief():
                list<list<int>> z = [[2, 3], [4, 5]]
                list<int> y = z["2"]
            end')
        end

        assert_raise(RangeError) do
            @@parser.test_run('
            nothing chief():
                list<list<int>> z = [[2, 3], [4, 5]]
                list<int> y = z[2]
            end')
        end

        assert_raise_message("List.[]: index ranges from 0 to 1") do
            @@parser.test_run('
            nothing chief():
                list<list<int>> z = [[2, 3], [4, 5]]
                list<int> y = z[2]
            end')
        end

        # errors for []=

        assert_raise(ArgumentError) do
            @@parser.test_run('
            nothing chief():
                list<int> z = [5 % 2, 3 ^ 2]
                z[0] = [1, 1]
            end')
        end

        assert_raise_message("List.[]=: is List expected Int") do
            @@parser.test_run('
            nothing chief():
                list<int> z = [5 % 2, 3 ^ 2]
                z[0] = [1, 1]
            end')
        end

        
        assert_raise_message("List.[]=: is String expected Int") do
            @@parser.test_run('
            nothing chief():
                [1, 2, 3][0] = "love"
            end')
        end

        assert_raise_message("List.[]=: 'index' must be of type Int") do
            @@parser.test_run('
            nothing chief():
                list<list<int>> z = [[2, 3], [4, 5]]
                z[4.4] = [1, 1]
            end') 
        end

        assert_raise(RangeError) do
            @@parser.test_run('
            nothing chief():
                list<int> z = [5 % 2, 3 ^ 2]
                z[2] = [4]
            end')
        end

       assert_raise_message("List.[]=: index ranges from 0 to 1") do
            @@parser.test_run('
            nothing chief():
                list<int> z = [5 % 2, 3 ^ 2]
                z[2] = [4]
            end')
        end
        
        # errors for add_to_back()

        assert_raise(ArgumentError) do
            @@parser.test_run('
            nothing chief():
                list<string> z = ["love","linus"]
                z.add_to_back([1,1])
            end')
        end

        assert_raise_message("List.add_to_back: is List expected String") do
            @@parser.test_run('
            nothing chief():
                list<string> z = ["love","linus"]
                z.add_to_back([1,1])
            end')
        end

        #errors for add_to_front()

        assert_raise(ArgumentError) do
            @@parser.test_run('
            nothing chief():
                list<string> z = ["love","linus"]
                z.add_to_front([1,1])
            end')
        end

        assert_raise_message("List.add_to_front: is List expected String") do
            @@parser.test_run('
            nothing chief():
                list<string> z = ["love","linus"]
                z.add_to_front([1,1])
            end')
        end

        # errors for pop_at()

        assert_raise(ArgumentError) do
            @@parser.test_run('
            nothing chief():
                list<list<int>> x = [[1],[2] ,[3]]
                x.pop_at("2")
            end') 
        end

        assert_raise_message("List.pop_at: 'index' must be of type Int") do
            @@parser.test_run('
            nothing chief():
                list<list<int>> x = [[1],[2] ,[3]]
                x.pop_at("2")
            end') 
        end

        assert_raise(RuntimeError) do
            @@parser.test_run('
            nothing chief():
                list<string> z 
                z.pop_at(2)
            end') 
        end

        assert_raise_message("List.pop_at: List is empty") do
            @@parser.test_run('
            nothing chief():
                list<string> z 
                z.pop_at(2)
            end') 
        end

        assert_raise(RangeError) do
            @@parser.test_run('
            nothing chief():
                list<string> z =  ["love","linus"]
                z.pop_at(2)
            end')   
        end

        assert_raise_message("List.pop_at: index ranges from 0 to 1") do
            @@parser.test_run('
            nothing chief():
                list<string> z =  ["love","linus"]
                z.pop_at(2)
            end')   
        end

        # errors for get_index()

        assert_raise(ArgumentError) do 
            @@parser.test_run("
            int chief():
                list<int> x = [1, 2, 3, 4]
                
                return x.get_index(5)
            end")
        end

        assert_raise_message("List.get_index: element 5 not in List") do 
            @@parser.test_run("
            int chief():
                list<int> x = [1, 2, 3, 4]
                
                return x.get_index(5)
            end")
        end
    end

    def test_maps()
        
        # empty

        assert_equal({}, @@parser.test_run('
        map<string, int> chief():
            map<string, int> x = {}
      
            return x
        end'))

        assert_equal({}, @@parser.test_run('
        map<string, int> chief():
            map<string, int> x 
        
            return x
        end'))
    
        # with basic types

        assert_equal({"hanna" => 1, "linus" => 2}, @@parser.test_run('
        map<string, int> chief():
            map<string, int> x = {"hanna": 1, "linus": 2}
      
            return x
        end'))

        assert_equal({[1, 2, 3] => "first three", [4, 5, 6] => "second three"}, @@parser.test_run('
        map<list<int>, string> chief():
            map<list<int>, string> x = {[1, 2, 3]: "first three", [4, 5, 6]: "second three"}
      
            return x
        end'))

        assert_equal({{1.1=>1, 2.2=>2}=>{[{1=>1, 2=>2}, {3=>3, 4=>4}]=>true}}, 
        @@parser.test_run('
        map<map<float, int>, map<list<map<int, int>>, bool>> chief():
            map<map<float, int>, map<list<map<int, int>>, bool>> x = {{1.1: 1, 2.2: 2}: {[{1: 1, 2: 2}, {3: 3, 4: 4}]: true}}
        
            return x
        end'))

        # with expressions
        assert_equal({[1, 2, 3] => "onetwothree"}, 
        @@parser.test_run('
        map<list<int>, string> chief():
            map<list<int>, string> x = {["a".length(), 1 + 1, "abc".length()]: "one" + "two" + "three"}
      
            return x
        end'))

        assert_equal(4, @@parser.test_run("
        int chief():
            map<string, lambda> x = {'+': [](int a, int b): a + b end}
            lambda l = x['+']
            return l(2, 2)
        end"))

        # with variables

        assert_equal({[1, 2, 3] => "onetwothree"}, @@parser.test_run('
        map<list<int>, string> chief():
            int z = 1
            int w = 2 
            int y = 3
            map<list<int>, string> x = {[z, w, y]: "one" + "two" + "three"}
            
            return x
        end'))

        assert_equal({[1, 2, 3] => "onetwothree"}, @@parser.test_run('
        map<list<int>, string> chief():
        
            list<int> x = [1, 2, 3]
            list<string> y = ["onetwo", "three"]
            map<list<int>, string> z = {x: y[0] + y[1]}
            
            return z
        end'))
    end

    def test_errors_map()

        assert_raise(DatatypeError) do
            @@parser.test_run('
            map<list<int>, string> chief():
                map<list<int>, string> x = {[1, 2, 3]: "first three", 8.8: "second three"}
            
                return x
            end') 
        end

        assert_raise_message("VARIABLE DECLARATION: is Float expected List") do
            @@parser.test_run('
            map<list<int>, string> chief():
                map<list<int>, string> x = {[1, 2, 3]: "first three", 8.8: "second three"}
          
                return x
            end') 
        end

        assert_raise_message("VARIABLE DECLARATION: is Bool expected String") do
            @@parser.test_run('
            map<list<int>, string> chief():
                map<list<int>, string> x = {[1, 2, 3]: true, [4, 5, 6]: "second three"}
          
                return x
            end')
        end

        assert_raise_message("VARIABLE DECLARATION: is Bool expected String") do
            @@parser.test_run('
            map<list<int>, string> chief():
                map<list<int>, string> x = { [1, 2, 3]: true, [4, 5, 6]: false }
          
                return x
            end')
        end

    end

    def test_map_methods()

        # type()
        assert_equal("Map", @@parser.test_run('
        string chief():
            return  {}.type()
        end'))

        # length()
        assert_equal(2, @@parser.test_run('
        int chief():
            map<list<int>, string> x = {[1, 2, 3]: "first three", [4, 5, 6]: "second three"}
        
            return x.length() 
        end'))

        # []

        assert_equal("first three", @@parser.test_run('
        string chief():
            map<list<int>, string> x = {[1, 2, 3]: "first three", [4, 5, 6]: "second three"}
      
            return x[[1, 2, 3]]
        end'))

        assert_equal(["first", "three"], @@parser.test_run('
        list<string> chief():
            map<map<int, int>, list<string>> x = {{1: 1, 2: 2, 3: 3}: ["first", "three"]}
            map <int, int> key = {1: 1, 2: 2, 3: 3}
            return x[key]
        end'))

        # []= 

        assert_equal({"hej" => 1}, @@parser.test_run('
        map<string, int> chief():
            map<string, int> x = {}
            x["hej"] = 1

            return x
        end'))

        assert_equal({[1, 2, 3]=> "changed", [4, 5, 6] => "second three"}, @@parser.test_run('
        map<list<int>, string> chief():
            map<list<int>, string> x = {[1, 2, 3]: "first three", [4, 5, 6]: "second three"}
            x[[1, 2, 3]] = "changed"

            return x
        end'))

        assert_equal(["changed"], @@parser.test_run('
        list<string> chief():
            map<map<int, int>, list<string>> x = {{1: 1, 2: 2, 3: 3}: ["first", "three"]}
            map<int, int> key = {1: 1, 2: 2, 3: 3}

            x[key] = ["changed"]

            return x[key] 
        end'))

        assert_equal(["changed"], @@parser.test_run('
        list<string> chief():
            map<map<list<int>, int>, list<string>> x = {{[1]: 1, [2]: 2, [3]: 3}: ["first", "three"]}
            map <list<int>, int> key = {[1]: 1, [2]: 2, [3]: 3}

            x[key] = ["changed"]

            return x[key]
        end'))

         # get_keys()

        assert_equal([{[1] => 1, [2] => 2, [3] => 3}], @@parser.test_run('
        list<map<list<int>, int>> chief():
            map<map<list<int>, int>, list<string>> x = {{[1]: 1, [2]: 2, [3]: 3}: ["first", "three"]}
            return x.get_keys()
        end'))
        
        assert_equal([], @@parser.test_run('list<map<list<int>, int>> chief():
        map<list<map<int, int>>, list<string>> x = {}
       
        return x.get_keys()
            end') ) 
            
        
        # get_values()

        assert_equal([["first", "three"]], @@parser.test_run('
        list<list<string>> chief():
            map<map<list<int>, int>, list<string>> x = {{[1]: 1, [2]: 2, [3]: 3}: ["first", "three"]}
            return x.get_values()
        end'))
        
        assert_equal([], @@parser.test_run('
        list<map<list<int>, int>> chief():
            map<list<map<int, int>>, list<string>> x = {}
        
            return x.get_values()
        end') ) 

    end

    def test_map_methods_errors()
        
        # errors for []

        assert_raise(ArgumentError) do
            @@parser.test_run('
            string chief():
                map<list<int>, string> x = {[1, 2, 3]: "first three", [4, 5, 6]: "second three"}
        
                return x[1]
            end')
        end

        assert_raise_message("Map.[]: is Int expected List") do
            @@parser.test_run('
            string chief():
                map<list<int>, string> x = {[1, 2, 3]: "first three", [4, 5, 6]: "second three"}
        
                return x[1]
            end')
        end
        
        assert_raise_message("Map.[]: is Int expected Map") do
            @@parser.test_run('
            string chief():
                map<list<map<int, int>>, string> x = {[{1: 1}, {2: 2}]: "first three"}
          
                return x[[1, 2, 3]]
            end')
        end

        assert_raise(KeyError) do
            @@parser.test_run('
            string chief():
                map<list<int>, string> x = {[1, 2, 3]: "first three", [4, 5, 6]: "second three"}
            
                return x[[1, 2]]
            end')
        end 

        assert_raise_message("Map.[]: key [1, 2] doesn't exist") do
            @@parser.test_run('
            string chief():
                map<list<int>, string> x = {[1, 2, 3]: "first three", [4, 5, 6]: "second three"}
            
                return x[[1, 2]]
            end')
        end 

        # errors for []=

        assert_raise(ArgumentError) do
            @@parser.test_run('
            string chief():
                map<list<map<int, int>>, string> x = {[{1: 1}, {2: 2}]: "first three"}
                x[[1, 2, 3]] = "changed"

                return x[[1, 2, 3]]
            end')
        end

        assert_raise_message("Map.[]=: is Int expected Map") do
            @@parser.test_run('
            string chief():
                map<list<map<int, int>>, string> x = {[{1: 1}, {2: 2}]: "first three"}
                x[[1, 2, 3]] = "changed"

                return x[[1, 2, 3]]
            end')
        end
        
        assert_raise_message("Map.[]=: is String expected List") do
            @@parser.test_run('
            string chief():
                map<list<map<int, int>>, list<string>> x = {[{1: 1}, {2: 2}]: ["first", "three"]}
                x[[{1: 1}, {2: 2}]] = "changed"

                return x[[{1: 1}, {2: 2}]]
            end')
        end
            
   end


end 