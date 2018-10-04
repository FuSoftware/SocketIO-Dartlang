import 'parser.dart';
import 'packet.dart';
import 'has_binary.dart';
import 'binary.dart';

import 'dart:convert';

import 'package:logging/logging.dart';

class IOParser implements Parser {

  static final Logger logger = new Logger('IOParser');

  static Packet<String> error(){
    return new Packet<String>(Parser.ERROR, "parser error");
  }
}

class IOEncoder implements Encoder {

  @override
  encode(Packet obj, EncoderCallback callback){
    if((obj.type == Parser.EVENT || obj.type == Parser.ACK) && HasBinary.hasBinary(obj.data)){
      obj.type = obj.type == Parser.EVENT ? Parser.BINARY_EVENT : Parser.BINARY_ACK;
    }

    if(IOParser.logger.isLoggable(Level.FINE)){
      IOParser.logger.fine('encoding packet $obj');
    }

    if(obj.type == Parser.BINARY_EVENT || obj.type == Parser.BINARY_ACK){
      encodeAsBinary(obj, callback);
    }else {
      String encoding = encodeAsString(obj);
      List<String> data = new List();
      data.add(encoding);
      callback.call(data);
    }
  }

  String encodeAsString(Packet obj){
    String str = obj.type.toString();

    if(obj.type == Parser.BINARY_ACK || obj.type == Parser.BINARY_EVENT){
      str += obj.attachments.toString();
      str += '-';
    }

    if (obj.nsp != null && obj.nsp.length != 0 && obj.nsp != '/') {
      str += obj.nsp;
      str += ',';
    }

    if (obj.id >= 0) {
      str += obj.id.toString();
    }

    if (obj.data != null) {
      str += obj.data;
    }

    if (IOParser.logger.isLoggable(Level.FINE)) {
      IOParser.logger.fine("encoded $obj as $str");
    }
    return str;
  }

  encodeAsBinary(Packet obj, EncoderCallback callback){
    DeconstructedPacket deconstruction = Binary.deconstructPacket(obj);
    String pack = encodeAsString(deconstruction.packet);
    List<Object> buffers = deconstruction.buffers;

    buffers.insert(0, pack);
    callback.call(buffers);
  }
}

class IODecoder implements Decoder {
  BinaryReconstructor reconstructor;
  DecoderCallback onDecodedCallback;

  IODecoder(){
    this.reconstructor = null;
  }

  @override
  addString(String obj) {
    Packet packet = decodeString(obj);

    if(packet.type == Parser.BINARY_EVENT || packet.type == Parser.BINARY_ACK){
      this.reconstructor = new BinaryReconstructor(packet);

      if(this.reconstructor.reconPack.attachments == 0){
        if(this.onDecodedCallback != null){
          this.onDecodedCallback.call(packet);
        }
      }
    }else{
      if(this.onDecodedCallback != null){
        this.onDecodedCallback.call(packet);
      }
    }
  }

  @override
  addBytes(List<int> obj){
    if (this.reconstructor == null) {
      throw new Exception("got binary data when not reconstructing a packet");
    } else {
      Packet packet = this.reconstructor.takeBinaryData(obj);
      if (packet != null) {
        this.reconstructor = null;
        if (this.onDecodedCallback != null) {
            this.onDecodedCallback.call(packet);
        }
      }
    }
  }

  static Packet decodeString(String str){
    int i=0;
    int length = str.length;

    Packet<Object> p = new Packet(str.codeUnitAt(0));

    if(p.type < 0 || p.type > Parser.types.length - 1) return IOParser.error();

    if(p.type == Parser.BINARY_EVENT || p.type == Parser.ACK){
      if(!str.contains('-') || length <= i + 1) return IOParser.error();

      String attachments = '';

      while(str[++i] != '-'){
        attachments += str[i];
      }

      p.attachments = int.parse(attachments);
    }

    if (length > i + 1 && '/' == str.codeUnitAt(i + 1)) {
      String nsp = '';
      while (true) {
        ++i;
        String c = str[i];
        if (',' == c) break;
        nsp += c;
        if (i + 1 == length) break;
      }
      p.nsp = nsp;
    } else {
        p.nsp = "/";
    }

    if (length > i + 1){
      String next = str[i + 1];
      if (int.parse(next) > -1) {
        String id = '';
        while (true) {
          ++i;
          String c = str[i];
          if (int.parse(c) < 0) {
              --i;
              break;
          }
          id += c;
          if (i + 1 == length) break;
        }
        try {
          p.id = int.parse(id);
        } catch (err){
          return IOParser.error();
        }
      }
    }

    if (length > i + 1){
      try {
        str[++i];
        p.data = new JsonDecoder().convert(str.substring(i));
      } catch (err) {
        IOParser.logger.log(Level.WARNING, "An error occured while retrieving data from JSONTokener", err);
        return IOParser.error();
      }
    }

    if (IOParser.logger.isLoggable(Level.FINE)) {
      IOParser.logger.fine("decoded $str as $p");
    }
    return p;
  }

  @override
  void destroy(){
    if (this.reconstructor != null) {
      this.reconstructor.finishReconstruction();
    }
    this.onDecodedCallback = null;
  }

  void onDecoded(DecoderCallback callback){
    this.onDecodedCallback = callback;
  }

}

class BinaryReconstructor {
  Packet reconPack;

  List<List<int>> buffers;

  BinaryReconstructor(Packet packet){
    this.reconPack = packet;
    this.buffers = new List<List<int>>();
  }

  Packet takeBinaryData(List<int> binData) {
    this.buffers.add(binData);
    if (this.buffers.length == this.reconPack.attachments) {
      Packet packet = Binary.reconstructPacket(this.reconPack,this.buffers);
      this.finishReconstruction();
      return packet;
    }
    return null;
  }

  finishReconstruction() {
    this.reconPack = null;
    this.buffers = new List<List<int>>();
  }
}