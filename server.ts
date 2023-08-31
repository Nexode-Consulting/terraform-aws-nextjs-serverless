import { NextConfig } from "next";
import NextServer from "next/dist/server/next-server";
import serverless from "serverless-http";
// @ts-ignore
import { config } from "./.next/required-server-files.json";

const nextServer = new NextServer({
  hostname: "localhost",
  port: 3000,
  dir: './',
  dev: false,
  conf: {
    ...(config as NextConfig),
  },
});

export const handler = serverless(nextServer.getRequestHandler(), {
  binary: ["*/*"],
  provider: 'aws',
  basePath: './'
});