import { Router } from "express";
import * as bundesagentur from "../adapters/bundesagenturJobAdapter";
import * as arbeitnow from "../adapters/arbeitnowJobAdapter";
import type { Job } from "../schemas/job";

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

  const results = await Promise.allSettled([
    bundesagentur.searchJobs({ query, location, radius, page, size }),
    arbeitnow.searchJobs({ query, location, page, size }),
  ]);

  const jobs: Job[] = [];
  let hasMore = false;
  for (const result of results) {
    if (result.status === "fulfilled") {
      jobs.push(...result.value.jobs);
      hasMore = hasMore || result.value.hasMore;
    }
  }

  if (jobs.length === 0 && results.every((r) => r.status === "rejected")) {
    res.status(502).json({ error: "job search failed for all sources" });
    return;
  }

  res.json({ jobs, page: page ?? 1, hasMore });
});

jobsRouter.get("/:source/:id", async (req, res) => {
  const { source, id } = req.params;
  try {
    if (source === "bundesagentur") {
      res.json(await bundesagentur.getJobDetail(id));
      return;
    }
    if (source === "arbeitnow") {
      res.json(await arbeitnow.getJobDetail(id));
      return;
    }
    res.status(400).json({ error: `unsupported job source: ${source}` });
  } catch (err) {
    res.status(502).json({ error: err instanceof Error ? err.message : "job detail lookup failed" });
  }
});
