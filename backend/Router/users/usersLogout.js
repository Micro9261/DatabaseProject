import express from "express";

const router = express.Router();

/************* /users/logout ********************/

router.post("/", async (req, res) => {
  if (req.user === undefined) {
    return res.status(401).json({ message: "Authentication header required" });
  }
  const { login } = req.user;

  try {
    const db = req.app.locals.db;
    try {
      await db.tx(async () => {
        await db.none(req.app.locals.schema_query);

        const sql = "SELECT * FROM delete_user_token(${login})";
        const sqlParams = { login };
        await db.oneOrNone(sql, sqlParams);
      });
    } catch (err) {
      console.log(err);
    }

    res
      .cookie("refresh_token", "Bearer ", {
        expires: new Date(Date.now()),
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
      })
      .json({ message: "User logout!" });
  } catch (err) {
    res.status(500).json({ error: "server error" });
  }
});

export default router;
