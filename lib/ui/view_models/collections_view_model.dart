import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wish_list/domain/models/collection.dart';
import 'package:wish_list/domain/use_cases/collection/list_collections_use_case.dart';
import 'package:wish_list/ui/mixins/request_status_manager.dart';

class CollectionsViewModel extends ChangeNotifier {

  String message;

  List<Collection> collections = [];

  ListCollectionsUseCase _listCollectionsUseCase;

  ScrollController scrollController = ScrollController();
  bool _scrollControllerListenerAdded = false;

  // List<ImageLoadingStatusManager> imageLoadingStatusManagers = [];
  // bool allImagesLoaded = false;

  RequestStatusManager requestStatusManager = RequestStatusManager();

  CollectionsViewModel(
      ListCollectionsUseCase listCollectionsUseCase,
      ) {
    _listCollectionsUseCase = listCollectionsUseCase;
    listRecent();
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange && !requestStatusManager.isLoading()) {
      listRecent();
    }
  }

  void listRecent() {
    if (!_scrollControllerListenerAdded) {
      scrollController.addListener(_scrollListener);
      _scrollControllerListenerAdded = true;
    }
    requestStatusManager.loading();
    notifyListeners();
    _listCollectionsUseCase.handle(ListCollectionsUseCaseRequest(
          (response) {
        message = response.message;
        if (requestStatusManager.isLoading()) {
          requestStatusManager.ok();
        }
        collections = response.collections;
        notifyListeners();
      },
      limit: 15,
    ));
  }

}

