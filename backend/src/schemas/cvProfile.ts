import { z } from "zod";

export const personalInfoSchema = z.object({
  fullName: z.string().default(""),
  email: z.string().default(""),
  phone: z.string().default(""),
  address: z.string().default(""),
  summary: z.string().default(""),
});

export const workExperienceSchema = z.object({
  company: z.string().default(""),
  position: z.string().default(""),
  startDate: z.string().default(""),
  endDate: z.string().default(""),
  description: z.string().default(""),
});

export const educationSchema = z.object({
  institution: z.string().default(""),
  degree: z.string().default(""),
  startDate: z.string().default(""),
  endDate: z.string().default(""),
});

export const cvProfileSchema = z.object({
  personalInfo: personalInfoSchema.default(() => ({
    fullName: "",
    email: "",
    phone: "",
    address: "",
    summary: "",
  })),
  experience: z.array(workExperienceSchema).default([]),
  education: z.array(educationSchema).default([]),
  skills: z.array(z.string()).default([]),
});

export type CvProfileInput = z.infer<typeof cvProfileSchema>;
