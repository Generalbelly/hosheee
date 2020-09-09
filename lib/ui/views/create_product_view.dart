import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wish_list/ui/view_models/product_view_model.dart';
import 'package:wish_list/ui/views/product_view.dart';

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
            child: Text('Skip'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ProductView(productViewModel.product)));
            },
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
                    labelText: 'Website URL',
                    hintText: 'Website URL',
                    errorText: productViewModel.errors['websiteUrl'],
                  ),
                  onChanged: (value) => productViewModel.setWebsiteUrl(value),
                  onEditingComplete: () async {
                    final result = await productViewModel.fillWithMetadata();
                    if (result) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductView(productViewModel.product),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

