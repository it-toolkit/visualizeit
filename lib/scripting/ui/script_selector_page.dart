import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:slugify/slugify.dart';
import 'package:uuid/uuid.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/common/ui/custom_bar_widget.dart';
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit/scripting/domain/script.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:collection/collection.dart';
import 'package:visualizeit/scripting/domain/searchable_list.dart';
import 'package:visualizeit_extensions/logging.dart';

import '../../common/markdown/markdown.dart';
import '../../common/ui/adaptive_container_widget.dart';
import '../../common/ui/buttons.dart';
import '../domain/script_def.dart';

final _logger = Logger("scripting.ui.script_selector_page");

class ScriptSelectorPage extends StatefulBasePage {
  static const RouteName = "script-selector";

  const ScriptSelectorPage(
      this._publicRawScriptRepository,
      this._myRawScriptRepository,
      {super.key, this.openScriptInPlayer, this.openScriptInEditor}
  ): super(RouteName);

  final Future<void> Function(String scriptRef, bool readonly)? openScriptInPlayer;
  final Future<void> Function(String scriptRef, bool readonly)? openScriptInEditor;
  final ScriptRepository _publicRawScriptRepository;
  final ScriptRepository _myRawScriptRepository;

  @override
  State<StatefulWidget> createState() {
    return _ScriptSelectorPageState();
  }
}

typedef _AvailableScript = Script;

class _ScriptSelectorPageState extends BasePageState<ScriptSelectorPage> with SingleTickerProviderStateMixin {
  final _uuid = Uuid();
  late TabController _tabController;

  static bool _queryByGroupOrName(String query, _AvailableScript availableScript) {
      final lowerCaseQuery = query.toLowerCase();
      final scriptMetadata = availableScript.metadata;
      return (scriptMetadata.group?.toLowerCase().contains(lowerCaseQuery) ?? false)
          || scriptMetadata.name.toLowerCase().contains(lowerCaseQuery);
  }

  SearchableList<_AvailableScript> _publicAvailableScripts = SearchableList<_AvailableScript>(<_AvailableScript>[], _queryByGroupOrName,);
  bool _loadingPublicScripts = true;
  TextEditingController _publicScriptsTextEditingController = TextEditingController();

  SearchableList<_AvailableScript> _myAvailableScripts = SearchableList<_AvailableScript>(<_AvailableScript>[], _queryByGroupOrName);
  bool _loadingMyScripts = true;
  TextEditingController _myScriptsTextEditingController = TextEditingController();

  void search(String query, SearchableList<_AvailableScript> availableScripts) => setState(() => availableScripts.search(query));

