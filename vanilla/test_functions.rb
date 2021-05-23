require './vanilla.rb'
require './nodes.rb'
require './errors.rb'
require 'test/unit'

class TestVanilla < Test::Unit::TestCase 
    @@parser = VanillaParser.new()
    @@parser.log(false)

    def test_regular_functions()

        assert_equal(4.4, @@parser.test_run("
        float chief(): 
            float x = foo()
                return x
        end

        float foo():
            return 4.4
        end"))

        # passing arguments to function

        assert_equal("LoveLoveLoveLove", @@parser.test_run('
        string chief(): 
            string x = foo(4, "Love")
            return x
        end

        string foo(int num, string word):
            string new_word = word * num 
            return new_word 
        end'))

        assert_equal(["Hanna", "Andreas", "Linus", "Love"], @@parser.test_run('
        list<string> chief(): 
            list<string> x = ["Hanna", "Andreas", "Linus"]
            x = foo(x)
            return x
        end 

        list<string> foo(list<string> names):
            names.add_to_back("Love")
            return names 
        end'))
        
        # returning lambda function
        assert_equal(12, @@parser.test_run('
        int chief():
            lambda tripler = create_x_multiplier(3)
        
            return tripler(4)
        end
    
        lambda create_x_multiplier(int n):
            return [n](int num): num * n end 
        end '))

        # lambda as parameter
        assert_equal(9, @@parser.test_run('
        int chief():
            int res = test_lambda(5, [](int y): y + 4 end)

            return res
        end

        int test_lambda(int n, lambda f):
            return f(n)  
        end'))

        # using default values

        assert_equal("linuslinus", @@parser.test_run('
        string chief(): 
            string x = foo(2, "linus")
            return x
        end

        string foo(int num, string word = "love"):
            string new_word = word * num 
            return new_word 
        end'))


        assert_equal("lovelovelovelove", @@parser.test_run('
        string chief(): 
            string x = foo(4)
            return x
        end

        string foo(int num, string word = "love"):
            string new_word = word * num 
            return new_word 
        end'))

        assert_equal("lovelove", @@parser.test_run('
        string chief(): 
            string x = foo()
            return x
        end

        string foo(int num = 2, string word = "love"):
            string new_word = word * num 
            return new_word 
        end'))

        assert_equal("EmmaKerimTångLove", @@parser.test_run('
        string chief(): 
            list<string> x = ["Hanna", "Andreas", "Linus"]
            x = foo()
            return x[0] + x[1] + x[2] + x[3]
        end 

        list<string> foo(list<string> names = ["Emma", "Kerim", "Tång"]):
            names.add_to_back("Love")
                return names 
        end'))
    end 

    def test_recursive_calls() 
        assert_equal("done", @@parser.test_run('
        string chief(): 
            return foo(6)
        end

        string foo(int num):
            if num == 1:  
                return "done"
            else: 
                return foo(num - 1)
            endif 
        end'))

        assert_equal(55, @@parser.test_run('
        int chief(): 
            return fib(10)
        end

        int fib(int num):
            if num == 1 or num == 0:  
                return num 
            else: 
                return fib(num-1) + fib(num-2)
            endif 
        end'))

        #Difference from above is that the result is stored in res before returned
        assert_equal(55, @@parser.test_run('
        int chief(): 
            return foo(10)
        end

        int foo(int num):
            if num == 1 or num == 0:  
                return num 
            else: 
                int res = foo(num - 1) + foo(num - 2)
    
                return res
            endif 
        end'))

        assert_equal(120, @@parser.test_run('int chief():
        int f = factorial(5)
            return f
        end 
    
        int factorial(int n):
            if n == 1: 
                return n
            else: 
                return n * factorial(n-1)  
            endif
        end'))

        assert_equal(24, @@parser.test_run('
        int chief():
            int res = recursion_while(5)
            return res
        end 
                
        int recursion_while(int n):
            int a = n 
            while a < 24:
                a = recursion_while(n + 1)
            endwhile
            return a
        end'))

        assert_equal(0, @@parser.test_run('
        int chief():    
            int res = recursion_while(6)
            return res
        end 

        int recursion_while(int n):
            int a = n 
            if a > 0: 
                while a > 0:
                a = recursion_while(n - 1)
                endwhile
            else:  

                return a
            endif
            return a      
        end'))
    end 

    def test_lambdas()
        assert_equal(4, @@parser.test_run('
        int chief():
            lambda x = [](int y): y + 2 end
            return x(2)
        end'))

        assert_equal(3, @@parser.test_run('
        int chief():
            lambda x = [](list<int> l): l.length() end
            list<int> l = [1, 2, 3]
            return x(l)
        end'))

        # default value for parameter 
        assert_equal(4, @@parser.test_run('
        int chief():
            lambda x = [](int y = 2): y + 2 end
            return x()
        end'))

        # with one capture 
        assert_equal(12, @@parser.test_run('
        int chief():
            lambda tripler = create_x_multiplier(3)
        
            return tripler(4)
        end
    
        lambda create_x_multiplier(int n):
            return [n](int num): num * n end 
        end '))

        # multiple variables in captures
        assert_equal(64, @@parser.test_run('
        int chief():
            lambda multiplier = create_x_multiplier(2)
        
            return multiplier(4)
        end
    
        lambda create_x_multiplier(int n):
            int z = 2
            int w = 4

            return [n, z, w](int num): num * n * z * w end 
        end '))

        # lambda as parameter in lambda. 
        assert_equal(9, @@parser.test_run('
        int chief():
    
            lambda l = [](int n, lambda f): f(n) end
            int res = l(5, [](int y): y + 4 end)
    
            return res
        end'))

        # returning lambda in lambda 
        assert_equal(4, @@parser.test_run('
        int chief():
            lambda l = [](int n): [n](int num): num * n end end 
            
            lambda doubler = l(2)
    
            return doubler(2)
        
        end'))
    end

    def test_errors()
        #Wrong number of arguments
        assert_raise_message("function foo: wrong number of arguments 0 given, expected 1 to 2") do
            @@parser.test_run('
            string chief(): 
                string x = foo()
                return x
            end

            string foo(int num, string word = "love"):
                string new_word = word * num 
                return new_word 
            end')

        end 

        #Wrong type of arguments
        assert_raise_message("foo: is String expected Int") do
            @@parser.test_run('
            string chief(): 
                string x = foo("kristoff")
                return x
            end

            string foo(int num2 = 2, string word2 = "love"):
                string new_word = word2 * num2 
                return new_word 
            end')

        end

        assert_raise_message("foo: is Int expected String") do
            @@parser.test_run('
            string chief(): 
                list<int> x = [1, 2, 3]
                x = foo(x)
                return x[0] + x[1] + x[2] + x[3]
            end 

            list<string> foo(list<string> names = ["Emma", "Kerim", "Tång"]):
                names.add_to_back("Love")
                return names 
            end')

        end 

        #########################
        ## Return type errors ###
        #########################

        assert_raise_message("foo: is Int expected String") do
            @@parser.test_run('
            string chief(): 
                string x = foo(4) 
                return x
            end 

            string foo(int num = 2, string word = "love"):
                return 2
            end')

        end

        assert_raise_message("foo: is Int expected String") do
            @@parser.test_run('
            string chief(): 
                list<string> x 
                x = foo()
                return x[0] + x[1] + x[2] + x[3]
            end 

            list<string> foo(list<string> names = ["Emma", "Kerim", "Tång"]):
                list<int> l = [1, 2, 3]
                names.add_to_back("Love")
                return l
            end')

        end
        
        assert_raise_message("foo: is Int expected String") do
            @@parser.test_run('
            string chief(): 
                string x = foo(2)
                return x
            end

            string foo(int num = 2, string word = "love"):
                if num == 2:  
                    return num 
                endif 
            end')

        end

        assert_raise_message("foo: is Int expected String") do
            @@parser.test_run('
            string chief(): 
                list<string> x 
                x = foo()
                return x[0] + x[1] + x[2] + x[3]
            end 

            list<string> foo(list<string> names = ["Emma", "Kerim", "Tång"]):
                if names.length() == 3:   
                    list<int> l = [1, 2, 3]
                    return l
                endif     
            end')

        end

        #############################
        ## Return statement errors ##
        #############################

        assert_raise_message("return statement found in nothing function: 'chief'") do
            @@parser.test_run('
            nothing chief():
                int f = 4
                return f

            end')

        end

        assert_raise_message("End of non-nothing function 'recursion_while': Return Statement not reached") do 
            @@parser.test_run('
            int chief():
                int res = recursion_while(6)
                return res
            end 

            int recursion_while(int n):
                int a = n 
                if a > 0: 
                    while a > 0:
                    a = recursion_while(n - 1)
          
                    endwhile
                else: 

                return a
                endif      
            end')
        end

        ####################
        ## chief - errors ##
        ####################

        assert_raise_message("function 'chief' required but not found") do
            @@parser.test_run('
            nothing foo():
                int f = 4
                return f

            end')
        end

        assert_raise_message("only one function named 'chief' is allowed") do
            @@parser.test_run('
            nothing chief():
                int f = 4
                return f

            end
            
            nothing chief():
                int f = 4
                return f

            end')
        end

    end
   
    def test_methodcall_errors()
        assert_raise_kind_of(NoMethodError) { @@parser.test_run('
        int chief(): 
            return "4".absolute()
        end') }
    end

end 

