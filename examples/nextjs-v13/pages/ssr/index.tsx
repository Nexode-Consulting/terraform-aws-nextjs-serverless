import type { NextPage } from 'next'
import { Dispatch, SetStateAction, createContext, useState } from 'react'
import SSR from './SSR'

export const Context = createContext({
  lang: 'en',
  setLang: (() => {}) as Dispatch<SetStateAction<string>>,
})

const Home: NextPage = (props: any) => {
  const [lang, setLang] = useState('en')

  return (
    <Context.Provider value={{ lang, setLang }}>
      <div>lang: {lang}</div>
      <SSR {...props} />
    </Context.Provider>
  )
}

// This gets called on every request
export async function getServerSideProps(context: any) {
  const baseUrl = `${
    process.env.NODE_ENV === 'production' ? 'https' : 'http'
  }://${context.req.headers.host}`

  // Fetch data from external API
  const res = await fetch(baseUrl + '/api/hello')
  const data = await res.json()

  // Pass data to the page via props
  return {
    props: {
      data,
      status: res.status,
      env: process.env.AWS_EXECUTION_ENV ?? null,
    },
  }
}

export default Home
