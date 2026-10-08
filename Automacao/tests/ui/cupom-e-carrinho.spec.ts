import { test, expect } from '@playwright/test';
import {
  irParaProdutos, adicionarAoCarrinho, abrirCarrinho, aplicarCupom, resumoDoPedido, cardDoProduto,
} from './paginas';

test.describe('UI: cupom e carrinho', () => {
  test('TC001: aplicar o cupom válido BEMVINDO10',
    { tag: ['@TC001', '@CA01', '@CA09'] },
    async ({ page }) => {
      await irParaProdutos(page);
      await adicionarAoCarrinho(page, 'Mochila Urbana 20L');
      await abrirCarrinho(page);

      await aplicarCupom(page, 'BEMVINDO10');

      // Mensagem de cupom aplicado
      await expect(page.getByText(/Cupom\s+BEMVINDO10\s+aplicado/)).toBeVisible();

      // Desconto de 10% sobre o subtotal (não incide sobre o frete)
      const resumo = resumoDoPedido(page);
      await expect(resumo).toContainText(/Subtotal\s*R\$\s*100,00/);
      await expect(resumo).toContainText(/Desconto \(BEMVINDO10\)\s*[-–−]\s*R\$\s*10,00/);
      await expect(resumo).toContainText(/Frete\s*R\$\s*19,90/);
      await expect(resumo).toContainText(/Total\s*R\$\s*109,90/);
    });

  test('TC011: limite de 5 unidades por produto',
    { tag: ['@TC011', '@CA10'] },
    async ({ page }) => {
      await irParaProdutos(page);
      await adicionarAoCarrinho(page, 'Tênis Casual Urbano', 5);

      // A 6ª unidade é impedida: botão desabilitado e mensagem de limite
      const card = cardDoProduto(page, 'Tênis Casual Urbano');
      await expect(card.getByRole('button', { name: 'Adicionar ao carrinho' })).toBeDisabled();
      await expect(card).toContainText('Limite de 5 unidades atingido.');

      // O carrinho permanece com 5 unidades (5 x R$ 189,90 = R$ 949,50), com frete grátis
      await abrirCarrinho(page);
      const resumo = resumoDoPedido(page);
      await expect(resumo).toContainText(/Subtotal\s*R\$\s*949,50/);
      await expect(resumo).toContainText(/Frete\s*Grátis/);
      await expect(resumo).toContainText(/Total\s*R\$\s*949,50/);
    });
});