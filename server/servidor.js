import express from 'express'
import cors from 'cors'
import bcrypt from 'bcryptjs'
import multer from 'multer'
import path from 'node:path'
import { randomUUID } from 'node:crypto'
import 'dotenv/config'
import { conexoes, executarTransacao } from './banco.js'
import { autenticar, exigirPerfil, gerarToken } from './autenticacao.js'

const app = express()
app.use(cors({ origin: process.env.FRONTEND_URL || 'http://localhost:5173' }))
app.use(express.json({ limit: '2mb' }))
app.use('/uploads', express.static(path.resolve('uploads')))
const upload = multer({ storage:multer.diskStorage({ destination:'uploads/produtos', filename:(_req,file,cb)=>cb(null,`${randomUUID()}${path.extname(file.originalname).toLowerCase()}`) }), limits:{fileSize:5*1024*1024}, fileFilter:(_req,file,cb)=>cb(null,['image/jpeg','image/png','image/webp'].includes(file.mimetype)) })
const storeUpload = multer({ storage:multer.diskStorage({ destination:'uploads/farmacias', filename:(_req,file,cb)=>cb(null,`${randomUUID()}${path.extname(file.originalname).toLowerCase()}`) }), limits:{fileSize:5*1024*1024}, fileFilter:(_req,file,cb)=>cb(null,['image/jpeg','image/png','image/webp'].includes(file.mimetype)) })
const prescriptionUpload = multer({ storage:multer.diskStorage({ destination:'uploads/receitas', filename:(_req,file,cb)=>cb(null,`${randomUUID()}${path.extname(file.originalname).toLowerCase()}`) }), limits:{fileSize:5*1024*1024}, fileFilter:(_req,file,cb)=>cb(null,['image/jpeg','image/png','image/webp'].includes(file.mimetype)) })

const asyncRoute = fn => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next)
const perfilParaBanco = { consumer: 'consumidor', seller: 'vendedor' }
const restricaoParaBanco = { otc:'livre', red_no_retention:'vermelha_sem_retencao', red_retention:'vermelha_com_retencao', black:'preta' }
const pagamentoParaBanco = { pix:'pix', credit_card:'cartao_credito', debit_card:'cartao_debito' }
const situacaoParaBanco = { new:'novo', preparing:'preparando', shipped:'enviado', completed:'concluido', cancelled:'cancelado' }
const whatsappApiUrl = String(process.env.WHATSAPP_API_URL || 'http://127.0.0.1:3003').replace(/\/$/, '')
const normalizarBusca = valor => String(valor || '').normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase().replace(/[^a-z0-9]+/g,' ').trim()

async function sincronizarContextoIa(conn, produtoId, dados) {
  const aliasesPorChave = new Map()
  for (const valor of [dados.name,...(Array.isArray(dados.aliases)?dados.aliases:[])]) {
    const alias=String(valor||'').trim();const chave=normalizarBusca(alias)
    if (alias&&chave&&!aliasesPorChave.has(chave)) aliasesPorChave.set(chave,alias)
  }
  const aliases = [...aliasesPorChave.entries()].slice(0,30)
  const atributos = (Array.isArray(dados.ai_attributes)?dados.ai_attributes:[]).map(item=>({name:String(item.name||'').trim(),value:String(item.value||'').trim(),unit:String(item.unit||'').trim()||null})).filter(item=>item.name&&item.value).slice(0,40)
  if (dados.dosage) atributos.push({name:'dosagem',value:String(dados.dosage).trim(),unit:null})
  if (dados.presentation) atributos.push({name:'apresentacao',value:String(dados.presentation).trim(),unit:null})
  const claims = (Array.isArray(dados.ai_claims)?dados.ai_claims:[]).map(item=>({text:String(item.text||item||'').trim(),type:String(item.type||'comercial').trim()})).filter(item=>item.text).slice(0,20)

  await conn.query('DELETE FROM produto_aliases WHERE produto_id=?',[produtoId])
  for (const [chave,alias] of aliases) await conn.query('INSERT INTO produto_aliases (produto_id,alias,alias_normalizado,ativo) VALUES (?,?,?,TRUE)',[produtoId,alias,chave])
  await conn.query("DELETE FROM produto_atributos WHERE produto_id=? AND fonte='formulario do vendedor'",[produtoId])
  for (const atributo of atributos) await conn.query('INSERT INTO produto_atributos (produto_id,nome,valor,unidade,verificado,fonte) VALUES (?,?,?,?,TRUE,?) ON DUPLICATE KEY UPDATE unidade=VALUES(unidade),verificado=TRUE,fonte=VALUES(fonte)',[produtoId,atributo.name,atributo.value,atributo.unit,'formulario do vendedor'])
  await conn.query("DELETE FROM produto_claims WHERE produto_id=? AND fonte='formulario do vendedor'",[produtoId])
  for (const claim of claims) await conn.query('INSERT INTO produto_claims (produto_id,texto,tipo,aprovado,aprovado_em,fonte) VALUES (?,?,?,?,?,?)',[produtoId,claim.text,claim.type,Boolean(dados.approve_ai_content),dados.approve_ai_content?new Date():null,'formulario do vendedor'])
}

async function requisitarWhatsapp(caminho, opcoes = {}) {
  let resposta
  let erroConexao
  for (let tentativa = 1; tentativa <= 3; tentativa += 1) {
    try {
      resposta = await fetch(`${whatsappApiUrl}${caminho}`, {
        ...opcoes,
        headers: { 'Content-Type':'application/json', ...opcoes.headers }
      })
      break
    } catch (erro) {
      erroConexao = erro
      if (tentativa < 3) await new Promise(resolve => setTimeout(resolve, 500 * tentativa))
    }
  }
  if (!resposta) throw Object.assign(new Error('O serviço do WhatsApp está iniciando ou indisponível. Aguarde alguns segundos e tente novamente.'), { status:503, cause:erroConexao })
  const corpo = resposta.status === 204 ? null : await resposta.json().catch(() => ({}))
  if (!resposta.ok) throw Object.assign(new Error(corpo?.message || 'Não foi possível acessar o serviço do WhatsApp.'), { status: resposta.status })
  return corpo
}

app.get('/api/health', asyncRoute(async (_req, res) => {
  await conexoes.query('SELECT 1')
  res.json({ status: 'ok', database: 'connected' })
}))

app.get('/api/vendedor/whatsapp/status', autenticar, exigirPerfil('seller'), asyncRoute(async (_req, res) => {
  res.json(await requisitarWhatsapp('/api/whatsapp/status'))
}))

