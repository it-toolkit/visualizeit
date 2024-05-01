import 'package:visualizeit/extension/domain/default/default_extension.dart';
import 'package:visualizeit_extensions/extension.dart';


List<Extension> buildAllAvailableExtensions() {
	return [
		DefaultExtensionBuilder().build(),
	];
}