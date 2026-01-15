import express from "express";

const router = express.Router({ mergeParams: true });

/*******************  /threads/:threadId/likes *********************/

router.get("/", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/threads/:threadId/likes GET" });
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
    res.json({ message: "/threads/:threadId/likes POST" });
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
    res.json({ message: "/threads/:threadId/likes DELETE" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

export default router;
