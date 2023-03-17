import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';

class BasicUtilsRC2Parameters extends KeyParameter {
  late int effectiveKeyBits;

  BasicUtilsRC2Parameters(Uint8List key, {int? bits}) : super(key) {
    if (bits != null) {
      effectiveKeyBits = bits;
    } else {
      effectiveKeyBits = (key.length > 128) ? 1024 : (key.length * 8);
    }
  }
}
