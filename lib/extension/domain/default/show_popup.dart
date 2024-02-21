import 'package:visualizeit_extensions/common.dart';

import 'default_extension.dart';

class ShowPopup extends GlobalCommand {

  final String message;

  ShowPopup.build(List<String> args) : message = args.single;

  @override
  void call(Model model) {
    (model as GlobalModel).pushGlobalStateUpdate(PopupMessage(message: message));
  }
}
