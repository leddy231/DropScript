import 'Context.dart';
import 'Interpreter.dart';
import 'Primitives.dart';
import 'dart:io';

class StandardLibrary {
  static String dirname = File(Platform.script.toFilePath()).parent.path;
  static Future<void> addStandardLibrary(Context context) async {
    bool success = await Interpreter.interpretFile(dirname + '/Interpreter/StandardLibrary.ds', context);
    if(!success) {
      throw("Error parsing standard library");
    }
    context.set('print', PrimitiveBlockSpecial(1, (Context ctx, List<Primitive> args) {
      Primitive arg = args[0];
      print(arg.toCode());
      return arg;
    }));
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