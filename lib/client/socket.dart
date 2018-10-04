import 'manager.dart';
import 'package:logging/logging.dart';

class Socket extends Emitter {

  static final Logger logger = new Logger('Socket');

  static final String EVENT_CONNECT = "connect";
  static final String EVENT_CONNECTING = "connecting";
  static final String EVENT_DISCONNECT = "disconnect";
  static final String EVENT_ERROR = "error";
  static final String EVENT_MESSAGE = "message";
  static final String EVENT_CONNECT_ERROR = Manager.EVENT_CONNECT_ERROR;
  static final String EVENT_CONNECT_TIMEOUT = Manager.EVENT_CONNECT_TIMEOUT;
  static final String EVENT_RECONNECT = Manager.EVENT_RECONNECT;
  static final String EVENT_RECONNECT_ERROR = Manager.EVENT_RECONNECT_ERROR;
  static final String EVENT_RECONNECT_FAILED = Manager.EVENT_RECONNECT_FAILED;
  static final String EVENT_RECONNECT_ATTEMPT = Manager.EVENT_RECONNECT_ATTEMPT;
  static final String EVENT_RECONNECTING = Manager.EVENT_RECONNECTING;
  static final String EVENT_PING = Manager.EVENT_PING;
  static final String EVENT_PONG = Manager.EVENT_PONG;

  Socket(Manager io, String nsp, ManagerOptions opts) {
    this.io = io;
    this.nsp = nsp;
    if (opts != null) {
        this.query = opts.query;
    }
  }
}