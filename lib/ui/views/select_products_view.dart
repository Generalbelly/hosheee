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
    if (productsViewModel.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(context, productsViewModel.message, (ctx) {
          Scaffold.of(ctx).hideCurrentSnackBar();
        });
        productsViewModel.message = null;
      });
    }

    final body = productsViewModel.products.length > 0
      ?
      CustomScrollView(
        controller: productsViewModel.scrollController,
        slivers: <Widget>[
          SliverGrid(
            delegate: SliverChildBuilderDelegate((c, i) {
              final product = productsViewModel.products[i];
              return GestureDetector(
                key: Key(product.id),
                child: product.imageUrl != null
                  ? ColorFiltered(
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
                )
                  :
                    Container(
                      color: Colors.black.withOpacity(
                        productsViewModel.selectedProductIds.indexOf(product.id) > -1 ? 0.3 : 0,
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
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
            child: Text("No item saved yet."),
          ),
        );
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            child: Text('Save'),
            onPressed: () async {
              await productsViewModel.addCollectionProducts(collection);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ProgressModal(
        isLoading: productsViewModel.requestStatusManager.isLoading() &&
        productsViewModel.products.length == 0,
        child: body));
  }
}

