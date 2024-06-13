import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importar Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Importar Firebase Auth

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Membresías',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MembershipPage(),
    );
  }
}

class MembershipPage extends StatelessWidget {
  Future<void> _buyMembership(
      BuildContext context, String title, int price) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión para comprar una membresía.')),
      );
      return;
    }

    var snapshot = await FirebaseFirestore.instance
        .collection('membresia_empresas')
        .doc(user.uid)
        .get();

    if (snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ya has comprado una membresía.')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('membresia_empresas')
        .doc(user.uid)
        .set({
      'title': title,
      'price': price,
      'date': DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gracias por comprar la membresía $title.')),
    );

    Navigator.pop(context); // Regresar a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comprar Membresía'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          MembershipCard(
            title: 'Platino',
            price: 45000,
            normalAds: 35,
            urgentAds: 10,
            premiumAds: 3,
            color: Colors.blueGrey,
            onBuy: (context) => _buyMembership(context, 'Platino', 45000),
          ),
          MembershipCard(
            title: 'Diamante',
            price: 30000,
            normalAds: 20,
            urgentAds: 5,
            premiumAds: 1,
            color: Colors.blue,
            onBuy: (context) => _buyMembership(context, 'Diamante', 30000),
          ),
          MembershipCard(
            title: 'Oro',
            price: 18500,
            normalAds: 10,
            urgentAds: 3,
            premiumAds: 0,
            color: Colors.amber,
            onBuy: (context) => _buyMembership(context, 'Oro', 18500),
          ),
        ],
      ),
    );
  }
}

class MembershipCard extends StatelessWidget {
  final String title;
  final int price;
  final int normalAds;
  final int urgentAds;
  final int premiumAds;
  final Color color;
  final Function(BuildContext) onBuy;

  MembershipCard({
    required this.title,
    required this.price,
    required this.normalAds,
    required this.urgentAds,
    required this.premiumAds,
    required this.color,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                  fontSize: 24.0, fontWeight: FontWeight.bold, color: color),
            ),
            SizedBox(height: 10.0),
            Text(
              'Precio: \$${price.toStringAsFixed(0)} COP',
              style: TextStyle(fontSize: 20.0, color: color),
            ),
            SizedBox(height: 10.0),
            Text('Anuncios Normales: $normalAds'),
            Text('Anuncios Urgentes: $urgentAds'),
            Text('Anuncios Premium: $premiumAds'),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () => onBuy(context),
              child: Text('Comprar'),
            ),
          ],
        ),
      ),
    );
  }
}
