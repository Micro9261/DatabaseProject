import express from "express";
import { intValidator } from "../../Middleware/validators.js";

const router = express.Router({ mergeParams: true });

//routers
import routerLikes from "./commentLikes.js";
import routerSaves from "./commentSaves.js";

/*******************  /threads/:threadId/comments *********************/

router.get("/", async (req, res) => {
  try {
    const authHeader = req.user;
    let login = null;
    if (authHeader) {
      login = authHeader.login;
    }
    const { threadId } = req.params;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM get_thread_comments_dfs(${threadId}, ${login})";
      const sqlParams = { threadId: Number(threadId), login };
      console.log(sqlParams);
      resDB = await t.any(sql, sqlParams);
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
    const { content } = req.body;
    if (content === undefined) {
      return res.status(500).json({ message: "invalid arguments undefind" });
    }

    const { parentId } = req.body;
    if (parentId != null && !Number.isInteger(Number(parentId))) {
      return res.status(500).json({ error: "Invalid parent_id" });
    }

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM add_thread_comment(${threadId}, ${parentId}, ${login}, ${content})";
      const sqlParams = {
        threadId: Number(threadId),
        parentId:
          parentId !== undefined && parentId !== null ? Number(parentId) : null,
        login,
        content,
      };
      console.log(sqlParams);
      resDB = await t.oneOrNone(sql, sqlParams);
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
    if (!authHeader && authHeader.role == "user") {
      return res.status(403).json({ error: "Invalid credentials" });
    }
    const { threadId } = req.params;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "UPDATE thread_comment tc SET delete_date = now() WHERE tc.thread_id = ${threadId}";
      const sqlParams = { threadId: Number(threadId) };
      console.log(sqlParams);
      resDB = await t.none(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Invalid arguments" });
  }
});

/*******************  /threads/:threadId/comments/:threadId *********************/

router.param("commentId", intValidator);

router.get("/:commentId", async (req, res) => {
  try {
    const { commentId, threadId } = req.params;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM threads_comments_info tci WHERE tci.thread_comm_id = ${commentId} and tci.thread_id = ${threadId}";
      const sqlParams = {
        commentId: Number(commentId),
        threadId: Number(threadId),
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

router.patch("/:commentId", async (req, res) => {
  try {
    const authHeader = req.user;
    if (!authHeader) {
      return res.status(403).json({ error: "Invalid credentials" });
    }
    const { threadId, commentId } = req.params;
    const { login, role } = authHeader;
    const { content } = req.body;
    if (content === undefined) {
      return res.status(500).json({ error: "Invalid arguments undefined" });
    }

    const db = req.app.locals.db;
    if (role == "user") {
      let resDB = [];
      await db.tx(async (t) => {
        t.none(req.app.locals.schema_query);
        const sql =
          "SELECT * FROM threads_comments_info tci WHERE tci.author = ${login} AND tci.thread_comm_id = ${commentId} AND tci.thread_id = ${threadId}";
        const sqlParams = {
          login,
          commentId: Number(commentId),
          threadId: Number(threadId),
        };
        resDB = await t.oneOrNone(sql, sqlParams);
        if (!resDB) {
          return res(403).json({ error: "Wrong user != project" });
        }
      });
    }

    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM modify_thread_comment(${commentId}, ${content})";
      const sqlParams = { commentId, content };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Invalid arguments" });
  }
});

router.delete("/:commentId", async (req, res) => {
  try {
    const authHeader = req.user;
    if (!authHeader) {
      return res.status(403).json({ error: "Invalid credentials" });
    }
    const { threadId, commentId } = req.params;
    const { login, role } = authHeader;

    const db = req.app.locals.db;
    if (role == "user") {
      let resDB = [];
      await db.tx(async (t) => {
        t.none(req.app.locals.schema_query);
        const sql =
          "SELECT * FROM threads_comments_info tci WHERE tci.author = ${login} AND tci.thread_comm_id = ${commentId} AND tci.thread_id = ${threadId}";
        const sqlParams = {
          login,
          commentId: Number(commentId),
          threadId: Number(threadId),
        };
        resDB = await t.oneOrNone(sql, sqlParams);
        if (!resDB) {
          return res(403).json({ error: "Wrong user != thread" });
        }
      });
    }

    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql = "SELECT * FROM delete_comment(FALSE ,${commentId})";
      const sqlParams = { commentId };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Invalid arguments" });
  }
});

router.use("/:commentId/likes", routerLikes);
router.use("/:commentId/saves", routerSaves);
export default router;
