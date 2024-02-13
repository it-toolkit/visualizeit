abstract interface class ModelPlugin{
  Function createModel();
  Function getCommandForTransition(String transition);
}

