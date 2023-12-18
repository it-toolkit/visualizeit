import 'package:flutter/material.dart';

class ScriptViewWidget extends StatelessWidget {
  const ScriptViewWidget({super.key, required this.script});

  final String script;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(171, 197, 212, 0.3),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Text(script),
        ),
      ),
    );
  }
}
