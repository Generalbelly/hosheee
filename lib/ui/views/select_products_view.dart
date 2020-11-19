import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hosheee/ui/view_models/products_view_model.dart';
import 'package:hosheee/ui/views/progress_modal.dart';

class SelectProductsView extends StatelessWidget {

  final collection;

  SelectProductsView({
    this.collection,
    Key key
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
    final productsViewModel = Provider.of<ProductsViewModel>(context);
    final body = productsViewModel.products.length > 0
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
                final product = productsViewModel.products[i];
                return GestureDetector(
                  key: Key(product.id),
                  child: product.imageUrl != null ?
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(
                        productsViewModel.selectedProductIds.indexOf(product.id) > -1 ? 0.3 : 0,
                      ), BlendMode.srcATop),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                          return Icon(Icons.error_outline);
                        },
                      ),
                    ),
                  ) :
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(
                          productsViewModel.selectedProductIds.indexOf(product.id) > -1 ? 0.3 : 0,
                        ),
                        border: Border.all(color: Colors.lightBlue.shade50, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        product.name,
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                    ),
                  ),
                  onTap: () {
                    productsViewModel.onTapProduct(product.id);
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
          actions: <Widget>[
            TextButton(
              child: Text('Save', style: Theme.of(context).primaryTextTheme.button),
              onPressed: () async {
                await productsViewModel.saveCollectionProducts(collection);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          if (productsViewModel.message != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showSnackBar(context, productsViewModel.message, (ctx) {
                Scaffold.of(ctx).hideCurrentSnackBar();
              });
              productsViewModel.message = null;
            });
          }
          return ProgressModal(
            isLoading: productsViewModel.requestStatusManager.isLoading() &&
            productsViewModel.products.length == 0,
            child: body
          );
        },
      ),
    );
  }
}

