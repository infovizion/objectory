/// Warning! That file is generated. Do not edit it manually
part of domain_model;

class $User {
  static String get name => 'name';
  static String get email => 'email';
  static String get login => 'login';
  static String get author => 'author';
  static final List<String> allFields = [name, email, login, author];
  static final List<PropertyDescriptor> simpleFields = [
    const PropertyDescriptor('name', PropertyType.String, 'name')
    ,const PropertyDescriptor('email', PropertyType.String, 'email')
    ,const PropertyDescriptor('login', PropertyType.String, 'login')
  ];
}

class User extends PersistentObject {
  String get collectionName => 'User';
  List<String> get $allFields => $User.allFields;
  String get name => getProperty('name');
  set name (String value) => setProperty('name',value);
  String get email => getProperty('email');
  set email (String value) => setProperty('email',value);
  String get login => getProperty('login');
  set login (String value) => setProperty('login',value);
  Author get author => getLinkedObject('author', Author);
  set author (Author value) => setLinkedObject('author',value);
}

class $Author {
  static String get name => 'name';
  static String get email => 'email';
  static String get age => 'age';
  static final List<String> allFields = [name, email, age];
  static final List<PropertyDescriptor> simpleFields = [
    const PropertyDescriptor('name', PropertyType.String, 'name')
    ,const PropertyDescriptor('email', PropertyType.String, 'email')
    ,const PropertyDescriptor('age', PropertyType.int, 'age')
  ];
}

class Author extends PersistentObject {
  String get collectionName => 'Author';
  List<String> get $allFields => $Author.allFields;
  String get name => getProperty('name');
  set name (String value) => setProperty('name',value);
  String get email => getProperty('email');
  set email (String value) => setProperty('email',value);
  int get age => getProperty('age');
  set age (int value) => setProperty('age',value);
}

registerClasses() {
  objectory.registerClass(User,()=>new User(),()=>new List<User>(), {'author': Author});
  objectory.registerClass(Author,()=>new Author(),()=>new List<Author>(), {});
}


 /// Postgresql DB Schema 
/*
CREATE SEQUENCE "User_id_seq"  INCREMENT 1  MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
CREATE TABLE "User" (
  "id" integer NOT NULL DEFAULT nextval('"User_id_seq"'::regclass),
  "name" character varying(255),
  "email" character varying(255),
  "login" character varying(255),
  "author" character varying(255),
  CONSTRAINT "User_px" PRIMARY KEY ("id")
);

CREATE SEQUENCE "Author_id_seq"  INCREMENT 1  MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
CREATE TABLE "Author" (
  "id" integer NOT NULL DEFAULT nextval('"Author_id_seq"'::regclass),
  "name" character varying(255),
  "email" character varying(255),
  "age" integer,
  CONSTRAINT "Author_px" PRIMARY KEY ("id")
);

*/
