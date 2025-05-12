import '../database/database_helper.dart';

class AuthService {
  Future<int> registerUser(String email, String password) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('users', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty){
      return result.first;
    } else{
      return null;
    }
  }

  Future<void> logout() async {
    print("Sesión cerrada correctamente");
    // limpiar datos almacenados en SQLite en el futuro
  }

}