  _AvailableScript? _getSelectedScript(SearchableList<_AvailableScript> availableScripts) => availableScripts.selected;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, animationDuration: Duration.zero);

    widget._publicRawScriptRepository.getAll()
        .then((allScripts) => this._publicAvailableScripts.setAllItems(allScripts))
        .whenComplete(() => setState(() => _loadingPublicScripts = false));

    loadMyAvailableScripts();

    super.initState();
  }

  Future<void> loadMyAvailableScripts() {
    _logger.trace(() => "Loading my available scripts");
    return widget._myRawScriptRepository.getAll()
        .then((allScripts) => this._myAvailableScripts.setAllItems(allScripts))
        .whenComplete(() => setState(() => _loadingMyScripts = false));
  }

  @override
  buildBody(BuildContext context) {
      return Container(
        decoration: const BoxDecoration(color: Colors.grey),
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(AppBarHeight - AppBarMargin.bottom),
              child: Container(
                decoration: AppBarBoxDecoration,
                child: TabBar(
                  tabs: [
                    Tab(child: Text("Public scripts", softWrap: true, textAlign: TextAlign.center)),
                    Tab(child: Text("My scripts", softWrap: true, textAlign: TextAlign.center)),
                  ],
                  controller: _tabController,
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                buildTabContent(context, true, buildButtonBar(context, _publicAvailableScripts), _loadingPublicScripts, _publicAvailableScripts, _publicScriptsTextEditingController),
                buildTabContent(context, false, buildMyScriptsButtonBar(context, _myAvailableScripts), _loadingMyScripts, _myAvailableScripts, _myScriptsTextEditingController),
              ],
            ),
        ),
      );
  }

  Widget buildTabContent(BuildContext context, bool readOnly, ButtonBar scriptButtonBar, bool loadingScripts,
      SearchableList<_AvailableScript> availableScripts,
      TextEditingController textEditingController) {
    return AdaptiveContainerWidget(
      header: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              flex: 5,
              child: TextField(
                controller: textEditingController,
                onChanged: (query) => search(query, availableScripts),
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(suffixIcon: Icon(Icons.search), hintText: 'Search scripts...', isDense: true),
              ),
            ),
            Spacer(),
            IconButton(onPressed: _createScript, icon: Icon(Icons.add_circle_outline), tooltip: "Create script", iconSize: 20),
            IconButton(onPressed: _importScripts, icon: Icon(Icons.compare_arrows), tooltip: "Import scripts", iconSize: 20),
            IconButton(onPressed: readOnly ? null : _exportAllFilteredScripts.takeIf(availableScripts.values.isNotEmpty), icon: Icon(Icons.import_export), tooltip: readOnly ? null : "Export my scripts", iconSize: 20),
      ])),
      children: [buildScriptsList(context, readOnly, loadingScripts, availableScripts, textEditingController),
        const Spacer(flex: 2), buildDetailsSection(context, scriptButtonBar, availableScripts)],
    );
  }

  String _buildNewScriptInitialContent(String scriptName, String scriptDescription) => """
    # Write your script here...
    name: "$scriptName"
    description: "$scriptDescription" 
    scenes:
      - name: "...scene name..."
        extensions: [ ]
        description: "...optional scene description"
        initial-state:
          - nop
        transitions:
          - show-banner: [ "**This is awesome!**", center, 2, true ]
    """.trimIndent();


  void _createScript() {
    _tabController.index = 1;
    var scriptRef = _uuid.v4();
    final  newScriptRegExp = RegExp(r'New script (\d+)');

    widget._myRawScriptRepository.getAll()
        .then((allScripts) {
          final nextIndex = allScripts
              .map((e) => newScriptRegExp.firstMatch(e.metadata.name)?.group(1)).nonNulls
              .map((e) => int.tryParse(e)).nonNulls.maxOrNull?.let((max) => max + 1) ?? 1;

          var scriptName = "New script $nextIndex";
          var scriptDescription = "... complete the 'New script $nextIndex' description...";
          return widget._myRawScriptRepository.save(RawScript(scriptRef, _buildNewScriptInitialContent(scriptName, scriptDescription)));
        })
        .then((script) => _myAvailableScripts.addItem(script))
        .then((v) => _openScriptInEditor(scriptRef, readOnly: false));
    ;
  }

  void _cloneScript(ScriptRef ref, ScriptMetadata metadata, ScriptRepository repository) {
    _tabController.index = 1;
    var scriptRef = _uuid.v4();
    repository.get(ref)
      .then((script) {
        widget._myRawScriptRepository.getAll().then((allScripts) {
          final nextIndex = allScripts
              .map((e) => e.metadata.name.replaceFirst(metadata.name, "").trim()).nonNulls
              .map((e) => int.tryParse(e)).nonNulls.maxOrNull?.let((max) => max + 1) ?? 1;

          var newScriptName = "${metadata.name} - clone $nextIndex";
          return widget._myRawScriptRepository.save(RawScript(scriptRef, script.raw.contentAsYaml.replaceFirst(metadata.name, newScriptName)));
        })
      .then((script) => _myAvailableScripts.addItem(script))
      .then((v) => _openScriptInEditor(scriptRef, readOnly: false));
    });
  }

  void _openScriptInEditor(String scriptRef, { bool readOnly = true }) {
    _loadingMyScripts = true;
    widget.openScriptInEditor?.call(scriptRef, readOnly)
        .then((value) => loadMyAvailableScripts())
        .whenComplete(() => setState((){}));
  }

  void _openScriptInPlayer(String scriptRef, { bool readOnly = true }) {
    _loadingMyScripts = true;
    widget.openScriptInPlayer?.call(scriptRef, readOnly)
        .then((value) => loadMyAvailableScripts())
        .whenComplete(() => setState((){}));
  }

  Widget buildScriptsList(BuildContext context, bool readOnly, bool loadingScripts, SearchableList<_AvailableScript> availableScripts, TextEditingController textEditingController) {
      return Expanded(
          flex: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Material(
                      type: MaterialType.transparency,
                      child: loadingScripts
                                ? Center(child: CircularProgressIndicator())
                                : availableScripts.values.length == 0 //Only root node
                                    ?  const Center(child: Text('No scripts available', style: TextStyle(fontSize: 18)))
                                    : _buildListView(availableScripts, textEditingController),
                  ))),
            ],
          ));
  }

  void _exportAllFilteredScripts() async {
    var visibleScriptCount = _myAvailableScripts.values.length;
    await _showConfirmDialog(
        context,
        visibleScriptCount > 1 ? "export the ${visibleScriptCount} filtered scripts": "export the selected script",
        () async => Future.wait(_myAvailableScripts.values.map((script) => _exportScript(script))),
    );
  }

  Future<void> _exportScript(_AvailableScript? script) async {
    if (script == null) return;

    final rawScript = await widget._myRawScriptRepository.get(script.raw.ref);
    final scriptContent = utf8.encoder.convert(rawScript.raw.contentAsYaml);
    final fileName = "${slugify(script.metadata.name)}.yaml";
    try {
      await FileSaver.instance.saveAs(name: fileName, ext: "yaml", mimeType: MimeType.custom, customMimeType: "application/yaml", bytes: scriptContent);
    } catch (e) {
      await FileSaver.instance.saveFile(name: fileName, mimeType: MimeType.custom, customMimeType: "application/yaml", bytes: scriptContent);
    }
  }

  Future<void> _shareScript(_AvailableScript? script) async {
    if (script == null) return;

    final rawScript = await widget._myRawScriptRepository.get(script.raw.ref);

    final result = await Share.share(rawScript.raw.contentAsYaml, subject: 'Script: ${script.metadata.name}');

    _logger.info(() => "Share script result: ${result.status}");
  }

  void _importScripts() async {
    _tabController.index = 1;
    List<PlatformFile> _paths = <PlatformFile>[];
    try {
      _paths = (await FilePicker.platform.pickFiles(
        allowCompression: false,
        type: FileType.custom,
        allowMultiple: true,
        onFileLoading: (FilePickerStatus status) => print(status),
        allowedExtensions: ['yaml'],
        dialogTitle: "Import scripts",
      ))?.files ?? [];
    } on PlatformException catch (e) {
      _logger.error(() => 'Unsupported operation' + e.toString());
    } catch (e) {
      _logger.error(e.toString);
    }
    if (!mounted) return;

    Future.wait(_paths.map((importedFile) =>
      importedFile.xFile.readAsString()
          .then((contentAsYaml) {
            var rawScript = RawScript(Uuid().v4(), contentAsYaml);
            return widget._myRawScriptRepository.save(rawScript);
          })
    ))
    .then((importedScripts) => setState(() => _myAvailableScripts.addItems(importedScripts)));
  }

  Widget _buildListView(SearchableList<_AvailableScript> availableScripts, TextEditingController textEditingController) {
    return GroupedListView<_AvailableScript, String>(
      elements: availableScripts.values,
      groupBy: (element) => element.metadata.group ?? "",
      groupComparator: (value1, value2) => value2.compareTo(value1),
      itemComparator: (item1, item2) => item1.metadata.name.compareTo(item2.metadata.name),
      order: GroupedListOrder.DESC,
      useStickyGroupSeparators: true,
      groupSeparatorBuilder: (String value) => _ScriptListGroup(value,
        onTap: () {
          textEditingController.text = value;
          search(value, availableScripts);
        },
      ),
      itemBuilder: (c, element) => _ScriptListItem(element.metadata.name,
          selected: availableScripts.selected == element,
          errors: element is InvalidScript ? element.parserError.causes.length : 0,
          onTap: () {
            _logger.debug(() => "Tap on: ${element.metadata.name}");
            setState(() {
              availableScripts.select(element);
            });
          },
      ),
    );
  }

  Expanded buildDetailsSection(BuildContext context, ButtonBar buttonBar, SearchableList<_AvailableScript> availableScripts) {
    return Expanded(
        flex: 58,
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: ExtendedMarkdownWidget(
                    data: _getSelectedScript(availableScripts)?.metadata.description ?? ""
                ),
              ),
            ),
            buttonBar
          ],
        ));
  }

  ButtonBar buildButtonBar(BuildContext context, SearchableList<_AvailableScript> availableScripts) {
    var selectedScript = _getSelectedScript(availableScripts);
    if (selectedScript == null) return ButtonBar(children: [
      Buttons.icon(Icons.copy_rounded, "Clone"),
      Buttons.icon(Icons.visibility_outlined, "View"),
      Buttons.highlightedIcon(Icons.play_circle, "Play"),
    ]);

    return ButtonBar(
      children: [
        Buttons.icon(Icons.copy_rounded, "Clone", action: (() => {_showConfirmDialog(context, "clone '${selectedScript.metadata.name}'", () => _cloneSelectedScript(availableScripts, widget._publicRawScriptRepository))})),
        Buttons.icon(Icons.visibility_outlined, "View", action: (() => { _openScriptInEditor(selectedScript.raw.ref, readOnly: true)})),
        Buttons.highlightedIcon(Icons.play_circle, "Play", action: selectedScript is ValidScript
          ? (() => {_openScriptInPlayer(selectedScript.raw.ref, readOnly: true)})
          : null,
        ),
      ],
    );
  }

  ButtonBar buildMyScriptsButtonBar(BuildContext context, SearchableList<_AvailableScript> availableScripts) {
    var selectedScript = _getSelectedScript(availableScripts);

    if (selectedScript == null) return ButtonBar(children: [
      Buttons.icon(Icons.share_outlined, "Share"),
      Buttons.icon(Icons.import_export_outlined, "Export"),
      Buttons.icon(Icons.delete_outline, "Delete"),
      Buttons.icon(Icons.copy_rounded, "Clone"),
      Buttons.icon(Icons.edit_outlined, "Edit"),
      Buttons.highlightedIcon(Icons.play_circle, "Play"),
    ]);

    return ButtonBar(
      children: [
        Buttons.icon(Icons.share_outlined, "Share", action: () => {_showConfirmDialog(context, "share '${selectedScript.metadata.name}'", () => _shareScript(selectedScript))}),
        Buttons.icon(Icons.import_export_outlined, "Export", action: () => {_showConfirmDialog(context, "export '${selectedScript.metadata.name}'", () => _exportScript(selectedScript))}),
        Buttons.icon(Icons.delete_outline, "Delete", action: () => {_showConfirmDialog(context, "delete '${selectedScript.metadata.name}'", () => _deleteScript(selectedScript))}),
        Buttons.icon(Icons.copy_rounded, "Clone", action: () => {_showConfirmDialog(context, "clone '${selectedScript.metadata.name}'", () => _cloneSelectedScript(availableScripts, widget._myRawScriptRepository))}),
        Buttons.icon(Icons.edit_outlined, "Edit", action: () => {_openScriptInEditor(selectedScript.raw.ref, readOnly: false)}),
        Buttons.highlightedIcon(Icons.play_circle, "Play", action: () => {_openScriptInPlayer(selectedScript.raw.ref, readOnly: false)}),
      ],
    );
  }

  void _deleteScript(_AvailableScript selectedScript) {
    widget._myRawScriptRepository.delete(selectedScript.raw.ref)
        .then((deleted) => _myAvailableScripts.delete(selectedScript))
        .whenComplete(() => setState((){}));
  }

  void _cloneSelectedScript(SearchableList<_AvailableScript> availableScripts, ScriptRepository repository){
    final selectedScript = _getSelectedScript(availableScripts);
    if (selectedScript == null) return;
    _cloneScript(selectedScript.raw.ref, selectedScript.metadata, repository);
  }

  Future<void> _showConfirmDialog(BuildContext context, String actionDescription, void Function() action) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(" "),
          content: Text('Would you like to $actionDescription?'),
          actions: <Widget>[
            Buttons.simple("Confirm", action: () {
              Navigator.of(context).pop();
              action.call();
            }),
            Buttons.highlighted("Cancel", action: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }
}

class _ScriptListItem extends StatelessWidget {

  final String text;
  final bool selected;
  final GestureTapCallback? onTap;
  final int errors;

  _ScriptListItem(this.text, {this.selected = false, this.errors = 1, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      child: SizedBox(
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
          leading: const Icon(Icons.text_snippet_outlined),
          trailing: errors > 0 ? Tooltip(message: "$errors errors found", child: const Icon(Icons.error_outline, color: Colors.deepOrangeAccent)): null,
          dense: true,
          title: Text(text),
          onTap: onTap,
          selected: selected,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          hoverColor: Colors.blue.shade100,
          selectedTileColor: Colors.blue.shade200,
          selectedColor: Colors.black,
        ),
      ),
    );
  }
}

class _ScriptListGroup extends StatelessWidget {

  final String text;
  final GestureTapCallback? onTap;

  _ScriptListGroup(this.text, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child:Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
