import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Panel de Entrenamiento"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _mostrarAlertaCerrarSesion(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildOptionButton(
              context,
              icon: Icons.directions_run,
              text: "Contador de Pasos",
              route: '/steps',
            ),
            _buildOptionButton(
              context,
              icon: Icons.map,
              text: "Ubicación GPS",
              route: '/gps',
            ),
            _buildOptionButton(
              context,
              icon: Icons.history,
              text: "Historial",
              route: '/history',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, {required IconData icon, required String text, required String route}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            SizedBox(width: 10),
            Text(text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _mostrarAlertaCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cerrar sesión"),
          content: Text("¿Estás seguro de que deseas cerrar sesión?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _authService.logout();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text("Cerrar sesión"),
            ),
          ],
        );
      },
    );
  }
}
