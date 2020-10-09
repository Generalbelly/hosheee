import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/ui/view_models/product_view_model.dart';
import 'package:hosheee/ui/view_models/products_view_model.dart';
import 'package:hosheee/ui/views/product_view.dart';
import 'package:hosheee/ui/views/progress_modal.dart';

class ProductsView extends StatelessWidget {

  _showSnackBar(BuildContext context, String message, Function cb) {
    print(message);
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
    final recentViewModel = Provider.of<ProductsViewModel>(context);
    if (recentViewModel.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(context, recentViewModel.message, (ctx) {
          Scaffold.of(ctx).hideCurrentSnackBar();
        });
        recentViewModel.message = null;
      });
    }

    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
    final body = recentViewModel.products.length > 0
      ?
      CustomScrollView(
        controller: recentViewModel.scrollController,
        slivers: <Widget>[
          SliverGrid(
            delegate: SliverChildBuilderDelegate((c, i) {
              final product = recentViewModel.products[i];
              return GestureDetector(
                key: Key(product.id),
                child: product.imageUrl != null
                  ?
                    Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                        return Icon(Icons.error_outline);
                      },
                    )
                  :
                    Container(
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
                      productViewModel.product = product;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProductView()));
                    },
              );
            },
              childCount: recentViewModel.products.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
          ),
          SliverToBoxAdapter(
            child: recentViewModel.requestStatusManager.isLoading()
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
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              productViewModel.product = Product(null);
              Navigator.pushNamed(context, '/products/create');
            },
          ),
        ],
      ),
      body: ProgressModal(
        isLoading: recentViewModel.requestStatusManager.isLoading() &&
        recentViewModel.products.length == 0,
        child: body));
  }
}

