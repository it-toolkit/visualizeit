
import 'package:visualizeit_extensions/common.dart';

const showBannerModelName = "default.show_banner";

class BannerModel extends Model {
  final String message;
  final String alignment;
  final int framesDuration;

  BannerModel(super.name, this.message, {this.alignment = "center", this.framesDuration = 1});

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
    return BannerModel(name, message);
  }
}

class ShowBanner extends ModelCommand {

  final String alignment;
  final int framesDuration;

  ShowBanner.build(List<String> args) : alignment = args[1], framesDuration = int.parse(args[2]), super(args[0]); //TODO validate int

  @override
  Result call(Model model) {
    model as BannerModel; //TODO fail if cannot cast
    if (framesDuration > 0 && model.framesDuration == 0) {
      var nextFrameDuration = framesDuration - 1;
      var result = Result(model: model.copy(alignment, nextFrameDuration), finished: nextFrameDuration <= 0);
      print("Call result: $result");
      return result;
    }
    else if (model.framesDuration > 0){
      var nextFrameDuration = model.framesDuration - 1;
      var result = Result(model: model.copy(alignment, nextFrameDuration), finished: nextFrameDuration <= 0);
      print("Call result: $result");
      return result;
    }
    else {
      print("Call result not touched");
      return Result(model: model);
    }
  }
}
