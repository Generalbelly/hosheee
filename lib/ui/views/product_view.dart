import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/ui/view_models/collections_view_model.dart';
import 'package:hosheee/ui/view_models/product_view_model.dart';
import 'package:hosheee/ui/views/progress_modal.dart';

class ProductView extends StatelessWidget {

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
    final collectionsViewModel = Provider.of<CollectionsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: productViewModel.product.id != null ? Text(productViewModel.product.name) : Text('New Item'),
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

        final imageField = productViewModel.product.imageUrl != null ? Image.network(productViewModel.product.imageUrl, fit: BoxFit.cover, errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
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

        final setting = productViewModel.product.id != null ? Row(
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
        ) : Container(
          padding: EdgeInsets.only(top: 24.0),
          child: SizedBox.shrink(),
        );

        return ProgressModal(
          isLoading: productViewModel.requestStatusManager.isLoading(),
          child: SingleChildScrollView(
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
                      if (await canLaunch(productViewModel.product.websiteUrl)) {
                        await launch(productViewModel.product.websiteUrl);
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
                    labelText: 'Note',
                    hintText: 'Note',
                    errorText: productViewModel.errors['note'],
                  ),
                  initialValue: productViewModel.product.note,
                  onChanged: (value) => productViewModel.setNote(value),
                  maxLines: 4,
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
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  height: 200.0,
                  child: ListView(
                    controller: collectionsViewModel.scrollController,
                    scrollDirection: Axis.horizontal,
                    children: collectionsViewModel.collections.map((collection) {
                      return GestureDetector(
                        key: Key(collection.id),
                        child: collection.imageUrl != null ?
                        Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              child: Image.network(
                                collection.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                  return Icon(Icons.error_outline);
                                },
                              ),
                            ),
                            Container(
                                child: Text(
                                  collection.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24.0,
                                    backgroundColor: Colors.black.withOpacity(0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                )
                            ),
                          ],
                        ) :
                        Container(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              collection.name,
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 24.0),
                            ),
                          ),
                        ),
                        onTap: () {
                          print('tapped');
                        },
                      );
                    }).toList(),
                  ),
                ),
                // DropdownButtonFormField<String>(
                //   decoration: InputDecoration(
                //     labelText: 'Collection',
                //     hintText: 'Collection',
                //   ),
                //   value: productViewModel.product.collectionId,
                //   elevation: 16,
                //   onChanged: productViewModel.isReadOnly() ? null : (value) {
                //     productViewModel.setCollectionId(value);
                //   },
                //   items: collectionsViewModel.collections
                //       .map<DropdownMenuItem<String>>((Collection collection) {
                //     return DropdownMenuItem<String>(
                //       value: collection.id,
                //       child: Text(collection.name),
                //     );
                //   }).toList(),
                // ),
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
        ));
      }),
    );
  }
}

