import 'package:flutter/foundation.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/use_cases/product/add_product_use_case.dart';
import 'package:wish_list/utils/validator.dart';

class ProductViewModel extends ChangeNotifier {

  Product product = Product(null, '');
  String urlErrorMessage;

  String message;

  List<Product> products = [];

  AddProductUseCase _addProductUseCase;

  ProductViewModel(
      AddProductUseCase addProductUseCase) {
    _addProductUseCase = addProductUseCase;
  }

  setName(String value) {
    product.name = value;
    _validateName(product.name);
    notifyListeners();
  }

  bool _validateName(String value) {
    final validator = Validator({
      'name': value,
    }, {
      'name': ['required'],
    });
    final result = validator.validate()[0];
    urlErrorMessage = result.valid ? null : result.messages[0];
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

