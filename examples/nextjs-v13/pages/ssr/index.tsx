import type { NextPage } from 'next'
import styles from '../../styles/Home.module.css'

const Home: NextPage = ({ data, status, env }: any) => {
  console.log({env})

  return (
    <main className={styles.main}>
      <div>{status}</div>
      <div>{JSON.stringify(data)}</div>
      <div>{env.AWS_EXECUTION_ENV}</div>
    </main>
  )
}

// This gets called on every request
export async function getServerSideProps() {
  // Fetch data from external API
  const res = await fetch(`{{DISTRIBUTION_URL}}/api/hello`)
  const data = await res.json()

  // Pass data to the page via props
  return { props: { data, status: res.status, env: process.env } }
}

export default Home
