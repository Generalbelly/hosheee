import 'package:flutter/foundation.dart';
import 'package:wish_list/domain/models/collection.dart';
import 'package:wish_list/domain/use_cases/collection/add_collection_use_case.dart';
import 'package:wish_list/domain/use_cases/collection/list_collections_use_case.dart';
import 'package:wish_list/utils/validator.dart';

class CollectionViewModel extends ChangeNotifier {

  Collection collection = Collection(null, '');
  String nameErrorMessage;

  String message;

  List<Collection> collections = [];

  AddCollectionUseCase _addCollectionUseCase;
  ListCollectionsUseCase _listCollectionsUseCase;

  CollectionViewModel(
      ListCollectionsUseCase listCollectionsUseCase,
      AddCollectionUseCase createCollectionUseCase) {
    _listCollectionsUseCase = listCollectionsUseCase;
    _addCollectionUseCase = createCollectionUseCase;
    if (collections.length == 0) {
      list();
    }
  }

  setName(String value) {
    collection.name = value;
    _validateName(collection.name);
    notifyListeners();
  }

  bool _validateName(String value) {
    final validator = Validator({
      'name': value,
    }, {
      'name': ['required'],
    });
    final result = validator.validate()[0];
    nameErrorMessage = result.valid ? null : result.messages[0];
    return result.valid;
  }

  create() async {
    final nameValid = _validateName(collection.name);
    message = null;
    if (nameValid) {
      final response = await _addCollectionUseCase.handle(
          AddCollectionUseCaseRequest(collection));
      message = response.message;
    }
    notifyListeners();
  }

  update() async {
//    final nameValid = _validateName();
//    message = null;
//    if (nameValid) {
//      final response = await _createCollectionUseCase.handle(
//          AddCollectionUseCaseRequest(name));
//      message = response.message;
//    }
//    notifyListeners();
  }

  list() async {
    final response = await _listCollectionsUseCase.handle(
        ListCollectionsUseCaseRequest());
    collections = response.collections;
    print(collections);
    message = response.message;
    notifyListeners();
  }
}

