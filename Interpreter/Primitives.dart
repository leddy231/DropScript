import '../Interpreter/Context.dart';
import '../Interpreter/Interpreter.dart';
import '../Parser/Actions.dart';
import 'dart:math';


PrimitiveBlockSpecial numArithmetic(num Function(num) arithFun, String name) 
  => PrimitiveBlockSpecial(1, (ctx, args){
      Primitive arg = args[0];
      if(arg is PrimitiveNum) {
        return PrimitiveNum(arithFun(arg.value));
      }
      throw("Cannot ${name} Number and ${arg}");
    });

PrimitiveBlockSpecial numCompare(bool Function(num) boolFun, String name) 
  => PrimitiveBlockSpecial(1, (ctx, args){
      Primitive arg = args[0];
      if(arg is PrimitiveNum) {
        return PrimitiveBool(boolFun(arg.value));
      }
      throw("Cannot ${name} Number and ${arg}");
    });

PrimitiveBlockSpecial boolCompare(bool Function(bool) boolFun, String name) 
  => PrimitiveBlockSpecial(1, (ctx, args){
      Primitive arg = args[0];
      if(arg is PrimitiveBool) {
        return PrimitiveBool(boolFun(arg.boolean));
      }
      throw("Cannot ${name} Boolean and ${arg}");
    });

PrimitiveBlockSpecial stringCompare(bool Function(String) boolFun, String name) 
  => PrimitiveBlockSpecial(1, (ctx, args){
      Primitive arg = args[0];
      if(arg is PrimitiveString) {
        return PrimitiveBool(boolFun(arg.string));
      }
      throw("Cannot ${name} Boolean and ${arg}");
    });

abstract class Primitive {
  final Map<String, Primitive> accessMap;
  Primitive(this.accessMap);
  Primitive? access(String identifier) {
    return accessMap[identifier];
  }
  String toString();
  String toCode();
}

class PrimitiveString extends Primitive {
  final String string;
  PrimitiveString(this.string) : super({
    "length": PrimitiveBlockSpecial(0, (ctx, args){
      return PrimitiveNum(string.length);
    }),
    "add": PrimitiveBlockSpecial(1, (ctx, args){
      return PrimitiveString(string + ctx.get('arg').toCode());
    }),
    "equal": stringCompare((arg) => string == arg, "compare"),
    "includes": stringCompare((arg) =>  string.contains(arg), "test inclusion"),
    "excludes": stringCompare((arg) => !string.contains(arg), "test exclusion"),
  });
  String toString() => "String(\"${string}\")";
  String toCode() => string;
}

class PrimitiveNum extends Primitive {
  final num value;
  PrimitiveNum(this.value) : super({
    "pow": numArithmetic((arg) => pow(value, arg), "power"),
    "add": numArithmetic((arg) => value + arg, "add"),
    "sub": numArithmetic((arg) => value - arg, "subtract"),
    "div": numArithmetic((arg) => value / arg, "divide"),
    "mul": numArithmetic((arg) => value * arg, "multiply"),
    "mod": numArithmetic((arg) => value % arg, "modulus"),
    "compare":   numArithmetic((arg) => value.compareTo(arg), "compare"),
    "equal":        numCompare((arg) => value == arg, "equal"),
    "lesserEqual":  numCompare((arg) => value <= arg, "equal"),
    "greaterEqual": numCompare((arg) => value >= arg, "equal"),
    "lesser":       numCompare((arg) => value <  arg, "equal"),
    "greater":      numCompare((arg) => value >  arg, "equal"),
    "notEqual":     numCompare((arg) => value != arg, "equal"),
    "range": PrimitiveBlockSpecial(1, (ctx, args){
      Primitive arg = args[0];
      if(arg is PrimitiveNum) {
        return Interpreter.interpretInline("range(${value},${arg.value});", ctx)[0];
      }
      throw("Cannot make a range with ${arg}");
    })
  });
  String toString() => "Num(${value})";
  String toCode() => value.toString();
}

class PrimitiveBool extends Primitive {
  final bool boolean;
  PrimitiveBool(this.boolean) : super({
    "equal":    boolCompare((arg) => boolean == arg, "equal"),
    "and":      boolCompare((arg) => boolean && arg, "and"),
    "or":       boolCompare((arg) => boolean || arg, "or"),
    "notEqual": boolCompare((arg) => boolean != arg, "equal"),
    "not": PrimitiveBlockSpecial(0, (ctx, args) => PrimitiveBool(!boolean))
  });
  String toString() => "Bool(${boolean})";
  String toCode() => boolean.toString();
}

abstract class PrimitiveAbstractBlock extends Primitive {
  final int arguments;
  
  PrimitiveAbstractBlock(this.arguments, Map<String, Primitive> map) : super(map);
  Primitive execute(Context context, List<Primitive> args);
}

class PrimitiveBlock extends PrimitiveAbstractBlock {
  List<Action> actions;
  final List<String> argumentList;
  final Context creatorContext;
  PrimitiveBlock(this.argumentList, this.creatorContext, this.actions) : super(argumentList.length, {});
  String toString() => "Block(${actions.join("\n")})";
  String toCode() => "(" + argumentList.join(',') + "):{" + actions.map((a) => a.toCode()).join("\n") + "}";
  Primitive execute(Context callerContext, List<Primitive> args) {
    Context subContext = creatorContext.subContext();
    for (int i = 0; i < arguments; i++) {
      String key = argumentList[i];
      subContext.set(key, args[i]);
    }
    for (var action in actions) {
      action.execute(subContext);
    }
    if(subContext.lookupLocal('return')) {
      return subContext.get('return');
    }
    return PrimitiveObject(subContext);
  }
}

class PrimitiveBlockSpecial extends PrimitiveAbstractBlock {
  final Primitive Function(Context context, List<Primitive> args) function;
  PrimitiveBlockSpecial(int args, this.function) : super(args, {});
  String toString() => "BlockSpecial()";
  String toCode() => "{}";
  Primitive execute(Context context, List<Primitive> args) => function(context, args);
}

class PrimitiveObject extends Primitive {
  final Context context;
  PrimitiveObject(this.context) : super(context.variables);
  String toString() => "Object(${context})";
  String toCode() => context.toCode();
}

/*
Part of the DropScript interpreter
Copyright (C) 2020 Martin Larsson aka leddy231

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

*/