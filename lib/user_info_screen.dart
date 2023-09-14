import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String location = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Information App"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: dobController,
              decoration: const InputDecoration(
                  labelText: "Date of Birth (YYYY-MM-DD)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _getLocation(),
              child: const Text("Get Location"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _getUserInfo(),
              child: const Text("Get UserInfo"),
            ),
            const SizedBox(height: 20),
            Text("Location: $location"),
          ],
        ),
      ),
    );
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        permission = await Geolocator.checkPermission();

        // return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      log(placemarks[0].country.toString());

      String address =
          "${placemarks[0].locality} ${placemarks[0].subAdministrativeArea} ${placemarks[0].administrativeArea}";

      setState(() {
        location =
            // "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
            address;
      });
    } catch (e) {
      setState(() {
        location = "Unable to fetch location data.";
      });
    }
  }

  _getUserInfo() {
    String username = usernameController.text;
    String dob = dobController.text;

    if (username.isEmpty || dob.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Please fill in all fields."),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return Future.value();
    }

    String userInfo =
        "Username: $username\nDate of Birth: $dob\nLocation: $location";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("User Information"),
          content: Text(userInfo),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
