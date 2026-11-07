import 'package:flutter_test/flutter_test.dart';
import 'package:town_pass/util/web_message_handler/tp_web_message_handler.dart';

void main() {
  test('gender from ID / resident certificate number', () {
    expect(genderFromIdNumber('A123456789'), 'male');
    expect(genderFromIdNumber('a223456789'), 'female');
    expect(genderFromIdNumber('A812345678'), 'male');
    expect(genderFromIdNumber('A912345678'), 'female');
    expect(genderFromIdNumber('AB12345678'), isNull); // old-style resident certificate
    expect(genderFromIdNumber(''), isNull);
    expect(genderFromIdNumber(null), isNull);
  });
}
