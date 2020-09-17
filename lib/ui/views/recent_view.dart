import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final productsViewModel = Provider.of<ProductsViewModel>(context);
    if (productsViewModel.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(context, productsViewModel.message, (ctx) {
          Scaffold.of(ctx).hideCurrentSnackBar();
          productsViewModel.message = null;
        });
      });
    }
    print(MediaQuery.of(context).size.width);

    final body = productsViewModel.products.length > 0
      ?
      Stack(children: [
        // 無限スクロールでローディングするときに出すか考える
        // Container(
        //   child: productsViewModel.products.length > 12
        //     ?
        //       Stack(
        //         children: <Widget>[
        //           Positioned(
        //             bottom: 10.0,
        //             left: MediaQuery.of(context).size.width / 2 - 20,
        //             height: 30.0,
        //             width: 30.0,
        //             child: productsViewModel.allImagesLoaded ? SizedBox.shrink() : CircularProgressIndicator(),
        //           ),
        //         ],
        //       )
        //     :
        //       SizedBox.shrink(),
        // ),
        GridView.count(
            controller: productsViewModel.scrollController,
            crossAxisCount: 3,
            children: productsViewModel.products.map((product) =>
              GestureDetector(
                child: product.imageUrl != null
                ?
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                      return Icon(Icons.error_outline);
                    },
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (loadingProgress == null) {
                          productsViewModel.imageLoadingDone(product.imageUrl);
                        }
                      });
                      return child;
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductView(product)));
                },
              )).toList())
      ])
      :
        Container(
          child: Center(
            child: productsViewModel.allImagesLoaded ? SizedBox.shrink() : SizedBox(width: 30, height: 30, child: CircularProgressIndicator()),
          ),
        );
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/products/create');
            },
          ),
        ],
      ),
      body: body);
  }
}

