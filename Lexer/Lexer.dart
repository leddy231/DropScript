
import 'Tokens.dart';

class Lexer {
  List<Token> lex(Iterator<String> input) {
    int line = 0;
    List<Token> tokens = [];
    while (input.moveNext()) {
      String currentLine = input.current.trim();
      line++;
      while(currentLine.length > 0) {
        bool found = false;
        currentLine = currentLine.trimLeft();
        for (MapEntry entry in Token.regexMap.entries) {
          TokenType type = entry.key;
          RegExp pattern = entry.value;
          if(currentLine.startsWith(pattern)) {
            found = true;
            currentLine = currentLine.replaceFirstMapped(pattern, (match){
              String matched = match.group(0)!.replaceAll('"', '');
              tokens.add(Token(type, matched, line));
              return '';
            });
            break;
          }
        }
        if(!found) {
          throw('Unknown token: ${currentLine} at line ${line}');
        }
      }
    }
    tokens.add(Token(TokenType.eof, 'EOF', line));
    return tokens;
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