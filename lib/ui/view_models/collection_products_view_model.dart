import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/domain/models/collection_product.dart';
import 'package:hosheee/domain/use_cases/collection_product/batch_delete_collection_products_use_case.dart';
import 'package:hosheee/domain/use_cases/collection_product/list_collection_products_by_collection_id_use_case.dart';
import 'package:hosheee/ui/common/request_status_manager.dart';

class CollectionProductsViewModel extends ChangeNotifier {

  String message;

  Collection _collection;
  Collection get collection => _collection;
  set collection(Collection value) {
    _collection = value;
    list();
  }

  List<CollectionProduct> collectionProducts = [];

  List<String> selectedCollectionProductIds = [];

  ListCollectionProductsByCollectionIdUseCase _listCollectionProductsUseCase;
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
    BatchDeleteCollectionProductsUseCase batchDeleteCollectionProductsUseCase,
  ) {
    _listCollectionProductsUseCase = listCollectionProductsByCollectionIdUseCase;
    _batchDeleteCollectionProductsUseCase = batchDeleteCollectionProductsUseCase;
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
    message = null;
    notifyListeners();
    _listCollectionProductsUseCase.handle(ListCollectionProductsByCollectionIdUseCaseRequest(
      collection.id,
      (response) {
        message = response.message;
        if (requestStatusManager.isLoading()) {
          requestStatusManager.ok();
        }
        print('called');
        collectionProducts = response.collectionProducts;
        if (collectionProducts.length == 0 && !isActionBarHidden) {
          _isActionBarHidden = true;
        }
        notifyListeners();
      },
      limit: 15,
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

