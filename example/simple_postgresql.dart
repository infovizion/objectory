//import 'package:postgresql/postgresql.dart';
//import 'package:objectory/objectory.dart';
//import 'package:objectory/src/sql_builder.dart';
import 'package:objectory/objectory_console.dart';
import 'domain_model/domain_model.dart';


main() async {


  String username = 'test';
  String password = 'test';
  String database = 'test';
  String host = 'localhost';
  int port = 5432;
  String uri = 'postgres://$username:$password@$host:$port/$database';
  objectory = new ObjectoryConsole(uri, registerClasses, false);
  await objectory.initDomainModel();

//  var res = await connection.query('INSERT INTO "test" ("name") VALUES (\'second\') RETURNING "id"').toList();
//  print(res);
  Author author = new Author();
  author.age = 141;
  author.name = 'Vadim1';
  await objectory.insert(author);

  List<Author> res = await objectory[Author].find();
  for (var each in res) {
    print(each.map);
  }


  int count = await objectory[Author].count();

  print('Total count: $count');

  await objectory.close();
//  var command = SqlQueryBuilder.getInsertCommand(author.collectionName, author.map);
//  print(command);
//  List<Row> res = await connection.query(command,author.map).toList();

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
