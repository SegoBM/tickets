import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
class CustomDropdownButton extends StatelessWidget {
  final ThemeData? theme;
  final BuildContext context;
  final List<String> items;
  final ValueNotifier<List<String>>? selectedItemsNotifier;
  final List<String> selectedItems;
  final Function setState;
  final Color? color;
  final Color? backgroundColor;
  final Color? textColor;
  Function onTap;
  String text;

  CustomDropdownButton({
    this.textColor,
    this.color,
    this.backgroundColor,
    this.theme,
    required this.context,
    required this.items,
    required this.selectedItems,
    required this.setState,
    required this.onTap,
    this.text = 'Selecciona alguna(s) opción(es)',
    this.selectedItemsNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        dropdownStyleData: DropdownStyleData(decoration: BoxDecoration(color: backgroundColor)),
        iconStyleData: IconStyleData(iconEnabledColor: color),isExpanded: true,
        hint: Text(text,
          style: TextStyle(fontSize: 13,
            color: color != null ? color : Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        items: [
          ...items.map((item) {
            return DropdownMenuItem(value: item, enabled: false,
              child: StatefulBuilder(
                builder: (context, menuSetState) {
                  final isSelected = selectedItems.contains(item);
                  return InkWell(
                    onTap: () {
                      isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                      //This rebuilds the StatefulWidget to update the button's text
                      setState(() {});
                      onTap();
                      //This rebuilds the dropdownMenu Widget to update the check mark
                      menuSetState(() {});
                    },
                    child: Container(
                      color: backgroundColor != null ? backgroundColor : Theme.of(context).colorScheme.background, // Si backgroundColor es null, se usará Colors.transparent
                      height: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          if (isSelected)
                             Icon(Icons.check_box_outlined,color:textColor != null ? textColor : Theme.of(context).colorScheme.onPrimary)
                          else
                             Icon(Icons.check_box_outline_blank,color:textColor != null ? textColor : Theme.of(context).colorScheme.onPrimary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                color: textColor != null ? textColor : Theme.of(context).colorScheme.onPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
           DropdownMenuItem(
            value: 'Quitar todos los filtros',
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                color: backgroundColor != null ? backgroundColor : Theme.of(context).colorScheme.background, // Cambia esto al color que desees
                child: Row(
                  children: [
                    Icon(Icons.clear_all,
                    color: textColor != null? textColor  : Theme.of(context).colorScheme.onPrimary,), // Icono personalizado
                    SizedBox(width: 8), // Espacio entre el icono y el texto
                    Text(
                      'Quitar todos los filtros',
                      style: TextStyle(fontSize: 14,
                        color: textColor != null ? textColor : Theme.of(context).colorScheme.onPrimary, // Cambia esto al color que desees
                        fontWeight: FontWeight.bold, // Estilo de fuente personalizado
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
        value: selectedItems.isEmpty ? null : selectedItems.last,
        onChanged: (value) {
          if (value == 'Quitar todos los filtros') {
            selectedItems.clear();
            setState(() {});
            onTap();
          }
        },
        selectedItemBuilder: (context) {
          return items.map(
                (item) {
              return Container(
                alignment: AlignmentDirectional.center,
                child: Text(
                  selectedItems.join(', '),
                  style:  TextStyle(
                    fontSize: 14,
                    color:textColor != null ? textColor : Theme.of(context).colorScheme.onPrimary,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              );
            },
          ).toList();
        },
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.only(left: 16, right: 8),
          height: 40, width: 140,
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40, padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}