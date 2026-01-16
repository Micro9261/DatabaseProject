import express from "express";
import rateLimit from "express-rate-limit";
import {
  checkPassword,
  accessTokenGen,
  refreshTokenGen,
} from "../../Middleware/auth.js";

const router = express.Router();

/************* /users/login ********************/

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: "Too many login attempts, please try again later",
});

router.post("/", loginLimiter, async (req, res) => {
  try {
    const { login, email, password } = req.body;

    if (
      password === undefined ||
      (email === undefined && login === undefined)
    ) {
      throw new Error("Invalid data!");
    }

    const db = req.app.locals.db;
    let resDB = null;
    try {
      await db.tx(async (t) => {
        await t.none(req.app.locals.schema_query);

        const sql = "SELECT * FROM get_login_credentials(${login}, ${email})";
        const sqlParams = {
          login: login ? login : null,
          email: email ? email : null,
        };
        console.log(sqlParams);
        resDB = await t.oneOrNone(sql, sqlParams);
      });
      const { passhash } = resDB;
      const result = await checkPassword(password, passhash);
      if (!result) {
        throw new Error("Wrong password!");
      }
    } catch (err) {
      return res.status(401).json({ messaage: "Invalid credentials" });
    }

    const loginDB = resDB.login;
    const roleDB = resDB.role;

    const tokenBody = { login: loginDB, role: roleDB };
    const accessExpire = process.env.ACCESS_EXPIRE;
    const refreshExpire = process.env.REFRESH_EXPIRE_DAYS;

    const accessToken = accessTokenGen(tokenBody, accessExpire);
    const refreshToken = refreshTokenGen(tokenBody, refreshExpire + "d");

    const expires = new Date(Date.now() + refreshExpire * 3600000 * 24);
    await db.tx(async () => {
      await db.none(req.app.locals.schema_query);

      const sql =
        "SELECT * FROM set_user_token(${login}, ${refreshToken}, ${expires})";
      const sqlParams = { login: loginDB, refreshToken, expires };
      resDB = await db.oneOrNone(sql, sqlParams);
    });

    res
      .status(201)
      .cookie("refresh_token", "Bearer " + refreshToken, {
        expires,
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
      })
      .json({
        message: "Login succesful!",
        accessToken,
      });
  } catch (error) {
    console.log(error);
    return res.status(401).json({ messaage: "Invalid credentials" });
  }
});

export default router;
