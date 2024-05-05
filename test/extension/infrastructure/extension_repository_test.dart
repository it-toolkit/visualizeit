

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:visualizeit/extension/domain/default/default_extension.dart';
import 'package:visualizeit/extension/domain/extension_repository.dart';
import 'package:visualizeit/extension/infrastructure/extension_repository.dart';
import 'package:visualizeit_extensions/extension.dart';

class ExtensionMock extends Mock implements Extension {}

void main() {
  test('No extension return when empty repository', () {
    var repository = DefaultExtensionRepository();

    expect(repository.getAll().length, equals(0));
  });

  test('When try to get unknown extension exception is thrown', () {
    var repository = DefaultExtensionRepository();

    expect(() => repository.getById("unknown"), throwsA(isA<ExtensionNotFoundException>()));
  });

  test('When try to get a known extension then returns it', () {
    var extensionMock = ExtensionMock();
    when(() => extensionMock.extensionId).thenReturn("known");
    var repository = DefaultExtensionRepository(extensions: [extensionMock]);

    expect(repository.getById("known"), equals(extensionMock));
    expect(repository.getAll().length, equals(1));
  });

  test('Default extension is included in available extensions', () async {
    var repository = await DefaultExtensionRepository.withAvailableExtensions();

    expect(repository.getAll().length, greaterThanOrEqualTo(1));
    expect(repository.getById(DefaultExtensionConsts.Id), isA<Extension>());
  });
}