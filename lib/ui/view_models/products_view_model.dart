import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/use_cases/product/list_products_use_case.dart';
import 'package:wish_list/ui/mixins/request_status_manager.dart';

class ProductsViewModel extends ChangeNotifier with RequestStatusManager {

  String message;

  List<Product> products = [];

  ListProductsUseCase _listProductsUseCase;

  ScrollController scrollController = ScrollController();
  bool _scrollControllerListenerAdded = false;

  ProductsViewModel(
    ListProductsUseCase listProductsUseCase,
  ) {
    _listProductsUseCase = listProductsUseCase;
    listRecent();
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      print("at the end of list");
      listRecent();
    }
  }

  Future<void> listRecent() async {
    if (!_scrollControllerListenerAdded) {
      print("yes");
      scrollController.addListener(_scrollListener);
      _scrollControllerListenerAdded = true;
    }
    final response = await _listProductsUseCase.handle(ListProductsUseCaseRequest(
      limit: 8,
    ));
    message = response.message;
    products.addAll(response.products);
    notifyListeners();
  }

}

