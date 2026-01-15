import express from "express";

const router = express.Router({ mergeParams: true });

/*******************  /projects/:projectId/likes *********************/

router.get("/", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    console.log(req.params.projectId);
    res.json({ message: "/projects/:projectId/likes GET" });
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
    res.json({ message: "/projects/:projectId/likes POST" });
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
    res.json({ message: "/projects/:projectId/likes DELETE" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

export default router;
