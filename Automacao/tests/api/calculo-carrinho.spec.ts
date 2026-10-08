import { test, expect } from '@playwright/test';

const ROTA = '/api/carrinho/calcular';

test.describe('API: cálculo do carrinho', () => {
  test('TC021: cálculo com cupom e frete grátis (exemplo da documentação)',
    { tag: ['@TC021', '@CA01', '@CA06', '@CA11'] },
    async ({ request }) => {
      const resposta = await request.post(ROTA, {
        data: {
          itens: [
            { produtoId: 'P002', quantidade: 1 },
            { produtoId: 'P004', quantidade: 2 },
          ],
          cupom: 'BEMVINDO10',
        },
      });

      expect(resposta.status()).toBe(200);
      const corpo = await resposta.json();
      expect(corpo).toMatchObject({
        subtotal: 239.7,
        desconto: 23.97,
        frete: 0,
        freteGratis: true,
        valorFaltanteFreteGratis: 0,
        total: 215.73,
      });
      expect(corpo.cupom).toMatchObject({ codigo: 'BEMVINDO10', aplicado: true });
    });

  test('TC022a: subtotal de R$ 199,80 cobra frete fixo',
    { tag: ['@TC022', '@CA07'] },
    async ({ request }) => {
      const resposta = await request.post(ROTA, {
        data: {
          itens: [
            { produtoId: 'P002', quantidade: 1 },
            { produtoId: 'P001', quantidade: 1 },
          ],
        },
      });

      expect(resposta.status()).toBe(200);
      expect(await resposta.json()).toMatchObject({
        subtotal: 199.8,
        frete: 19.9,
        freteGratis: false,
        valorFaltanteFreteGratis: 0.2,
        total: 219.7,
      });
    });

  test('TC022b: subtotal de exatamente R$ 200,00 tem frete grátis (BUG CONHECIDO)',
    { tag: ['@TC022', '@CA06', '@bug-conhecido'] },
    async ({ request }) => {
      // BUG: o frete grátis não é aplicado quando o subtotal é exatamente R$ 200,00 (CA06 diz "inclusive").
      // O teste está marcado como "falha esperada": ele passa enquanto o bug existir
      // e começa a falhar quando o bug for corrigido, avisando que a marcação deve ser removida.
      test.fail(true, 'Bug conhecido: frete grátis não aplicado com subtotal igual a R$ 200,00 (ver docs/03-bugs)');

      const resposta = await request.post(ROTA, {
        data: { itens: [{ produtoId: 'P005', quantidade: 2 }] },
      });

      expect(resposta.status()).toBe(200);
      expect(await resposta.json()).toMatchObject({
        subtotal: 200,
        frete: 0,
        freteGratis: true,
        valorFaltanteFreteGratis: 0,
        total: 200,
      });
    });
});
