import 'packet.dart';

class Parser{
  static final int CONNECT = 0;
  static final int DISCONNECT = 1;
  static final int EVENT = 2;
  static final int ACK = 3;
  static final int ERROR = 4;
  static final int BINARY_EVENT = 5;
  static final int BINARY_ACK = 6;

  static int protocol = 4;

  static List<String> types = [
    'CONNECT',
    'DISCONNECT',
    'EVENT',
    'ACK',
    'ERROR',
    'BINARY_EVENT',
    'BINARY_ACK'
  ];
}

class Encoder {
  encode(Packet packet, EncoderCallback callback) {}
}

class EncoderCallback{
  call(List<Object> data) {}
}

class Decoder {
  addString(String obj) {}

  addBytes(List<int> obj) {}

  destroy() {}

  onDecoded(DecoderCallback callback) {}

  
}

class DecoderCallback {
    call(Packet packet) {}
}