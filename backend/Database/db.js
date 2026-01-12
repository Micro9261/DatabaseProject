import fs from "fs";
import path from "path";
import pgp from "pg-promise";

export async function initDatabase(db, schema, loadTestData) {
  const createTableSqlFile = path.join(
    process.cwd(),
    "Database\\CreateTables.sql"
  );
  const createFunctionsSqlFile = path.join(
    process.cwd(),
    "Database\\CreateFunctions.sql"
  );
  const createTriggerSqlFile = path.join(
    process.cwd(),
    "Database\\CreateTriggers.sql"
  );
  const createViewSqlFile = path.join(
    process.cwd(),
    "Database\\CreateViews.sql"
  );
  const loadDataSqlFile = path.join(process.cwd(), "Database\\LoadData.sql");

  const executeSql = [
    createTableSqlFile,
    createFunctionsSqlFile,
    createTriggerSqlFile,
    createViewSqlFile,
    loadDataSqlFile,
  ];

  if (loadTestData) {
    const initTestDataSqlFile = path.join(
      process.cwd(),
      "Database\\InitTestData.sql"
    );

    executeSql.push(initTestDataSqlFile);
  }

  try {
    const createSchema = "CREATE SCHEMA IF NOT EXISTS $1:name";
    const schemaParams = [schema];
    const sqlQuery = pgp.as.format(createSchema, schemaParams);
    await db.none(sqlQuery);

    for (let i = 0; i < executeSql.length; i++) {
      const sql = fs.readFileSync(executeSql[i], "utf-8");
      const searchPath = `SET search_path TO $1:name`;
      const schemaParams = [schema];
      const sqlQueryPath = pgp.as.format(searchPath, schemaParams);
      await db.tx(async (t) => {
        await db.any(sqlQueryPath);
        const res = await db.any(sql);
      });
    }
  } catch (err) {
    console.log(err);
  }
}

export async function deleteDatabase(db, schema) {
  const deleteDbSqlFile = path.join(
    process.cwd(),
    "Database\\DeleteDatabase.sql"
  );
  try {
    const dropSchema = "DROP SCHEMA IF EXISTS $1:name CASCADE";
    const schemaParams = [schema];
    const sqlQuerySchema = pgp.as.format(dropSchema, schemaParams);

    const sql = fs.readFileSync(deleteDbSqlFile, "utf-8");

    const createSchema = "SET search_path to $1:name";
    const sqlQueryPath = pgp.as.format(createSchema, schemaParams);
    await db.tx(async (t) => {
      await db.none(sqlQueryPath);
      await db.none(sql);
      await db.any(sqlQuerySchema);
    });
  } catch (err) {
    console.log(err);
  }
}
