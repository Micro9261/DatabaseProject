import express from "express";
import pgp from "pg-promise";
import { authenticateJWT, createPasshash } from "../../Middleware/auth.js";

const router = express.Router({ mergeParams: true });

//routers
import routerLogin from "./usersLogin.js";
import routerLogout from "./usersLogout.js";
import routerRefresh from "./usersRefreshToken.js";
import routerBlock from "./usersBlock.js";

router.use("/login", routerLogin);
router.use("/refresh", routerRefresh);

/************* /user ********************/
router.use(authenticateJWT);

router.post("/", async (req, res) => {
  const body = req.body;
  if (!body) {
    return res.status(500).json({ error: "data required!" });
  }

  try {
    console.log(req.user);
    console.log(req.params);
    console.log(req.body);
    console.log(req.query);

    const { name, surname, login, email, password, gender } = body;
    const passHash = createPasshash(password);
    let role = "user";

    const authHeader = req.user;
    if (authHeader && authHeader.role != "user") {
      role = body.role ? body.role : "user";
    }

    try {
      const db = req.app.locals.db;
      let resDB = [];
      await db.tx(async (t) => {
        t.none(req.app.locals.schema_query);
        const sql =
          "SELECT * FROM user_create(${name}, ${surname}, ${login}, ${email}, ${gender}, ${role}, ${passHash})";
        const sqlParams = {
          name,
          surname,
          login,
          email,
          gender,
          role,
          passHash: await passHash,
        };
        console.log(sqlParams);
        resDB = await t.one(sql, sqlParams);
      });
      res.status(201).json(resDB);
    } catch (err) {
      return res.status(500).json({ error: "Database error" });
    }
  } catch (err) {
    res.status(500).json({ error: "data required!" });
  }
});

router.get("/", async (req, res) => {
  try {
    const userAuth = req.user;
    if (!userAuth) {
      return res.status(403).json({ message: "Invalid credentials" });
    }

    const { login, role } = userAuth;

    try {
      const db = req.app.locals.db;
      let resDB = [];
      if (role == "user") {
        await db.tx(async (t) => {
          t.none(req.app.locals.schema_query);
          const sql = "SELECT * FROM users_info ui WHERE ui.login = ${login}";
          const sqlParams = { login };
          console.log(sqlParams);
          resDB = await t.one(sql, sqlParams);
        });
      } else if (role == "admin" || role == "moderator") {
        const { from, to, top, order, projects } = req.query;
        switch (true) {
          case from !== undefined &&
            to !== undefined &&
            Number.isInteger(Number(from)) &&
            Number.isInteger(Number(to)):
            console.log("to, from select");
            const limit = to - from + 1;
            if (limit < 0) {
              break;
            }
            await db.tx(async (t) => {
              t.none(req.app.locals.schema_query);
              const sql =
                "SELECT * FROM top_users tu ORDER BY tu.score OFFSET ${from} LIMIT ${limit}";
              const sqlParams = { from, limit };
              console.log(sqlParams);
              resDB = await t.any(sql, sqlParams);
            });
            break;
          case top !== undefined &&
            order !== undefined &&
            Number.isInteger(Number(top)) &&
            ["asc", "desc"].includes(order.toLowerCase()):
            await db.tx(async (t) => {
              t.none(req.app.locals.schema_query);
              const sql = `SELECT * FROM top_users tu ORDER BY tu.score ${order} LIMIT ${top}`;
              // const sqlParams = { top: Number(top) };
              // resDB = await t.any(sql, sqlParams);
              resDB = await t.any(sql);
            });
            console.log("top, order logic");
            break;

          case projects !== undefined && Number.isInteger(Number(projects)):
            await db.tx(async (t) => {
              t.none(req.app.locals.schema_query);
              const sql = `SELECT 
                        u.login, 
                        COUNT(DISTINCT p.id) AS total_projects,
                        SUM( (SELECT COUNT(*) FROM relation_project_like rpl WHERE rpl.project_id = p.id) ) AS total_likes_received
                        FROM users u
                        JOIN projects p ON u.id = p.author_id
                        WHERE p.delete_date IS NULL
                        GROUP BY u.id, u.login
                        HAVING COUNT(DISTINCT p.id) >= ${Number(projects)}`;
              resDB = await t.any(sql);
            });
            console.log("projects logic");
            break;

          case top !== undefined ||
            order !== undefined ||
            from != undefined ||
            to != undefined:
            return res.status(500).json({ message: "bad request" });

          default:
            await db.tx(async (t) => {
              t.none(req.app.locals.schema_query);
              const sql =
                "SELECT * FROM top_users tu ORDER BY tu.score LIMIT 100";
              const sqlParams = { top, order };
              console.log(sqlParams);
              resDB = await t.any(sql, sqlParams);
            });
            console.log("default");
        }
      } else {
        return res.status(403).json({ message: "invalid credentials" });
      }
      res.status(201).json(resDB);
    } catch (err) {
      console.log(err);
    }
  } catch (err) {
    res.status(500).json({ error: "Database error" });
  }
});

