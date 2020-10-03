import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hosheee/ui/view_models/home_view_model.dart';
import 'package:hosheee/ui/view_models/sign_in_view_model.dart';
import 'package:hosheee/ui/views/progress_modal.dart';

class SignInView extends StatelessWidget {

  _showSnackBar(BuildContext context, String message, Function cb) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: () => cb(context),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final signInViewModel = Provider.of<SignInViewModel>(context);
    final homeViewModel = Provider.of<HomeViewModel>(context);
    if (homeViewModel.user != null) {
      Navigator.pushReplacementNamed(context, '/');
    }

    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          if (signInViewModel.message != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showSnackBar(context, signInViewModel.message, (ctx) {
                Scaffold.of(ctx).hideCurrentSnackBar();
              });
              signInViewModel.message = null;
            });
          }
          return ProgressModal(isLoading: signInViewModel.requestStatusManager.isLoading(), child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 72.0),
                    child: SizedBox(
                      height: 100,
                      child: Image.asset("assets/images/logo.png")
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Email',
                      errorText: signInViewModel.emailErrorMessage,
                    ),
                    onChanged: (value) => signInViewModel.email = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Password',
                      errorText: signInViewModel.passwordErrorMessage,
                    ),
                    onChanged: (value) => signInViewModel.password = value,
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      color: Colors.lightBlue,
                      child: Text('Sign in'),
                      onPressed: () => signInViewModel.submit(),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      child: Text('Create account'),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/sign-up');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ));
        }
      )
    );
  }
}

