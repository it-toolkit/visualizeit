import 'package:test/test.dart';
import 'package:visualizeit/plugins/manager/plugin_manager.dart';
import 'package:visualizeit/plugins/tree/tree_plugin.dart';

void main(){

  group('When we fetch a tree plugin ', () {
    test('and it exists, it must be returned', () {
      var fromModuleName = PluginManager.fromModuleName("tree");
      expect(fromModuleName.runtimeType, TreePlugin);
    });

    test('and it doesnt exist, it must return null, ', () {
    var fromModuleName = PluginManager.fromModuleName("non existent plugin");
      expect(fromModuleName, null);
    });

  });
  
}