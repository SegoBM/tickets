import 'package:tickets/shared/widgets/bar/sidebar_item.dart';

class SidebarGroupItem {
  SidebarGroupItem({
    required this.text,
    required this.items,
  });

  final String text;
  List<SidebarItem> items;
}