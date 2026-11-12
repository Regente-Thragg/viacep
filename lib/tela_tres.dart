import 'package:flutter/material.dart';

class TelaTres extends StatelessWidget {
  const TelaTres({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banco de Dados'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Disciplina: Banco de Dados',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 10),
            Text(
              'Modelagem, gerenciamento e consultas em bancos de dados relacionais e não relacionais.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Conteúdos Abordados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Modelagem Conceitual e Lógica'),
            Text('• Linguagem SQL (DDL e DML)'),
            Text('• Conexão de Apps com Bancos de Dados'),
          ],
        ),
      ),
    );
  }
}