import { test, expect } from '@playwright/test';

const ROTA = '/api/carrinho/calcular';

test.describe('API: quantidade máxima por produto (CA10)', () => {
  test('TC024a: 5 unidades de um produto são aceitas',
    { tag: ['@TC024', '@CA10'] },
    async ({ request }) => {
      const resposta = await request.post(ROTA, {
        data: { itens: [{ produtoId: 'P003', quantidade: 5 }] },
      });

      expect(resposta.status()).toBe(200);
      expect(await resposta.json()).toMatchObject({ subtotal: 949.5, total: 949.5 });
    });

  test('TC024b: 6 unidades de um produto são rejeitadas (BUG CONHECIDO)',
    { tag: ['@TC024', '@CA10', '@bug-conhecido'] },
    async ({ request }) => {
      // BUG: a API aceita quantidades maiores que 5, contrariando o CA10.
      test.fail(true, 'Bug conhecido: API aceita quantidade maior que 5 (ver docs/03-bugs)');

      const resposta = await request.post(ROTA, {
        data: { itens: [{ produtoId: 'P003', quantidade: 6 }] },
      });

      expect(resposta.status()).toBe(422);
      const corpo = await resposta.json();
      expect(corpo.erro.codigo).toBe('QUANTIDADE_MAXIMA_EXCEDIDA');
      expect(corpo.erro.campo).toBe('itens[0].quantidade');
    });
});
