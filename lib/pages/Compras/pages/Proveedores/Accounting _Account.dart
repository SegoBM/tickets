import 'package:flutter/material.dart';
import 'package:tickets/pages/Compras/pages/Proveedores/tree_view.dart';
import '../../../../shared/utils/icon_library.dart';
import '../../../../shared/widgets/textfields/my_textfield_icon.dart';

class AccountingAccount extends StatefulWidget {
  const AccountingAccount({super.key});

  @override
  _AccountingAccountState createState() => _AccountingAccountState();
}

class _AccountingAccountState extends State<AccountingAccount> {
  final TextEditingController _accountController = TextEditingController();
  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Row(
      children: [
        const Spacer(),
        SizedBox(
          width: 500,
          child: MyTextfieldIcon(
            toUpperCase: true,
            backgroundColor: theme.colorScheme.background,
            labelText: 'Cuenta Contable',
            textController: _accountController,
            suffixIcon: const Icon(IconLibrary.iconNumber),
          ),
        ),
        IconButton(
          onPressed: _showAccountDialog,
          icon: const Icon(IconLibrary.arrowDawn),
          color: theme.colorScheme.onPrimary,
        ),
        const Spacer(),
      ],
    );
  }

  void _showAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Capturar Información'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ThreeLevelTreeView(
              data: [
                TreeNodeData(title: 'Root 1', icon: Icons.folder,)..addChildren([
                  TreeNodeData(title: 'Node 1.1', icon: Icons.folder,)..addChildren([
                    TreeNodeData(title: 'Node 1.1.1', icon: Icons.description),
                  ]),
                ]),
                TreeNodeData(title: 'Root 2', icon: Icons.folder,)..addChildren([
                  TreeNodeData(title: 'Node 2.1', icon: Icons.folder,)..addChildren([
                    TreeNodeData(title: 'Node 2.1.1', icon: Icons.description),
                  ]),
                ]),
                TreeNodeData(title: 'Root 3', icon: Icons.folder,)..addChildren([
                  TreeNodeData(title: 'Node 3.1', icon: Icons.folder,)..addChildren([
                    TreeNodeData(title: 'Node 3.1.1', icon: Icons.description),
                  ]),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
