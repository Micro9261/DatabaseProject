import express from "express";
import { accessTokenGen, verifyRefreshToken } from "../../Middleware/auth.js";

const router = express.Router();

/************* /users/refresh-token ********************/

router.post("/", async (req, res) => {
  const cookies = req.cookies;
  if (!cookies.refresh_token) {
    return res.status(403).json({ message: "Refresh token required" });
  }
  const { refresh_token } = cookies;
  const refreshToken = refresh_token.split(" ")[1];

  try {
    const db = req.app.locals.db;
    const { login, role } = verifyRefreshToken(refreshToken);
    let dbRefreshToken = null;
    try {
      await db.tx(async () => {
        await db.none(req.app.locals.schema_query);

        const sql = "SELECT * FROM get_user_token(${login})";
        const sqlParams = { login };
        dbRefreshToken = await db.oneOrNone(sql, sqlParams);
      });
    } catch (err) {
      console.log(err);
      return res
        .status(403)
        .json({ error: "Invalid or expired refresh token" });
    }
    const expire_time = dbRefreshToken.expire_time;
    const token = dbRefreshToken.token;
    const dateNow = new Date(Date.now());

    if (dateNow < expire_time && token == refreshToken) {
      const accessToken = accessTokenGen({ login, role }, "15m");

      res.json({
        message: "Token refreshed",
        accessToken,
      });
    } else {
      await db.tx(async () => {
        await db.none(req.app.locals.schema_query);

        const sql = "SELECT * FROM delete_user_token(${login})";
        const sqlParams = { login };
        await db.oneOrNone(sql, sqlParams);
      });
      res.status(500).json({ error: "Invalid or expired refresh token" });
    }
  } catch (err) {
    res.status(500).json({ error: "Invalid or expired refresh token" });
  }
});

export default router;
