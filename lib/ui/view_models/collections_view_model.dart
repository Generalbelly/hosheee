import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/domain/models/collection_product.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/use_cases/collection/list_collections_use_case.dart';
import 'package:hosheee/domain/use_cases/collection_product/batch_upsert_collection_products_use_case.dart';
import 'package:hosheee/ui/common/request_status_manager.dart';

class CollectionsViewModel extends ChangeNotifier {

  String message;

  List<Collection> collections = [];

  ListCollectionsUseCase _listCollectionsUseCase;

  BatchUpsertCollectionProductsUseCase _batchUpsertCollectionProductsUseCase;

  ScrollController collectionsViewScrollController = ScrollController();

  ScrollController productViewScrollController = ScrollController();

  RequestStatusManager requestStatusManager = RequestStatusManager();

  List<String> selectedCollectionIds = [];

  CollectionsViewModel(
    ListCollectionsUseCase listCollectionsUseCase,
    BatchUpsertCollectionProductsUseCase batchUpsertCollectionProductsUseCase,
  ) {
    _listCollectionsUseCase = listCollectionsUseCase;
    _batchUpsertCollectionProductsUseCase = batchUpsertCollectionProductsUseCase;
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

  void onTapCollection(String collectionId) async {
    if (selectedCollectionIds.indexOf(collectionId) == -1) {
      selectedCollectionIds.add(collectionId);
    } else {
      selectedCollectionIds.remove(collectionId);
    }
    notifyListeners();
  }

  Future<void> addCollectionProducts(Product product) async {
    final collectionProducts = selectedCollectionIds.map((selectedCollectionId) {
      final collection = collections.firstWhere((collection) => collection.id == selectedCollectionId, orElse: null);
      return CollectionProduct(null, name: product.name, imageUrl: product.imageUrl, productId: product.id, collectionId: collection.id);
    }).toList();
    message = null;
    final response = await _batchUpsertCollectionProductsUseCase.handle(
        BatchUpsertCollectionProductsUseCaseRequest(collectionProducts)
    );
    message = response.message;
    if (message != null) {
      notifyListeners();
    }
  }

}

