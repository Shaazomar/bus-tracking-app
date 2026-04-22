import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: '',
    anonKey: '',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String location = "Press button to get location";

  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location is ON
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        location = "Location is OFF";
      });
      return;
    }

    // Request permission
    permission = await Geolocator.requestPermission();

    // Get location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.from('bus_locations').insert({
        'bus_id': 'bus_1',
        'lat': position.latitude,
        'lng': position.longitude,
      });

      print("✅ INSERT SUCCESS: $response");
    } catch (e) {
      print("❌ INSERT ERROR: $e");
    }

    setState(() {
      location = "Lat: ${position.latitude}, Lng: ${position.longitude}";
    });
  } // ✅ THIS WAS MISSING

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bus Tracking Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(location),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getLocation,
              child: Text("Get Location"),
            ),
          ],
        ),
      ),
    );
  }
}