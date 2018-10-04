//https://github.com/socketio/socket.io-client-java/tree/master/src/main/java/io/socket/hasbinary

import 'package:logging/logging.dart';

class HasBinary{

  static final Logger logger = new Logger('HasBinary');

  static bool hasBinary(Object data){
    return _hasBinary(data);
  }

  static bool _hasBinary(Object obj) {
    if (obj == null) return false;

    if (obj is List<int>) {
      return true;
    }

    if (obj is List<Object>) {
      List<Object> _obj = obj;
      int length = _obj.length;
      for (int i = 0; i < length; i++) {
        Object v;
        try {
          v = _obj[i];
        } catch (err) {
          logger.log(Level.WARNING, "An error occured while retrieving data from JSONArray", err);
          return false;
        }
        if (_hasBinary(v)) {
          return true;
        }
      }
    } else if (obj is Map<String, Object>) {
      Map<String, Object> _obj = obj;
      _obj.keys.forEach((key) {
        Object v;
        try {
          v = _obj[key];
        } catch (err) {
          logger.log(Level.WARNING, "An error occured while retrieving data from JSONObject", err);
          return false;       
        }
        if (_hasBinary(v)) {
          return true;
        }
      });
    }
    return false;
  }
}