import type { Job } from "../schemas/job";

const BASE_URL = "https://www.arbeitnow.com/api/job-board-api";

interface ArbeitnowJob {
  slug: string;
  company_name?: string;
  title?: string;
  description?: string;
  url?: string;
  tags?: string[];
  location?: string;
  created_at?: number;
}

interface ArbeitnowResponse {
  data?: ArbeitnowJob[];
}

function stripHtml(html: string | undefined): string | undefined {
  if (!html) return undefined;
  return html.replace(/<[^>]*>/g, " ").replace(/\s+/g, " ").trim();
}

function matches(job: ArbeitnowJob, query: string, location: string | undefined): boolean {
  const haystack = [job.title, job.description, job.company_name, ...(job.tags ?? [])]
    .filter(Boolean)
    .join(" ")
    .toLowerCase();
  const queryMatches = query
    .toLowerCase()
    .split(/\s+/)
    .filter(Boolean)
    .every((term) => haystack.includes(term));
  if (!queryMatches) return false;
  if (location && location.trim() !== "") {
    return (job.location ?? "").toLowerCase().includes(location.toLowerCase());
  }
  return true;
}

function toJob(raw: ArbeitnowJob): Job {
  return {
    id: raw.slug,
    source: "arbeitnow",
    title: raw.title ?? "Unbekannte Position",
    company: raw.company_name,
    location: raw.location,
    description: stripHtml(raw.description),
    postedDate: raw.created_at ? new Date(raw.created_at * 1000).toISOString() : undefined,
    applicationUrl: raw.url,
  };
}

export interface SearchJobsParams {
  query: string;
  location?: string;
  page?: number;
  size?: number;
}

export async function searchJobs(
  params: SearchJobsParams,
): Promise<{ jobs: Job[]; page: number; hasMore: boolean }> {
  const page = params.page ?? 1;
  const size = params.size ?? 25;

  const response = await fetch(`${BASE_URL}?page=${page}`);
  if (!response.ok) {
    throw new Error(`Arbeitnow API request failed: ${response.status} ${response.statusText}`);
  }
  const data = (await response.json()) as ArbeitnowResponse;
  const filtered = (data.data ?? []).filter((job) => matches(job, params.query, params.location));

  return {
    jobs: filtered.slice(0, size).map(toJob),
    page,
    hasMore: filtered.length > size,
  };
}

// Arbeitnow has no per-job lookup endpoint, only paginated listings, so a
// job posted outside page 1 by the time it's opened won't resolve here.
export async function getJobDetail(slug: string): Promise<Job> {
  const response = await fetch(`${BASE_URL}?page=1`);
  if (!response.ok) {
    throw new Error(`Arbeitnow API request failed: ${response.status} ${response.statusText}`);
  }
  const data = (await response.json()) as ArbeitnowResponse;
  const found = (data.data ?? []).find((job) => job.slug === slug);
  if (!found) {
    throw new Error(`Arbeitnow job not found: ${slug}`);
  }
  return toJob(found);
}
