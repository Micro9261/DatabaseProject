import express from "express";
import { authenticateJWT } from "../../Middleware/auth.js";
import { intValidator } from "../../Middleware/validators.js";

const router = express.Router({ mergeParams: true });
router.use(authenticateJWT);

//routers
import routerComments from "./comments.js";
import routerLikes from "./threadLikes.js";
import routerSaves from "./threadSaves.js";
import routerViews from "./threadViews.js";

/*******************  /threads *********************/

router.get("/", async (req, res) => {
  try {
    const { from, to, top, order } = req.query;

    const db = req.app.locals.db;
    let resDB = [];
    switch (true) {
      case from !== undefined &&
        to !== undefined &&
        Number.isInteger(Number(from)) &&
        Number.isInteger(Number(to)):
        console.log("to, from select");
        const limit = to - from + 1;
        if (limit < 0) {
          break;
        }
        await db.tx(async (t) => {
          t.none(req.app.locals.schema_query);
          const sql =
            "SELECT * FROM top_threads tt ORDER BY tt.score OFFSET ${from} LIMIT ${limit}";
          const sqlParams = { from, limit };
          console.log(sqlParams);
          resDB = await t.any(sql, sqlParams);
        });
        break;
      case top !== undefined &&
        order !== undefined &&
        Number.isInteger(Number(top)) &&
        ["asc", "desc"].includes(order.toLowerCase()):
        await db.tx(async (t) => {
          t.none(req.app.locals.schema_query);
          const sql = `SELECT * FROM threads_info tt ORDER BY tt.score ${order} LIMIT ${top}`;
          const sqlParams = { top: Number(top) };
          resDB = await t.any(sql, sqlParams);
        });
        console.log("top, order logic");
        break;
      case top !== undefined ||
        order !== undefined ||
        from != undefined ||
        to != undefined:
        return res.status(500).json({ message: "bad request" });
      default:
        await db.tx(async (t) => {
          t.none(req.app.locals.schema_query);
          const sql =
            "SELECT * FROM threads_info tt ORDER BY tt.create_date LIMIT 100";
          const sqlParams = { top, order };
          resDB = await t.any(sql, sqlParams);
        });
        console.log("default");
    }
    res.status(201).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.post("/", async (req, res) => {
  try {
    const authHeader = req.user;
    if (!authHeader) {
      return res.status(403).json({ error: "Invalid credentials" });
    }
    const { login } = authHeader;
    const { title, content } = req.body;
    if (title === undefined || content === undefined) {
      return res.status(500).json({ message: "invalid arguments undefind" });
    }

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql = "SELECT * FROM add_thread(${title}, ${login}, ${content})";
      const sqlParams = { title, login, content };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Invalid arguments" });
  }
});

/*******************  /threads/:threadId *********************/

router.param("threadId", intValidator);

router.get("/:threadId", async (req, res) => {
  try {
    const { threadId } = req.params;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM threads_info pi WHERE pi.thread_id = ${threadId}";
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

router.patch("/:threadId", async (req, res) => {
  try {
    const authHeader = req.user;
    if (!authHeader) {
      return res.status(403).json({ error: "Invalid credentials" });
    }
    const { threadId } = req.params;
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
          "SELECT * FROM threads_info pi WHERE pi.author = ${login} AND pi.thread_id = ${threadId}";
        const sqlParams = { login, threadId: Number(threadId) };
        resDB = await t.oneOrNone(sql, sqlParams);
        if (!resDB) {
          return res(403).json({ error: "Wrong user != project" });
        }
      });
    }

    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql = "SELECT * FROM modify_thread(${threadId}, ${content})";
      const sqlParams = { threadId: Number(threadId), content };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Invalid arguments" });
  }
});

router.delete("/:threadId", async (req, res) => {
  try {
    const authHeader = req.user;
    if (!authHeader) {
      return res.status(403).json({ error: "Invalid credentials" });
    }
    const { threadId } = req.params;
    const { login, role } = authHeader;

    const db = req.app.locals.db;
    if (role == "user") {
      let resDB = [];
      await db.tx(async (t) => {
        t.none(req.app.locals.schema_query);
        const sql =
          "SELECT * FROM threads_info pi WHERE pi.author = ${login} AND pi.thread_id = ${threadId}";
        const sqlParams = { login, threadId: Number(threadId) };
        resDB = await t.oneOrNone(sql, sqlParams);
        if (!resDB) {
          return res(403).json({ error: "Wrong user != project" });
        }
      });
    }

    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql = "SELECT * FROM delete_thread(${threadId})";
      const sqlParams = { threadId: Number(threadId) };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Invalid arguments" });
  }
});

router.use("/:threadId/views", routerViews);
router.use("/:threadId/likes", routerLikes);
router.use("/:threadId/saves", routerSaves);
router.use("/:threadId/comments", routerComments);
export default router;
