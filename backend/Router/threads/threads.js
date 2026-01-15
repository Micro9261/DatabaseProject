import express from "express";
import { authenticateJWT } from "../../Auth/auth.js";

const router = express.Router({ mergeParams: true });
router.use(authenticateJWT);

//routers
import routerComments from "./comments.js";
import routerLikes from "./threadLikes.js";
import routerSaves from "./threadSaves.js";

/*******************  /threads *********************/

router.get("/", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/threads GET" });
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
    res.json({ message: "/threads POST" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

/*******************  /threads/:threadId *********************/

router.get("/:threadId", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/threads/:threadId GET" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.patch("/:threadId", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/threads/:threadId PATCH" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.delete("/:threadId", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/threads/:threadId DELETE" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.use("/:threadId/likes", routerLikes);
router.use("/:threadId/saves", routerSaves);
router.use("/:threadId/comments", routerComments);
export default router;
