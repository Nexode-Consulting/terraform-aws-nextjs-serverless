import https from 'https'

/**
 * The function fetchBufferFromUrl fetches a buffer from a given URL using the https module in Node.js.
 * @param {string} url - The `url` parameter is a string that represents the URL from which you want to
 * fetch the buffer.
 * @returns The function `fetchBufferFromUrl` returns a Promise that resolves to a Buffer.
 */
export const fetchBufferFromUrl = (url: string): Promise<Buffer> => {
  return new Promise((resolve, reject) => {
    https.get(url, res => {
      const chunks: any[] = []

      res.on('data', chunk => {
        chunks.push(chunk)
      })

      res.on('end', () => {
        const buffer = Buffer.concat(chunks)
        resolve(buffer)
      })

      res.on('error', error => {
        reject(error)
      })
    })
  })
}
