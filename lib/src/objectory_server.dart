//library instock.shelf.objectory.server;
//
//import 'dart:io';
//import 'package:mongo_dart/mongo_dart.dart';
//import 'package:logging/logging.dart';
//import 'dart:convert';
//import 'package:instock/utils/user_lookup.dart';
//
////Map<String, ObjectoryClient> connections;
//class RequestHeader {
//  String command;
//  String collection;
//  int requestId;
//  RequestHeader.fromMap(Map commandMap) {
//    command = commandMap['command'];
//    collection = commandMap['collection'];
//    requestId = commandMap['requestId'];
//  }
//  Map toMap() =>
//      {'command': command, 'collection': collection, 'requestId': requestId};
//  String toString() => 'RequestHeader(${toMap()})';
//}
//
//class ObjectoryClient {
//  ObjectoryServerImpl server;
//  Logger log = new Logger('Objectory');
//  DateTime startDate = new DateTime.now();
//  DateTime lastActivity;
//  Db db;
//  int token;
//  WebSocket socket;
//  bool authenticated = false;
//  String userName;
//  String authToken;
//  bool testMode;
//  bool closed = false;
//  ObjectoryClient(this.token, this.socket, this.db, this.testMode, this.server) {
//    server.sessions.add(this);
//    socket.done.catchError((e) {
//      closed = true;
//      server.sessions.remove(this);
//    });
//    socket.listen((message) {
//      try {
//        lastActivity = new DateTime.now();
//        var binary = new BsonBinary.from(JSON.decode(message));
//        var jdata = new BSON().deserialize(binary);
//        var header = new RequestHeader.fromMap(jdata['header']);
//        Map content = jdata['content'];
//        Map extParams = jdata['extParams'];
//        log.info('$userName ${header.collection} ${header.command} ${content}');
//        if (header.command == 'authenticate') {
//          authenticate(header, content);
//          return;
//        }
//        if (header.command == 'listSessions') {
//          listSessions(header);
//          return;
//        }
//        if (header.command == "insert") {
//          save(header, content);
//          return;
//        }
//        if (header.command == "update") {
//          save(header, content, extParams);
//          return;
//        }
//        if (header.command == "remove") {
//          remove(header, content);
//          return;
//        }
//        if (header.command == "findOne") {
//          findOne(header, content, extParams);
//          return;
//        }
//        if (header.command == "count") {
//          count(header, content, extParams);
//          return;
//        }
//        if (header.command == "find") {
//          find(header, content, extParams);
//          return;
//        }
//        if (header.command == "queryDb") {
//          queryDb(header, content);
//          return;
//        }
//        if (header.command == "dropDb") {
//          dropDb(header);
//          return;
//        }
//        if (header.command == "dropCollection") {
//          dropCollection(header);
//          return;
//        }
//        log.shout('Unexpected message: $message');
//        sendResult(header, content);
//      } catch (e) {
//        log.severe(e);
//      }
//    }, onDone: () {
//      closed = true;
//      socket.close();
//      server.sessions.remove(this);
//    }, onError: (error) {
//      log.severe(error.toString());
//      socket.close();
//      server.sessions.remove(this);
//    });
//  }
//  sendResult(RequestHeader header, content) {
//    if (closed) {
//      log.warning(
//          'WARNING: trying send on closed connection. token:$token $header, $content');
//    } else {
//      log.fine(() => 'token:$token sendResult($header, $content) ');
//      sendMessage(header.toMap(), content);
//    }
//  }
//
//  sendMessage(header, content) {
//    socket.add(JSON.encode(
//        new BSON().serialize({'header': header, 'content': content}).byteList));
//  }
//
//  save(RequestHeader header, Map mapToSave, [Map idMap]) {
//    if (header.command == 'insert') {
//      db.collection(header.collection).insert(mapToSave).then((responseData) {
//        sendResult(header, responseData);
//      });
//    } else {
//      var id = mapToSave['_id'];
//      if (id != null) {
//        db.collection(header.collection).update({'_id': id}, mapToSave)
//            .then((responseData) {
//          sendResult(header, responseData);
//        });
//      } else {
//        if (idMap != null) {
//          db
//              .collection(header.collection)
//              .update(idMap, mapToSave)
//              .then((responseData) {
//            sendResult(header, responseData);
//          });
//        } else {
//          log.shout(
//              'ERROR: Trying to update object without _id set. $header, $mapToSave');
//        }
//      }
//    }
//  }
//
//  SelectorBuilder _selectorBuilder(Map selector, Map extParams) {
//    SelectorBuilder selectorBuilder = new SelectorBuilder();
//    selectorBuilder.map = selector;
//    selectorBuilder.paramLimit = extParams['limit'];
//    selectorBuilder.paramSkip = extParams['skip'];
//    return selectorBuilder;
//  }
//
//  find(RequestHeader header, Map selector, Map extParams) async {
//    log.fine(() => 'find $header $selector $extParams');
//    if (!authenticated) {
//      return [];
//    }
//    var responseData = await db
//        .collection(header.collection)
//        .find(_selectorBuilder(selector, extParams))
//        .toList();
//    sendResult(header, responseData);
//  }
//
//  remove(RequestHeader header, Map selector) {
//    db.collection(header.collection).remove(selector).then((responseData) {
//      sendResult(header, responseData);
//    });
//  }
//
//  findOne(RequestHeader header, Map selector, Map extParams) async {
//    if (!authenticated) {
//      return {};
//    }
//    var responseData = await db
//        .collection(header.collection)
//        .findOne(_selectorBuilder(selector, extParams));
//    sendResult(header, responseData);
//  }
//
//  authenticate(RequestHeader header, Map selector) async {
//    userName = selector['userName'];
//    authToken = selector['authToken'];
//    print('Objectory authenticate. userName: $userName');
//    var result = <String, String>{};
//    if (new StaticUserLookup().users.map((e)=>e.first).contains(userName)) {
//      authenticated = true;
//      result['userName'] = userName;
//      result['authToken'] = authToken;
//    }
//    sendResult(header, result);
//  }
//  listSessions(RequestHeader header) async {
//    print('Objectory listSessions');
//    var result = [];
//    for (var each in server.sessions) {
//      var item = {};
//      item['userName'] = each.userName;
//      item['sessionStarted'] = each.startDate.toString().substring(0,19);
//      item['lastActivity'] = each.lastActivity.toString().substring(0,19);
//      result.add(item);
//    }
//    sendResult(header, result);
//  }
//
//
//  count(RequestHeader header, Map selector, Map extParams) {
//    db
//        .collection(header.collection)
//        .count(_selectorBuilder(selector, extParams))
//        .then((responseData) {
//      sendResult(header, responseData);
//    });
//  }
//
//  queryDb(RequestHeader header, Map query) {
//    db
//        .executeDbCommand(DbCommand.createQueryDbCommand(db, query))
//        .then((responseData) {
//      sendResult(header, responseData);
//    });
//  }
//
//  dropDb(RequestHeader header) {
//    db.drop().then((responseData) {
//      sendResult(header, responseData);
//    });
//  }
//
//  dropCollection(RequestHeader header) {
//    db.dropCollection(header.collection).then((responseData) {
//      sendResult(header, responseData);
//    });
//  }
//
//  protocolError(String errorMessage) {
//    log.shout('PROTOCOL ERROR: $errorMessage');
//  }
//
//  String toString() {
//    return "ObjectoryClient_${token}";
//  }
//}
//class ObjectoryServerImpl {
//  final Logger log = new Logger('Objectory server');
//  final Set<ObjectoryClient> sessions = new Set<ObjectoryClient>();
//  Db db;
//  bool testMode = false;
//  String hostName;
//  int port;
//  String mongoUri;
//  int _token = 0;
//  String oauthClientId;
//  ObjectoryServerImpl(this.hostName,this.port,this.mongoUri, this.testMode, bool verbose ) {
//    hierarchicalLoggingEnabled = true;
//    if (verbose) {
//      log.level = Level.ALL;
//      log.info('Verbose mode on. Set log level ALL');
//    }
//    else {
//      log.level = Level.WARNING;
//    }
//  }
//  start() async {
//    db = new Db(mongoUri);
//    db.open().then((_) {
//      HttpServer.bind(hostName, port).then((server) {
//        print('Objectory server started. Listening on http://$hostName:$port');
//        server.transform(new WebSocketTransformer()).listen((WebSocket webSocket) {
//          _token+=1;
//          new ObjectoryClient(_token, webSocket, db, testMode, this);
//          log.fine('adding connection token = ${_token}');
//
//        }, onError: (e) => log.severe(e.toString()));
//      }).catchError((e) => log.severe(e.toString()));
//    });
//  }
//}
