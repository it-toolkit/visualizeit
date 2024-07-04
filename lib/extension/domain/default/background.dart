
import 'package:flutter/material.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/logging.dart';
import 'package:visualizeit_extensions/scripting.dart';
import 'package:visualizeit_extensions/scripting_extensions.dart';

import 'default_extension.dart';

final _logger = Logger("extension.default.background");

class BackgroundModel extends Model {
  final String imageUrl;
  final BoxFit scaling;

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
  static final commandDefinition = CommandDefinition(
      DefaultExtensionConsts.Id,
      "background",
      [CommandArgDef("imageUrl", ArgType.string), CommandArgDef("scaling", ArgType.string)]
  );

  final String imageUrl;
  final BoxFit scaling;
  final String backgroundModelName = "default.background";

  ShowBackground.build(RawCommand rawCommand):
    imageUrl = commandDefinition.getArg(name: "imageUrl", from: rawCommand),
    scaling = commandDefinition.getBoxFitArg(name: "scaling", from: rawCommand);

  @override
  String toString() {
    return 'ShowBackground{imageUrl: $imageUrl, scaling: $scaling}';
  }

  @override
  Result call(Model model, CommandContext context) {
    final globalModel = (model as GlobalModel).clone();
    final backgroundModel = BackgroundModel(backgroundModelName, imageUrl, scaling);

    Result result = Result(model: globalModel);
    globalModel.models[backgroundModelName] = backgroundModel;

    _logger.trace(() => "ShowBackground call result: $result");
    return result;
  }
}
