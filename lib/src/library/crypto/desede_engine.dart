import 'dart:typed_data';

import 'package:basic_utils/src/library/crypto/des_base.dart';
import 'package:pointycastle/export.dart';

class DESedeEngine extends DesBase implements BlockCipher {
  static final BLOCK_SIZE = 8;

  List<int>? workingKey1;
  List<int>? workingKey2;
  List<int>? workingKey3;

  bool forEncryption = false;

  String get algorithmName => 'DESede';

  int get blockSize => BLOCK_SIZE;

  void init(bool forEncryption, CipherParameters? params) {
    if (params is KeyParameter) {
      var keyMaster = params.key;

      if (keyMaster.length != 24 && keyMaster.length != 16) {
        throw ArgumentError("key size must be 16 or 24 bytes.");
      }

      this.forEncryption = forEncryption;

      var key1 = Uint8List(8);

      _arrayCopy(keyMaster, 0, key1, 0, key1.length);
      workingKey1 = generateWorkingKey(forEncryption, key1);

      var key2 = Uint8List(8);
      _arrayCopy(keyMaster, 8, key2, 0, key2.length);
      workingKey2 = generateWorkingKey(!forEncryption, key2);

      if (keyMaster.length == 24) {
        var key3 = Uint8List(8);
        _arrayCopy(keyMaster, 16, key3, 0, key3.length);
        workingKey3 = generateWorkingKey(forEncryption, key3);
      } else {
        workingKey3 = workingKey1;
      }
    }
  }

  Uint8List process(Uint8List data) {
    var out = Uint8List(blockSize);
    var len = processBlock(data, 0, out, 0);
    return out.sublist(0, len);
  }

  int processBlock(Uint8List inp, int inpOff, Uint8List out, int outOff) {
    if (workingKey1 == null || workingKey2 == null || workingKey3 == null) {
      throw ArgumentError("DESede engine not initialised");
    }

    if ((inpOff + BLOCK_SIZE) > inp.length) {
      throw ArgumentError("input buffer too short");
    }

    if ((outOff + BLOCK_SIZE) > out.length) {
      throw ArgumentError("output buffer too short");
    }

    var temp = Uint8List(BLOCK_SIZE);

    if (forEncryption) {
      desFunc(workingKey1!, inp, inpOff, temp, 0);
      desFunc(workingKey2!, temp, 0, temp, 0);
      desFunc(workingKey3!, temp, 0, out, outOff);
    } else {
      desFunc(workingKey3!, inp, inpOff, temp, 0);
      desFunc(workingKey2!, temp, 0, temp, 0);
      desFunc(workingKey1!, temp, 0, out, outOff);
    }

    return BLOCK_SIZE;
  }

  void reset() {}

  void _arrayCopy(Uint8List? sourceArr, int sourcePos, Uint8List? outArr,
      int outPos, int len) {
    for (var i = 0; i < len; i++) {
      outArr![outPos + i] = sourceArr![sourcePos + i];
    }
  }

  int bitsOfSecurity() {
    if (workingKey1 != null && workingKey1 == workingKey3) {
      return 80;
    }
    return 112;
  }
}
