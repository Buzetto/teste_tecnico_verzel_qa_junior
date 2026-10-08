# Teste técnico QA Júnior: Verzel Store (VZS-142)

**Autor:** Victor Augusto Buzetto

Validação da entrega **cupom de desconto e frete grátis** (versão 2.3.0) da Verzel Store: cenários de teste, execução manual e exploratória, bugs encontrados, evidências e automação com Playwright.

- **Loja:** https://verzel-store.qa-test-verzel-store.workers.dev/
- **Documentação da entrega:** https://verzel-store.qa-test-verzel-store.workers.dev/documentacao
- **API:** https://verzel-store.qa-test-verzel-store.workers.dev/api

## Resumo da execução

| Item | Quantidade |
|---|---|
| Cenários planejados | 30 |
| Aprovados | 28 |
| Reprovados (com bug) | 2 |
| Bugs registrados | 2 |
| Melhorias registradas | 2 |
| Cenários automatizados com Playwright | 10 |

## Bugs encontrados

1. **Frete grátis não é aplicado quando o subtotal é exatamente R$ 200,00** (CA06 diz "a partir de R$ 200,00, inclusive"). Cenários: TC008, TC010 e TC022.
2. **A API aceita quantidade maior que 5 por produto** em `/api/carrinho/calcular` (CA10). Cenário: TC024.

Passos de reprodução, severidade, prioridade e prints de cada bug estão em [`docs/03-bugs/`](docs/03-bugs/).

## Onde encontrar cada entrega

| Entrega pedida | Onde está |
|---|---|
| Cenários de teste (30 casos, TC001 a TC030) | [`docs/01-cenarios/casos-de-teste.md`](docs/01-cenarios/casos-de-teste.md) |
| Cenários em formato Azure DevOps (importação) | [`docs/01-cenarios/casos-de-teste-azure-devops.xlsx`](docs/01-cenarios/casos-de-teste-azure-devops.xlsx) e `.csv` |
| Cenários em Gherkin | [`docs/01-cenarios/gherkin/`](docs/01-cenarios/gherkin/) (5 arquivos `.feature`) |
| Execução dos testes e evidências (resultado de cada cenário, com prints) | [`docs/02-evidencias/`](docs/02-evidencias/) |
| Report dos bugs encontrados | [`docs/03-bugs/`](docs/03-bugs/) |
| Automação com Playwright | [`automacao/`](automacao/) |

## Ambiente em que os testes foram executados

| Item | Valor |
|---|---|
| Data dos testes | 07/10/2026 |
| Versão testada | 2.3.0 (card VZS-142) |
| Sistema operacional | Windows 11 |
| Navegador | Chrome 154.0.8037.98 |

## Como os cenários estão organizados

Os 30 casos cobrem todos os critérios de aceite (CA01 a CA11), as regras de cliente já existentes (nome, e-mail e CEP) e os códigos de erro da API. Cada caso tem referência ao critério de aceite e tipo (UI ou API). As ambiguidades da documentação e a interpretação adotada para cada uma estão no fim do arquivo `casos-de-teste.md`.

Os arquivos Gherkin usam as tags `@TCxxx` e `@CAxx`, que ligam cada cenário ao caso de teste e ao critério de aceite correspondentes.

## Como rodar a automação

**Pré-requisito:** Node.js 18 ou superior.

```bash
cd automacao
npm install
npm run browsers      # baixa o Chromium (necessário só para os testes de interface)
npm test              # roda tudo (API e interface)
```

Outros comandos:

| Comando | O que faz |
|---|---|
| `npm run test:api` | Roda só os testes de API (não precisa de navegador) |
| `npm run test:ui` | Roda só os testes de interface |
| `npm run test:headed` | Roda a interface com o navegador visível |
| `npm run report` | Abre o relatório HTML da última execução |

Para apontar para outra URL da loja: `BASE_URL=https://outra-url npm test`.

## Cenários automatizados

| Caso | Tipo | Arquivo | O que valida |
|---|---|---|---|
| TC001 | UI | `tests/ui/cupom-e-carrinho.spec.ts` | Aplicar BEMVINDO10: mensagem, desconto de R$ 10,00, frete e total |
| TC011 | UI | `tests/ui/cupom-e-carrinho.spec.ts` | Limite de 5 unidades: botão desabilitado, mensagem de limite e carrinho com 5 |
| TC021 | API | `tests/api/calculo-carrinho.spec.ts` | Cálculo com cupom e frete grátis (exemplo da documentação) |
| TC022a | API | `tests/api/calculo-carrinho.spec.ts` | Subtotal de R$ 199,80 cobra frete fixo |
| TC022b | API | `tests/api/calculo-carrinho.spec.ts` | Subtotal de R$ 200,00 deve ter frete grátis (**bug conhecido**) |
| TC024a | API | `tests/api/quantidade-maxima.spec.ts` | 5 unidades são aceitas |
| TC024b | API | `tests/api/quantidade-maxima.spec.ts` | 6 unidades devem ser rejeitadas (**bug conhecido**) |
| TC027 | API | `tests/api/pedidos.spec.ts` | Criar pedido válido com cupom (status 201, número, valores e CEP) |
| TC028a/b | API | `tests/api/pedidos.spec.ts` | Pedido com cupom inexistente ou expirado retorna 422 |

### Testes de bugs conhecidos

Os testes **TC022b** e **TC024b** descrevem o comportamento correto pela documentação, mas o sistema ainda tem o bug. Por isso estão marcados com `test.fail()` (falha esperada):

- Enquanto o bug existir, o teste aparece como **aprovado** no relatório, porque a falha é esperada.
- Quando o bug for corrigido, o teste passa a **falhar** com a mensagem "Expected to fail, but passed". É o sinal de que a marcação `test.fail()` deve ser removida.

## Observações

- O ambiente é compartilhado com outros candidatos. Por isso a automação roda de forma sequencial (um teste por vez), sem rajadas de requisições. Testes de carga, estresse e segurança estão fora do escopo.
- Os seletores da interface ficam concentrados em `automacao/tests/ui/paginas.ts`. Se algum texto ou elemento da loja mudar, é só ajustar esse arquivo.
