# Coding Challenge - 015: Generate Password

The purpose of this coding challenge is to write a program that creates a random password from a given full name.

## Learning Outcomes

At the end of this coding challenge, students will be able to;

- Analyze a problem, identify, and apply programming knowledge for an appropriate solution.

- Implement conditional statements effectively to solve a problem.

- Implement loops to solve a problem.

- Execute operations on strings.

- Make use of random numbers to solve a problem.

- Demonstrate their knowledge of algorithmic design principles by solving the problem effectively.

## Problem Statement

Write a Python program that prompts the user to enter his/her full name (without any spaces) and then creates a secret password consisting of three letters (in lowercase) randomly picked up from his/her full name, and a random four-digit number. For example, if the user enters "JackClarusway", a secret password can probably be one of "jcs1578" or "yka8832" or "awu1250".

- Expected Output:

```text
Please enter your full name: StephenClarkson
rto8807

Please enter your full name: BillJames
ils6032

Please enter your full name: MarkJackson
jkr7034

Please enter your full name: CarlSmith
iih7800
```

## Solution

```python
import random as rnd

name = input("Please enter your full name (without any space): ")
passw = ""

for i in range(3):
  randIndex = rnd.randint(0, len(name)-1)
  letter = name[randIndex]
  passw += letter.lower()
randNum = rnd.randint(1000,9999)
passw += str(randNum)
print(passw)
```

## Computational Thinking

### Abstraction

What you are looking for is a "password". If you apply abstraction, a password is a string. In this case, this string is going to be generated under certain rules. These rules are that it has to start with 3 letters that exist in a given name and that it should end with 4 random digits. So what you want at the end of the day is a string that starts with 3 letters from a given name and surname and followed with 4 random digits.

### Pattern Recognition

The pattern is the given rule in this case. It is the first 3 letters and the following 4 digits. Every time the program is executed, you have to randomly pick 3 letters from the name and surname combination and 4 digits from 0 to 9.

### Algorithm Design

We are going to use the pattern that we have recognized to design the algorithm. So the algorithm should be as follows:

- Step 1: Pick 3 random letters from the given string one by one. And add them to the string you would like to create which is empty in the beginning.

- Step 2: Add 4 random digits to the string. You can see this as a 4 digit number. So it is a random number between 1000 and 9999.
