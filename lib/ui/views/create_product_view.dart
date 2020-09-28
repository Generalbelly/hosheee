import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hosheee/ui/view_models/product_view_model.dart';

class CreateProductView extends StatelessWidget {

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
    final productViewModel = Provider.of<ProductViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('New Product'),
        actions: <Widget>[
          FlatButton(
            child: Text('Save'),
            onPressed: () => productViewModel.create(),
          ),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        if (productViewModel.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSnackBar(context, productViewModel.message, (ctx) {
              Scaffold.of(ctx).hideCurrentSnackBar();
              productViewModel.message = null;
            });
          });
        }
        return Center(
          child: Container(
            padding: EdgeInsets.all(35.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Product Page URL',
                    errorText: productViewModel.errors['websiteUrl'],
                  ),
                  onChanged: (value) => productViewModel.setWebsiteUrl(value),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

