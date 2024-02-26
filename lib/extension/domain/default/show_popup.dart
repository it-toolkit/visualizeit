import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/logging.dart';

import 'default_extension.dart';

final _logger = Logger("extension.default.popup");

class ShowPopup extends GlobalCommand {

  final String message;

  ShowPopup.build(List<String> args) : message = args.single;

  @override
  Result call(Model model) {
    var popupMessage = PopupMessage(message: message);
    (model as GlobalModel).pushGlobalStateUpdate(popupMessage);

    _logger.trace(() => "ShowPopup call pushed global state update: $PopupMessage");

    return Result(model: model);
  }
}
