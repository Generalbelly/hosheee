import 'package:flutter/material.dart';
import 'package:hosheee/ui/view_models/products_view_model.dart';
import 'package:hosheee/ui/views/select_products_view.dart';
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

    if (collectionProductsViewModel.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(context, collectionProductsViewModel.message, (ctx) {
          Scaffold.of(ctx).hideCurrentSnackBar();
        });
        collectionProductsViewModel.message = null;
      });
    }

    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);

    final scrollView = collectionProductsViewModel.collectionProducts.length > 0
        ?
    CustomScrollView(
      controller: collectionProductsViewModel.scrollController,
      slivers: <Widget>[
        // SliverToBoxAdapter(
        //   child: actionBar,
        // ),
        SliverGrid(
          delegate: SliverChildBuilderDelegate((c, i) {
            final collectionProduct = collectionProductsViewModel.collectionProducts[i];
            return GestureDetector(
              child: collectionProduct.imageUrl != null
                  ?
              ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(
                  collectionProductsViewModel.selectedCollectionProductIds.indexOf(collectionProduct.id) > -1 ? 0.3 : 0,
                ), BlendMode.srcATop),
                child: Image.network(
                  collectionProduct.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                    return Icon(Icons.error_outline);
                  },
                ),
              )
                  :
              Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    collectionProduct.name,
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ),
              ),
              onTap: () async {
                if (!collectionProductsViewModel.isActionBarHidden) {
                  collectionProductsViewModel.onTapProduct(collectionProduct.id);
                } else {
                  // すでにローカルにとってきてるデータをまずチェックする
                  var product = productsViewModel.products.firstWhere((product) => product.id == collectionProduct.productId, orElse: null);
                  if (product == null) {
                    product = await productViewModel.get(collectionProduct.productId);
                  }
                  productViewModel.product = product;
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
            childCount: collectionProductsViewModel.collectionProducts.length,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
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
        child: Text("No item in this collection."),
      ),
    );
    return Scaffold(
        appBar: AppBar(
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
      body: ProgressModal(
        isLoading: collectionProductsViewModel.requestStatusManager.isLoading() &&
            collectionProductsViewModel.collectionProducts.length == 0,
        child: scrollView,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          productsViewModel.selectedProductIds = [];
          Navigator.push(context, MaterialPageRoute(builder: (context) => SelectProductsView(collection: collectionProductsViewModel.collection), fullscreenDialog: true));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }
}

