import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:examen/pages/dashboard.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pushNamed(context, '/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Cours'),
            onTap: () {
              Navigator.pushNamed(context, '/cours');
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Étudiant'),
            onTap: () {
              Navigator.pushNamed(context, '/etudiants');
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent, color: Colors.indigo),
            title: const Text("Service Client", style: TextStyle(fontSize: 16)),
            onTap: () {
              appeler(); // définis cette fonction pour lancer un appel, ouvrir WhatsApp, etc.
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text("Quitter", style: TextStyle(fontSize: 16)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

void appeler() async {
  const tel = 'tel:+221771234567'; // <-- change avec ton vrai numéro
  final uri = Uri.parse(tel);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Impossible d’ouvrir le numéro $tel';
  }
}
