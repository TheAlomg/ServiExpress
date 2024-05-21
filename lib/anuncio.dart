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
  List<Map<String, dynamic>> _publishedAds = [];

  void updateAdDetails(String name, String content, int participants, double value, String vehicleType) {
    setState(() {
      _adName = name;
      _adContent = content;
      _adParticipants = participants;
      _adValue = value;
    });
  }

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

  void publishAd(String name, String content, int participants, double value, String vehicleType) {
    setState(() {
      _publishedAds.add({
        'name': name,
        'content': content,
        'participants': participants,
        'value': value,
        'vehicleType': vehicleType,
      });
    });
  }

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(appliedAds: _appliedAds, publishedAds: _publishedAds)),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Anuncios disponibles', style: TextStyle(fontSize: 20.0)),
            AnuncioCard(
              titulo: 'Anuncio 1',
              onPressedAplicar: () {
                applyToAd('Anuncio 1', 'Contenido del Anuncio 1', 10, 100.0);
              },
              onPressedVerMas: () {
                showAdDetailsDialog(context);
              },
            ),
            AnuncioCard(
              titulo: 'Anuncio 2',
              onPressedAplicar: () {
                applyToAd('Anuncio 2', 'Contenido del Anuncio 2', 5, 200.0);
              },
              onPressedVerMas: () {
                showAdDetailsDialog(context);
              },
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: Text('Comprar Membresia'),
              onTap: () {
                Navigator.pop(context); // Cierra el menú
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MembershipPage()),
                );
              },
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Cierra el menú
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateAdPage(publishAd)),
                );
              },
              child: ListTile(title: Text('Crear Anuncio')),
            ),
            ListTile(
              title: Text('Configuraciones'),
              onTap: () {
                Navigator.pop(context); // Cierra el menú
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
              decoration: InputDecoration(labelText: 'Cantidad de Participantes'),
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
                      int participants = int.parse(_participantsController.text);
                      double value = double.parse(_valueController.text);
                      String vehicleType = _selectedVehicleType;

                      widget.publishAd(name, content, participants, value, vehicleType);

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
  final List<Map<String, dynamic>> publishedAds;

  ProfilePage({required this.appliedAds, required this.publishedAds});

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
                  MaterialPageRoute(builder: (context) => AppliedAdsPage(appliedAds: appliedAds)),
                );
              },
              child: Text('Anuncios publicados'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Membresía'),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyInfoPage extends StatefulWidget {
  @override
  _CompanyInfoPageState createState() => _CompanyInfoPageState();
}

class _CompanyInfoPageState extends State<CompanyInfoPage> {
  String _companyName = 'Nombre de la Empresa';
  String _companyDescription = 'Descripción de la Empresa';
  String _ownerName = 'Nombre del Dueño';
  String _location = 'Ubicación';

  bool _isEditing = false;
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyDescriptionController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _companyNameController.text = _companyName;
    _companyDescriptionController.text = _companyDescription;
    _ownerNameController.text = _ownerName;
    _locationController.text = _location;
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        _companyName = _companyNameController.text;
        _companyDescription = _companyDescriptionController.text;
        _ownerName = _ownerNameController.text;
        _location = _locationController.text;
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información de la Empresa'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_isEditing)
              Column(
                children: <Widget>[
                  TextField(
                    controller: _companyNameController,
                    decoration: InputDecoration(labelText: 'Nombre de la Empresa'),
                  ),
                  TextField(
                    controller: _companyDescriptionController,
                    decoration: InputDecoration(labelText: 'Descripción de la Empresa'),
                  ),
                  TextField(
                    controller: _ownerNameController,
                    decoration: InputDecoration(labelText: 'Nombre del Dueño'),
                  ),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'Ubicación'),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Nombre de la Empresa: $_companyName', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Descripción de la Empresa: $_companyDescription', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Nombre del Dueño: $_ownerName', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Ubicación: $_location', style: TextStyle(fontSize: 16)),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleEdit,
              child: Text(_isEditing ? 'Guardar' : 'Editar'),
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

  AnuncioCard({required this.titulo, required this.onPressedAplicar, required this.onPressedVerMas});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(title: Text(titulo)),
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

class PublishedAdsPage extends StatelessWidget {
  final List<Map<String, dynamic>> publishedAds;

  PublishedAdsPage({required this.publishedAds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anuncios Publicados'),
      ),
      body: ListView.builder(
        itemCount: publishedAds.length,
        itemBuilder: (context, index) {
          final ad = publishedAds[index];
          return ListTile(
            title: Text(ad['name']),
            subtitle: Text(ad['content']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditAdPage(ad: ad),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EditAdPage extends StatefulWidget {
  final Map<String, dynamic> ad;

  EditAdPage({required this.ad});

  @override
  _EditAdPageState createState() => _EditAdPageState();
}

class _EditAdPageState extends State<EditAdPage> {
  late TextEditingController _nameController;
  late TextEditingController _contentController;
  late TextEditingController _participantsController;
  late TextEditingController _valueController;
  late String _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ad['name']);
    _contentController = TextEditingController(text: widget.ad['content']);
    _participantsController = TextEditingController(text: widget.ad['participants'].toString());
    _valueController = TextEditingController(text: widget.ad['value'].toString());
    _selectedVehicleType = widget.ad['vehicleType'];
  }

  void _saveAd() {
    setState(() {
      widget.ad['name'] = _nameController.text;
      widget.ad['content'] = _contentController.text;
      widget.ad['participants'] = int.parse(_participantsController.text);
      widget.ad['value'] = double.parse(_valueController.text);
      widget.ad['vehicleType'] = _selectedVehicleType;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Anuncio'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Contenido del Anuncio'),
            ),
            TextField(
              controller: _participantsController,
              decoration: InputDecoration(labelText: 'Cantidad de Participantes'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _valueController,
              decoration: InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
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
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAd,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
