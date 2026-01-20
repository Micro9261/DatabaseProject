import express from "express";
import pg from "pg-promise";
import cors from "cors";
import dotenv from "dotenv";
import bodyParser from "body-parser";
import cookieParser from "cookie-parser";
import bcrypt from "bcrypt";

import { initDatabase, deleteDatabase } from "./Database/db.js";

//Routers
import usersRouter from "./Router/users/users.js";
import projectsRouter from "./Router/projects/projects.js";
import threadsRouter from "./Router/threads/threads.js";
import reportsRouter from "./Router/reports/report.js";

dotenv.config();
const app = express();
const port = process.env.PORT || 3000;

const pgp = pg();
const db = pgp({
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
});

//Database operations
const schema = process.env.SCHEMA;

const deleteDb = process.env.DELETE_DB;
const loadTestData = process.env.LOAD_TEST_DATA;

if (deleteDb) {
  await deleteDatabase(db, schema);
  await initDatabase(db, schema, loadTestData);
} else {
  await initDatabase(db, schema, loadTestData);
}

//Locals
const searchPath = `SET search_path TO ${process.env.SCHEMA}`;
app.locals.schema_query = searchPath;
app.locals.db = db;

//Express config
app.use(cookieParser());
app.use(
  cors({
    origin: ["http://localhost:5173"],
    methods: ["POST", "PUT", "GET", "OPTIONS", "HEAD", "PATCH", "DELETE"],
    credentials: true,
  }),
);
app.use(bodyParser.json());
app.use(express.urlencoded({ extended: true }));

app.use("/api/users", usersRouter);
app.use("/api/projects", projectsRouter);
app.use("/api/Threads", threadsRouter);
app.use("/api/reports", reportsRouter);

app.get("/", (req, res) => {
  res.send("Hello World from Express!");
});

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
