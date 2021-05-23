int chief():
    int pairs = count_nested_pairs(5)
    print("Degree: ")
    printn(5)

    print("Number of pairs: ")
    printn(pairs)
    return pairs 
end 

# CATALANTAL WOOP 

int count_nested_pairs(int n):
   
    if n == 1 or n == 2:
        return 1
    else: 
        int res
        
        for int i = 1, i < n, i += 1:

            int rhs = n - i

            int lhs_factor = count_nested_pairs(i)
            int rhs_factor = count_nested_pairs(rhs)

            res = res + rhs_factor * lhs_factor   
        endfor
    
        return res 
    endif
end