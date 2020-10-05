import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/ui/view_models/collection_view_model.dart';
import 'package:hosheee/ui/view_models/collections_view_model.dart';
import 'package:hosheee/ui/view_models/products_view_model.dart';
import 'package:hosheee/ui/views/collection_view.dart';
import 'package:hosheee/ui/views/products_view.dart';
import 'package:hosheee/ui/views/progress_modal.dart';

class CollectionsView extends StatelessWidget {

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
    final collectionsViewModel = Provider.of<CollectionsViewModel>(context);
    final productsViewModel = Provider.of<ProductsViewModel>(context);
    if (collectionsViewModel.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(context, collectionsViewModel.message, (ctx) {
          Scaffold.of(ctx).hideCurrentSnackBar();
        });
        collectionsViewModel.message = null;
      });
    }

    final collectionViewModel = Provider.of<CollectionViewModel>(context, listen: false);

    final body = collectionsViewModel.collections.length > 0
        ?
    CustomScrollView(
      controller: collectionsViewModel.scrollController,
      slivers: <Widget>[
        SliverGrid(
          delegate: SliverChildBuilderDelegate((c, i) {
            final collection = collectionsViewModel.collections[i];
            return GestureDetector(
              child: collection.imageUrl != null ?
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  // Container(
                  //   child: ColorFiltered(
                  //     colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.srcATop),
                  //     child: Image.network(
                  //       collection.imageUrl,
                  //       fit: BoxFit.cover,
                  //       errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                  //         return Icon(Icons.error_outline);
                  //       },
                  //     ),
                  //   ),
                  // ),
                  // Container(
                  //   child: Opacity(opacity: 0.8, child: Text(
                  //     collection.name,
                  //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24.0),
                  //   ))
                  // ),
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
                productsViewModel.collection = collection;
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsView()));
              },
            );
          },
            childCount: collectionsViewModel.collections.length,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
        ),
        SliverToBoxAdapter(
            child: collectionsViewModel.requestStatusManager.isLoading()
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
          child: Text("No collection saved yet."),
      ),
    );
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                collectionViewModel.collection = Collection(null);
                Navigator.push(context, MaterialPageRoute(builder: (context) => CollectionView()));
              },
            ),
          ],
        ),
        body: ProgressModal(
          isLoading: collectionsViewModel.requestStatusManager.isLoading() &&
          collectionsViewModel.collections.length == 0,
          child: body));
  }
}

