import 'package:flutter/foundation.dart';
import 'package:wish_list/domain/models/collection.dart';
import 'package:wish_list/domain/use_cases/collection/add_collection_use_case.dart';
import 'package:wish_list/domain/use_cases/collection/delete_collection_use_case.dart';
import 'package:wish_list/domain/use_cases/collection/update_collection_use_case.dart';
import 'package:wish_list/ui/mixins/request_status_manager.dart';
import 'package:wish_list/utils/validator.dart';

class CollectionViewModel extends ChangeNotifier with RequestStatusManager {

  Collection _collection = Collection(null);
  Collection get collection => _collection;
  set collection(Collection value) {
    _collection = value;
    if (_collection.id != null) {
      _isEditing = false;
    }
  }

  Map<String, String> errors = {
    'name': null,
  };

  String message;

  AddCollectionUseCase _addCollectionUseCase;
  UpdateCollectionUseCase _updateCollectionUseCase;
  DeleteCollectionUseCase _deleteCollectionUseCase;

  bool _detailHidden = true;
  bool get detailHidden => _detailHidden;
  set detailHidden(bool value) {
    _detailHidden = value;
    notifyListeners();
  }

  bool _isEditing = false;
  bool get isEditing => _isEditing;
  set isEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }

  bool isReadOnly() {
    return _collection.id != null && !_isEditing;
  }

  CollectionViewModel(
    AddCollectionUseCase addCollectionUseCase,
    UpdateCollectionUseCase updateCollectionUseCase,
    DeleteCollectionUseCase deleteCollectionUseCase,
  ) {
    _addCollectionUseCase = addCollectionUseCase;
    _updateCollectionUseCase = updateCollectionUseCase;
    _deleteCollectionUseCase = deleteCollectionUseCase;
  }

  void clearErrors() {
    errors = {
      'name': null,
    };
  }

  void setName(String value) {
    _collection.name = value;
    _validateName(_collection.name);
    notifyListeners();
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

  bool _validateCollection() {
    return _validateName(_collection.name);
  }

  Future<void> save() async {
    message = null;
    if (_validateCollection()) {
      if (_collection.id != null) {
        final response = await _updateCollectionUseCase.handle(UpdateCollectionUseCaseRequest(_collection));
        message = response.message;
      } else {
        final response = await _addCollectionUseCase.handle(AddCollectionUseCaseRequest(_collection));
        message = response.message;
      }
    }
    notifyListeners();
  }

  Future<void> delete() async {
    message = null;
    if (_collection.id != null) {
      final response = await _deleteCollectionUseCase.handle(DeleteCollectionUseCaseRequest(_collection));
      message = response.message;
    }
    notifyListeners();
  }

}

