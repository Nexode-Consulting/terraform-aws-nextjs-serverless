import { useEffect, useState } from 'react'
import styles from '../../styles/Home.module.css'

const SSR = ({ data, status, env }: any) => {
  const [state, setState] = useState(0)

  useEffect(() => void setTimeout(() => setState(status), 1500), [status])

  return (
    <main className={styles.main}>
      <div>status: {state}</div>
      <div>body: {state ? JSON.stringify(data) : 'fake loading...'}</div>
      <div>env: {env}</div>
    </main>
  )
}

export default SSR
