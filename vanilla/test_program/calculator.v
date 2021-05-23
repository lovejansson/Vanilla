nothing chief():
    int num1 = input("type in first operand: ").int()
    string op = input("type in operator (+ or -): ")
    int num2 = input("type in second operand: ").int() 

    map<string, lambda> operators = {"+": [](int a, int b): a + b end, "-": [](int a, int b): a - b end}

   lambda func = operators[op]

   int res = func(num1, num2)

   printn("expression: " + num1.string() + op + num2.string())
   printn("result: " + res.string())

end