
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/logging.dart';

import 'default_extension.dart';

final _logger = Logger("extension.default.banner");

class BannerModel extends Model with CommandExecutionAware {
  final String message;
  final String alignment;
  final int pendingFrames;
  final bool freeSize = false;

  BannerModel(name, this.message, {this.alignment = "center", this.pendingFrames = 1}): super(DefaultExtensionConsts.Id, name);

  @override
  Model clone() {
    return BannerModel(name, message, alignment: alignment, pendingFrames: pendingFrames);
  }

  BannerModel copy(String alignment, int framesDuration, Duration timeFrame)
    => BannerModel(name, message, alignment: alignment, pendingFrames: framesDuration)..timeFrame = timeFrame;

  @override
  String toString() {
    return "BannerModel($message, $alignment, $pendingFrames)";
  }
}

class ShowBanner extends GlobalCommand {

  final String alignment;
  final int framesDuration;
  final String message;
  final String bannerModelName = "${new DateTime.now().millisecondsSinceEpoch}"; //TODO usar uuid

  ShowBanner.build(List<String> args) : message = args[0], alignment = args[1], framesDuration = int.parse(args[2]);

  @override
  String toString() {
    return 'ShowBanner{framesDuration: $framesDuration, alignment: $alignment, message: ${message.cap(30)}}';
  }

  @override
  Result call(Model model, CommandContext context) {
    final globalModel = (model as GlobalModel).clone(); //TODO fail if cannot cast
    final bannerModel = globalModel.models[bannerModelName] as BannerModel? ?? BannerModel(bannerModelName, message, pendingFrames: framesDuration);

    Result result;
    if (bannerModel.pendingFrames > 0){
      var nextFrameDuration = bannerModel.pendingFrames - 1;
      globalModel.models[bannerModelName] = bannerModel.copy(alignment, nextFrameDuration, context.timeFrame);
      result = Result(model: globalModel, finished: nextFrameDuration < 0);
    }
    else {
      globalModel.models.remove(bannerModelName);
      result = Result(model: globalModel, finished: true); //Return null model to force deletion
    }

    _logger.trace(() => "ShowBanner call result: $result");
    return result;
  }
}
