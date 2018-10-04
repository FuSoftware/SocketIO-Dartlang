

class Url {
  static RegExp PATTERN_HTTPS = new RegExp(r'^http|ws$');
  static RegExp PATTERN_HTTP = new RegExp(r'^http|ws$');

  static Uri parse(Uri uri){
    //Protocol
    String protocol = uri.scheme;
    if(protocol == null || !PATTERN_HTTPS.hasMatch(protocol)){
      protocol = 'https';
    }

    //Port
    int port = uri.port;
    if(port == -1){
      if(PATTERN_HTTP.hasMatch(protocol)){
        port = 80;
      }else if(PATTERN_HTTPS.hasMatch(protocol)){
        port = 443;
      }
    }

    //Path
    String path = uri.path;
    if(path == null || path.length == 0){
      path = '/';
    }

    String userInfo = uri.userInfo;
    String query = uri.query;
    String fragment = uri.fragment;

    return new Uri(
      fragment: fragment,
      port:  port,
      query: query,
      host: uri.host,
      scheme: protocol,
      userInfo: userInfo,
      path: path,
    );
  }

  static String extractId(Uri url) {
    String protocol = url.scheme;
    int port = url.port;
    if (port == -1) {
      if (PATTERN_HTTP.hasMatch(protocol)) {
        port = 80;
      } else if (PATTERN_HTTPS.hasMatch(protocol)) {
        port = 443;
      }
    }
    return protocol + "://" + url.host + ":" + port.toString();
  }
}