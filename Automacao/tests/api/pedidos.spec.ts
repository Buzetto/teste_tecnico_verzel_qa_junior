import { test, expect } from '@playwright/test';

const ROTA = '/api/pedidos';
const cliente = { nome: 'Maria Silva', email: 'maria@exemplo.com', cep: '01310-100' };
const itens = [{ produtoId: 'P005', quantidade: 1 }];

test.describe('API: pedidos', () => {
  test('TC027: criar um pedido válido com cupom',
    { tag: ['@TC027', '@CA01'] },
    async ({ request }) => {
      const resposta = await request.post(ROTA, { data: { cliente, itens, cupom: 'BEMVINDO10' } });

      expect(resposta.status()).toBe(201);
      const corpo = await resposta.json();
      expect(corpo.numero).toMatch(/^VZ-\d{6}$/);
      expect(corpo).toMatchObject({
        subtotal: 100,
        desconto: 10,
        frete: 19.9,
        valorFaltanteFreteGratis: 100,
        total: 109.9,
      });
      // O CEP volta apenas com dígitos
      expect(corpo.cliente.cep).toBe('01310100');
    });

  const cuponsRejeitados = [
    { cupom: 'XYZ123', codigo: 'CUPOM_INVALIDO', caso: 'TC028a: cupom inexistente' },
    { cupom: 'VERAO2026', codigo: 'CUPOM_EXPIRADO', caso: 'TC028b: cupom expirado' },
  ];

  for (const { cupom, codigo, caso } of cuponsRejeitados) {
    test(`${caso} gera erro 422 no pedido`,
      { tag: ['@TC028', '@CA03', '@CA04'] },
      async ({ request }) => {
        const resposta = await request.post(ROTA, { data: { cliente, itens, cupom } });

        // Diferente do cálculo do carrinho (200), o pedido com cupom inválido deve falhar.
        expect(resposta.status()).toBe(422);
        expect((await resposta.json()).erro.codigo).toBe(codigo);
      });
  }
});
