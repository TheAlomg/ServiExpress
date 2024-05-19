import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servi_express/firebase_options.dart';
import 'anuncio.dart';

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

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Anuncio(); // Replace with your actual home screen widget
  }
}

class AuthService {
  static Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Ingrese un correo electrónico y contraseña válidos.');
    }

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // Handle successful login (navigate to HomeScreen or show success message)
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

  static Future<void> register(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Ingrese un correo electrónico y contraseña válidos.');
    }

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // Handle successful registration (navigate to HomeScreen or show success message)
    } catch (e) {
      print('Error al registrar: $e');
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            throw Exception('El correo electrónico ya está en uso.');
          case 'invalid-email':
            throw Exception('Correo electrónico no válido.');
          case 'weak-password':
            throw Exception('Contraseña débil. Elija una contraseña más segura.');
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

  bool _isLoginForm = true;

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
                  await AuthService.login(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
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
          SizedBox(height: 30.0),
          ElevatedButton(
            onPressed: () async {
              if (_registerFormKey.currentState!.validate()) {
                try {
                  await AuthService.register(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
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