

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/extension.dart';
import 'package:visualizeit_extensions/logging.dart';
import 'package:visualizeit_extensions/visualizer.dart';

import 'background.dart';
import 'banner.dart';
import 'nop.dart';
import 'show_banner.dart';
import 'show_popup.dart';

final _logger = Logger("extension.default");

abstract class DefaultExtensionConsts {
  static const String Id = "default";
}


class _DefaultExtensionCore extends ExtensionCore {

  _DefaultExtensionCore(): super({
    ShowPopup.commandDefinition: ShowPopup.build,
    ShowBackground.commandDefinition: ShowBackground.build,
    ShowBanner.commandDefinition: ShowBanner.build,
    NoOp.commandDefinition: NoOp.build
  });

  @override
  Iterable<Widget> renderAll(Model model, BuildContext context) {
    switch (model.name) {
      default:
        if (model is GlobalModel) {
          return model.models.values.map((innerModel) {
            return switch (innerModel) {
              BannerModel innerModel => BannerWidget(innerModel),
              BackgroundModel innerModel => BackgroundWidget(innerModel),
              _ => null
            };
          }).nonNulls;
        }

        return [];
    }
  }
}


abstract class GlobalCommand extends ModelCommand {
  GlobalCommand() : super ("global");
}

abstract class GlobalStateUpdate{}

class PopupMessage extends GlobalStateUpdate {
  String? title;
  String message;

  PopupMessage({this.title, required this.message});

  @override
  String toString() {
    return 'PopupMessage{title: $title, message: ${message.cap(30, addRealLengthSuffix: true)}}';
  }
}

class BackgroundWidget extends StatelessWidget with RenderingPriority {

  final BackgroundModel model;

  BackgroundWidget(this.model) {
    initPriority(RenderingPriority.minPriority);
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
        model.imageUrl,
        fit: _parseImageBoxFit(model.scaling)
    );
  }

  BoxFit _parseImageBoxFit(String boxFit) {
    switch(boxFit) {
      case "fill": return BoxFit.fill;
      case "contain": return BoxFit.contain;
      case "cover": return BoxFit.cover;
      default: throw Exception("Unknown image scaling strategy value"); //TODO handle error properly, provide a custom exception to use
    }
  }
}

const globalModelName = "global";

class GlobalModel extends Model {

  GlobalModel() : super(DefaultExtensionConsts.Id, globalModelName);

  GlobalModel clone() {
    return GlobalModel()
     ..globalStateUpdates = Queue.from(this.globalStateUpdates)
     ..models = Map.from(this.models);
  }

  Queue<GlobalStateUpdate> globalStateUpdates = Queue();
  Map<String, Model> models = {};
  
  GlobalStateUpdate? takeNextGlobalStateUpdate() => globalStateUpdates.isNotEmpty ? globalStateUpdates.removeFirst() : null;

  void pushGlobalStateUpdate(GlobalStateUpdate globalStateUpdate) {
    globalStateUpdates.add(globalStateUpdate);
  }

  @override
  String toString() {
    return 'GlobalModel{globalStateUpdates: $globalStateUpdates, models: $models}';
  }
}


class DefaultExtensionBuilder implements ExtensionBuilder {
  static const _docsLocationPath = "assets/docs/default_extension";
  static const _availableDocsLanguages = [LanguageCodes.en];

  @override
  Future<Extension> build() async {
    _logger.trace(() => "Building extension: ${DefaultExtensionConsts.Id}");
    final markdownDocs = {
      for (final languageCode in _availableDocsLanguages) languageCode : '$_docsLocationPath/$languageCode.md'
    };

    return Extension.create(id: DefaultExtensionConsts.Id, markdownDocs: markdownDocs, extensionCore: _DefaultExtensionCore());
  }
}
