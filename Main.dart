
import 'Interpreter/Interpreter.dart';
import 'Interpreter/Context.dart';
import 'Interpreter/StandardLibrary.dart';
main(List<String> args) async {
  List<String> files = [];
  Set<String> flags = {};
  for(String arg in args) {
    if (arg.startsWith('-')){
      arg.replaceAll('-', '');
      for(String char in arg.split('')) {
        flags.add(char);
      }
    } else {
      files.add(arg);
    }
  }
  if(files.length == 0) {
    print("No file specified");
    return;
  }
  Context context = Context();
  await StandardLibrary.addStandardLibrary(context);
  await Interpreter.interpretFile(files[0], context, 
    printLines:   flags.contains('l'), 
    printActions: flags.contains('a'), 
    printTokens:  flags.contains('t'), 
    printGraph:   flags.contains('g'));
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