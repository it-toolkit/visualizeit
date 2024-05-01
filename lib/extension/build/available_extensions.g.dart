import 'package:visualizeit_extension_template/visualizeit_extension_template.dart';
import 'package:visualizeit/extension/domain/default/default_extension.dart';
import 'package:visualizeit_extensions/extension.dart';


List<Extension> buildAllAvailableExtensions() {
	return [
		FakeExtensionBuilder().build(),
		DefaultExtensionBuilder().build(),
	];
}