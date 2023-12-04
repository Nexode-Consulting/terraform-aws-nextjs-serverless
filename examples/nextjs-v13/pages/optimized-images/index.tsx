import type { NextPage } from 'next'
import Image from 'next/image'
import styles from '../../styles/Home.module.css'

const Home: NextPage = () => {
  return (
    <main className={styles.main}>
      <div style={{ border: '1px solid black', margin: '5px', padding: '5px' }}>
        <span>.avif</span>
        <Image
          src='/images/sample.avif'
          alt='Sample Image'
          width={500}
          height={325}
        />
      </div>
      <div style={{ border: '1px solid black', margin: '5px', padding: '5px' }}>
        <span>.gif</span>
        <Image
          // unoptimized={true}
          src='/images/sample.gif'
          alt='Sample Image'
          width={500}
          height={325}
        />
      </div>
      <div style={{ border: '1px solid black', margin: '5px', padding: '5px' }}>
        <span>.jpeg</span>
        <Image
          src='/images/sample.jpg'
          alt='Sample Image'
          width={500}
          height={325}
        />
      </div>
      <div style={{ border: '1px solid black', margin: '5px', padding: '5px' }}>
        <span>.png</span>
        <Image
          src='/images/sample.png'
          alt='Sample Image'
          width={500}
          height={325}
        />
      </div>
      <div style={{ border: '1px solid black', margin: '5px', padding: '5px' }}>
        <span>.webp</span>
        <Image
          src='/images/sample.webp'
          alt='Sample Image'
          width={500}
          height={325}
        />
      </div>
      <div style={{ border: '1px solid black', margin: '5px', padding: '5px' }}>
        <span>img component</span>
        <img src='/images/sample.png' alt='sample image' width={500} height={325} />
      </div>
      <div style={{ border: '1px solid black', margin: '5px', padding: '5px' }}>
        <span>bg-img (css)</span>
        <div
          style={{
            backgroundImage: 'url(/images/sample.png)',
            backgroundPosition: 'center',
            backgroundSize: 'contain',
            width: 500,
            height: 325,
          }}
        />
      </div>
    </main>
  )
}

export default Home