app.get('/api/vendedor/whatsapp/conversas', autenticar, exigirPerfil('seller'), asyncRoute(async (_req, res) => {
  res.json(await requisitarWhatsapp('/api/dashboard/conversations'))
}))

app.get('/api/vendedor/whatsapp/conversas/:id/mensagens', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  res.json(await requisitarWhatsapp(`/api/dashboard/conversations/${Number(req.params.id)}/messages`))
}))

app.post('/api/vendedor/whatsapp/conversas/:id/mensagens', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const mensagem = await requisitarWhatsapp(`/api/dashboard/conversations/${Number(req.params.id)}/messages`, { method:'POST', body:JSON.stringify({ content:req.body.content }) })
  res.status(201).json(mensagem)
}))

app.patch('/api/vendedor/whatsapp/conversas/:id/modo', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const mode = String(req.body.mode || '').toUpperCase()
  if (!['AI','HUMAN'].includes(mode)) return res.status(400).json({ message:'O modo deve ser IA ou humano.' })
  res.json(await requisitarWhatsapp(`/api/dashboard/conversations/${Number(req.params.id)}/mode`, {
    method:'PATCH', body:JSON.stringify({ mode })
  }))
}))

app.post('/api/vendedor/whatsapp/conversas/:id/finalizar', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  res.json(await requisitarWhatsapp(`/api/dashboard/conversations/${Number(req.params.id)}/close`, { method:'POST' }))
}))

app.get('/api/consumidor/atendimento/mensagens', autenticar, exigirPerfil('consumer'), asyncRoute(async (req, res) => {
  res.json(await requisitarWhatsapp(`/api/webchat/farma-${req.user.id}/messages`))
}))

app.post('/api/consumidor/atendimento/mensagens', autenticar, exigirPerfil('consumer'), asyncRoute(async (req, res) => {
  const content = String(req.body.content || '').trim()
  if (!content || content.length > 4000) return res.status(400).json({ message:'A mensagem deve conter entre 1 e 4.000 caracteres.' })
  const [usuarios] = await conexoes.query('SELECT nome FROM usuarios WHERE id=? LIMIT 1',[req.user.id])
  const resultado = await requisitarWhatsapp(`/api/webchat/farma-${req.user.id}/messages`, {
    method:'POST', body:JSON.stringify({ content, name:usuarios[0]?.nome || 'Consumidor' })
  })
  res.status(201).json(resultado)
}))

app.post('/api/vendedor/whatsapp/conversas/:id/pedido', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const conversaId = Number(req.params.id)
  if (!Number.isInteger(conversaId) || conversaId < 1) return res.status(400).json({ message:'Conversa inválida.' })
  if (!Array.isArray(req.body.itens) || !req.body.itens.length || req.body.itens.length > 50) return res.status(400).json({ message:'Inclua ao menos um produto no pedido.' })
  const itens = req.body.itens.map(item => ({ produtoId:Number(item.produto_id), quantidade:Number(item.quantidade) }))
  if (itens.some(item => !Number.isInteger(item.produtoId) || item.produtoId < 1 || !Number.isInteger(item.quantidade) || item.quantidade < 1 || item.quantidade > 999)) return res.status(400).json({ message:'Os produtos ou quantidades do pedido são inválidos.' })
  if (new Set(itens.map(item => item.produtoId)).size !== itens.length) return res.status(400).json({ message:'Há produtos repetidos no pedido.' })

  const detalhes = await requisitarWhatsapp(`/api/dashboard/conversations/${conversaId}/messages`)
  const cliente = String(detalhes?.conversation?.customer?.name || `WhatsApp +${detalhes?.conversation?.customer?.phone || ''}`).trim()
  const venda = await executarTransacao(async conn => {
    const [farmacias] = await conn.query('SELECT id,nome FROM farmacias WHERE proprietario_id=?',[req.user.id])
    if (!farmacias[0]) throw Object.assign(new Error('Loja não encontrada.'),{status:404})
    const ids = itens.map(item => item.produtoId)
    const [produtos] = await conn.query(`SELECT p.id,p.nome,p.dosagem,p.restricao_venda,p.preco,p.estoque,c.nome categoria FROM produtos p JOIN farmacias f ON f.id=p.farmacia_id LEFT JOIN categorias c ON c.id=p.categoria_id WHERE f.proprietario_id=? AND p.ativo=1 AND p.id IN (${ids.map(()=>'?').join(',')}) FOR UPDATE`,[req.user.id,...ids])
    if (produtos.length !== ids.length) throw Object.assign(new Error('Um dos produtos não existe, está inativo ou não pertence a esta farmácia.'),{status:404})
    const linhas = itens.map(item => {
      const produto = produtos.find(registro => Number(registro.id) === item.produtoId)
      if (Number(produto.estoque) < item.quantidade) throw Object.assign(new Error(`Estoque insuficiente para ${produto.nome}. Disponível: ${produto.estoque}.`),{status:409})
      return { ...item, nome:produto.nome, dosagem:produto.dosagem, restricao:produto.restricao_venda, categoria:produto.categoria, preco:Number(produto.preco), subtotal:Number(produto.preco)*item.quantidade }
    })
    const vendas = []
    for (const linha of linhas) {
      await conn.query('UPDATE produtos SET estoque=estoque-? WHERE id=?',[linha.quantidade,linha.produtoId])
      const [resultado] = await conn.query('INSERT INTO vendas_balcao (farmacia_id,produto_id,nome_produto,dosagem,restricao_venda,categoria,nome_cliente,preco,quantidade,receita_url) VALUES (?,?,?,?,?,?,?,?,?,NULL)',[farmacias[0].id,linha.produtoId,linha.nome,linha.dosagem,linha.restricao,linha.categoria,cliente,linha.preco,linha.quantidade])
      vendas.push(resultado.insertId)
    }
    return { farmacia:farmacias[0].nome, itens:linhas, vendas, total:linhas.reduce((soma,item)=>soma+item.subtotal,0) }
  })
  const moeda = valor => Number(valor).toLocaleString('pt-BR',{style:'currency',currency:'BRL'})
  const texto = [`✅ *Pedido confirmado - ${venda.farmacia}*`,'',...venda.itens.map(item=>`• ${item.quantidade}x ${item.nome} - ${moeda(item.subtotal)}`),'',`*Total: ${moeda(venda.total)}*`,'Seu pedido foi registrado e seguirá para separação e envio conforme o combinado.'].join('\n')
  let mensagemWhatsapp = null
  let aviso = null
  try { mensagemWhatsapp = await requisitarWhatsapp(`/api/dashboard/conversations/${conversaId}/messages`,{method:'POST',body:JSON.stringify({content:texto})}) }
  catch (erro) { aviso = `A venda foi registrada e o estoque foi atualizado, mas a confirmação não foi enviada pelo WhatsApp: ${erro.message}` }
  res.status(201).json({ vendas:venda.vendas, total:venda.total, itens:venda.itens.map(item=>({produto_id:item.produtoId,quantidade:item.quantidade})), mensagem_whatsapp:mensagemWhatsapp, aviso, message:aviso || 'Pedido confirmado, estoque atualizado e resumo enviado ao cliente.' })
}))

