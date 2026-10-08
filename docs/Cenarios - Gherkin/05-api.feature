# language: pt
@api
Funcionalidade: API da Verzel Store
  Como consumidor da API da Verzel Store
  Quero consultar produtos, calcular o carrinho e criar pedidos
  Para que os valores e as validações sigam as regras da entrega VZS-142

  Contexto:
    Dado que a API da Verzel Store está disponível em "/api"

  # ---------- Produtos ----------

  @TC020 @produtos
  Cenário: Listar todos os produtos
    Quando envio uma requisição GET para "/api/produtos"
    Então a resposta tem status 200
    E a lista contém 8 produtos, de "P001" a "P008"
    E cada produto tem os campos "id", "nome", "descricao", "categoria" e "preco"

  @TC020 @produtos
  Cenário: Consultar um produto existente
    Quando envio uma requisição GET para "/api/produtos/P001"
    Então a resposta tem status 200
    E o campo "nome" é "Camiseta Essencial"
    E o campo "preco" é 59.9

  @TC020 @produtos
  Cenário: Consultar um produto inexistente
    Quando envio uma requisição GET para "/api/produtos/P999"
    Então a resposta tem status 404
    E o campo "erro.codigo" é "PRODUTO_NAO_ENCONTRADO"

  # ---------- Cálculo do carrinho ----------

  @TC021 @CA01 @CA06 @CA11 @calculo
  Cenário: Cálculo do carrinho com cupom e frete grátis (exemplo da documentação)
    Quando envio uma requisição POST para "/api/carrinho/calcular" com o corpo:
      """
      {
        "itens": [
          { "produtoId": "P002", "quantidade": 1 },
          { "produtoId": "P004", "quantidade": 2 }
        ],
        "cupom": "BEMVINDO10"
      }
      """
    Então a resposta tem status 200
    E o campo "subtotal" é 239.7
    E o campo "desconto" é 23.97
    E o campo "frete" é 0
    E o campo "freteGratis" é true
    E o campo "valorFaltanteFreteGratis" é 0
    E o campo "total" é 215.73
    E o campo "cupom.aplicado" é true

  @TC022 @CA06 @calculo
  Cenário: Subtotal exatamente R$ 200,00 tem frete grátis
    Quando envio uma requisição POST para "/api/carrinho/calcular" com o corpo:
      """
      { "itens": [ { "produtoId": "P005", "quantidade": 2 } ] }
      """
    Então a resposta tem status 200
    E o campo "subtotal" é 200
    E o campo "frete" é 0
    E o campo "freteGratis" é true
    E o campo "valorFaltanteFreteGratis" é 0
    E o campo "total" é 200

  @TC022 @CA07 @calculo
  Cenário: Subtotal de R$ 199,80 cobra frete fixo
    Quando envio uma requisição POST para "/api/carrinho/calcular" com o corpo:
      """
      {
        "itens": [
          { "produtoId": "P002", "quantidade": 1 },
          { "produtoId": "P001", "quantidade": 1 }
        ]
      }
      """
    Então a resposta tem status 200
    E o campo "subtotal" é 199.8
    E o campo "frete" é 19.9
    E o campo "freteGratis" é false
    E o campo "valorFaltanteFreteGratis" é 0.2
    E o campo "total" é 219.7

  @TC023 @CA02 @cupom @calculo
  Cenário: Cupom em minúsculas e com espaços é aceito no cálculo
    Quando envio uma requisição POST para "/api/carrinho/calcular" com o corpo:
      """
      {
        "itens": [ { "produtoId": "P005", "quantidade": 1 } ],
        "cupom": "  bemvindo10  "
      }
      """
    Então a resposta tem status 200
    E o campo "cupom.aplicado" é true
    E o campo "desconto" é 10
    E o campo "total" é 109.9

  @TC023 @CA03 @CA04 @cupom @calculo
  Esquema do Cenário: Cupom inexistente ou expirado não gera erro no cálculo
    Quando envio uma requisição POST para "/api/carrinho/calcular" com o corpo:
      """
      {
        "itens": [ { "produtoId": "P005", "quantidade": 1 } ],
        "cupom": "<cupom>"
      }
      """
    Então a resposta tem status 200
    E o campo "cupom.aplicado" é false
    E o campo "desconto" é 0
    E o campo "cupom.mensagem" é "<mensagem>"

    Exemplos:
      | cupom     | mensagem         |
      | XYZ123    | Cupom inválido.  |
      | VERAO2026 | Cupom expirado.  |

  @TC024 @CA10 @quantidade
  Cenário: Quantidade máxima de 5 unidades é aceita no cálculo
    Quando envio uma requisição POST para "/api/carrinho/calcular" com o corpo:
      """
      { "itens": [ { "produtoId": "P003", "quantidade": 5 } ] }
      """
    Então a resposta tem status 200
    E o campo "subtotal" é 949.5
    E o campo "total" é 949.5

  @TC024 @CA10 @quantidade
  Esquema do Cenário: Mais de 5 unidades é rejeitado no cálculo e no pedido
    Quando envio uma requisição POST para "<rota>" com o corpo:
      """
      <corpo>
      """
    Então a resposta tem status 422
    E o campo "erro.codigo" é "QUANTIDADE_MAXIMA_EXCEDIDA"
    E o campo "erro.campo" é "itens[0].quantidade"

    Exemplos:
      | rota                   | corpo                                                                                                                                             |
      | /api/carrinho/calcular | {"itens":[{"produtoId":"P003","quantidade":6}]}                                                                                                   |
      | /api/pedidos           | {"cliente":{"nome":"Maria Silva","email":"maria@exemplo.com","cep":"01310-100"},"itens":[{"produtoId":"P003","quantidade":6}]}                    |

  @TC025 @quantidade
  Esquema do Cenário: Quantidades inválidas são rejeitadas
    Quando envio uma requisição POST para "/api/carrinho/calcular" com o corpo:
      """
      { "itens": [ { "produtoId": "P001", "quantidade": <quantidade> } ] }
      """
    Então a resposta tem status 422
    E o campo "erro.codigo" é "QUANTIDADE_INVALIDA"

    Exemplos:
      | quantidade |
      | 0          |
      | -1         |
      | 1.5        |
      | "2"        |
      | null       |

  @TC026 @itens
  Esquema do Cenário: A lista de itens é validada
    Quando envio uma requisição POST para "/api/carrinho/calcular" com o corpo:
      """
      { "itens": <itens> }
      """
    Então a resposta tem status 422
    E o campo "erro.codigo" é "<codigo>"

    Exemplos:
      | itens                                                                 | codigo                 |
      | []                                                                    | ITENS_OBRIGATORIOS     |
      | [{"produtoId":"P999","quantidade":1}]                                 | PRODUTO_NAO_ENCONTRADO |
      | [{"produtoId":"P001","quantidade":1},{"produtoId":"P001","quantidade":2}] | ITEM_DUPLICADO     |
      | ["P001"]                                                              | ITEM_INVALIDO          |

  # ---------- Pedidos ----------

  @TC027 @CA01 @pedidos
  Cenário: Criar um pedido válido com cupom
    Quando envio uma requisição POST para "/api/pedidos" com o corpo:
      """
      {
        "cliente": { "nome": "Maria Silva", "email": "maria@exemplo.com", "cep": "01310-100" },
        "itens": [ { "produtoId": "P005", "quantidade": 1 } ],
        "cupom": "BEMVINDO10"
      }
      """
    Então a resposta tem status 201
    E o campo "numero" segue o formato "VZ-000000"
    E o campo "subtotal" é 100
    E o campo "desconto" é 10
    E o campo "frete" é 19.9
    E o campo "valorFaltanteFreteGratis" é 100
    E o campo "total" é 109.9
    E o campo "cliente.cep" é "01310100"

  @TC028 @CA03 @CA04 @pedidos
  Esquema do Cenário: Pedido com cupom inexistente ou expirado gera erro
    # Diferente do cálculo do carrinho, que responde 200
    Quando envio uma requisição POST para "/api/pedidos" com o corpo:
      """
      {
        "cliente": { "nome": "Maria Silva", "email": "maria@exemplo.com", "cep": "01310-100" },
        "itens": [ { "produtoId": "P005", "quantidade": 1 } ],
        "cupom": "<cupom>"
      }
      """
    Então a resposta tem status 422
    E o campo "erro.codigo" é "<codigo>"

    Exemplos:
      | cupom     | codigo         |
      | XYZ123    | CUPOM_INVALIDO |
      | VERAO2026 | CUPOM_EXPIRADO |

  @TC029 @regra-existente @pedidos
  Cenário: Pedido com dados de cliente inválidos
    Quando envio uma requisição POST para "/api/pedidos" com o corpo:
      """
      {
        "cliente": { "nome": "Maria", "email": "maria@", "cep": "123" },
        "itens": [ { "produtoId": "P005", "quantidade": 1 } ]
      }
      """
    Então a resposta tem status 422
    E o campo "erro.codigo" é "DADOS_INVALIDOS"
    E o campo "campos" detalha os erros de nome, e-mail e CEP

  # ---------- Erros gerais ----------

  @TC030 @erros
  Cenário: Corpo com JSON malformado
    Quando envio uma requisição POST para "/api/carrinho/calcular" com o corpo:
      """
      {"itens": [
      """
    Então a resposta tem status 400
    E o campo "erro.codigo" é "JSON_INVALIDO"

  @TC030 @erros
  Esquema do Cenário: Método não permitido e rota inexistente
    Quando envio uma requisição <metodo> para "<rota>"
    Então a resposta tem status <status>
    E o campo "erro.codigo" é "<codigo>"

    Exemplos:
      | metodo | rota                   | status | codigo                |
      | GET    | /api/carrinho/calcular | 405    | METODO_NAO_PERMITIDO  |
      | GET    | /api/rota-inexistente  | 404    | ROTA_NAO_ENCONTRADA   |
