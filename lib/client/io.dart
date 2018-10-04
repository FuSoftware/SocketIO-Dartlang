import 'dart:html';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:socket_io_client/parser/parser.dart';
import 'manager.dart';
import 'socket.dart';
import 'url.dart' as IOUrl;

class IO {
  static final Logger logger = new Logger('IO');

  static int protocol = Parser.protocol;

  static final Map<String, Manager> managers = Map();

  static void setDefaultOkHttpWebSocketFactory(WebSocket.Factory factory) {
      Manager.defaultWebSocketFactory = factory;
  }

  static void setDefaultOkHttpCallFactory(Call.Factory factory) {
      Manager.defaultCallFactory = factory;
  }

  IO() {}

  /**
   * Initializes a {@link Socket} from an existing {@link Manager} for multiplexing.
   *
   * @param uri uri to connect.
   * @param opts options for socket.
   * @return {@link Socket} instance.
   */
  static Socket socket(Uri uri, Options opts) {
    if (opts == null) {
        opts = new Options();
    }

    Uri parsed = IOUrl.Url.parse(uri);
    Uri source = parsed;
    String id = IOUrl.Url.extractId(parsed);
    String path = parsed.path;
    bool sameNamespace = managers.containsKey(id) && managers[id].nsps.containsKey(path);
    bool newConnection = opts.forceNew || !opts.multiplex || sameNamespace;
    Manager io;

    if (newConnection) {
      if (logger.isLoggable(Level.FINE)) {
        logger.fine(String.format("ignoring socket cache for %s", source));
      }
      io = new Manager(source, opts);
    } else {
      if (!managers.containsKey(id)) {
        if (logger.isLoggable(Level.FINE)) {
          logger.fine(String.format("new io instance for %s", source));
        }
        managers.putIfAbsent(id, new Manager(source, opts));
      }
      io = managers.get(id);
    }

    String query = parsed.getQuery();
    if (query != null && (opts.query == null || opts.query.isEmpty())) {
      opts.query = query;
    }

    return io.socket(parsed.getPath(), opts);
  }
}

class Options extends ManagerOptions {
  bool forceNew;
  bool multiplex = true;
}