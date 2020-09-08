enum RequestStatus {
  initial,
  loading,
  ok,
  error,
}

mixin RequestStatusManager {
  RequestStatus status = RequestStatus.initial;

  void loading() {
    status = RequestStatus.loading;
  }

  bool isInitial() {
    return status == RequestStatus.initial;
  }

  bool isLoading() {
    return status == RequestStatus.loading;
  }

  void ok() {
    status = RequestStatus.ok;
  }

  bool isOk() {
    return status == RequestStatus.loading;
  }

  void error() {
    status = RequestStatus.error;
  }

  bool isError() {
    return status == RequestStatus.loading;
  }

}
