
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/logging.dart';

import 'default_extension.dart';

const showBannerModelName = "default.show_banner";
final _logger = Logger("extension.default.banner");

class BannerModel extends Model {
  final String message;
  final String alignment;
  final int framesDuration;

  BannerModel(name, this.message, {this.alignment = "center", this.framesDuration = 1}): super(DefaultExtensionConsts.Id, name);

  BannerModel copy(String alignment, int framesDuration)
    => BannerModel(name, message, alignment: alignment, framesDuration: framesDuration);

  @override
  String toString() {
    return "BannerModel($message, $alignment, $framesDuration)";
  }
}

class CreateBanner extends ModelBuilderCommand {
  final String name;
  final String message;

  CreateBanner.build(List<String> args) : name = args[0], message = args[1];

  @override
  Model call() {
    var bannerModel = BannerModel(name, message);

    _logger.trace(() => "CreateBanner call result: $bannerModel");
    return bannerModel;
  }
}

class ShowBanner extends ModelCommand {

  final String alignment;
  final int framesDuration;

  ShowBanner.build(List<String> args) : alignment = args[1], framesDuration = int.parse(args[2]), super(args[0]); //TODO validate int

  @override
  Result call(Model model) {
    model as BannerModel; //TODO fail if cannot cast
    Result result;
    if (framesDuration > 0 && model.framesDuration == 0) {
      var nextFrameDuration = framesDuration - 1;
      result = Result(model: model.copy(alignment, nextFrameDuration), finished: nextFrameDuration <= 0);
    }
    else if (model.framesDuration > 0){
      var nextFrameDuration = model.framesDuration - 1;
      result = Result(model: model.copy(alignment, nextFrameDuration), finished: nextFrameDuration <= 0);
    }
    else {
      result = Result(model: model);
    }

    _logger.trace(() => "ShowBanner call result: $result");
    return result;
  }
}
