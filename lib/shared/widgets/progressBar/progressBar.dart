import 'dart:ui';
import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progreso;
  final Function(String) onTap;

  const ProgressBar({required this.progreso, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // Ensure the ProgressBar takes the full width of its parent
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onTap('Abierto'),
                  child: Icon(Icons.circle, color: progreso >= 0.25 ? Colors.green : Colors.grey),
                ),
              ),
              Expanded(
                child: Divider(
                  color: progreso >= 0.5 ? Colors.green : Colors.grey,
                  thickness: 2,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onTap('En Progreso'),
                  child: Icon(Icons.circle, color: progreso >= 0.5 ? Colors.green : Colors.grey),
                ),
              ),
              Expanded(
                child: Divider(
                  color: progreso >= 0.75 ? Colors.green : Colors.grey,
                  thickness: 2,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onTap('Resuelto'),
                  child: Icon(Icons.circle, color: progreso >= 0.75 ? Colors.green : Colors.grey),
                ),
              ),
              Expanded(
                child: Divider(
                  color: progreso >= 1.0 ? Colors.green : Colors.grey,
                  thickness: 2,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onTap('Cerrado'),
                  child: Icon(Icons.circle, color: progreso >= 1.0 ? Colors.green : Colors.grey),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Abierto', style: TextStyle(fontSize: 9, color: Colors.white)),
              Text('En Progreso', style: TextStyle(fontSize: 9, color: Colors.white)),
              Text('Resuelto', style: TextStyle(fontSize: 9, color: Colors.white)),
              Text('Cerrado', style: TextStyle(fontSize: 9, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}