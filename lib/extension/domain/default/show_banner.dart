
import 'package:uuid/uuid.dart';
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/logging.dart';
import 'package:visualizeit_extensions/scripting.dart';

import 'default_extension.dart';

final _logger = Logger("extension.default.banner");

class BannerModel extends Model with CommandExecutionAware {
  final String message;
  final String alignment;
  final bool adjustSize;

  BannerModel(name, this.message, {this.alignment = "center", this.adjustSize = false}): super(DefaultExtensionConsts.Id, name);

  @override
  BannerModel clone() {
    return BannerModel(name, message, alignment: alignment, adjustSize: adjustSize)
      ..withCommandExecutionStateFrom(this);
  }

  @override
  String toString() {
    return "BannerModel(${message.cap(30, addRealLengthSuffix: true)}, $alignment, $pendingFrames, $adjustSize)";
  }
}

class ShowBanner extends GlobalCommand {
  static final commandDefinition = CommandDefinition(DefaultExtensionConsts.Id, "show-banner",
      [
        CommandArgDef("message", ArgType.string),
        CommandArgDef("position", ArgType.string, required: false, defaultValue: "center"),
        CommandArgDef("duration", ArgType.int, required: false, defaultValue: "1"),
        CommandArgDef("adjustSize", ArgType.boolean, required: false, defaultValue: "false"),
      ]
  );

  final String alignment;
  final int framesDuration;
  final String message;
  final bool adjustSize;
  final String bannerModelName;

  ShowBanner.build(RawCommand rawCommand) :
    bannerModelName = Uuid().v4(),
    message = commandDefinition.getArg(name: "message", from: rawCommand),
    alignment = commandDefinition.getArg(name: "position", from: rawCommand),
    framesDuration = commandDefinition.getArg(name: "duration", from: rawCommand),
    adjustSize = commandDefinition.getArg(name: "adjustSize", from: rawCommand);

  @override
  String toString() {
    return 'ShowBanner{framesDuration: $framesDuration, alignment: $alignment, adjustSize: $adjustSize, message: ${message.cap(30, addRealLengthSuffix: true)}}';
  }

  @override
  Result call(Model model, CommandContext context) {
    final globalModel = (model as GlobalModel).clone();
    final bannerModel = (
        globalModel.models[bannerModelName]
        ?? BannerModel(bannerModelName, message, alignment: alignment, adjustSize: adjustSize).withFramesDuration(framesDuration + 1) //Add extra frame for model disposal
    ) as BannerModel;

    Result result;

    if (bannerModel.pendingFrames > 1) {
      var updatedModel = bannerModel.clone()
        ..consumePendingFrame(context);

      globalModel.models[bannerModelName] = updatedModel;
      result = Result(model: globalModel, finished: false);
    }
    else { //Use last frame for model disposal
      globalModel.models.remove(bannerModelName);
      result = Result(model: globalModel, finished: true); //Return null model to force deletion
    }

    _logger.trace(() => "ShowBanner call result: $result");
    return result;
  }
}
