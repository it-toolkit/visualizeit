import 'package:visualizeit_bsharptree_extension/extension/bsharp_tree_extension.dart';
import 'package:visualizeit_extension_template/visualizeit_extension_template.dart';
import 'package:visualizeit_external_sort_extension/extension/external_sort_extension.dart';
import 'package:visualizeit_slides_extension/visualizeit_slides_extension.dart';
import 'package:visualizeit/extension/domain/default/default_extension.dart';
import 'package:visualizeit_extensions/extension.dart';

List<Future<Extension>> buildAllAvailableExtensions() {
  return [
    FakeExtensionBuilder().build(),
    DefaultExtensionBuilder().build(),
    SlidesExtensionBuilder().build(),
    BSharpTreeExtensionBuilder().build(),
    ExternalSortExtensionBuilder().build()
  ];
}
