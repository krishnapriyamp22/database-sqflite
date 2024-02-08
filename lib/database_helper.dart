import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._inst();     //singleton
  static Database? _database;

  factory DatabaseHelper() => _instance;                              //to crt instnc of dbhplr cls

  DatabaseHelper._inst();                                 //  private constctr...usd to crte siglton instnc of  cls

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }
//Database Initialization
 Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();//directory
    final path = join(databasePath, 'student_database.db');
//pn crt sqlite db
    return await openDatabase(
      path,
      version: 2,                //use for mngng dbse schema
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE student_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        address TEXT,
        parent TEXT,
        hobbies TEXT,
        imagePath TEXT
      )
    ''');
  }
  //Database Operations
//Insertion

  Future<int> insert(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('student_table', row);
  }

//Updating

  Future<int> update(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      'student_table',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

//Deletion

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'student_table',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

//Searching

  Future<List<Map<String, dynamic>>> searchAll(String searchQuery) async {
    final db = await database;
    if (searchQuery.isEmpty) {
      return await db.query('student_table');
    } else {
      return await db.query(
        'student_table',
        where: 'name LIKE ?',
        whereArgs: ['%$searchQuery%'],
      );
    }
  }
}