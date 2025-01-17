import 'package:flutter/material.dart';
import 'package:hosheee/ui/view_models/collection_products_view_model.dart';
import 'package:hosheee/ui/view_models/collections_view_model.dart';
import 'package:provider/provider.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/ui/view_models/product_view_model.dart';
import 'package:hosheee/ui/view_models/products_view_model.dart';
import 'package:hosheee/ui/views/product_view.dart';
import 'package:hosheee/ui/views/progress_modal.dart';

class ProductsView extends StatelessWidget {

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
    final collectionProductsViewModel = Provider.of<CollectionProductsViewModel>(context, listen: false);
    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);

    final products = productsViewModel.products;

    final content = products.length > 0
      ?
      CustomScrollView(
        controller: productsViewModel.scrollController,
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
                final product = products[i];
                return GestureDetector(
                  key: Key(productsViewModel.generateProductKey(product)),
                  child: product.imageUrl != null ?
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                        return GestureDetector(
                          child: Container(
                            child: Center(
                              child: Icon(Icons.error_outline),
                            ),
                          ),
                          onTap: () {
                            productsViewModel.reloadImage(product);
                            productViewModel.product = product;
                            collectionProductsViewModel.product = product;
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductView(showAdWhenPop: true)));
                          },
                        );
                      },
                    ),
                  ) :
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        product.name,
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 24.0),
                      ),
                    ),
                  ),
                  onTap: () async {
                    productViewModel.product = product;
                    collectionProductsViewModel.product = product;
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductView(showAdWhenPop: true)));
                  },
                );
              },
                childCount: productsViewModel.products.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: productsViewModel.requestStatusManager.isLoading()
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
            child: Text("No items saved yet."),
          ),
        );
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
      body: Builder(
        builder: (BuildContext context) {
          if (productsViewModel.message != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showSnackBar(context, productsViewModel.message, (ctx) {
                Scaffold.of(ctx).hideCurrentSnackBar();
                productsViewModel.message = null;
              });
            });
          }
          return ProgressModal(
            isLoading: productsViewModel.requestStatusManager.isLoading() && productsViewModel.products.length == 0,
            child: content);
        },
      ),
      floatingActionButton: Container(
        height: 75.0,
        width: 75.0,
        child: FittedBox(
          child: FloatingActionButton(
            heroTag: 'products-view-action-button',
            onPressed: () {
              final product = Product(null);
              collectionProductsViewModel.product = product;
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

