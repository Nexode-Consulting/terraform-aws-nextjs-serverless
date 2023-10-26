import https from 'https'

/**
 * @deprecated
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

/**
 * The function `redirectTo` is used to create a redirect response with a specified URL.
 * @param {string} url - The `url` parameter is a string that represents the URL to which you want to
 * redirect the user.
 * @param {any} callback - The `callback` parameter is a function that is used to return the response
 * to the caller. It takes two arguments: an error object (if any) and the response object. In this
 * case, the response object is an HTTP response with a status code of 302 (Redirect) and a `
 * @returns a callback function with two arguments: null and an object representing a response.
 */
export const redirectTo = (url: string, callback: any) => {
  const response = {
    status: 302,
    statusDescription: 'Redirect',
    headers: {
      location: [
        {
          key: 'Location',
          value: url,
        },
      ],
    },
  }

  return callback(null, response)
}
