import 'package:hosheee/ui/view_models/home_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:hosheee/ui/views/create_product_view.dart';
import 'package:hosheee/ui/views/home_view.dart';
import 'package:hosheee/ui/views/sign_in_view.dart';
import 'package:hosheee/ui/views/sign_up_view.dart';

class AppView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: true);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'hosheee',
      theme: ThemeData(
        primaryColor: Color(homeViewModel.setting.themeColor),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(homeViewModel.setting.themeColor),
        ),
      ),
      initialRoute: '/',
      builder: (context, child) => Container(
        margin: EdgeInsets.only(top: 80.0),
        child: child,
      ),
      routes: {
        HomeView.routeName: (context) => HomeView(),
        SignUpView.routeName: (context) => SignUpView(),
        SignInView.routeName: (context) => SignInView(),
        CreateProductView.routeName: (context) => CreateProductView(),
      },
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
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
    );
  }
}
