# DropScript V alpha 0.4
DropScript is a simple interpreted programming language made as a hobby project.

The interpreter is written in Dart, targeting Dart 2.9.
Until Dart 2.9 is fully released please use the [2.9 dev sdk](https://github.com/dart-lang/samples/blob/master/null_safety/calculate_lix/README.md#dart-preview-sdk-installation) with the `--enable-experiment=non-nullable` flag, example:
```
dart --enable-experiment=non-nullable Main.dart filename.ds
```
where `filename.ds` is the DropScript file to run.

# Quick tour
## Basics
DropScript has 7 datatypes
* Integer
* Double
* String
* Boolean
* Block
* Object

The syntax consists of objects (not to be confuesd with the datatype) that are made up of a base, with 0 or more extensions. These objects can then be part of actions or just be evaluated on their own. Each action or standalone object ends with a semicolon.

The base of an object is either a constant, or an identifier for a variable. Some base objects:
```
"Hello i am a string";
4.6;
myCar;
```
0 or more extensions can be chained from an object. These are field access, executions, and operators
```
myCar.color; //access "color" on the object
print(); //execute the print function (with 0 arguments)
3 + 7;
```
operators are just syntactical sugar for access and execution of a corresponding function, so `3 + 7` is the same as `3.add(7)`. See a full list of operators further down.

Finally objects can be part of actions. There are currently 3 actions: assignment, ternary operator, and just evaluating the object on its own.
```
color = "#" + "00ff00"; //assignment

x == 3 ? print("Its 3") : print("Its not 3"); //ternary

myFunction(); //simply evaluating the object and calling the function
```
## Functions
Functions in DropScript are created by creating a Block. A block has the syntax:
```
(arguments):{code}
```
where `arguments` is a comma separated list of identifiers to use as arguments, and `code` is 0 or more lines of code. For example, we can create a Block and assign it to a variable.
```
myFunction = (first, second):{
    print(first);
    print(second);
}; //as this is really just a assignment, so dont forget the semicolon!

myFunction("Hello", "World");
```
As Blocks are treated just like the other datatypes, you can use them as arguments to other blocks too.

There is no return keyword (in fact, there is not keywords at all), but it is possible to return a value from a function by setting the return variable to a value
```
add = (x, y):{
    return = x + y;
};
print(add(2, 3)); //prints 5
```
## Objects
Lets look at the syntax for objects
```
//a "class" for a car
car = (color, model):{
    speed = 3;
    //a "method"
    accelerate = { //if a block takes no arguments, the (): can be omitted
        speed = speed + 1;
    };
};

volvo = car("red", "volvo");
print(volvo.color); //red
print(volvo.speed); //3
volvo.accelerate();
print(volvo.speed); //4
```
Now you might be thinking, "that is the same syntax as for functions?". And you would be correct.
If you do not set a return value in a block, instead an Object with all variables assigned inside the block will be returned. This includes the arguments, so a Block with an empty body would return an Object containing just the arguments. A method inside a class is simply a block assigned to a variable, that will be returned as part of the object.

And that is about it for the syntax. There are no reserver keywords for if, switch, while, for etc. But there are functions implemented to take their place in the standard library

## Standard library
The standard library currently contains definitions for `if` (and `else`), `loop`, `while`, and a `range` class. There is also a handy `print` functions that prints to the console.

Lets look at the `if` block
```
if = (condition, trueblock):{
    condition ? trueblock() : {}();
    else = (falseblock):{
        condition ? {}() : falseblock();
    };
};
```
The block takes a condition and a block, and uses the ternary operator to either run the block or do nothing (run a empty block).
The object returned by `if` also contains a field for `else`, that takes a new block and runs it if the condition was false. Some example usage:
```
if(a == b, {
    print("They are the same");
}); //remember that this is just a function call, dont forget the semicolon!


if(x == 3, {
    print("x is 3");
}).else({
    print("x is something else");
});
```
`while` takes a condition block and a loop block, and will run the loop block as long as the condition block returns true
```
x = 1;
while({return = x < 10;}, {
    print(x);
    x = x + 1;
});
```
Warning: `while` uses recursion under the hood, and there is no tail recursion optimisation yet. Too long loop and your going to hit a stack overflow.

The standard library will be expanded with some more functions in the future.

## Operator table
Each operator calls the corresponding function with one argument, except for `!`, which is a prefix operator that takes no argument
| Operator | Function name |
|--|--|
^   |pow|
|+   |add|
|-   |sub|
|/   |div|
|*   |mul|
|%   |mod|
|&&  |and|
|\|\|  |or|
|<=> |compare|
|==  |equal|
|<=  |lesserEqual|
|>=  |greaterEqual|
|<   |lesser|
|>   |greater|
|!=  |notEqual|
|><  |includes|
|<>  |excludes|
|<<  |append|
|..  |range|

If you make custom objects they can have blocks assigned to these names, which will allow you to use the corresponding operator with the object. 

# Future plans
There is no guarantee that anything will be added, as this is simply a fun hobby project. However I hope to add
* List primitive datatype
* Hashmap primitive datatype
* Setting fields on objects (`mything.field = 3`)
* Some more syntactical sugar for small blocks (`while({return = x < 10;}, ...` is a bit much)
* syntax highlighting
* third party libraries
* comments