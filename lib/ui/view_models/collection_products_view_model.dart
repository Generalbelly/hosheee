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

  List<List<CollectionProduct>> accumulatedResultByCollectionId = [];
  List<List<CollectionProduct>> accumulatedResultByProductId = [];

  List<CollectionProduct> get collectionProductsByCollectionId {
    return accumulatedResultByCollectionId.expand((ps) => ps).toList();
  }

  List<CollectionProduct> get collectionProductsByProductId {
    return accumulatedResultByProductId.expand((ps) => ps).toList();
  }

  Collection _collection;
  Collection get collection => _collection;
  set collection(Collection value) {
    _collection = value;
    accumulatedResultByCollectionId = [];
    notifyListeners();
    listByCollectionId();
  }

  Product _product;
  Product get product => _product;
  set product(Product value) {
    _product = value;
    accumulatedResultByProductId = [];
    notifyListeners();
    listByProductId();
  }

  Map<String, String> reloadKeys = {};

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

  List<String> collectionProductIdsToDelete = [];

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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }


  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange && !requestStatusManager.isLoading()) {
      listByCollectionId();
    }
  }

  void listByCollectionId() {
    if (collection.id == null) return;
    requestStatusManager.loading();
    message = null;
    notifyListeners();
    _listCollectionProductsByCollectionIdUseCase.handle(ListCollectionProductsByCollectionIdUseCaseRequest(
      collection.id,
      (response) {
        message = response.message;
        requestStatusManager.ok();
        final index = response.startIndex == 0 ? 0 : response.startIndex ~/ response.limit;
        if (accumulatedResultByCollectionId.length > index) {
          accumulatedResultByCollectionId[index] = response.collectionProducts;
        } else {
          accumulatedResultByCollectionId.add(response.collectionProducts);
        }
        if (collectionProductsByCollectionId.length == 0 && !isActionBarHidden) {
          _isActionBarHidden = true;
        }
        // collectionProductsByCollectionId.map((cp) => cp.id).forEach((id) {
        //   if (collection.collectionProductIds.indexOf(id) == -1) {
        //     collection.collectionProductIds.add(id);
        //   }
        // });
        notifyListeners();
      },
      startIndex: accumulatedResultByCollectionId.length == 0 ? 0 : (accumulatedResultByCollectionId.where((result) => result.length > 0).length * 20).toInt(),
      limit: 20,
    ));
  }

  void listByProductId() {
    if (product.id == null) return;
    requestStatusManager.loading();
    message = null;
    notifyListeners();
    _listCollectionProductsByProductIdUseCase.handle(ListCollectionProductsByProductIdUseCaseRequest(
      product.id,
      (response) {
        message = response.message;
        requestStatusManager.ok();
        final index = response.startIndex == 0 ? 0 : response.startIndex ~/ response.limit;
        if (accumulatedResultByProductId.length > index) {
          accumulatedResultByProductId[index] = response.collectionProducts;
        } else {
          accumulatedResultByProductId.add(response.collectionProducts);
        }
        if (collectionProductsByProductId.length == 0 && !isActionBarHidden) {
          _isActionBarHidden = true;
        }
        collectionProductsByProductId.map((cp) => cp.collectionId).forEach((id) {
          if (product.collectionIds.indexOf(id) == -1) {
            product.collectionIds.add(id);
          }
        });
        notifyListeners();
      },
      startIndex: collectionProductsByProductId.length,
      limit: 20,
    ));
  }

  void onTapCollectionProductToDelete(String collectionProductId) async {
    if (collectionProductIdsToDelete.indexOf(collectionProductId) == -1) {
      collectionProductIdsToDelete.add(collectionProductId);
    } else {
      collectionProductIdsToDelete.remove(collectionProductId);
    }
    notifyListeners();
  }

  String generateProductKey(CollectionProduct collectionProduct) {
    final reloadKey = reloadKeys[collectionProduct.id] ?? '';
    return collectionProduct.id+reloadKey;
  }

  reloadImage(CollectionProduct collectionProduct) {
    reloadKeys[collectionProduct.id] = DateTime.now().millisecondsSinceEpoch.toInt().toString();
    notifyListeners();
  }

  void batchDelete() async {
    requestStatusManager.loading();
    message = null;
    notifyListeners();
    final collectionProductsToDelete = collectionProductIdsToDelete.map((selectedCollectionProductId) {
      return collectionProductsByCollectionId.firstWhere((collectionProduct) => collectionProduct.id == selectedCollectionProductId, orElse: () => null);
    }).toList();
    final response = await _batchDeleteCollectionProductsUseCase.handle(BatchDeleteCollectionProductsUseCaseRequest(
      collectionProductsToDelete,
    ));
    message = response.message;
    requestStatusManager.ok();
    notifyListeners();
  }

}

