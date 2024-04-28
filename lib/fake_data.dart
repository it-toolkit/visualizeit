import 'package:visualizeit/common/utils/extensions.dart';

import 'extension/ui/extension_page.dart';

const fakeScriptNames = [
  "B# Tree values manipulation",
  "B# Tree underflow",
  "B# Tree overflow",
  "Merge sort",
];

const fakeSelectedScriptId = "0";

final fakeSelectedScriptDetails = """
  ## B# Tree values manipulation
  This script creates B# trees and perform some operations on it.
  """
    .trimIndent();

const fakeSelectedTags = ["database"];

const fakeScenes = [
  'Add some sequential\nvalues',
  'Delete some random\nvalues',
  'Add some random\nvalues',
];

final fakeSceneScriptExample = """
      fixture
          btree TD
      transitions
          add 1
          add 2
          add 3
      """
    .trimIndent();

final fakeFullScriptExample = """
      name [${fakeScriptNames[0]}]
      details [[[
        ## B# Tree values manipulation
        This script creates B# trees and perform some operations on it.
      ]]]
      tags: data-structure
      scene 1
          description [${fakeScenes[0]}]
          fixture
              btree TD
          transitions
              add 1
              add 2
              add 3
              
      scene 2
          description [${fakeScenes[1]}]
          fixture
              btree TD
              values 1, 2, 3, 4, 5, 6, 7, 8, 9
          transitions
              delete 2
              delete 5
              delete 7
              
      scene 3
          description [${fakeScenes[2]}]
          fixture
              btree TD
          transitions
              add 1
              add 7
              add 2 
              add 23
      """
    .trimIndent();

final fakeExtensions = [
  Extension('B# Tree', "B# Tree implementation for academic purposes"),
  Extension('Flow diagram', "Flow diagram implementation supporting partial Mermaid syntax"),
  Extension('Merge Sort', "Merge Sort implementation for academic purposes"),
];

const validRawScriptYaml = """
      name: "Script example"
      description: |-
        ## Example of flow diagram usage
        
        This script builds a simple flow diagram and adds some components 
      tags: [data-structure, example]
      scenes:
        - name: Scene name
          extensions: []
          description: Initial scene description
          initial-state:
            - background: ["https://images.pexels.com/photos/159627/pencils-clips-colour-pencils-foam-rubber-159627.jpeg", cover]
          transitions:
            - show-banner: 
              - |-  
                 "# Banner at center position
                 
                 
                 ![Argentina](https://pbs.twimg.com/profile_banners/507419507/1705687945/1500x500)
                 
                 
                 with image and with **multiple** lines
                 
                 
                 markdown format"
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
                 # Final pop up
                 
                 with **multiple** lines
                 
                 
                 and markdown format
            - nop
            - background: ["https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Thats_all_folks.svg/1589px-Thats_all_folks.svg.png?20150104034840", fill]
    """;