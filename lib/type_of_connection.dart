

enum TypeOfConnection {
  login,
  register
}

extension TypeOfConnectionExtension on TypeOfConnection {
  int get label {
    switch (this) {
      case TypeOfConnection.login:
        return 0;
      case TypeOfConnection.register:
        return 1;
    }
  }
}