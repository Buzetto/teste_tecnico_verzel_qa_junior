# language: pt
@ui @pedido
Funcionalidade: Finalização do pedido
  Como cliente da Verzel Store
  Quero finalizar meu pedido informando meus dados
  Para receber minha compra pagando na entrega

  Contexto:
    Dado que estou na Verzel Store com o carrinho vazio

  @TC014 @CA01
  Cenário: Finalizar um pedido válido com cupom
    Dado que tenho 1 unidade do produto "P005" no carrinho
    E que apliquei o cupom "BEMVINDO10"
    Quando finalizo o pedido informando nome "Maria Silva", e-mail "maria@exemplo.com" e CEP "01310-100"
    Então o pedido é confirmado com um número no formato "VZ-000000"
    E o desconto é "R$ 10,00"
    E o frete é "R$ 19,90"
    E o total é "R$ 109,90"
    E não existe etapa de pagamento online, pois o pagamento é feito na entrega

  @TC015 @regra-existente
  Cenário: Nome sem sobrenome é rejeitado
    Dado que tenho 1 unidade do produto "P005" no carrinho
    Quando finalizo o pedido informando nome "Maria", e-mail "maria@exemplo.com" e CEP "01310-100"
    Então o pedido não é confirmado
    E é exibido um erro indicando que o nome precisa ter nome e sobrenome

  @TC016 @regra-existente
  Esquema do Cenário: E-mail em formato inválido é rejeitado
    Dado que tenho 1 unidade do produto "P005" no carrinho
    Quando finalizo o pedido informando nome "Maria Silva", e-mail "<email>" e CEP "01310-100"
    Então o pedido não é confirmado
    E é exibido um erro no campo de e-mail

    Exemplos:
      | email         |
      | maria         |
      | maria@        |
      | maria@exemplo |

  @TC017 @regra-existente
  Esquema do Cenário: CEP válido é aceito com ou sem hífen
    Dado que tenho 1 unidade do produto "P005" no carrinho
    Quando finalizo o pedido informando nome "Maria Silva", e-mail "maria@exemplo.com" e CEP "<cep>"
    Então o pedido é confirmado com um número no formato "VZ-000000"

    Exemplos:
      | cep       |
      | 01310-100 |
      | 01310100  |

  @TC018 @regra-existente
  Esquema do Cenário: CEP inválido é rejeitado
    Dado que tenho 1 unidade do produto "P005" no carrinho
    Quando finalizo o pedido informando nome "Maria Silva", e-mail "maria@exemplo.com" e CEP "<cep>"
    Então o pedido não é confirmado
    E é exibido um erro no campo de CEP

    Exemplos:
      | cep       | motivo           |
      | 0131010   | 7 dígitos        |
      | 013101001 | 9 dígitos        |
      | 0131A100  | contém uma letra |

  @TC019 @exploratorio
  Cenário: Tentar finalizar com o carrinho vazio
    # A documentação não define este comportamento: registrar o que ocorrer
    Quando tento finalizar o pedido sem nenhum produto no carrinho
    Então o pedido não é confirmado
    E nenhum número de pedido é gerado
