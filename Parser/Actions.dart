import '../Interpreter/Context.dart';
import '../Interpreter/Primitives.dart';

abstract class Action {
  static int globalid = 0;
  final int id;
  final int line;
  Action(this.line) 
  : id = globalid {
    globalid += 1;
  }
  Primitive execute(Context context) {
    try {
      return internalExecute(context);
    } catch (e) {
      throw e.toString() + "\nIn ${runtimeType} at line ${line}";
    }
  }
  Primitive internalExecute(Context context);
  String toGraph(List<String> list);
  String toCode();
}

class ActionConstant extends Action{
  final Primitive value;
  ActionConstant(this.value, int line) : super(line);
  Primitive internalExecute(Context context) => value;
  String toString() => "ActionConstant(${value})";
  String toGraph(List<String> list) {
    String ret = "[${id}|Constant|${value.toCode()}]";
    var block = value;
    if(block is PrimitiveBlock) {
      for (var action in block.actions) {
        list.add(ret + '->' + action.toGraph(list));
      }
    }
    return ret;
  }
  String toCode() => value.toCode();
}

class ActionIdentifier extends Action {
  final String identifier;
  ActionIdentifier(this.identifier, int line) : super(line);
  Primitive internalExecute(Context context) => context.get(identifier);
  String toGraph(List<String> list) => "[${id}|Identifier|${identifier}]";
  String toCode() => identifier;
}

class ActionAccess extends Action {
  final Action object;
  final String identifier;
  ActionAccess(this.object, this.identifier, int line) : super(line);
  Primitive internalExecute(Context context) {
    Primitive obj = object.execute(context);
    Primitive? value = obj.access(identifier);
    if(value == null) {
      throw("No value on ${obj} with identifier ${identifier}");
    }
    return value;
  }
    String toGraph(List<String> list) {
    String ret ="[${id}|Access|${identifier}]";
    list.add(ret + '->' + object.toGraph(list));
    return ret;
  }
  String toCode() => object.toCode() + "." + identifier;
}

class ActionAssign extends Action {
  final Action destination;
  final Action value;
  ActionAssign(this.destination, this.value, int line) : super(line);
  Primitive internalExecute(Context context) {
    if(destination is ActionIdentifier) {
      ActionIdentifier identifier = destination as ActionIdentifier;
      Primitive val = value.execute(context);
      context.set(identifier.identifier, val);
      return val;
    }
    
    throw("Cannot assign to object of type ${destination}");
  }
  String toGraph(List<String> list) {
    String ret = "[${id}|Assign]";
    list.add(ret + '->' + destination.toGraph(list));
    list.add(ret + '->' + value.toGraph(list));
    return ret;
  }
  String toCode() => value.toCode() + " = " + destination.toCode();
}

class ActionExecute extends Action {
  final Action object;
  final List<Action> arguments;
  ActionExecute(this.object, this.arguments, int line) : super(line);
  Primitive internalExecute(Context context) {
    Primitive value = object.execute(context);
    if(value is! PrimitiveAbstractBlock) {
      throw("Cannot execute this object: ${value}");
    }
    PrimitiveAbstractBlock block = value;
    if(block.arguments != arguments.length) {
      throw("Missmatched argument lengths, wanted ${block.arguments}, got ${arguments.length}");
    }
    List<Primitive> argValues = arguments.map((arg) => arg.execute(context)).toList();
    return block.execute(context, argValues);
  }
  String toGraph(List<String> list) {
    String ret ="[${id}|Execute]";
    list.add(ret + '->' + object.toGraph(list));
    if(arguments.length > 0) {
      String args = "[${id}a|Arguments]";
      list.add(ret + '->' + args);
      for (var arg in arguments) {
        list.add(args + '->' + arg.toGraph(list));
      }
    }
    return ret;
  }
  String toCode() => object.toCode() + "(" + arguments.map((a) => a.toCode()).join(", ") + ")";
}

class ActionTernary extends Action {
  final Action condition;
  final Action ifTrue;
  final Action ifFalse;
  ActionTernary(this.condition, this.ifTrue, this.ifFalse, int line) : super(line);
  Primitive internalExecute(Context context) {
    Primitive value = condition.execute(context);
    if(value is! PrimitiveBool) {
      throw("Cannot branch on non boolean object: ${value}");
    }
    PrimitiveBool boolean = value;
    Action torun = ifFalse;
    if(boolean.boolean) {
      torun = ifTrue;
    }
    return torun.execute(context);
  }
  String toGraph(List<String> list) {
    String ret = "[${id}|Ternary]";
    list.add(ret + '->' + condition.toGraph(list));
    list.add(ret + '->' + ifTrue.toGraph(list));
    list.add(ret + '->' + ifFalse.toGraph(list));
    return ret;
  }
  String toCode() => condition.toCode() + " ? " + ifTrue.toCode() + " : " + ifFalse.toCode();
}

class ActionBlock extends Action {
  final List<String> arguments;
  final List<Action> block;
  ActionBlock(this.block, this.arguments, int line) : super(line);
  Primitive internalExecute(Context context) => PrimitiveBlock(arguments, context, block);
  String toGraph(List<String> list) => "[${id}|Block]";
  String toCode() => "(" + arguments.join(", ") + "):{" + block.map((a) => a.toCode()).join("\n") + "}";
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