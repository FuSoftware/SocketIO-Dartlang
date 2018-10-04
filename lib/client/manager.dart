import 'package:logging/logging.dart';
import 'package:socket_io_client/parser/parser.dart';

import 'dart:html';

class Manager {
  static final Logger logger = new Logger('Manager');

  /**
   * Called on a successful connection.
   */
  static final String EVENT_OPEN = "open";

  /**
   * Called on a disconnection.
   */
  static final String EVENT_CLOSE = "close";

  static final String EVENT_PACKET = "packet";
  static final String EVENT_ERROR = "error";

  /**
   * Called on a connection error.
   */
  static final String EVENT_CONNECT_ERROR = "connect_error";

  /**
   * Called on a connection timeout.
   */
  static final String EVENT_CONNECT_TIMEOUT = "connect_timeout";

  /**
   * Called on a successful reconnection.
   */
  static final String EVENT_RECONNECT = "reconnect";

  /**
   * Called on a reconnection attempt error.
   */
  static final String EVENT_RECONNECT_ERROR = "reconnect_error";

  static final String EVENT_RECONNECT_FAILED = "reconnect_failed";

  static final String EVENT_RECONNECT_ATTEMPT = "reconnect_attempt";

  static final String EVENT_RECONNECTING = "reconnecting";

  static final String EVENT_PING = "ping";

  static final String EVENT_PONG = "pong";

  /**
   * Called when a new transport is created. (experimental)
   */
  static final String EVENT_TRANSPORT = Engine.EVENT_TRANSPORT;

  bool _reconnection;
  bool skipReconnect;
  bool reconnecting;
  bool encoding;
  int _reconnectionAttempts;
  int _reconnectionDelay;
  int _reconnectionDelayMax;
  double _randomizationFactor;
  Backoff backoff;
  int _timeout;
  Set<Socket> connecting = new HashSet<Socket>();
  DateTime lastPing;
  Uri uri;
  List<Packet> packetBuffer;
  Queue<On.Handle> subs;
  Options opts;
  Socket engine;
  Parser.Encoder encoder;
  Parser.Decoder decoder;

  Manager(Uri uri, Object opts)
}

enum ManagerReadyState {
  CLOSED, OPENING, OPEN
}

class Engine extends Socket {

  Engine(Uri uri, Options opts) {
    super(uri, opts);
  }
}

class ManagerOptions extends SocketOptions {
  bool reconnection = true;
  int reconnectionAttempts;
  int reconnectionDelay;
  int reconnectionDelayMax;
  double randomizationFactor;
  Encoder encoder;
  Decoder decoder;
  int timeout = 20000;
}