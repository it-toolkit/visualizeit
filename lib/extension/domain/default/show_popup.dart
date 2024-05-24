import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/logging.dart';
import 'package:visualizeit_extensions/scripting.dart';

import 'default_extension.dart';

final _logger = Logger("extension.default.popup");

class ShowPopup extends GlobalCommand {
  static final commandDefinition = CommandDefinition(DefaultExtensionConsts.Id, "show-popup", [CommandArgDef("message", ArgType.string)]);
  final String message;

  ShowPopup.build(RawCommand rawCommand) : message = commandDefinition.getArg(name: "message", from: rawCommand);

  @override
  String toString() {
    return 'ShowPopup{message: ${message.cap(30, addRealLengthSuffix: true)}}';
  }

  @override
  Result call(Model model, CommandContext context) {
    var popupMessage = PopupMessage(message: message);
    (model as GlobalModel).pushGlobalStateUpdate(popupMessage);

    _logger.trace(() => "ShowPopup call pushed global state update: $PopupMessage");

    return Result(model: model);
  }
}
