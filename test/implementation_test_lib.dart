library implementation_test_lib;

import 'dart:async';
import 'package:objectory/objectory.dart';
import 'package:bson/bson.dart';
import 'package:test/test.dart';
import 'domain_model.dart';

allImplementationTests() {
  setUp(() async {
    await objectory.initDomainModel();
  });
  test('Simple test for insert object', () async {
    await objectory.truncate(Author);
    Author author = new Author();
    author.name = 'Dan';
    author.age = 32;
    author.email = 'who@cares.net';
    await author.save();
    expect(author.id, isNotNull);
    Author authFromDb = await objectory[Author].findOne(where.id(author.id));
    expect(authFromDb, isNotNull);
    expect(authFromDb.age, 32);
    objectory.close();
  });

  test('Insert object, then update it', () async {
    await objectory.truncate(Author);
    Author author = new Author();
    author.name = 'Dan';
    author.age = 3;
    author.email = 'who@cares.net';
    await author.save();
    expect(author.id, isNotNull);
    author.age = 4;
    await author.save();
    Author authFromDb = await objectory[Author].findOne(where.id(author.id));
    expect(authFromDb, isNotNull);
    expect(authFromDb.age, 4);
    objectory.close();
  });
  test('simpleTestInsertAndRemove', () async {
    await objectory.truncate(Author);
    Author author;
    author = new Author();
    author.name = 'Dan';
    author.age = 3;
    author.email = 'who@cares.net';
    await author.save();
    Author authFromDb = await objectory[Author].findOne(where.id(author.id));
    expect(authFromDb, isNotNull);
    expect(authFromDb.age, 3);
    await authFromDb.remove();
    authFromDb = await objectory[Author].findOne(where.id(author.id));
    expect(authFromDb, isNull);
    objectory.close();
  });
  test('testInsertionAndUpdate', () async {
    await objectory.truncate(Author);
    Author author = new Author();
    author.name = 'Dan';
    author.age = 3;
    author.email = 'who@cares.net';
    await author.save();
    author.age = 4;
    await author.save();
    var coll = await objectory[Author].find();
    expect(coll.length, 1);
    Author authFromMongo = coll[0];
    expect(authFromMongo.age, 4);
    await objectory.close();
  });
  test('testSaveWithoutChanges', () async {
    await objectory.truncate(Author);
    Author author = new Author();
    author.name = 'Dan';
    author.age = 3;
    author.email = 'who@cares.net';
    await author.save();
    author.age = 4;
    await author.save();
    var coll = await objectory[Author].find();
    expect(coll.length, 1);
    Author authFromMongo = coll[0];
    expect(authFromMongo.age, 4);
    authFromMongo.save();
    var author1 = await objectory[Author].findOne(where.id(authFromMongo.id));
    expect(author1.age, 4);
    expect(author1.name, 'Dan'); // Converted to uppecase in setter
    expect(author1.email, 'who@cares.net');
    await objectory.close();
  });
//  test('testMatch', () async {
//    await objectory.truncate(Person);
//    var person = new Person();
//    person.firstName = 'Daniil';
//    person.save();
//    person = new Person();
//    person.firstName = 'Vadim';
//    person.save();
//    person = new Person();
//    person.firstName = 'Nickolay';
//    await person.save();
//    var coll = await objectory[Person].find(
//        where.match($Person.firstName, '^niCk.*y\$', caseInsensitive: true));
//    expect(coll.length, 1);
//    Person personFromMongo = coll[0];
//    expect(personFromMongo.firstName, 'Nickolay');
//    objectory.close();
//  });

  test('tesFindWithoutParams', () async {
    await objectory.truncate(Person);
    var person = new Person();
    person.firstName = 'Daniil';
    person.save();
    person = new Person();
    person.firstName = 'Vadim';
    person.save();
    person = new Person();
    person.firstName = 'Nickolay';
    await person.save();
    var coll = await objectory[Person].find();
    expect(coll.length, 3);
    objectory.close();
  });
  test('testLimit', () async {
    await objectory.truncate(Author);
    for (int n = 0; n < 30; n++) {
      Author author = new Author();
      author.age = n;
      await author.save();
    }
    var coll = await objectory[Author].find(where.skip(20).limit(10));
    expect(coll.length, 10);
    Author authFromMongo = coll[0];
    expect(authFromMongo.age, 20);
    await objectory.close();
  });
  test('testCount', () async {
    await objectory.truncate(Author);

    for (int n = 0; n < 27; n++) {
      Author author = new Author();
      author.age = n;
      await author.save();
    }
    var _count = await objectory[Author].count();
    expect(_count, 27);
    await objectory.close();
  });

  test('findOne should not get object from cache', () async {
    await objectory.truncate(Author);
      Author author = new Author();
      author.id = 233;
      objectory.addToCache(author);
      author = await objectory[Author].findOne(where.id(author.id));
      expect(author, isNull);
      objectory.close();
  });


  test('find with fetchLinks mode', () async {
    await objectory.truncate(Person);
    Person father = new Person()..firstName = 'Vadim';
    await father.save();
    Person son = new Person()..firstName = 'Nick'..father=father;
    await son.save();
    int sonId = son.id;

    objectory.clearCache(Person);
    Person sonFromDb = await objectory[Person].findOne(where.id(sonId));
    expect(sonFromDb.firstName, 'Nick');
    expect(sonFromDb.father.id, isNotNull);
    expect(sonFromDb.father.firstName, isNull);
    objectory.clearCache(Person);
    sonFromDb = await objectory[Person].findOne(where.id(sonId).fetchLinks());
    expect(sonFromDb.firstName, 'Nick');
    expect(sonFromDb.father.id, isNotNull);
    expect(sonFromDb.father.firstName, 'Vadim');

//    return objectory.initDomainModel().then((_) {
//      _setupArticle(objectory);
//      return objectory[Article].find(where.sortBy($Article.title).fetchLinks());
//    }).then((artciles) {
//      Article artcl = artciles[0];
//      expect(artcl.comments[0].user.name, 'Joe Great');
//      expect(artcl.comments[1].user.name, 'Lisa Fine');
//      expect(artcl.author.name, 'VADIM');
//      objectory.close();
//    });
  });
  test('testCollectionGet', () async {
    await objectory.initDomainModel();
    var person = new Person();
    person.firstName = '111';
    person.lastName = 'initial setup';
    await person.save();
    person =
        await objectory[Person].findOne(where.eq($Person.firstName, '111'));
    expect(person, isNotNull);
    expect(person.lastName, 'initial setup');
    person.lastName = 'unsaved changes';
    person =
        await objectory[Person].findOne(where.eq($Person.firstName, '111'));
    expect(person.lastName, 'initial setup',
        reason: 'Find operations should get objects from Db');
    person.lastName = 'unsaved changes';
    person = await objectory[Person].get(person.id);
    expect(person.lastName, 'unsaved changes',
        reason:
            'Collection get method should get objects from objectory cache');
    objectory.close();
  });
}
