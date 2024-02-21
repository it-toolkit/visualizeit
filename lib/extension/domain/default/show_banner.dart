
import 'package:visualizeit_extensions/common.dart';

const showBannerModelName = "default.show_banner";

class ShowBannerModel extends Model {
  final String message;
  final String alignment;
  final int framesDuration;

  ShowBannerModel(this.message, this.alignment, this.framesDuration): super("$showBannerModelName.${uniqueSuffix()}");

  static int uniqueSuffix() => DateTime.timestamp().millisecondsSinceEpoch;

  @override
  void apply(Command command) {}
}

class ShowBanner extends ModelBuilderCommand {

  final String message;
  final String alignment;
  final int framesDuration;

  ShowBanner.build(List<String> args) : message = args[0], alignment = args[1], framesDuration = int.parse(args[2]); //TODO validate int

  @override
  Model call() {
    return ShowBannerModel(message, alignment, framesDuration);
  }
}
