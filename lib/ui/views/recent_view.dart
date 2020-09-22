import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/ui/view_models/product_view_model.dart';
import 'package:wish_list/ui/view_models/products_view_model.dart';
import 'package:wish_list/ui/views/product_view.dart';

class RecentView extends StatelessWidget {

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
    print('build:recent_view');
    final productsViewModel = Provider.of<ProductsViewModel>(context);
    if (productsViewModel.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(context, productsViewModel.message, (ctx) {
          Scaffold.of(ctx).hideCurrentSnackBar();
        });
        productsViewModel.message = null;
      });
    }
    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
    final body = productsViewModel.products.length > 0
      ?
      CustomScrollView(
        controller: productsViewModel.scrollController,
        slivers: <Widget>[
          SliverGrid(
            delegate: SliverChildBuilderDelegate((c, i) {
              final product = productsViewModel.products[i];
              return GestureDetector(
                child: product.imageUrl != null
                  ?
                    Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                        return Icon(Icons.error_outline);
                      },
                      // loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                      //   WidgetsBinding.instance.addPostFrameCallback((_) {
                      //     if (loadingProgress == null) {
                      //       productsViewModel.imageLoadingDone(product.imageUrl);
                      //     }
                      //   });
                      //   return child;
                      // },
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
            child: productsViewModel.requestStatusManager.isLoading()
              ?
                SizedBox(width: 32, height: 32, child: CircularProgressIndicator())
              :
                Text("No item saved yet.")
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
      body: body);
  }
}

