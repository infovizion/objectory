library objectory_direct_connection;
import 'package:postgresql/postgresql.dart';
import 'sql_builder.dart';
import 'dart:async';
import 'persistent_object.dart';
import 'objectory_query_builder.dart';
import 'objectory_base.dart';

class ObjectoryCollectionDirectConnectionImpl extends ObjectoryCollection{
  ObjectoryDirectConnectionImpl objectoryImpl;
  ObjectoryCollectionDirectConnectionImpl(this.objectoryImpl);
  Future<int> count([ObjectoryQueryBuilder selector]) { 
    return  objectoryImpl.db.collection(tableName).count(selector); 
  }
  Future<List<PersistentObject>> find([ObjectoryQueryBuilder selector]){
    Completer completer = new Completer();
    var result = objectory.createTypedList(classType);
    objectoryImpl.db.collection(tableName)
      .find(selector)
      .forEach((map){
        PersistentObject obj = objectory.map2Object(classType,map);
        result.add(obj);
      }).then((_) {
        if (selector == null ||  !selector.paramFetchLinks) {
          completer.complete(result);
        } else {
          Future
          .wait(result.map((item) => item.fetchLinks()))
          .then((res) {completer.complete(res);}); 
        }
      });
    return completer.future;
  }




  Future<PersistentObject> findOne([ObjectoryQueryBuilder selector]){
    Completer completer = new Completer();
    objectoryImpl.db.collection(tableName)
      .findOne(selector)
      .then((map){
        objectoryImpl.completeFindOne(map,completer,selector, classType);          
      });
    return completer.future;
  }
}

class ObjectoryDirectConnectionImpl extends Objectory{
  Connection connection;
  ObjectoryDirectConnectionImpl(String uri,Function registerClassesCallback,bool dropCollectionsOnStartup):
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

  Future doUpdate(String collection,var id, Map toUpdate) {
        assert(id.runtimeType == idType);
        return db.collection(collection).update({"id": id},toUpdate);
  }


  Future<List<Map>> findRawObjects(String tableName, [ObjectoryQueryBuilder selector]) async
    => await db.collection(tableName).find(selector).toList();

  Future remove(PersistentObject persistentObject) =>
      db.collection(persistentObject.tableName).remove({"id":persistentObject.id});
  
  ObjectoryCollection constructCollection() => new ObjectoryCollectionDirectConnectionImpl(this);

  Future<Map> dropDb(){
    return db.drop();
  }

  Future<Map> wait(){
    return db.wait();
  }


  Future close() async {
    await connection.close();
    connection = null;
  }
  Future dropCollections() async {
    for (var collection in getCollections()) {
      await db.collection(collection).drop();
    }
  }

}
