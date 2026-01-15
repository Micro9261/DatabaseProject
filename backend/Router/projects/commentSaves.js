import express from "express";

const router = express.Router({ mergeParams: true });

/*******************  /projects/:projectId/comments/:projectId/saves *********************/

router.get("/", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/projects/:projectId/comments/:commentId/saves GET" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.post("/", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({
      message: "/projects/:projectId/comments/:commentId/saves POST",
    });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.delete("/", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({
      message: "/projects/:projectId/comments/:commentId/saves DELETE",
    });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

export default router;
