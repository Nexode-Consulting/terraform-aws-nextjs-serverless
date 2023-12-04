import { useContext, useEffect, useState } from 'react'
import styles from '../../styles/Home.module.css'
import { Context } from '.'

const SSR = ({ data, status, env }: any) => {
  const { lang, setLang } = useContext(Context)
  const [state, setState] = useState(0)

  useEffect(() => void setTimeout(() => setState(status), 1500), [status])

  return (
    <main className={styles.main}>
      <div>status: {state}</div>
      <div>body: {state ? JSON.stringify(data) : 'fake loading...'}</div>
      <div>env: {env}</div>

      <div>lang: {lang}</div>
      <button onClick={() => setLang('en')}>en</button>
      <button onClick={() => setLang('de')}>de</button>
    </main>
  )
}

export default SSR
