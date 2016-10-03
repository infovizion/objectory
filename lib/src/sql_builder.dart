import 'objectory_query_builder.dart';
import 'persistent_object.dart';

class SqlQueryBuilder {
  ObjectoryQueryBuilder parent;
  String whereClause = '';
  Map<String, dynamic> params = {};
  int paramCounter = 0;
  SqlQueryBuilder(this.parent);

  processQueryPart() {
    Map sourceQuery = parent.map[r'$query'];
    if (sourceQuery == null) {
      return;
    }
    whereClause = ' WHERE ' + _processQueryNode(sourceQuery);
  }

  String _processQueryNode(Map query) {
    if (query.length != 1) {
      throw new Exception(
          'Unexpected query structure at $query. Whole query: ${parent.map[r"$query"]}');
    }
    var key = query.keys.first;
    if (key == r'$and') {
      List<Map> subComponents = query[key];
      return '(' +
          subComponents
              .map((Map subQuery) => _processQueryNode(subQuery))
              .join(' AND ') +
          ')';
    } else if (key == r'$or') {
      List<Map> subComponents = query[key];
      return '(' +
          subComponents
              .map((Map subQuery) => _processQueryNode(subQuery))
              .join(' OR ') +
          ')';
    } else {
      var value = query[key];
      Type valueType = value.runtimeType;
      if (valueType == String ||
          value is num ||
          valueType == DateTime ||
          valueType == bool) {
        paramCounter++;
        params['@p$paramCounter'] = value;
        return '$key = @p$paramCounter';
      } else {
        throw new Exception('Unexpected branch in _processQueryNode');
      }
    }
  }
  static String getInsertCommand(String tableName, Map content) {
    List<String> fieldNames = content.keys.toList();
    fieldNames.remove('id');
    List<String> paramNames = fieldNames.map((el)=> '@$el').toList();
    return '''
    INSERT INTO "${tableName}"
      (${fieldNames.join(',')})
      VALUES (${paramNames.join(',')})
        RETURNING "id"
   ''';
  }

}

class SqlInsertBuilder {
  PersistentObject po;
  String insertCommand = '';
  SqlInsertBuilder(this.po);
  String getSqlCommand() {
    List<String> fieldNames = po.map.keys.toList();
    fieldNames.remove('id');
    List<String> paramNames = fieldNames.map((el)=> '@$el').toList();
    return '''
    INSERT INTO "${po.collectionName}"
      (${fieldNames.join(',')})
      VALUES (${paramNames.join(',')})
        RETURNING "id"
   ''';
  }
}