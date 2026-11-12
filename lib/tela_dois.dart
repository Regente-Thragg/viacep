import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TelaDois extends StatefulWidget {
  const TelaDois({super.key});

  @override
  State<TelaDois> createState() => _TelaDoisState();
}

class _TelaDoisState extends State<TelaDois> {
  final TextEditingController _cidadeController = TextEditingController();
  bool _carregando = false;
  String _resultadoErro = '';
  Map<String, dynamic>? _dadosClima;

  Future<void> _consultarClima() async {
    final nomeCidade = _cidadeController.text.trim();

    if (nomeCidade.isEmpty) {
      setState(() {
        _resultadoErro = 'Por favor, digite o nome de uma cidade.';
        _dadosClima = null;
      });
      return;
    }

    setState(() {
      _carregando = true;
      _resultadoErro = '';
      _dadosClima = null;
    });

    try {
      // 1. Busca a latitude e longitude da cidade na API de Geocodificação da Open-Meteo
      final urlGeo = Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=$nomeCidade&count=1&language=pt&format=json');

      final respostaGeo = await http.get(urlGeo);

      if (respostaGeo.statusCode == 200) {
        final dadosGeo = json.decode(respostaGeo.body);

        if (dadosGeo['results'] == null || (dadosGeo['results'] as List).isEmpty) {
          setState(() {
            _resultadoErro = 'Cidade não encontrada. Verifique a digitação.';
            _carregando = false;
          });
          return;
        }

        final cidadeInfo = dadosGeo['results'][0];
        final double lat = cidadeInfo['latitude'];
        final double lon = cidadeInfo['longitude'];
        final String nomeOficial = cidadeInfo['name'];
        final String estado = cidadeInfo['admin1'] ?? '';
        final String pais = cidadeInfo['country'] ?? '';

        // 2. Monta a URL de forma limpa e segura com os parâmetros corretos
        final urlClima = Uri.https('api.open-meteo.com', '/v1/forecast', {
          'latitude': lat.toString(),
          'longitude': lon.toString(),
          'current_weather': 'true',
        });

        final respostaClima = await http.get(urlClima);

        if (respostaClima.statusCode == 200) {
          final dadosClima = json.decode(respostaClima.body);
          setState(() {
            _dadosClima = {
              'cidade': '$nomeOficial${estado.isNotEmpty ? ' - $estado' : ''} ($pais)',
              'temperatura': dadosClima['current_weather']['temperature'],
              'vento': dadosClima['current_weather']['windspeed'],
              'condicao': _traduzirCodigoClima(dadosClima['current_weather']['weathercode']),
            };
          });
        } else {
          setState(() {
            _resultadoErro = 'Erro ao buscar dados meteorológicos.';
          });
        }
      } else {
        setState(() {
          _resultadoErro = 'Erro ao localizar a cidade.';
        });
      }
    } catch (e) {
      setState(() {
        _resultadoErro = 'Erro de conexão. Verifique sua internet.';
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  String _traduzirCodigoClima(int codigo) {
    if (codigo == 0) return 'Céu limpo ☀️';
    if (codigo >= 1 && codigo <= 3) return 'Parcialmente nublado ⛅';
    if (codigo >= 45 && codigo <= 48) return 'Nevoeiro 🌫️';
    if (codigo >= 51 && codigo <= 67) return 'Chuva leve / Garoa 🌧️';
    if (codigo >= 71 && codigo <= 77) return 'Neve ❄️';
    if (codigo >= 80 && codigo <= 82) return 'Pancadas de chuva 🌦️';
    if (codigo >= 95) return 'Tempestade com raios ⚡';
    return 'Nublado / Variável ☁️';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previsão do Tempo - Brasil & Mundo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
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
                      'Trocar de Tela',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.blueAccent),
                title: const Text('Início (Principal)'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.orange),
                title: const Text('Consulta de CEP (Tela 1)'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/tela1');
                },
              ),
              ListTile(
                leading: const Icon(Icons.wb_sunny, color: Colors.blue),
                title: const Text('Previsão do Tempo (Tela 2)'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.monetization_on, color: Colors.green[700]),
                title: const Text('Conversor de Moedas (Tela 3)'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/tela3');
                },
              ),
            ],
          ),
        ),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Consulte o Clima de Qualquer Cidade:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cidadeController,
                decoration: InputDecoration(
                  labelText: 'Nome da Cidade (ex: Coxim, Campo Grande, São Paulo)',
                  hintText: 'Digite o nome da cidade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.location_city, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _carregando ? null : _consultarClima,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(
                  _carregando ? 'Buscando clima...' : 'Consultar Clima',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              if (_resultadoErro.isNotEmpty)
                Text(
                  _resultadoErro,
                  style: const TextStyle(color: Colors.red, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              if (_dadosClima != null) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Clima em ${_dadosClima!['cidade']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                        Text(
                          '${_dadosClima!['temperatura']} °C',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Condição: ${_dadosClima!['condicao']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vento: ${_dadosClima!['vento']} km/h',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}