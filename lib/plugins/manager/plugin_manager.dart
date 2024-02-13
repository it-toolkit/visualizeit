import 'package:visualizeit/plugins/model_plugin.dart';
import 'package:visualizeit/plugins/tree/tree_plugin.dart';

class PluginManager{

  //Acá deberiamos cargar la lista de plugins
  //final Map<String, ModelPlugin> installedPlugins=["tree", TreePlugin()];

  //Esto deberia tener un metodo que reciba un String y devuelva un Plugin
  static ModelPlugin? fromModuleName(String moduleName){
    switch (moduleName) {
      case "tree":
        return TreePlugin();
      
      default:
        return null; //Esto deberia tirar una excepcion
    }
  }
}