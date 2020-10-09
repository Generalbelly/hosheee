import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hosheee/domain/models/collection_product.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/use_cases/collection_product/batch_add_collection_products_use_case.dart';
import 'package:hosheee/domain/use_cases/product/list_products_use_case.dart';
import 'package:hosheee/ui/common/request_status_manager.dart';

class ProductsViewModel extends ChangeNotifier {

  String message;

  List<Product> products = [];

  ListProductsUseCase _listProductsUseCase;

  BatchAddCollectionProductsUseCase _batchAddCollectionProductsUseCase;

  ScrollController scrollController = ScrollController();

  RequestStatusManager requestStatusManager = RequestStatusManager();

  List<String> selectedProductIds = [];

  ProductsViewModel(
    ListProductsUseCase listProductsUseCase,
    BatchAddCollectionProductsUseCase batchAddCollectionProductsUseCase,
  ) {
    _listProductsUseCase = listProductsUseCase;
    _batchAddCollectionProductsUseCase = batchAddCollectionProductsUseCase;
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
        for (var i = 0; i < response.products.length; i++) {
          final index = response.startIndex+i;
          if (products.length < index + 1) {
            if (products.indexWhere((product) => product.id == response.products[i].id) == -1) {
              products.add(response.products[i]);
            }
          } else {
            products[response.startIndex+i] = response.products[i];
          }
        }
        notifyListeners();
      },
      startIndex: products.length,
      limit: 20,
    ));
  }

  void onTapProduct(String productId) async {
    if (selectedProductIds.indexOf(productId) == -1) {
      selectedProductIds.add(productId);
    } else {
      selectedProductIds.remove(productId);
    }
    notifyListeners();
  }

  Future<void> onSaveInTheCollection(String collectionId) async {
    final collectionProducts = selectedProductIds.map((selectedProductId) {
      final product = products.firstWhere((product) => product.id == selectedProductId, orElse: null);
      return CollectionProduct(null, name: product.name, imageUrl: product.imageUrl, productId: product.id, collectionId: collectionId);
    }).toList();
    message = null;
    final response = await _batchAddCollectionProductsUseCase.handle(
        BatchAddCollectionProductsUseCaseRequest(collectionProducts)
    );
    message = response.message;
    if (message != null) {
      notifyListeners();
    }
  }

}

