import jwt from 'jsonwebtoken'

const segredo = () => process.env.JWT_SECRET || 'desenvolvimento-local-farma-market'
export const gerarToken = user => jwt.sign({ id: user.id, role: user.role }, segredo(), { expiresIn: '7d' })

export function autenticar(req, res, next) {
  const token = req.headers.authorization?.replace(/^Bearer\s+/i, '')
  if (!token) return res.status(401).json({ message: 'Faça login para continuar.' })
  try { req.user = jwt.verify(token, segredo()); next() }
  catch { res.status(401).json({ message: 'Sessão inválida ou expirada.' }) }
}

export const exigirPerfil = role => (req, res, next) =>
  req.user.role === role ? next() : res.status(403).json({ message: 'Acesso não autorizado.' })
