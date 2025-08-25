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
    return '''
╔══════════════════════════════════════╗
║                ITEM                  ║
╠══════════════════════════════════════╣
║ ID: $id
║ Nome: $nome
║ Preço Unitário: R\$ ${preco.toStringAsFixed(2)}
║ Quantidade: $quantidade
║ Subtotal: R\$ ${calcularSubtotal().toStringAsFixed(2)}
╚══════════════════════════════════════╝''';
  }
}
