import { GetObjectCommand, S3Client } from '@aws-sdk/client-s3'
import sharp from 'sharp'

import { defaults, limits } from './constants'
import { redirectTo } from './helpers'

/**
 * This TypeScript function is a CloudFront function that resizes and compresses images based on the
 * request URI and returns the resized image as a base64 encoded string.
 * @param {any} event - The `event` parameter is an object that contains information about the event
 * that triggered the Lambda function. In this case, it contains the CloudFront event data, which
 * includes details about the request and configuration.
 * @param {any} _context - The `_context` parameter is a context object that contains information about
 * the execution environment and runtime. It is typically not used in this code snippet, so it can be
 * ignored for now.
 * @param {any} callback - The `callback` parameter is a function that is used to send the response
 * back to the caller. It takes two arguments: an error object (or null if there is no error) and the
 * response object. The response object should contain the status code, status description, headers,
 * body encoding, and
 * @returns The code is returning a response object with the following properties:
 */
export const handler = async (event: any, _context: any, callback: any) => {
  try {
    /* Extract the `request` and `config` properties. */
    const { request, config } = event?.Records?.[0]?.cf
    /* Construct the base URL for the image assets. */
    const baseUrl = config?.distributionDomainName + '/assets/'

    /* The S3 region. */
    const s3Region =
      request?.origin?.custom?.customHeaders?.['s3-region']?.[0]?.value
    /* The public_assets_bucket name. */
    const publicAssetsBucket =
      request?.origin?.custom?.customHeaders?.['public-assets-bucket']?.[0]
        ?.value

    /* Extracting the relevant information from the request URI. */
    const queryString = (request?.uri as string)
      ?.replace('/_next/image/', '')
      ?.split('/')
    // Build an object with these information
    const query = {
      width: parseInt(queryString?.[0] || defaults.width.toString()),
      quality: parseInt(queryString?.[1] || defaults.quality.toString()),
      type: 'image/' + queryString?.[2],
      filename: queryString?.slice(3)?.join('/'),
    }

    // The url where the image is stored
    const imageUrl = 'https://' + baseUrl + query.filename
    // The options for image transformation
    const options = {
      quality: query.quality,
    }

    /* The S3 Client. */
    const s3 = new S3Client({ region: s3Region })

    /* Build the s3 command. */
    const s3Command = new GetObjectCommand({
      Bucket: publicAssetsBucket,
      Key: 'assets/' + query.filename.replace('%2F', '/'),
    })

    /* The body of the S3 object. */
    const { Body } = await s3.send(s3Command)
    /* Transforming the body of the S3 object into a byte array. */
    const s3Object = await Body.transformToByteArray()

    /* Resize and compress the image. */
    const resizedImage = sharp(s3Object).resize({ width: query.width })

    let newContentType = null
    /* Apply the corresponding image type transformation. */
    switch (query.type) {
      case 'image/webp':
        resizedImage.webp(options)
        newContentType = 'image/webp'
        break
      case 'image/jpeg':
        resizedImage.jpeg(options)
        newContentType = 'image/jpeg'
        break
      case 'image/png':
        resizedImage.png(options)
        newContentType = 'image/png'
        break
      // case 'image/gif':
      //   // resizedImage.gif(options)
      //   resizedImage.gif()
      //   newContentType = 'image/gif'
      //   break
      // case 'image/apng':
      //   // resizedImage.apng(options)
      //   resizedImage.png(options)
      //   newContentType = 'image/apng'
      //   break
      // case 'image/avif':
      //   resizedImage.avif(options)
      //   newContentType = 'image/avif'
      //   break
      // // case 'image/svg+xml':
      // //   resizedImage.svg(options)
      // //   newContentType = 'image/svg+xml'
      // //   break

      default:
        return redirectTo(imageUrl, callback)
    }

    /* Converting the resized image into a buffer. */
    const resizedImageBuffer = await resizedImage.toBuffer()
    /* The response body in the CloudFront function is expected to be a base64 encoded string. */
    const imageBase64 = resizedImageBuffer.toString('base64')

    /* If the resized image exceeds the Cloudfront response size limit, redirect to the original image */
    if (imageBase64.length > limits.imageSize) {
      return redirectTo(imageUrl, callback)
    }

    /* Define the response. */
    const response = {
      status: 200,
      statusDescription: 'OK',
      headers: {
        'content-type': [
          {
            key: 'Content-Type',
            value: newContentType,
          },
        ],
        'cache-control': [
          {
            key: 'Cache-Control',
            value: 'public, max-age=600, stale-while-revalidate=2592000', // Serve cached content up to 30 days old while revalidating it after 10 minutes
          },
        ],
      },
      bodyEncoding: 'base64',
      body: imageBase64,
    }

    return callback(null, response)
  } catch (error) {
    console.error({ error })

    return callback(null, {
      status: 403, // to not leak data
    })
  }
}
