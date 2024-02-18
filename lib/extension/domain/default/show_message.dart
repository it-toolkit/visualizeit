import 'package:visualizeit_extensions/common.dart';

import 'default_extension.dart';

class ShowMessage extends GlobalCommand {

  final String message;

  ShowMessage.build(List<String> args) : message = args.single;

  @override
  void call(Model model) {
    (model as GlobalModel).pushGlobalStateUpdate(MessageDialog(message: message));
  }
}
