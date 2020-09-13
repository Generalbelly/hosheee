import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wish_list/domain/models/collection.dart';
import 'package:wish_list/domain/use_cases/collection/list_collections_use_case.dart';
import 'package:wish_list/ui/mixins/request_status_manager.dart';

class CollectionsViewModel extends ChangeNotifier with RequestStatusManager {

  String message;

  List<Collection> collections = [];

  ListCollectionsUseCase _listCollectionsUseCase;

  ScrollController _scrollController = ScrollController();
  bool _scrollControllerListenerAdded = false;

  CollectionsViewModel(
    ListCollectionsUseCase listCollectionsUseCase,
  ) {
    print('come');
    _listCollectionsUseCase = listCollectionsUseCase;
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      print("at the end of list");
      listRecent();
    }
  }

  Future<void> listRecent() async {
    if (!_scrollControllerListenerAdded) {
      _scrollController.addListener(_scrollListener);
      _scrollControllerListenerAdded = true;
    }
    final response = await _listCollectionsUseCase.handle(ListCollectionsUseCaseRequest(
      limit: 20,
    ));
    message = response.message;
    collections = response.collections;
    notifyListeners();
  }

}

