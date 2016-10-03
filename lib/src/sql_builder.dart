import 'objectory_query_builder.dart';
import 'persistent_object.dart';

class SqlQueryBuilder {
  ObjectoryQueryBuilder parent;
  String tableName;
  String whereClause = '';
  List params = [];
  List paramPlaceholders = [];
  int paramCounter = -1;
  SqlQueryBuilder(this.tableName,this.parent);

  processQueryPart() {
    if (parent == null) {
      return;
    }
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
        params.add(value);
        return '$key = @$paramCounter';
      } else {
        throw new Exception('Unexpected branch in _processQueryNode valueType = $valueType value = $value');
      }
    }
  }
  String getQuerySql() {
    processQueryPart();
    return 'SELECT * FROM "$tableName" $whereClause';
  }

  String getQueryCountSql() {
    processQueryPart();
    return 'SELECT Count(*) FROM "$tableName" $whereClause';
  }

  String getUpdateSql(Map<String,dynamic> toUpdate) {
    processQueryPart();
    List<String> setOperations = [];
    for (var key in toUpdate.keys) {
      paramCounter++;
      setOperations.add('$key = @$paramCounter');
      params.add(toUpdate[key]);
    }
    return 'UPDATE "$tableName" SET ${setOperations.join(', ')} $whereClause';
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

