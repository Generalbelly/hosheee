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

  List<ImageLoadingStatus> imageLoadingStatuses = [];
  bool allImagesLoaded = false;

  ProductsViewModel(
    ListProductsUseCase listProductsUseCase,
  ) {
    _listProductsUseCase = listProductsUseCase;
    listRecent();
  }

  void _scrollListener() {
    print("at the end of list");
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      print("at the end of list");
      listRecent();
    }
  }

  void imageLoadingDone(String url) {
    final imageLoadingStatus = imageLoadingStatuses.firstWhere((imageLoadingStatus) => imageLoadingStatus.url == url, orElse: () => null);
    if (imageLoadingStatus != null) {
      imageLoadingStatus.ok();
    }
    if (!allImagesLoaded) {
      allImagesLoaded = _checkIfImageLoadingAllDone();
      if (allImagesLoaded) {
        notifyListeners();
      }
    }
  }

  bool _checkIfImageLoadingAllDone() {
    imageLoadingStatuses.forEach((imageLoadingStatus) {
      if (!imageLoadingStatus.isOk()) {
        return false;
      }
    });
    return true;
  }

  Future<void> listRecent() async {
    if (!_scrollControllerListenerAdded) {
      scrollController.addListener(_scrollListener);
      _scrollControllerListenerAdded = true;
    }
    allImagesLoaded = false;
    final response = await _listProductsUseCase.handle(ListProductsUseCaseRequest(
      limit: 15,
    ));
    message = response.message;
    response.products.forEach((product) {
      if (product.websiteUrl != null) {
        imageLoadingStatuses.add(ImageLoadingStatus(product.websiteUrl));
      }
    });
    products.addAll(response.products);
    notifyListeners();
  }

}

