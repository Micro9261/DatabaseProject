import fs from "fs";
import path from "path";
import pgp from "pg-promise";
import bcrypt from "bcrypt";

const users = [
  {
    name: "Pawel",
    surname: "Glowacki",
    login: "AdminTest",
    email: "test1@gmail.com",
    gender: "male",
    role: "admin",
    passHash: "1234",
  },
  {
    name: "Kacper",
    surname: "Marmaj",
    login: "ModeratorTest",
    email: "test2@gmail.com",
    gender: "male",
    role: "moderator",
    passHash: "1234",
  },
  {
    name: "Piotr",
    surname: "Nowak",
    login: "UserTest",
    email: "test3@gmail.com",
    gender: "male",
    role: "user",
    passHash: "1234",
  },
  {
    name: "Jacek",
    surname: "Pietruszka",
    login: "Pietruszka1",
    email: "test4@gmail.com",
    gender: "male",
    role: "user",
    passHash: "1234",
  },
  {
    name: "marek",
    surname: "staszyński",
    login: "Staszeczek",
    email: "test5@gmail.com",
    gender: "male",
    role: "user",
    passHash: "1234",
  },
  {
    name: "kuba",
    surname: "wrocek",
    login: "wrocławskiRok",
    email: "test6@gmail.com",
    gender: "male",
    role: "user",
    passHash: "1234",
  },
  {
    name: "Mikołaj",
    surname: "warta",
    login: "mikoWart",
    email: "test7@gmail.com",
    gender: "male",
    role: "user",
    passHash: "1234",
  },
  {
    name: "Justyna",
    surname: "bomba",
    login: "Justice",
    email: "test8@gmail.com",
    gender: "female",
    role: "user",
    passHash: "1234",
  },
  {
    name: "Anastazja",
    surname: "wieczorek",
    login: "AnWek",
    email: "test9@gmail.com",
    gender: "female",
    role: "user",
    passHash: "1234",
  },
];

export async function initDatabase(db, schema, loadTestData) {
  const createTableSqlFile = path.join(
    process.cwd(),
    "Database/CreateTables.sql",
  );
  const createFunctionsSqlFile = path.join(
    process.cwd(),
    "Database/CreateFunctions.sql",
  );
  const createTriggerSqlFile = path.join(
    process.cwd(),
    "Database/CreateTriggers.sql",
  );
  const createViewSqlFile = path.join(
    process.cwd(),
    "Database/CreateViews.sql",
  );
  const createFunctionsAfterViewsSqlFile = path.join(
    process.cwd(),
    "Database/CreateFunctionsAfterViews.sql",
  );
  const loadDataSqlFile = path.join(process.cwd(), "Database/LoadData.sql");

  const executeSql = [
    createTableSqlFile,
    createFunctionsSqlFile,
    createTriggerSqlFile,
    createViewSqlFile,
    createFunctionsAfterViewsSqlFile,
    loadDataSqlFile,
  ];

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
        await t.any(sqlQueryPath);
        const res = await t.any(sql);
      });
    }

    if (loadTestData) {
      const initTestDataSqlFile = path.join(
        process.cwd(),
        "Database/InitTestData.sql",
      );

      const salt = Number(process.env.SALT);
      let sqlParamList = [];
      const passHash = await bcrypt.hash(users[0].passHash, Number(salt));
      for (let i = 0; i < users.length; i++) {
        sqlParamList.push({ ...users[i], passHash });
      }
      await db.tx(async (t) => {
        const searchPath = `SET search_path TO $1:name`;
        await t.none(searchPath, [schema]);

        const sql = "SELECT * FROM user_create($1, $2, $3, $4, $5, $6, $7)";

        for (let i = 0; i < sqlParamList.length; i++) {
          const p = sqlParamList[i];
          const values = [
            p.name,
            p.surname,
            p.login,
            p.email,
            p.gender,
            p.role,
            p.passHash,
          ];
          await t.any(sql, values);
        }
      });

      const sql = fs.readFileSync(initTestDataSqlFile, "utf-8");
      const searchPath = `SET search_path TO $1:name`;
      const schemaParams = [schema];
      const sqlQueryPath = pgp.as.format(searchPath, schemaParams);
      db.tx(async (t) => {
        t.any(sqlQueryPath);
        t.any(sql);
      });

      console.log("DataLoaded!");
    }
  } catch (err) {
    console.log(err);
  }
}

export async function deleteDatabase(db, schema) {
  const deleteDbSqlFile = path.join(
    process.cwd(),
    "Database/DeleteDatabase.sql",
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
