class Field {
  final String id;
  final String label;
  final String title;
  final Type type;
  final bool logChanges;
  const Field({this.id: '', this.label: '', this.title: '', this.type: Object, this.logChanges: false});
}

class BaseTable {
  static List<Field> get fields => throw new Exception('Shoulg be implemented');
  String get tableName => throw new Exception('Shoulg be implemented');
  String get createSequenceCommand =>
      'CREATE SEQUENCE "${tableName}_id_seq"  INCREMENT 1  MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1';
  String get dropSequenceCommand => 'DROP SEQUENCE "${tableName}_id_seq"';
  String get dropTableCommand => 'DROP TABLE "${tableName}_id_seq"';
  String get createTableCommand => throw new Exception('Shoulg be implemented');
}
