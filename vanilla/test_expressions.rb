
require './vanilla.rb'
require 'test/unit'

class TestVanilla < Test::Unit::TestCase 
    @@parser = VanillaParser.new()
    @@parser.log(false)
                               
    ##############################
    ### ARITHMETIC EXPRESSIONS ###
    ##############################

    def test_addition()

        assert_equal(104.4, @@parser.test_run("
        float chief():
            return 4.4+100
        end"))

        assert_equal(-4.2, @@parser.test_run("
        float chief():
            return -2.2+-2
        end"))

        assert_equal(0, @@parser.test_run("
        int chief():
            return -4+4+-4+4
        end"))
    end 
    
    def test_subtraction()

        assert_equal(104.5, @@parser.test_run("
        float chief():
            return 105.5 - 1
        end"))

        assert_equal(-4, @@parser.test_run("
        int chief():
            return -4 - (4 - 4)
        end"))

        assert_equal(0, @@parser.test_run("
        int chief():
            return 1000 - 500 - 500
        end"))    
    end 

    def test_multiplication()
   
        assert_equal(4.4, @@parser.test_run("
        float chief(): 
            return 2.2*2
        end"))

        assert_equal(-40, @@parser.test_run("
        int chief(): 
            return -4*10
        end"))

        assert_equal(4, @@parser.test_run("
        int chief():
            return -2*-2
        end"))

        assert_equal(8, @@parser.test_run("
        int chief():
            return 2*2*2
        end"))
    end

    def test_division()

        assert_equal(4.4 ,@@parser.test_run("
        float chief():
            return 8.8/2
        end"))

        assert_equal(-4,@@parser.test_run("
        int chief():
            return -20/5
        end"))

        assert_equal(4,@@parser.test_run("
        int chief():
            return -20/-5
        end"))

        assert_equal(4, @@parser.test_run("
        int chief():
            return 16/2/2
        end"))
    end

    def test_mod()

        assert_equal(4, @@parser.test_run("
        int chief():
            return 104 % 25
        end"))

        assert_equal(0.4, @@parser.test_run("
        float chief():
            return 4.4 % 2
        end").round(1))

        assert_equal(4, @@parser.test_run("
        int chief():
            return 14 % -10
        end"))

        assert_equal(-4, @@parser.test_run("
        int chief():
            return -14 % -10
        end"))

        assert_equal(-4, @@parser.test_run("
        int chief():
            return -14 % 10
        end"))

        assert_equal(0, @@parser.test_run("
        int chief():
            return 4 % 3 % 1
        end"))
    end 

    def test_power()
        assert_equal(128, @@parser.test_run("
        int chief(): 
            return 2^7
        end"))

        assert_equal(10000, @@parser.test_run("
        int chief():
            return 10^2^2
        end"))

        assert_equal(1, @@parser.test_run("
        int chief(): 
            return -1^4
        end"))

        assert_equal(-1, @@parser.test_run("
        int chief(): 
            return -1^3
        end"))

        assert_equal(0.001, @@parser.test_run("
        float chief():
            return 10^-3
        end"))

        assert_equal(1, @@parser.test_run("
        int chief():
            return 100^0
        end"))

        assert_equal(0, @@parser.test_run("
        int chief():
            return 0^5
        end"))      
    end 

    def test_compounded_expressions()

        # + with other operators

        assert_equal(4, @@parser.test_run("
        int chief():
            return 7 + 1 - 4
        end"))

        assert_equal(4, @@parser.test_run("
        int chief():
            return 2 + 1 * 2
        end"))

        assert_equal(6, @@parser.test_run("
        int chief():
            return (2 + 1) * 2
        end"))

        assert_equal(104, @@parser.test_run("
        int chief():
            return 100 + 8 / 2
        end"))

        assert_equal(54, @@parser.test_run("
        int chief():
            return (100 + 8) / 2
        end"))

        assert_equal(2, @@parser.test_run("
        int chief():
            return 2 + 4 % 2
        end"))

        assert_equal(0, @@parser.test_run("
        int chief():
            return 4 % (2 + 2)
        end"))

        assert_equal(6, @@parser.test_run("
        int chief():
            return 2 + 2^2
        end"))

        assert_equal(16, @@parser.test_run("
        int chief():
            return (2 + 2)^2
        end"))

        assert_equal(16, @@parser.test_run("
        int chief():
            return 2^(2+2)
        end"))

        # - with other operators (except +)

        assert_equal(-900, @@parser.test_run("
        int chief():
            return 100 - 10 * 100
        end"))

        assert_equal(9000, @@parser.test_run("
        int chief():
            return (100 - 10) * 100
        end"))

        assert_equal(10, @@parser.test_run("
        int chief():
            return 100 / 5 - 10
        end"))

        assert_equal(-20, @@parser.test_run("
        int chief():
            return 100 / (5 - 10)
        end"))

        assert_equal(8, @@parser.test_run("
        int chief():
            return 10 - 5 % 3
        end"))

        assert_equal(2, @@parser.test_run("int chief():
        return (10 - 5) % 3
        end"))

        assert_equal(96, @@parser.test_run("
        int chief():
            return 10^2 - 4
        end"))

        assert_equal(0.01, @@parser.test_run("
        float chief():
            return 10^(2 - 4)
        end"))
        
        # * with other operators (except +, -)

        assert_equal(500, @@parser.test_run("
        int chief():
            return 100 * 10 / 2
        end"))

        assert_equal(2, @@parser.test_run("
        int chief():
            return 5 % 2 * 2
        end"))

        assert_equal(1, @@parser.test_run("
        int chief():
            return 5 % (2 * 2)
        end"))

        assert_equal(100, @@parser.test_run("
        int chief():
            return 10^(2*1)
        end"))

        assert_equal(1000, @@parser.test_run("
        int chief():
            return 10 * 10^2
        end"))

        assert_equal(10000, @@parser.test_run("
        int chief():
            return (10 * 10)^2
        end"))

        # / with %, ^

        assert_equal(2, @@parser.test_run("
        int chief():
            return 100 / 2 % 3
        end"))

        assert_equal(25, @@parser.test_run("
        int chief():
            return 100 / 2^2
        end"))

        assert_equal(2500, @@parser.test_run("
        int chief():
            return (100 / 2)^2
        end"))
        
        assert_equal(1000, @@parser.test_run("
        int chief():
            return 10^(18/6)
        end"))

        # % and ^

        assert_equal(32, @@parser.test_run("
        int chief():
            return 2^(105 % 20)
        end "))

        assert_equal(25, @@parser.test_run("
        int chief():
            return (105 % 20)^2
        end "))
    end 

    ########################
    ### BOOL EXPRESSIONS ###
    ########################

    def test_bool_expr()

        # and

        assert_equal(true, @@parser.test_run("
        bool chief():
            return true and true
        end"))

        assert_equal(false, @@parser.test_run("
        bool chief():
            return true and false
        end"))

        assert_equal(4, @@parser.test_run("
        int chief():
            return true and 4
        end"))

        # or

        assert_equal(true, @@parser.test_run("
        bool chief():
            return true or false
        end"))

        assert_equal(false, @@parser.test_run("
        bool chief():
            return false or false
        end"))

        assert_equal(4, @@parser.test_run("
        int chief():
            return 4 or true 
        end"))

        # combinations of 'and' and 'or'

        assert_equal(true, @@parser.test_run("
        bool chief():
            return true or true and false
        end"))

        assert_equal(false, @@parser.test_run("
        bool chief():
            return false or true and false
        end"))

        assert_equal(true, @@parser.test_run("
        bool chief():
            return false and true or true and true
        end"))

        assert_equal(false, @@parser.test_run("
        bool chief():
            return false and true or true and false
        end"))

        assert_equal(true, @@parser.test_run("
        bool chief():
            return true and true and false or true
        end"))

        assert_equal(false, @@parser.test_run("
        bool chief():
            return true and true and false or false
        end"))

        # including 'not' and '!'

        assert_equal(false, @@parser.test_run("
        bool chief():
            return !true and true
        end"))

        assert_equal(true, @@parser.test_run("
        bool chief():
            return !(true and false)
        end"))

        assert_equal(true, @@parser.test_run("
        bool chief():
            return not true and false or true
        end"))

        assert_equal(false, @@parser.test_run("
        bool chief():
            return !true and false or false
        end"))

        assert_equal(true, @@parser.test_run("
        bool chief():
            return not false and true or false
        end"))
    end

    #############################
    ### COMPARING EXPRESSIONS ###
    #############################

    def test_comparisons()

        # < and <=

        assert_equal(true, @@parser.test_run("
        bool chief():
            return 1 < 4
        end"))

        assert_equal(false, @@parser.test_run("
        bool chief():
            return 1 < -4.4
        end"))

        assert_equal(true, @@parser.test_run("
        bool chief():
            return 'abc' < 'xyz'
        end"))

        assert_equal(true, @@parser.test_run("
        bool chief():
            return 1 <= 4
        end"))

        assert_equal(true, @@parser.test_run("
        bool chief():
            return 'a' <= 'a'
        end"))

        # > and >=

        assert_equal(true, @@parser.test_run("
        bool chief():
            return 10 > 4
        end"))

        assert_equal(false, @@parser.test_run("
        bool chief():
            return -10 > 4.4
        end"))

        assert_equal(true, @@parser.test_run("
        bool chief():
            return 'xyz' > 'abc'
        end"))

        assert_equal(true, @@parser.test_run("
        bool chief():
            return 10 >= 4
        end"))

        assert_equal(true, @@parser.test_run("
        bool chief():
            return 'x' >= 'x'
        end"))

        # ==

        assert_equal(false, @@parser.test_run("
        bool chief():
            return 1 == 4 
        end"))

        assert_equal(true, @@parser.test_run("
        bool chief():
            return 'love' == 'love'
        end"))

        assert_equal(true, @@parser.test_run('
        bool chief():
            list<list<int>> l = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
            list<list<int>> l2 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

            return l == l2 
        end'))

        assert_equal(false, @@parser.test_run('
        bool chief():
            return {"hanna": 1, "linus": 2} == {"hanna": 1, "andreas": 2}
        end'))

        # !=

        assert_equal(true, @@parser.test_run("
        bool chief():
            return 1 != 4
        end"))

        assert_equal(true, @@parser.test_run("
        bool chief():
            return 'love' != 'Love'
        end"))

        assert_equal(false, @@parser.test_run('
        bool chief():
            list<list<int>> l = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
            list<list<int>> l2 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

            return l != l2 
        end'))

        assert_equal(true, @@parser.test_run('
        bool chief():
            return {"hanna": 1, "linus": 2} != {"hanna": 1, "andreas": 2}
        end'))
      
        # with arithmetic expression 
        assert_equal(true, @@parser.test_run("
        bool chief():
            return -1 < 5 + 5
        end"))

        assert_equal(false, @@parser.test_run("
        bool chief():
            return 2^2 > 100
        end"))
    end

    # Few tests to check that the parser parses mixes of boolean expressions and
    # comparing expressions correctly. 
    def test_bool_comparison() 
        assert_equal(true, @@parser.test_run("
        bool chief():
            return 15 < 10^2 and 20 != 15*3
        end"))

        assert_equal(false, @@parser.test_run("
        bool chief():
            return 100 < 10*2 or 15 + 25 < 30
        end"))
    end

    def test_arithmetic_errors()

        assert_raise(RuntimeError) do
            @@parser.test_run('nothing chief():
            list<int> l = [1, 2, 3]
            string s = "Love"

            printn(l + s)
            end')
        end

        assert_raise_message("Lambda can't be included in arithmetic expression") do
            @@parser.test_run('nothing chief():
            lambda l = [](): end 
            string s = "Love"

            printn(l + s)
            end')
        end

        assert_raise(RuntimeError) do
            @@parser.test_run('nothing chief():
            bool x = true
            string s = "Love"

            printn(s + x)
            end')
        end

        assert_raise_message("Bool can't be included in arithmetic expression") do
            @@parser.test_run('nothing chief():
            bool x = true
            string s = "Love"

            printn(s + x)
            end')
        end

        assert_raise(ZeroDivisionError) do
            @@parser.test_run('nothing chief():
            printn(2/0)
            end')
        end

        assert_raise_message("can't divide 2 by 0") do
            @@parser.test_run('nothing chief():
            printn(2/0)
            end')
        end
    end

    
    def test_comparison_errors()

        assert_raise(OperatorError) do
            @@parser.test_run('bool chief():
            list<int> l = [1, 2, 3]
            string s = "Love"

            return l > s
            end')
        end

        assert_raise_message("List has no operator '>'") do
            @@parser.test_run('bool chief():
            list<int> l = [1, 2, 3]
            string s = "Love"

            return l > s
            end')
        end

        assert_raise(RuntimeError) do
            @@parser.test_run('bool chief():
            int num = 4
            string s = "Love"

            return s > 4
            end')
        end

        assert_raise_message("String can't be compared with Int") do
            @@parser.test_run('bool chief():
            int num = 4
            string s = "Love"

            return s > 4
            end')
        end

        assert_raise(RuntimeError) do
            @@parser.test_run('bool chief():
            int num = 4
            string s = "Love"

            return 4 > s
            end')
        end

        assert_raise_message("Int can't be compared with String") do
            @@parser.test_run('bool chief():
            int num = 4
            string s = "Love"

            return 4 > s
            end')
        end
    end

end  