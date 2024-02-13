//import 'package:visualizeit/plugins/model.dart';
import 'package:visualizeit/plugins/model_plugin.dart';
//import 'package:visualizeit/plugins/model_syntax.dart';
import 'package:visualizeit/plugins/tree/tree.dart';

class TreePlugin implements ModelPlugin{
  
  @override
  Function createModel(){ //Este createModel podria tener una lista de parametros?
    return () => Tree();
  }

  //Aca deberia haber un metodo que retorne una funcion que devuelva 
  //una forma de parsear un string (transition) en un comando sobre un Tree
  //Se me ocurre que ese string puede ser un regex o algo asi, que permita 
  //ser evaluado para chequear la sintaxis en el script parser
  //Ej: Function getCommandForTransition(String transition)
  @override
  Function getCommandForTransition(String transition){
    return Tree.addMethod(Tree()); //Deberia recibir siempre el Model?
  }
}