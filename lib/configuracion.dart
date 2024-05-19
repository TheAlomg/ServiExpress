import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Lógica para cambiar la foto de perfil
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangeProfilePicturePage()),
                );
              },
              child: Text('Cambiar foto de perfil'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Lógica para cambiar la contraseña
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
              child: Text('Cambiar contraseña'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Lógica para eliminar la cuenta
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteAccountPage()),
                );
              },
              child: Text('Eliminar cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangeProfilePicturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambiar foto de perfil'),
      ),
      body: Center(
        child: Text('Aquí puedes cambiar tu foto de perfil'),
      ),
    );
  }
}

class ChangePasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambiar contraseña'),
      ),
      body: Center(
        child: Text('Aquí puedes cambiar tu contraseña'),
      ),
    );
  }
}

class DeleteAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eliminar cuenta'),
      ),
      body: Center(
        child: Text('Aquí puedes eliminar tu cuenta'),
      ),
    );
  }
}
