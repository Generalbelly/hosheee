import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hosheee/main.dart';
import 'package:hosheee/ui/view_models/home_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingView extends StatelessWidget {

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
    final homeViewModel = Provider.of<HomeViewModel>(context);

    if (homeViewModel.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(context, homeViewModel.message, (ctx) {
          Scaffold.of(ctx).hideCurrentSnackBar();
          homeViewModel.message = null;
        });
      });
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44.0),
        child: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Icon(Icons.star, size: 26),
                padding: const EdgeInsets.only(bottom: 6),
              )
            ],
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(title: Text("Theme Color"), onTap: () async {
            homeViewModel.previousThemeColorValue = homeViewModel.setting.themeColor;
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Pick your theme color'),
                  content: SingleChildScrollView(
                    child: BlockPicker(
                      pickerColor: homeViewModel.generateThemeColor(),
                      onColorChanged: (Color color) {
                        homeViewModel.setThemeColor(color.value);
                      },
                    ),
                  ),
                  actions: [
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed:  () {
                        homeViewModel.setThemeColor(homeViewModel.previousThemeColorValue);
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text("Apply"),
                      onPressed:  () async {
                        await homeViewModel.saveSetting();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
            if (homeViewModel.previousThemeColorValue != homeViewModel.setting.themeColor) {
              homeViewModel.setThemeColor(homeViewModel.previousThemeColorValue);
            }
          }),
          Divider(height: 1),
          // ListTile(title: Text("Font Family")),
          ListTile(title: Text("Contact"), onTap: () async {
            if (await canLaunch(EnvironmentConfig.CONTACT_FORM_URL)) {
              await launch(EnvironmentConfig.CONTACT_FORM_URL);
            } else {
              _showSnackBar(context, 'Could not launch the url.', (ctx) {
                Scaffold.of(ctx).hideCurrentSnackBar();
              });
            }
          }),
          Divider(height: 1),
          ListTile(title: Text("Sign Out"), onTap: () async {
            await homeViewModel.signOut();
          }),
          Divider(height: 1),
        ],
      ),
    );
  }
}

