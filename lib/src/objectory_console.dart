library objectory_direct_connection;
import 'package:postgresql/postgresql.dart';
import 'sql_builder.dart';
import 'dart:async';
import 'persistent_object.dart';
import 'objectory_query_builder.dart';
import 'objectory_base.dart';
import 'objectory_collection_console.dart';

export 'objectory_collection_console.dart';



class ObjectoryConsole extends Objectory{
  Connection connection;
  ObjectoryConsole(String uri,Function registerClassesCallback,bool dropCollectionsOnStartup):
    super(uri, registerClassesCallback, dropCollectionsOnStartup);
  Future open() async {
    if (connection != null){
      await connection.close();
    }
    connection = await connect(uri);
  }
  /// Insert the data and returns id of newly inserted row
  Future doInsert(String tableName, Map toInsert) async {
    var command = SqlQueryBuilder.getInsertCommand(tableName, toInsert);
    List<Row> res = await connection.query(command,toInsert).toList();
    return res.first.toList().first;
  }

  Future close() async {
    await connection.close();
    connection = null;
  }

  ObjectoryCollection constructCollection() => new ObjectoryCollectionConsole(this);

//  Future<List<Map>> findRawObjects(String tableName, [ObjectoryQueryBuilder selector]) async
//  => await db.collection(tableName).find(selector).toList();




//
//
//  Future doUpdate(String collection,var id, Map toUpdate) {
//    assert(id.runtimeType == idType);
//    return db.collection(collection).update({"id": id},toUpdate);
//  }
//
//
//
//  Future remove(PersistentObject persistentObject) =>
//      db.collection(persistentObject.tableName).remove({"id":persistentObject.id});
//
//  ObjectoryCollection constructCollection() => new ObjectoryCollectionDirectConnectionImpl(this);
//
//  Future<Map> dropDb(){
//    return db.drop();
//  }
//
//  Future<Map> wait(){
//    return db.wait();
//  }
//
//
//  Future dropCollections() async {
//    for (var collection in getCollections()) {
//      await db.collection(collection).drop();
//    }
//  }

}
