nothing chief():
    string name = "Love"
    string encoded = encode(name)
    printn("ENCODED: ")
    printn(encoded)
    
    printn("")

    string decoded = decode(encoded)
    printn("DECODED: ")
    printn(decoded)
end


bool is_consonant(string c):

 string consonant = "BCDFGHJKLMNPQRSTVWXYZ"

 return consonant.has_chr(c.upper())
end 

string encode(string word):
  
    string res
    for string letter in word:
       
        if is_consonant(letter): 
            res = res + letter + "o" + letter 
             
        else: 
            res = res + letter
             
        endif 
    endfor 

    return res.lower()
end

string decode(string word):
    string res 
    int i 

    while i <= word.length() - 1:
        res = res + word[i]
        
        if word[i].is_alpha() and is_consonant(word[i]): 
            i = i + 3
        else: 
            i = i + 1
        endif
    endwhile 

    return res 
end