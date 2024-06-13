import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:servi_express/firebase_options.dart';
import 'anuncio.dart';
import 'Domianuncio.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicación de inicio de sesión',
      home: LoginScreen(),
    );
  }
}

class AuthService {
  static Future<User?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Ingrese un correo electrónico y contraseña válidos.');
    }

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            throw Exception('Correo electrónico no válido.');
          case 'user-disabled':
            throw Exception('Usuario desactivado.');
          case 'user-not-found':
            throw Exception('Usuario no encontrado.');
          case 'wrong-password':
            throw Exception('Contraseña incorrecta.');
          default:
            throw Exception('Error desconocido al iniciar sesión.');
        }
      } else {
        throw Exception('Error desconocido.');
      }
    }
  }

  static Future<void> register(
      String email, String password, String userType) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Ingrese un correo electrónico y contraseña válidos.');
    }

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Guardar información adicional en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'userType': userType,
      });
    } catch (e) {
      print('Error al registrar: $e');
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            throw Exception('El correo electrónico ya está en uso.');
          case 'invalid-email':
            throw Exception('Correo electrónico no válido.');
          case 'weak-password':
            throw Exception(
                'Contraseña débil. Elija una contraseña más segura.');
          default:
            throw Exception('Error desconocido al registrar.');
        }
      } else {
        throw Exception('Error desconocido.');
      }
    }
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();

  bool _isLoginForm = true;
  String _selectedUserType = 'domiciliario'; // Default value for the select

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginForm ? 'Iniciar sesión' : 'Registrar'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: _isLoginForm ? _buildLoginForm() : _buildRegisterForm(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Ingrese su correo electrónico.';
              }
              return null;
            },
          ),
          SizedBox(height: 20.0),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Ingrese su contraseña.';
              }
              return null;
            },
          ),
          SizedBox(height: 30.0),
          ElevatedButton(
            onPressed: () async {
              if (_loginFormKey.currentState!.validate()) {
                try {
                  User? user = await AuthService.login(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                  if (user != null) {
                    // Obtener el tipo de usuario desde Firestore
                    DocumentSnapshot userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();
                    String userType = userDoc['userType'];
                    if (userType == 'empresa') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Anuncio()),
                      );
                    } else if (userType == 'domiciliario') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DomiAnuncio()),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text('Iniciar sesión'),
          ),
          SizedBox(height: 10.0),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoginForm = false;
              });
            },
            child: Text('¿No tienes una cuenta? Regístrate aquí.'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Ingrese su correo electrónico.';
              }
              return null;
            },
          ),
          SizedBox(height: 20.0),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Ingrese su contraseña.';
              }
              return null;
            },
          ),
          SizedBox(height: 20.0),
          DropdownButtonFormField<String>(
            value: _selectedUserType,
            decoration: InputDecoration(
              labelText: 'Tipo de Usuario',
            ),
            items: <String>['domiciliario', 'empresa'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedUserType = newValue!;
              });
            },
          ),
          SizedBox(height: 30.0),
          ElevatedButton(
            onPressed: () async {
              if (_registerFormKey.currentState!.validate()) {
                try {
                  await AuthService.register(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                    _selectedUserType,
                  );
                  // Iniciar sesión automáticamente después de registrar
                  User? user = await AuthService.login(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                  if (user != null) {
                    if (_selectedUserType == 'empresa') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Anuncio()),
                      );
                    } else if (_selectedUserType == 'domiciliario') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DomiAnuncio()),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text('Registrarse'),
          ),
        ],
      ),
    );
  }
}
