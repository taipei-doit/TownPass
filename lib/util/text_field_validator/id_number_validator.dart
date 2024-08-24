import 'package:characters/characters.dart';
import 'package:collection/collection.dart';

String _head = 'ABCDEFGHJKLMNPQRSTUVWXYZIO';

bool idNumberValidator({required String idNumber}) {
  if (idNumber.length != 10) {
    return false;
  }

  if (!idNumber.contains(RegExp(r'^[a-zA-Z]\d{9}$'))) {
    return false;
  }

  if (!['1', '2'].contains(idNumber[1])) {
    return false;
  }

  int sum = 0;
  return 0 ==
      idNumber.characters.mapIndexed<int>(
        (index, char) {
          if (index == 0) {
            sum += (_head.indexOf(char) + 10) ~/ 10;
          }
          return switch (index) {
            0 => (_head.indexOf(char) + 10) % 10,
            _ => int.parse(char),
          };
        },
      ).foldIndexed(
        sum,
        (index, pre, number) {
          return switch (index) {
            9 => number - (10 - pre % 10),
            _ => sum += (number * (9 - index)),
          };
        },
      );
}
