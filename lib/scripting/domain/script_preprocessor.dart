
import 'dart:math';

import 'package:visualizeit/scripting/domain/script_repository.dart';

class RawScriptPreprocessor {
  static final PreprocessorDirectivesHints = const ["_int_array_xxx_"];


  RawScript? preProcess(RawScript rawScript){
    final placeholderRegexp = RegExp(r'_int_array_(\d{1,3})_');
    var rng = Random();
    var contentAsYaml = rawScript.contentAsYaml;
    var match = placeholderRegexp.firstMatch(rawScript.contentAsYaml);

    while (match != null) {
      final arraySize = int.parse(match.group(1)!);
      final maxInt = arraySize * 10;
      Set<int> randomValues = Set<int>();
      while (randomValues.length < arraySize) {
        randomValues.add(rng.nextInt(maxInt));
      }

      contentAsYaml = contentAsYaml.replaceAll(placeholderRegexp, "[${randomValues.join(", ")}]");

      match = placeholderRegexp.firstMatch(contentAsYaml);
    }

    if (contentAsYaml != rawScript.contentAsYaml) return rawScript.copyWith(contentAsYaml: contentAsYaml);
    else return null;
  }
}