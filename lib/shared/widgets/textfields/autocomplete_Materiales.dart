import 'package:flutter/material.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:tickets/controllers/ComprasController/MaterialesControllers/materialesController.dart';
import 'package:tickets/models/ComprasModels/MaterialesModels/materiales.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
import '../../actions/handleException.dart';
import '../Snackbars/cherryToast.dart';

class AutocompleteMateriales extends StatefulWidget {
  final TextEditingController textController;
  final Function(List<MaterialesModels>) onValueChanged;

  const AutocompleteMateriales({
    Key? key,
    required this.textController,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  _AutocompleteMaterialesState createState() => _AutocompleteMaterialesState();
}

class _AutocompleteMaterialesState extends State<AutocompleteMateriales> {
  final MaterialesController _materialesProvider = MaterialesController();
  List<MaterialesModels> _listMateriales = [];
  List<MaterialesModels> _filteredMateriales = [];
  List<MaterialesModels> _selectedMateriales = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late Theme theme;

  @override
  void initState() {
    super.initState();
    _getMateriales();
  }

  Future<void> _getMateriales() async {
    try {
      setState(() {
        _isLoading = true;
      });
      List<MaterialesModels> materiales = await _materialesProvider.getMateriales([1,2,3]);
      setState(() {
        _listMateriales = materiales;
        _filteredMateriales = materiales;
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
        _myContainer("BUSCAR MATERIALES"),
        SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: MyTextfieldIcon(
            backgroundColor: Theme.of(context).colorScheme.background,
            labelText: "Materiales",
            textController: widget.textController,
            suffixIcon: const Icon(Icons.search),
            onChanged: handleAutocompleteValueChangedMaterial,
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
                itemCount: _filteredMateriales.length,
                itemBuilder: (context, index) {
                  final material = _filteredMateriales[index];
                  final isSelected = _selectedMateriales.contains(material);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedMateriales.remove(material);
                        } else {
                          _selectedMateriales.add(material);
                        }
                      });
                    },
                    child: Card(
                      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              material.codigoProducto,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nombre: ${material.familiaNombre} ${material.subFamiliaNombre} ${material.categoria}',
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              material.descripcion == null || material.descripcion.trim().isEmpty
                                  ? "Sin descripción"
                                  : "Descripción: ${material.descripcion}",
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
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
                  "Cancelar",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                elevation: 5,
                padding: const EdgeInsets.symmetric(horizontal:20, vertical: 10),
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
                    fontSize: 14, ),
                  ),
                  onPressed: (){
                      if(_selectedMateriales == null || _selectedMateriales.isEmpty){
                        MyCherryToast.showWarningSnackBar(context, theme, "La acción no fue posible", "Seleccione un material mínimo para continuar");
                      }else{
                        widget.onValueChanged(_selectedMateriales);
                        Navigator.pop(context);
                      }
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                elevation: 5,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
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
        child: const Text(
          'Cargando...', // Mensaje de carga
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void handleAutocompleteValueChangedMaterial(String value) {
    setState(() {
      _filteredMateriales = _listMateriales.where((material) =>
      material.codigoProducto.toLowerCase().contains(value.toLowerCase()) ||
          material.familiaNombre!.toLowerCase().contains(value.toLowerCase()) ||
          material.subFamiliaNombre!.toLowerCase().contains(value.toLowerCase()) ||
          material.categoria.toLowerCase().contains(value.toLowerCase())
      ).toList();
    }); }

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
