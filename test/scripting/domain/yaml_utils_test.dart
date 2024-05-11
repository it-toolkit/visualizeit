import 'package:flutter_test/flutter_test.dart';
import 'package:visualizeit/scripting/domain/yaml_utils.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('unwrap scalars in map', () {
    final yamlNode = loadYaml("""
        - 1
        - 2.5
        - text
        - [ 'a', 'b', 3]
        """);

    final list = YamlUtils.unwrapScalarsInList(yamlNode);
    expect(list[0], equals(1));
    expect(list[1], equals(2.5));
    expect(list[2], equals("text"));
    expect(list[3], containsAll(['a', 'b', 3]));
  });

  test('unwrap scalars in map', () {
    final yamlNode = loadYaml("""
        a: 1
        b: 2.5
        c: text
        d: [ 'a', 'b', 3]
        """);

    final map = YamlUtils.unwrapScalarsInMap(yamlNode);
    expect(map['a'], equals(1));
    expect(map['b'], equals(2.5));
    expect(map['c'], equals("text"));
    expect(map['d'], containsAll(['a', 'b', 3]));
  });
}
