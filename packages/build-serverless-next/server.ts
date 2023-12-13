import { NextConfig } from 'next'
import NextServer from 'next/dist/server/next-server'
import serverless from 'serverless-http'
// @ts-ignore
import { config } from './.next/required-server-files.json'

const getProps = async (event: any, context: any) => {
  const path =
    './.next/server/pages/' +
    event.rawPath
      .replace('/_next/data/', '')
      .split('/')
      .slice(1)
      .join('/')
      .replace('.json', '.js')
  const { getServerSideProps } = require(path)

  const customResponse = await getServerSideProps(context)
  const response: any = {}

  response.statusCode = 200
  response.body = JSON.stringify({ pageProps: customResponse.props })

  return response
}

const nextServer = new NextServer({
  hostname: 'localhost',
  port: 3000,
  dir: './',
  dev: false,
  conf: {
    ...(config as NextConfig),
  },
  customServer: true,
})

const main = serverless(nextServer.getRequestHandler(), {
  binary: ['*/*'],
  provider: 'aws',
})

export const handler = (event: any, context: any) =>
  event.rawPath.includes('/_next/data/')
    ? getProps(event, context)
    : main(event, context)
