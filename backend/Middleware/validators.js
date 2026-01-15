export const intValidator = (req, res, next, value) => {
  //   console.log("check param: " + value);
  if (!Number.isInteger(Number(value))) {
    return res.status(400).json({ error: "Invalid param" });
  }
  next();
};
