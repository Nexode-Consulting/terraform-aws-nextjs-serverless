// pages/__tests__/index.test.js
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom'

import Home from '../../pages/index'

describe('Index page', () => {
  it('renders welcome message', () => {
    render(<Home />)

    const title = screen.getByText('Welcome to')
    const subtitle = screen.getByText('Get started by editing')

    expect(title).toBeInTheDocument()
    expect(subtitle).toBeInTheDocument()
  })
})
