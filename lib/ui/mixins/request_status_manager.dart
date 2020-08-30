enum Status {
  initial,
  loading,
  ok,
  error,
}

mixin RequestStatusManager {
  Status status = Status.initial;

  void loading() {
    status = Status.loading;
  }

  bool isInitial() {
    return status == Status.initial;
  }

  bool isLoading() {
    return status == Status.loading;
  }

  void ok() {
    status = Status.ok;
  }

  bool isOk() {
    return status == Status.loading;
  }

  void error() {
    status = Status.error;
  }

  bool isError() {
    return status == Status.loading;
  }

}