app.post('/api/auth/cadastrar', asyncRoute(async (req, res) => {
  const { name, email, password, role = 'consumer', phone } = req.body
  if (!name || !email || !password) return res.status(400).json({ message: 'Nome, e-mail e senha são obrigatórios.' })
  if (!['consumer', 'seller'].includes(role)) return res.status(400).json({ message: 'Perfil inválido.' })
  const [existente] = await conexoes.query('SELECT id FROM users WHERE email = ?', [email])
  if (existente.length) return res.status(409).json({ message: 'Este e-mail já está cadastrado.' })
  const hash = await bcrypt.hash(password, 12)
  const [resultado] = await conexoes.query('INSERT INTO usuarios (nome,email,senha_hash,perfil,telefone) VALUES (?,?,?,?,?)', [name, email, hash, perfilParaBanco[role], phone || null])
  if (role === 'seller') await conexoes.query('INSERT INTO farmacias (proprietario_id,nome) VALUES (?,?)', [resultado.insertId, `Farmácia de ${name}`])
  const user = { id: resultado.insertId, name, email, role }
  res.status(201).json({ token: gerarToken(user), user })
}))

app.post('/api/auth/entrar', asyncRoute(async (req, res) => {
  const [linhas] = await conexoes.query('SELECT id,name,email,password_hash,role FROM users WHERE email = ? AND active = 1', [req.body.email])
  const user = linhas[0]
  if (!user || !await bcrypt.compare(req.body.password || '', user.password_hash)) return res.status(401).json({ message: 'E-mail ou senha incorretos.' })
  delete user.password_hash
  res.json({ token: gerarToken(user), user })
}))

app.get('/api/me', autenticar, asyncRoute(async (req, res) => {
  const [linhas] = await conexoes.query('SELECT id,name,email,role,phone,cpf,created_at FROM users WHERE id=?', [req.user.id])
  res.json(linhas[0])
}))

app.put('/api/me', autenticar, asyncRoute(async (req, res) => {
  const { name, email, phone, cpf } = req.body
  if (!name || !email) return res.status(400).json({ message: 'Nome e e-mail são obrigatórios.' })
  const [duplicado] = await conexoes.query('SELECT id FROM users WHERE email=? AND id<>?', [email, req.user.id])
  if (duplicado.length) return res.status(409).json({ message: 'Este e-mail já está em uso.' })
  await conexoes.query('UPDATE usuarios SET nome=?,email=?,telefone=?,cpf=? WHERE id=?', [name, email, phone || null, cpf || null, req.user.id])
  res.json({ message: 'Perfil atualizado.' })
}))

app.get('/api/produtos', asyncRoute(async (req, res) => {
  const { category, search, store } = req.query
  let sql = `SELECT p.*,c.name category,s.name store_name,mt.name medication_type,b.name brand,d.volume,d.concentracao,d.genero_publico,d.notas_saida,d.notas_corpo,d.notas_fundo,d.destaque_1,d.destaque_2,d.destaque_3,d.destaque_4 FROM products p JOIN categories c ON c.id=p.category_id JOIN stores s ON s.id=p.store_id LEFT JOIN medication_types mt ON mt.id=p.medication_type_id LEFT JOIN brands b ON b.id=p.brand_id LEFT JOIN detalhes_produtos d ON d.produto_id=p.id WHERE p.active=1`
  const params = []
  if (category) { sql += ' AND c.slug=?'; params.push(category) }
  if (search) { sql += ' AND (p.name LIKE ? OR p.description LIKE ?)'; params.push(`%${search}%`, `%${search}%`) }
  if (store) { sql += ' AND p.store_id=?'; params.push(store) }
  sql += ' ORDER BY p.created_at DESC'
  const [linhas] = await conexoes.query(sql, params)
  res.json(linhas)
}))

app.get('/api/produtos/:id', asyncRoute(async (req, res) => {
  const [linhas] = await conexoes.query(`SELECT p.*,c.name category,s.name store_name,s.rating store_rating,mt.name medication_type,b.name brand,b.manufacturer,d.volume,d.concentracao,d.genero_publico,d.notas_saida,d.notas_corpo,d.notas_fundo,d.destaque_1,d.destaque_2,d.destaque_3,d.destaque_4 FROM products p JOIN categories c ON c.id=p.category_id JOIN stores s ON s.id=p.store_id LEFT JOIN medication_types mt ON mt.id=p.medication_type_id LEFT JOIN brands b ON b.id=p.brand_id LEFT JOIN detalhes_produtos d ON d.produto_id=p.id WHERE p.id=? AND p.active=1`, [req.params.id])
  if (!linhas[0]) return res.status(404).json({ message: 'Produto não encontrado.' })
  res.json(linhas[0])
}))

app.get('/api/farmacias/:id', asyncRoute(async (req, res) => {
  const [farmacias]=await conexoes.query('SELECT id,name,description,phone,email,address,city,state,zip_code,opening_hours,delivery_info,logo_url,banner_url,rating,verified FROM stores WHERE id=? AND active=1',[req.params.id])
  if(!farmacias[0])return res.status(404).json({message:'Farmácia não encontrada.'})
  const [produtos]=await conexoes.query(`SELECT p.*,c.name category,mt.name medication_type,b.name brand,d.volume,d.concentracao,d.genero_publico,d.notas_saida,d.notas_corpo,d.notas_fundo,d.destaque_1,d.destaque_2,d.destaque_3,d.destaque_4 FROM products p JOIN categories c ON c.id=p.category_id LEFT JOIN medication_types mt ON mt.id=p.medication_type_id LEFT JOIN brands b ON b.id=p.brand_id LEFT JOIN detalhes_produtos d ON d.produto_id=p.id WHERE p.store_id=? AND p.active=1 ORDER BY p.created_at DESC`,[req.params.id])
  res.json({...farmacias[0],produtos})
}))

