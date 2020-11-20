import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:hosheee/ui/view_models/collection_view_model.dart';
import 'package:hosheee/ui/views/progress_modal.dart';

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44.0),
        child: AppBar(
          title: collectionViewModel.collection.id != null ? Text(collectionViewModel.collection.name) : Text('New Folder'),
          actions: <Widget>[
            TextButton(
              child: collectionViewModel.isReadOnly() ?
              Text('Edit', style: Theme.of(context).primaryTextTheme.button) :
              Text('Save', style: Theme.of(context).primaryTextTheme.button),
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
      ),
      body: Builder(builder: (BuildContext context) {
        if (collectionViewModel.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSnackBar(context, collectionViewModel.message, (ctx) {
              Scaffold.of(ctx).hideCurrentSnackBar();
            });
            collectionViewModel.message = null;
          });
        }

        return ProgressModal(
          isLoading: collectionViewModel.requestStatusManager.isLoading(),
          child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // imageField,
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
                SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlineButton.icon(
                    icon: Icon(Icons.delete),
                    color: Colors.red.shade900,
                    label: Text('DELETE', style: TextStyle(color: Colors.red.shade900)),
                    onPressed: () async {
                      await collectionViewModel.delete();
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
      }),
    );
  }
}

