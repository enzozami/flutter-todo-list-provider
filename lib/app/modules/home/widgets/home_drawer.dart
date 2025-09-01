import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_provider/app/core/auth/auth_provider.dart';
import 'package:todo_list_provider/app/core/ui/messages.dart';
import 'package:todo_list_provider/app/core/ui/theme_extensions.dart';
import 'package:todo_list_provider/app/services/user/user_service.dart';

class HomeDrawer extends StatelessWidget {
  final nameVN = ValueNotifier<String>('');
  HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: context.primaryColor.withAlpha(70),
              ),
              child: Row(
                children: [
                  Selector<AuthProvider, String>(
                    selector: (context, authProvider) {
                      return authProvider.user?.photoURL ?? 'https://i.sstatic.net/Hq8za.jpg';
                    },
                    builder: (_, value, __) {
                      return CircleAvatar(
                        backgroundImage: NetworkImage(value),
                        radius: 30,
                      );
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Selector<AuthProvider, String>(
                        selector: (context, authProvider) {
                          return authProvider.user?.displayName ?? 'Não informado';
                        },
                        builder: (_, value, __) {
                          return Text(
                            value,
                            style: context.textTheme.titleSmall,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: const Text('Alterar Nome'),
                        content: TextField(
                          onChanged: (value) => nameVN.value = value,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                final nameValue = nameVN.value;
                                if (nameVN.value.isEmpty) {
                                  Messages.of(context).showError('Nome Obrigatório');
                                } else {
                                  context.read<UserService>().updateDisplayName(nameValue);
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Alterar'))
                        ],
                      );
                    });
              },
              title: const Text('Alterar Nome'),
            ),
            ListTile(
              onTap: () => context.read<AuthProvider>().logout(),
              title: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
