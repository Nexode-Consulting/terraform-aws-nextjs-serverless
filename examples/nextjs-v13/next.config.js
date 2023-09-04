/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  images: {
    unoptimized: true, // Nowhere to cache the images in Lambda (read only)
  },
  output: 'standalone',
}

module.exports = nextConfig
