import 'package:flutter/foundation.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/use_cases/product/add_product_use_case.dart';
import 'package:wish_list/domain/use_cases/url_metadata/get_url_metadata_use_case.dart';
import 'package:wish_list/utils/validator.dart';

class ProductViewModel extends ChangeNotifier {

  Product product = Product(null, '');
  Map<String, String> errors = {
    'websiteUrl': null,
    'name': null,
  };

  String message;

  List<Product> products = [];

  AddProductUseCase _addProductUseCase;
  GetUrlMetadataUseCase _getUrlMetadataUseCase;

  ProductViewModel(
      AddProductUseCase addProductUseCase,
      GetUrlMetadataUseCase getUrlMetadataUseCase) {
    _addProductUseCase = addProductUseCase;
    _getUrlMetadataUseCase = getUrlMetadataUseCase;
  }

  setName(String value) {
    product.name = value;
    _validateName(product.name);
    notifyListeners();
  }

  setWebsiteUrl(String value) async {
    product.websiteUrl = value;
    final valid = _validateWebsiteUrl(product.websiteUrl);
    print(valid);
    if (valid) {
      final response = await _getUrlMetadataUseCase.handle(GetUrlMetadataUseCaseRequest(product.websiteUrl));
    }
    notifyListeners();
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

  create() async {
    final nameValid = _validateName(product.name);
    message = null;
    if (nameValid) {
      final response = await _addProductUseCase.handle(
          AddProductUseCaseRequest(product));
      message = response.message;
    }
    notifyListeners();
  }

  update() async {
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

