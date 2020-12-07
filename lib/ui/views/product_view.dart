import 'package:hosheee/ui/view_models/collection_products_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hosheee/ui/view_models/collections_view_model.dart';
import 'package:hosheee/ui/view_models/product_view_model.dart';
import 'package:hosheee/ui/views/progress_modal.dart';

class ProductView extends StatelessWidget {

  final bool showAdWhenPop;

  ProductView({
    Key key,
    this.showAdWhenPop = false,
  }) : super(key: key);

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
    final collectionProductsViewModel = Provider.of<CollectionProductsViewModel>(context, listen: true);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44.0),
        child: AppBar(
          title: productViewModel.product.id != null ? Text(productViewModel.product.name) : Text('New Item'),
          actions: <Widget>[
            TextButton(
              child: productViewModel.isReadOnly() ?
                Text('Edit', style: Theme.of(context).primaryTextTheme.button) :
                Text('Save', style: Theme.of(context).primaryTextTheme.button),
              onPressed: () async {
                if (productViewModel.isReadOnly()) {
                  // collectionProductsViewModel.product.collectionIds = collectionProductsViewModel.collectionProducts.map((collection) => collection.collectionId).toList();
                  productViewModel.isEditing = true;
                } else {
                  await productViewModel.save();
                  await collectionsViewModel.saveCollectionProducts(productViewModel.product);
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                }
              },
            ),
          ],
        ),
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
          Image.network(
            productViewModel.product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
              return Icon(Icons.error_outline);
            }) :
          SizedBox.shrink();

        Widget collectionProductsField;
        if (productViewModel.isReadOnly()) {
          if (collectionProductsViewModel.collectionProductsByProductId.length == 0) {
            collectionProductsField = SizedBox.shrink();
          } else {
            collectionProductsField = Column(
              children: [
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(top: 48.0),
                    child: Text('Folders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  alignment: Alignment.topLeft),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 20.0),
                    height: 128.0,
                    child: ListView.separated(
                      itemCount: collectionProductsViewModel.collectionProductsByProductId.length,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (BuildContext context, int index) => SizedBox(
                        width: 12,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final collectionProduct = collectionProductsViewModel.collectionProductsByProductId[index];
                        if (collectionProduct.collectionImageUrl != null) {
                          return Column(
                            children: <Widget>[
                              Container(
                                constraints: BoxConstraints(minHeight: 100, maxHeight: 100),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  child: Image.network(
                                    collectionProduct.collectionImageUrl,
                                    fit: BoxFit.cover,
                                    width: 100.0,
                                    errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                      return Icon(Icons.error_outline);
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                collectionProduct.collectionName,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }
                        return Container(
                          key: Key(collectionProduct.id),
                          color: Colors.black.withOpacity(
                            collectionProductsViewModel.product.collectionIds.indexOf(collectionProduct.id) > -1 ? 0.3 : 0,
                          ),
                          width: 100.0,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              collectionProduct.collectionName,
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    )
                )
              ],
            );
          }
        } else {
          collectionProductsField = SizedBox.shrink();
        }

        Widget collectionsField;
        if (productViewModel.isReadOnly()) {
          collectionsField = SizedBox.shrink();
        } else {
          collectionsField = Column(
            children: [
              Container(
                child: Padding(
                  padding: EdgeInsets.only(top: 48.0),
                  child: Text('Add To Folders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                alignment: Alignment.topLeft
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20.0),
                height: 128.0,
                child: ListView.separated(
                    itemCount: collectionsViewModel.collections.length,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (BuildContext context, int index) => SizedBox(
                      width: 12,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final collection = collectionsViewModel.collections[index];
                      return GestureDetector(
                        key: Key(collection.id),
                        child: collection.imageUrl != null ?
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: collectionProductsViewModel.product.collectionIds.indexOf(collection.id) > -1 ? Theme.of(context).accentColor : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                constraints: BoxConstraints(minHeight: 100, maxHeight: 100),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  child: Image.network(
                                    collection.imageUrl,
                                    fit: BoxFit.cover,
                                    width: 100.0,
                                    errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                      return Icon(Icons.error_outline);
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                collection.name,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12.0,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ) :
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: collectionProductsViewModel.product.collectionIds.indexOf(collection.id) > -1 ? Theme.of(context).accentColor : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          width: 100.0,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              collection.name,
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        onTap: () {
                          productViewModel.appendCollectionId(collection.id);
                        },
                      );
                    }
                ),
              )
            ],
          );
        }

        return ProgressModal(
            isLoading: productViewModel.requestStatusManager.isLoading(),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                        labelText: 'Description',
                        hintText: 'Description',
                        errorText: productViewModel.errors['description'],
                      ),
                      initialValue: productViewModel.product.description,
                      onChanged: (value) => productViewModel.setDescription(value),
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
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Price',
                        hintText: 'Price',
                        errorText: productViewModel.errors['price'],
                      ),
                      initialValue: productViewModel.product.price != null ? productViewModel.product.price.toString() : null,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      keyboardType: TextInputType.number,
                      onChanged: (value) => productViewModel.setPrice(double.parse(value)),
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
                    collectionProductsField,
                    collectionsField,
                    SizedBox(
                      height: 24,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlineButton.icon(
                        icon: Icon(Icons.delete),
                        color: Colors.red.shade900,
                        label: Text('DELETE', style: TextStyle(color: Colors.red.shade900)),
                        onPressed: () async {
                          await productViewModel.delete();
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                        },
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

