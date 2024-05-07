
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/logging.dart';

import 'default_extension.dart';

final _logger = Logger("extension.default.background");

class BackgroundModel extends Model {
  final String imageUrl;
  final String scaling;

  BackgroundModel(name, this.imageUrl, this.scaling): super(DefaultExtensionConsts.Id, name);

  @override
  Model clone() {
    return BackgroundModel(name, imageUrl, scaling);
  }

  @override
  String toString() {
    return "BackgroundModel($imageUrl, $scaling)";
  }
}

class ShowBackground extends GlobalCommand {

  final String imageUrl;
  final String scaling;
  final String backgroundModelName = "default.background";

  ShowBackground.build(List<String> args) : imageUrl = args[0], scaling = args[1];

  @override
  String toString() {
    return 'ShowBackground{imageUrl: $imageUrl, scaling: $scaling}';
  }

  @override
  Result call(Model model, CommandContext context) {
    final globalModel = (model as GlobalModel).clone(); //TODO fail if cannot cast
    final backgroundModel = BackgroundModel(backgroundModelName, imageUrl, scaling);

    Result result = Result(model: globalModel);
    globalModel.models[backgroundModelName] = backgroundModel;

    _logger.trace(() => "ShowBackground call result: $result");
    return result;
  }
}
