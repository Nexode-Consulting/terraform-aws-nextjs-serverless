import type { NextPage } from 'next'
import Image from 'next/image'
import styles from '../../styles/Home.module.css'

const Home: NextPage = () => {
  return (
    <main className={styles.main}>
      <div>
        <span>.avif</span>
        <Image
          src='/images/sample.avif'
          alt='Sample Image'
          width={500}
          height={325}
        />
      </div>
      <div>
        <span>.gif</span>
        <Image
          // unoptimized={true}
          src='/images/sample.gif'
          alt='Sample Image'
          width={500}
          height={325}
        />
      </div>
      <div>
        <span>.jpeg</span>
        <Image
          src='/images/sample.jpg'
          alt='Sample Image'
          width={500}
          height={325}
        />
      </div>
      <div>
        <span>.png</span>
        <Image
          src='/images/sample.png'
          alt='Sample Image'
          width={500}
          height={325}
        />
      </div>
      <div>
        <span>.webp</span>
        <Image
          src='/images/sample.webp'
          alt='Sample Image'
          width={500}
          height={325}
        />
      </div>
    </main>
  )
}

export default Home
