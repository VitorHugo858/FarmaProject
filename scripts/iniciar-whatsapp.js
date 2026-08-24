import { spawn } from 'node:child_process'
import http from 'node:http'
import path from 'node:path'

const pastaBackend = path.resolve('..','whatsapiproject','manager-aichat','backend')

function verificarServico() {
  return new Promise(resolve => {
    const requisicao = http.get('http://127.0.0.1:3003/api/whatsapp/status', { timeout: 2000 }, resposta => {
      resposta.resume()
      resolve(resposta.statusCode >= 200 && resposta.statusCode < 500)
    })
    requisicao.on('timeout', () => { requisicao.destroy();resolve(false) })
    requisicao.on('error', () => resolve(false))
  })
}

const aguardar = tempo => new Promise(resolve => setTimeout(resolve, tempo))

if (await verificarServico()) {
  console.log('Backend do WhatsApp já está ativo na porta 3003; reutilizando a instância existente.')
  setInterval(() => {}, 60_000)
} else {
  await aguardar(750)
  if (await verificarServico()) {
    console.log('Outra instância iniciou o WhatsApp na porta 3003; reutilizando o serviço.')
    setInterval(() => {}, 60_000)
  } else {
  const comandoNpm = process.platform === 'win32' ? 'npm.cmd' : 'npm'
  const processo = spawn(comandoNpm, ['start'], { cwd:pastaBackend, stdio:'inherit' })
  const encerrar = sinal => { if (!processo.killed) processo.kill(sinal) }
  process.on('SIGINT', () => encerrar('SIGINT'))
  process.on('SIGTERM', () => encerrar('SIGTERM'))
  processo.on('exit', async codigo => {
    await aguardar(1000)
    if (await verificarServico()) {
      console.log('A porta 3003 foi assumida por outra instância; mantendo o ambiente integrado ativo.')
      setInterval(() => {}, 60_000)
      return
    }
    process.exit(codigo ?? 1)
  })
  processo.on('error', erro => { console.error(`Não foi possível iniciar o WhatsApp: ${erro.message}`);process.exit(1) })
  }
}
