import 'package:cc_uts/views/perfil/Perfil.dart';
import 'package:cc_uts/views/principal/Publicacion/CrearPublicacion.dart';
import 'package:cc_uts/views/principal/Publicacion/Publicaciones.dart';
import 'package:cc_uts/views/principal/Repositorio.dart';
import 'package:cc_uts/views/principal/chats/ListaChat.dart';
import 'package:flutter/material.dart';

class Pantallas extends StatefulWidget {
  const Pantallas({super.key});

  @override
  State<Pantallas> createState() => _PantallasState();
}

class _PantallasState extends State<Pantallas> {
  int _paginaActual = 0;
  final PageController _pageController = PageController();

  // Lista de páginas correspondientes a cada ítem del BottomNavigationBar
  final List<Widget> _paginas = [
    Publicaciones(),
    SubirDocumentoScreen(),
    CrearPublicacion(),
    ListaChat(),
    Perfil()
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _paginaActual = index;
          });
        },
        children: _paginas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _paginaActual = index;
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        currentIndex: _paginaActual,
        type: BottomNavigationBarType.fixed, // Evita la animación del color
        backgroundColor: Colors.green, // Fondo verde
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
                color: _paginaActual == 0 ? Colors.green[800] : Colors.black),
            label: 'Publicaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book,
                color: _paginaActual == 1 ? Colors.green[800] : Colors.black),
            label: 'Repositorio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add,
                color: _paginaActual == 2 ? Colors.green[800] : Colors.black),
            label: 'Crear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat,
                color: _paginaActual == 3 ? Colors.green[800] : Colors.black),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _paginaActual == 4 ? Colors.green[800] : Colors.black),
            label: 'Perfil',
          ),
        ],
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.green[1000], // Ícono seleccionado más oscuro
      ),
    );
  }
}