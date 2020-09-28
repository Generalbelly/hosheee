import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/use_cases/product/list_products_use_case.dart';
import 'package:wish_list/ui/mixins/request_status_manager.dart';

class RecentViewModel extends ChangeNotifier {

  String message;

  List<Product> products = [];

  ListProductsUseCase _listProductsUseCase;

  ScrollController scrollController = ScrollController();

  RequestStatusManager requestStatusManager = RequestStatusManager();

  RecentViewModel(
    ListProductsUseCase listProductsUseCase,
  ) {
    _listProductsUseCase = listProductsUseCase;
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
    _listProductsUseCase.handle(ListProductsUseCaseRequest(
      (response) {
        message = response.message;
        requestStatusManager.ok();
        products = response.products;
        notifyListeners();
      },
      limit: 3,
    ));
  }

}

