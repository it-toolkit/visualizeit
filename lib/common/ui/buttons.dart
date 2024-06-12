import 'package:flutter/material.dart';

final class Buttons {

  Buttons._();

  static Widget simple(String text, { void Function()? action = null }) {
    return TextButton(onPressed: action, child: Text(text));
  }

  static Widget icon(IconData icon, String tooltip, { void Function()? action = null }) {
    return IconButton(onPressed: action, tooltip: tooltip, icon: Icon(icon));
  }

  static Widget highlighted(String text, { void Function()? action = null }) {
    return ElevatedButton(onPressed: action, child: Text(text));
  }
}