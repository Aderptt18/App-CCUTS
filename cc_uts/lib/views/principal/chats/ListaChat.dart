import 'package:flutter/material.dart';


class ListaChat extends StatelessWidget {
  const ListaChat({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [
          _buildChatItem(
            'Cambio climático, Juan Perez',
            'Nuevos mensajes',
            true,
          ),
          const Divider(height: 1),
          _buildChatItem(
            'Cuidado de niños, Esteban herran',
            'leido',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(String title, String subtitle, bool hasNewMessages) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: hasNewMessages ? Colors.green : Colors.grey,
        ),
      ),
      onTap: () {
        // Implementar navegación al chat
      },
    );
  }
  
}