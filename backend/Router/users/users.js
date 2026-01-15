import express from "express";
import { authenticateJWT } from "../../Auth/auth.js";

const router = express.Router({ mergeParams: true });

//routers
import routerLogin from "./usersLogin.js";
import routerLogout from "./usersLogout.js";
import routerRefresh from "./usersRefreshToken.js";
import routerBlock from "./usersBlock.js";

router.use("/login", routerLogin);
router.use("/refreshToken", routerRefresh);

/************* /user ********************/

router.post("/", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/user POST" });
  } catch (err) {
    res.status(500).json({ error: "Database error" });
  }
});

//Authorization check from here
router.use(authenticateJWT);

router.get("/", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/user GET" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.use("/logout", routerLogout);

/************* /users/:login ********************/

router.get("/:login", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/users/:login GET" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.post("/:login", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/users/:login POST" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.patch("/:login", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/users/:login PATCH" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.delete("/:login", async (req, res) => {
  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);
    res.json({ message: "/users/:login DELETE" });
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.use("/:login/block", routerBlock);
export default router;
