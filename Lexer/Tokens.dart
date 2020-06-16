enum TokenType {
  equal,
  semi,
  comma,
  not,
  qmark,
  colon,
  dot,
  closebrace,
  openbrace,
  closeparen,
  openparen,
  identifier,
  number,
  string,
  boolean,
  op,
  ret,
  eof
}

class Token {
  static final Map<String, String> operatorMap = {
    '^'   :'pow',
    '+'   :'add',
    '-'   :'sub',
    '/'   :'div',
    '*'   :'mul',
    '%'   :'mod',
    '&&'  :'and',
    '||'  :'or',
    '<=>' :'compare',
    '=='  :'equal',
    '<='  :'lesserEqual',
    '>='  :'greaterEqual',
    '<'   :'lesser',
    '>'   :'greater',
    '!='  :'notEqual',
    '><'  :'includes',
    '<>'  :'excludes',
    '<<'  :'append',
    '..'  :'range',
  };
  static final Map<TokenType, RegExp> regexMap = {
    TokenType.semi:RegExp(r';'),
    TokenType.comma:RegExp(r','),
    TokenType.qmark:RegExp(r'\?'),
    TokenType.colon:RegExp(r':'),
    TokenType.closebrace:RegExp(r'\}'),
    TokenType.openbrace:RegExp(r'\{'),
    TokenType.closeparen:RegExp(r'\)'),
    TokenType.openparen:RegExp(r'\('),
    TokenType.number:RegExp(r'\d+'),
    TokenType.string:RegExp(r'\".*?\"'),
    TokenType.boolean:RegExp(r'(true|false)(?!\w)'),
    TokenType.op:RegExp(r'==|&&|\|\||>=|<=|!=|\.\.|<>|><|<<|\+|-|\*|\/|\^|%|>|<'),
    TokenType.dot:RegExp(r'\.'),
    TokenType.equal:RegExp(r'='),
    TokenType.not:RegExp(r'!'),
    TokenType.identifier:RegExp(r'[a-zA_Z]\w*')
  };

  final TokenType type;
  final String string;
  final int line;
  Token(this.type, this.string, this.line);

  String toString() {
    return string;
  }

  String toCode() {
    return "${type}<${string}>";
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