import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

export const authenticateJWT = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return next();
  }

  const token = authHeader.split(" ")[1];
  if (!token) {
    return next();
  }

  try {
    const payload = verifyAccessToken(token);
    req.user = payload;
    console.log("Authorized!");
  } catch (error) {
    console.log("Not Authorized!");
  }
  next();
};

export const accessTokenGen = (data, expireTime) => {
  const token = jwt.sign(data, process.env.JWT_SECRET, {
    expiresIn: expireTime,
  });

  console.log(token);

  return token;
};

export const refreshTokenGen = (data, expireTime) => {
  const token = jwt.sign(data, process.env.JWT_REFRESH_SECRET, {
    expiresIn: expireTime,
  });

  console.log(token);

  return token;
};

export const verifyAccessToken = (token) => {
  const result = jwt.verify(token, process.env.JWT_SECRET);
  // console.log(result);
  return result;
};

export const verifyRefreshToken = (token) => {
  const result = jwt.verify(token, process.env.JWT_REFRESH_SECRET);
  // console.log(result);
  return result;
};

export const createPasshash = async (password) => {
  const salt = Number(process.env.SALT);
  const passHash = await bcrypt.hash(password, salt);
  return passHash;
  // return "1234";
};

export const checkPassword = async (password, hash) => {
  const passHash = await bcrypt.compare(password, hash);
  return passHash;
  // return "1234";
};
