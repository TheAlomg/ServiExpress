import 'package:flutter/material.dart';
import 'membresia.dart';
import 'configuracion.dart';

void main() {
  runApp(Anuncio());
}

class Anuncio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _adName = '';
  String _adContent = '';
  int _adParticipants = 0;
  double _adValue = 0.0;

  List<Map<String, dynamic>> _appliedAds = [];

  // Función para actualizar los detalles del anuncio
  void updateAdDetails(
      String name, String content, int participants, double value) {
    setState(() {
      _adName = name;
      _adContent = content;
      _adParticipants = participants;
      _adValue = value;
    });
  }

  // Función para aplicar a un anuncio
  void applyToAd(String name, String content, int participants, double value) {
    setState(() {
      _appliedAds.add({
        'name': name,
        'content': content,
        'participants': participants,
        'value': value,
      });
    });
  }

  // Función para mostrar los detalles del anuncio en la parte de "Aquí van los anuncios disponibles"
  void showAdDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles del Anuncio'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Nombre: $_adName'),
                Text('Contenido del Anuncio: $_adContent'),
                Text('Cantidad de Participantes: $_adParticipants'),
                Text('Valor: $_adValue'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ServiExpress'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Acción al presionar el botón de perfil
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(appliedAds: _appliedAds)),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Anuncios disponibles',
              style: TextStyle(fontSize: 20.0),
            ),
            AnuncioCard(
              titulo: 'Anuncio 1',
              onPressedAplicar: () {
                // Lógica para aplicar al anuncio 1
                applyToAd('Anuncio 1', 'Contenido del Anuncio 1', 10, 100.0);
              },
              onPressedVerMas: () {
                // Lógica para ver más detalles del anuncio 1
                showAdDetailsDialog(context);
              },
            ),
            AnuncioCard(
              titulo: 'Anuncio 2',
              onPressedAplicar: () {
                // Lógica para aplicar al anuncio 2
                applyToAd('Anuncio 2', 'Contenido del Anuncio 2', 5, 200.0);
              },
              onPressedVerMas: () {
                // Lógica para ver más detalles del anuncio 2
                showAdDetailsDialog(context);
              },
            ),
            // Agregar más widgets AdCard según sea necesario
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Comprar Membresia'),
              onTap: () {
                // Acción al seleccionar la opción 1
                Navigator.pop(context); // Cierra el menú
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MembershipPage()),
                );
              },
            ),
            GestureDetector(
              onTap: () {
                print(
                    'Seleccionaste la opción de crear anuncio'); // Impresión de depuración
                Navigator.pop(context); // Cierra el menú
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateAdPage(updateAdDetails)),
                );
              },
              child: ListTile(
                title: Text('Crear Anuncio'),
              ),
            ),
            ListTile(
              title: Text('Configuraciones'),
              onTap: () {
                Navigator.pop(context); // Cierra el menú
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
                // Acción al seleccionar la opción 3
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CreateAdPage extends StatefulWidget {
  final Function(String, String, int, double) updateAdDetails;

  CreateAdPage(this.updateAdDetails);

  @override
  _CreateAdPageState createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  bool _isButtonEnabled = false;

  void _checkButtonState() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty &&
          _contentController.text.isNotEmpty &&
          _participantsController.text.isNotEmpty &&
          _valueController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Anuncio'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Regresar a la pantalla anterior
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
              onChanged: (value) {
                _checkButtonState();
              },
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Contenido del Anuncio'),
              onChanged: (value) {
                _checkButtonState();
              },
            ),
            TextField(
              controller: _participantsController,
              decoration:
                  InputDecoration(labelText: 'Cantidad de Participantes'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _checkButtonState();
              },
            ),
            TextField(
              controller: _valueController,
              decoration: InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _checkButtonState();
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isButtonEnabled
                  ? () {
                      // Acción al presionar el botón de publicar
                      String name = _nameController.text;
                      String content = _contentController.text;
                      int participants =
                          int.parse(_participantsController.text);
                      double value = double.parse(_valueController.text);

                      // Actualizar los detalles del anuncio en la página principal
                      widget.updateAdDetails(
                          name, content, participants, value);

                      // Regresar a la página principal
                      Navigator.pop(context);
                    }
                  : null,
              child: Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final List<Map<String, dynamic>> appliedAds;

  ProfilePage({required this.appliedAds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage(
                  'assets/foto_perfil.png'), // Aquí debes proporcionar la ruta de la imagen de la foto de perfil
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para mostrar información del perfil
              },
              child: Text('Información'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para mostrar aplicaciones relacionadas
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AppliedAdsPage(appliedAds: appliedAds)),
                );
              },
              child: Text('Anuncios publicados'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para mostrar la página de membresía
              },
              child: Text('Membresía'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppliedAdsPage extends StatelessWidget {
  final List<Map<String, dynamic>> appliedAds;

  AppliedAdsPage({required this.appliedAds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anuncios Aplicados'),
      ),
      body: ListView.builder(
        itemCount: appliedAds.length,
        itemBuilder: (context, index) {
          final ad = appliedAds[index];
          return ListTile(
            title: Text(ad['name']),
            subtitle: Text(ad['content']),
          );
        },
      ),
    );
  }
}

class AnuncioCard extends StatelessWidget {
  final String titulo;
  final VoidCallback onPressedAplicar;
  final VoidCallback onPressedVerMas;

  AnuncioCard({
    required this.titulo,
    required this.onPressedAplicar,
    required this.onPressedVerMas,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(titulo),
          ),
          ButtonBar(
            children: <Widget>[
              ElevatedButton(
                onPressed: onPressedAplicar,
                child: Text('Aplicar'),
              ),
              ElevatedButton(
                onPressed: onPressedVerMas,
                child: Text('Ver más'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
