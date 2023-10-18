/* A list of supported image types. 
It contains the MIME types for various image formats. 
These image types are prioritized in the array, with the most preferred format at the beginning. */
const imageTypes = [
  'image/webp',
  'image/avif',
  'image/jpeg',
  'image/png',
  'image/svg+xml',
  'image/gif',
  'mage/apng',
]

export const handler = async (event: any, _context: any, callback: any) => {
  try {
    /* Extract the `request` properties. */
    const request = event?.Records?.[0]?.cf?.request

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
    ].join('/')

    /* Define the response. */
    const response = {
      status: 302,
      statusDescription: 'Redirect',
      headers: {
        location: [
          {
            key: 'Location',
            value: redirectToUrl,
          },
        ],
      },
    }

    return callback(null, response)
  } catch (error) {
    console.error({ error })

    return callback(null, {
      status: 403, // to not leak data
    })
  }
}
