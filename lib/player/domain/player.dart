

import 'package:visualizeit_extensions/common.dart';

class Player {

  Model _buildInitialState(List<Command> commands) {

    Map<String, Model> models = commands.fold(<String, Model>{}, (models, command) {
      if (command is ModelBuilderCommand) {
        Model model = command();
        models[model.name] = model;
      } else if (command is ModelCommand) {
        var model = models[command.modelName];
        if (model == null) throw Exception("Unknown model: ${command.modelName}"); //TODO define custom exception for linter

        command(model);
      } else if (command is GlobalCommand) {
        command();
      } else {
        throw Exception("Unknown command: $command"); //TODO define custom exception for linter
      }

      return models;
    });

    switch(models.length){
      case 0: return NoModel();
      case 1: return models.values.single;
      default: throw UnimplementedError("Multiple model support");
    }
  }
}

class NoModel extends Model {
  static final NoModel _singleton = NoModel._internal();

  factory NoModel() {
    return _singleton;
  }

  NoModel._internal() : super("NoModel");

  @override
  void apply(Command command) {}
}