import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (productViewModel.product.id != product.id) {
      productViewModel.product = product;
    }
    print(product.id);

    return Scaffold(
      appBar: AppBar(
        title: product.id != null ? Text(product.name) : Text('New Item'),
        actions: <Widget>[
          FlatButton(
            child: productViewModel.isReadOnly() ? Text('Edit') : Text('Save'),
            onPressed: () async {
              if (productViewModel.isReadOnly()) {
                productViewModel.isEditing = true;
              } else {
                await productViewModel.save();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              }
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
        final imageField = productViewModel.product.imageUrl != null ?
          Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
            return Icon(Icons.error_outline);
          }) : SizedBox.shrink();
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
          readOnly: productViewModel.isReadOnly(),
        );

        final setting = product.id != null
          ?
            Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.more_horiz),
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete'),
                            onTap: () async {
                              await productViewModel.delete();
                              Navigator.popUntil(context, ModalRoute.withName('/'));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        )
          :
            Container(
              padding: EdgeInsets.only(top: 24.0),
              child: SizedBox.shrink(),
            );

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                setting,
                imageField,
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: OutlineButton(
                    onPressed: () async {
                      if (await canLaunch(product.websiteUrl)) {
                        await launch(product.websiteUrl);
                      } else {
                        _showSnackBar(context, 'Could not launch the url.', (ctx) {
                          Scaffold.of(ctx).hideCurrentSnackBar();
                        });
                      }
                    },
                    child: Text('Go To URL'),
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Name',
                    errorText: productViewModel.errors['name'],
                  ),
                  initialValue: productViewModel.product.name,
                  onChanged: (value) => productViewModel.setName(value),
                  readOnly: productViewModel.isReadOnly(),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Website URL',
                    hintText: 'Website URL',
                    errorText: productViewModel.errors['websiteUrl'],
                  ),
                  initialValue: productViewModel.product.websiteUrl,
                  onChanged: (value) => productViewModel.setWebsiteUrl(value),
                  readOnly: productViewModel.isReadOnly(),
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
                  readOnly: productViewModel.isReadOnly(),
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

