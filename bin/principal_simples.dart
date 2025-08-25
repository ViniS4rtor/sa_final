import 'dart:io';
import 'package:sa_final/cliente.dart';
import 'package:sa_final/item.dart';
import 'package:sa_final/pedido.dart';

List<Cliente> clientes = [];
List<Pedido> pedidos = [];
int proximoIdCliente = 1;
int proximoIdPedido = 1;
int proximoIdItem = 1;

void main() {
  print("=== SISTEMA DE PEDIDOS ===");

  while (true) {
    mostrarMenu();
    String? opcao = stdin.readLineSync();

    switch (opcao) {
      case '1':
        cadastrarCliente();
        break;
      case '2':
        listarClientes();
        break;
      case '3':
        criarPedido();
        break;
      case '4':
        adicionarItem();
        break;
      case '5':
        listarPedidos();
        break;
      case '6':
        finalizarPedido();
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
}

void mostrarMenu() {
  print("\n--- MENU ---");
  print("1. Cadastrar Cliente");
  print("2. Listar Clientes");
  print("3. Criar Pedido");
  print("4. Adicionar Item ao Pedido");
  print("5. Listar Pedidos");
  print("6. Finalizar Pedido");
  print("0. Sair");
  print("Escolha: ");
}

void cadastrarCliente() {
  print("\n--- Cadastrar Cliente ---");

  print("Nome: ");
  String? nome = stdin.readLineSync() ?? "";

  print("Email: ");
  String? email = stdin.readLineSync() ?? "";

  print("Telefone: ");
  String? telefone = stdin.readLineSync() ?? "";

  print("Endereco: ");
  String? endereco = stdin.readLineSync() ?? "";

  Cliente cliente = Cliente(
    proximoIdCliente++,
    nome,
    email,
    telefone,
    endereco,
  );
  clientes.add(cliente);

  print("Cliente cadastrado com sucesso!");
  print(cliente.toString());
}

void listarClientes() {
  print("\n--- Clientes ---");

  if (clientes.isEmpty) {
    print("Nenhum cliente cadastrado.");
    return;
  }

  for (Cliente cliente in clientes) {
    print(cliente.toString());
    print("---");
  }
}

void criarPedido() {
  print("\n--- Criar Pedido ---");

  if (clientes.isEmpty) {
    print("Nenhum cliente cadastrado! Cadastre um cliente primeiro.");
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
    Cliente? cliente;
    for (Cliente c in clientes) {
      if (c.id == clienteId) {
        cliente = c;
        break;
      }
    }

    if (cliente != null) {
      Pedido pedido = Pedido(proximoIdPedido++, cliente, DateTime.now());
      pedidos.add(pedido);

      print("Pedido criado com sucesso!");
      print(pedido.toString());
    } else {
      print("Cliente nao encontrado!");
    }
  } else {
    print("ID invalido!");
  }
}

void adicionarItem() {
  print("\n--- Adicionar Item ---");

  if (pedidos.isEmpty) {
    print("Nenhum pedido criado!");
    return;
  }

  // Mostrar pedidos pendentes
  List<Pedido> pedidosPendentes = [];
  for (Pedido p in pedidos) {
    if (p.status == "Pendente") {
      pedidosPendentes.add(p);
    }
  }

  if (pedidosPendentes.isEmpty) {
    print("Nenhum pedido pendente!");
    return;
  }

  print("Pedidos pendentes:");
  for (Pedido pedido in pedidosPendentes) {
    print("${pedido.id} - Cliente: ${pedido.cliente.nome}");
  }

  print("ID do pedido: ");
  String? idStr = stdin.readLineSync();
  int? pedidoId = int.tryParse(idStr ?? "");

  if (pedidoId != null) {
    Pedido? pedido;
    for (Pedido p in pedidosPendentes) {
      if (p.id == pedidoId) {
        pedido = p;
        break;
      }
    }

    if (pedido != null) {
      print("Nome do item: ");
      String? nome = stdin.readLineSync() ?? "";

      print("Preco: ");
      String? precoStr = stdin.readLineSync();
      double? preco = double.tryParse(precoStr ?? "");

      print("Quantidade: ");
      String? qtdStr = stdin.readLineSync();
      int? quantidade = int.tryParse(qtdStr ?? "");

      if (preco != null && quantidade != null) {
        Item item = Item(proximoIdItem++, nome, preco, quantidade);
        pedido.adicionarItem(item);

        print("Item adicionado com sucesso!");
        print(item.toString());
      } else {
        print("Dados invalidos!");
      }
    } else {
      print("Pedido nao encontrado!");
    }
  } else {
    print("ID invalido!");
  }
}

void listarPedidos() {
  print("\n--- Pedidos ---");

  if (pedidos.isEmpty) {
    print("Nenhum pedido criado.");
    return;
  }

  for (Pedido pedido in pedidos) {
    print(pedido.toString());
    print("---");
  }
}

void finalizarPedido() {
  print("\n--- Finalizar Pedido ---");

  List<Pedido> pedidosPendentes = [];
  for (Pedido p in pedidos) {
    if (p.status == "Pendente") {
      pedidosPendentes.add(p);
    }
  }

  if (pedidosPendentes.isEmpty) {
    print("Nenhum pedido pendente!");
    return;
  }

  print("Pedidos pendentes:");
  for (Pedido pedido in pedidosPendentes) {
    print(
      "${pedido.id} - Cliente: ${pedido.cliente.nome} - Total: R\$ ${pedido.calcularTotal().toStringAsFixed(2)}",
    );
  }

  print("ID do pedido: ");
  String? idStr = stdin.readLineSync();
  int? pedidoId = int.tryParse(idStr ?? "");

  if (pedidoId != null) {
    Pedido? pedido;
    for (Pedido p in pedidosPendentes) {
      if (p.id == pedidoId) {
        pedido = p;
        break;
      }
    }

    if (pedido != null) {
      if (pedido.itens.isNotEmpty) {
        pedido.finalizar();
        print("Pedido finalizado com sucesso!");
        print(pedido.toString());
      } else {
        print("Nao e possivel finalizar um pedido sem itens!");
      }
    } else {
      print("Pedido nao encontrado!");
    }
  } else {
    print("ID invalido!");
  }
}
