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
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/projects GET" });
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
    res.json({ message: "/projects POST" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

/*******************  /projects/:projectId *********************/

router.param("projectId", intValidator);

router.get("/:projectId", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/projects/:projectId GET" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.patch("/:projectId", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/projects/:projectId PATCH" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.delete("/:projectId", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/projects/:projectId DELETE" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.use("/:projectId/likes", routerLikes);
router.use("/:projectId/saves", routerSaves);
router.use("/:projectId/comments", routerComments);
export default router;
