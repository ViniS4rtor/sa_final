class Cliente {
  int id;
  String nome;
  String email;
  String telefone;
  String endereco;

  Cliente(this.id, this.nome, this.email, this.telefone, this.endereco);

  @override
  String toString() {
    return '''
╔══════════════════════════════════════╗
║               CLIENTE                ║
╠══════════════════════════════════════╣
║ ID: $id
║ Nome: $nome
║ Email: $email
║ Telefone: $telefone
║ Endereço: $endereco
╚══════════════════════════════════════╝''';
  }
}
