import express from "express";
import bcrypt from "bcrypt";
import pg from "pg-promise";
import jwt from "jsonwebtoken";
import cors from "cors";
import dotenv from "dotenv";

import { initDatabase, deleteDatabase } from "./Database/db.js";

//Routers
import userRouter from "./Router/user.js";
import projectRouter from "./Router/project.js";
import projectsRouter from "./Router/projects.js";
import threadRouter from "./Router/thread.js";
import threadsRouter from "./Router/threads.js";

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
app.locals.jwt = jwt;
app.locals.bcrypt = bcrypt;

//Express config
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/api/User", userRouter);
app.use("/api/Project", projectRouter);
app.use("/api/Projects", projectsRouter);
app.use("/api/Thread", threadRouter);
app.use("/api/Threads", threadsRouter);

app.get("/", (req, res) => {
  res.send("Hello World from Express!");
});

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
