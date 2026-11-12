import 'package:flutter/material.dart';

class TelaDois extends StatelessWidget {
  const TelaDois({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desenvolvimento Web'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Disciplina: Desenvolvimento Web',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 10),
            Text(
              'Estudo de tecnologias front-end e back-end para criação de aplicações web modernas.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Conteúdos Abordados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• HTML5, CSS3 e JavaScript'),
            Text('• Frameworks Front-end'),
            Text('• Construção de Serviços RESTful'),
          ],
        ),
      ),
    );
  }
}