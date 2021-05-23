nothing chief():

    list<map<string, string>> movies_list = []

    movies_list.add_to_back({'title': 'Raise your voice', 'actor': 'Hilary Duff', 'score': '5'})

    movies_list.add_to_back({'title': 'The imitation game', 'actor': 'Benedict Cumberbatch', 'score': '10'})

    movies_list.add_to_back({'title': 'Boyz n the Hood', 'actor': 'Cuba Gooding, Jr.', 'score': '10'})

    lambda criteria = [](map<string, string> movie):  movie["score"] end

    lambda info = [](map<string, string> movie):  movie["title"] end

    list<string> res = search(movies_list, "10", criteria, info)

    printn("Filmer med betyg 10: ")
    printn(res)
end

list<string> search(list<map<string, string>> movies_list, string res, lambda criteria, lambda info):
    list<string> best_movies

    for auto m in movies_list:
        if criteria(m) == res:
            best_movies.add_to_back(info(m))
        endif 
    endfor 

    return best_movies

end 