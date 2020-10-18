import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/domain/models/collection_product.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/use_cases/collection_product/batch_delete_collection_products_use_case.dart';
import 'package:hosheee/domain/use_cases/collection_product/list_collection_products_by_collection_id_use_case.dart';
import 'package:hosheee/domain/use_cases/collection_product/list_collection_products_by_product_id_use_case.dart';
import 'package:hosheee/ui/common/request_status_manager.dart';

class CollectionProductsViewModel extends ChangeNotifier {

  String message;

  List<List<CollectionProduct>> accumulatedResult = [];

  List<CollectionProduct> get collectionProducts {
    return accumulatedResult.expand((ps) => ps).toList();
  }

  Collection _collection;
  Collection get collection => _collection;
  set collection(Collection value) {
    _collection = value;
    accumulatedResult = [];
    selectedCollectionProductIds = [];
    listByCollectionId();
  }

  Product _product;
  Product get product => _product;
  set product(Product value) {
    _product = value;
    accumulatedResult = [];
    selectedCollectionProductIds = [];
    listByProductId();
  }

  List<String> selectedCollectionProductIds = [];

  ListCollectionProductsByCollectionIdUseCase _listCollectionProductsByCollectionIdUseCase;
  ListCollectionProductsByProductIdUseCase _listCollectionProductsByProductIdUseCase;
  BatchDeleteCollectionProductsUseCase _batchDeleteCollectionProductsUseCase;

  bool _isActionBarHidden = true;
  bool get isActionBarHidden => _isActionBarHidden;
  set isActionBarHidden(bool value) {
    _isActionBarHidden = value;
    notifyListeners();
  }

  ScrollController scrollController = ScrollController();

  RequestStatusManager requestStatusManager = RequestStatusManager();

  CollectionProductsViewModel(
    ListCollectionProductsByCollectionIdUseCase listCollectionProductsByCollectionIdUseCase,
      ListCollectionProductsByProductIdUseCase listCollectionProductsByProductIdUseCase,
    BatchDeleteCollectionProductsUseCase batchDeleteCollectionProductsUseCase,
  ) {
    _listCollectionProductsByCollectionIdUseCase = listCollectionProductsByCollectionIdUseCase;
    _listCollectionProductsByProductIdUseCase = listCollectionProductsByProductIdUseCase;
    _batchDeleteCollectionProductsUseCase = batchDeleteCollectionProductsUseCase;
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange && !requestStatusManager.isLoading()) {
      listByCollectionId();
    }
  }

  void listByCollectionId() {
    requestStatusManager.loading();
    message = null;
    notifyListeners();
    _listCollectionProductsByCollectionIdUseCase.handle(ListCollectionProductsByCollectionIdUseCaseRequest(
      collection.id,
      (response) {
        message = response.message;
        requestStatusManager.ok();
        final index = response.startIndex == 0 ? 0 : response.startIndex / response.limit;
        if (accumulatedResult.length > index) {
          accumulatedResult[index] = response.collectionProducts;
        } else {
          accumulatedResult.add(response.collectionProducts);
        }
        if (collectionProducts.length == 0 && !isActionBarHidden) {
          _isActionBarHidden = true;
        }
        notifyListeners();
      },
      startIndex: collectionProducts.length,
      limit: 15,
    ));
  }

  void listByProductId() {
    requestStatusManager.loading();
    message = null;
    notifyListeners();
    _listCollectionProductsByProductIdUseCase.handle(ListCollectionProductsByProductIdUseCaseRequest(
      product.id,
      (response) {
        message = response.message;
        requestStatusManager.ok();
        final index = response.startIndex == 0 ? 0 : response.startIndex / response.limit;
        if (accumulatedResult.length > index) {
          accumulatedResult[index] = response.collectionProducts;
        } else {
          accumulatedResult.add(response.collectionProducts);
        }
        if (collectionProducts.length == 0 && !isActionBarHidden) {
          _isActionBarHidden = true;
        }
        notifyListeners();
      },
      startIndex: collectionProducts.length,
      limit: 20,
    ));
  }

  void onTapProduct(String productId) async {
    if (selectedCollectionProductIds.indexOf(productId) == -1) {
      selectedCollectionProductIds.add(productId);
    } else {
      selectedCollectionProductIds.remove(productId);
    }
    notifyListeners();
  }

  void batchDelete() async {
    requestStatusManager.loading();
    message = null;
    notifyListeners();
    final collectionProductsToDelete = selectedCollectionProductIds.map((selectedCollectionProductId) {
      return collectionProducts.firstWhere((collectionProduct) => collectionProduct.id == selectedCollectionProductId, orElse: null);
    }).toList();
    final response = await _batchDeleteCollectionProductsUseCase.handle(BatchDeleteCollectionProductsUseCaseRequest(
      collectionProductsToDelete,
    ));
    message = response.message;
    requestStatusManager.ok();
    notifyListeners();
  }

}

