library objectory_query;

import 'persistent_object.dart';
import 'dart:convert';
import 'dart:collection';

QueryBuilder get where => new QueryBuilder();

class QueryBuilder {
//  static final RegExp objectIdRegexp =
//  new RegExp(".ObjectId...([0-9a-f]{24})....");
  Map map = {};
  bool paramFetchLinks = false;
  bool _isQuerySet = false;
  Map get _query {
    if (!_isQuerySet) {
      map['\$query'] = {};
      _isQuerySet = true;
    }
    return map['\$query'];
  }

  int paramSkip = 0;
  int paramLimit = 0;
  Map paramFields;

  Map get extParamsMap => {
        'skip': paramSkip,
        'limit': paramLimit,
        'fetchLinksMode': paramFetchLinks
      };

  String toString() => "SelectorBuilder($map)";

  _addExpression(String fieldName, value) {
    Map exprMap = {};
    exprMap[fieldName] = value;
    if (_query.isEmpty) {
      _query[fieldName] = value;
    } else {
      _addExpressionMap(exprMap);
    }
  }

  _addExpressionMap(Map expr) {
    if (_query.containsKey('AND')) {
      List expressions = _query['AND'];
      expressions.add(expr);
    } else {
      var expressions = [_query];
      expressions.add(expr);
      map['\$query'] = {'AND': expressions};
    }
  }

  void _ensureParamFields() {
    if (paramFields == null) {
      paramFields = {};
    }
  }

  void _ensureOrderBy() {
    _query;
    if (!map.containsKey("orderby")) {
      map["orderby"] = new LinkedHashMap();
    }
  }

  QueryBuilder eq(String fieldName, value) {
    _addExpression(fieldName, {"=": value});
    return this;
  }

  QueryBuilder id(int value) {
    return eq('id', value);
  }

  QueryBuilder ne(String fieldName, value) {
    _addExpression(fieldName, {"<>": value});
    return this;
  }

  QueryBuilder gt(String fieldName, value) {
    _addExpression(fieldName, {">": value});
    return this;
  }

  QueryBuilder lt(String fieldName, value) {
    _addExpression(fieldName, {"<": value});
    return this;
  }

  QueryBuilder gte(String fieldName, value) {
    _addExpression(fieldName, {">=": value});
    return this;
  }

  QueryBuilder lte(String fieldName, value) {
    _addExpression(fieldName, {"<=": value});
    return this;
  }

  QueryBuilder like(String fieldName, String value, {bool caseInsensitive: false}) {
    _addExpression(fieldName, {'LIKE': value, 'caseInsensitive': caseInsensitive});
    return this;
  }

//  QueryBuilder all(String fieldName, List values) {
//    _addExpression(fieldName, {"\$all": values});
//    return this;
//  }

//  QueryBuilder notIn(String fieldName, List values) {
//    _addExpression(fieldName, {"\$nin": values});
//    return this;
//  }

  QueryBuilder oneFrom(String fieldName, List values) {
    _addExpression(fieldName, {"IN": values, "DUMMY": 0});
    return this;
  }

//  QueryBuilder exists(String fieldName) {
//    _addExpression(fieldName, {"\$exists": true});
//    return this;
//  }
//
//  QueryBuilder notExists(String fieldName) {
//    _addExpression(fieldName, {"\$exists": false});
//    return this;
//  }

//  QueryBuilder mod(String fieldName, int value) {
//    _addExpression(fieldName, {
//      "\$mod": [value, 0]
//    });
//    return this;
//  }

//  SelectorBuilder match(String fieldName, String pattern,
//      {bool multiLine, bool caseInsensitive, bool dotAll, bool extended}) {
//    _addExpression(fieldName, {
//      '\$regex': new BsonRegexp(pattern,
//          multiLine: multiLine,
//          caseInsensitive: caseInsensitive,
//          dotAll: dotAll,
//          extended: extended)
//    });
//    return this;
//  }

//  QueryBuilder inRange(String fieldName, min, max,
//      {bool minInclude: true, bool maxInclude: false}) {
//    Map rangeMap = {};
//    if (minInclude) {
//      rangeMap["\$gte"] = min;
//    } else {
//      rangeMap["\$gt"] = min;
//    }
//    if (maxInclude) {
//      rangeMap["\$lte"] = max;
//    } else {
//      rangeMap["\$lt"] = max;
//    }
//    _addExpression(fieldName, rangeMap);
//    return this;
//  }

