import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'user_session.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
              child : Image.asset('assets/images/logo.png', height: 100, width: 100, fit: BoxFit.cover), // Logo
               ),
              SizedBox(height: 10),
              Text(
                "TrainingPro",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              SizedBox(height: 30),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Correo",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                ),
                onPressed: () async {
                  var user = await _authService.loginUser(
                    emailController.text,
                    passwordController.text,
                  );

                  if (user != null) {
                    UserSession.currentUserId = user['id'];
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Inicio de sesión exitoso 🎉"), backgroundColor: Colors.green),
                    );
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: Usuario o contraseña incorrectos ❌"), backgroundColor: Colors.red),
                    );
                  }
                },
                child: Text("Iniciar Sesión", style: TextStyle(fontSize: 18)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text("Crear Cuenta", style: TextStyle(color: Colors.blueAccent, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
