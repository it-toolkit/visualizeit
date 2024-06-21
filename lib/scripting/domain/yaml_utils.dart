import 'dart:convert';

import 'package:json2yaml/json2yaml.dart';
import 'package:yaml/yaml.dart';

abstract class YamlUtils {
  YamlUtils._();

  static dynamic _convertNode(dynamic v) {
    if (v is YamlMap) return unwrapScalarsInMap(v);
    else if (v is YamlList) return unwrapScalarsInList(v);
    else if (v is YamlScalar) return v.value;
    else return v;
  }

  static Map<String, dynamic> unwrapScalarsInMap(YamlMap yamlMap) {
    var map = <String, dynamic>{};
    yamlMap.nodes.forEach((k, v) {
      map[(k as YamlScalar).value.toString()] = _convertNode(v.value);
    });
    return map;
  }

  static List<dynamic> unwrapScalarsInList(YamlList yamlList) {
    var list = <dynamic>[];
    yamlList.forEach((e) { list.add(_convertNode(e)); });
    return list;
  }

  static String toFormattedYamlString(YamlNode node) {
    return json2yaml(json.decode(json.encode(node)));
  }
}