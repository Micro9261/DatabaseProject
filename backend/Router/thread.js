import express from "express";
const router = express.Router();

//******************************** GET ***********************/

router.get("/comment/:thread_id", async (req, res) => {
  try {
    const db = req.app.locals.db;

    await db.none(req.app.locals.schema_query);
    const sqlQuery = "SELECT * from get_thread_comments(${thread_id})";
    const sqlParams = {
      thread_id: req.params.thread_id,
    };
    const thread_comments = await db.any(sqlQuery, sqlParams);

    res.json(thread_comments);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.get("/:thread_id", async (req, res) => {
  try {
    const db = req.app.locals.db;

    await db.none(req.app.locals.schema_query);
    const sqlQuery =
      "SELECT * FROM threads_info pi WHERE pi.thread_id = ${thread_id}";
    const sqlParams = {
      thread_id: req.params.thread_id,
    };
    const thread = await db.any(sqlQuery, sqlParams);

    // if (thread.length === 0) {
    //   res.status(500).json({ error: "Not exists!" });
    // } else {
    res.json(thread);
    // }
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

//******************************** POST ***********************/

router.get("/comment/", async (req, res) => {
  try {
    const db = req.app.locals.db;

    await db.none(req.app.locals.schema_query);
    const sqlQuery =
      "SELECT * FROM add_thread_comment(${title}, ${author}, ${content})";
    const sqlParams = {
      title,
      author,
      content,
    };
    const thread_comments = await db.any(sqlQuery, sqlParams);

    res.json(thread_comments);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.post("/", async (req, res) => {
  try {
    const db = req.app.locals.db;
    const { title, author, content } = req.body;

    await db.none(req.app.locals.schema_query);
    const sqlQuery =
      "SELECT * FROM add_thread(${title}, ${author}, ${content})";
    const sqlParams = {
      title,
      author,
      content,
    };
    const thread = await db.any(sqlQuery, sqlParams);
    console.log(thread);

    res.json(thread);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

/****************************** DELETE *************************************/

export default router;
