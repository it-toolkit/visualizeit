import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/logging.dart';
import 'package:visualizeit_extensions/scripting.dart';

import 'default_extension.dart';

final _logger = Logger("extension.default.nop");

class NoOp extends GlobalCommand {
  static final commandDefinition = CommandDefinition(DefaultExtensionConsts.Id, "nop", []);


  NoOp.build();

  @override
  Result call(Model model, CommandContext context) {
    _logger.trace(() => "Call on No op command");

    return Result(model: model);
  }

  @override
  String toString() {
    return 'NoOp';
  }
}