import express from "express";
import { authenticateJWT } from "../../Middleware/auth.js";
import { intValidator } from "../../Middleware/validators.js";

const router = express.Router({ mergeParams: true });
router.use(authenticateJWT);

//routers
import routerComments from "./comments.js";
import routerLikes from "./projectLikes.js";
import routerSaves from "./projectSaves.js";

/*******************  /projects *********************/

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
            "SELECT * FROM top_projects tp ORDER BY tp.score OFFSET ${from} LIMIT ${limit}";
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
          const sql = `SELECT * FROM top_projects tp ORDER BY tp.score ${order} LIMIT ${top}`;
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
            "SELECT * FROM top_projects tp ORDER BY tp.score LIMIT 100";
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
      return res.status(401).json({ error: "Invalid credentials" });
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
      const sql = "SELECT * FROM add_project(${title}, ${login}, ${content})";
      const sqlParams = { title, login, content };
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Invalid arguments" });
  }
});

/*******************  /projects/:projectId *********************/

router.param("projectId", intValidator);

router.get("/:projectId", async (req, res) => {
  try {
    const { projectId } = req.params;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM projects_info pi WHERE pi.project_id = ${projectId}";
      const sqlParams = { projectId: Number(projectId) };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Database error" });
  }
});

router.patch("/:projectId", async (req, res) => {
  try {
    const authHeader = req.user;
    if (!authHeader) {
      return res.status(401).json({ error: "Invalid credentials" });
    }
    const { projectId } = req.params;
    const { login, role } = authHeader;
    const { content } = req.body;
    if (content === undefined) {
      return res.status(500).json({ error: "Invalid arguments undefined" });
    }

    if (role == "user") {
      let resDB = [];
      await db.tx(async (t) => {
        t.none(req.app.locals.schema_query);
        const sql =
          "SELECT * FROM projects_info pi WHERE pi.author = ${login} AND pi.project_id = ${projectId}";
        const sqlParams = { login, projectId: Number(projectId) };
        resDB = await t.oneOrNone(sql, sqlParams);
        if (!resDB) {
          return res(401).json({ error: "Wrong user != project" });
        }
      });
    }

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql = "SELECT * FROM modify_project(${projectId}, ${content})";
      const sqlParams = { projectId: Number(projectId), content };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Invalid arguments" });
  }
});

router.delete("/:projectId", async (req, res) => {
  try {
    const authHeader = req.user;
    if (!authHeader) {
      return res.status(401).json({ error: "Invalid credentials" });
    }
    const { projectId } = req.params;
    const { login, role } = authHeader;

    if (role == "user") {
      let resDB = [];
      await db.tx(async (t) => {
        t.none(req.app.locals.schema_query);
        const sql =
          "SELECT * FROM projects_info pi WHERE pi.author = ${login} AND pi.project_id = ${projectId}";
        const sqlParams = { login, projectId: Number(projectId) };
        resDB = await t.oneOrNone(sql, sqlParams);
        if (!resDB) {
          return res(401).json({ error: "Wrong user != project" });
        }
      });
    }

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql = "SELECT * FROM delete_project(${projectId})";
      const sqlParams = { projectId: Number(projectId) };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Invalid arguments" });
  }
});

router.use("/:projectId/likes", routerLikes);
router.use("/:projectId/saves", routerSaves);
router.use("/:projectId/comments", routerComments);
export default router;