router.use("/logout", routerLogout);

/************* /users/:login ********************/

router.get("/:loginP", async (req, res) => {
  try {
    const authHeader = req.user;
    if (!authHeader) {
      return res.status(403).json({ error: "Invalid credentials" });
    }

    const { role } = authHeader;
    let login = authHeader.login;
    if (role == "user" && login == loginP) {
      let resDB = [];
      await db.tx(async (t) => {
        t.none(req.app.locals.schema_query);
        const sql = "SELECT * FROM users_info ui WHERE ui.login = ${login}";
        const sqlParams = { login };
        resDB = await t.oneOrNone(sql, sqlParams);
        if (!resDB) {
          return res(403).json({ error: "Wrong user!" });
        }
      });
    } else {
      login = body.login ? body.login : null;
    }

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql = "SELECT * FROM get_user_data(${login})";
      const sqlParams = { login };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    // console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.patch("/:loginP", async (req, res) => {
  try {
    const authHeader = req.user;
    if (!authHeader) {
      return res.status(403).json({ error: "Invalid credentials" });
    }

    const body = req.body;
    if (!body) {
      return res.status(403).json("Not body provided");
    }

    const { loginP } = req.params;
    const { role } = authHeader;
    let login = authHeader.login;
    let new_role = null;
    if (role == "user" && login == loginP) {
      let resDB = [];
      await db.tx(async (t) => {
        t.none(req.app.locals.schema_query);
        const sql = "SELECT * FROM users_info ui WHERE ui.login = ${login}";
        const sqlParams = { login };
        resDB = await t.oneOrNone(sql, sqlParams);
        if (!resDB) {
          return res(403).json({ error: "Wrong user!" });
        }
      });
    } else {
      new_role = body.role ? body.role : null;
      login = body.oldLogin ? body.oldLogin : null;
    }
    const new_login = body.login ? body.login : null;
    const new_email = body.email ? body.email : null;
    const new_name = body.name ? body.name : null;
    const new_surname = body.surname ? body.surname : null;
    const new_gender = body.gender ? body.gender : null;
    let new_password = body.password ? body.password : null;
    if (new_password !== null) {
      new_password = await createPasshash(new_password);
    }

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql =
        "SELECT * FROM modify_user(${login}, ${new_login}, ${new_email}, ${new_password}, ${new_name}, ${new_surname}, ${new_gender}, ${new_role})";
      const sqlParams = {
        login,
        new_login,
        new_email,
        new_password,
        new_name,
        new_surname,
        new_gender,
        new_role,
      };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Invalid arguments" });
  }
});

router.delete("/:loginP", async (req, res) => {
  try {
    const authHeader = req.user;
    if (!authHeader) {
      return res.status(403).json({ error: "Invalid credentials" });
    }

    const { role } = authHeader;
    let login = authHeader.login;
    if (role == "user" && login == loginP) {
      let resDB = [];
      await db.tx(async (t) => {
        t.none(req.app.locals.schema_query);
        const sql = "SELECT * FROM users_info ui WHERE ui.login = ${login}";
        const sqlParams = { login };
        resDB = await t.oneOrNone(sql, sqlParams);
        if (!resDB) {
          return res(403).json({ error: "Wrong user!" });
        }
      });
    } else {
      const body = req.body;
      login = body.login ? body.login : null;
    }

    const db = req.app.locals.db;
    let resDB = [];
    await db.tx(async (t) => {
      t.none(req.app.locals.schema_query);
      const sql = "SELECT * FROM delete_user(${login})";
      const sqlParams = { login };
      console.log(sqlParams);
      resDB = await t.one(sql, sqlParams);
    });

    res.status(200).json(resDB);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Database error" });
  }
});

router.use("/:loginP/block", routerBlock);
export default router;