app.get('/api/farmacias', asyncRoute(async (_req, res) => {
  const [farmacias] = await conexoes.query('SELECT id,name,description,phone,email,address,city,state,zip_code,opening_hours,delivery_info,logo_url,banner_url,rating,verified FROM stores WHERE active=1 ORDER BY name')
  res.json(farmacias)
}))

app.get('/api/categorias', asyncRoute(async (_req, res) => {
  const [linhas] = await conexoes.query('SELECT id,name,slug FROM categories ORDER BY name')
  res.json(linhas)
}))

app.get('/api/tipos-medicamento', asyncRoute(async (_req, res) => {
  const [linhas] = await conexoes.query('SELECT id,name,description FROM medication_types WHERE active=1 ORDER BY name')
  res.json(linhas)
}))

app.get('/api/marcas', asyncRoute(async (_req, res) => {
  const [linhas] = await conexoes.query('SELECT id,name,manufacturer FROM brands WHERE active=1 ORDER BY name')
  res.json(linhas)
}))

app.post('/api/vendedor/tipos-medicamento', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const name=String(req.body.name||'').trim();const description=String(req.body.description||'').trim()
  if (!name) return res.status(400).json({ message:'Informe o nome do tipo.' })
  const [resultado]=await conexoes.query('INSERT INTO tipos_medicamento (nome,descricao) VALUES (?,?)',[name,description||null])
  res.status(201).json({id:resultado.insertId,name,description})
}))

app.post('/api/vendedor/marcas', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const name=String(req.body.name||'').trim();const manufacturer=String(req.body.manufacturer||'').trim()
  if (!name) return res.status(400).json({ message:'Informe o nome da marca.' })
  const [resultado]=await conexoes.query('INSERT INTO marcas (nome,fabricante) VALUES (?,?)',[name,manufacturer||null])
  res.status(201).json({id:resultado.insertId,name,manufacturer})
}))

app.post('/api/vendedor/imagem-produto', autenticar, exigirPerfil('seller'), upload.single('image'), (req,res) => {
  if (!req.file) return res.status(400).json({message:'Envie uma imagem JPG, PNG ou WebP de até 5 MB.'})
  res.status(201).json({image_url:`/uploads/produtos/${req.file.filename}`})
})

app.post('/api/vendedor/imagem-farmacia', autenticar, exigirPerfil('seller'), storeUpload.single('image'), (req,res) => {
  if (!req.file) return res.status(400).json({message:'Envie uma imagem JPG, PNG ou WebP de até 5 MB.'})
  res.status(201).json({image_url:`/uploads/farmacias/${req.file.filename}`})
})

app.post('/api/vendedor/imagem-receita', autenticar, exigirPerfil('seller'), prescriptionUpload.single('image'), (req,res) => {
  if (!req.file) return res.status(400).json({message:'Envie uma receita JPG, PNG ou WebP de até 5 MB.'})
  res.status(201).json({image_url:`/uploads/receitas/${req.file.filename}`})
})

app.get('/api/enderecos', autenticar, exigirPerfil('consumer'), asyncRoute(async (req, res) => {
  const [linhas] = await conexoes.query('SELECT * FROM addresses WHERE user_id=? ORDER BY is_default DESC,id DESC', [req.user.id])
  res.json(linhas)
}))

app.post('/api/enderecos', autenticar, exigirPerfil('consumer'), asyncRoute(async (req, res) => {
  const { label='Casa',recipient,street,number,complement,district,city,state,zip_code,is_default=false } = req.body
  if (!street || !number || !district || !city || !state || !zip_code) return res.status(400).json({ message:'Preencha o endereço completo.' })
  if (is_default) await conexoes.query('UPDATE enderecos SET principal=0 WHERE usuario_id=?',[req.user.id])
  const [resultado] = await conexoes.query('INSERT INTO enderecos (usuario_id,identificacao,destinatario,logradouro,numero,complemento,bairro,cidade,estado,cep,principal) VALUES (?,?,?,?,?,?,?,?,?,?,?)',[req.user.id,label,recipient||null,street,number,complement||null,district,city,state,zip_code,is_default])
  res.status(201).json({ id:resultado.insertId,message:'Endereço cadastrado.' })
}))

app.put('/api/enderecos/:id', autenticar, exigirPerfil('consumer'), asyncRoute(async (req, res) => {
  const { label='Casa',recipient,street,number,complement,district,city,state,zip_code,is_default=false } = req.body
  if (!street || !number || !district || !city || !state || !zip_code) return res.status(400).json({ message:'Preencha o endereço completo.' })
  if (is_default) await conexoes.query('UPDATE enderecos SET principal=0 WHERE usuario_id=?',[req.user.id])
  const [resultado] = await conexoes.query('UPDATE enderecos SET identificacao=?,destinatario=?,logradouro=?,numero=?,complemento=?,bairro=?,cidade=?,estado=?,cep=?,principal=? WHERE id=? AND usuario_id=?',[label,recipient||null,street,number,complement||null,district,city,state,zip_code,is_default,req.params.id,req.user.id])
  if (!resultado.affectedRows) return res.status(404).json({ message:'Endereço não encontrado.' })
  res.json({ message:'Endereço atualizado.' })
}))

app.get('/api/favoritos', autenticar, exigirPerfil('consumer'), asyncRoute(async (req, res) => {
  const [linhas] = await conexoes.query('SELECT product_id FROM favorites WHERE user_id=?',[req.user.id])
  res.json(linhas.map(row=>row.product_id))
}))

app.post('/api/favoritos/:productId', autenticar, exigirPerfil('consumer'), asyncRoute(async (req, res) => {
  await conexoes.query('INSERT IGNORE INTO favoritos (usuario_id,produto_id) VALUES (?,?)',[req.user.id,req.params.productId])
  res.status(201).json({ message:'Favorito adicionado.' })
}))

app.delete('/api/favoritos/:productId', autenticar, exigirPerfil('consumer'), asyncRoute(async (req, res) => {
  await conexoes.query('DELETE FROM favoritos WHERE usuario_id=? AND produto_id=?',[req.user.id,req.params.productId])
  res.status(204).end()
}))

app.get('/api/vendedor/farmacia', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const [linhas] = await conexoes.query('SELECT * FROM stores WHERE owner_id=?', [req.user.id])
  res.json(linhas[0])
}))

