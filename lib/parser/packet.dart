
class Packet<T>{
  int type = -1;
  int id = -1;
  String nsp;
  T data;
  int attachments;
  String query;


  Packet([int type = -1, T data = null]){
    this.type =  type;
    this.data = data;
  }
}