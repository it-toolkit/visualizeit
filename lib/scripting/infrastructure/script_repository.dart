

import 'package:visualizeit/scripting/domain/script_repository.dart';

class FakeRawScriptRepository implements RawScriptRepository {

  RawScript findById(String id) {
    const validRawScriptYaml = """
      name: "Flow diagram example"
      description: |
        "## Example of flow diagram usage
        
        This script builds a simple flow diagram and adds some components" 
      tags: [data-structure, example]
      scenes:
        - name: Scene name
          extensions: []
          description: Initial scene description
          initial-state:
            - nop
          transitions:
            - show-banner: 
              - |  
                 "# Banner at center position
                 
                 with **multiple** lines
                 
                 
                 and markdown format"
              - center
              - 3
            - nop
            - show-banner: ["Banner at top position", topCenter, 3]
            - nop
            - show-banner: ["Banner at left position", centerLeft, 3]
            - nop
            - show-banner: ["Banner at right position", centerRight, 3]
            - nop
            - show-banner: ["Banner at bottom position", bottomCenter, 3]
            - nop
            - show-popup: "Showing a nice message"
            - nop
            - show-popup: |  
                 "# Final pop up
                 
                 with **multiple** lines
                 
                 
                 and markdown format"
            - nop
    """;

    return RawScript(validRawScriptYaml);
  }
}