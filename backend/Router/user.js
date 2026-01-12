const express = require("express");
const router = express.Router();

router.get("/", async (req, res) => {
  try {
    const db = req.app.locals.db;

    await db.none(req.app.locals.schema_query);
    const users = await db.any("SELECT * from users");

    res.json(users);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.post("/", async (req, res) => {
  try {
    const db = req.app.locals.db;
    const { name, surname, nickname, email, gender, role, pass_hash } =
      req.body;

    await db.none(req.app.locals.schema_query);
    const user = await db.one(
      "SELECT * FROM register_user(${name}, ${surname}, ${nickname}, ${email}, ${gender}, ${role}, ${pass_hash})",
      {
        name,
        surname,
        nickname,
        email,
        gender,
        role,
        pass_hash,
      }
    );
    res.json(user);
  } catch (err) {
    //Postgres error
    console.log("PG ERROR");
    console.log(err.code);
    console.log(err.query);
    res.status(500).json({ error: "Database error" });
  }
});

module.exports = router;
