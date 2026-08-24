import React from 'react'
import ReactDOM from 'react-dom/client'
import { registerSW } from 'virtual:pwa-register'
import Aplicacao from './Aplicacao'
import './estilos.css'
import './consumidor.css'
import './autenticacao.css'
import './instalacao.css'
import './medicamento.css'
import './detalhes-medicamento.css'
import './descricao-produto.css'
import './formulario-produto.css'
import './pedidos.css'
import './importacao-estoque.css'
import './venda-balcao.css'
import './bi-vendas.css'
import './relatorios-vendas.css'
import './vitrine-farmacia.css'
import './envio-farmacia.css'
import './busca-farmacia.css'
import './whatsapp.css'
import './whatsapp-pedido.css'
import './whatsapp-template.css'
import './whatsapp-layout-fix.css'
import './assistente-cadastro.css'

registerSW({ immediate: true })

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode><Aplicacao /></React.StrictMode>,
)
