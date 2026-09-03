import "dotenv/config";
import cors from "cors";
import express from "express";
import { jobsRouter } from "./routes/jobs";
import { cvRouter } from "./routes/cv";
import { applicationsRouter } from "./routes/applications";
import { authRouter } from "./routes/auth";
import { requireAuth } from "./middleware/requireAuth";
import "./db";

const app = express();
app.use(cors());
app.use(express.json({ limit: "15mb" }));

app.get("/api/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.use("/api/auth", authRouter);
app.use("/api/jobs", jobsRouter);
app.use("/api/cv", requireAuth, cvRouter);
app.use("/api/applications", requireAuth, applicationsRouter);

const port = Number(process.env["PORT"] ?? 3000);
app.listen(port, () => {
  console.log(`jobtailor backend listening on port ${port}`);
});