  QueryBuilder sortBy(String fieldName, {bool descending: false}) {
    _ensureOrderBy();
    int order = 1;
    if (descending) {
      order = -1;
    }
    map["orderby"][fieldName] = order;
    return this;
  }


  QueryBuilder fields(List<String> fields) {
    _ensureParamFields();
    for (var field in fields) {
      paramFields[field] = 1;
    }
    return this;
  }

  QueryBuilder excludeFields(List<String> fields) {
    _ensureParamFields();
    for (var field in fields) {
      paramFields[field] = 0;
    }
    return this;
  }

  QueryBuilder limit(int limit) {
    paramLimit = limit;
    return this;
  }

  QueryBuilder skip(int skip) {
    paramSkip = skip;
    return this;
  }

  QueryBuilder raw(Map rawSelector) {
    map = rawSelector;
    return this;
  }

//  QueryBuilder within(String fieldName, value) {
//    _addExpression(fieldName, {
//      "\$within": {"\$box": value}
//    });
//    return this;
//  }
//
//  QueryBuilder near(String fieldName, var value, [double maxDistance]) {
//    if (maxDistance == null) {
//      _addExpression(fieldName, {"\$near": value});
//    } else {
//      _addExpression(
//          fieldName, {"\$near": value, "\$maxDistance": maxDistance});
//    }
//    return this;
//  }

  /// Combine current expression with expression in parameter.
  /// [See MongoDB doc](http://docs.mongodb.org/manual/reference/operator/and/#op._S_and)
  /// [QueryBuilder] provides implicit `and` operator for chained queries so these two expression will produce
  /// identical MongoDB queries
  ///
  ///     where.eq('price', 1.99).lt('qty', 20).eq('sale', true);
  ///     where.eq('price', 1.99).and(where.lt('qty',20)).and(where.eq('sale', true))
  ///
  /// Both these queries would produce json map:
  ///
  ///     {'\$query': {'AND': [{'price':1.99},{'qty': {'\$lt': 20 }}, {'sale': true }]}}
  QueryBuilder and(QueryBuilder other) {
    if (_query.isEmpty) {
      throw new StateError('`And` opertion is not supported on empty query');
    }
    _addExpressionMap(other._query);
    return this;
  }

  /// Combine current expression with expression in parameter by logical operator **OR**.
  /// [See MongoDB doc](http://docs.mongodb.org/manual/reference/operator/and/#op._S_or)
  /// For example
  ///    inventory.find(where.eq('price', 1.99).and(where.lt('qty',20).or(where.eq('sale', true))));
  ///
  /// This query will select all documents in the inventory collection where:
  /// * the **price** field value equals 1.99 and
  /// * either the **qty** field value is less than 20 or the **sale** field value is true
  /// MongoDB json query from this expression would be
  ///      {'\$query': {'AND': [{'price':1.99}, {'OR': [{'qty': {'\$lt': 20 }}, {'sale': true }]}]}}
  QueryBuilder or(QueryBuilder other) {
    if (_query.isEmpty) {
      throw new StateError('`And` opertion is not supported on empty query');
    }
    if (_query.containsKey('OR')) {
      List expressions = _query['OR'];
      expressions.add(other._query);
    } else {
      var expressions = [_query];
      expressions.add(other._query);
      map['\$query'] = {'OR': expressions};
    }
    return this;
  }

  String getQueryString() {
    var result = JSON.encode(map);
    return result;
  }

  QueryBuilder fetchLinks() {
    paramFetchLinks = true;
    return this;
  }


  QueryBuilder clone() {
    var copy = where;
    copy.map = new Map.from(map);
    return copy;
  }
}

