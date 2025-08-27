import 'dart:io';
import 'package:sa_final/cliente.dart';
import 'package:sa_final/item.dart';
import 'package:sa_final/database.dart';

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

void mostrarMenu() {
  print("\n${"=" * 50}");
  print("               MENU PRINCIPAL");
  print("=" * 50);
  print("1. 👤 Cadastrar Cliente");
  print("2. 📋 Listar Clientes");
  print("3. 🛒 Criar Pedido");
  print("4. ➕ Adicionar Item ao Pedido");
  print("5. 📦 Listar Pedidos");
  print("6. ✅ Finalizar Pedido");
  print("0. 🚪 Sair");
  print("=" * 50);
  print("Escolha uma opção: ");
}

Future<void> cadastrarCliente() async {
  print("\n--- 👤 CADASTRO DE CLIENTE ---");

  print("Nome: ");
  String? nome = stdin.readLineSync() ?? "";

  print("Email: ");
  String? email = stdin.readLineSync() ?? "";

  print("Telefone: ");
  String? telefone = stdin.readLineSync() ?? "";

  print("Endereco: ");
  String? endereco = stdin.readLineSync() ?? "";

  Cliente cliente = Cliente(0, nome, email, telefone, endereco);

  int? id = await Database.inserirCliente(cliente);
  if (id != null) {
    cliente.id = id;
    print("✅ Cliente cadastrado com sucesso!");
    print(cliente.toString());
  } else {
    print("❌ Erro ao cadastrar cliente!");
  }
}

Future<void> listarClientes() async {
  print("\n--- 📋 LISTA DE CLIENTES ---");

  List<Cliente> clientes = await Database.listarClientes();

  if (clientes.isEmpty) {
    print("❌ Nenhum cliente cadastrado.");
    return;
  }

  for (Cliente cliente in clientes) {
    print(cliente.toString());
    print("---");
  }
}

Future<void> criarPedido() async {
  print("\n--- 🛒 CRIAR PEDIDO ---");

  List<Cliente> clientes = await Database.listarClientes();

  if (clientes.isEmpty) {
    print("❌ Nenhum cliente cadastrado! Cadastre um cliente primeiro.");
    return;
  }

  print("Clientes disponíveis:");
  for (Cliente cliente in clientes) {
    print("${cliente.id} - ${cliente.nome}");
  }

  print("ID do cliente: ");
  String? idStr = stdin.readLineSync();
  int? clienteId = int.tryParse(idStr ?? "");

  if (clienteId != null) {
    Cliente? cliente = await Database.buscarClientePorId(clienteId);

    if (cliente != null) {
      int? pedidoId = await Database.inserirPedido(clienteId);
      if (pedidoId != null) {
        print("✅ Pedido criado com sucesso!");
        print("📋 ID do Pedido: $pedidoId");
        print("👤 Cliente: ${cliente.nome}");
      } else {
        print("❌ Erro ao criar pedido!");
      }
    } else {
      print("❌ Cliente não encontrado!");
    }
  } else {
    print("❌ ID inválido!");
  }
}

Future<void> adicionarItem() async {
  print("\n--- ➕ ADICIONAR ITEM ---");

  // Mostrar pedidos pendentes
  List<Map<String, dynamic>> pedidos = await Database.listarPedidos();
  List<Map<String, dynamic>> pedidosPendentes = pedidos
      .where((p) => p['status'] == 'Pendente')
      .toList();

  if (pedidosPendentes.isEmpty) {
    print("❌ Nenhum pedido pendente!");
    return;
  }

  print("Pedidos pendentes:");
  for (var pedido in pedidosPendentes) {
    print("${pedido['id']} - Cliente: ${pedido['cliente_nome']}");
  }

  print("ID do pedido: ");
  String? idStr = stdin.readLineSync();
  int? pedidoId = int.tryParse(idStr ?? "");

  if (pedidoId == null) {
    print("❌ ID inválido!");
    return;
  }

  // Verificar se o pedido existe e está pendente
  var pedidoSelecionado = pedidosPendentes
      .where((p) => p['id'] == pedidoId)
      .firstOrNull;
  if (pedidoSelecionado == null) {
    print("❌ Pedido não encontrado!");
    return;
  }

  // Mostrar itens disponíveis
  List<Item> itens = await Database.listarItens();
  if (itens.isEmpty) {
    print("❌ Nenhum item disponível no estoque!");
    return;
  }

  print("\nItens disponíveis:");
  for (Item item in itens) {
    print(
      "${item.id} - ${item.nome} - R\$ ${item.preco.toStringAsFixed(2)} (Estoque: ${item.quantidade})",
    );
  }

  print("ID do item: ");
  String? itemIdStr = stdin.readLineSync();
  int? itemId = int.tryParse(itemIdStr ?? "");

  if (itemId == null) {
    print("❌ ID do item inválido!");
    return;
  }

  Item? itemSelecionado = await Database.buscarItemPorId(itemId);
  if (itemSelecionado == null) {
    print("❌ Item não encontrado!");
    return;
  }

  print("Quantidade: ");
  String? qtdStr = stdin.readLineSync();
  int? quantidade = int.tryParse(qtdStr ?? "");

  if (quantidade == null || quantidade <= 0) {
    print("❌ Quantidade inválida!");
    return;
  }

  if (quantidade > itemSelecionado.quantidade) {
    print(
      "❌ Quantidade solicitada maior que o estoque disponível (${itemSelecionado.quantidade})!",
    );
    return;
  }

  bool sucesso = await Database.adicionarItemPedido(
    pedidoId,
    itemId,
    quantidade,
    itemSelecionado.preco,
  );
  if (sucesso) {
    print("✅ Item adicionado com sucesso!");
    print(
      "📦 ${itemSelecionado.nome} - Qtd: $quantidade - Total: R\$ ${(quantidade * itemSelecionado.preco).toStringAsFixed(2)}",
    );
  } else {
    print("❌ Erro ao adicionar item ao pedido!");
  }
}

