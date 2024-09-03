import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

abstract class TPWebMessageReply {
  final String name;
  final Object? data;

  const TPWebMessageReply({
    required this.name,
    required this.data,
  });

  WebMessage get message;
}

class TPWebStringMessageReply extends TPWebMessageReply {
  TPWebStringMessageReply({
    required super.name,
    required super.data,
  });

  @override
  WebMessage get message => WebMessage(
        type: WebMessageType.STRING,
        data: jsonEncode(
          {
            'name': name,
            'data': data,
          },
        ),
      );
}

// class TPWebUInt8ListMessageReply extends TPWebMessageReply {
//   TPWebUInt8ListMessageReply({
//     required super.name,
//     required super.data,
//   });
//
//   @override
//   WebMessage get message => WebMessage(
//         type: WebMessageType.ARRAY_BUFFER,
//         data: jsonEncode(
//           {
//             'name': name,
//             'data': data,
//           },
//         ),
//       );
// }