app.get('/api/vendedor/produtos', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const [linhas] = await conexoes.query(`SELECT p.*,c.name category,mt.name medication_type,b.name brand,d.volume,d.concentracao,d.genero_publico,d.notas_saida,d.notas_corpo,d.notas_fundo,d.destaque_1,d.destaque_2,d.destaque_3,d.destaque_4,(SELECT GROUP_CONCAT(pa.alias ORDER BY pa.id SEPARATOR '\n') FROM produto_aliases pa WHERE pa.produto_id=p.id AND pa.ativo=TRUE) aliases_contexto,(SELECT GROUP_CONCAT(CONCAT(pat.nome,': ',pat.valor,IF(pat.unidade IS NULL OR pat.unidade='','',CONCAT(' | ',pat.unidade))) ORDER BY pat.id SEPARATOR '\n') FROM produto_atributos pat WHERE pat.produto_id=p.id AND pat.fonte='formulario do vendedor') atributos_contexto,(SELECT GROUP_CONCAT(pc.texto ORDER BY pc.id SEPARATOR '\n') FROM produto_claims pc WHERE pc.produto_id=p.id AND pc.fonte='formulario do vendedor') claims_contexto,(SELECT COALESCE(MIN(pc.aprovado),0) FROM produto_claims pc WHERE pc.produto_id=p.id AND pc.fonte='formulario do vendedor') contexto_aprovado FROM products p JOIN categories c ON c.id=p.category_id JOIN stores s ON s.id=p.store_id LEFT JOIN medication_types mt ON mt.id=p.medication_type_id LEFT JOIN brands b ON b.id=p.brand_id LEFT JOIN detalhes_produtos d ON d.produto_id=p.id WHERE s.owner_id=? AND p.active=1 ORDER BY p.created_at DESC`,[req.user.id])
  res.json(linhas)
}))

app.put('/api/vendedor/farmacia', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const { name, description, cnpj, phone, email, address, city, state, zip_code, opening_hours, delivery_info, logo_url, banner_url } = req.body
  await conexoes.query('UPDATE farmacias SET nome=?,descricao=?,cnpj=?,telefone=?,email=?,endereco=?,cidade=?,estado=?,cep=?,horario_funcionamento=?,informacao_entrega=?,foto_perfil_url=?,imagem_capa_url=? WHERE proprietario_id=?', [name,description||null,cnpj,phone,email,address,city,state,zip_code,opening_hours||null,delivery_info||null,logo_url||null,banner_url||null,req.user.id])
  res.json({ message: 'Loja atualizada.' })
}))

app.get('/api/vendedor/produtos/sugestoes-cadastro', autenticar, exigirPerfil('seller'), asyncRoute(async (req,res)=>{
  const busca=String(req.query.busca||'').trim()
  if(busca.length<3)return res.json([])
  const termo=`%${busca.replace(/[%_]/g,'')}%`
  const [linhas]=await conexoes.query(`SELECT v.produto_id id,v.nome_oficial name,v.descricao_oficial description,v.categoria category,v.marca brand,v.tipo_medicamento medication_type,v.apresentacao presentation,v.dosagem dosage,v.aliases,v.atributos_verificados verified_attributes,v.claims_aprovados approved_claims,p.categoria_id category_id,p.tipo_medicamento_id medication_type_id,p.marca_id brand_id,CASE p.restricao_venda WHEN 'livre' THEN 'otc' WHEN 'vermelha_sem_retencao' THEN 'red_no_retention' WHEN 'vermelha_com_retencao' THEN 'red_retention' ELSE 'black' END sale_restriction,p.generico is_generic,d.volume,d.concentracao,d.genero_publico,d.notas_saida,d.notas_corpo,d.notas_fundo,d.destaque_1,d.destaque_2,d.destaque_3,d.destaque_4 FROM vw_produto_contexto_ia v JOIN produtos p ON p.id=v.produto_id LEFT JOIN detalhes_produtos d ON d.produto_id=p.id WHERE v.ativo=TRUE AND (v.nome_oficial LIKE ? OR v.aliases LIKE ?) ORDER BY CASE WHEN v.nome_oficial=? THEN 0 WHEN v.nome_oficial LIKE CONCAT(?,'%') THEN 1 ELSE 2 END,v.nome_oficial LIMIT 8`,[termo,termo,busca,busca])
  res.json(linhas)
}))

app.post('/api/vendedor/produtos', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const { name, description, category_id, medication_type_id, brand_id, dosage, presentation, sale_restriction='otc', is_generic=false, price, old_price, stock: estoque, image_url, volume, concentration, target_audience, top_notes, heart_notes, base_notes, highlight_1, highlight_2, highlight_3, highlight_4 } = req.body
  if (!name || !description || !category_id || !medication_type_id || !brand_id || price === undefined) return res.status(400).json({ message:'Nome, descrição, categoria, tipo, marca e preço são obrigatórios.' })
  const requiresPrescription=sale_restriction!=='otc'
  const produto=await executarTransacao(async conn=>{
    const [farmacias] = await conn.query('SELECT id FROM farmacias WHERE proprietario_id=?', [req.user.id])
    if (!farmacias[0]) throw Object.assign(new Error('Loja não encontrada.'),{status:404})
    const [resultado] = await conn.query('INSERT INTO produtos (farmacia_id,categoria_id,tipo_medicamento_id,marca_id,nome,descricao,dosagem,apresentacao,exige_receita,restricao_venda,generico,preco,preco_anterior,estoque,foto_url) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [farmacias[0].id,category_id,medication_type_id,brand_id,name,description,dosage||null,presentation||null,requiresPrescription,restricaoParaBanco[sale_restriction]||'livre',Boolean(is_generic),price,old_price||null,estoque||0,image_url||null])
    await conn.query('INSERT INTO detalhes_produtos (produto_id,volume,concentracao,genero_publico,notas_saida,notas_corpo,notas_fundo,destaque_1,destaque_2,destaque_3,destaque_4) VALUES (?,?,?,?,?,?,?,?,?,?,?)',[resultado.insertId,volume||null,concentration||null,target_audience||null,top_notes||null,heart_notes||null,base_notes||null,highlight_1||null,highlight_2||null,highlight_3||null,highlight_4||null])
    await sincronizarContextoIa(conn,resultado.insertId,req.body)
    return {id:resultado.insertId}
  })
  res.status(201).json({ ...produto, message: 'Produto e contexto da IA cadastrados.' })
}))

