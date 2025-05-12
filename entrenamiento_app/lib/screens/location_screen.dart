import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:entrenamiento_app/database/database_helper.dart';
import 'user_session.dart';


class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  LatLng? _currentPosition;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  bool _showMap = false;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El servicio de ubicacion esta desactivado.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permiso de ubicacion denegado.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permiso de ubicacion denegado permanentemente.")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _showMap = true;
    });
  }

  Future<void> _saveLocation() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se puede guardar, ubicación no disponible.")),
      );
      return;
    }

    try {
      print("Guardando ubicación: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}");
      await DatabaseHelper.instance.saveLocation(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        UserSession.currentUserId!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ubicación guardada en el historial.")),
    );
  } catch (e) {
      print("error al guardar ubicacion: $e");
    }
  }

  Future<void> _calculateRoute() async {
    if (_currentPosition == null || _destination == null) {
      print("Error: Coordenadas no definidas.");
      return;
    }

    String apiKey = "5b3ce3597851110001cf62481e3251923eab456e8118966916fa9aaa";
    String url =
        "https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${_currentPosition!.longitude},${_currentPosition!.latitude}&end=${_destination!.longitude},${_destination!.latitude}";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey("features") && data["features"].isNotEmpty) {

          List<dynamic> coordinates = data["features"][0]["geometry"]["coordinates"];

          setState(() {
            _routePoints = coordinates
                .map((coord) => LatLng(coord[1], coord[0]))
                .toList();
          });
        } else {
          print("Error: No se encontraron rutas en la respuesta.");
        }
      } else {
        print("Error en la solicitud: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error al calcular la ruta: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ubicacion en el Mapa")),
      body: Column(
        children: [
          if (!_showMap)
            Expanded(
              child: Center(
                child: ElevatedButton(
                  onPressed: _getCurrentLocation,
                  child: Text("Obtener Ubicacion"),
                ),
              ),
            )
          else
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _currentPosition!,
                  initialZoom: 15.0,
                  onTap: (_, latLng) {
                    setState(() {
                      _destination = latLng;
                    });
                    _calculateRoute();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  if (_currentPosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition!,
                          width: 40,
                          height: 40,
                          child: Icon(Icons.location_on, color: Colors.blue, size: 40),
                        ),
                      ],
                    ),
                  if (_destination != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _destination!,
                          width: 40,
                          height: 40,
                          child: Icon(Icons.flag, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: Colors.blue,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ElevatedButton(
          onPressed: _saveLocation,
          child: Text("Guardar Ubicación"),
          ),
        ],
      ),
    );
  }
}

