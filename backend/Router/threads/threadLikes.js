import express from "express";

const router = express.Router({ mergeParams: true });

/******************* /api/threads/:threadId/likes *********************/

router.get("/", async (req, res) => {
  try {
    const { threadId } = req.params;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT likes FROM threads_info pi WHERE pi.thread_id = ${threadId}";
      const sqlParams = { threadId: Number(threadId) };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Database error" });
  }
});

router.post("/", async (req, res) => {
  try {
    const authHeader = req.user;
    if (!authHeader) {
      return res.status(403).json({ error: "Invalid credentials" });
    }
    const { threadId } = req.params;
    const { login } = authHeader;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql = "SELECT * FROM add_like(${login}, NULL, ${threadId}, NULL)";
      const sqlParams = { login, threadId: Number(threadId) };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Invalid arguments" });
  }
});

router.delete("/", async (req, res) => {
  try {
    const authHeader = req.user;
    if (!authHeader) {
      return res.status(403).json({ error: "Invalid credentials" });
    }
    const { threadId } = req.params;
    const { login } = authHeader;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM delete_like(${login}, NULL, ${threadId}, NULL)";
      const sqlParams = { login, threadId: Number(threadId) };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Invalid arguments" });
  }
});

export default router;
