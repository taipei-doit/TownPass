import 'package:flutter/material.dart';
import 'package:get/get.dart';

sealed class FetchStatus {}

class DoneFetchStatus extends FetchStatus {

}

class ErrorFetchStatus extends FetchStatus {

}

class FetchingFetchStatus extends FetchStatus {

}


class TPFetchWidgetController extends GetxController {
  final Function? onFetch;

  TPFetchWidgetController({this.onFetch,});
}

class TPFetchWidget extends StatelessWidget {
  const TPFetchWidget({
    super.key,
    required this.fetch,
  });

  final Function fetch;

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
