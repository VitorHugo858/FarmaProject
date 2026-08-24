const API_URL = import.meta.env.VITE_API_URL || '/api'

export type Sessao = { token: string; user: { id: number; name: string; email: string; role: 'consumer' | 'seller' } }
export type ProdutoApi = { id:number; store_id:number;store_name?:string;name:string; category:string; category_id:number; price:number; old_price?:number; stock:number; rating:number; review_count:number; image_url?:string; description?:string; medication_type_id?:number; medication_type?:string; brand_id?:number; brand?:string; dosage?:string; presentation?:string; requires_prescription?:boolean; sale_restriction?:'otc'|'red_no_retention'|'red_retention'|'black';is_generic?:boolean;volume?:string;concentracao?:string;genero_publico?:string;notas_saida?:string;notas_corpo?:string;notas_fundo?:string;destaque_1?:string;destaque_2?:string;destaque_3?:string;destaque_4?:string;aliases_contexto?:string;atributos_contexto?:string;claims_contexto?:string;contexto_aprovado?:boolean }
export type OpcaoCatalogo = { id:number;name:string;description?:string;manufacturer?:string }
export type PedidoApi = { id:number; consumer_name:string; store_name:string; total:number; status:string; created_at:string;item_count:number;items_summary?:string;delivery_address?:string;payment_method?:string }
export type UsuarioApi = { id:number; name:string; email:string; role:'consumer'|'seller'; phone?:string; cpf?:string }
export type EnderecoApi = { id:number;label:string;recipient?:string;street:string;number:string;complement?:string;district:string;city:string;state:string;zip_code:string;is_default:boolean }
export type FarmaciaApi = { id:number;name:string;description?:string;cnpj?:string;phone?:string;email?:string;address?:string;city?:string;state?:string;zip_code?:string;opening_hours?:string;delivery_info?:string;logo_url?:string;banner_url?:string;rating?:number;verified?:boolean }
export type FarmaciaPublica = FarmaciaApi & {produtos:ProdutoApi[]}
export type ClienteWhatsapp = { id:number;phone:string;name?:string }
export type MensagemWhatsapp = { id:number;conversationId:number;direction:'INBOUND'|'OUTBOUND';senderType:string;content:string;createdAt:string }
export type ConversaWhatsapp = { id:number;status:'OPEN'|'CLOSED';mode:'AI'|'HUMAN';lastMessageAt:string;customer:ClienteWhatsapp;lastMessage?:MensagemWhatsapp;messageCount:number }
export type DetalhesConversaWhatsapp = { conversation:ConversaWhatsapp;messages:MensagemWhatsapp[] }
export type PedidoWhatsappResultado = { vendas:number[];total:number;itens:{produto_id:number;quantidade:number}[];mensagem_whatsapp:MensagemWhatsapp|null;aviso:string|null;message:string }
export type SugestaoCadastroProduto = {id:number;name:string;description:string;category:string;category_id:number;brand?:string;brand_id?:number;medication_type?:string;medication_type_id?:number;presentation?:string;dosage?:string;aliases?:string;verified_attributes?:string;approved_claims?:string;sale_restriction?:string;is_generic?:boolean;volume?:string;concentracao?:string;genero_publico?:string;notas_saida?:string;notas_corpo?:string;notas_fundo?:string;destaque_1?:string;destaque_2?:string;destaque_3?:string;destaque_4?:string}
export type BiVendasApi = {summary:{sales_count:number;revenue:number;units:number;average_ticket:number;counter_sales:number;online_sales:number};days:{day:string;total:number;sales_count:number}[];top_products:{name:string;units:number;revenue:number}[]}
export type VendaRelatorioApi = {receipt_number:string;source_id:number;source:'counter'|'online';sold_at:string;customer:string;items:string;units:number;total:number;status:'completed'|'cancelled';prescription_url?:string}
export type RelatorioVendasApi = {store:{id:number;nome:string;cnpj?:string;endereco?:string;cidade?:string;estado?:string};sales:VendaRelatorioApi[]}
export const obterSessao = (): Sessao | null => JSON.parse(localStorage.getItem('farma-session') || 'null')

async function requisicao<T>(path: string, options: RequestInit = {}): Promise<T> {
  const token = obterSessao()?.token
  let response: Response
  try {
    response = await fetch(`${API_URL}${path}`, { ...options, headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}), ...options.headers } })
  } catch {
    throw new Error('Não foi possível conectar à API. Verifique se o MySQL do XAMPP está ativo e execute npm run dev:all.')
  }
  if (!response.ok) { const body = await response.json().catch(() => ({})); throw new Error(body.message || 'Não foi possível concluir a operação.') }
  return response.status === 204 ? undefined as T : response.json()
}

