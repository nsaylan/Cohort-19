def isValid(s):
  bracket_map = {"(": ")", "[": "]",  "{": "}"}
  open_par = set(["(", "[", "{"])
  stack = []
  for i in s:
    if i in open_par:
        stack.append(i)
    elif stack and i == bracket_map[stack[-1]]: # stack listesine parantez var mı diye kontrol eder.
        stack.pop()
    else:
        return False
  return stack == []

combination = input('Write a string that contains only `(`, `)`, `{`, `}`, `[` and `]`: ')
print(isValid(combination))