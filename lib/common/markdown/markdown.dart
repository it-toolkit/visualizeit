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
      generator: MarkdownGenerator(
        generators: [latexGenerator, videoGeneratorWithTag],
        inlineSyntaxList: [LatexSyntax()],
        textGenerator: (node, config, visitor) => CustomTextNode(node.textContent, config, visitor),
      ),
    );
  }
}

class ExtendedMarkdownWidget extends StatelessWidget {
  final String data;

  ExtendedMarkdownWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return MarkdownWidget(
      data: data,
      markdownGenerator: MarkdownGenerator(
        generators: [latexGenerator, videoGeneratorWithTag],
        inlineSyntaxList: [LatexSyntax()],
        textGenerator: (node, config, visitor) => CustomTextNode(node.textContent, config, visitor),
      ),
    );
  }
}
