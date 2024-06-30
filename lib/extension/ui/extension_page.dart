import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/extension/domain/extension_repository.dart';
import 'package:visualizeit_extensions/extension.dart';
import 'package:visualizeit_extensions/logging.dart';

import '../../common/markdown/markdown.dart';
import '../../common/ui/adaptive_container_widget.dart';

final _logger = Logger("extension.ui");

class ExtensionPage extends StatefulBasePage {
  static const RouteName = "extensions";

  final ExtensionRepository _repository;

  const ExtensionPage(ExtensionRepository repository, {super.key}): this._repository = repository, super(RouteName);

  @override
  State<StatefulWidget> createState() {
    return _ExtensionPageState();
  }
}

class _ExtensionPageState extends BasePageState<ExtensionPage> {
  List<Extension> _filteredExtensions = [];
  int? _selectedIndex;
  String _query = '';

  void search(String query) {
    setState(
      () {
        _query = query;
        _filteredExtensions = getAllExtensions().where((item) => item.id.toLowerCase().contains(query.toLowerCase())).toList();
        if (_filteredExtensions.length == 1) {
          _selectedIndex = 0;
        } else {
          _selectedIndex = null;
        }
      },
    );
  }

  List<Extension> getAllExtensions() => widget._repository.getAll();

  @override
  Widget buildBody(BuildContext context) {
    return AdaptiveContainerWidget(
      header: buildSearchBar(),
      children: [buildScriptsList(), const Spacer(flex: 2), buildDetailsSection(context)],
    );
  }

  Widget buildScriptsList() {
    return Expanded(
        flex: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Padding(
              child: Text("Extensions", style: TextStyle(fontWeight: FontWeight.bold)),
              padding: EdgeInsets.all(10),
            ),
            Expanded(
                child: Material(
                    type: MaterialType.transparency,
                    child: _filteredExtensions.isNotEmpty || _query.isNotEmpty
                        ? _filteredExtensions.isEmpty
                            ? const Center(child: Text('No extensions found', style: TextStyle(fontSize: 18)))
                            : _buildListView(_filteredExtensions)
                        : _buildListView(getAllExtensions()))),
          ]),
        ));
  }

  Widget _buildListView(List<Extension> extensions) {
    return ListView.builder(
      itemCount: extensions.length,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) => _ExtensionListItem(
        extensions[index].id,
        onTap: () => setState(() => _selectedIndex = index),
        selected: index == _selectedIndex,
      )
    );
  }

  Widget buildSearchBar() {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 200,
            height: 40,
            child: TextField(
                onChanged: search,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(suffixIcon: Icon(Icons.search), hintText: 'Search extensions...')),
          ),
        ));
  }

  Widget markdownFromAsset(String assetLocation) {
    return FutureBuilder(
        future: rootBundle.loadString(assetLocation),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return ExtendedMarkdownWidget(data: snapshot.data!);
          } else if (snapshot.hasError) {
            _logger.error(() => "Error loading docs from location [${assetLocation}]: ${snapshot.error}");
            return const Text("Error loading docs");
          } else {
            return CircularProgressIndicator();
          }
        }
    );
  }

  Widget buildDetailsSection(BuildContext context) {
    final selectedExtension = _selectedIndex != null
        ? _filteredExtensions.isEmpty
            ? getAllExtensions()[_selectedIndex!]
            : _filteredExtensions[_selectedIndex!]
        : null;
    final detailsWidget = selectedExtension != null ? markdownFromAsset(selectedExtension.markdownDocs["en"]!) : null;

    return Expanded(
      flex: 58,
      child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: detailsWidget),
    );
  }
}

class _ExtensionListItem extends StatelessWidget {

  final String text;
  final bool selected;
  final GestureTapCallback? onTap;

  _ExtensionListItem(this.text, {this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      child: SizedBox(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
          leading: const Icon(Icons.text_snippet_outlined),
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