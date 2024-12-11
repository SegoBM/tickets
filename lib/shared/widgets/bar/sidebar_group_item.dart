import 'package:tickets/shared/widgets/bar/sidebar_item.dart';

class SidebarGroupItem {
  SidebarGroupItem({
    required this.text,
    required this.items,
    this.isCollapsed = true,
  });

  final String text;
  bool isCollapsed;
  List<SidebarItem> items;
}