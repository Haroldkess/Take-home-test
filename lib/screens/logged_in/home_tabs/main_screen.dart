import 'package:flutter/material.dart';
import '../../../components/app_avatar.dart';
import '../../../components/geo_fencing_status_widget.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo tracker'),
        actions: [
      
          InkWell(
             onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),);
            },
            
            child: const AppAvatar(),),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[GeofenceStatusWidget()],
        ),
      ),
    );
  }
}
