import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/domain/use_cases/collection/list_collections_use_case.dart';
import 'package:hosheee/ui/common/request_status_manager.dart';

class CollectionsViewModel extends ChangeNotifier {

  String message;

  List<Collection> collections = [];

  ListCollectionsUseCase _listCollectionsUseCase;

  ScrollController scrollController = ScrollController();

  // List<ImageLoadingStatusManager> imageLoadingStatusManagers = [];
  // bool allImagesLoaded = false;

  RequestStatusManager requestStatusManager = RequestStatusManager();

  CollectionsViewModel(
      ListCollectionsUseCase listCollectionsUseCase,
      ) {
    _listCollectionsUseCase = listCollectionsUseCase;
    scrollController.addListener(_scrollListener);
    list();
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange && !requestStatusManager.isLoading()) {
      list();
    }
  }

  void list() {
    requestStatusManager.loading();
    notifyListeners();
    _listCollectionsUseCase.handle(ListCollectionsUseCaseRequest(
          (response) {
        message = response.message;
        requestStatusManager.ok();
        if (collections.length == 0) {
          collections.addAll(response.collections);
        } else {
          for (var i = 0; i < response.collections.length; i++) {
            collections[response.startIndex+i] = response.collections[i];
          }
        }
        notifyListeners();
      },
      startIndex: collections.length,
      limit: 20,
    ));
  }

}