app.put('/api/vendedor/produtos/:id', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const { name, description, category_id, medication_type_id, brand_id, dosage, presentation, sale_restriction='otc', is_generic=false, price, old_price, stock: estoque, image_url, active, volume, concentration, target_audience, top_notes, heart_notes, base_notes, highlight_1, highlight_2, highlight_3, highlight_4 } = req.body
  if (!name || !description || !category_id || !medication_type_id || !brand_id || price === undefined) return res.status(400).json({ message:'Nome, descrição, categoria, tipo, marca e preço são obrigatórios.' })
  const requiresPrescription=sale_restriction!=='otc'
  await executarTransacao(async conn=>{
    const [resultado] = await conn.query(`UPDATE produtos p JOIN farmacias f ON f.id=p.farmacia_id SET p.nome=?,p.descricao=?,p.categoria_id=?,p.tipo_medicamento_id=?,p.marca_id=?,p.dosagem=?,p.apresentacao=?,p.exige_receita=?,p.restricao_venda=?,p.generico=?,p.preco=?,p.preco_anterior=?,p.estoque=?,p.foto_url=?,p.ativo=? WHERE p.id=? AND f.proprietario_id=?`, [name,description,category_id,medication_type_id,brand_id,dosage||null,presentation||null,requiresPrescription,restricaoParaBanco[sale_restriction]||'livre',Boolean(is_generic),price,old_price||null,estoque,image_url||null,active??1,req.params.id,req.user.id])
    if (!resultado.affectedRows) throw Object.assign(new Error('Produto não encontrado.'),{status:404})
    await conn.query(`INSERT INTO detalhes_produtos (produto_id,volume,concentracao,genero_publico,notas_saida,notas_corpo,notas_fundo,destaque_1,destaque_2,destaque_3,destaque_4) VALUES (?,?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE volume=VALUES(volume),concentracao=VALUES(concentracao),genero_publico=VALUES(genero_publico),notas_saida=VALUES(notas_saida),notas_corpo=VALUES(notas_corpo),notas_fundo=VALUES(notas_fundo),destaque_1=VALUES(destaque_1),destaque_2=VALUES(destaque_2),destaque_3=VALUES(destaque_3),destaque_4=VALUES(destaque_4)`,[req.params.id,volume||null,concentration||null,target_audience||null,top_notes||null,heart_notes||null,base_notes||null,highlight_1||null,highlight_2||null,highlight_3||null,highlight_4||null])
    await sincronizarContextoIa(conn,Number(req.params.id),req.body)
  })
  res.json({ message: 'Produto e contexto da IA atualizados.' })
}))

app.delete('/api/vendedor/produtos/:id', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const [resultado] = await conexoes.query('UPDATE produtos p JOIN farmacias f ON f.id=p.farmacia_id SET p.ativo=0 WHERE p.id=? AND f.proprietario_id=?', [req.params.id,req.user.id])
  if (!resultado.affectedRows) return res.status(404).json({ message: 'Produto não encontrado.' })
  res.status(204).end()
}))

app.patch('/api/vendedor/produtos/:id/estoque', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const estoque = Number(req.body.stock)
  if (!Number.isInteger(estoque) || estoque < 0) return res.status(400).json({ message:'Estoque inválido.' })
  const [resultado] = await conexoes.query('UPDATE produtos p JOIN farmacias f ON f.id=p.farmacia_id SET p.estoque=? WHERE p.id=? AND f.proprietario_id=?',[estoque,req.params.id,req.user.id])
  if (!resultado.affectedRows) return res.status(404).json({ message:'Produto não encontrado.' })
  res.json({ message:'Estoque atualizado.' })
}))

app.post('/api/vendedor/estoque/importar', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const linhas=req.body.rows
  if (!Array.isArray(linhas) || !linhas.length || linhas.length>2000) return res.status(400).json({message:'A planilha deve conter entre 1 e 2.000 linhas.'})
  const normalizados=linhas.map((row,index)=>({line:index+2,id:Number(String(row.sku||'').replace(/\D/g,'')),estoque:Number(row.stock)}))
  const invalidos=normalizados.filter(row=>!Number.isInteger(row.id)||row.id<1||!Number.isInteger(row.estoque)||row.estoque<0)
  if(invalidos.length)return res.status(400).json({message:`Dados inválidos nas linhas: ${invalidos.slice(0,10).map(row=>row.line).join(', ')}.`})
  const resultado=await executarTransacao(async conn=>{
    const ids=[...new Set(normalizados.map(row=>row.id))]
    const [pertencentes]=await conn.query(`SELECT p.id FROM produtos p JOIN farmacias f ON f.id=p.farmacia_id WHERE f.proprietario_id=? AND p.id IN (${ids.map(()=>'?').join(',')})`,[req.user.id,...ids])
    const ownedIds=new Set(pertencentes.map(row=>Number(row.id)));const ausentes=normalizados.filter(row=>!ownedIds.has(row.id))
    if(ausentes.length)throw Object.assign(new Error(`SKU não encontrado nesta loja nas linhas: ${ausentes.slice(0,10).map(row=>row.line).join(', ')}.`),{status:400})
    for(const row of normalizados)await conn.query('UPDATE produtos SET estoque=? WHERE id=?',[row.estoque,row.id])
    return {updated:normalizados.length}
  })
  res.json({...resultado,message:`${resultado.updated} produtos atualizados.`})
}))

app.post('/api/vendedor/vendas-balcao', autenticar, exigirPerfil('seller'), asyncRoute(async (req,res) => {
  const { product_id, product_name, dosage, sale_restriction, category, customer_name, price, quantity, prescription_url } = req.body
  const produtoId=product_id ? Number(product_id) : null
  const quantidade=quantity === '' || quantity == null ? null : Number(quantity)
  const preco=price === '' || price == null ? null : Number(price)
  if (produtoId && !Number.isInteger(produtoId)) return res.status(400).json({message:'Produto inválido.'})
  if (quantidade !== null && (!Number.isInteger(quantidade) || quantidade < 1)) return res.status(400).json({message:'A quantidade deve ser um número inteiro maior que zero.'})
  if (preco !== null && (!Number.isFinite(preco) || preco < 0)) return res.status(400).json({message:'Preço inválido.'})
  const venda=await executarTransacao(async conn=>{
    const [farmacias]=await conn.query('SELECT id FROM farmacias WHERE proprietario_id=?',[req.user.id])
    if(!farmacias[0])throw Object.assign(new Error('Loja não encontrada.'),{status:404})
    if(produtoId){
      const [produtos]=await conn.query('SELECT p.id,p.estoque FROM produtos p JOIN farmacias f ON f.id=p.farmacia_id WHERE p.id=? AND f.proprietario_id=? FOR UPDATE',[produtoId,req.user.id])
      if(!produtos[0])throw Object.assign(new Error('Produto não encontrado nesta loja.'),{status:404})
      if(quantidade !== null && produtos[0].estoque < quantidade)throw Object.assign(new Error('Estoque insuficiente para registrar esta venda.'),{status:409})
      if(quantidade !== null)await conn.query('UPDATE produtos SET estoque=estoque-? WHERE id=?',[quantidade,produtoId])
    }
    const [resultado]=await conn.query('INSERT INTO vendas_balcao (farmacia_id,produto_id,nome_produto,dosagem,restricao_venda,categoria,nome_cliente,preco,quantidade,receita_url) VALUES (?,?,?,?,?,?,?,?,?,?)',[farmacias[0].id,produtoId,String(product_name||'').trim()||null,String(dosage||'').trim()||null,String(sale_restriction||'').trim()||null,String(category||'').trim()||null,String(customer_name||'').trim()||null,preco,quantidade,String(prescription_url||'').trim()||null])
    return {id:resultado.insertId}
  })
  res.status(201).json({...venda,message:'Venda cadastrada com sucesso.'})
}))

