// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'membresia.dart';
import 'configuracion.dart';

class Anuncio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity, colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: Colors.blueAccent),
      ),
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

  void showAdDetailsDialog(BuildContext context, Map<String, dynamic> ad, String adId) {
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
            TextButton(
              onPressed: () {
                showConfirmationDialog(context, adId);
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void showConfirmationDialog(BuildContext context, String adId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Atención'),
          content: Text('¿Está seguro de que desea eliminar este anuncio?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo de confirmación
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Cerrar el diálogo de confirmación
                await deleteAd(adId); // Eliminar el anuncio de la base de datos
                Navigator.pop(context); // Cerrar el diálogo de detalles
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Anuncio eliminado con éxito')),
                );
              },
              child: Text('Sí', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteAd(String adId) async {
    try {
      await FirebaseFirestore.instance.collection('anuncios').doc(adId).delete();
    } catch (e) {
      print('Error al eliminar el anuncio: $e');
    }
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
              String adId = ads[index].id;
              return AnuncioCard(
                titulo: ad['name'],
                onPressedVerMas: () {
                  showAdDetailsDialog(context, ad, adId);
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
              decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  image: AssetImage('assets/drawer_header_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Text('Menú',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.payment),
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
              leading: Icon(Icons.add_box),
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
              leading: Icon(Icons.settings),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                titulo,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            ButtonBar(
              children: <Widget>[
                ElevatedButton(
                  onPressed: onPressedVerMas,
                  child: Text('Ver más'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (value) {
                  _checkButtonState();
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Contenido del Anuncio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (value) {
                  _checkButtonState();
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _participantsController,
                decoration: InputDecoration(
                  labelText: 'Cantidad de Participantes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _checkButtonState();
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _checkButtonState();
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: InputDecoration(
                  labelText: 'Tipo de Vehículo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
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
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                        String name = _nameController.text;
                        String content = _contentController.text;
                        int participants = int.parse(_participantsController.text);
                        double value = double.parse(_valueController.text);
                        String vehicleType = _selectedVehicleType;

                        widget.publishAd(
                            name, content, participants, value, vehicleType);

                        Navigator.pop(context);
                      }
                    : null,
                child: Text('Publicar Anuncio'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: _isButtonEnabled ? Colors.blue : Colors.grey,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Empresa {
  final String nombre;
  final String introduccion;
  final String direccion;
  final String telefono;
  final String? imagenUrl;

  Empresa({
    required this.nombre,
    required this.introduccion,
    required this.direccion,
    required this.telefono,
    this.imagenUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'introduccion': introduccion,
      'direccion': direccion,
      'telefono': telefono,
      'imagenUrl': imagenUrl,
    };
  }

  static Empresa fromMap(Map<String, dynamic> map) {
    return Empresa(
      nombre: map['nombre'],
      introduccion: map['introduccion'],
      direccion: map['direccion'],
      telefono: map['telefono'],
      imagenUrl: map['imagenUrl'],
    );
  }
}
class ProfilePage extends StatefulWidget {
  static Empresa? empresaGuardada;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>?> _fetchMembership() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión para ver tu membresía.')),
      );
      return null;
    }

    var docSnapshot = await FirebaseFirestore.instance
        .collection('membresia_empresas')
        .doc(user.uid)
        .get();

    return docSnapshot.exists ? docSnapshot.data() : null;
  }

  Future<void> _fetchEmpresaGuardada() async {
    var docSnapshot =
        await FirebaseFirestore.instance.collection('empresas').doc('empresa1').get();
    if (docSnapshot.exists) {
      setState(() {
        ProfilePage.empresaGuardada =
            Empresa.fromMap(docSnapshot.data() as Map<String, dynamic>);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEmpresaGuardada();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CompanyInfoPage()),
                );
              },
              child: Text('Editar Información de Empresa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PublishedAdsPage()),
                );
              },
              child: Text('Ver Anuncios Publicados'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
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
                            'Tipo de Membresía: ${membership['title']}\nPrecio: \$${membership['price']} COP\nEstado: ${membership['estado'] ?? 'Activo'}'),
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
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No tienes una membresía activa.')),
                  );
                }
              },
              child: Text('Ver Membresía'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (ProfilePage.empresaGuardada != null) ...[
              SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text('Información de la Empresa'),
                  subtitle: Text(ProfilePage.empresaGuardada!.nombre),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompanyDetailsPage(
                          empresa: ProfilePage.empresaGuardada!,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _introduccionController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  File? _imageFile;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _saveEmpresa() async {
    String? imageUrl;
    if (_imageFile != null) {
      try {
        var snapshot = await FirebaseStorage.instance
            .ref()
            .child('imagenes/${DateTime.now().millisecondsSinceEpoch}')
            .putFile(_imageFile!);
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    Empresa empresa = Empresa(
      nombre: _nombreController.text,
      introduccion: _introduccionController.text,
      direccion: _direccionController.text,
      telefono: _telefonoController.text,
      imagenUrl: imageUrl,
    );

    await FirebaseFirestore.instance.collection('empresas').doc('empresa1').set(empresa.toMap());

    setState(() {
      ProfilePage.empresaGuardada = empresa;
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
        child: ListView(
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : ProfilePage.empresaGuardada?.imagenUrl != null
                        ? NetworkImage(ProfilePage.empresaGuardada!.imagenUrl!)
                        : AssetImage('assets/foto_perfil.png') as ImageProvider,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.camera_alt,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre de la Empresa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _introduccionController,
              decoration: InputDecoration(
                labelText: 'Introducción',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _direccionController,
              decoration: InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveEmpresa();
                Navigator.pop(context);
              },
              child: Text('Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class CompanyDetailsPage extends StatelessWidget {
  final Empresa empresa;

  CompanyDetailsPage({required this.empresa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Empresa'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            if (empresa.imagenUrl != null)
              Center(
                child: Image.network(
                  empresa.imagenUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 20),
            Text(
              'Nombre: ${empresa.nombre}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Introducción: ${empresa.introduccion}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Dirección: ${empresa.direccion}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Teléfono: ${empresa.telefono}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
class PublishedAdsPage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchAds() async {
    var querySnapshot = await FirebaseFirestore.instance.collection('anuncios').get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anuncios Publicados'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAds(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var ads = snapshot.data!;
          return ListView.builder(
            itemCount: ads.length,
            itemBuilder: (context, index) {
              var ad = ads[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    ad['name'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(ad['content']),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    // Acciones al tocar el anuncio
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
