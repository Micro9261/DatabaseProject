import express from "express";

const router = express.Router();

/************* api/users/logout ********************/

/**
 * sent authorization header
 * return {message: "User logout!"}
 */
router.post("/", async (req, res) => {
  if (req.user === undefined) {
    return res.status(403).json({ message: "Authentication header required" });
  }
  const { login } = req.user;

  try {
    const db = req.app.locals.db;

    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);

      const sql =
        "SELECT * FROM tokens t INNER JOIN users u ON u.token_id = t.id WHERE u.login = ${login}";
      const sqlParams = { login };
      const result = await t.oneOrNone(sql, sqlParams);
      result;
      if (!result) {
        return res
          .status(403)
          .json({ message: "Authentication header required" });
      }
    });

    try {
      await db.tx(async () => {
        await db.none(req.app.locals.schema_query);

        const sql = "SELECT * FROM delete_user_token(${login})";
        const sqlParams = { login };
        const result = await db.oneOrNone(sql, sqlParams);
        const { delete_user_token } = result;
        if (!delete_user_token) {
          throw new Error("Token not found");
        }
      });
    } catch (err) {
      return res.status(403).json({ message: "Invalid credentials!" });
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
