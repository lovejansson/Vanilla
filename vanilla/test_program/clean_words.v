

#1. Ta bort alla tecken som inte är bokstäver fram till första bokstaven i ordet.
#2. Ta bort alla tecken som inte är bokstäver efter den sista bokstaven i ordet.
#3. Gör om eventuella gemener (små bokstäver) till versaler (stora bokstäver), tecken som inte
#är bokstäver skall inte ändras.
#4. Lägg till ordet i en lista.
#5. Upprepa 1-6 tills alla ord i i filen har behandlats.
#6. Skriv ut listan

nothing chief():
  
    list <string> l = ["hej", "!hEj#$", "!he#j#$", "&h#e$j%$#@#", "!@#$#$%^&*())__+=HeJ{}|?>|"]
    list <string> res

    for string s in l:
        if s.is_alpha() == true:
            bool first_letter_found = false
            list<string> chars = s.split("")
            int first_index
            string last_letter

            for string c in chars:
                
                if c.is_alpha():

                    if first_letter_found == false:
                        first_index = chars.get_index(c)
                        first_letter_found = true
                    else: 
                        last_letter = c 
                    endif
                endif  
            endfor

            int last_index = chars.get_index(last_letter)

            string clean_word 
            
            for int i = first_index, i < last_index + 1, i += 1: 
                clean_word = clean_word + chars[i]

            endfor 

            clean_word = clean_word.upper()
        
            res.add_to_back(clean_word)
        endif 

    endfor

    printn("Original words: ")

    for string s in l: 
            printn(s)
    endfor 

    printn("")
    
    printn("Cleaned words: ")

    for string s in res: 
            printn(s)
    endfor 
end

