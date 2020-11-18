import 'package:flutter/material.dart';
import 'package:hosheee/ui/view_models/products_view_model.dart';
import 'package:provider/provider.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/ui/view_models/collection_view_model.dart';
import 'package:hosheee/ui/view_models/collections_view_model.dart';
import 'package:hosheee/ui/view_models/collection_products_view_model.dart';
import 'package:hosheee/ui/views/collection_view.dart';
import 'package:hosheee/ui/views/collection_products_view.dart';
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
    final collectionProductsViewModel = Provider.of<CollectionProductsViewModel>(context, listen: false);
    final collectionViewModel = Provider.of<CollectionViewModel>(context, listen: false);
    final productsViewModel = Provider.of<ProductsViewModel>(context, listen: false);

    final body = collectionsViewModel.collections.length > 0
        ?
    CustomScrollView(
      controller: collectionsViewModel.scrollController,
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.all(8),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            delegate: SliverChildBuilderDelegate((c, i) {
              final collection = collectionsViewModel.collections[i];
              return GestureDetector(
                key: Key(collection.id),
                child: collection.imageUrl != null ?
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: Image.network(
                          collection.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                            return Icon(Icons.error_outline);
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                      child: Text(
                        collection.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                          ),
                        textAlign: TextAlign.center,
                      ),
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ) :
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlue.shade50, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      collection.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 24.0),
                    ),
                  ),
                ),
                onTap: () {
                  productsViewModel.selectedProductIds = [];
                  collectionProductsViewModel.collection = collection;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CollectionProductsView()));
                },
              );
            },
              childCount: collectionsViewModel.collections.length,
            ),
          )
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44.0),
        child: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Icon(Icons.star, size: 26),
                padding: const EdgeInsets.only(bottom: 22),
              )
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          if (collectionsViewModel.message != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showSnackBar(context, collectionsViewModel.message, (ctx) {
                Scaffold.of(ctx).hideCurrentSnackBar();
              });
              collectionsViewModel.message = null;
            });
          }
          return ProgressModal(
              isLoading: collectionsViewModel.requestStatusManager.isLoading() && collectionsViewModel.collections.length == 0,
              child: body);
        },
      ),
      floatingActionButton: Container(
        height: 75.0,
        width: 75.0,
        child: FittedBox(
          child: FloatingActionButton(
            heroTag: 'collections-view-action-button',
            onPressed: () {
              productsViewModel.selectedProductIds = [];
              collectionViewModel.collection = Collection(null);
              Navigator.push(context, MaterialPageRoute(builder: (context) => CollectionView()));
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

