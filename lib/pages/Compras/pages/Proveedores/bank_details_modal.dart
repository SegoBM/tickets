import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import '../../../../shared/utils/icon_library.dart';
import '../../../../shared/widgets/buttons/dropdown_decoration.dart';
import '../../../../shared/widgets/textfields/my_textfield_icon.dart';

class BankDetailsModal extends StatefulWidget {
  final Function(Map<String, String>) onSave;
  final Map<String, String>? initialData;

  const BankDetailsModal({super.key, required this.onSave, this.initialData});

  @override
  _BankDetailsModalState createState() => _BankDetailsModalState();
}

class _BankDetailsModalState extends State<BankDetailsModal> {
  late Size size;
  late ThemeData theme;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController bancoController = TextEditingController();
  final TextEditingController clabeController = TextEditingController();
  final TextEditingController nombreTitularController = TextEditingController();
  final TextEditingController tipoCuentaController = TextEditingController();
  final TextEditingController bancoIntController = TextEditingController();
  final TextEditingController clabeIntController = TextEditingController();
  final TextEditingController tipoCuentaIntController = TextEditingController();
  List<String> listMonedasString = [];
  List<String> metodosPago = ["TRANSFERENCIA", "CHEQUE", "EFECTIVO"];
  String selectedMoneda = "";
  String selectedMetodoPago = "TRANSFERENCIA";

  @override
  void initState() {
    super.initState();
    listMonedasString = ["USD", "MXN", "EUR"];
    selectedMoneda = listMonedasString.first;
    if (widget.initialData != null) {
      bancoController.text = widget.initialData!['Banco'] ?? '';
      clabeController.text = widget.initialData!['Clabe'] ?? '';
      nombreTitularController.text = widget.initialData!['Nombre del Titular'] ?? '';
      tipoCuentaController.text = widget.initialData!['Tipo de cuenta'] ?? '';
      selectedMoneda = widget.initialData!['Moneda'] ?? listMonedasString.first;
      selectedMetodoPago = widget.initialData!['Método de pago'] ?? 'TRANSFERENCIA';
      bancoIntController.text = widget.initialData!['Banco Internacional'] ?? '';
      clabeIntController.text = widget.initialData!['Clabe Internacional'] ?? '';
      tipoCuentaIntController.text = widget.initialData!['Tipo de cuenta Internacional'] ?? '';
    }
  }

  bool _isNacionalFilled(){
    return bancoController.text.isNotEmpty && clabeController.text.isNotEmpty && tipoCuentaController.text.isNotEmpty;
  }
  bool _isNacionalOne(){
    return bancoController.text.isNotEmpty || clabeController.text.isNotEmpty ||
        tipoCuentaController.text.isNotEmpty;
  }
  bool _isInternacionalFilled(){
    return bancoIntController.text.isNotEmpty && clabeIntController.text.isNotEmpty && tipoCuentaIntController.text.isNotEmpty;
  }
  bool _isInternacionalOne(){
    return bancoIntController.text.isNotEmpty || clabeIntController.text.isNotEmpty ||
        tipoCuentaIntController.text.isNotEmpty;
  }
  String? _clabeNacionalValidator(String? value) {
    if ((!_isNacionalFilled() && !_isInternacionalFilled()) && (value == null || value.isEmpty)) {
      return 'Por favor completa este campo';
    }
    if (value != null && value.isNotEmpty && value.length != 18) {
      return 'Ingrese una clabe valida (${value.length}/18)';
    }
    if(_isNacionalOne() && (value == null || value.isEmpty)){
      return 'Por favor completa este campo';
    }
    return null;
  }
  String? _bancoValidator(String? value) {
    if ((!_isNacionalFilled() && !_isInternacionalFilled()) && (value == null || value.isEmpty)) {
      return 'Por favor completa este campo';
    }
    if(_isNacionalOne() && (value == null || value.isEmpty)){
      return 'Por favor completa este campo';
    }
    return null;
  }
  String? _bancoInternacionalValidator(String? value) {
    if ((!_isNacionalFilled() && !_isInternacionalFilled()) && (value == null || value.isEmpty)) {
      return 'Por favor completa este campo';
    }
    if(_isInternacionalOne() && (value == null || value.isEmpty)){
      return 'Por favor completa este campo';
    }
    return null;
  }
  String? _tipoCuentaValidator(String? value) {
    if (!_isNacionalFilled() && !_isInternacionalFilled() && (value == null || value.isEmpty)) {
      return 'Por favor completa este campo';
    }
    if(_isNacionalOne() && (value == null || value.isEmpty)){
      return 'Por favor completa este campo';
    }
    return null;
  }
  String? _tipoCuentaInternacionalValidator(String? value) {
    if (!_isNacionalFilled() && !_isInternacionalFilled() && (value == null || value.isEmpty)) {
      return 'Por favor completa este campo';
    }
    if(_isInternacionalOne() && (value == null || value.isEmpty)){
      return 'Por favor completa este campo';
    }
    return null;
  }
  String? _clabeInternacionalValidator(String? value) {
    if ((!_isNacionalFilled() && !_isInternacionalFilled()) && (value == null || value.isEmpty)) {
      return 'Por favor completa este campo';
    }
    if (value != null && value.isNotEmpty && value.length != 18) {
      return 'Ingrese una clabe valida (${value.length}/18)';
    }
    if(_isInternacionalOne() && (value == null || value.isEmpty)){
      return 'Por favor completa este campo';
    }
    return null;
  }

