import { expect, type Page, type Locator } from '@playwright/test';

// Todos os seletores da interface ficam neste arquivo.
// Se a loja mudar um texto ou a estrutura, basta ajustar aqui.

/** Card do produto na listagem: o menor elemento que contém o nome e um botão. */
export function cardDoProduto(page: Page, nome: string): Locator {
  return page.locator(`xpath=//*[normalize-space(text())="${nome}"]/ancestor::*[.//button][1]`);
}

export async function irParaProdutos(page: Page) {
  await page.goto('/');
  await expect(page.getByText('Mochila Urbana 20L').first()).toBeVisible();
}

export async function adicionarAoCarrinho(page: Page, nomeProduto: string, vezes = 1) {
  const botao = cardDoProduto(page, nomeProduto).getByRole('button', { name: 'Adicionar ao carrinho' });
  for (let i = 0; i < vezes; i++) {
    await botao.click();
  }
}

export async function abrirCarrinho(page: Page) {
  await page.getByRole('link', { name: /Carrinho/ }).click();
  await expect(page.getByRole('heading', { name: 'Carrinho', exact: true })).toBeVisible();
}

export async function aplicarCupom(page: Page, codigo: string) {
  await page.getByRole('textbox', { name: /cupom/i }).fill(codigo);
  await page.getByRole('button', { name: /aplicar/i }).click();
}

/** Bloco "Resumo do pedido" (subtotal, desconto, frete, total). Na página é uma região (region) com esse nome. */
export function resumoDoPedido(page: Page): Locator {
  return page.getByRole('region', { name: 'Resumo do pedido' });
}