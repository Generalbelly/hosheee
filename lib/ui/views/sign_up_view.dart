import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wish_list/ui/view_models/home_view_model.dart';
import 'package:wish_list/ui/view_models/sign_up_view_model.dart';

class SignUpView extends StatelessWidget {

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
    final signUpViewModel = Provider.of<SignUpViewModel>(context);
    final homeViewModel = Provider.of<HomeViewModel>(context);
    if (homeViewModel.user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
    }

    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          if (signUpViewModel.message != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showSnackBar(context, signUpViewModel.message, (ctx) {
                Scaffold.of(ctx).hideCurrentSnackBar();
                signUpViewModel.message = null;
              });
            });
          }
          return SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(35.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'wish',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Email',
                        errorText: signUpViewModel.emailErrorMessage,
                      ),
                      onChanged: (value) => signUpViewModel.email = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Password',
                        errorText: signUpViewModel.passwordErrorMessage,
                      ),
                      onChanged: (value) => signUpViewModel.password = value,
                      obscureText: true,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password Confirmation',
                        hintText: 'Password Confirmation',
                      ),
                      onChanged: (value) => signUpViewModel.passwordConfirmation = value,
                      obscureText: true,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.lightBlue,
                        child: Text('Sign up'),
                        onPressed: () => signUpViewModel.submit(),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        child: Text('Sign in'),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/sign-in');
                        },
                      ),
                    ),
                  ],
                ),
              ),
          );
        },
      )
    );
  }
}

