import 'package:firebase_admob/firebase_admob.dart';
import 'package:hosheee/ad_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/domain/models/collection_product.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/use_cases/collection_product/batch_upsert_collection_products_use_case.dart';
import 'package:hosheee/domain/use_cases/product/list_products_use_case.dart';
import 'package:hosheee/ui/common/request_status_manager.dart';

class ProductsViewModel extends ChangeNotifier {

  String message;

  List<List<Product>> accumulatedResult = [];

  List<Product> get products {
    return accumulatedResult.expand((ps) => ps).toList();
  }

  ListProductsUseCase _listProductsUseCase;

  BatchUpsertCollectionProductsUseCase _batchUpsertCollectionProductsUseCase;

  ScrollController scrollController = ScrollController();

  RequestStatusManager requestStatusManager = RequestStatusManager();

  List<String> selectedProductIds = [];

  BannerAd _bannerAd;

  ProductsViewModel(
    ListProductsUseCase listProductsUseCase,
    BatchUpsertCollectionProductsUseCase batchUpsertCollectionProductsUseCase,
  ) {
    _listProductsUseCase = listProductsUseCase;
    _batchUpsertCollectionProductsUseCase = batchUpsertCollectionProductsUseCase;
    scrollController.addListener(_scrollListener);
    list();

    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.banner,
    );
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.bottom);
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
        final index = response.startIndex == 0 ? 0 : response.startIndex ~/ response.limit;
        if (accumulatedResult.length > index) {
          accumulatedResult[index] = response.products;
        } else {
          accumulatedResult.add(response.products);
        }
        notifyListeners();
      },
      startIndex: accumulatedResult.length == 0 ? 0 : (accumulatedResult.where((result) => result.length > 0).length * 20).toInt(),
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

  Future<void> saveCollectionProducts(Collection collection) async {
    final collectionProducts = selectedProductIds.map((selectedProductId) {
      final product = products.firstWhere((product) => product.id == selectedProductId, orElse: null);
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

