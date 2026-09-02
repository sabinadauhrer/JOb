import { Router } from "express";
import Anthropic from "@anthropic-ai/sdk";
import { z } from "zod";
import { cvProfileSchema, type CvProfileInput } from "../schemas/cvProfile";

export const cvRouter = Router();

const tailorRequestSchema = z.object({
  profile: cvProfileSchema,
  jobDescription: z.string().min(1),
  jobTitle: z.string().optional(),
  company: z.string().optional(),
});

const importRequestSchema = z.object({
  pdfBase64: z.string().min(1),
});

const IMPORT_SYSTEM_PROMPT =
  "Extrahiere aus dem beigefügten Lebenslauf (PDF) die Daten strukturiert. Antworte " +
  'ausschließlich mit einem JSON-Objekt exakt dieser Form: {"personalInfo": {"fullName": ' +
  'string, "email": string, "phone": string, "address": string, "summary": string}, ' +
  '"experience": [{"company": string, "position": string, "startDate": string, "endDate": ' +
  'string, "description": string}], "education": [{"institution": string, "degree": string, ' +
  '"startDate": string, "endDate": string}], "skills": string[]}. Erfinde keine Informationen; ' +
  'lass Felder leer ("" bzw. []), wenn sie nicht im Dokument stehen.';

function buildPrompt(
  profile: CvProfileInput,
  jobDescription: string,
  jobTitle?: string,
  company?: string,
): string {
  const { personalInfo, experience, education, skills } = profile;
  const experienceText = experience
    .map((e) => `- ${e.position} bei ${e.company} (${e.startDate} - ${e.endDate}): ${e.description}`)
    .join("\n");
  const educationText = education
    .map((e) => `- ${e.degree}, ${e.institution} (${e.startDate} - ${e.endDate})`)
    .join("\n");

  return [
    `Stelle: ${jobTitle ?? "unbekannt"}${company ? ` bei ${company}` : ""}`,
    "Stellenbeschreibung:",
    jobDescription,
    "",
    "Lebenslauf des Bewerbers:",
    `Name: ${personalInfo.fullName || "(nicht angegeben)"}`,
    `Aktuelles Kurzprofil: ${personalInfo.summary || "(keins angegeben)"}`,
    "Berufserfahrung:",
    experienceText || "(keine angegeben)",
    "Ausbildung:",
    educationText || "(keine angegeben)",
    `Skills: ${skills.join(", ") || "(keine angegeben)"}`,
    "",
    "Aufgabe: Schreibe ein neues, auf diese Stelle zugeschnittenes Kurzprofil (2-3 Sätze) " +
      "und ein kurzes, individuelles Anschreiben (max. 200 Wörter) für diese Bewerbung. " +
      "Nutze ausschließlich Informationen aus dem Lebenslauf oben, erfinde nichts hinzu.",
  ].join("\n");
}

function parseTailorResponse(text: string): { tailoredSummary: string; coverLetter: string } {
  const jsonMatch = text.match(/\{[\s\S]*\}/);
  if (!jsonMatch) {
    throw new Error("model response did not contain JSON");
  }
  const data = JSON.parse(jsonMatch[0]) as Record<string, unknown>;
  return {
    tailoredSummary: typeof data["tailoredSummary"] === "string" ? data["tailoredSummary"] : "",
    coverLetter: typeof data["coverLetter"] === "string" ? data["coverLetter"] : "",
  };
}

cvRouter.post("/tailor", async (req, res) => {
  const parsed = tailorRequestSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: "invalid request body", details: parsed.error.flatten() });
    return;
  }

  if (!process.env["ANTHROPIC_API_KEY"]) {
    res.status(503).json({ error: "CV tailoring is not configured (missing ANTHROPIC_API_KEY)" });
    return;
  }

  const { profile, jobDescription, jobTitle, company } = parsed.data;
  const client = new Anthropic();
  const prompt = buildPrompt(profile, jobDescription, jobTitle, company);

  try {
    const response = await client.messages.create({
      model: "claude-opus-5",
      max_tokens: 2000,
      system:
        "Du bist ein erfahrener Karriereberater. Du schreibst auf Deutsch, sachlich und ohne " +
        "Übertreibungen, und erfindest keine Erfahrungen oder Fähigkeiten, die nicht im Lebenslauf " +
        'stehen. Antworte ausschließlich mit einem JSON-Objekt der Form ' +
        '{"tailoredSummary": string, "coverLetter": string}, ohne weiteren Text drumherum.',
      messages: [{ role: "user", content: prompt }],
    });

    const textBlock = response.content.find(
      (block): block is Anthropic.TextBlock => block.type === "text",
    );
    if (!textBlock) {
      res.status(502).json({ error: "no text response from model" });
      return;
    }

    res.json(parseTailorResponse(textBlock.text));
  } catch (err) {
    res.status(502).json({ error: err instanceof Error ? err.message : "CV tailoring failed" });
  }
});

cvRouter.post("/import", async (req, res) => {
  const parsed = importRequestSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: "invalid request body", details: parsed.error.flatten() });
    return;
  }

  if (!process.env["ANTHROPIC_API_KEY"]) {
    res.status(503).json({ error: "CV import is not configured (missing ANTHROPIC_API_KEY)" });
    return;
  }

  // The API rejects a base64 payload containing newlines/whitespace.
  const pdfBase64 = parsed.data.pdfBase64.replace(/\s+/g, "");
  const client = new Anthropic();

  try {
    const response = await client.messages.create({
      model: "claude-opus-5",
      max_tokens: 4000,
      system: IMPORT_SYSTEM_PROMPT,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "document",
              source: { type: "base64", media_type: "application/pdf", data: pdfBase64 },
            },
            { type: "text", text: "Extrahiere die Lebenslaufdaten wie im System-Prompt beschrieben." },
          ],
        },
      ],
    });

    const textBlock = response.content.find(
      (block): block is Anthropic.TextBlock => block.type === "text",
    );
    if (!textBlock) {
      res.status(502).json({ error: "no text response from model" });
      return;
    }

    const jsonMatch = textBlock.text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      res.status(502).json({ error: "model response did not contain JSON" });
      return;
    }

    res.json(cvProfileSchema.parse(JSON.parse(jsonMatch[0])));
  } catch (err) {
    res.status(502).json({ error: err instanceof Error ? err.message : "CV import failed" });
  }
});
