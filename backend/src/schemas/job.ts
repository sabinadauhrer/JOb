import { z } from "zod";

export const jobSchema = z.object({
  id: z.string(),
  source: z.literal("bundesagentur"),
  title: z.string(),
  company: z.string().optional(),
  location: z.string().optional(),
  description: z.string().optional(),
  postedDate: z.string().optional(),
  applicationEmail: z.string().optional(),
  applicationUrl: z.string().optional(),
});

export type Job = z.infer<typeof jobSchema>;

export const jobSearchResultSchema = z.object({
  jobs: z.array(jobSchema),
  page: z.number(),
  hasMore: z.boolean(),
});

export type JobSearchResult = z.infer<typeof jobSearchResultSchema>;
