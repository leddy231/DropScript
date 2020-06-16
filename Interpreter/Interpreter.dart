import '../Lexer/Lexer.dart';
import '../Lexer/Tokens.dart';
import '../Parser/Parser.dart';
import '../Parser/Actions.dart';
import 'Context.dart';
import 'Primitives.dart';
import 'dart:io';

class Interpreter {
  static Future<bool> interpretFile(String filename, Context context, {printTokens: false, printActions: false, printGraph: false, printLines: false}) async {
    File file = File(filename);
    if (!await file.exists()) {
      throw("File: ${filename} not found");
    }
    String contents = await file.readAsString();
    List<String> lines = contents.split("\n");

    Lexer lexer = Lexer();
    List<Token> tokens = lexer.lex(lines.iterator);
    if(printTokens) {
      print(tokens);
    }
    
    Parser parser = Parser(tokens);
    List<Action> actions;
    try {
      actions = parser.parseProgram();
    } catch (e) {
      print("Error during parsing");
      print(e);
      return false;
    }
    if(printActions) {
      for (var action in actions) {
        print(action.toString());
      }
    }
    if(printGraph) {
      List<String> list = [];
      var topnode = actions[0].toGraph(list);
      list.insert(0, topnode);
      print(list.join("\n"));
    }

    for (var action in actions) {
      if(printActions) {
        print("${action.line} action: ${action.toCode()}");
      }
      try {
        var result = action.execute(context);
        if(printLines) {
         print("${action.line} result: ${result}");
        }
      } catch (e) {
        print("Error during execution");
        print(e);
        return false;
      }
    }
    return true;
  }

  static List<Primitive> interpretInline(String code, Context context) {
    Lexer lexer = Lexer();
    List<Token> tokens = lexer.lex([code].iterator);
    Parser parser = Parser(tokens);
    List<Action> actions = parser.parseProgram();
    List<Primitive> results = actions.map((action) => action.execute(context)).toList();
    return results;
  }
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