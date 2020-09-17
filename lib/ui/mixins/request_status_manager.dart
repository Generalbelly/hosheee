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

  void initial() {
    status = RequestStatus.initial;
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
    return status == RequestStatus.ok;
  }

  void error() {
    status = RequestStatus.error;
  }

  bool isError() {
    return status == RequestStatus.error;
  }

}

class ImageLoadingStatus with RequestStatusManager {
  String url;

  ImageLoadingStatus(this.url);

}
