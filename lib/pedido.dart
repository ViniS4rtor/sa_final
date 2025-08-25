import 'cliente.dart';
import 'item.dart';

class Pedido {
  int id;
  Cliente cliente;
  List<Item> itens = [];
  DateTime data;
  String status = "Pendente";

  Pedido(this.id, this.cliente, this.data);

  void adicionarItem(Item item) {
    itens.add(item);
  }

  void removerItem(int itemId) {
    itens.removeWhere((item) => item.id == itemId);
  }

  double calcularTotal() {
    double total = 0;
    for (Item item in itens) {
      total += item.calcularSubtotal();
    }
    return total;
  }

  void finalizar() {
    status = "Finalizado";
  }

  @override
  String toString() {
    String itensStr = "";
    if (itens.isNotEmpty) {
      itensStr = "\n║ ITENS:\n";
      for (int i = 0; i < itens.length; i++) {
        itensStr +=
            "║ ${i + 1}. ${itens[i].nome} - Qtd: ${itens[i].quantidade} - R\$ ${itens[i].calcularSubtotal().toStringAsFixed(2)}\n";
      }
    } else {
      itensStr = "\n║ ITENS: Nenhum item adicionado\n";
    }

    return '''
╔══════════════════════════════════════╗
║               PEDIDO                 ║
╠══════════════════════════════════════╣
║ ID: $id
║ Cliente: ${cliente.nome}
║ Data: ${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}
║ Status: $status$itensStr║ 
║ TOTAL: R\$ ${calcularTotal().toStringAsFixed(2)}
╚══════════════════════════════════════╝''';
  }
}
