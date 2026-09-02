import "dotenv/config";
import cors from "cors";
import express from "express";
import { jobsRouter } from "./routes/jobs";
import { cvRouter } from "./routes/cv";

const app = express();
app.use(cors());
app.use(express.json({ limit: "15mb" }));

app.get("/api/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.use("/api/jobs", jobsRouter);
app.use("/api/cv", cvRouter);

const port = Number(process.env["PORT"] ?? 3000);
app.listen(port, () => {
  console.log(`jobtailor backend listening on port ${port}`);
});
