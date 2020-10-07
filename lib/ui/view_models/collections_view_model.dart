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
    listRecent();
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange && !requestStatusManager.isLoading()) {
      listRecent();
    }
  }

  void listRecent() {
    requestStatusManager.loading();
    notifyListeners();
    _listCollectionsUseCase.handle(ListCollectionsUseCaseRequest(
          (response) {
        message = response.message;
        requestStatusManager.ok();
        collections.replaceRange(
            response.startIndex,
            response.startIndex+response.limit,
            response.collections);
        notifyListeners();
      },
      startIndex: collections.length,
      limit: 20,
    ));
  }

}

