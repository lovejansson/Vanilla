
#Archer har varit ute på en resa och tittat på berg. Tyvärr gick filmrullen(man hade sådana innan
#digitalkameror) i kameran sönder när han sköt pilbåge (Archer… Get it?). Därför har han gett dig i
#uppgift att skriva ett program som ritar berg.
#Du ska skapa en funktion som heter draw_mountain. Funktionen tar en parameter, ett heltal som
#beskriver hur högt berget skall vara och skriver sedan ut ett berg av den storleken. Ditt program ska
#sedan ta inmatning från användaren som inte behöver felkontrolleras och använda den inmatningen
#för att anropa funktionen.

int chief():
    int num = input("Type in the size of the mountain:").int()  
    draw_mountain(num)
    return 1 
    
end 

nothing draw_mountain(int n):
    int outer_spaces = n - 1
    int inner_spaces = 0 

    for int i =  0, i < n, i += 1:
        print(outer_spaces * " ")
        print("/")
        print(" " * inner_spaces)
        printn("\")
        outer_spaces = outer_spaces - 1
        inner_spaces = inner_spaces + 2
    endfor 
end 

 
 