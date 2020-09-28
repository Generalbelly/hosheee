import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wish_list/ui/view_models/home_view_model.dart';
import 'package:wish_list/ui/views/progress_modal.dart';

class HomeView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    if (homeViewModel.contents.length == 0) {
      return Scaffold(
        body: SizedBox.shrink(),
      );
    }
    if (!homeViewModel.requestStatusManager.isInitial() && homeViewModel.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/sign-in');
      });
    }
    return Scaffold(
      body: ProgressModal(
        isLoading: homeViewModel.requestStatusManager.isLoading(),
        child: Center(
          child: IndexedStack(
            index: homeViewModel.selectedIndex,
            children: homeViewModel.contents,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            title: Text('Recent'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            title: Text('Collections'),
          ),
        ],
        currentIndex: homeViewModel.selectedIndex,
        //selectedItemColor: Colors.amber[800],
        onTap: (index) => { homeViewModel.selectedIndex = index },
      ),
    );
  }
}
