const express = require("express");
const bcrypt = require("bcrypt");
const pg = require("pg-promise");
const jwt = require("jsonwebtoken");
const cors = require("cors");
const dotenv = require("dotenv");

//Routers
const userRouter = require("./Router/user");
const projectRouter = require("./Router/project");
const projectsRouter = require("./Router/projects");
const threadRouter = require("./Router/thread");
const threadsRouter = require("./Router/threads");

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

//Locals
app.locals.schema_query = `SET search_path TO ${process.env.SCHEMA}`;
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

// app.post("/register", async (req, res) => {
//   try {
//     const { id, username } = req.body;
//     console.log(`received id: ${id}, username: ${username}`);
//     const result_path = await pool.query("SET search_path  TO project");
//     const result = await pool.query(
//       "INSERT INTO users (name) VALUES ($1) RETURNING *",
//       [username]
//     );
//     // console.log(result);

//     // const result_id = await pool.query(
//     //   "SELECT * FROM users WHERE name = ($1)",
//     //   [username]
//     // );

//     // console.log(result_id);
//     console.log(`return id: ${result.rows[0].user_id}`);

//     res.status(201).json({ id: result.rows[0].user_id });
//   } catch (error) {
//     console.error(error.message);
//     res.status(500).send("Server Error");
//   }
// });
