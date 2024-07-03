import 'package:flutter/material.dart';

typedef CustomWidgetBuilder<T> = Widget Function(BuildContext context, T data);

abstract class WidgetFutureUtils {

  WidgetFutureUtils._();

  static Widget awaitAndBuild<T>({
    required Future<T>? future,
    required CustomWidgetBuilder<T> builder,
    T? initialData,
    CustomWidgetBuilder? onErrorBuilder
  }) {
    return FutureBuilder(
      future: future,
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (onErrorBuilder == null) throw snapshot.error!;
          return onErrorBuilder(context, snapshot.error);
        } else if (!snapshot.hasData) {
          return const Center(child: SizedBox(width: 60, height: 60, child: CircularProgressIndicator()));
        } else {
          return builder(context, snapshot.data!);
        }
      },
    );
  }
}