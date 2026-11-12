import 'package:flutter/material.dart';
import 'tela_um.dart';
import 'tela_dois.dart';
import 'tela_tres.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/tela1': (context) => const TelaUm(),
        '/tela2': (context) => const TelaDois(),
        '/tela3': (context) => const TelaTres(),
      },
      home: const TelaZero(),
    );
  }
}

class TelaZero extends StatelessWidget {
  const TelaZero({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App 3 Telas'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      // Adição do Menu Lateral Esquerdo (Drawer)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Menu de Navegação',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Escolha uma opção abaixo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blueAccent),
              title: const Text('Início'),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.orange),
              title: const Text('Consulta de CEP (Tela 1)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tela1');
              },
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny, color: Colors.blue),
              title: const Text('Previsão do Tempo (Tela 2)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tela2');
              },
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on, color: Colors.red),
              title: const Text('Conversor de Moedas (Tela 3)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tela3');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Professores',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(),
            const Text('Tony Bignardi'),
            const Text('Gilson Santos'),
            const SizedBox(height: 40),
            const Text(
              'Disciplinas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('Mobile', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Web', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Banco de Dados', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/tela1');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Entrar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/tela2');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Entrar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/tela3');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Entrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}