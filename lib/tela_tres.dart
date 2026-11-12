import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TelaTres extends StatefulWidget {
  const TelaTres({super.key});

  @override
  State<TelaTres> createState() => _TelaTresState();
}

class _TelaTresState extends State<TelaTres> {
  bool _carregando = true;
  String _erro = '';
  Map<String, dynamic> _taxas = {};

  // Cor principal em verde lima solicitada
  final Color _corLima = const Color.fromRGBO(0, 255, 0, 1);

  Map<String, String> _moedasNomes = {
    'USD': 'Dólar Americano',
    'BRL': 'Real Brasileiro',
    'EUR': 'Euro',
    'GBP': 'Libra Esterlina',
    'JPY': 'Iene Japonês',
    'ARS': 'Peso Argentino',
    'CAD': 'Dólar Canadense',
    'AUD': 'Dólar Australiano',
    'CHF': 'Franco Suíço',
    'CNY': 'Yuan Chinês',
  };

  String _moeda1 = 'USD';
  String _moeda2 = 'BRL';
  String _moeda3 = 'EUR';

  final TextEditingController _ctrl1 = TextEditingController();
  final TextEditingController _ctrl2 = TextEditingController();
  final TextEditingController _ctrl3 = TextEditingController();

  final TextEditingController _buscaController = TextEditingController();
  String _filtroBusca = '';

  bool _atualizando = false;

  @override
  void initState() {
    super.initState();
    _buscarTaxasCambio();
  }

  Future<void> _buscarTaxasCambio() async {
    try {
      final url = Uri.parse('https://open.er-api.com/v6/latest/USD');
      final resposta = await http.get(url);

      if (resposta.statusCode == 200) {
        final dados = json.decode(resposta.body);
        setState(() {
          _taxas = Map<String, dynamic>.from(dados['rates']);
          if (_taxas.isNotEmpty) {
            for (String key in _taxas.keys) {
              if (!_moedasNomes.containsKey(key)) {
                _moedasNomes[key] = key;
              }
            }
          }
          _carregando = false;
        });
      } else {
        setState(() {
          _erro = 'Erro ao carregar taxas de câmbio.';
          _carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        _erro = 'Falha de conexão com o serviço de moedas.';
        _carregando = false;
      });
    }
  }

  void _converter(String origem, String valorStr) {
    if (_atualizando || _taxas.isEmpty) return;
    _atualizando = true;

    double? val = double.tryParse(valorStr.replaceAll(',', '.'));

    if (val == null || val == 0.0) {
      if (origem == '1') {
        _ctrl2.text = '';
        _ctrl3.text = '';
      } else if (origem == '2') {
        _ctrl1.text = '';
        _ctrl3.text = '';
      } else if (origem == '3') {
        _ctrl1.text = '';
        _ctrl2.text = '';
      }
      _atualizando = false;
      setState(() {});
      return;
    }

    double taxaOrigem = (_taxas[_moeda1] ?? 1.0).toDouble();
    double taxa2 = (_taxas[_moeda2] ?? 1.0).toDouble();
    double taxa3 = (_taxas[_moeda3] ?? 1.0).toDouble();

    double valorEmUSD = 0;

    if (origem == '1') {
      valorEmUSD = val / taxaOrigem;
      _ctrl2.text = (valorEmUSD * taxa2).toStringAsFixed(2);
      _ctrl3.text = (valorEmUSD * taxa3).toStringAsFixed(2);
    } else if (origem == '2') {
      valorEmUSD = val / taxa2;
      _ctrl1.text = (valorEmUSD * taxaOrigem).toStringAsFixed(2);
      _ctrl3.text = (valorEmUSD * taxa3).toStringAsFixed(2);
    } else if (origem == '3') {
      valorEmUSD = val / taxa3;
      _ctrl1.text = (valorEmUSD * taxaOrigem).toStringAsFixed(2);
      _ctrl2.text = (valorEmUSD * taxa2).toStringAsFixed(2);
    }

    _atualizando = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var moedasFiltradas = _moedasNomes.entries.where((entry) {
      final query = _filtroBusca.toLowerCase();
      return entry.key.toLowerCase().contains(query) ||
          entry.value.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Moedas Global'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        centerTitle: true,
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
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.green[700]),
                child: const Column(
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
                  Navigator.pushReplacementNamed(context, '/tela2');
                },
              ),
              ListTile(
                leading: Icon(Icons.monetization_on, color: Colors.green[700]),
                title: const Text('Conversor de Moedas (Tela 3)'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Atalhos de Conversão:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: TextField(
                  controller: _buscaController,
                  onChanged: (value) {
                    setState(() {
                      _filtroBusca = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar moeda...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const Divider(),
              ...moedasFiltradas.map((entry) {
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.monetization_on, size: 18, color: Colors.green[700]),
                  title: Text('${entry.key} - ${entry.value}'),
                  onTap: () {
                    setState(() {
                      _moeda1 = entry.key;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
      ),
      body: _carregando
          ? Center(child: CircularProgressIndicator(color: _corLima))
          : _erro.isNotEmpty
              ? Center(child: Text(_erro, style: const TextStyle(color: Colors.red, fontSize: 16)))
              : ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.monetization_on, size: 45, color: _corLima),
                        const SizedBox(height: 8),
                        Text(
                          'Conversor de Moedas Global (3 Campos)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildCampoConversao(
                          label: 'Moeda 1',
                          controller: _ctrl1,
                          moedaSelecionada: _moeda1,
                          onMoedaChanged: (novaMoeda) {
                            setState(() {
                              _moeda1 = novaMoeda!;
                              _converter('1', _ctrl1.text);
                            });
                          },
                          onTextChanged: (val) => _converter('1', val),
                        ),
                        const SizedBox(height: 15),
                        _buildCampoConversao(
                          label: 'Moeda 2',
                          controller: _ctrl2,
                          moedaSelecionada: _moeda2,
                          onMoedaChanged: (novaMoeda) {
                            setState(() {
                              _moeda2 = novaMoeda!;
                              _converter('2', _ctrl2.text);
                            });
                          },
                          onTextChanged: (val) => _converter('2', val),
                        ),
                        const SizedBox(height: 15),
                        _buildCampoConversao(
                          label: 'Moeda 3',
                          controller: _ctrl3,
                          moedaSelecionada: _moeda3,
                          onMoedaChanged: (novaMoeda) {
                            setState(() {
                              _moeda3 = novaMoeda!;
                              _converter('3', _ctrl3.text);
                            });
                          },
                          onTextChanged: (val) => _converter('3', val),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _ctrl1.clear();
                              _ctrl2.clear();
                              _ctrl3.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Limpar Campos', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildCampoConversao({
    required String label,
    required TextEditingController controller,
    required String moedaSelecionada,
    required ValueChanged<String?> onMoedaChanged,
    required ValueChanged<String> onTextChanged,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: onTextChanged,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _moedasNomes.containsKey(moedaSelecionada) ? moedaSelecionada : _moedasNomes.keys.first,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                items: _moedasNomes.keys.map((String codigo) {
                  return DropdownMenuItem<String>(
                    value: codigo,
                    child: Text(
                      codigo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: onMoedaChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}