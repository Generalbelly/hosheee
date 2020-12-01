import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:hosheee/ad/ad_manager.dart';
import 'package:hosheee/adapter/gateway/collection_product/collection_product_repository.dart';
import 'package:hosheee/adapter/gateway/setting/setting_repository.dart';
import 'package:hosheee/domain/use_cases/collection_product/batch_upsert_collection_products_use_case.dart';
import 'package:hosheee/domain/use_cases/collection_product/batch_delete_collection_products_use_case.dart';
import 'package:hosheee/domain/use_cases/collection_product/list_collection_products_by_collection_id_use_case.dart';
import 'package:hosheee/domain/use_cases/collection_product/list_collection_products_by_product_id_use_case.dart';
import 'package:hosheee/domain/use_cases/product/get_product_use_case.dart';
import 'package:hosheee/domain/use_cases/setting/add_setting_use_case.dart';
import 'package:hosheee/domain/use_cases/setting/get_setting_use_case.dart';
import 'package:hosheee/domain/use_cases/setting/update_setting_use_case.dart';
import 'package:hosheee/ui/view_models/setting_view_model.dart';
import 'package:hosheee/ui/views/app_view.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hosheee/adapter/gateway/auth.dart';
import 'package:hosheee/adapter/gateway/collection/collection_repository.dart';
import 'package:hosheee/adapter/gateway/product/product_repository.dart';
import 'package:hosheee/adapter/gateway/url_metadata/url_metadata_repository.dart';
import 'package:hosheee/domain/use_cases/collection/delete_collection_use_case.dart';
import 'package:hosheee/domain/use_cases/collection/update_collection_use_case.dart';
import 'package:hosheee/domain/use_cases/product/add_product_use_case.dart';
import 'package:hosheee/domain/use_cases/product/delete_product_use_case.dart';
import 'package:hosheee/domain/use_cases/product/list_products_use_case.dart';
import 'package:hosheee/domain/use_cases/product/update_product_use_case.dart';
import 'package:hosheee/domain/use_cases/url_metadata/get_url_metadata_use_case.dart';
import 'package:hosheee/ui/view_models/collection_view_model.dart';
import 'package:hosheee/ui/view_models/collections_view_model.dart';
import 'package:hosheee/ui/view_models/home_view_model.dart';
import 'package:hosheee/ui/view_models/product_view_model.dart';
import 'package:hosheee/ui/view_models/collection_products_view_model.dart';
import 'package:hosheee/ui/view_models/products_view_model.dart';
import 'package:hosheee/ui/view_models/sign_in_view_model.dart';
import 'package:hosheee/ui/view_models/sign_up_view_model.dart';
import 'package:hosheee/domain/models/auth.dart' as i_auth;
import 'package:hosheee/domain/use_cases/collection/list_collections_use_case.dart';
import 'package:hosheee/domain/use_cases/auth/sign_in_use_case.dart';
import 'package:hosheee/domain/use_cases/auth/sign_up_use_case.dart';
import 'package:hosheee/domain/repositories/collection_repository.dart' as i_collection_repository;
import 'package:hosheee/domain/repositories/product_repository.dart' as i_product_repository;
import 'package:hosheee/domain/repositories/url_metadata_repository.dart' as i_url_metadata_repository;
import 'package:hosheee/domain/repositories/collection_product_repository.dart' as i_collection_product_repository;
import 'package:hosheee/domain/repositories/setting_repository.dart' as i_setting_repository;
import 'package:hosheee/domain/use_cases/collection/add_collection_use_case.dart';

