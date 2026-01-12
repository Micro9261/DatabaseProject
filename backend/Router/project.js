const express = require("express");
const router = express.Router();

//******************************** GET ***********************/

router.get("/comment/:project_id", async (req, res) => {
  try {
    const db = req.app.locals.db;

    await db.none(req.app.locals.schema_query);
    const sqlQuery = "SELECT * from get_project_comments(${project_id})";
    const sqlParams = {
      project_id: req.params.project_id,
    };
    const project_comments = await db.any(sqlQuery, sqlParams);

    res.json(project_comments);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.get("/:project_id", async (req, res) => {
  try {
    const db = req.app.locals.db;

    await db.none(req.app.locals.schema_query);
    const sqlQuery =
      "SELECT * FROM projects_info pi WHERE pi.project_id = ${project_id}";
    const sqlParams = {
      project_id: req.params.project_id,
    };
    const project = await db.any(sqlQuery, sqlParams);

    res.json(project);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

//******************************** POST ***********************/

router.post("/", async (req, res) => {
  try {
    const db = req.app.locals.db;
    const { title, author, content } = req.body;

    await db.none(req.app.locals.schema_query);
    const sqlQuery =
      "SELECT * FROM add_project(${title}, ${author}, ${content})";
    const sqlParams = {
      title,
      author,
      content,
    };
    const project = await db.any(sqlQuery, sqlParams);
    console.log(project);

    res.json(project);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

module.exports = router;
