import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

import 'custom_node.dart';
import 'latex.dart';
import 'video.dart';

class ExtendedMarkdownBlock extends StatelessWidget {
  final String data;

  ExtendedMarkdownBlock({required this.data});

  @override
  Widget build(BuildContext context) {
    return MarkdownBlock(
      data: data,
      config: _buildMarkdownConfig(),
      generator: _buildMarkdownGenerator(),
    );
  }
}

class ExtendedMarkdownWidget extends StatelessWidget {
  final String data;
  final TocController? tocController;

  ExtendedMarkdownWidget({required this.data, this.tocController});

  @override
  Widget build(BuildContext context) {
    return MarkdownWidget(
      data: data,
      tocController: tocController,
      config: _buildMarkdownConfig(),
      markdownGenerator: _buildMarkdownGenerator(),
    );
  }
}

MarkdownConfig _buildMarkdownConfig() {
  return MarkdownConfig(
    configs: [
      PConfig(textStyle: TextStyle(fontSize: 14)),
      TableConfig(wrapper: (child) => SingleChildScrollView(scrollDirection: Axis.horizontal, child: child))
    ],
  );
}

MarkdownGenerator _buildMarkdownGenerator() {
  return MarkdownGenerator(
    generators: [latexGenerator, videoGeneratorWithTag],
    inlineSyntaxList: [LatexSyntax()],
    textGenerator: (node, config, visitor) => CustomTextNode(node.textContent, config, visitor),
  );
}
