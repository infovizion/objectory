//import 'package:postgresql/postgresql.dart';
//import 'package:objectory/objectory.dart';
//import 'package:objectory/src/sql_builder.dart';
import 'package:objectory/objectory_console.dart';
import 'domain_model/domain_model.dart';


main() async {


  String username = 'test';
  String password = 'test';
  String database = 'objectory_test';
  String host = 'localhost';
  int port = 5432;
  String uri = 'postgres://$username:$password@$host:$port/$database';
  print('$uri');
  objectory = new ObjectoryConsole(uri, registerClasses);
  ObjectoryConsole objectoryConsole = objectory;
  await objectory.initDomainModel();

//  var res = await objectoryConsole.connection.query('SELECT * FROM "Author"  WHERE id = @p1', {'p1': 2}).toList();
//  print(res);


//  await objectoryConsole.createTable(Author);
  await objectoryConsole.recreateSchema();
//
//
  Author author = new Author();
  author.name = 'Dan';
  author.age = 3;
  author.email = 'who@cares.net';
  //author.save();
  await objectory.save(author);

  print('author.id = ${author.id}');

  author.age = 4;
  await author.save();



//  author.age = 4;
//  await author.save();
  Author authFromDb = await objectory[Author].findOne(where.id(author.id));
  print(authFromDb.map);
  await objectory.close();



//  Author author = new Author();
//  author.age = 141;
//  author.name = 'Vadim1';
//  await objectory.insert(author);
//
//  List<Author> res = await objectory[Author].find();
//  for (var each in res) {
//    print(each.map);
//  }
//
//
//  int count = await objectory[Author].count();
//
//  print('Total count: $count');
//
//  await objectory.close();


}
