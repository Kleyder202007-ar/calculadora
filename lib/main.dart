import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Pro',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = '0';
  String _history = '';
  final List<String> _historyLog = [];
  double _num1 = 0;
  double _num2 = 0;
  String _operand = '';
  bool _isNewOperand = true;

  void _buttonPressed(String buttonText) {
    HapticFeedback.lightImpact();

    setState(() {
      if (buttonText == 'AC') {
        _output = '0';
        _history = '';
        _num1 = 0;
        _num2 = 0;
        _operand = '';
        _isNewOperand = true;
      } else if (buttonText == '⌫') {
        if (_output.length > 1 && _output != 'Error') {
          _output = _output.substring(0, _output.length - 1);
        } else {
          _output = '0';
          _isNewOperand = true;
        }
      } else if (['+', '-', '×', '÷'].contains(buttonText)) {
        if (_operand.isNotEmpty && !_isNewOperand) {
          _calculateResult(isIntermediate: true);
        } else {
          _num1 = double.tryParse(_output) ?? 0;
        }
        _operand = buttonText;
        _history = '$_output $_operand ';
        _isNewOperand = true;
      } else if (buttonText == '.') {
        if (_isNewOperand) {
          _output = '0.';
          _isNewOperand = false;
        } else if (!_output.contains('.')) {
          _output = '$_output.';
        }
      } else if (buttonText == '%') {
        double current = double.tryParse(_output) ?? 0;
        _output = (current / 100).toString();
        _cleanTrailingZero();
      } else if (buttonText == '=') {
        if (_operand.isNotEmpty) {
          _calculateResult(isIntermediate: false);
        }
      } else {
        if (_output == '0' || _output == 'Error' || _isNewOperand) {
          _output = buttonText;
          _isNewOperand = false;
        } else {
          _output += buttonText;
        }
      }
    });
  }

  void _calculateResult({required bool isIntermediate}) {
    _num2 = double.tryParse(_output) ?? 0;
    String calculationExpression = '$_history$_output';

    switch (_operand) {
      case '+':
        _output = (_num1 + _num2).toString();
        break;
      case '-':
        _output = (_num1 - _num2).toString();
        break;
      case '×':
        _output = (_num1 * _num2).toString();
        break;
      case '÷':
        if (_num2 == 0) {
          _output = 'Error';
        } else {
          _output = (_num1 / _num2).toString();
        }
        break;
    }

    _cleanTrailingZero();

    if (!isIntermediate) {
      if (_output != 'Error') {
        _historyLog.insert(0, '$calculationExpression = $_output');
      }
      _history = '';
      _operand = '';
      _isNewOperand = true;
    } else {
      _num1 = double.tryParse(_output) ?? 0;
      _history = '$_output $_operand ';
      _isNewOperand = true;
    }
  }

  void _cleanTrailingZero() {
    if (_output != 'Error') {
      if (_output.endsWith('.0')) {
        _output = _output.substring(0, _output.length - 2);
      }
    }
  }

  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Corregido aquí
                children: [
                  const Text(
                    'Historial de operaciones',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        _historyLog.clear();
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _historyLog.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay historial aún',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _historyLog.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _historyLog[index],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalcButton(String text, {int flex = 1, String type = 'number'}) {
    final theme = Theme.of(context);

    Color bgColor;
    Color fgColor;

    if (type == 'operator') {
      bgColor = theme.colorScheme.primaryContainer;
      fgColor = theme.colorScheme.onPrimaryContainer;
    } else if (type == 'equal') {
      bgColor = theme.colorScheme.primary;
      fgColor = theme.colorScheme.onPrimary;
    } else if (type == 'special') {
      // Usamos surfaceVariant compatible con versiones anteriores
      bgColor = theme.colorScheme.surfaceVariant;
      fgColor = theme.colorScheme.onSurfaceVariant;
    } else {
      bgColor = theme.colorScheme.surface;
      fgColor = theme.colorScheme.onSurface;
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 22),
          ),
          onPressed: () => _buttonPressed(text),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora Pro'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver historial',
            onPressed: _showHistoryModal,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _history,
                      style: TextStyle(
                        fontSize: 20,
                        color: theme.colorScheme.primary.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      alignment: Alignment.centerRight,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _output,
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 0.5),
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildCalcButton('AC', type: 'special'),
                          _buildCalcButton('⌫', type: 'special'),
                          _buildCalcButton('%', type: 'special'),
                          _buildCalcButton('÷', type: 'operator'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildCalcButton('7'),
                          _buildCalcButton('8'),
                          _buildCalcButton('9'),
                          _buildCalcButton('×', type: 'operator'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildCalcButton('4'),
                          _buildCalcButton('5'),
                          _buildCalcButton('6'),
                          _buildCalcButton('-', type: 'operator'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildCalcButton('1'),
                          _buildCalcButton('2'),
                          _buildCalcButton('3'),
                          _buildCalcButton('+', type: 'operator'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildCalcButton('0', flex: 2),
                          _buildCalcButton('.'),
                          _buildCalcButton('=', type: 'equal'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
