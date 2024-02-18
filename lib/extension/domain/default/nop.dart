import 'package:visualizeit_extensions/common.dart';

import 'default_extension.dart';

class NoOp extends GlobalCommand {

  NoOp.build();

  @override
  void call(Model model) {
    print("No op");// TODO: implement call
  }
}