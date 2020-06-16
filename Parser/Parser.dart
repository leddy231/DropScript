import '../Lexer/Tokens.dart';
import 'Actions.dart';
import '../Interpreter/Primitives.dart';

class UnexpectedToken implements Exception {
  Token got;
  TokenType? expected;
  final String message;
  UnexpectedToken(this.got, [this.expected = null]) : message = _formatMsg(got, expected);

  static String _formatMsg(Token got, TokenType? expected) {
    String msg = "Unexpected ${got}";
    if(expected != null) {
      msg += ", expected ${expected}";
    }
    msg += " at line ${got.line}";
    return msg;
  }
  String toString() => message;
}

class Parser {
  final List<Token> tokens;
  Parser(this.tokens);

  List<Token> _groupBy(TokenType begin, TokenType end) {
    expect(begin);
    List<Token> ret = [];
    int depth = 1;
    while (depth > 0) {
      Token token = next();
      if(token.type == begin) {
        depth += 1;
      }
      if(token.type == end) {
        depth -= 1;
      }
      if(token.type == TokenType.eof) {
        throw UnexpectedToken(token, TokenType.closeparen);
      }
      ret.add(token);
    }
    ret.removeLast();
    return ret;
  }

  List<Token> groupParentheses() => _groupBy(TokenType.openparen, TokenType.closeparen);

  List<Token> groupBraces() => _groupBy(TokenType.openbrace, TokenType.closebrace);

  Token next() {
    return tokens.removeAt(0);
  }

  Token peek() {
    return tokens[0];
  }

  bool peekSequence(List<TokenType> expectedTypes) {
    int index = 0;
    while (index < expectedTypes.length) {
      if(index == tokens.length) {
        return false;
      }
      if(tokens[index].type != expectedTypes[index]) {
        return false;
      }
      index++;
    }
    return true;
  }

  Token expect(TokenType type) {
    Token token = next();
    if(token.type != type) {
      throw UnexpectedToken(token, type);
    }
    return token;
  }

  List<String> parseBlockArgs() {
    List<String> ret = [];
    if(tokens.length > 0) {
      ret.add(expect(TokenType.identifier).string);
      while(tokens.length > 0) {
        expect(TokenType.comma);
        ret.add(expect(TokenType.identifier).string);
      }
    }
    return ret;
  }

  List<Action> parseArguments() {
    List<Action> ret = [];
    if(tokens.length > 0) {
      ret.add(parseObject());
      while(tokens.length > 0) {
        expect(TokenType.comma);
        ret.add(parseObject());
      }
    }
    return ret;
  }

  List<Action> parseProgram() {
    List<Action> ret = [];
    if(tokens.length == 0) {
      return ret;
    }
    while(tokens.length > 1) {
      ret.add(parseAction());
      expect(TokenType.semi);
    }
    if(tokens.length == 1) {
      if(peek().type != TokenType.eof) {
        throw UnexpectedToken(peek(), TokenType.eof);
      } 
    }
    return ret;
  }

  Action parseAction() {
    Action ret = parseObject();
    ret = parseActionInternal(ret);
    return ret;
  }

  Action parseObject() {
    Action ret = parseBase();
    Action? object = parseExtension(ret);
    while(object != null) {
      ret = object;
      object = parseExtension(object);
    }
    return ret;
  }

  Action parseActionInternal(Action object) {
    if(tokens.length == 0) {
      return object;
    }
    switch(peek().type) {
      case TokenType.equal: {
        int line = next().line;
        Action value = parseObject();
        return ActionAssign(object, value, line);
      }
      case TokenType.qmark: {
        int line = next().line;
        Action ifTrue = parseObject();
        expect(TokenType.colon);
        Action ifFalse = parseObject();
        return ActionTernary(object, ifTrue, ifFalse, line);
      }
      default: {
        return object;
      }
    }
  }

  Action parseBase() {
    switch(peek().type) {
      case TokenType.not: {
        int line = next().line;
        Action object = parseObject();
        Action access = ActionAccess(object, "not", line);
        return ActionExecute(access, [], line);
      }
      case TokenType.openbrace: {
        int line = peek().line;
        List<Token> code = groupBraces();
        List<Action> actions = Parser(code).parseProgram();
        return ActionBlock(actions, [], line);
      }
      case TokenType.openparen: {
        Parser content = Parser(groupParentheses());
        //it is a list of block arguments if its a colon, otherwise just parentheses around a object
        if(peek().type == TokenType.colon) { 
          int line = next().line;
          Parser codeParser = Parser(groupBraces());
          List<String> arguments = content.parseBlockArgs();
          List<Action> code = codeParser.parseProgram();
          return ActionBlock(code, arguments, line);
        }
        Action internal = content.parseAction();
        if(content.tokens.length != 0) {
          content.expect(TokenType.closeparen);
        }
        return internal;
      }
      
      case TokenType.number: {
        Token token = next();
        String str = token.string;
        int line = token.line;
        if(peekSequence([TokenType.dot, TokenType.number])) {
          next();
          str += '.' + next().string;
          double number = double.parse(str);
          return ActionConstant(PrimitiveNum(number), line);
        }
        int number = int.parse(str);
        return ActionConstant(PrimitiveNum(number), line);
      }
      case TokenType.string: {
        Token token = next();
        return ActionConstant(PrimitiveString(token.string), token.line);
      }
      case TokenType.boolean: {
        Token token = next();
        return ActionConstant(PrimitiveBool(token.string == 'true'), token.line);
      }
      case TokenType.identifier: {
        Token token = next();
        return ActionIdentifier(token.string, token.line);
      }
      default: {
        throw UnexpectedToken(peek());
      }
    }
  }

  Action? parseExtension(Action base) {
    if(tokens.length == 0) {
      return null;
    }
    switch(peek().type) {
      case TokenType.dot: {
        int line = next().line;
        Token identifier = expect(TokenType.identifier);
        return ActionAccess(base, identifier.string, line);
      }
      case TokenType.op: {
        Token op = next();
        Action argument = parseObject();
        Action access = ActionAccess(base, Token.operatorMap[op.string]!, op.line);
        return ActionExecute(access, [argument], op.line);
      }
      case TokenType.openparen: {
        int line = peek().line;
        Parser argparser = Parser(groupParentheses());
        List<Action> arguments = argparser.parseArguments();
        return ActionExecute(base, arguments, line);
      }
      default: {
        return null;
      }
    }
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