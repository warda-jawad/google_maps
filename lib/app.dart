import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'direction_model.dart';
import 'direction_repository.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(
      37.773972,
      -122.431297,
    ),
    zoom: 11.5,
  );

  Directions _info = Directions(
    bounds: null,
    polylinePoints: null,
    totalDistance: null,
    totalDuration: null,
  );

  late GoogleMapController _googleMapControoler;

  Marker _origin = Marker(
    markerId: MarkerId("origin"),
    position: LatLng(37.773972, -122.431297),
  );
  Marker _destination = Marker(
    markerId: MarkerId("destination"),
    position: LatLng(37.773972, -122.431297),
  );

  @override
  void dispose() {
    _googleMapControoler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Google Maps"),
          centerTitle: false,
          actions: [
            // ignore: unnecessary_null_comparison
            if (_origin != null)
              TextButton(
                  onPressed: () {
                    _googleMapControoler.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                      target: _origin.position,
                      zoom: 14.5,
                      tilt: 50,
                    )));
                  },
                  style: TextButton.styleFrom(primary: Colors.red),
                  child: Text("ORIGIN")),
            // ignore: unnecessary_null_comparison
            if (_destination != null)
              TextButton(
                  onPressed: () {
                    _googleMapControoler.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                      target: _origin.position,
                      zoom: 14.5,
                      tilt: 70,
                    )));
                  },
                  style: TextButton.styleFrom(primary: Colors.green),
                  child: Text("DESTINATION")),
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (controller) => _googleMapControoler = controller,
              markers: {
                // ignore: unnecessary_null_comparison
                if (_origin != null) _origin,
                // ignore: unnecessary_null_comparison
                if (_destination != null) _destination
              },
              polylines: {
                Polyline(polylineId: const PolylineId("Overview Polyline"), 
                color: Colors.orange, 
                width: 5, 
                points: _info.polylinePoints!.map((e) => LatLng(e.latitude, e.longitude)).toList()), 

              },
              onLongPress: _addMarker,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.black,
          onPressed: () => _googleMapControoler.animateCamera( 
           // _info != null ?
          //  CameraUpdate.newLatLngBounds(_info.bounds, 100.0) :
            CameraUpdate.newCameraPosition(_initialCameraPosition),
          ),
          child: Icon(Icons.center_focus_strong),
        ),
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    // ignore: unnecessary_null_comparison
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
        _destination = Marker(
          markerId: MarkerId("destination"),
        );
      });
    } else {
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
        _destination = Marker(
          markerId: MarkerId("destination"),
        );
      });
    }

    final directions = await DirectionsRepository().getDirections(
      origin: _origin.position,
      destination: pos,
    );
    setState(() => _info = directions!);
  }
}
