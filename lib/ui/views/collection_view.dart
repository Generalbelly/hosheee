import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:wish_list/ui/view_models/collection_view_model.dart';
import 'package:wish_list/ui/views/progress_modal.dart';

class CollectionView extends StatelessWidget {

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
    final collectionViewModel = Provider.of<CollectionViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: collectionViewModel.collection.id != null ? Text(collectionViewModel.collection.name) : Text('New Item'),
        actions: <Widget>[
          FlatButton(
            child: collectionViewModel.isReadOnly() ? Text('Edit') : Text('Save'),
            onPressed: () async {
              if (collectionViewModel.isReadOnly()) {
                collectionViewModel.isEditing = true;
              } else {
                await collectionViewModel.save();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              }
            },
          ),
        ],
      ),
      body: ProgressModal(isLoading: collectionViewModel.requestStatusManager.isLoading(), child: Builder(builder: (BuildContext context) {
        if (collectionViewModel.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSnackBar(context, collectionViewModel.message, (ctx) {
              Scaffold.of(ctx).hideCurrentSnackBar();
            });
            collectionViewModel.message = null;
          });
        }
        final imageField = collectionViewModel.collection.imageUrl != null ?
        Image.network(collectionViewModel.collection.imageUrl, fit: BoxFit.cover, errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
          return Icon(Icons.error_outline);
        }) : SizedBox.shrink();

        final setting = collectionViewModel.collection.id != null
            ?
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.more_horiz),
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete'),
                            onTap: () async {
                              await collectionViewModel.delete();
                              Navigator.popUntil(context, ModalRoute.withName('/'));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        )
            :
        Container(
          padding: EdgeInsets.only(top: 24.0),
          child: SizedBox.shrink(),
        );

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                setting,
                imageField,
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Name',
                    errorText: collectionViewModel.errors['name'],
                  ),
                  initialValue: collectionViewModel.collection.name,
                  onChanged: (value) => collectionViewModel.setName(value),
                  readOnly: collectionViewModel.isReadOnly(),
                ),
              ],
            ),
          ),
        );
      })),
    );
  }
}

