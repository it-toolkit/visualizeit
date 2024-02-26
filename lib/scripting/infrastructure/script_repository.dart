

import 'package:visualizeit/scripting/domain/script_repository.dart';

class FakeRawScriptRepository implements RawScriptRepository {

  RawScript findById(String id) {
    const validRawScriptYaml = """
      name: "Flow diagram example"
      description: |
        ## Example of flow diagram usage
        This script builds a simple flow diagram and adds some components 
      tags: [data-structure, example]
      scenes:
        - name: Scene name
          extensions: []
          description: Initial scene description
          initial-state:
            - banner: [A, "Banner text"]
            - show-banner: [A, center, 1]
          transitions:
            - nop
            - show-banner: [A, topCenter, 1]
            - nop
            - show-banner: [A, centerLeft, 4]
            - nop
            - show-banner: [A, centerRight, 4]
            - nop
            - show-banner: [A, bottomCenter, 1]
            - nop
            - show-popup: "Showing a nice message"
            - nop
            - show-popup: "Goodbye!"
            - nop
    """;

    return RawScript(validRawScriptYaml);
  }
}