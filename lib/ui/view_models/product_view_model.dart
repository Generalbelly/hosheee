import 'package:flutter/foundation.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/use_cases/product/add_product_use_case.dart';
import 'package:wish_list/domain/use_cases/url_metadata/get_url_metadata_use_case.dart';
import 'package:wish_list/ui/mixins/request_status_manager.dart';
import 'package:wish_list/utils/validator.dart';

class ProductViewModel extends ChangeNotifier with RequestStatusManager {

  Product product = Product(null, '');
  Map<String, String> errors = {
    'websiteUrl': null,
    'name': null,
  };

  String message;

  AddProductUseCase _addProductUseCase;
  GetUrlMetadataUseCase _getUrlMetadataUseCase;

  bool _detailHidden = true;
  bool get detailHidden => _detailHidden;
  set detailHidden(bool value) {
    _detailHidden = value;
    notifyListeners();
  }

  ProductViewModel(
    AddProductUseCase addProductUseCase,
    GetUrlMetadataUseCase getUrlMetadataUseCase
  ) {
    _addProductUseCase = addProductUseCase;
    _getUrlMetadataUseCase = getUrlMetadataUseCase;
  }

  // void setProduct(Product value) {
  //   product = value;
  //   clearErrors();
  // }

  void clearErrors() {
    errors = {
      'websiteUrl': null,
      'name': null,
    };
  }

  void setName(String value) {
    product.name = value;
    _validateName(product.name);
    // notifyListeners();
  }

  // void setTitle(String value) {
  //   product.title = value;
  //   // notifyListeners();
  // }
  //
  // void setDescription(String value) {
  //   product.title = value;
  //   // notifyListeners();
  // }
  //
  // void setVideoUrl(String value) async {
  //   product.videoUrl = value;
  //   // notifyListeners();
  // }


  void setWebsiteUrl(String value) async {
    product.websiteUrl = value;
    notifyListeners();
  }

  void setProvider(String value) async {
    product.provider = value;
    // notifyListeners();
  }

  void setImageUrl(String value) async {
    product.imageUrl = value;
    // notifyListeners();
  }

  void setNote(String value) async {
    product.note = value;
    // notifyListeners();
  }

  void setPrice(double value) async {
    product.price = value;
    // notifyListeners();
  }

  Future<bool> fillWithMetadata() async {
    if (_validateWebsiteUrl(product.websiteUrl)) {
      final response = await _getUrlMetadataUseCase.handle(GetUrlMetadataUseCaseRequest(product.websiteUrl));
      message = response.message;
      final urlMetadata = response.urlMetadata;
      if (urlMetadata != null) {
        print(urlMetadata.url);
        print(urlMetadata.image);
        product.name = urlMetadata.title;
        // product.videoUrl = urlMetadata.video;
        // product.title = urlMetadata.title;
        // product.description = urlMetadata.description;
        product.note = urlMetadata.description;
        product.websiteUrl = urlMetadata.url;
        product.imageUrl = urlMetadata.image;
        product.provider = urlMetadata.publisher;
      }
      return true;
    }
    return false;
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
    return _validateName(product.name) && _validateWebsiteUrl(product.websiteUrl);
  }

  Future<void> create() async {
    message = null;
    if (_validateProduct()) {
      final response = await _addProductUseCase.handle(
          AddProductUseCaseRequest(product));
      message = response.message;
    }
    notifyListeners();
  }

  Future<void> update() async {
//    final nameValid = _validateName();
//    message = null;
//    if (nameValid) {
//      final response = await _createProductUseCase.handle(
//          AddProductUseCaseRequest(name));
//      message = response.message;
//    }
//    notifyListeners();
  }

}

