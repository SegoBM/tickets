import 'package:flutter/material.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:tickets/controllers/ComprasController/ServiciosProductosController/serviciosProductosController.dart';
import 'package:tickets/models/ComprasModels/ServiciosProductosModels/serviciosProductos.dart';
import 'package:tickets/shared/widgets/Snackbars/cherryToast.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
import '../../actions/handleException.dart';

class AutocompleteServicios extends StatefulWidget {
  final TextEditingController textController;
  final Function(List<ServiciosProductosModels>) onValueChanged;

  const AutocompleteServicios({
    Key? key,
    required this.textController,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  _AutocompleteServiciosState createState() => _AutocompleteServiciosState();
}

class _AutocompleteServiciosState extends State<AutocompleteServicios> {
  final ServiciosProductosController _serviciosProvider = ServiciosProductosController();
  List<ServiciosProductosModels> _listServicios = [];
  List<ServiciosProductosModels> _filteredServicios = [];
  List<ServiciosProductosModels> _selectedServicios = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late Theme theme;

  @override
  void initState() {
    super.initState();
    _getServicios();
  }

  Future<void> _getServicios() async {
    try {
      setState(() {
        _isLoading = true;
      });
      List<ServiciosProductosModels> servicios = await _serviciosProvider.GetServicios([1,2,3]);
      setState(() {
        _listServicios = servicios;
        _filteredServicios = servicios;
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
        _myContainer("BUSCAR SERVICIOS"),
        SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: MyTextfieldIcon(
            backgroundColor: Theme.of(context).colorScheme.background,
            labelText: "Servicios",
            textController: widget.textController,
            suffixIcon: const Icon(Icons.search),
            onChanged: handleAutocompleteValueChangedServicio,
          ),
        ),
        const SizedBox(height: 10),
        _isLoading
            ? _loadingWidget() // Mostrar widget de carga personalizado
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
                  itemCount: _filteredServicios.length,
                  itemBuilder: (context, index) {
                    final servicio = _filteredServicios[index];
                    final isSelected = _selectedServicios.contains(servicio);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedServicios.remove(servicio);
                          } else {
                            _selectedServicios.add(servicio);
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
                                servicio.codigo,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              servicio.concepto,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                              Text(
                                servicio.descripcion == null || servicio.descripcion.trim().isEmpty
                                    ? "Sin Descripción"
                                    : "Descripción: ${servicio.descripcion}",
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
              onPressed: () {
                Navigator.pop(context);
              },
              child:  Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onPrimary,
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
                fontSize: 14, ),
              ),
              onPressed: () {
                if(_selectedServicios == null || _selectedServicios.isEmpty){
                  MyCherryToast.showWarningSnackBar(context, theme, "La acción no fue posible.", "Seleccione un servicio mínimo para continuar");
                }else {
                  widget.onValueChanged(_selectedServicios);
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
        child: Text(
          'Cargando...', // Mensaje de carga
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void handleAutocompleteValueChangedServicio(String value) {
    setState(() {
      _filteredServicios= _listServicios.where((servicio) =>
          servicio.codigo.toLowerCase().contains(value.toLowerCase()) ||
          servicio.concepto.toLowerCase().contains(value.toLowerCase()))
          .toList();
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