  void clearControllers() {
    bancoController.clear();
    clabeController.clear();
    nombreTitularController.clear();
    tipoCuentaController.clear();
    selectedMoneda = listMonedasString.first;
    selectedMetodoPago = "Transferencia";
    bancoIntController.clear();
    clabeIntController.clear();
    tipoCuentaIntController.clear();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final Map<String, String> formData = {
        'Banco': bancoController.text,
        'Clabe': clabeController.text,
        'Nombre del Titular': nombreTitularController.text,
        'Tipo de cuenta': tipoCuentaController.text,
        'Moneda': selectedMoneda,
        'Método de pago': selectedMetodoPago,
        'Banco Internacional': bancoIntController.text,
        'Clabe Internacional': clabeIntController.text,
        'Tipo de cuenta Internacional': tipoCuentaIntController.text,
      };
      widget.onSave(formData);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    bancoController.dispose();
    clabeController.dispose();
    nombreTitularController.dispose();
    tipoCuentaController.dispose();
    bancoIntController.dispose();
    clabeIntController.dispose();
    tipoCuentaIntController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return PressedKeyListener(
      Gkey: GlobalKey(), keyActions: {
      LogicalKeyboardKey.escape: () {Navigator.of(context).pop();},
    },
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,),
        child: SingleChildScrollView(
          child: Container(padding: const EdgeInsets.all(20),
            child: Form(key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min,
                children: [
                  _myContainer2("Datos de Pago"),
                  _rowDivided2(
                    MyTextfieldIcon(toUpperCase: true, labelText: "Banco", textController: bancoController,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      suffixIcon: const Icon(Icons.business), validator: _bancoValidator,
                    ),
                      MyTextfieldIcon(
                        labelText: "Clabe",
                        toUpperCase: true,
                        textController: clabeController,
                        backgroundColor: Theme.of(context).colorScheme.background,
                        suffixIcon: const Icon(Icons.text_format),
                        validator: _clabeNacionalValidator,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(18),
                          UpperCaseTextFormatter(),
                        ],
                      ),
                  ),
                  const SizedBox(height: 10),
                  MyTextfieldIcon(
                    labelText: "Nombre del Titular",
                    toUpperCase: true,
                    textController: nombreTitularController,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    suffixIcon: const Icon(Icons.person),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor completa este campo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _rowDivided2(
                    MyTextfieldIcon(
                      toUpperCase: true,
                      labelText: "Tipo de Cuenta",
                      textController: tipoCuentaController,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      suffixIcon: const Icon(Icons.description),
                      validator:_tipoCuentaValidator,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("Moneda", style: TextStyle(fontSize: 11)),
                        MyDropdown(
                          selectedItemColor: theme.colorScheme.onPrimary,
                          dropdownItems: listMonedasString,
                          suffixIcon: const Icon(IconLibrary.iconMoney),
                          textStyle: const TextStyle(fontSize: 12),
                          selectedItem: selectedMoneda,
                          onPressed: (String? value) {
                            setState(() {
                              selectedMoneda = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _rowDivided2(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("Método de pago", style:
                        TextStyle(fontSize: 11)),
                        MyDropdown(
                          selectedItemColor: theme.colorScheme.onPrimary,
                          dropdownItems: metodosPago,
                          suffixIcon: const Icon(Icons.payment),
                          textStyle: const TextStyle(fontSize: 12),
                          selectedItem: selectedMetodoPago, onPressed: (String? value) {
                            setState(() {
                              selectedMetodoPago = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    MyTextfieldIcon(
                      toUpperCase: true,
                      labelText: "Banco Internacional",
                      textController: bancoIntController,
                      suffixIcon: const Icon(IconLibrary.iconBusiness2),
                      backgroundColor: Theme.of(context).colorScheme.background,
                      validator: _bancoInternacionalValidator,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _rowDivided2(
                    MyTextfieldIcon(
                      labelText: "Clabe Internacional",
                      toUpperCase: true,
                      textController: clabeIntController,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      suffixIcon: const Icon(Icons.text_format),
                      validator: _clabeInternacionalValidator,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(18),
                        UpperCaseTextFormatter(),
                      ],
                    ),
                    MyTextfieldIcon(
                      toUpperCase: true,
                      labelText: "Tipo de cuenta Internacional",
                      textController: tipoCuentaIntController,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      suffixIcon: const Icon(Icons.description),
                      validator: _tipoCuentaInternacionalValidator,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.inversePrimary, primary: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveForm,
                          style: TextButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                          ),
                          child: Text('Guardar', style: (TextStyle(color: theme.colorScheme.onPrimary)),),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rowDivided2(Widget leftWidget, Widget rightWidget) {
    return Row(
      children: [
        Expanded(child: Padding(padding: const EdgeInsets.only(right: 8.0), child: leftWidget,),),
        Expanded(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: rightWidget,),),
      ],
    );
  }

  Widget _myContainer2(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}