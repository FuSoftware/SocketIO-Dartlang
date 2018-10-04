class On {

  On() {}

  static Handle on(final Emitter obj, final String ev, final Emitter.Listener fn) {
    obj.on(ev, fn);
    return new Handle() {
      @override
      void destroy() {
        obj.off(ev, fn);
      }
    };
  }
}

class OnHandle {
  void destroy() {}
}