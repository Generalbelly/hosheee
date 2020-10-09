import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/domain/use_cases/collection/list_collections_use_case.dart';
import 'package:hosheee/ui/common/request_status_manager.dart';

class CollectionsViewModel extends ChangeNotifier {

  String message;

  List<Collection> collections = [];

  ListCollectionsUseCase _listCollectionsUseCase;

  ScrollController collectionsViewScrollController = ScrollController();

  ScrollController productViewScrollController = ScrollController();

  RequestStatusManager requestStatusManager = RequestStatusManager();

  CollectionsViewModel(
      ListCollectionsUseCase listCollectionsUseCase,
      ) {
    _listCollectionsUseCase = listCollectionsUseCase;
    collectionsViewScrollController.addListener(_collectionsViewScrollListener);
    productViewScrollController.addListener(_productViewScrollListener);
    list();
  }

  void _collectionsViewScrollListener() {
    if (collectionsViewScrollController.offset >= collectionsViewScrollController.position.maxScrollExtent &&
        !collectionsViewScrollController.position.outOfRange && !requestStatusManager.isLoading()) {
      list();
    }
  }

  void _productViewScrollListener() {
    if (productViewScrollController.offset >= productViewScrollController.position.maxScrollExtent &&
        !productViewScrollController.position.outOfRange && !requestStatusManager.isLoading()) {
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
        for (var i = 0; i < response.collections.length; i++) {
          final index = response.startIndex+i;
          if (collections.length < index + 1) {
            if (collections.indexWhere((collection) => collection.id == response.collections[i].id) == -1) {
              collections.add(response.collections[i]);
            }
          } else {
            collections[response.startIndex+i] = response.collections[i];
          }
        }
        notifyListeners();
      },
      startIndex: collections.length,
      limit: 4,
    ));
  }

}

