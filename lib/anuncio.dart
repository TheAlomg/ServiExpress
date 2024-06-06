import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'membresia.dart';
import 'configuracion.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
                if (CompanyInfoForm.empresaGuardada != null) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Información de la Empresa'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Nombre: ${CompanyInfoForm.empresaGuardada!.nombre}'),
                            Text('Introducción: ${CompanyInfoForm.empresaGuardada!.introduccion}'),
                            Text('Dirección: ${CompanyInfoForm.empresaGuardada!.direccion}'),
                            Text('Teléfono: ${CompanyInfoForm.empresaGuardada!.telefono}'),
                          ],
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No hay información de empresa guardada')));
                }
              },
              child: Text('Perfil'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CompanyInfoForm()),
                );
              },
              child: Text('Editar Perfil'),
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
                            'Tipo de Membresía: ${membership['tipo']}\nEstado: ${membership['estado']}'),
                        actions: <Widget>[
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
                }
              },
              child: Text('Ver Membresía'),
            ),
          ],
        ),
      ),
    );
  }

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
}


class Empresa {
  final String nombre;
  final String introduccion;
  final String direccion;
  final String telefono;

  Empresa({
    required this.nombre,
    required this.introduccion,
    required this.direccion,
    required this.telefono,
  });
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
              CompanyInfoForm(), // Llamada a la clase interna
            ],
          ),
        ),
      ),
    );
  }
}

class CompanyInfoForm extends StatefulWidget {
  static Empresa? empresaGuardada;

  @override
  _CompanyInfoFormState createState() => _CompanyInfoFormState();
}

class _CompanyInfoFormState extends State<CompanyInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _introduccionController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final List<File> _imagenes = [];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Agregar la información de la empresa a Firestore
        DocumentReference companyRef = await FirebaseFirestore.instance.collection('perfil_de_empresa').add({
          'nombre': _nombreController.text,
          'introduccion': _introduccionController.text,
          'direccion': _direccionController.text,
          'telefono': _telefonoController.text,
        });

        // Guardar la información en una variable estática
        CompanyInfoForm.empresaGuardada = Empresa(
          nombre: _nombreController.text,
          introduccion: _introduccionController.text,
          direccion: _direccionController.text,
          telefono: _telefonoController.text,
        );

        // Subir las imágenes
        await _uploadImages(companyRef.id);

        // Mostrar un mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Información guardada con éxito')));

        // Limpiar los campos después de guardar
        _nombreController.clear();
        _introduccionController.clear();
        _direccionController.clear();
        _telefonoController.clear();
        setState(() {
          _imagenes.clear();
        });
      } catch (e) {
        // Manejo de errores
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar la información')));
      }
    }
  }

  Future<void> _uploadImages(String docId) async {
    // Implementación para subir imágenes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información de la Empresa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese el nombre de la empresa';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _introduccionController,
                decoration: InputDecoration(labelText: 'Introducción'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese una introducción';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(labelText: 'Dirección'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese la dirección';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese el teléfono';
                  }
                  return null;
                },
              ),
              // Añadir aquí el widget para cargar imágenes si es necesario
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Guardar'),
              ),
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
