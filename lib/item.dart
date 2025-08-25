class Item {
  int id;
  String nome;
  double preco;
  int quantidade;

  Item(this.id, this.nome, this.preco, this.quantidade);

  double calcularSubtotal() {
    return preco * quantidade;
  }

  @override
  String toString() {
    return "ID: $id | Nome: $nome | Preco: R\$ ${preco.toStringAsFixed(2)} | Qtd: $quantidade | Subtotal: R\$ ${calcularSubtotal().toStringAsFixed(2)}";
  }
}
