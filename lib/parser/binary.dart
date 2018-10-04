
//Based on https://github.com/socketio/socket.io-client-java/blob/master/src/main/java/io/socket/parser/Binary.java

import 'package:logging/logging.dart';
import 'packet.dart';

class Binary {
  static final String KEY_PLACEHOLDER = "_placeholder";
  static final String KEY_NUM = "num";
  static final Logger logger = new Logger('Binary');

  static deconstructPacket(Packet packet){
    List<List<int>> buffers = new List();

    packet.data = _deconstructPacket(packet.data, buffers);
    packet.attachments = buffers.length;

    DeconstructedPacket result = new DeconstructedPacket();
    result.packet = packet;
    result.buffers = new List(buffers.length);
    return result;
  }

  static Object _deconstructPacket(Object data,  List<List<int>> buffers){
    if(data == null) return null;

    if(data is List<int>){
      dynamic placeholder;
      try{
        placeholder[KEY_PLACEHOLDER] = true;
        placeholder[KEY_NUM] = buffers.length;
      }catch(err){
        logger.log(Level.WARNING, "An error occured while putting data to JSONObject", err);
        return null;
      }
      
      buffers.add(data);
      return placeholder;

    }else if(data is List<Object>){
      List<Object> newData;
      List<Object> _data = data;
      int len = _data.length;
      for(int i=0; i<len; i++){
        try {
          newData[i] = _deconstructPacket(_data[i], buffers);
        }catch(err){
          logger.log(Level.WARNING, "An error occured while putting packet data to JSONObject", err);
          return null;
        }
      }
      return newData;
    }else if(data is Map<String, Object>){
      Map<String, Object> newData = new Map();
      Map<String, Object> _data = data;

      _data.keys.forEach((key){
        try{
          newData[key] = _deconstructPacket(_data[key], buffers);
        }catch(err){
          logger.log(Level.WARNING, "An error occured while putting data to JSONObject", err);
          return null;
        }
      });
      return newData;
    }
  }

  static Packet reconstructPacket(Packet packet, List<List<int>> buffers){
    packet.data = _reconstructPacket(packet.data, buffers);
    packet.attachments = -1;
    return packet;
  }

  static Object _reconstructPacket(Object data, List<List<int>> buffers){
    if(data is List<Object>){
      List<Object> _data = data;
      int len = _data.length;

      for(int i=0;i<len;i++){
        try{
          _data[i] = _reconstructPacket(_data[i], buffers);
        }catch(err){
          logger.log(Level.WARNING, "An error occured while putting packet data to JSONObject", err);
          return null;
        }
      }
      return _data;
    }else if(data is Map<String, Object>){
      Map<String, Object> _data = data;

      if(_data.containsKey(KEY_PLACEHOLDER)){
        int n = _data[KEY_NUM];
        return n >= 0 && n < buffers.length ? buffers[n] : null;
      }

      _data.keys.forEach((key){
        try{
          _data[key] = _reconstructPacket(_data[key], buffers);
        }catch(err){
          logger.log(Level.WARNING, "An error occured while putting data to JSONObject", err);
          return null;
        }
      });

      return _data;
    }else{
      print('Failed to reconstruct becuse type is unsupported');
      return data;
    }
  }

}

class DeconstructedPacket{
    Packet packet;
    List<List<int>> buffers;
}