import 'package:postgresql/postgresql.dart';
import 'package:objectory/objectory.dart';
import 'package:objectory/src/sql_builder.dart';
import 'domain_model/domain_model.dart';


main() async {

  objectory = new Objectory(null,null, false);
  registerClasses();
  String username = 'test';
  String password = 'test';
  String database = 'test';
  String host = 'localhost';
  int port = 5432;
  Connection connection = await connect('postgres://$username:$password@$host:$port/$database');
//  var res = await connection.query('INSERT INTO "test" ("name") VALUES (\'second\') RETURNING "id"').toList();
//  print(res);
  Author author = new Author();
  author.age = 14;
  author.name = 'Vadim';
  var command = new SqlInsertBuilder(author).getSqlCommand();
  print(command);

  var res = await connection.query(command,author.map).toList();
  print(res);
  await connection.close();
//  var map = (where
//          .eq('www', 12)
//          .eq('qqq', 'werwer')
//          .or(where.ne('eee', 2))
//          .sortBy('www'))
//      .map;
//  print(map);
//  map = (where.id('123123')).map;
//  print(map);
//  var qb = new PgQueryBuilder(
//      where.eq('www', 12).eq('qqq', 'werwer').or(where.eq('eee', 2)));
//  qb.processQueryPart();
//  print(qb.whereClause);
//  print(qb.params);
}
