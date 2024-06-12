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

  static Widget highlightedIcon(IconData icon, String tooltip, {void Function()? action = null}) {
    return IconButton(
        onPressed: action,
        tooltip: tooltip,
        icon: action != null
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.blue.shade300, blurRadius: 10.0)],
                ),
                child: Icon(icon),
              )
            : Icon(icon));
  }
}