import express from "express";

const router = express.Router({ mergeParams: true });

/*******************  /api/projects/:projectId/comments/:commentId/likes *********************/

router.get("/", async (req, res) => {
  try {
    const { projectId, commentId } = req.params;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT likes FROM projects_comments_info pci WHERE pci.project_id = ${projectId} AND pci.project_comm_id = ${commentId}";
      const sqlParams = {
        projectId: Number(projectId),
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
    const { commentId, projectId } = req.params;
    const { login } = authHeader;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM add_like(${login}, ${projectId}, NULL , ${commentId})";
      const sqlParams = {
        login,
        projectId: Number(projectId),
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
    const { commentId, projectId } = req.params;
    const { login } = authHeader;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM delete_like(${login}, ${projectId}, NULL , ${commentId})";
      const sqlParams = {
        login,
        projectId: Number(projectId),
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
