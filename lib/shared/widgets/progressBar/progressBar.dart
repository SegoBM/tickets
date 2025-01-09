import 'dart:ui';
import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progreso;
  final Function(String) onTap;
  final double width;

  const ProgressBar({required this.progreso, required this.onTap, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // Ensure the ProgressBar takes the full width of its parent
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (progreso < 0.5)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onTap('Abierto'),
                    child: Icon(Icons.circle, color: progreso >= 0.25 ? Colors.green : Colors.grey),
                  ),
                )
              else
                Icon(Icons.circle, color: progreso >= 0.25 ? Colors.green : Colors.grey),
              Expanded(
                child: Divider(
                  color: progreso >= 0.5 ? Colors.green : Colors.grey,
                  thickness: 2,
                ),
              ),
              if (progreso < 1.0)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onTap('En Progreso'),
                    child: Icon(Icons.circle, color: progreso >= 0.5 ? Colors.green : Colors.grey),
                  ),
                )
              else
                Icon(Icons.circle, color: progreso >= 0.5 ? Colors.green : Colors.grey),
              Expanded(
                child: Divider(
                  color: progreso >= 0.75 ? Colors.green : Colors.grey,
                  thickness: 2,
                ),
              ),
              if (progreso < 1.0)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onTap('Resuelto'),
                    child: Icon(Icons.circle, color: progreso >= 0.75 ? Colors.green : Colors.grey),
                  ),
                )
              else
                Icon(Icons.circle, color: progreso >= 0.75 ? Colors.green : Colors.grey),
              Expanded(
                child: Divider(
                  color: progreso >= 1.0 ? Colors.green : Colors.grey,
                  thickness: 2,
                ),
              ),
              if (progreso < 1.0)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onTap('Cerrado'),
                    child: Icon(Icons.circle, color: progreso >= 1.0 ? Colors.green : Colors.grey),
                  ),
                )
              else
                Icon(Icons.check_circle, color: progreso >= 1.0 ? Colors.green : Colors.grey),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Abierto', style: TextStyle(fontSize: 8.5, color: Colors.white)),
              Text('En Progreso', style: TextStyle(fontSize: 8.5, color: Colors.white)),
              Text('Resuelto', style: TextStyle(fontSize: 8.5, color: Colors.white)),
              Text('Cerrado', style: TextStyle(fontSize: 8.5, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}