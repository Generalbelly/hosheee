import 'package:provider/provider.dart';
import 'package:wish_list/adapter/gateway/auth.dart';
import 'package:wish_list/adapter/gateway/collection/collection_repository.dart';
import 'package:wish_list/adapter/gateway/product/product_repository.dart';
import 'package:wish_list/domain/use_cases/product/add_product_use_case.dart';
import 'package:wish_list/ui/view_models/collection_view_model.dart';
import 'package:wish_list/ui/view_models/home_view_model.dart';
import 'package:wish_list/ui/view_models/product_view_model.dart';
import 'package:wish_list/ui/view_models/sign_in_view_model.dart';
import 'package:wish_list/ui/view_models/sign_up_view_model.dart';
import 'package:wish_list/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:wish_list/domain/models/auth.dart' as i_auth;
import 'package:wish_list/domain/use_cases/collection/list_collections_use_case.dart';
import 'package:wish_list/domain/use_cases/auth/sign_in_use_case.dart';
import 'package:wish_list/domain/use_cases/auth/sign_up_use_case.dart';
import 'package:wish_list/domain/repositories/collection_repository.dart' as i_collection_repository;
import 'package:wish_list/domain/repositories/product_repository.dart' as i_product_repository;
import 'package:wish_list/domain/use_cases/collection/add_collection_use_case.dart';
import 'package:wish_list/ui/views/create_collection_view.dart';
import 'package:wish_list/ui/views/create_product_view.dart';
import 'package:wish_list/ui/views/home_view.dart';
import 'package:wish_list/ui/views/sign_up_view.dart';
import 'package:wish_list/ui/views/sign_in_view.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;

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
        Provider<ListCollectionsUseCase>(
          create: (context) => ListCollectionsUseCase(
              Provider.of<i_auth.Auth>(context, listen: false),
              Provider.of<i_collection_repository.CollectionRepository>(context, listen: false),
          ),
        ),
        Provider<AddCollectionUseCase>(
          create: (context) => AddCollectionUseCase(
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
        ChangeNotifierProvider<SignInViewModel>(
          create: (context) => SignInViewModel(Provider.of<SignInUseCase>(context, listen: false)),
        ),
        ChangeNotifierProvider<SignUpViewModel>(
          create: (context) => SignUpViewModel(Provider.of<SignUpUseCase>(context, listen: false)),
        ),
        ChangeNotifierProvider<CollectionViewModel>(
          create: (context) => CollectionViewModel(
              Provider.of<ListCollectionsUseCase>(context, listen: false),
              Provider.of<AddCollectionUseCase>(context, listen: false)),
        ),
        ChangeNotifierProvider<ProductViewModel>(
          create: (context) => ProductViewModel(
              Provider.of<AddProductUseCase>(context, listen: false)),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(Provider.of<i_auth.Auth>(context, listen: false)),
        ),
      ],
      child: MaterialApp(
        title: 'wish',
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
          }
          return null;
        },
      ),
    );
  }
}
