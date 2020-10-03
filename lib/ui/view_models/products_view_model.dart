import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/use_cases/product/list_products_by_collection_id_use_case.dart';
import 'package:hosheee/ui/common/request_status_manager.dart';

class ProductsViewModel extends ChangeNotifier {

  String message;

  Collection _collection;

  Collection get collection => _collection;
  set collection(Collection value) {
    _collection = value;
    list();
  }

  List<Product> products = [];

  ListProductsByCollectionIdUseCase _listProductsUseCase;

  ScrollController scrollController = ScrollController();

  RequestStatusManager requestStatusManager = RequestStatusManager();

  ProductsViewModel(
      ListProductsByCollectionIdUseCase listProductsUseCase,
      ) {
    _listProductsUseCase = listProductsUseCase;
    scrollController.addListener(_scrollListener);
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
    _listProductsUseCase.handle(ListProductsByCollectionIdUseCaseRequest(
      collection.id,
      (response) {
        message = response.message;
        if (requestStatusManager.isLoading()) {
          requestStatusManager.ok();
        }
        products = response.products;
        notifyListeners();
      },
      limit: 15,
    ));
  }

}

