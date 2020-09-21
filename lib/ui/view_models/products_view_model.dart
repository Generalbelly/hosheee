import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/use_cases/product/list_products_use_case.dart';
import 'package:wish_list/ui/mixins/request_status_manager.dart';

class ProductsViewModel extends ChangeNotifier {

  String message;

  List<Product> products = [];

  ListProductsUseCase _listProductsUseCase;

  ScrollController scrollController = ScrollController();
  bool _scrollControllerListenerAdded = false;

  // List<ImageLoadingStatusManager> imageLoadingStatusManagers = [];
  // bool allImagesLoaded = false;

  RequestStatusManager requestStatusManager = RequestStatusManager();

  ProductsViewModel(
    ListProductsUseCase listProductsUseCase,
  ) {
    _listProductsUseCase = listProductsUseCase;
    listRecent();
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange && !requestStatusManager.isLoading()) {
      listRecent();
    }
  }

  // void imageLoadingDone(String url) {
  //   final imageLoadingStatus = imageLoadingStatusManagers.firstWhere((imageLoadingStatus) => imageLoadingStatus.url == url, orElse: () => null);
  //   if (imageLoadingStatus != null) {
  //     imageLoadingStatus.ok();
  //   }
  //   if (!allImagesLoaded) {
  //     allImagesLoaded = _checkIfImageLoadingAllDone();
  //     if (allImagesLoaded) {
  //       notifyListeners();
  //     }
  //   }
  // }

  // bool _checkIfImageLoadingAllDone() {
  //   imageLoadingStatusManagers.forEach((imageLoadingStatus) {
  //     if (!imageLoadingStatus.isOk()) {
  //       return false;
  //     }
  //   });
  //   return true;
  // }

  void listRecent() {
    if (!_scrollControllerListenerAdded) {
      scrollController.addListener(_scrollListener);
      _scrollControllerListenerAdded = true;
    }
    requestStatusManager.loading();
    notifyListeners();
    _listProductsUseCase.handle(ListProductsUseCaseRequest(
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

