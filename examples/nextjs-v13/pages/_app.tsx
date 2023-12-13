import Link from 'next/link'
import '../styles/globals.css'
import type { AppProps } from 'next/app'

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      Routes:
      <ul style={{ textDecoration: 'underline' }}>
        <li>
          <Link href='/api/hello'>/api/hello</Link>
        </li>
        <li>
          <Link href='/optimized-images'>/optimized-images</Link>
        </li>
        <li>
          <Link href='/ssr'>/ssr</Link>
        </li>
        <li>
          <Link href='/'>/</Link>
        </li>
      </ul>
      <Component {...pageProps} />
    </>
  )
}

export default MyApp