export const api = {
  entrar: (email:string,password:string) => requisicao<Sessao>('/auth/entrar',{method:'POST',body:JSON.stringify({email,password})}),
  cadastrar: (data:object) => requisicao<Sessao>('/auth/cadastrar',{method:'POST',body:JSON.stringify(data)}),
  me: () => requisicao<UsuarioApi>('/me'),
  atualizarMeuPerfil: (data:object) => requisicao('/me',{method:'PUT',body:JSON.stringify(data)}),
  produtos: () => requisicao<ProdutoApi[]>('/produtos'),
  produtosVendedor: () => requisicao<ProdutoApi[]>('/vendedor/produtos'),
  sugestoesCadastroProduto: (busca:string) => requisicao<SugestaoCadastroProduto[]>(`/vendedor/produtos/sugestoes-cadastro?${new URLSearchParams({busca}).toString()}`),
  criarProduto: (data:object) => requisicao<{id:number}>('/vendedor/produtos',{method:'POST',body:JSON.stringify(data)}),
  atualizarProduto: (id:number,data:object) => requisicao(`/vendedor/produtos/${id}`,{method:'PUT',body:JSON.stringify(data)}),
  atualizarEstoque: (id:number,stock:number) => requisicao(`/vendedor/produtos/${id}/estoque`,{method:'PATCH',body:JSON.stringify({stock})}),
  importarEstoque: (rows:{sku:string;product?:string;stock:number}[]) => requisicao<{updated:number;message:string}>('/vendedor/estoque/importar',{method:'POST',body:JSON.stringify({rows})}),
  cadastrarVendaBalcao: (data:object) => requisicao<{id:number;message:string}>('/vendedor/vendas-balcao',{method:'POST',body:JSON.stringify(data)}),
  biVendas: () => requisicao<BiVendasApi>('/vendedor/bi-vendas'),
  relatorioVendas: (filters:{from?:string;to?:string;source?:string}) => requisicao<RelatorioVendasApi>(`/vendedor/relatorio-vendas?${new URLSearchParams(Object.entries(filters).filter(([,value])=>value) as [string,string][]).toString()}`),
  excluirProduto: (id:number) => requisicao<void>(`/vendedor/produtos/${id}`,{method:'DELETE'}),
  pedidos: () => requisicao<PedidoApi[]>('/pedidos'),
  atualizarSituacaoPedido: (id:number,status:string) => requisicao(`/vendedor/pedidos/${id}/situacao`,{method:'PATCH',body:JSON.stringify({status})}),
  enderecos: () => requisicao<EnderecoApi[]>('/enderecos'),
  criarEndereco: (data:object) => requisicao<{id:number}>('/enderecos',{method:'POST',body:JSON.stringify(data)}),
  atualizarEndereco: (id:number,data:object) => requisicao(`/enderecos/${id}`,{method:'PUT',body:JSON.stringify(data)}),
  farmacia: () => requisicao<FarmaciaApi>('/vendedor/farmacia'),
  farmacias: () => requisicao<FarmaciaApi[]>('/farmacias'),
  farmaciaPublica: (id:number) => requisicao<FarmaciaPublica>(`/farmacias/${id}`),
  atualizarFarmacia: (data:object) => requisicao('/vendedor/farmacia',{method:'PUT',body:JSON.stringify(data)}),
  favoritos: () => requisicao<number[]>('/favoritos'),
  adicionarFavorito: (id:number) => requisicao(`/favoritos/${id}`,{method:'POST'}),
  removerFavorito: (id:number) => requisicao<void>(`/favoritos/${id}`,{method:'DELETE'}),
  criarPedido: (data:object) => requisicao('/pedidos',{method:'POST',body:JSON.stringify(data)}),
  salvarSessao: (session:Sessao) => localStorage.setItem('farma-session',JSON.stringify(session)),
  sair: () => localStorage.removeItem('farma-session'),
  tiposMedicamento: () => requisicao<OpcaoCatalogo[]>('/tipos-medicamento'),
  marcas: () => requisicao<OpcaoCatalogo[]>('/marcas'),
  criarTipoMedicamento: (data:object) => requisicao<OpcaoCatalogo>('/vendedor/tipos-medicamento',{method:'POST',body:JSON.stringify(data)}),
  criarMarca: (data:object) => requisicao<OpcaoCatalogo>('/vendedor/marcas',{method:'POST',body:JSON.stringify(data)}),
  enviarImagemProduto: async (file:File) => { const form=new FormData();form.append('image',file);let response:Response;try{response=await fetch(`${API_URL}/vendedor/imagem-produto`,{method:'POST',headers:{Authorization:`Bearer ${obterSessao()?.token||''}`},body:form})}catch{throw new Error('Não foi possível enviar a imagem.')}const body=await response.json().catch(()=>({}));if(!response.ok)throw new Error(body.message||'Falha no upload da imagem.');return body as {image_url:string} },
  enviarImagemFarmacia: async (file:File) => { const form=new FormData();form.append('image',file);let response:Response;try{response=await fetch(`${API_URL}/vendedor/imagem-farmacia`,{method:'POST',headers:{Authorization:`Bearer ${obterSessao()?.token||''}`},body:form})}catch{throw new Error('Não foi possível enviar a imagem.')}const body=await response.json().catch(()=>({}));if(!response.ok)throw new Error(body.message||'Falha no upload da imagem.');return body as {image_url:string} },
  enviarImagemReceita: async (file:File) => { const form=new FormData();form.append('image',file);let response:Response;try{response=await fetch(`${API_URL}/vendedor/imagem-receita`,{method:'POST',headers:{Authorization:`Bearer ${obterSessao()?.token||''}`},body:form})}catch{throw new Error('Não foi possível enviar a receita.')}const body=await response.json().catch(()=>({}));if(!response.ok)throw new Error(body.message||'Falha no upload da receita.');return body as {image_url:string} },
  statusWhatsapp: () => requisicao<{connected:boolean;status:string}>('/vendedor/whatsapp/status'),
  conversasWhatsapp: () => requisicao<ConversaWhatsapp[]>('/vendedor/whatsapp/conversas'),
  mensagensWhatsapp: (id:number) => requisicao<DetalhesConversaWhatsapp>(`/vendedor/whatsapp/conversas/${id}/mensagens`),
  enviarMensagemWhatsapp: (id:number,content:string) => requisicao<MensagemWhatsapp>(`/vendedor/whatsapp/conversas/${id}/mensagens`,{method:'POST',body:JSON.stringify({content})}),
  confirmarPedidoWhatsapp: (id:number,itens:{produto_id:number;quantidade:number}[]) => requisicao<PedidoWhatsappResultado>(`/vendedor/whatsapp/conversas/${id}/pedido`,{method:'POST',body:JSON.stringify({itens})}),
}
