import 'package:visualizeit/plugins/model.dart';

class Tree extends Model{
  Tree();

  //Por cada metodo del modelo tiene que haber una combinación metodo + function estatica que aplica esa funcion 
  //(esto puede hacerse en menos lineas, seguro)
  static Function addMethod(Tree tree){
    return (tree) => tree.add(tree);
  }

  Tree add(Tree tree){
    return Tree();
  }
  //
}