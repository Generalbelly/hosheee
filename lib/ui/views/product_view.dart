import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/ui/view_models/product_view_model.dart';

class ProductView extends StatelessWidget {

  final Product product;

  ProductView(this.product, {Key key}) : super(key: key);

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
    productViewModel.product = product;

    return Scaffold(
      appBar: AppBar(
        title: product.id != null ? Text(product.name) : Text('New Product'),
        actions: <Widget>[
          FlatButton(
            child: Text('Save'),
            onPressed: () async {
              await productViewModel.create();
              Navigator.popUntil(context, ModalRoute.withName('/'));
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
        final imageField = productViewModel.product.imageUrl != null ? Image.network(productViewModel.product.imageUrl) : SizedBox.shrink();
        final priceField = productViewModel.detailHidden ? SizedBox.shrink() : TextFormField(
          decoration: InputDecoration(
            labelText: 'Price',
            hintText: 'Price',
            errorText: productViewModel.errors['price'],
          ),
          initialValue: productViewModel.product.price != null ? productViewModel.product.price.toString() : null,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly
          ],
          keyboardType: TextInputType.number,
          onChanged: (value) => productViewModel.setPrice(double.parse(value)),
        );

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(35.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                imageField,
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Name',
                    errorText: productViewModel.errors['name'],
                  ),
                  initialValue: productViewModel.product.name,
                  onChanged: (value) => productViewModel.setName(value),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Website URL',
                    hintText: 'Website URL',
                    errorText: productViewModel.errors['websiteUrl'],
                  ),
                  initialValue: productViewModel.product.websiteUrl,
                  onChanged: (value) => productViewModel.setWebsiteUrl(value),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Note',
                    hintText: 'Note',
                    errorText: productViewModel.errors['note'],
                  ),
                  initialValue: productViewModel.product.note,
                  onChanged: (value) => productViewModel.setNote(value),
                  maxLines: 4,
                ),
                priceField,
                SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    child: productViewModel.detailHidden ? Text('More') : Text('Less'),
                    onPressed: () => productViewModel.detailHidden = !productViewModel.detailHidden,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

