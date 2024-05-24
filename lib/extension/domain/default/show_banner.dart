
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/logging.dart';
import 'package:visualizeit_extensions/scripting.dart';

import 'default_extension.dart';

final _logger = Logger("extension.default.banner");

class BannerModel extends Model with CommandExecutionAware {
  final String message;
  final String alignment;
  final bool freeSize = false;

  BannerModel(name, this.message, {this.alignment = "center"}): super(DefaultExtensionConsts.Id, name);

  @override
  BannerModel clone() {
    return BannerModel(name, message, alignment: alignment)
      ..withCommandExecutionStateFrom(this);
  }

  @override
  String toString() {
    return "BannerModel($message, $alignment, $pendingFrames)";
  }
}

class ShowBanner extends GlobalCommand {
  static final commandDefinition = CommandDefinition(DefaultExtensionConsts.Id, "show-banner", [CommandArgDef("message", ArgType.string), CommandArgDef("position", ArgType.string), CommandArgDef("duration", ArgType.int)]);

  final String alignment;
  final int framesDuration;
  final String message;
  final String bannerModelName = "${new DateTime.now().millisecondsSinceEpoch}"; //TODO usar uuid

  ShowBanner.build(RawCommand rawCommand) :
    message = commandDefinition.getArg(name: "message", from: rawCommand),
    alignment = commandDefinition.getArg(name: "position", from: rawCommand),
    framesDuration = commandDefinition.getArg(name: "duration", from: rawCommand);

  @override
  String toString() {
    return 'ShowBanner{framesDuration: $framesDuration, alignment: $alignment, message: ${message.cap(30)}}';
  }

  @override
  Result call(Model model, CommandContext context) {
    final globalModel = (model as GlobalModel).clone(); //TODO fail if cannot cast
    final bannerModel = (
        globalModel.models[bannerModelName]
        ?? BannerModel(bannerModelName, message, alignment: alignment).withFramesDuration(framesDuration + 1) //Add extra frame for model disposal
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
