enum RequestType { GET, POST, PUT, DELETE }

enum MessageType {
  IMAGE,
  TEXT;

  static String getString(MessageType type) {
    if (type == IMAGE) {
      return 'image';
    }
    if (type == TEXT) {
      return 'text';
    }
    return '';
  }

  static MessageType fromString(String message) {
    if (message == 'image') {
      return IMAGE;
    }
    return TEXT;
  }
}
