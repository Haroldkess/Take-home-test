import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../components/app_button.dart';
import '../../../components/app_form.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _homeLatController = TextEditingController();
  final _homeLonController = TextEditingController();
  final _officeLatController = TextEditingController();
  final _officeLonController = TextEditingController();

  Box? settingsBox;

  @override
  void initState() {
    super.initState();
    // Ensuring the Hive box "geofenceSettings" is open.
    settingsBox = Hive.box('geofenceSettings');
    _loadSettings();
  }

  /// Load saved geofence settings from the Hive box.
  Future<void> _loadSettings() async {
    // Use default values if not set.
    final double homeLat = settingsBox?.get('homeLat', defaultValue: 37.4219983) as double;
    final double homeLon = settingsBox?.get('homeLon', defaultValue: -122.084) as double;
    final double officeLat = settingsBox?.get('officeLat', defaultValue: 37.7858) as double;
    final double officeLon = settingsBox?.get('officeLon', defaultValue: -122.4364) as double;

    setState(() {
      _homeLatController.text = homeLat.toString();
      _homeLonController.text = homeLon.toString();
      _officeLatController.text = officeLat.toString();
      _officeLonController.text = officeLon.toString();
    });
  }

  /// Save the geofence settings to the Hive box.
  Future<void> _saveSettings(BuildContext context) async {
    // Parse inputs.
    final double? homeLat = double.tryParse(_homeLatController.text);
    final double? homeLon = double.tryParse(_homeLonController.text);
    final double? officeLat = double.tryParse(_officeLatController.text);
    final double? officeLon = double.tryParse(_officeLonController.text);

    if (homeLat != null &&
        homeLon != null &&
        officeLat != null &&
        officeLon != null) {
      await settingsBox?.put('homeLat', homeLat);
      await settingsBox?.put('homeLon', homeLon);
      await settingsBox?.put('officeLat', officeLat);
      await settingsBox?.put('officeLon', officeLon);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Geofence settings saved')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid input')));
    }
  }

  @override
  void dispose() {
    _homeLatController.dispose();
    _homeLonController.dispose();
    _officeLatController.dispose();
    _officeLonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geofence Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Home Geofence',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            const SizedBox(height: 30),
            ReusableTextFormField(
              controller: _homeLatController,
              hintText: 'Home Latitude',
              borderRadius: 10,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            ReusableTextFormField(
              controller: _homeLonController,
              hintText: 'Home Longitude',
              borderRadius: 10,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 50),
            const Text('Office Geofence',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            ReusableTextFormField(
              controller: _officeLatController,
              hintText: 'Office Latitude',
              borderRadius: 10,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            ReusableTextFormField(
              controller: _officeLonController,
              hintText: 'Office Longitude',
              borderRadius: 10,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Save Settings',
              onPressed: () => _saveSettings(context),
              textStyle: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
