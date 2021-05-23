 nothing chief():
    list<list<string>> d = create_deck()
    printn("DECK: ")
   for list<string> card in d:
        print("Suit: ")
        printn(card[1])
        print("Value: ")
        printn(card[0])
        printn("")
    endfor 

   
 end 
 
 list<list<string>> create_deck():
    list<list<string>> deck 
    for int i = 1, i < 15, i += 1:
        for string c in ["hearts", "spades", "clubs", "diamonds"]:
            list<string> card = [i.string(), c]

            deck.add_to_back(card)      
        endfor 
    
    endfor 
    return deck
end 
