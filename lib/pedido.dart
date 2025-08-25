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
    for (int i = 0; i < itens.length; i++) {
      itensStr += "\n  ${i + 1}. ${itens[i].toString()}";
    }

    return "PEDIDO ID: $id\nCliente: ${cliente.nome}\nData: ${data.day}/${data.month}/${data.year}\nStatus: $status\nItens:$itensStr\nTOTAL: R\$ ${calcularTotal().toStringAsFixed(2)}";
  }
}
