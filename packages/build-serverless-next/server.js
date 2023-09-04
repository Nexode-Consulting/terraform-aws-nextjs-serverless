'use strict'
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, '__esModule', { value: true })
exports.handler = void 0
const next_server_1 = __importDefault(require('next/dist/server/next-server'))
const serverless_http_1 = __importDefault(require('serverless-http'))
// @ts-ignore
const required_server_files_json_1 = require('./.next/required-server-files.json')
const nextServer = new next_server_1.default({
  hostname: 'localhost',
  port: 3000,
  dir: __dirname,
  dev: false,
  conf: Object.assign({}, required_server_files_json_1.config),
})
exports.handler = (0, serverless_http_1.default)(
  nextServer.getRequestHandler(),
  {
    binary: ['*/*'],
  }
)
