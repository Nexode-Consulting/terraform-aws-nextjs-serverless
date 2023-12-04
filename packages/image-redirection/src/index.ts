/* A list of supported image types. 
It contains the MIME types for various image formats. 
These image types are prioritized in the array, with the most preferred format at the beginning. */
const imageTypes = [
  'image/webp',
  // 'image/avif',
  'image/jpeg',
  'image/png',
  // 'image/svg+xml',
  // 'image/gif',
  // 'image/apng',
]

/**
 * The function `redirectTo` is used to create a redirect response with a specified URL.
 * @param {string} url - The `url` parameter is a string that represents the URL to which you want to
 * redirect the user.
 * @param {any} callback - The `callback` parameter is a function that is used to return the response
 * to the caller. It takes two arguments: an error object (if any) and the response object. In this
 * case, the response object is an HTTP response with a status code of 302 (Redirect) and a `
 * @returns a callback function with two arguments: null and an object representing a response.
 */
const redirectTo = (url: string, callback: any) => {
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
      'cache-control': [
        {
          key: 'Cache-Control',
          value: 'public, max-age=600, stale-while-revalidate=2592000', // Serve cached content up to 30 days old while revalidating it after 10 minutes
        },
      ],
    },
  }

  return callback(null, response)
}

/**
 * This TypeScript function handles image requests and redirects them to the appropriate image URL
 * based on the request parameters and headers.
 * @param {any} event - The `event` parameter is an object that contains information about the event
 * that triggered the Lambda function. In this case, it is expected to have a `Records` property, which
 * is an array of records. Each record represents a CloudFront event and contains information about the
 * request and configuration.
 * @param {any} _context - The `_context` parameter is a context object that contains information about
 * the execution environment and runtime. It is typically used to access information such as the AWS
 * Lambda function name, version, and memory limit. In this code snippet, the `_context` parameter is
 * not used, so it can be safely ignored
 * @param {any} callback - The `callback` parameter is a function that you can use to send a response
 * back to the caller. It takes two arguments: an error object (or null if there is no error) and a
 * response object. The response object should contain the necessary information to return a response
 * to the caller, such
 * @returns The code is returning a redirect response to a specified URL.
 */
export const handler = async (event: any, _context: any, callback: any) => {
  try {
    /* Extract the `request` and `config` properties. */
    const { request, config } = event?.Records?.[0]?.cf

    /* This forms the base URL for the redirect. */
    const baseUrl = '/_next/image'
    /* Parsing the query string from the request URL and converting it into an object. */
    const query: Record<string, string> = request?.querystring
      ?.split('&')
      .map((q: string) => q.split('='))
      .reduce(
        (acc: Record<string, string>, q: string) => ({
          ...acc,
          [q[0]]: q[1],
        }),
        {}
      )

    // Return original image if it's remote image
    if (/^(http|https)%3A%2F%2F/.test(query?.url)) {
      /* The URL for the original image. */
      const imageUrl = query?.url.replace(/%3A/g, ':').replace(/%2F/g, '/')
      console.log({ imageUrl });
      return redirectTo(imageUrl, callback)
    }

    // Return original image if it's static image
    if (/_next/.test(query?.url)) {
      /* The URL for the original image. */
      const imageUrl =
        'https://' +
        config?.distributionDomainName +
        query?.url.replace(/%2F/g, '/')
      return redirectTo(imageUrl, callback)
    }

    // Return original image if it's image/gif or image/svg+xml
    const regex = /\.(gif|svg|xml)$/
    if (regex.test(query?.url)) {
      /* The URL for the original image. */
      const imageUrl =
        'https://' + config?.distributionDomainName + '/assets' + query?.url
      return redirectTo(imageUrl, callback)
    }

    /* Extract the value of the "accept" header from the request headers. */
    const acceptHeader: string = request?.headers?.accept?.find(
      (item: Record<string, string>) => item.key === 'accept'
    )?.value
    /* Create a list with accepted image types. */
    const acceptedTypes = acceptHeader
      ?.split(',')
      ?.filter((type: string) => type.startsWith('image/'))

    /* Default value in case none of the accepted image types match the supported image types. */
    let requestType = imageTypes[0]
    /* Find a prefered type that is accepted */
    for (const type of imageTypes) {
      if (acceptedTypes.includes(type)) {
        requestType = type
        break
      }
    }

    /*  Creating a URL string for the redirect. */
    const redirectToUrl = [
      baseUrl,
      query?.w,
      query?.q,
      requestType.replace('image/', ''),
      query?.url.replace('%2F', ''),
    ]
      .join('/')
      .replace(/%2F/g, '/')
      .replace('/assets', '')

    return redirectTo(redirectToUrl, callback)
  } catch (error) {
    console.error({ error })

    return callback(null, {
      status: 403, // to not leak data
    })
  }
}
