# language: pt
@ui @cupom
Funcionalidade: Cupom de desconto no carrinho
  Como cliente da Verzel Store
  Quero aplicar um cupom de desconto no carrinho
  Para pagar menos nas minhas compras

  Contexto:
    Dado que estou na Verzel Store com o carrinho vazio

  @TC001 @CA01 @CA09
  Cenário: Aplicar o cupom válido BEMVINDO10
    # O desconto é 10% do subtotal (R$ 100,00) e não incide sobre o frete
    Dado que tenho 1 unidade do produto "P005" no carrinho
    Quando aplico o cupom "BEMVINDO10"
    Então o carrinho exibe a mensagem de cupom aplicado
    E o subtotal é "R$ 100,00"
    E o desconto é "R$ 10,00"
    E o frete é "R$ 19,90"
    E o total é "R$ 109,90"

  @TC002 @CA02
  Esquema do Cenário: O código do cupom não diferencia maiúsculas de minúsculas
    Dado que tenho 1 unidade do produto "P005" no carrinho
    Quando aplico o cupom "<codigo>"
    Então o desconto é "R$ 10,00"
    E o total é "R$ 109,90"

    Exemplos:
      | codigo     |
      | bemvindo10 |
      | BemVindo10 |

  @TC002 @CA02
  Cenário: Espaços no início e no fim do código do cupom são ignorados
    Dado que tenho 1 unidade do produto "P005" no carrinho
    Quando aplico o cupom "BEMVINDO10" digitado com espaços antes e depois
    Então o desconto é "R$ 10,00"
    E o total é "R$ 109,90"

  @TC003 @CA03
  Esquema do Cenário: Cupom inexistente é rejeitado
    # "BEM VINDO10" tem espaço no meio: só os espaços das pontas são ignorados
    Dado que tenho 1 unidade do produto "P005" no carrinho
    Quando aplico o cupom "<codigo>"
    Então a mensagem "Cupom inválido." é exibida
    E nenhum desconto é aplicado
    E o total é "R$ 119,90"

    Exemplos:
      | codigo      |
      | XYZ123      |
      | BEM VINDO10 |

  @TC003 @CA03 @exploratorio
  Cenário: Aplicar o cupom com o campo vazio
    # A documentação não define este comportamento: registrar o que ocorrer
    Dado que tenho 1 unidade do produto "P005" no carrinho
    Quando tento aplicar um cupom deixando o campo vazio
    Então nenhum desconto é aplicado
    E a tela continua funcionando normalmente

  @TC004 @CA04
  Cenário: Cupom expirado é rejeitado
    Dado que tenho 1 unidade do produto "P005" no carrinho
    Quando aplico o cupom "VERAO2026"
    Então a mensagem "Cupom expirado." é exibida
    E nenhum desconto é aplicado
    E o total é "R$ 119,90"

  @TC005 @CA05
  Cenário: Apenas um cupom pode estar aplicado por vez
    Dado que tenho 1 unidade do produto "P005" no carrinho
    E que apliquei o cupom "BEMVINDO10"
    Quando tento aplicar o cupom "VERAO2026" sem remover o cupom atual
    Então os descontos não se acumulam
    E apenas um cupom permanece aplicado

  @TC005 @CA05
  Cenário: Remover o cupom atual para aplicar outro
    Dado que tenho 1 unidade do produto "P005" no carrinho
    E que apliquei o cupom "BEMVINDO10"
    Quando removo o cupom aplicado
    Então o desconto é "R$ 0,00"
    E o total é "R$ 119,90"
    Quando aplico o cupom "VERAO2026"
    Então a mensagem "Cupom expirado." é exibida

  @TC006 @CA01 @CA11
  Cenário: Alterar a quantidade com cupom aplicado recalcula os valores
    Dado que tenho 1 unidade do produto "P005" no carrinho
    E que apliquei o cupom "BEMVINDO10"
    Quando altero a quantidade do produto "P005" para 3
    Então o subtotal é "R$ 300,00"
    E o desconto é "R$ 30,00"
    E o frete é "R$ 0,00"
    E o total é "R$ 270,00"
