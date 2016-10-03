import 'dart:async';
import 'persistent_object.dart';
import 'objectory_query_builder.dart';
import 'objectory_console.dart';
import 'objectory_base.dart';
import 'sql_builder.dart';
import 'package:postgresql/postgresql.dart';

class ObjectoryCollectionConsole extends ObjectoryCollection {
  ObjectoryConsole objectoryImpl;

  ObjectoryCollectionConsole(this.objectoryImpl);

  Future<List<PersistentObject>> find([ObjectoryQueryBuilder selector]) async {
    SqlQueryBuilder sqlBuilder = new SqlQueryBuilder(collectionName, selector);
    String command = sqlBuilder.getQuerySql();
    var result = objectory.createTypedList(classType);
    await objectoryImpl.connection
        .query(command, sqlBuilder.params)
        .forEach((Row row) {
      PersistentObject obj = objectory.map2Object(classType, row.toMap());
      result.add(obj);
    });
    if (selector != null && !selector.paramFetchLinks) {
      await Future.wait(result.map((item) => item.fetchLinks()));
    }
    return result;
  }

  Future<PersistentObject> findOne([ObjectoryQueryBuilder selector]) async {
    List<PersistentObject> pl = await find(selector);
    if (pl.isEmpty) {
      return null;
    } else {
      return pl.first;
    }
  }

  Future<int> count([ObjectoryQueryBuilder selector]) async {
    SqlQueryBuilder sqlBuilder = new SqlQueryBuilder(collectionName, selector);
    String command = sqlBuilder.getQueryCountSql();
    List<Row> rows = await objectoryImpl.connection
        .query(command, sqlBuilder.params)
        .toList();
    return rows.first.toList().first;
  }


}
