import express from "express";

const router = express.Router({ mergeParams: true });

/*******************  /threads/:threadId/comments/:threadId/likes *********************/

router.get("/", async (req, res) => {
  try {
    const { threadId, commentId } = req.params;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT likes FROM threads_comments_info tci WHERE tci.thread_id = ${threadId} AND tci.thread_comm_id = ${commentId}";
      const sqlParams = {
        threadId: Number(threadId),
        commentId: Number(commentId),
      };
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
    const { commentId, threadId } = req.params;
    const { login } = authHeader;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM add_like(${login}, NULL, ${threadId} , ${commentId})";
      const sqlParams = {
        login,
        threadId: Number(threadId),
        commentId: Number(commentId),
      };
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
    const { commentId, threadId } = req.params;
    const { login } = authHeader;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM delete_like(${login}, NULL, ${threadId} , ${commentId})";
      const sqlParams = {
        login,
        threadId: Number(threadId),
        commentId: Number(commentId),
      };
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
