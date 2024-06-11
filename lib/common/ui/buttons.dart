import 'package:flutter/material.dart';

final class Buttons {

  Buttons._();

  static Widget simple(String text, { void Function()? action = null }) {
    return TextButton(onPressed: action, child: Text(text));
  }

  static Widget highlighted(String text, { void Function()? action = null }) {
    return ElevatedButton(onPressed: action, child: Text(text));
  }
}