Future<void> listarPedidos() async {
  print("\n--- 📦 LISTA DE PEDIDOS ---");

  List<Map<String, dynamic>> pedidos = await Database.listarPedidos();

  if (pedidos.isEmpty) {
    print("❌ Nenhum pedido criado.");
    return;
  }

  for (var pedido in pedidos) {
    print("╔══════════════════════════════════════╗");
    print("║               PEDIDO                 ║");
    print("╠══════════════════════════════════════╣");
    print("║ ID: ${pedido['id']}");
    print("║ Cliente: ${pedido['cliente_nome']}");
    print("║ Data: ${pedido['data_pedido']}");
    print("║ Status: ${pedido['status']}");

    // Buscar itens do pedido
    List<Map<String, dynamic>> itens = await Database.listarItensPedido(
      pedido['id'],
    );
    if (itens.isNotEmpty) {
      print("║ ITENS:");
      for (int i = 0; i < itens.length; i++) {
        var item = itens[i];
        print(
          "║ ${i + 1}. ${item['item_nome']} - Qtd: ${item['quantidade']} - R\$ ${item['subtotal'].toStringAsFixed(2)}",
        );
      }
    } else {
      print("║ ITENS: Nenhum item adicionado");
    }

    print("║ TOTAL: R\$ ${pedido['total'].toStringAsFixed(2)}");
    print("╚══════════════════════════════════════╝");
    print("---");
  }
}

Future<void> finalizarPedido() async {
  print("\n--- 🏁 FINALIZAR PEDIDO ---");

  List<Map<String, dynamic>> pedidos = await Database.listarPedidos();
  List<Map<String, dynamic>> pedidosPendentes = pedidos
      .where((p) => p['status'] == 'Pendente')
      .toList();

  if (pedidosPendentes.isEmpty) {
    print("❌ Nenhum pedido pendente!");
    return;
  }

  print("📋 Pedidos pendentes:");
  for (var pedido in pedidosPendentes) {
    print(
      "${pedido['id']} - Cliente: ${pedido['cliente_nome']} - Total: R\$ ${pedido['total'].toStringAsFixed(2)}",
    );
  }

  print("💯 Digite o ID do pedido: ");
  String? idStr = stdin.readLineSync();
  int? pedidoId = int.tryParse(idStr ?? "");

  if (pedidoId != null) {
    var pedidoSelecionado = pedidosPendentes
        .where((p) => p['id'] == pedidoId)
        .firstOrNull;

    if (pedidoSelecionado != null) {
      // Verificar se o pedido tem itens
      List<Map<String, dynamic>> itens = await Database.listarItensPedido(
        pedidoId,
      );

      if (itens.isNotEmpty) {
        bool sucesso = await Database.finalizarPedido(pedidoId);
        if (sucesso) {
          print("✅ Pedido finalizado com sucesso!");
          print(
            "📋 Pedido ${pedidoSelecionado['id']} - Cliente: ${pedidoSelecionado['cliente_nome']}",
          );
          print(
            "💰 Total: R\$ ${pedidoSelecionado['total'].toStringAsFixed(2)}",
          );
        } else {
          print("❌ Erro ao finalizar pedido!");
        }
      } else {
        print("❌ Não é possível finalizar um pedido sem itens!");
      }
    } else {
      print("❌ Pedido não encontrado!");
    }
  } else {
    print("❌ ID inválido!");
  }
}
