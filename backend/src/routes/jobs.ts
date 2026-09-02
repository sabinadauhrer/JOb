import { Router } from "express";
import { getJobDetail, searchJobs } from "../adapters/bundesagenturJobAdapter";

export const jobsRouter = Router();

jobsRouter.get("/search", async (req, res) => {
  const query = req.query["query"];
  if (typeof query !== "string" || query.trim() === "") {
    res.status(400).json({ error: "query is required" });
    return;
  }
  const location = typeof req.query["location"] === "string" ? req.query["location"] : undefined;
  const radius = req.query["radius"] ? Number(req.query["radius"]) : undefined;
  const page = req.query["page"] ? Number(req.query["page"]) : undefined;
  const size = req.query["size"] ? Number(req.query["size"]) : undefined;

  try {
    const result = await searchJobs({ query, location, radius, page, size });
    res.json(result);
  } catch (err) {
    res.status(502).json({ error: err instanceof Error ? err.message : "job search failed" });
  }
});

jobsRouter.get("/:source/:id", async (req, res) => {
  const { source, id } = req.params;
  if (source !== "bundesagentur") {
    res.status(400).json({ error: `unsupported job source: ${source}` });
    return;
  }
  try {
    const job = await getJobDetail(id);
    res.json(job);
  } catch (err) {
    res.status(502).json({ error: err instanceof Error ? err.message : "job detail lookup failed" });
  }
});
