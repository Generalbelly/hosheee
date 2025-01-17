import 'package:flutter/material.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/ui/view_models/collections_view_model.dart';
import 'package:hosheee/ui/view_models/products_view_model.dart';
import 'package:provider/provider.dart';
import 'package:hosheee/ui/view_models/collection_view_model.dart';
import 'package:hosheee/ui/view_models/product_view_model.dart';
import 'package:hosheee/ui/view_models/collection_products_view_model.dart';
import 'package:hosheee/ui/views/collection_view.dart';
import 'package:hosheee/ui/views/product_view.dart';
import 'package:hosheee/ui/views/progress_modal.dart';

class CollectionProductsView extends StatelessWidget {

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
    final productsViewModel = Provider.of<ProductsViewModel>(context);
    final collectionProductsViewModel = Provider.of<CollectionProductsViewModel>(context);
    final collectionViewModel = Provider.of<CollectionViewModel>(context, listen: false);

    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);

    final collectionProducts = collectionProductsViewModel.collectionProductsByCollectionId;
    final content = collectionProducts.length > 0
        ?
    CustomScrollView(
      controller: collectionProductsViewModel.scrollController,
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.all(8),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            delegate: SliverChildBuilderDelegate((c, i) {
              final collectionProduct = collectionProducts[i];
              return GestureDetector(
                key: Key(collectionProductsViewModel.generateProductKey(collectionProduct)),
                child: collectionProduct.productImageUrl != null ?
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: !collectionProductsViewModel.isActionBarHidden && collectionProductsViewModel.collectionProductIdsToDelete.indexOf(collectionProduct.id) > -1 ? Theme.of(context).accentColor : Colors.transparent,
                      width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: Image.network(
                      collectionProduct.productImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                        return GestureDetector(
                          child: Container(
                            child: Center(
                              child: Icon(Icons.error_outline),
                            ),
                          ),
                          onTap: () async {
                            collectionProductsViewModel.reloadImage(collectionProduct);
                            if (!collectionProductsViewModel.isActionBarHidden) {
                              collectionProductsViewModel.onTapCollectionProductToDelete(collectionProduct.id);
                            } else {
                              // すでにローカルにとってきてるデータをまずチェックする
                              Product product;
                              if (productsViewModel.products.length > 0) {
                                product = productsViewModel.products.firstWhere((product) => product.id == collectionProduct.productId, orElse: () => null);
                              }
                              if (product == null) {
                                product = await productViewModel.get(collectionProduct.productId);
                              }
                              productViewModel.product = product;
                              collectionProductsViewModel.product = product;
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ProductView()));
                            }
                          },
                        );
                      },
                    ),
                  ),
                ) :
                Container(
                  decoration: BoxDecoration(
                    color: !collectionProductsViewModel.isActionBarHidden && collectionProductsViewModel.collectionProductIdsToDelete.indexOf(collectionProduct.id) > -1 ? Theme.of(context).accentColor : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      collectionProduct.productName,
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 24.0),
                    ),
                  ),
                ),
                onTap: () async {
                  if (!collectionProductsViewModel.isActionBarHidden) {
                    collectionProductsViewModel.onTapCollectionProductToDelete(collectionProduct.id);
                  } else {
                    // すでにローカルにとってきてるデータをまずチェックする
                    Product product;
                    if (productsViewModel.products.length > 0) {
                      product = productsViewModel.products.firstWhere((product) => product.id == collectionProduct.productId, orElse: () => null);
                    }
                    if (product == null) {
                      product = await productViewModel.get(collectionProduct.productId);
                    }
                    productViewModel.product = product;
                    collectionProductsViewModel.product = product;
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductView()));
                  }
                },
                onLongPress: () {
                  if (collectionProductsViewModel.isActionBarHidden) {
                    collectionProductsViewModel.isActionBarHidden = false;
                  }
                }
              );
            },
              childCount: collectionProductsViewModel.collectionProductsByCollectionId.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
            child: collectionProductsViewModel.requestStatusManager.isLoading()
                ?
            Container(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator()),
                  ),
                )
            )
                :
            SizedBox.shrink()
        ),
      ],
    )
        :
    Container(
      child: Center(
        child: Text("No items in this folder yet."),
      ),
    );
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44.0),
        child: AppBar(
          leading: collectionProductsViewModel.isActionBarHidden ? null : IconButton(
              color: Colors.white,
              icon: Icon(Icons.clear),
              onPressed: () {
                collectionProductsViewModel.isActionBarHidden = true;
              }
          ),
          title: Text(collectionProductsViewModel.collection.name),
          actions: collectionProductsViewModel.isActionBarHidden
            ?
              <Widget>[
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    collectionViewModel.collection = collectionProductsViewModel.collection;
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CollectionView()));
                  },
                ),
              ]
            :
              <Widget>[
                IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    collectionProductsViewModel.batchDelete();
                  },
                ),
              ],
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          if (collectionProductsViewModel.message != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showSnackBar(context, collectionProductsViewModel.message, (ctx) {
                Scaffold.of(ctx).hideCurrentSnackBar();
                collectionProductsViewModel.message = null;
              });
            });
          }
          return ProgressModal(
            isLoading: collectionProductsViewModel.requestStatusManager.isLoading() &&
                collectionProductsViewModel.collectionProductsByCollectionId.length == 0,
            child: content,
          );
        },
      ),
      floatingActionButton: Container(
        height: 75.0,
        width: 75.0,
        child: FittedBox(
          child: FloatingActionButton(
            heroTag: 'collection-products-view-action-button',
            onPressed: () {
              final product = Product(null);
              product.collectionIds = [collectionProductsViewModel.collection.id];
              productViewModel.product = product;
              Navigator.pushNamed(context, 'fetch-url-metadata');
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