class EnvironmentConfig {
  static const BUILD_ENV = String.fromEnvironment('BUILD_ENV');
  static const CONTACT_FORM_URL = 'https://docs.google.com/forms/d/e/1FAIpQLSeygm_CYpX6i_lyEu17vgaubtB9VnpIrkBmHGiTdyX9sv3nnA/viewform';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  await Firebase.initializeApp();
  await FirebaseAdMob.instance.initialize(appId: AdManager.appId);
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Using MultiProvider is convenient when providing multiple objects.
    return MultiProvider(
      providers: [
        Provider<i_auth.Auth>(
          create: (_) => Auth(),
        ),
        Provider<SignInUseCase>(
          create: (context) => SignInUseCase(Provider.of<i_auth.Auth>(context, listen: false)),
        ),
        Provider<SignUpUseCase>(
          create: (context) => SignUpUseCase(Provider.of<i_auth.Auth>(context, listen: false)),
        ),
        Provider<i_collection_repository.CollectionRepository>(
          create: (_) => CollectionRepository(),
        ),
        Provider<i_product_repository.ProductRepository>(
          create: (_) => ProductRepository(),
        ),
        Provider<i_url_metadata_repository.UrlMetadataRepository>(
          create: (_) => UrlMetadataRepository(),
        ),
        Provider<i_collection_product_repository.CollectionProductRepository>(
          create: (_) => CollectionProductRepository(),
        ),
        Provider<i_setting_repository.SettingRepository>(
          create: (_) => SettingRepository(),
        ),
        Provider<ListProductsUseCase>(
          create: (context) => ListProductsUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_product_repository.ProductRepository>(context, listen: false),
          ),
        ),
        Provider<ListCollectionProductsByCollectionIdUseCase>(
          create: (context) => ListCollectionProductsByCollectionIdUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_collection_product_repository.CollectionProductRepository>(context, listen: false),
          ),
        ),
        Provider<ListCollectionProductsByProductIdUseCase>(
          create: (context) => ListCollectionProductsByProductIdUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_collection_product_repository.CollectionProductRepository>(context, listen: false),
          ),
        ),
        Provider<BatchUpsertCollectionProductsUseCase>(
          create: (context) => BatchUpsertCollectionProductsUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_collection_product_repository.CollectionProductRepository>(context, listen: false),
          ),
        ),
        Provider<AddCollectionUseCase>(
          create: (context) => AddCollectionUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_collection_repository.CollectionRepository>(context, listen: false),
          ),
        ),
        Provider<UpdateCollectionUseCase>(
          create: (context) => UpdateCollectionUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_collection_repository.CollectionRepository>(context, listen: false),
          ),
        ),
        Provider<DeleteCollectionUseCase>(
          create: (context) => DeleteCollectionUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_collection_repository.CollectionRepository>(context, listen: false),
          ),
        ),
        Provider<ListCollectionsUseCase>(
          create: (context) => ListCollectionsUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_collection_repository.CollectionRepository>(context, listen: false),
          ),
        ),
        Provider<AddProductUseCase>(
          create: (context) => AddProductUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_product_repository.ProductRepository>(context, listen: false),
          ),
        ),
        Provider<UpdateProductUseCase>(
          create: (context) => UpdateProductUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_product_repository.ProductRepository>(context, listen: false),
          ),
        ),
        Provider<DeleteProductUseCase>(
          create: (context) => DeleteProductUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_product_repository.ProductRepository>(context, listen: false),
          ),
        ),
        Provider<GetUrlMetadataUseCase>(
          create: (context) => GetUrlMetadataUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_url_metadata_repository.UrlMetadataRepository>(context, listen: false),
          ),
        ),
        Provider<BatchUpsertCollectionProductsUseCase>(
          create: (context) => BatchUpsertCollectionProductsUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_collection_product_repository.CollectionProductRepository>(context, listen: false),
          ),
        ),
        Provider<BatchDeleteCollectionProductsUseCase>(
          create: (context) => BatchDeleteCollectionProductsUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_collection_product_repository.CollectionProductRepository>(context, listen: false),
          ),
        ),
        Provider<GetProductUseCase>(
          create: (context) => GetProductUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_product_repository.ProductRepository>(context, listen: false),
          ),
        ),
        Provider<GetSettingUseCase>(
          create: (context) => GetSettingUseCase(
            Provider.of<i_auth.Auth>(context, listen: false),
            Provider.of<i_setting_repository.SettingRepository>(context, listen: false),
          ),
        ),
        Provider<AddSettingUseCase>(
          create: (context) => AddSettingUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_setting_repository.SettingRepository>(context, listen: false),
          ),
        ),
        Provider<UpdateSettingUseCase>(
          create: (context) => UpdateSettingUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_setting_repository.SettingRepository>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<SignInViewModel>(
          create: (context) => SignInViewModel(Provider.of<SignInUseCase>(context, listen: false)),
        ),
        ChangeNotifierProvider<SignUpViewModel>(
          create: (context) => SignUpViewModel(Provider.of<SignUpUseCase>(context, listen: false)),
        ),
        ChangeNotifierProvider<CollectionViewModel>(
          create: (context) => CollectionViewModel(
              Provider.of<AddCollectionUseCase>(context, listen: false),
              Provider.of<UpdateCollectionUseCase>(context, listen: false),
              Provider.of<DeleteCollectionUseCase>(context, listen: false)
          ),
        ),
        ChangeNotifierProvider<ProductViewModel>(
          create: (context) => ProductViewModel(
              Provider.of<AddProductUseCase>(context, listen: false),
              Provider.of<UpdateProductUseCase>(context, listen: false),
              Provider.of<DeleteProductUseCase>(context, listen: false),
              Provider.of<GetUrlMetadataUseCase>(context, listen: false),
              Provider.of<GetProductUseCase>(context, listen: false)
          ),
        ),
        ChangeNotifierProvider<ProductsViewModel>(
          create: (context) => ProductsViewModel(
            Provider.of<ListProductsUseCase>(context, listen: false),
            Provider.of<BatchUpsertCollectionProductsUseCase>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<CollectionProductsViewModel>(
          create: (context) => CollectionProductsViewModel(
            Provider.of<ListCollectionProductsByCollectionIdUseCase>(context, listen: false),
            Provider.of<ListCollectionProductsByProductIdUseCase>(context, listen: false),
            Provider.of<BatchDeleteCollectionProductsUseCase>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<CollectionsViewModel>(
          create: (context) => CollectionsViewModel(
            Provider.of<ListCollectionsUseCase>(context, listen: false),
            Provider.of<BatchUpsertCollectionProductsUseCase>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(
            Provider.of<i_auth.Auth>(context, listen: false),
            Provider.of<GetSettingUseCase>(context, listen: false),
            Provider.of<AddSettingUseCase>(context, listen: false),
            Provider.of<UpdateSettingUseCase>(context, listen: false),
          ),
        ),
      ],
      child: AppView(),
    );
  }
}
