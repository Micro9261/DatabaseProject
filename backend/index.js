const express = require("express");
// const bcrypt = require("bcrypt");
const pg = require("pg");
// const jwt = require("jsonwebtoken");
const dotenv = require("dotenv");

dotenv.config();
const app = express();
const port = process.env.PORT || 3000;

const pool = new pg.Pool({
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.send("Hello World from Express!");
});

app.post("/register", async (req, res) => {
  try {
    const { id, username } = req.body;
    console.log(`received id: ${id}, username: ${username}`);
    const result_path = await pool.query("SET search_path  TO project");
    const result = await pool.query(
      "INSERT INTO users (name) VALUES ($1) RETURNING *",
      [username]
    );
    // console.log(result);

    // const result_id = await pool.query(
    //   "SELECT * FROM users WHERE name = ($1)",
    //   [username]
    // );

    // console.log(result_id);
    console.log(`return id: ${result.rows[0].user_id}`);

    res.status(201).json({ id: result.rows[0].user_id });
  } catch (error) {
    console.error(error.message);
    res.status(500).send("Server Error");
  }
});

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
