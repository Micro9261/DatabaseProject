import express from "express";
import { intValidator } from "../../Middleware/validators.js";

const router = express.Router({ mergeParams: true });

//routers
import routerLikes from "./commentLikes.js";
import routerSaves from "./commentSaves.js";

/*******************  /projects/:projectId/comments *********************/

router.get("/", async (req, res) => {
  try {
    const authHeader = req.user;
    let login = null;
    if (authHeader) {
      login = authHeader.login;
    }
    const { projectId } = req.params;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM get_project_comments_dfs(${projectId}, ${login})";
      const sqlParams = {
        projectId: Number(projectId),
        login,
      };
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
      return res.status(401).json({ error: "Invalid credentials" });
    }
    const { projectId } = req.params;
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
        "SELECT * FROM add_project_comment(${projectId}, ${parentId}, ${login}, ${content})";
      const sqlParams = {
        projectId: Number(projectId),
        parentId: parentId !== undefined ? Number(parentId) : null,
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
      return res.status(401).json({ error: "Invalid credentials" });
    }
    const { projectId } = req.params;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "UPDATE project_comment pc SET delete_date = now() WHERE pc.project_id = ${projectId}";
      const sqlParams = { projectId: Number(projectId) };
      console.log(sqlParams);
      resDB = await t.none(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Invalid arguments" });
  }
});

/*******************  /projects/:projectId/comments/:projectId *********************/

router.param("commentId", intValidator);

router.get("/:commentId", async (req, res) => {
  try {
    const { commentId, projectId } = req.params;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM projects_comments_info pci WHERE pci.project_comm_id = ${commentId} AND pci.project_id = ${projectId}";
      const sqlParams = {
        commentId: Number(commentId),
        projectId: Number(projectId),
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
      return res.status(401).json({ error: "Invalid credentials" });
    }
    const { projectId, commentId } = req.params;
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
          "SELECT * FROM projects_comments_info pci WHERE pci.author = ${login} AND pci.project_id = ${projectId} AND pci.comm_id = ${commentId}";
        const sqlParams = {
          login,
          projectId: Number(projectId),
          commentId: Number(commentId),
        };
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
      const sql =
        "SELECT * FROM modify_project_comment(${commentId}, ${content})";
      const sqlParams = { commentId: Number(commentId), content };
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
      return res.status(401).json({ error: "Invalid credentials" });
    }
    const { projectId, commentId } = req.params;
    const { login, role } = authHeader;

    if (role == "user") {
      let resDB = [];
      await db.tx(async (t) => {
        t.none(req.app.locals.schema_query);
        const sql =
          "SELECT * FROM projects_comments_info pci WHERE pci.author = ${login} AND pci.project_id = ${projectId} AND pci.comm_id = ${commentId}";
        const sqlParams = {
          login,
          projectId: Number(projectId),
          commentId: Number(commentId),
        };
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
      const sql = "SELECT * FROM delete_comment(TRUE, ${commentId})";
      const sqlParams = { commentId: Number(commentId) };
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
