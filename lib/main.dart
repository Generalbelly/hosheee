import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wish_list/adapter/gateway/auth.dart';
import 'package:wish_list/adapter/gateway/collection/collection_repository.dart';
import 'package:wish_list/adapter/gateway/product/product_repository.dart';
import 'package:wish_list/adapter/gateway/url_metadata/url_metadata_repository.dart';
import 'package:wish_list/domain/use_cases/product/add_product_use_case.dart';
import 'package:wish_list/domain/use_cases/product/delete_product_use_case.dart';
import 'package:wish_list/domain/use_cases/product/list_products_use_case.dart';
import 'package:wish_list/domain/use_cases/product/update_product_use_case.dart';
import 'package:wish_list/domain/use_cases/url_metadata/get_url_metadata_use_case.dart';
import 'package:wish_list/ui/view_models/collection_view_model.dart';
import 'package:wish_list/ui/view_models/home_view_model.dart';
import 'package:wish_list/ui/view_models/product_view_model.dart';
import 'package:wish_list/ui/view_models/products_view_model.dart';
import 'package:wish_list/ui/view_models/sign_in_view_model.dart';
import 'package:wish_list/ui/view_models/sign_up_view_model.dart';
import 'package:wish_list/common/theme.dart';
import 'package:wish_list/domain/models/auth.dart' as i_auth;
import 'package:wish_list/domain/use_cases/collection/list_collections_use_case.dart';
import 'package:wish_list/domain/use_cases/auth/sign_in_use_case.dart';
import 'package:wish_list/domain/use_cases/auth/sign_up_use_case.dart';
import 'package:wish_list/domain/repositories/collection_repository.dart' as i_collection_repository;
import 'package:wish_list/domain/repositories/product_repository.dart' as i_product_repository;
import 'package:wish_list/domain/repositories/url_metadata_repository.dart' as i_url_metadata_repository;
import 'package:wish_list/domain/use_cases/collection/add_collection_use_case.dart';
import 'package:wish_list/ui/views/create_collection_view.dart';
import 'package:wish_list/ui/views/create_product_view.dart';
import 'package:wish_list/ui/views/home_view.dart';
import 'package:wish_list/ui/views/sign_up_view.dart';
import 'package:wish_list/ui/views/sign_in_view.dart';

class EnvironmentConfig {
  static const BUNDLE_ID_SUFFIX = String.fromEnvironment('BUNDLE_ID_SUFFIX');
  static const APP_ENV = String.fromEnvironment('APP_ENV');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  await Firebase.initializeApp();
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
        Provider<ListProductsUseCase>(
          create: (context) => ListProductsUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_product_repository.ProductRepository>(context, listen: false),
          ),
        ),
        Provider<AddCollectionUseCase>(
          create: (context) => AddCollectionUseCase(
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
        ChangeNotifierProvider<SignInViewModel>(
          create: (context) => SignInViewModel(Provider.of<SignInUseCase>(context, listen: false)),
        ),
        ChangeNotifierProvider<SignUpViewModel>(
          create: (context) => SignUpViewModel(Provider.of<SignUpUseCase>(context, listen: false)),
        ),
        ChangeNotifierProvider<CollectionViewModel>(
          create: (context) => CollectionViewModel(
              Provider.of<AddCollectionUseCase>(context, listen: false)),
        ),
        ChangeNotifierProvider<ProductViewModel>(
          create: (context) => ProductViewModel(
              Provider.of<AddProductUseCase>(context, listen: false),
              Provider.of<UpdateProductUseCase>(context, listen: false),
              Provider.of<DeleteProductUseCase>(context, listen: false),
              Provider.of<GetUrlMetadataUseCase>(context, listen: false)
          ),
        ),
        ChangeNotifierProvider<ProductsViewModel>(
          create: (context) => ProductsViewModel(
            Provider.of<ListProductsUseCase>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(
              Provider.of<i_auth.Auth>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'wish_list',
        theme: appTheme,
        initialRoute: '/',
        home: HomeView(),
        routes: {
          '/sign-up': (context) => SignUpView(),
          '/sign-in': (context) => SignInView(),
          '/products/create': (context) => CreateProductView(),
        },
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/collections/create':
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return CreateCollectionView();
                },
              );
              break;
            default:
              return MaterialPageRoute(builder: (_) {
                return Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                );
              });
          }
        },
      ),
    );
  }
}
