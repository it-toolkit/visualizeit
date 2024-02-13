import 'package:visualizeit/plugins/model.dart';
import 'package:visualizeit/plugins/tree/tree.dart';
import 'package:visualizeit/plugins/tree/tree_plugin.dart';
import 'package:test/test.dart';

void main(){
  test('The creation method must return an instance of a Model subclass', () {
      var creationFunction = TreePlugin().createModel();
      
      assert(creationFunction() is Model);
  });

  test('The creation method must return an instance of a Tree subclass', () {
      var creationFunction = TreePlugin().createModel();
      
      assert(creationFunction() is Tree);
  });

  /*test('When we want to apply a transition, it must return the function that applies that transition to the model', () {
      var transitionFunction = TreePlugin().getCommandForTransition("transition");
      
      assert(transitionFunction() is Function);
  });*/
}