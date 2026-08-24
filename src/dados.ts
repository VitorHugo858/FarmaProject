export type Produto = {
  id: number; name: string; category: string; price: number; oldPrice?: number;
  stock: number; rating: number; reviews: number; icon: string; color: string; tag?: string;
  description?: string; medicationTypeId?: number; medicationType?: string; brandId?: number; brand?: string;
  dosage?: string; presentation?: string; requiresPrescription?: boolean;
  saleRestriction?: 'otc'|'red_no_retention'|'red_retention'|'black'; isGeneric?: boolean; imageUrl?: string;
  storeId?: number; storeName?: string;
  volume?: string; concentration?: string; targetAudience?: string;
  topNotes?: string; heartNotes?: string; baseNotes?: string; highlights?: string[];
  aiAliases?: string[]; aiAttributes?: {name:string;value:string;unit?:string}[]; aiClaims?: string[]; aiContentApproved?: boolean;
}

export const categorias = [
  { name: 'Medicamentos', icon: 'pill', color: '#dff3ec' },
  { name: 'Vitaminas', icon: 'sparkles', color: '#fff0ce' },
  { name: 'Beleza', icon: 'heart', color: '#fce3e8' },
  { name: 'Mamãe & Bebê', icon: 'baby', color: '#e4edfb' },
  { name: 'Higiene', icon: 'bath', color: '#e1f5f4' },
]

export const produtosIniciais: Produto[] = [
  { id: 1, name: 'Vitamina C 1000mg', category: 'Vitaminas', price: 34.90, oldPrice: 42.90, stock: 28, rating: 4.9, reviews: 126, icon: 'vitamin', color: '#ffd55f', tag: 'Mais vendido' },
  { id: 2, name: 'Protetor Solar FPS 70', category: 'Beleza', price: 59.90, stock: 12, rating: 4.8, reviews: 89, icon: 'sunscreen', color: '#ed9672', tag: 'Oferta' },
  { id: 3, name: 'Fraldas Premium M', category: 'Mamãe & Bebê', price: 74.50, oldPrice: 89.90, stock: 34, rating: 4.7, reviews: 54, icon: 'diaper', color: '#82b8dc' },
  { id: 4, name: 'Shampoo Nutritivo', category: 'Higiene', price: 26.90, stock: 19, rating: 4.6, reviews: 71, icon: 'bottle', color: '#b79ad7' },
  { id: 5, name: 'Ômega 3 1000mg', category: 'Vitaminas', price: 45.90, stock: 8, rating: 4.9, reviews: 103, icon: 'omega', color: '#db994d', tag: 'Últimas unidades' },
  { id: 6, name: 'Kit Higiene Bucal', category: 'Higiene', price: 19.90, stock: 45, rating: 4.5, reviews: 42, icon: 'dental', color: '#5db6a6' },
]