app.get('/api/vendedor/bi-vendas', autenticar, exigirPerfil('seller'), asyncRoute(async (req,res) => {
  const owner=req.user.id
  const [resumo]=await conexoes.query(`SELECT SUM(source_count) sales_count,SUM(revenue) revenue,SUM(units) units,CASE WHEN SUM(source_count)>0 THEN SUM(revenue)/SUM(source_count) ELSE 0 END average_ticket,SUM(counter_count) counter_sales,SUM(online_count) online_sales FROM (
    SELECT COUNT(v.id) source_count,COALESCE(SUM(COALESCE(v.preco,0)*COALESCE(v.quantidade,1)),0) revenue,COALESCE(SUM(COALESCE(v.quantidade,0)),0) units,COUNT(v.id) counter_count,0 online_count FROM vendas_balcao v JOIN farmacias f ON f.id=v.farmacia_id WHERE f.proprietario_id=? AND v.criado_em>=DATE_FORMAT(CURRENT_DATE,'%Y-%m-01')
    UNION ALL
    SELECT COUNT(DISTINCT o.id),COALESCE(SUM(o.total),0),COALESCE(SUM((SELECT SUM(oi.quantidade) FROM itens_pedido oi WHERE oi.pedido_id=o.id)),0),0,COUNT(DISTINCT o.id) FROM pedidos o JOIN farmacias f ON f.id=o.farmacia_id WHERE f.proprietario_id=? AND o.situacao<>'cancelado' AND o.criado_em>=DATE_FORMAT(CURRENT_DATE,'%Y-%m-01')
  ) sources`,[owner,owner])
  const [dias]=await conexoes.query(`SELECT day,SUM(total) total,SUM(sales_count) sales_count FROM (
    SELECT DATE(v.criado_em) day,SUM(COALESCE(v.preco,0)*COALESCE(v.quantidade,1)) total,COUNT(*) sales_count FROM vendas_balcao v JOIN farmacias f ON f.id=v.farmacia_id WHERE f.proprietario_id=? AND v.criado_em>=CURRENT_DATE-INTERVAL 6 DAY GROUP BY DATE(v.criado_em)
    UNION ALL
    SELECT DATE(o.criado_em),SUM(o.total),COUNT(*) FROM pedidos o JOIN farmacias f ON f.id=o.farmacia_id WHERE f.proprietario_id=? AND o.situacao<>'cancelado' AND o.criado_em>=CURRENT_DATE-INTERVAL 6 DAY GROUP BY DATE(o.criado_em)
  ) sources GROUP BY day ORDER BY day`,[owner,owner])
  const [topProducts]=await conexoes.query(`SELECT name,SUM(units) units,SUM(revenue) revenue FROM (
    SELECT COALESCE(v.nome_produto,'Produto não informado') name,COALESCE(SUM(v.quantidade),0) units,COALESCE(SUM(COALESCE(v.preco,0)*COALESCE(v.quantidade,1)),0) revenue FROM vendas_balcao v JOIN farmacias f ON f.id=v.farmacia_id WHERE f.proprietario_id=? AND v.criado_em>=DATE_FORMAT(CURRENT_DATE,'%Y-%m-01') GROUP BY COALESCE(v.produto_id,0),COALESCE(v.nome_produto,'Produto não informado')
    UNION ALL
    SELECT oi.nome_produto,SUM(oi.quantidade),SUM(oi.preco_unitario*oi.quantidade) FROM itens_pedido oi JOIN pedidos o ON o.id=oi.pedido_id JOIN farmacias f ON f.id=o.farmacia_id WHERE f.proprietario_id=? AND o.situacao<>'cancelado' AND o.criado_em>=DATE_FORMAT(CURRENT_DATE,'%Y-%m-01') GROUP BY COALESCE(oi.produto_id,0),oi.nome_produto
  ) sources GROUP BY name ORDER BY units DESC,revenue DESC LIMIT 4`,[owner,owner])
  res.json({summary:resumo[0],days:dias,top_products:topProducts})
}))

app.get('/api/vendedor/relatorio-vendas', autenticar, exigirPerfil('seller'), asyncRoute(async (req,res) => {
  const source=['all','counter','online'].includes(String(req.query.source))?String(req.query.source):'all'
  const from=/^\d{4}-\d{2}-\d{2}$/.test(String(req.query.from||''))?String(req.query.from):null
  const to=/^\d{4}-\d{2}-\d{2}$/.test(String(req.query.to||''))?String(req.query.to):null
  const [farmacias]=await conexoes.query('SELECT id,nome,cnpj,endereco,cidade,estado FROM farmacias WHERE proprietario_id=?',[req.user.id])
  if(!farmacias[0])return res.status(404).json({message:'Loja não encontrada.'})
  const filters=[];const params=[]
  if(from){filters.push('DATE(sold_at)>=?');params.push(from)}
  if(to){filters.push('DATE(sold_at)<=?');params.push(to)}
  if(source!=='all'){filters.push('source=?');params.push(source)}
  const where=filters.length?`WHERE ${filters.join(' AND ')}`:''
  const [sales]=await conexoes.query(`SELECT * FROM (
    SELECT CONCAT('B-',v.id) receipt_number,v.id source_id,'counter' source,v.criado_em sold_at,COALESCE(v.nome_cliente,'Cliente não informado') customer,COALESCE(v.nome_produto,'Produto não informado') items,COALESCE(v.quantidade,0) units,COALESCE(v.preco,0)*COALESCE(v.quantidade,1) total,'completed' status,v.receita_url prescription_url
    FROM vendas_balcao v WHERE v.farmacia_id=?
    UNION ALL
    SELECT CONCAT('O-',o.id),o.id,'online',o.criado_em,u.nome,COALESCE((SELECT GROUP_CONCAT(CONCAT(oi.quantidade,'x ',oi.nome_produto) ORDER BY oi.id SEPARATOR ', ') FROM itens_pedido oi WHERE oi.pedido_id=o.id),'Sem itens'),COALESCE((SELECT SUM(oi.quantidade) FROM itens_pedido oi WHERE oi.pedido_id=o.id),0),o.total,CASE o.situacao WHEN 'cancelado' THEN 'cancelled' ELSE 'completed' END,NULL
    FROM pedidos o JOIN usuarios u ON u.id=o.consumidor_id WHERE o.farmacia_id=?
  ) sales ${where} ORDER BY sold_at DESC`,[farmacias[0].id,farmacias[0].id,...params])
  res.json({store:farmacias[0],sales})
}))

