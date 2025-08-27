import 'dart:io';
import 'package:sa_final/database.dart';
import 'package:sa_final/menu.dart';

void main() async {
  print("╔══════════════════════════════════════╗");
  print("║         SISTEMA DE PEDIDOS           ║");
  print("║             Bem-vindo!               ║");
  print("╚══════════════════════════════════════╝");

  // Conectar ao banco de dados
  final conn = await Database.connect();
  if (conn == null) {
    print(
      '❌ Não foi possível conectar ao banco de dados. Verifique as credenciais',
    );
    return;
  }

  try {
    while (true) {
      mostrarMenu();
      String? opcao = stdin.readLineSync();

      switch (opcao) {
        case '1':
          await cadastrarCliente();
          break;
        case '2':
          await listarClientes();
          break;
        case '3':
          await criarPedido();
          break;
        case '4':
          await adicionarItem();
          break;
        case '5':
          await listarPedidos();
          break;
        case '6':
          await finalizarPedido();
          break;
        case '0':
          print("Saindo...");
          return;
        default:
          print("Opcao invalida!");
      }
      print("\nPressione ENTER para continuar...");
      stdin.readLineSync();
    }
  } finally {
    await Database.close();
  }
}
