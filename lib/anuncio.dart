import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'membresia.dart';
import 'configuracion.dart';

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
  Future<void> publishAd(String name, String content, int participants,
      double value, String vehicleType) async {
    await FirebaseFirestore.instance.collection('anuncios').add({
      'name': name,
      'content': content,
      'participants': participants,
      'value': value,
      'vehicleType': vehicleType,
    });
  }

  void showAdDetailsDialog(BuildContext context, Map<String, dynamic> ad) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles del Anuncio'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Nombre: ${ad['name']}'),
                Text('Contenido del Anuncio: ${ad['content']}'),
                Text('Cantidad de Participantes: ${ad['participants']}'),
                Text('Valor: ${ad['value']}'),
                Text('Tipo de Vehículo: ${ad['vehicleType']}'),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('anuncios').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var ads = snapshot.data!.docs;
          return ListView.builder(
            itemCount: ads.length,
            itemBuilder: (context, index) {
              var ad = ads[index].data() as Map<String, dynamic>;
              return AnuncioCard(
                titulo: ad['name'],
                onPressedVerMas: () {
                  showAdDetailsDialog(context, ad);
                },
              );
            },
          );
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menú',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: Text('Comprar Membresía'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MembershipPage()),
                );
              },
            ),
            ListTile(
              title: Text('Crear Anuncio'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateAdPage(publishAd)),
                );
              },
            ),
            ListTile(
              title: Text('Configuraciones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AnuncioCard extends StatelessWidget {
  final String titulo;
  final VoidCallback onPressedVerMas;

  AnuncioCard({required this.titulo, required this.onPressedVerMas});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(title: Text(titulo)),
          ButtonBar(
            children: <Widget>[
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

class CreateAdPage extends StatefulWidget {
  final Function(String, String, int, double, String) publishAd;

  CreateAdPage(this.publishAd);

  @override
  _CreateAdPageState createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  String _selectedVehicleType = 'Carro';

  bool _isButtonEnabled = false;

  void _checkButtonState() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty &&
          _contentController.text.isNotEmpty &&
          _participantsController.text.isNotEmpty &&
          _valueController.text.isNotEmpty &&
          _selectedVehicleType.isNotEmpty;
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
            DropdownButton<String>(
              value: _selectedVehicleType,
              items: <String>['Carro', 'Moto', 'Bicicleta'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedVehicleType = newValue!;
                  _checkButtonState();
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isButtonEnabled
                  ? () {
                      String name = _nameController.text;
                      String content = _contentController.text;
                      int participants =
                          int.parse(_participantsController.text);
                      double value = double.parse(_valueController.text);
                      String vehicleType = _selectedVehicleType;

                      widget.publishAd(
                          name, content, participants, value, vehicleType);

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
  Future<Map<String, dynamic>?> _fetchMembership() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('membresias')
        .doc('userId')
        .get();
    if (snapshot.exists) {
      return snapshot.data();
    }
    return null;
  }

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
              backgroundImage: AssetImage('assets/foto_perfil.png'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CompanyInfoPage()),
                );
              },
              child: Text('Información'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PublishedAdsPage()),
                );
              },
              child: Text('Anuncios publicados'),
            ),
            ElevatedButton(
              onPressed: () async {
                var membership = await _fetchMembership();
                if (membership != null) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Membresía Actual'),
                        content: Text(
                          'Membresía: ${membership['title']}\n'
                          'Precio: ${membership['price']} COP\n'
                          'Fecha de Compra: ${membership['date'].toDate()}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cerrar'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No has comprado una membresía.')),
                  );
                }
              },
              child: Text('Membresía'),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información de la Empresa'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Información de la Empresa',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Somos una empresa comprometida con el medio ambiente...',
                style: TextStyle(fontSize: 18),
              ),
              // Agrega más información según sea necesario
            ],
          ),
        ),
      ),
    );
  }
}

class PublishedAdsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anuncios Publicados'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('anuncios').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var ads = snapshot.data!.docs;
          return ListView.builder(
            itemCount: ads.length,
            itemBuilder: (context, index) {
              var ad = ads[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(ad['name']),
                subtitle: Text(ad['content']),
              );
            },
          );
        },
      ),
    );
  }
}
