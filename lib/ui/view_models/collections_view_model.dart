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

  List<List<Collection>> accumulatedResult = [];

  List<Collection> get collections {
    return accumulatedResult.expand((ps) => ps).toList();
  }

  ListCollectionsUseCase _listCollectionsUseCase;

  BatchUpsertCollectionProductsUseCase _batchUpsertCollectionProductsUseCase;

  ScrollController scrollController = ScrollController();

  RequestStatusManager requestStatusManager = RequestStatusManager();

  Map<String, String> reloadKeys = {};

  CollectionsViewModel(
    ListCollectionsUseCase listCollectionsUseCase,
    BatchUpsertCollectionProductsUseCase batchUpsertCollectionProductsUseCase,
  ) {
    _listCollectionsUseCase = listCollectionsUseCase;
    _batchUpsertCollectionProductsUseCase = batchUpsertCollectionProductsUseCase;
    scrollController.addListener(_scrollListener);
    list();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
    _listCollectionsUseCase.handle(ListCollectionsUseCaseRequest(
          (response) {
        message = response.message;
        requestStatusManager.ok();
        final index = response.startIndex == 0 ? 0 : response.startIndex ~/ response.limit;
        if (accumulatedResult.length > index) {
          accumulatedResult[index] = response.collections;
        } else {
          accumulatedResult.add(response.collections);
        }
        notifyListeners();
      },
      startIndex: accumulatedResult.length == 0 ? 0 : (accumulatedResult.where((result) => result.length > 0).length * 20).toInt(),
      limit: 20,
    ));
  }

  String generateCollectionKey(Collection collection) {
    final reloadKey = reloadKeys[collection.id] ?? '';
    return collection.id+reloadKey;
  }

  reloadImage(Collection collection) {
    reloadKeys[collection.id] = DateTime.now().millisecondsSinceEpoch.toInt().toString();
    notifyListeners();
  }

  Future<void> saveCollectionProducts(Product product) async {
    final collectionProducts = product.collectionIds.map((selectedCollectionId) {
      final collection = collections.firstWhere((collection) => collection.id == selectedCollectionId, orElse: () => null);
      return CollectionProduct(null,
        collectionName: collection.name,
        collectionImageUrl: collection.imageUrl,
        productName: product.name,
        productImageUrl: product.imageUrl,
        productId: product.id,
        collectionId: collection.id);
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

