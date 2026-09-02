import type { Job } from "../schemas/job";

const BASE_URL = "https://rest.arbeitsagentur.de/jobboerse/jobsuche-service";
const API_KEY = "jobboerse-jobsuche";

interface BaAddress {
  plz?: string;
  ort?: string;
  region?: string;
  land?: string;
}

interface BaJobLocation {
  adresse?: BaAddress;
}

interface BaJobSummary {
  referenznummer: string;
  stellenangebotsTitel?: string;
  firma?: string;
  stellenlokationen?: BaJobLocation[];
  veroeffentlichungszeitraum?: { von?: string };
  datumErsteVeroeffentlichung?: string;
  externeUrl?: string;
}

interface BaSearchResponse {
  ergebnisliste?: BaJobSummary[];
  maxErgebnisse?: number;
}

interface BaJobDetail extends BaJobSummary {
  stellenangebotsBeschreibung?: string;
}

function formatLocation(locations: BaJobLocation[] | undefined): string | undefined {
  const first = locations?.[0]?.adresse;
  if (!first) return undefined;
  return [first.ort, first.region].filter(Boolean).join(", ") || undefined;
}

function extractApplicationEmail(description: string | undefined): string | undefined {
  if (!description) return undefined;
  const match = description.match(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/);
  return match?.[0];
}

function toJob(raw: BaJobSummary, description?: string): Job {
  return {
    id: raw.referenznummer,
    source: "bundesagentur",
    title: raw.stellenangebotsTitel ?? "Unbekannte Position",
    company: raw.firma,
    location: formatLocation(raw.stellenlokationen),
    description,
    postedDate: raw.veroeffentlichungszeitraum?.von ?? raw.datumErsteVeroeffentlichung,
    applicationEmail: extractApplicationEmail(description),
    applicationUrl: raw.externeUrl,
  };
}

async function baFetch<T>(path: string): Promise<T> {
  const response = await fetch(`${BASE_URL}${path}`, {
    headers: { "X-API-Key": API_KEY },
  });
  if (!response.ok) {
    throw new Error(`Bundesagentur API request failed: ${response.status} ${response.statusText}`);
  }
  return response.json() as Promise<T>;
}

export interface SearchJobsParams {
  query: string;
  location?: string;
  radius?: number;
  page?: number;
  size?: number;
}

export async function searchJobs(params: SearchJobsParams): Promise<{ jobs: Job[]; page: number; hasMore: boolean }> {
  const page = params.page ?? 1;
  const size = params.size ?? 25;
  const searchParams = new URLSearchParams({
    was: params.query,
    page: String(page),
    size: String(size),
  });
  if (params.location) searchParams.set("wo", params.location);
  if (params.radius !== undefined) searchParams.set("umkreis", String(params.radius));

  const data = await baFetch<BaSearchResponse>(`/pc/v6/jobs?${searchParams.toString()}`);
  const results = data.ergebnisliste ?? [];
  return {
    jobs: results.map((r) => toJob(r)),
    page,
    hasMore: results.length >= size,
  };
}

export async function getJobDetail(referenznummer: string): Promise<Job> {
  const encoded = encodeURIComponent(Buffer.from(referenznummer, "utf-8").toString("base64"));
  const detail = await baFetch<BaJobDetail>(`/pc/v4/jobdetails/${encoded}`);
  return toJob(detail, detail.stellenangebotsBeschreibung);
}
