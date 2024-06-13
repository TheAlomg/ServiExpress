import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:servi_express/anuncio.dart';
import 'Domimembresia.dart';
import 'Domiconfiguracion.dart';

class DomiAnuncio extends StatelessWidget {
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
  void applyToAd(String adId, int currentParticipants) async {
    // Verificar si hay participantes disponibles
    if (currentParticipants > 0) {
      // Reducir la cantidad de participantes en el anuncio
      await FirebaseFirestore.instance
          .collection('anuncios')
          .doc(adId)
          .update({'participants': currentParticipants - 1});

      // Registrar la aplicación del usuario
      await FirebaseFirestore.instance.collection('aplicaciones').add({
        'adId': adId,
        'userId': 'someUserId', // ID del usuario actual
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No hay más participantes disponibles para este anuncio'),
      ));
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
              var adId = ads[index].id;
              return AdCard(
                ad: ad,
                adId: adId,
                onApply: () => applyToAd(adId, ad['participants']),
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
                  MaterialPageRoute(builder: (context) => DomiMembershipPage()),
                );
              },
            ),
            ListTile(
              title: Text('Ver Aplicaciones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ApplicationsPage()),
                );
              },
            ),
            ListTile(
              title: Text('Configuraciones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DomiSettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AdCard extends StatefulWidget {
  final Map<String, dynamic> ad;
  final String adId;
  final VoidCallback onApply;

  AdCard({required this.ad, required this.adId, required this.onApply});

  @override
  _AdCardState createState() => _AdCardState();
}

class _AdCardState extends State<AdCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(widget.ad['name']),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Contenido: ${widget.ad['content']}'),
                  Text('Cantidad de Participantes: ${widget.ad['participants']}'),
                  Text('Valor: ${widget.ad['value']}'),
                  Text('Tipo de Vehículo: ${widget.ad['vehicleType']}'),
                ],
              ),
            ),
          ButtonBar(
            children: <Widget>[
              ElevatedButton(
                onPressed: widget.onApply,
                child: Text('Aplicar'),
              ),
            ],
          ),
        ],
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileDetailPage()),
                );
              },
              child: Text('Perfil'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DomiciliarioInfoForm()),
                );
              },
              child: Text('Editar Perfil'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ApplicationsPage()),
                );
              },
              child: Text('Aplicaciones Terminadas'),
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
                            'Tipo de Membresía: ${membership['title']}\nEstado: ${membership['estado'] ?? 'Activo'}'),
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
        .collection('membresia_domiciliarios')
        .doc('userId') // Reemplaza 'userId' con el ID real del usuario
        .get();
    if (snapshot.exists) {
      return snapshot.data();
    }
    return null;
  }
}


class ProfileDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Perfil'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('perfil_domiciliario')
            .doc('userId') // Reemplaza 'userId' con el ID real del usuario
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var data = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Nombre: ${data['nombre']}', style: TextStyle(fontSize: 18)),
                Text('Matricula: ${data['introduccion']}', style: TextStyle(fontSize: 18)),
                Text('Tipo de Vehiculo: ${data['direccion']}', style: TextStyle(fontSize: 18)),
                Text('Teléfono: ${data['telefono']}', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Domiciliario {
  final String nombre;
  final String introduccion;
  final String direccion;
  final String telefono;

  Domiciliario({
    required this.nombre,
    required this.introduccion,
    required this.direccion,
    required this.telefono,
  });
}

class DomiciliarioInfoForm extends StatefulWidget {
  static Domiciliario? domiciliarioGuardado;

  @override
  _DomiciliarioInfoFormState createState() => _DomiciliarioInfoFormState();
}

class _DomiciliarioInfoFormState extends State<DomiciliarioInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late String _introduccion;
  late String _direccion;
  late String _telefono;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        DomiciliarioInfoForm.domiciliarioGuardado = Domiciliario(
          nombre: _nombre,
          introduccion: _introduccion,
          direccion: _direccion,
          telefono: _telefono,
        );
      });

      // Guardar en Firestore
      await FirebaseFirestore.instance
          .collection('perfil_domiciliario')
          .doc('userId') // Reemplaza 'userId' con el ID real del usuario
          .set({
        'nombre': _nombre,
        'introduccion': _introduccion,
        'direccion': _direccion,
        'telefono': _telefono,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese su nombre';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nombre = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Matricula'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese su matricula';
                  }
                  return null;
                },
                onSaved: (value) {
                  _introduccion = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Tipo de Vehiculo'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese su tipo de vehiculo';
                  }
                  return null;
                },
                onSaved: (value) {
                  _direccion = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Teléfono'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese su teléfono';
                  }
                  return null;
                },
                onSaved: (value) {
                  _telefono = value!;
                },
              ),
              SizedBox(height: 16.0),
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

class ApplicationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplicaciones'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('aplicaciones').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var applications = snapshot.data!.docs;
          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              var application = applications[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Anuncio ID: ${application['adId']}'),
                subtitle: Text('Usuario ID: ${application['userId']}'),
              );
            },
          );
        },
      ),
    );
  }
}
