import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wish_list/ui/view_models/product_view_model.dart';
import 'package:wish_list/ui/views/product_view.dart';
import 'package:wish_list/ui/views/progress_modal.dart';

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

    final nextButtonColor = productViewModel.errors['websiteUrl'] == null && productViewModel.product.websiteUrl != null ? Colors.lightBlue : null;
    return Scaffold(
      appBar: AppBar(
        title: Text('New Product'),
        actions: <Widget>[
          FlatButton(
            child: Text('Skip'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ProductView()));
            },
          ),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        if (productViewModel.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSnackBar(context, productViewModel.message, (ctx) {
              Scaffold.of(ctx).hideCurrentSnackBar();
            });
            productViewModel.message = null;
          });
        }
        return ProgressModal(
          isLoading: productViewModel.requestStatusManager.isLoading(),
          child: Center(
          child: Container(
            padding: EdgeInsets.all(24.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Website URL',
                    hintText: 'Website URL',
                    errorText: productViewModel.errors['websiteUrl'],
                  ),
                  onChanged: (value) => productViewModel.setWebsiteUrl(value),
                  onEditingComplete: () async {
                    if (await productViewModel.fillWithMetadata()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductView(),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    color: nextButtonColor,
                    child: Text('Next'),
                    onPressed:  () async {
                      if (await productViewModel.fillWithMetadata()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductView(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        )
        );
      }),
    );
  }
}

