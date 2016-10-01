library objectory_direct_connection;
import 'dart:async';
import 'persistent_object.dart';
import 'objectory_query_builder.dart';
import 'objectory_base.dart';
import 'package:postgresql/postgresql.dart';

class ObjectoryCollectionPostgreSqlImpl extends ObjectoryCollection{
  ObjectoryPostgreSqlImpl objectoryImpl;
  ObjectoryCollectionPostgreSqlImpl(this.objectoryImpl);
  Future<int> count([ObjectoryQueryBuilder selector]) { 
    return  objectoryImpl.db.collection(collectionName).count(selector); 
  }
  Future<List<PersistentObject>> find([ObjectoryQueryBuilder selector]){
    Completer completer = new Completer();
    var result = objectory.createTypedList(classType);
    objectoryImpl.db.collection(collectionName)
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
    objectoryImpl.db.collection(collectionName)
      .findOne(selector)
      .then((map){
        objectoryImpl.completeFindOne(map,completer,selector, classType);          
      });
    return completer.future;
  }
}

class ObjectoryPostgreSqlImpl extends Objectory{
  Connection connection;
  ObjectoryPostgreSqlImpl(String uri,Function registerClassesCallback,bool dropCollectionsOnStartup):
    super('', registerClassesCallback, dropCollectionsOnStartup);
  Future open() async {
    if (connection != null){
      await connection.close();
    }
    connection = await connect(uri);
  }
  Future doInsert(String collectionName, Map toInsert) =>
      db.collection(collectionName).insert(toInsert);

  Future doUpdate(String collection,var id, Map toUpdate) {
        assert(id.runtimeType == idType);
        return db.collection(collection).update({"id": id},toUpdate);
  }


  Future<List<Map>> findRawObjects(String collectionName, [ObjectoryQueryBuilder selector]) async
    => await db.collection(collectionName).find(selector).toList();

  Future remove(PersistentObject persistentObject) =>
      gateway.table(persistentObject.collectionName).delete(remove({"id":persistentObject.id});
  
  ObjectoryCollection constructCollection() => new ObjectoryCollectionPostgreSqlImpl(this);




  close() async {
    await connection.close();
    connection = null;
  }

}
