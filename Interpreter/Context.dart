import 'Primitives.dart';

class Context {
  final Context? parent;
  final Map<String, Primitive> variables = {};
  Context([this.parent = null]);

  Context subContext() {
    return Context(this);
  }

  bool lookupLocal(String key) {
    return variables.containsKey(key);
  }

  bool lookup(String key) {
    bool exists = lookupLocal(key);
    if (!exists) {
      exists = parent?.lookup(key) ?? false;
    }
    return exists;
  }

  Primitive? getLocal(String key) {
    return variables[key];
  }

  Primitive get(String key) {
    Primitive? ret = variables[key];
    if(ret == null) {
      ret = parent?.get(key);
    }
    if(ret == null) {
      throw("\"${key}\" does not exist");
    }
    return ret;
  }

  void setLocal(String key, Primitive value) {
    variables[key] = value;
  }

  void set(String key, Primitive value) {
    if(lookupLocal(key)) {
      variables[key] = value;
    } else if (parent?.lookup(key) ?? false) {
      parent?.set(key, value);
    } else {
      variables[key] = value;
    }
  }

  String toString() => variables.toString();
  String toCode() => variables.toString();
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