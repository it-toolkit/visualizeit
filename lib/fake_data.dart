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
