import 'package:flutter/foundation.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/use_cases/product/add_product_use_case.dart';
import 'package:hosheee/domain/use_cases/product/delete_product_use_case.dart';
import 'package:hosheee/domain/use_cases/product/get_product_use_case.dart';
import 'package:hosheee/domain/use_cases/product/update_product_use_case.dart';
import 'package:hosheee/domain/use_cases/url_metadata/get_url_metadata_use_case.dart';
import 'package:hosheee/ui/common/request_status_manager.dart';
import 'package:hosheee/ui/common/validator.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProductViewModel extends ChangeNotifier {

  Product _product = Product(null);
  Product get product => _product;
  set product(Product value) {
    _product = value;
    if (_product.id != null) {
      _isEditing = false;
    }
    webViewShouldOpen = false;
  }

  Map<String, String> errors = {
    'websiteUrl': null,
    'name': null,
  };

  String message;

  AddProductUseCase _addProductUseCase;
  UpdateProductUseCase _updateProductUseCase;
  DeleteProductUseCase _deleteProductUseCase;
  GetUrlMetadataUseCase _getUrlMetadataUseCase;
  GetProductUseCase _getProductUseCase;

  // bool _detailHidden = true;
  // bool get detailHidden => _detailHidden;
  // set detailHidden(bool value) {
  //   _detailHidden = value;
  //   notifyListeners();
  // }

  bool _isEditing = false;
  bool get isEditing => _isEditing;
  set isEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }

  bool _webViewShouldOpen = false;
  bool get webViewShouldOpen => _webViewShouldOpen;
  set webViewShouldOpen(bool value) {
    if (value && _validateWebsiteUrl(_product.websiteUrl)) {
      _webViewShouldOpen = value;
    } else {
      _webViewShouldOpen = value;
      webViewController = null;
    }
    notifyListeners();
  }
  WebViewController webViewController;

  RequestStatusManager requestStatusManager = RequestStatusManager();

  ProductViewModel(
    AddProductUseCase addProductUseCase,
    UpdateProductUseCase updateProductUseCase,
    DeleteProductUseCase deleteProductUseCase,
    GetUrlMetadataUseCase getUrlMetadataUseCase,
    GetProductUseCase getProductUseCase,
  ) {
    _addProductUseCase = addProductUseCase;
    _updateProductUseCase = updateProductUseCase;
    _deleteProductUseCase = deleteProductUseCase;
    _getUrlMetadataUseCase = getUrlMetadataUseCase;
    _getProductUseCase = getProductUseCase;
  }

  bool isReadOnly() {
    return _product.id != null && !_isEditing;
  }

  void clearErrors() {
    errors = {
      'websiteUrl': null,
      'name': null,
    };
  }

  void setName(String value) {
    _product.name = value;
    _validateName(_product.name);
    notifyListeners();
  }

  // void setTitle(String value) {
  //   _product.title = value;
  //   // notifyListeners();
  // }
  //
  void setDescription(String value) {
    _product.description = value;
    // notifyListeners();
  }

  // void setVideoUrl(String value) async {
  //   _product.videoUrl = value;
  //   // notifyListeners();
  // }


  void setWebsiteUrl(String value) async {
    _product.websiteUrl = value;
    _validateWebsiteUrl(value);
    notifyListeners();
  }

  void setProvider(String value) async {
    _product.provider = value;
    // notifyListeners();
  }

  void setImageUrl(String value) async {
    _product.imageUrl = value;
    // notifyListeners();
  }

  void setNote(String value) async {
    _product.note = value;
    // notifyListeners();
  }

  void setPrice(double value) async {
    _product.price = value;
    // notifyListeners();
  }

  Future<void> fillWithMetadata(String html) async {
    final response = await _getUrlMetadataUseCase.handle(GetUrlMetadataUseCaseRequest(_product.websiteUrl, html));
    message = response.message;
    final urlMetadata = response.urlMetadata;
    if (urlMetadata != null) {
      _product.name = urlMetadata.title ?? '';
      // _product.videoUrl = urlMetadata.video;
      // _product.title = urlMetadata.title;
      _product.description = urlMetadata.description ?? '';
      _product.note = '';
      _product.websiteUrl = urlMetadata.url ?? '';
      _product.imageUrl = urlMetadata.image ?? '';
      _product.provider = urlMetadata.publisher ?? '';
    }
    webViewShouldOpen = false;
  }

  bool _validateWebsiteUrl(String value) {
    final validator = Validator({
      'websiteUrl': value,
    }, {
      'websiteUrl': ['required', 'url'],
    });
    final result = validator.validate()[0];
    errors['websiteUrl'] = result.valid ? null : result.messages[0];
    return result.valid;
  }

  bool _validateName(String value) {
    final validator = Validator({
      'name': value,
    }, {
      'name': ['required'],
    });
    final result = validator.validate()[0];
    errors['name'] = result.valid ? null : result.messages[0];
    return result.valid;
  }

  bool _validateProduct() {
    return _validateName(_product.name) && _validateWebsiteUrl(_product.websiteUrl);
  }

  Future<void> save() async {
    if (_validateProduct() && !requestStatusManager.isLoading()) {
      message = null;
      requestStatusManager.loading();
      notifyListeners();
      if (_product.id != null) {
        final response = await _updateProductUseCase.handle(UpdateProductUseCaseRequest(_product));
        message = response.message;
      } else {
        final response = await _addProductUseCase.handle(AddProductUseCaseRequest(_product));
        message = response.message;
      }
      requestStatusManager.ok();
      notifyListeners();
    }
  }

  Future<void> delete() async {
    if (_product.id != null && !requestStatusManager.isLoading()) {
      message = null;
      requestStatusManager.loading();
      notifyListeners();
      final response = await _deleteProductUseCase.handle(DeleteProductUseCaseRequest(_product));
      message = response.message;
      requestStatusManager.ok();
      notifyListeners();
    }
  }

  Future<Product> get(String productId) async {
    message = null;
    final response = await _getProductUseCase.handle(GetProductUseCaseRequest(productId));
    message = response.message;
    if (message != null) {
      notifyListeners();
    }
    return response.product;
  }
}

