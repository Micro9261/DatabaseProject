import express from "express";

const router = express.Router({ mergeParams: true });

/*******************  /api//projects/:projectId/views *********************/

router.get("/", async (req, res) => {
  try {
    const { projectId } = req.params;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT views FROM projects_info pi WHERE pi.project_id = ${projectId}";
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

router.post("/", async (req, res) => {
  try {
    const { projectId } = req.params;

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql = "SELECT * FROM add_view(${projectId}, NULL)";
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

export default router;
