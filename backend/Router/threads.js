const express = require("express");
const router = express.Router();

router.get("/top", async (req, res) => {
  try {
    const db = req.app.locals.db;

    await db.none(req.app.locals.schema_query);

    const sqlQuery = `SELECT * from threads_info LIMIT 3`;
    const users = await db.any(sqlQuery);

    res.json(users);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.get("/count", async (req, res) => {
  try {
    const db = req.app.locals.db;

    await db.none(req.app.locals.schema_query);

    const sqlQuery = `SELECT COUNT(*) from threads_info`;
    const users = await db.any(sqlQuery);

    res.json(users);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.get("/", async (req, res) => {
  try {
    const db = req.app.locals.db;

    await db.none(req.app.locals.schema_query);

    const sqlQuery = `SELECT * from threads_info`;
    const users = await db.any(sqlQuery);

    res.json(users);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.get("/:id", async (req, res) => {
  try {
    const db = req.app.locals.db;

    await db.none(req.app.locals.schema_query);

    const id = req.params.id;
    const sqlQuery = `SELECT * from threads_info ${
      id > 0 ? "OFFSET " + 10 * id : ""
    }`;
    const users = await db.any(sqlQuery);

    res.json(users);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

module.exports = router;
