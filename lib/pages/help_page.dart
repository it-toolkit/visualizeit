
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:visualizeit/pages/base_page.dart';

import 'adaptive_container.dart';

class HelpPage extends BasePage {
  const HelpPage({super.key, super.onHelpPressed});

  @override
  Widget buildBody(BuildContext context) {
    return const Markdown(data: helpDocsExample);
  }

  static const helpDocsExample = """
> lorem ipsum, lorem ipsum, lorem ipsum

# Lorem impsum  
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum  
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum

## Lorem impsum  
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum  
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum  
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum

```
lorem ipsum
```
  
""";
}