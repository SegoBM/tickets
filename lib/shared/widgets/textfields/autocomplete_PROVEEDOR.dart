import 'package:flutter/material.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:tickets/controllers/ComprasController/ProveedorController/proveedorController.dart';
import 'package:tickets/models/ComprasModels/ProveedorModels/proveedor.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
import '../../actions/handleException.dart';
import '../Snackbars/cherryToast.dart';

class CustomAutocomplete extends StatefulWidget {
  final TextEditingController textController;
  final Function(List<ProveedorModels>) onValueChanged;

  const CustomAutocomplete({
    Key? key,
    required this.textController,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  _CustomAutocompleteState createState() => _CustomAutocompleteState();
}

class _CustomAutocompleteState extends State<CustomAutocomplete> {
  final ProveedorController _proveedorProvider = ProveedorController();
  List<ProveedorModels> _listProveedores = [];
  List<ProveedorModels> _filteredProveedores = [];
  List<ProveedorModels> _selectedProveedores = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late Theme theme;

  @override
  void initState() {
    super.initState();
    _getProveedores();
  }

  Future<void> _getProveedores() async {
    try {
      setState(() {
        _isLoading = true;
      });
      List<ProveedorModels> proveedores = await _proveedorProvider.getProveedoresActivos();
      setState(() {
        _listProveedores = proveedores;
        _filteredProveedores = proveedores;
      });
    } catch (error) {
      ConnectionExceptionHandler().handleConnectionException(context, error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _myContainer("BUSCAR PROVEEDORES"),
        SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: MyTextfieldIcon(
            backgroundColor: Theme.of(context).colorScheme.background,
            labelText: "Proveedores",
            textController: widget.textController,
            suffixIcon: const Icon(Icons.search),
            onChanged: handleAutocompleteValueChangedProveedor,
          ),
        ),
        const SizedBox(height: 10),
        _isLoading
            ? _loadingWidget()
            : Expanded(
             child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: FadingEdgeScrollView.fromScrollView(
                gradientFractionOnStart: 0.1,
                gradientFractionOnEnd: 0.1,
                child: GridView.builder(
                  controller: _scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                  ),
                  itemCount: _filteredProveedores.length,
                  itemBuilder: (context, index) {
                    final proveedor = _filteredProveedores[index];
                    final isSelected = _selectedProveedores.contains(proveedor);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedProveedores.remove(proveedor);
                          } else {
                            _selectedProveedores.add(proveedor);
                          }
                        });
                      },
                      child: Card(
                        color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(17),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                proveedor.nombre,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                proveedor.rfc == null || proveedor.rfc.trim().isEmpty
                                    ? "Sin RFC"
                                    : "RFC: ${proveedor.rfc}",
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                proveedor.telefono == null || proveedor.telefono.trim().isEmpty
                                    ? "Sin Télefono"
                                    : "Tel: ${proveedor.telefono}",
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancelar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              ElevatedButton(
                  child: Text(
                    'Aceptar',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 14
                    ),
                  ),
                onPressed: (){
                    if(_selectedProveedores == null || _selectedProveedores.isEmpty){
                      MyCherryToast.showWarningSnackBar(context, theme as ThemeData, "La acción no fue posible.", "Seleccione un proveedor mínimo para continuar");
                    }else {
                      widget.onValueChanged(_selectedProveedores);
                      print(_selectedProveedores);
                      Navigator.pop(context);
                    }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  )
                ),
              ),
            ],
          ),
        ],
      );
    }

  Widget _loadingWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child:  Column(
          children: [
            CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary,),
            const SizedBox(height: 15),
            const Text(
              '  Cargando...', textAlign: TextAlign.center, // Mensaje de carga
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleAutocompleteValueChangedProveedor(String value) {
    setState(() {
      _filteredProveedores = _listProveedores.where((proveedor) {
        final lowerValue = value.toLowerCase();
        return proveedor.nombre.toLowerCase().contains(lowerValue) ||
            proveedor.rfc.toLowerCase().contains(lowerValue);
      }).toList();
    });
  }

  Widget _myContainer(String title) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(
            thickness: 1,
            endIndent: 100,
            indent: 100,
          ),
        ],
      ),
    );
  }
}
