import 'package:flutter/material.dart';
import 'package:visualizeit/scripting/domain/parser.dart';

class ScriptErrorWidget extends StatelessWidget {
  final ParserException? scriptErrors;

  ScriptErrorWidget(this.scriptErrors);

  @override
  Widget build(BuildContext context) {
    var errorMessages = scriptErrors?.errorMessages.map((e) => Text("\u{26A0} $e", softWrap: true)).toList() ?? [];
    return Stack(children: [
      Container(
        height: 80,
        padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
        decoration: BoxDecoration(
          color: Colors.red.shade200,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: ListView(children: errorMessages),
      ),
      buildHeader(errorMessages)
    ]);
  }

  Align buildHeader(List<Text> errorMessages) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 15, top: 5),
        child: Text(
          "${errorMessages.length} ${errorMessages.length == 1 ? 'error' : 'errors'} found",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
