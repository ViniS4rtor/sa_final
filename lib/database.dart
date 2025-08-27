import 'package:mysql_client/mysql_client.dart';
import 'cliente.dart';
import 'item.dart';

// Configurações do banco de dados
const String _dbHost = '127.0.0.1';
const int _dbPort = 3306;
const String _dbUser = 'root'; // Ajuste conforme sua configuração
const String _dbPassword = 'sua_senha'; // Ajuste conforme sua configuração
const String _dbDatabase = 'sistema_pedidos';

class Database {
  static MySQLConnection? _connection;

  // Conectar ao banco de dados
  static Future<MySQLConnection?> connect() async {
    try {
      _connection = await MySQLConnection.createConnection(
        host: _dbHost,
        port: _dbPort,
        userName: _dbUser,
        databaseName: _dbDatabase,
        password: _dbPassword,
      );
      await _connection!.connect();
      print('✅ Conexão com banco estabelecida com sucesso!');
      return _connection;
    } catch (erro) {
      print('❌ Erro ao conectar ao MySQL: $erro');
      return null;
    }
  }

  // Fechar conexão
  static Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
      print('🔒 Conexão com banco fechada.');
    }
  }

  // OPERAÇÕES COM CLIENTES
  static Future<int?> inserirCliente(Cliente cliente) async {
    try {
      var result = await _connection!.execute(
        'INSERT INTO clientes (nome, email, telefone, endereco) VALUES (:nome, :email, :telefone, :endereco)',
        {
          'nome': cliente.nome,
          'email': cliente.email,
          'telefone': cliente.telefone,
          'endereco': cliente.endereco,
        },
      );
      return result.lastInsertID.toInt();
    } catch (erro) {
      print('❌ Erro ao inserir cliente: $erro');
      return null;
    }
  }

  static Future<List<Cliente>> listarClientes() async {
    try {
      var resultado = await _connection!.execute(
        'SELECT id, nome, email, telefone, endereco FROM clientes ORDER BY id',
      );

      List<Cliente> clientes = [];
      for (var linha in resultado.rows) {
        final id = linha.typedColByName<int>('id')!;
        final nome = linha.typedColByName<String>('nome')!;
        final email = linha.typedColByName<String>('email')!;
        final telefone = linha.typedColByName<String>('telefone') ?? '';
        final endereco = linha.typedColByName<String>('endereco') ?? '';

        clientes.add(Cliente(id, nome, email, telefone, endereco));
      }
      return clientes;
    } catch (erro) {
      print('❌ Erro ao listar clientes: $erro');
      return [];
    }
  }

  static Future<Cliente?> buscarClientePorId(int id) async {
    try {
      var resultado = await _connection!.execute(
        'SELECT id, nome, email, telefone, endereco FROM clientes WHERE id = :id',
        {'id': id},
      );

      if (resultado.rows.isNotEmpty) {
        var linha = resultado.rows.first;
        final nome = linha.typedColByName<String>('nome')!;
        final email = linha.typedColByName<String>('email')!;
        final telefone = linha.typedColByName<String>('telefone') ?? '';
        final endereco = linha.typedColByName<String>('endereco') ?? '';

        return Cliente(id, nome, email, telefone, endereco);
      }
      return null;
    } catch (erro) {
      print('❌ Erro ao buscar cliente: $erro');
      return null;
    }
  }

  // OPERAÇÕES COM ITENS
  static Future<List<Item>> listarItens() async {
    try {
      var resultado = await _connection!.execute(
        'SELECT id, nome, preco, quantidade_estoque FROM itens ORDER BY id',
      );

      List<Item> itens = [];
      for (var linha in resultado.rows) {
        final id = linha.typedColByName<int>('id')!;
        final nome = linha.typedColByName<String>('nome')!;
        final preco = linha.typedColByName<double>('preco')!;
        final quantidade = linha.typedColByName<int>('quantidade_estoque')!;

        itens.add(Item(id, nome, preco, quantidade));
      }
      return itens;
    } catch (erro) {
      print('❌ Erro ao listar itens: $erro');
      return [];
    }
  }

  static Future<Item?> buscarItemPorId(int id) async {
    try {
      var resultado = await _connection!.execute(
        'SELECT id, nome, preco, quantidade_estoque FROM itens WHERE id = :id',
        {'id': id},
      );

      if (resultado.rows.isNotEmpty) {
        var linha = resultado.rows.first;
        final nome = linha.typedColByName<String>('nome')!;
        final preco = linha.typedColByName<double>('preco')!;
        final quantidade = linha.typedColByName<int>('quantidade_estoque')!;

        return Item(id, nome, preco, quantidade);
      }
      return null;
    } catch (erro) {
      print('❌ Erro ao buscar item: $erro');
      return null;
    }
  }

  // OPERAÇÕES COM PEDIDOS
  static Future<int?> inserirPedido(int clienteId) async {
    try {
      var result = await _connection!.execute(
        'INSERT INTO pedidos (cliente_id) VALUES (:cliente_id)',
        {'cliente_id': clienteId},
      );
      return result.lastInsertID.toInt();
    } catch (erro) {
      print('❌ Erro ao inserir pedido: $erro');
      return null;
    }
  }

  static Future<bool> adicionarItemPedido(
    int pedidoId,
    int itemId,
    int quantidade,
    double precoUnitario,
  ) async {
    try {
      await _connection!.execute(
        'INSERT INTO pedido_itens (pedido_id, item_id, quantidade, preco_unitario, subtotal) VALUES (:pedido_id, :item_id, :quantidade, :preco_unitario, :subtotal)',
        {
          'pedido_id': pedidoId,
          'item_id': itemId,
          'quantidade': quantidade,
          'preco_unitario': precoUnitario,
          'subtotal': quantidade * precoUnitario,
        },
      );
      return true;
    } catch (erro) {
      print('❌ Erro ao adicionar item ao pedido: $erro');
      return false;
    }
  }

  static Future<bool> finalizarPedido(int pedidoId) async {
    try {
      await _connection!.execute(
        'UPDATE pedidos SET status = "Finalizado" WHERE id = :id',
        {'id': pedidoId},
      );
      return true;
    } catch (erro) {
      print('❌ Erro ao finalizar pedido: $erro');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> listarPedidos() async {
    try {
      var resultado = await _connection!.execute('''
        SELECT 
          p.id,
          p.cliente_id,
          c.nome as cliente_nome,
          p.data_pedido,
          p.status,
          p.total
        FROM pedidos p
        JOIN clientes c ON p.cliente_id = c.id
        ORDER BY p.id DESC
      ''');

      List<Map<String, dynamic>> pedidos = [];
      for (var linha in resultado.rows) {
        pedidos.add({
          'id': linha.typedColByName<int>('id'),
          'cliente_id': linha.typedColByName<int>('cliente_id'),
          'cliente_nome': linha.typedColByName<String>('cliente_nome'),
          'data_pedido': linha.typedColByName<String>('data_pedido'),
          'status': linha.typedColByName<String>('status'),
          'total': linha.typedColByName<double>('total'),
        });
      }
      return pedidos;
    } catch (erro) {
      print('❌ Erro ao listar pedidos: $erro');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> listarItensPedido(
    int pedidoId,
  ) async {
    try {
      var resultado = await _connection!.execute(
        '''
        SELECT 
          pi.id,
          pi.item_id,
          i.nome as item_nome,
          pi.quantidade,
          pi.preco_unitario,
          pi.subtotal
        FROM pedido_itens pi
        JOIN itens i ON pi.item_id = i.id
        WHERE pi.pedido_id = :pedido_id
        ORDER BY pi.id
      ''',
        {'pedido_id': pedidoId},
      );

      List<Map<String, dynamic>> itens = [];
      for (var linha in resultado.rows) {
        itens.add({
          'id': linha.typedColByName<int>('id'),
          'item_id': linha.typedColByName<int>('item_id'),
          'item_nome': linha.typedColByName<String>('item_nome'),
          'quantidade': linha.typedColByName<int>('quantidade'),
          'preco_unitario': linha.typedColByName<double>('preco_unitario'),
          'subtotal': linha.typedColByName<double>('subtotal'),
        });
      }
      return itens;
    } catch (erro) {
      print('❌ Erro ao listar itens do pedido: $erro');
      return [];
    }
  }
}