app.post('/api/pedidos', autenticar, exigirPerfil('consumer'), asyncRoute(async (req, res) => {
  const { items: itens, address_id, payment_method } = req.body
  if (!Array.isArray(itens) || !itens.length) return res.status(400).json({ message: 'O pedido não possui itens.' })
  const pedido = await executarTransacao(async conn => {
    const ids = itens.map(item => item.product_id)
    const [produtos] = await conn.query(`SELECT id,farmacia_id store_id,nome name,preco price,estoque stock FROM produtos WHERE ativo=1 AND id IN (${ids.map(()=>'?').join(',')}) FOR UPDATE`, ids)
    if (produtos.length !== ids.length) throw Object.assign(new Error('Um produto não está mais disponível.'), { status: 409 })
    let total = 0
    for (const item of itens) { const produto=produtos.find(p=>p.id===item.product_id); if (produto.stock<item.quantity) throw Object.assign(new Error(`Estoque insuficiente para ${produto.name}.`),{status:409}); total += produto.price*item.quantity }
    const [resultado] = await conn.query('INSERT INTO pedidos (consumidor_id,farmacia_id,endereco_id,forma_pagamento,total,situacao) VALUES (?,?,?,?,?,?)', [req.user.id,produtos[0].store_id,address_id,pagamentoParaBanco[payment_method]||'pix',total,'novo'])
    for (const item of itens) { const produto=produtos.find(p=>p.id===item.product_id); await conn.query('INSERT INTO itens_pedido (pedido_id,produto_id,nome_produto,preco_unitario,quantidade) VALUES (?,?,?,?,?)',[resultado.insertId,produto.id,produto.name,produto.price,item.quantity]); await conn.query('UPDATE produtos SET estoque=estoque-? WHERE id=?',[item.quantity,produto.id]) }
    return { id: resultado.insertId, total }
  })
  res.status(201).json(pedido)
}))

app.get('/api/pedidos', autenticar, asyncRoute(async (req, res) => {
  const condition = req.user.role === 'seller' ? 's.owner_id=?' : 'o.consumer_id=?'
  const [linhas] = await conexoes.query(`SELECT o.*,u.name consumer_name,s.name store_name,
    CONCAT_WS(', ',a.street,a.number,a.complement,a.district,a.city,a.state) delivery_address,
    (SELECT COALESCE(SUM(oi.quantity),0) FROM order_items oi WHERE oi.order_id=o.id) item_count,
    (SELECT GROUP_CONCAT(CONCAT(oi.quantity,'x ',oi.product_name) ORDER BY oi.id SEPARATOR ', ') FROM order_items oi WHERE oi.order_id=o.id) items_summary
    FROM orders o JOIN users u ON u.id=o.consumer_id JOIN stores s ON s.id=o.store_id
    LEFT JOIN addresses a ON a.id=o.address_id WHERE ${condition} ORDER BY o.created_at DESC`, [req.user.id])
  res.json(linhas)
}))

app.get('/api/pedidos/:id', autenticar, asyncRoute(async (req, res) => {
  const [orders] = await conexoes.query(`SELECT o.*,u.name consumer_name,s.name store_name,a.label,a.street,a.number,a.district,a.city,a.state,a.zip_code FROM orders o JOIN users u ON u.id=o.consumer_id JOIN stores s ON s.id=o.store_id LEFT JOIN addresses a ON a.id=o.address_id WHERE o.id=? AND (o.consumer_id=? OR s.owner_id=?)`, [req.params.id,req.user.id,req.user.id])
  if (!orders[0]) return res.status(404).json({ message: 'Pedido não encontrado.' })
  const [itens] = await conexoes.query('SELECT * FROM order_items WHERE order_id=?', [req.params.id])
  res.json({ ...orders[0], itens })
}))

app.patch('/api/vendedor/pedidos/:id/situacao', autenticar, exigirPerfil('seller'), asyncRoute(async (req, res) => {
  const permitidos = ['new','preparing','shipped','completed','cancelled']
  if (!permitidos.includes(req.body.status)) return res.status(400).json({ message: 'Status inválido.' })
  const [resultado] = await conexoes.query('UPDATE pedidos p JOIN farmacias f ON f.id=p.farmacia_id SET p.situacao=? WHERE p.id=? AND f.proprietario_id=?', [situacaoParaBanco[req.body.status],req.params.id,req.user.id])
  if (!resultado.affectedRows) return res.status(404).json({ message: 'Pedido não encontrado.' })
  res.json({ message: 'Status atualizado.' })
}))

app.use((erro, _req, res, _next) => { console.error(erro);if(erro.code==='ER_DUP_ENTRY')return res.status(409).json({message:'Esta opção já está cadastrada.'});if(erro instanceof multer.MulterError)return res.status(400).json({message:erro.code==='LIMIT_FILE_SIZE'?'A imagem deve ter no máximo 5 MB.':'Não foi possível enviar a imagem.'});res.status(erro.status || 500).json({ message: erro.status ? erro.message : 'Erro interno do servidor.' }) })
const port = Number(process.env.PORT || 3001)
const servidorHttp = app.listen(port, () => console.log(`API Farma&Farma em http://localhost:${port}`))
servidorHttp.ref()
const manterApiAtiva = setInterval(() => {}, 60_000)

const encerrarServidor = sinal => {
  console.log(`\n${sinal} recebido. Encerrando a API...`)
  clearInterval(manterApiAtiva)
  servidorHttp.close(() => process.exit(0))
}

process.on('SIGINT', () => encerrarServidor('SIGINT'))
process.on('SIGTERM', () => encerrarServidor('SIGTERM'))
