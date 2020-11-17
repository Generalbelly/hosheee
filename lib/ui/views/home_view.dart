import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hosheee/ui/view_models/home_view_model.dart';
import 'package:hosheee/ui/views/progress_modal.dart';

class HomeView extends StatelessWidget {

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          if (homeViewModel.requestStatusManager.isOk() && homeViewModel.user == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/sign-in');
            });
          }
          return ProgressModal(
            isLoading: homeViewModel.requestStatusManager.isLoading(),
            child: Center(
              child: IndexedStack(
                index: homeViewModel.selectedIndex,
                children: homeViewModel.contents,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Recent',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Folders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            label: 'Preference',
          ),
        ],
        currentIndex: homeViewModel.selectedIndex,
        //selectedItemColor: Colors.amber[800],
        onTap: (index) => { homeViewModel.selectedIndex = index },
      ),
    );
  }
}
