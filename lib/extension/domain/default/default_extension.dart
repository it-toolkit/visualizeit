

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/extension.dart';
import 'package:visualizeit_extensions/logging.dart';
import 'package:visualizeit_extensions/scripting.dart';
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


class _DefaultExtensionComponents extends DefaultScriptingExtension implements ScriptingExtension, VisualizerExtension {

  _DefaultExtensionComponents(): super({
    ShowPopup.commandDefinition: ShowPopup.build,
    ShowBackground.commandDefinition: ShowBackground.build,
    ShowBanner.commandDefinition: ShowBanner.build,
    NoOp.commandDefinition: NoOp.build
  });

  @override
  Widget? render(Model model, BuildContext context) {
    switch (model.name) {
      default:
        if (model is GlobalModel) {
          return Stack(fit: StackFit.expand, children: model.models.values.map((innerModel) {
            if (innerModel is BannerModel) return buildBannerWidget(innerModel);
            else if (innerModel is BackgroundModel) return buildBackgroundWidget(innerModel);
            else return null;
          }).nonNulls.toList());
        }

        return null;
    }
  }

  Widget buildBannerWidget(BannerModel innerModel) {
    _logger.trace(() => "Building widget for: ${innerModel.toString()}");

    return BannerWidget(innerModel);
  }

  Widget buildBackgroundWidget(BackgroundModel innerModel) {
    _logger.trace(() => "Building widget for: ${innerModel.toString()}");

    return Image.network(
      innerModel.imageUrl,
      fit: parseImageBoxFit(innerModel.scaling)
    );
  }

  BoxFit parseImageBoxFit(String boxFit) {
    switch(boxFit) {
      case "fill": return BoxFit.fill;
      case "contain": return BoxFit.contain;
      case "cover": return BoxFit.cover;
      default: throw Exception("Unknown image scaling strategy value"); //TODO handle error properly
    }
  }

  Alignment parseAlignment(String alignment) {
    switch(alignment) {
      case "topLeft": return Alignment.topLeft;
      case "topCenter": return Alignment.topCenter;
      case "topRight": return Alignment.topRight;
      case "centerLeft": return Alignment.centerLeft;
      case "center": return Alignment.center;
      case "centerRight": return Alignment.centerRight;
      case "bottomLeft": return Alignment.bottomLeft;
      case "bottomCenter": return Alignment.bottomCenter;
      case "bottomRight": return Alignment.bottomRight;
      default: throw Exception("Unknown alignment value"); //TODO handle error properly
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
    final markdownDocs = {
      for (final languageCode in _availableDocsLanguages) languageCode : '$_docsLocationPath/$languageCode.md'
    };

    final component = _DefaultExtensionComponents();
    return Extension(DefaultExtensionConsts.Id, component, component, markdownDocs);
  }
}
