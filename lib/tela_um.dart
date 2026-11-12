import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TelaUm extends StatefulWidget {
  const TelaUm({super.key});

  @override
  State<TelaUm> createState() => _TelaUmState();
}

class _TelaUmState extends State<TelaUm> {
  final TextEditingController _cepController = TextEditingController();
  
  bool _carregando = false;
  String _resultado = '';
  Map<String, dynamic>? _dadosCep;

  // Função para consultar a API do ViaCEP
  Future<void> _consultarCep() async {
    final cep = _cepController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) {
      setState(() {
        _resultado = 'Digite um CEP válido com 8 dígitos.';
        _dadosCep = null;
      });
      return;
    }

    setState(() {
      _carregando = true;
      _resultado = '';
      _dadosCep = null;
    });

    try {
      final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
      final resposta = await http.get(url);

      if (resposta.statusCode == 200) {
        final dados = json.decode(resposta.body);

        if (dados.containsKey('erro') && dados['erro'] == true) {
          setState(() {
            _resultado = 'CEP não encontrado na base de dados.';
          });
        } else {
          setState(() {
            _dadosCep = dados;
          });
        }
      } else {
        setState(() {
          _resultado = 'Erro ao consultar a API.';
        });
      }
    } catch (e) {
      setState(() {
        _resultado = 'Erro de conexão. Verifique sua internet.';
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de CEP (ViaCEP)'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Digite o CEP que deseja consultar:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              maxLength: 9,
              decoration: InputDecoration(
                labelText: 'CEP',
                hintText: 'Ex: 01001-000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _carregando ? null : _consultarCep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _carregando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(
                _carregando ? 'Consultando...' : 'Buscar CEP',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            if (_resultado.isNotEmpty)
              Text(
                _resultado,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            if (_dadosCep != null) ...[
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        const Text(
                          'Resultado da Consulta:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                        Text('CEP: ${_dadosCep!['cep']}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Logradouro: ${_dadosCep!['logradouro']}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Complemento: ${_dadosCep!['complemento'] ?? 'Nenhum'}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Bairro: ${_dadosCep!['bairro']}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Cidade: ${_dadosCep!['localidade']}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Estado: ${_dadosCep!['uf']}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('DDD: ${_dadosCep!['ddd']}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}