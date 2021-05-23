
require './vanilla.rb'
require 'test/unit'

class TestVanilla < Test::Unit::TestCase 
    @@parser = VanillaParser.new()
    @@parser.log(false)
     """ These tests are for assignments, input statements, if statements, 
     and different iteration statements, 
    """ 
    
    def test_assignment()
        assert_equal(4, @@parser.test_run("
        int chief():
            int z 
            z = 4

            return z
        end"))

        assert_equal(4.4, @@parser.test_run("
        float chief():
            float z
            z = 4.4

            return z
        end"))

        assert_equal('love', @@parser.test_run("
        string chief():
            string z
            z = 'love'

            return z
        end"))

        assert_equal([1, 2, 3], @@parser.test_run("
        list<int> chief():
            list<int> z
            z = [1, 2, 3]

            return z
        end"))

        assert_equal({1 => 1}, @@parser.test_run("
        map<int, int> chief():
            map<int, int> z
            z = {1: 1}

            return z
        end"))    
    end

    def test_errors_assignment()
        assert_raise(DatatypeError) do 
            @@parser.test_run("
            map<int, int> chief():
                map<int, int> z
                z = [1, 2]

                return z
            end")
        end
        
        assert_raise_message("VARIABLE ASSIGNMENT: is List expected Map") do 
            @@parser.test_run("
            map<int, int> chief():
                map<int, int> z
                z = [1, 2]

                return z
            end")
        end

        assert_raise(DeclarationError) do 
            @@parser.test_run("
            map<int, int> chief():
                map<int, int> z
                x = [1, 2]

                return z
            end")
        end
        
        assert_raise_message("variable x not declared") do 
            @@parser.test_run("
            map<int, int> chief():
                map<int, int> z
                x = [1, 2]

                return z
            end")
        end    
    end

    def test_errors_declaration()
        assert_raise(DatatypeError) do 
            @@parser.test_run("
            map<int, int> chief():
                map<int, int> z = [1, 2]

                return z
            end")
        end
        
        assert_raise_message("VARIABLE DECLARATION: is List expected Map") do 
            @@parser.test_run("
            map<int, int> chief():
                map<int, int> z = [1, 2]

                return z
            end")
        end

        assert_raise(DeclarationError) do 
            @@parser.test_run("
            map<int, int> chief():
                map<int, int> z
                map<int, int> z
        
                return z
            end")
        end
        
        assert_raise_message("variable z already declared") do 
            @@parser.test_run("
            map<int, int> chief():
                map<int, int> z
                map<int, int> z

                return z
            end")
        end    
    end 
        
    def test_short_hand_assignment()
        assert_equal(102, @@parser.test_run("
        int chief():
            int z = 100 
            z += 2
            return z
        end"))

        assert_equal(50, @@parser.test_run("
        int chief():
            int z = 100 
            z -= 50 
            return z
        end"))
        
        assert_equal(33.33, @@parser.test_run("
        float chief():
            float z = 100.0
            z /= 3
            return z.round(2)
        end"))

        assert_equal(16, @@parser.test_run("
        int chief():
            int z = 4
            z *= 4
            return z
        end"))

        assert_equal(128, @@parser.test_run("
        int chief():
            int z = 2
            z ^= 7
            return z
        end"))

        assert_equal(1, @@parser.test_run("
        int chief():
            int z = 5 
            z %= 2
            return z
        end"))
    end
  
    def test_input()

        assert_equal("Love", @@parser.test_run("
        string chief():
            string my_name = input('TYPE IN THE NAME Love: ')
            return my_name
        end"))

        assert_equal(4, @@parser.test_run("
        int chief():
            int number = input('TYPE IN THE NUMBER 4: ').int() 
            return number
        end"))

        assert_equal(150, @@parser.test_run("
        int chief():
            int number = input('TYPE IN THE NUMBER 100: ').int() + 100 / 2 
            return number
        end"))

        assert_equal("Emma Gustafsson", @@parser.test_run('
        string chief():
            string name = input("TYPE IN Emma: ") + " " + "Gustafsson"  
            return name
        end'))

        assert_equal(4444.0, @@parser.test_run('
        float chief():
            float number = input("TYPE IN 44.44: ").float() * 100
            return number 
        end '))

        puts ("Testing input in for loop...")

        assert_equal(8, @@parser.test_run('
        int chief():
            int res 
            for int i, i < 2, i += 1:
                printn("Type in the number 4: ")
                res = res + input().int() 
            endfor 
            return res 
        end '))

    end

    def test_if_statements()

        assert_equal(1, @@parser.test_run("
        int chief():
            if false:
            elseif false:
            elseif true:
            else: 
            endif 
    
            return 1
        end"))

        assert_equal(2, @@parser.test_run("
        int chief():
            if true: 
                return 2
            endif

            return 1
        end"))

        assert_equal(1, @@parser.test_run("
        int chief():
            if false: 
                return 2
            endif

            return 1 
        end"))
                              
        assert_equal(5, @@parser.test_run("
        int chief():
            int x = 0

            if x > 1:
                x = 1
            elseif x == 0:
                return 5
            elseif x == 100:
                return x
            endif

            return 1
        end"))

        assert_equal(4, @@parser.test_run("
        int chief():
            int z = 0
            list<list<int>> x = [[1, 2, 3], [4, 5, 6, 7], [7, 6, 4, 2, 3]]

            if x[2].length() < x[0].length():
                z = 1
            elseif x[1].length() == 4 :
                z = z + 4
            else:
                return x
            endif

            return z
        end"))

        assert_equal(1 , @@parser.test_run("
        int chief():
            list<list<int>> x = [[1, 2, 3], [4, 5, 6, 7], [7, 6, 4, 2, 3]]
            int z = 100

            if x[2].length() > x[0].length(): 
                if x[2][0] == 1:
                    z = 3
                elseif x[2][0] == 7: 
                    z = 1
                endif 
            
            elseif x[1].length() == 4 :
                z = z + 4
            else: 
                return x
            endif

            return z
        end"))
    end 

    ##########################
    ## ITERATION STATEMENTS ##
    ##########################

    def test_for_each_map()

        # with explicit types of iterationvariables

        assert_equal(nil, @@parser.test_run('
        nothing chief():
            map<int, int> m = { 2: 2, 3: 3}
        
            for int i, int j in m:
            
      
            endfor 
        end'))

        assert_equal(15, @@parser.test_run('
        int chief():
            map<int, int> x = {1: 2, 2: 3, 3: 4}
            int res = 0 

            for int i, int j in x:
                res = res + i + j 
            endfor 

            return res
        end'))

        assert_equal(32, @@parser.test_run('
        int chief():
            map<map<int, int>, int> x = {{1: 2, 2: 3, 3: 4}: 10, {5: 6, 6: 7, 7: 8}: 20}
            map<map<int, int>, int> y  = {}
            int res = 0

            for map<int, int> m, int j in x:
                y[m] = j + 1
                res = res + y[m]
            endfor

            return res
        end'))

        assert_equal(84, @@parser.test_run('
        int chief():
            map<map<int, int>, int> x = {{1: 2, 2: 3, 3: 4}: 10, {5: 6, 6: 7, 7: 8}: 20}
            int res = 0 

            for map<int, int> m, int j in x:
                for int y, int z in m:
                    res = res + y + z  
                endfor

                res = res + j 
            endfor 

            return res
        end')) 

        assert_equal(54, @@parser.test_run('
        int chief():
            map<list<int>, list<string>> x = {[1, 2, 3]: ["123"], [2, 3, 4]: ["234"], [3, 4, 5]: ["345"]}

            int res = 0 

            for list<int> i, list<string> j in x:
                    for string s in j: 
                        for string l in s:
                            res = res + l.int()
                        endfor 
                    endfor

                    for int n in i: 
                        res = res + n 
                    endfor 
            endfor 

            return res
        end'))

        
         # with auto

        assert_equal(nil, @@parser.test_run('
        nothing chief():
            map<int, int> m = { 2: 2, 3: 3}

            for auto i, auto j in m:


            endfor   
        end'))

        assert_equal(15, @@parser.test_run('
        int chief():
            map<list<int>, int> x = {[1]: 2, [2]: 3, [3]: 4}
            int res = 0 

            for auto i, auto j in x:
                    res = res + i[0] + j 
            endfor 

            return res
        end'))

        assert_equal(84, @@parser.test_run('
        int chief():
            map<map<int, int>, int> x = {{1: 2, 2: 3, 3: 4}: 10, {5: 6, 6: 7, 7: 8}: 20}
            int res = 0 

            for auto m, auto j in x:
                for auto y, auto z in m:
                    res = res + y + z  
                endfor

                res = res + j 
            endfor 

            return res
        end'))
    end 
 
    def test_for_each_list()

        # with explicit type of iterationvariable

        assert_equal(nil, @@parser.test_run('
        nothing chief():
            list<int> l = [1, 2, 3]

            for int j in l:

            endfor 
        end'))
        
        assert_equal("hannalinusandreas", @@parser.test_run('
        string chief():
            list<string> x = ["hanna", "linus", "andreas"]
            string res

            for string name in x:  
                res = res + name 
            endfor

            return res
        end'))

        assert_equal(45, @@parser.test_run('
        int chief():
            list<list<int>> x = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
            int res

            for list<int> l in x:  
                for int num in l:
                    res = res + num 
                endfor 
            endfor

           return res
       end'))

        # with auto 

        assert_equal(nil, @@parser.test_run('
        nothing chief():
            list<int> l = [1, 2, 3]

            for auto j in l:


            endfor 
        end'))

        assert_equal("hannalinusandreas", @@parser.test_run('
        string chief():
            list<string> x = ["hanna", "linus", "andreas"]
            string res

            for auto name in x:  
                res = res + name 
            endfor

            return res
        end'))

        assert_equal(30, @@parser.test_run('
        int chief():
            list<list<int>> x = [[1, 2, 3], [10, 20, 30], [7, 8, 9]]
            int res

                for auto l in x:  
                    for auto num in l:
                        if num < 10:
                            res = res + num
                        endif 
                    endfor 
                endfor

            return res
        end'))

        assert_equal(84, @@parser.test_run('
        int chief():
            list<list<list<int>>> x = [[[1, 2, 3], [4, 5, 6], [7, 8, 9]], [[4, 5, 6], [7, 8, 9]]]
                int res 
                    for auto l in x:  
                        for auto l2 in l:
                            for auto num in l2:
                                res = res + num
                            endfor
                        endfor 
                    endfor
            return res
        end')) 
    end 

    def test_for_each_str()

        assert_equal("hannalinusandreas", @@parser.test_run('
        string chief():
            string x = "hannalinusandreas"
            string res

            for string letter in x:  
                res = res + letter
            endfor

            return res
        end'))
    
    end

    def test_for_each_error()
        assert_raise_message("container must be of type String, List or Map") do 
            @@parser.test_run('
            string chief():

                for string letter in 3 + 3:  

                endfor

                return res
            end')
        end
    end

    def test_for_loops()

        assert_equal(nil, @@parser.test_run('
        nothing chief():

            for int i, i < 2, i+=1:


            endfor

        end'))

        assert_equal(3628800, @@parser.test_run("
        int chief():
            int res = 1

            for int i = 1, i <= 10, i +=1:
                res = res * i
            endfor

            return res
        end"))

        # Same as above with step == 2
        assert_equal(945, @@parser.test_run("
        int chief():
            int res = 1

            for int i = 1, i <= 10, i += 2:
                res = res * i
            endfor

            return res
        end"))

        assert_equal(9, @@parser.test_run("
        int chief():
            int res = 1

            for int i = 1, i <= 2, i+=1:
                for int j = 0, j < 2, j += 1:
                    res = res + i + j
                endfor
            endfor

            return res
        end")) 
        
        # Same as above with step == 2
        assert_equal(4, @@parser.test_run("
        int chief():
            int res = 1

            for int i = 1, i <= 2, i += 2:
                for int j = 0, j < 2, j += 1:
                    res = res + i + j
                endfor
            endfor

            return res
        end")) 
        
        # making sure that correct 'z' is updated and later returned.
        assert_equal(6, @@parser.test_run("
        int chief():
            int z = 100
            for int i = 1, i <= 2, i += 2:
                int z 
                for int j = 0, j < 6, j += 1:
                    if z > 4: 
                        return z
                    endif 
                    z = z + j 
                endfor
            endfor

            return z
        end"))

         # making sure that correct 'z' is updated and later returned.
        assert_equal(1, @@parser.test_run("
        int chief():
            int z = 1

            for int i = 1, i <= 2, i += 1:
                int z 
                for int j = 0, j < 6, j += 1:
                    z += j
                endfor
            endfor 
            return z
        end"))

        # making sure that correct 'w' is updated returned
        assert_equal(111.2, @@parser.test_run("
        float chief():
            int z = 4
            int w = 5
            int x = 6

            for int i = 0, i < 2, i += 1:
                int x = 0
                for int j = 0, j < 2, j += 1:
                    float w = 100.2
                    for int k = 0, k < 2, k += 1:
                        z += 1
                        x += 1
                        w += z

                        if w == 111.2:
                            return w
                        endif

                    endfor
                endfor
            endfor
        return z
        end"))
    end

    def test_for_loop_errors()

        assert_raise_message("FOR LOOP: is String expected Int") do
            @@parser.test_run("
            float chief():
                int z = 1
                
                for string j, j < 3, j += 1:
                    if z > 4: 
                        return z
                    endif 
                    z = z + j 
                endfor
    
                return z
            end")
        end 
    end 

    def test_while_loops()

        assert_equal(6, @@parser.test_run("
        int chief():
            int x = 0

            while x < 6:
                x += 1
            endwhile

            return x
        end"))

                                    
        assert_equal(16.0, @@parser.test_run("
        float chief():
            int x = 0
            float y = 0.0 

            while x < 6:
                while y < 10.0: 
                    y += 2.0 
                endwhile 

                x += 1
            endwhile

            return y + x 
        end"))

        # Making sure that scope is working, y in the second loop should not change
        # the y declared outside the loops. 
        assert_equal(6.0, @@parser.test_run("
        float chief():
            int x = 0
            float y = 0.0 

            while x < 6:
                float y = 5.0 
                while y < 10.0:
                    y += 2.0
                endwhile 

                x += 1
            endwhile

            return y + x 
        end"))

        # In this program, y declared in the first while loop is returned
        # in the inner loop when it reaches 25. 
        assert_equal(25.0, @@parser.test_run("
        float chief():
            int x = 0
            float y = 0.0 

            while x < 6:
                float y = 5.0 
                while y < 50.0:
                    y += 2.0

                    if y == 25.0:  
                        return y
                    endif 
                endwhile 

                x += 1
            endwhile

            return y + x 
        end"))

        # x is updated to be 10 in the third while loop and returned in the second while
        # loop 
        assert_equal(10, @@parser.test_run("
        int chief():
            int x = 0
            float y = 0.0 

            while x < 6:
                float y = 5.0 
                while y < 50.0:
                    y += 2.0 
                    if y == 25.0:  
                        return y
                    elseif x == 10:  
                        return x 
                    endif

                    while y < 15.0: 
                        x += 5 
                        y += 5.0 
                    endwhile 
                endwhile 

                x+= 1
            endwhile

            return y + x 
        end"))

    end

    def test_break_next()

        #break

        assert_equal(5, @@parser.test_run("
        int chief():
            int res

            for int i = 0, i < 10, i += 1:
                res = i
                if i == 5: 
                    break
                endif
            endfor

            return res
        end"))

        assert_equal(24, @@parser.test_run("
        int chief():
            int res

            for int i = 0, i < 6, i += 1:
                res += 1

                for int j = 0, j < 5, j += 1:
                    if j == 3: 
                        break
                    endif
                    res += 1
                endfor
            endfor

            return res
        end"))


        assert_equal(15, @@parser.test_run('
        int chief():
            list<list<int>> x = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [7, 8, 9]]
            int res 
                for auto l in x: 
                    for auto num in l:
                        if num % 2 == 0:
                            break
                        else:
                            res = res + num
                        endif

                    endfor
                endfor
            return res    
        end'))

        assert_equal(11, @@parser.test_run("
        int chief():
            int x = 0
            float y = 0.0 

            while x < 6:
                float y = 5.0 
                while y < 50.0:
                    y = y + 2.0  
                    if y == 25.0:  
                        return y
                    elseif x == 10:  
                        break 
                    endif

                    while y < 15.0: 
                        x = x + 5
                        y = y + 5.0 
                    endwhile 
                endwhile 

                x = x + 1
            endwhile

            return x 
        end"))

        #next
        assert_equal("hnnlinusndres", @@parser.test_run('
        string chief():
            string x = "hannalinusandreas"
            string res

            for string letter in x:  
                if letter.has_chr("a"):  
                    next
                else: 
                    res = res + letter 
                endif 
            endfor

            return res
        end'))

                                         
        assert_equal(65, @@parser.test_run("
        int chief():
            int res

            for int i = 0, i < 10, i += 1:
                for int i = 0, i < 5, i += 1: 
                    if i % 2 == 0:  
                        next
                    else:
                        res = res + 1
                    endif  
                endfor 
                res = res + i
            endfor

            return res
        end"))

        assert_equal(25.0 , @@parser.test_run("
        float chief():
            int x = 0
            float y = 0.0 

            while x < 6:
                float y = 5.0 
                while y < 50.0:
                    y = y + 2.0  
                    if y == 25.0:  
                        return y
                    elseif x == 10:  
                        next  
                    endif

                    while y < 15.0: 
                        x = x + 5
                        y = y + 5.0 
                    endwhile 
                endwhile 

                x = x + 1
            endwhile

            return y 
        end"))
    end
end 